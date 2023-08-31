# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2022/10/18
@skip #DBLE0REQ-1867未合并
Feature: connection pool basic test, from DBLE0REQ-1867
  Background: config for this test suites
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_8_t1" shardingNode="dn1,dn2,dn3,dn4,dn5,dn6,dn7,dn8" function="hash-eight" shardingColumn="id"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
    <shardingNode dbGroup="ha_group1" database="db4" name="dn7" />
    <shardingNode dbGroup="ha_group2" database="db4" name="dn8" />
    <function class="Hash" name="hash-eight">
        <property name="partitionCount">8</property>
        <property name="partitionLength">1</property>
    </function>
    """
    #调大心跳周期和扩缩容周期，防止扩缩容周期到了新建连接
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="4" primary="true">
            <property name="heartbeatPeriodMillis">1800000</property>
            <property name="idleTimeout">600000</property>
            <property name="timeBetweenEvictionRunsMillis">1800000</property>
        </dbInstance>
    </dbGroup>
    """
    #关闭XA事务定期检测周期（默认300s），防止启动后自动新建一根连接，为了方便测试，所以先关闭此功能。from DBLE0REQ-1614
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DbackendProcessorExecutor=8
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                       | expect                     | db      |
      | conn_0 | False   | drop table if exists sharding_8_t1                                        | success                    | schema1 |
      | conn_0 | True    | create table sharding_8_t1(id int,name varchar(20))                       | success                    | schema1 |
      | conn_0 | True    | insert into sharding_8_t1 values(2,'2'),(4,'4'),(6,'6'),(8,'8')           | success                    | schema1 |
      | conn_0 | True    | insert into sharding_8_t1 values(10,'10'),(12,'12'),(14,'14'),(16,'16')   | success                    | schema1 |
      | conn_0 | True    | insert into sharding_8_t1 values(18,'18'),(20,'20')                       | success                    | schema1 |
    #确保测试前没有启动、reload并发，导致多一根连接的情况，DBLE0REQ-1925
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'    | success       | dble_information  |
    Then kill the redundant connections if "rs_1" is more then expect value "4" in "mysql-master1"

  @CRITICAL @btrace @auto_retry
  Scenario: borrowDirectly方法中窃取到1条非排队线程创建的连接（即空闲连接），且排队线程等于1，窃取线程不会新建1条连接  #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4,6)         | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_8_t1 where id=8                 | success                    | schema1 |
    #add btrace before create connection in borrow function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                             | db      |
      | conn_3 | True    | select * from sharding_8_t1 where id=2          | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "1" times
    """
    get into newConnectionBorrow1
    """
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                         | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'           |  length{(0)}  | dble_information  |
    Given prepare a thread execute sql "commit" with "conn_2"
    #等待2s，使窃取线程能够获取到commit释放的连接
    Given sleep "2" seconds
    #返回结果会hang住一会，原因是commit在把连接回收时，如果有排队线程在的话，需要连接被排队线程取走了才会回收成功，不然会一直hang住
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect                     | db      |
      | conn_4 | True    | select * from sharding_8_t1 where id=4                     | success                    | schema1 |
    #等待10s，commit返回结果
    Given sleep "10" seconds
    Given destroy btrace threads list
    Given destroy sql threads list
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    2	2
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                     | length{(5)}  | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(2)}  | dble_information  |

  @CRITICAL @btrace @auto_retry
  Scenario: borrowDirectly方法中窃取到1条非排队线程创建的连接（即空闲连接），且排队线程大于1，窃取线程不会新建1条连接 #2
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4,6)         | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_8_t1 where id=8                 | success                    | schema1 |
    #add btrace before create connection in borrow function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                  | db      |
      | conn_3 | True    | select * from sharding_8_t1 where id in (10,12,14)   | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "3" times
    """
    get into newConnectionBorrow1
    """
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                         | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'           | length{(0)}  | dble_information  |
    Given prepare a thread execute sql "commit" with "conn_2"
    Then execute "user" cmd  in "dble-1" at background with "1" in file name
      | conn   | toClose | sql                                                | db      |
      | conn_4 | True    | select * from sharding_8_t1 where id=16            | schema1 |
    Given sleep "10" seconds
    Given destroy sql threads list
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    12	12
    14	14
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query_1.log" in host "dble-1"
    """
    16	16
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                     | length{(7)}  | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(4)}  | dble_information  |

  @CRITICAL @btrace @auto_retry
  Scenario: borrowDirectly方法中窃取到2条非排队线程创建的连接（即空闲连接），且排队线程大于1，窃取线程不会新建2条连接 #3
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4)           | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_8_t1 where id=6                 | success                    | schema1 |
      | conn_3 | False   | begin                                                  | success                    | schema1 |
      | conn_3 | False   | select * from sharding_8_t1 where id=8                 | success                    | schema1 |
    #add btrace before create connection in borrow function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                  | db      |
      | conn_4 | True    | select * from sharding_8_t1 where id in (10,12,14)   | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "3" times
    """
    get into newConnectionBorrow1
    """
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                         | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(0)}  | dble_information  |
    Given prepare a thread execute sql "commit" with "conn_2"
    Given prepare a thread execute sql "commit" with "conn_3"
    Then execute "user" cmd  in "dble-1" at background with "1" in file name
      | conn   | toClose | sql                                                   | db      |
      | conn_5 | True    | select * from sharding_8_t1 where id in (16,18)       | schema1 |
    Given sleep "25" seconds
    Given destroy sql threads list
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    12	12
    14	14
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query_1.log" in host "dble-1"
    """
    16	16
    18	18
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                     | length{(7)}  | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(5)}  | dble_information  |

  @CRITICAL @btrace @auto_retry
  Scenario: borrowDirectly方法中窃取到1条排队线程创建的连接，且排队线程等于1，窃取线程会新建1条连接 #4
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4,6,8)       | success                    | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(0)}  | dble_information  |
    #add btrace after create connection and before get connection in borrowDirectly function
    Given delete file "/opt/dble/newConnectionAfter.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java.log" on "dble-1"
    Given update file content "./assets/newConnectionAfter.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionAfter.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                             | db      |
      | conn_2 | True    | select * from sharding_8_t1 where id=10         | schema1 |
    Then check btrace "newConnectionAfter.java" output in "dble-1" with "1" times
    """
    get into newConnectionAfter
    """
    Given stop btrace script "newConnectionAfter.java" in "dble-1"
    Given destroy btrace threads list
    Then execute "user" cmd  in "dble-1" at background with "1" in file name
      | conn   | toClose | sql                                                | db      |
      | conn_3 | True    | select * from sharding_8_t1 where id=12            | schema1 |
    #等待桩结束
    Given sleep "15" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query_1.log" in host "dble-1"
    """
    12	12
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                     | length{(6)}   | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(2)}   | dble_information  |

  @CRITICAL @btrace @auto_retry
  Scenario: borrowDirectly方法中窃取到1条排队线程创建的连接，且排队线程大于1，窃取线程会新建1条连接 #5
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4,6,8)       | success                    | schema1 |
    #add btrace after create connection and before get connection in borrowDirectly function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java.log" on "dble-1"
    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(2000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Given update file content "./assets/newConnectionAfter.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionAfter.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                  | db      |
      | conn_2 | True    | select * from sharding_8_t1 where id in (10,12,14)   | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "3" times
    """
    get into newConnectionBorrow1
    """
    Then check btrace "newConnectionAfter.java" output in "dble-1" with "3" times
    """
    get into newConnectionAfter
    """
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    Given stop btrace script "newConnectionAfter.java" in "dble-1"
    Given destroy btrace threads list
    Then execute "user" cmd  in "dble-1" at background with "1" in file name
      | conn   | toClose | sql                                                 | db      |
      | conn_3 | True    | select * from sharding_8_t1 where id=16            | schema1 |
    Given sleep "15" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    12	12
    14	14
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query_1.log" in host "dble-1"
    """
    16	16
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                     | length{(8)}  | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(4)}  | dble_information  |

  @CRITICAL @btrace @auto_retry
  Scenario: borrowDirectly方法中窃取到2条排队线程创建的连接，且排队线程大于1，窃取线程窃会新建2条连接 #6
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4,6,8)       | success                    | schema1 |
    #add btrace after create connection and before get connection in borrowDirectly function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java.log" on "dble-1"
    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(2000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Given update file content "./assets/newConnectionAfter.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionAfter.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                  | db      |
      | conn_2 | True    | select * from sharding_8_t1 where id in (10,12,14)   | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "3" times
    """
    get into newConnectionBorrow1
    """
    Then check btrace "newConnectionAfter.java" output in "dble-1" with "3" times
    """
    get into newConnectionAfter
    """
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    Given stop btrace script "newConnectionAfter.java" in "dble-1"
    Given destroy btrace threads list
    Then execute "user" cmd  in "dble-1" at background with "1" in file name
      | conn   | toClose | sql                                                        | db      |
      | conn_3 | True    | select * from sharding_8_t1 where id in(16,18)             | schema1 |
    Given sleep "18" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    12	12
    14	14
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query_1.log" in host "dble-1"
    """
    16	16
    18	18
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                     | length{(9)}  | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(5)}  | dble_information  |

  @CRITICAL @btrace @auto_retry
  Scenario: borrow方法中窃取到1条非排队线程创建的连接（即空闲连接），且排队线程等于1，窃取线程不会新建1条连接 #7
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4,6)         | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_8_t1 where id=8                 | success                    | schema1 |
    #add btrace before create connection in borrow function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java.log" on "dble-1"
    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                             | db      |
      | conn_3 | True    | select * from sharding_8_t1 where id=10         | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "1" times
    """
    get into newConnectionBorrow1
    """
    #窃取线程
    Given update file content "./assets/borrowConnectionBefore.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /borrowConnectionBefore/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "borrowConnectionBefore.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background with "1" in file name
      | conn   | toClose | sql                                             | db      |
      | conn_4 | True    | select * from sharding_8_t1 where id=12         | schema1 |
    Then check btrace "borrowConnectionBefore.java" output in "dble-1" with "1" times
    """
    get into borrowConnectionBefore
    """
    Given stop btrace script "borrowConnectionBefore.java" in "dble-1"
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    Given destroy btrace threads list
    Given prepare a thread execute sql "commit" with "conn_2"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(1)}  | dble_information  |
    Given sleep "20" seconds
    Given destroy btrace threads list
    Given destroy sql threads list
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query_1.log" in host "dble-1"
    """
    12	12
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                     | length{(5)}  | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(2)}  | dble_information  |


  @CRITICAL @btrace @auto_retry
  Scenario: borrow方法中窃取到1条非排队线程创建的连接（即空闲连接），且排队线程大于1，窃取线程不会新建1条连接 #8
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4,6)         | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_8_t1 where id=8                 | success                    | schema1 |
    #add btrace before create connection in borrow function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java.log" on "dble-1"
    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                | db      |
      | conn_3 | True    | select * from sharding_8_t1 where id in(10,12,14)  | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "3" times
    """
    get into newConnectionBorrow1
    """
    #窃取线程
    Given update file content "./assets/borrowConnectionBefore.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /borrowConnectionBefore/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "borrowConnectionBefore.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background with "1" in file name
      | conn   | toClose | sql                                             | db      |
      | conn_4 | True    | select * from sharding_8_t1 where id=16         | schema1 |
    Then check btrace "borrowConnectionBefore.java" output in "dble-1" with "1" times
    """
    get into borrowConnectionBefore
    """
    Given stop btrace script "borrowConnectionBefore.java" in "dble-1"
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    Given prepare a thread execute sql "commit" with "conn_2"
    Given sleep "20" seconds
    Given destroy btrace threads list
    Given destroy sql threads list
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    12	12
    14	14
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query_1.log" in host "dble-1"
    """
    16	16
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect       | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                     | length{(7)}  | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(4)}  | dble_information  |


  @CRITICAL @btrace @auto_retry
  Scenario: borrow方法中窃取到2条非排队线程创建的连接（即空闲连接），且排队线程大于1，窃取线程不会新建2条连接 #9
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4)           | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_8_t1 where id=6                 | success                    | schema1 |
      | conn_3 | False   | begin                                                  | success                    | schema1 |
      | conn_3 | False   | select * from sharding_8_t1 where id=8                 | success                    | schema1 |
    #add btrace before create connection in borrow function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java.log" on "dble-1"
    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                | db      |
      | conn_4 | True    | select * from sharding_8_t1 where id in(10,12,14)  | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "3" times
    """
    get into newConnectionBorrow1
    """
    #窃取线程
    Given update file content "./assets/borrowConnectionBefore.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /borrowConnectionBefore/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "borrowConnectionBefore.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background with "1" in file name
      | conn   | toClose | sql                                             | db      |
      | conn_5 | True    | select * from sharding_8_t1 where id in(16,18)  | schema1 |
    Then check btrace "borrowConnectionBefore.java" output in "dble-1" with "2" times
    """
    get into borrowConnectionBefore
    """
    Given stop btrace script "borrowConnectionBefore.java" in "dble-1"
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    Given prepare a thread execute sql "commit" with "conn_2"
    Given prepare a thread execute sql "commit" with "conn_3"
    Given sleep "30" seconds
    Given destroy btrace threads list
    Given destroy sql threads list
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    12	12
    14	14
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query_1.log" in host "dble-1"
    """
    16	16
    18	18
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect       | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                     | length{(7)}  | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(5)}  | dble_information  |

  @CRITICAL @btrace @auto_retry
  Scenario: borrow方法中窃取到1条排队线程创建的连接，且排队线程为1，窃取线程会新建1条连接 #10
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4,6,8)       | success                    | schema1 |
    #add btrace before create connection in borrow function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java.log" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java.log" on "dble-1"
    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                             | db      |
      | conn_2 | True    | select * from sharding_8_t1 where id=10         | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "1" times
    """
    get into newConnectionBorrow1
    """
    #窃取线程
    Given update file content "./assets/borrowConnectionBefore.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /borrowConnectionBefore/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "borrowConnectionBefore.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background with "1" in file name
      | conn   | toClose | sql                                            | db      |
      | conn_3 | True    | select sleep(30)                               | schema1 |
    Then check btrace "borrowConnectionBefore.java" output in "dble-1" with "1" times
    """
    get into borrowConnectionBefore
    """
    Given update file content "./assets/newConnectionAfter.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(25000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionAfter.java" in "dble-1"
    Then check btrace "newConnectionAfter.java" output in "dble-1" with "1" times
    """
    get into newConnectionAfter
    """
    #进入newConnectionAfter方法表示newConnectionBorrow1结束
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    #大于5S(6s)后连接会被窃取线程取走，且窃取线程会并发新建一条新连接
    Given sleep "6" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect       | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(1)}  | dble_information  |
    #等待select sleep(30)语句返回结果，关闭其他桩
    Given sleep "55" seconds
    Given stop btrace script "borrowConnectionBefore.java" in "dble-1"
    Given stop btrace script "newConnectionAfter.java" in "dble-1"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble_user_query_1.log" in host "dble-1"
    """
    ERROR
    """
#    Given sleep "20" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                | expect       | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state in ('idle','in_use') and remote_addr='172.100.9.5'    | length{(2)}  | dble_information  |
    #日志结束

  @CRITICAL @btrace @auto_retry
  Scenario: borrow方法中窃取到1条排队线程创建的连接，且排队线程大于1，窃取线程会新建1条连接 #11
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4,6,8)       | success                    | schema1 |
    #add btrace before create connection in borrow function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java.log" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java.log" on "dble-1"

    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                  | db      |
      | conn_2 | True    | select * from sharding_8_t1 where id in(10,12,14)    | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "3" times
    """
    get into newConnectionBorrow1
    """
    #窃取线程
    Given update file content "./assets/borrowConnectionBefore.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /borrowConnectionBefore/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "borrowConnectionBefore.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background with "1" in file name
      | conn   | toClose | sql                                                | db      |
      | conn_3 | True    | select sleep(30)                                   | schema1 |
    Then check btrace "borrowConnectionBefore.java" output in "dble-1" with "1" times
    """
    get into borrowConnectionBefore
    """
    Given update file content "./assets/newConnectionAfter.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(25000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionAfter.java" in "dble-1"
    Then check btrace "newConnectionAfter.java" output in "dble-1" with "3" times
    """
    get into newConnectionAfter
    """
    #进入newConnectionAfter方法表示newConnectionBorrow1结束
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    #大于5S(5s)后连接会被窃取线程取走，并且窃取线程会并发新建一条新连接
    Given sleep "6" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect       | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(3)}  | dble_information  |
    #等待select sleep(30)语句返回结果，关闭桩其他桩：30+30-6
    Given sleep "55" seconds
    Given stop btrace script "borrowConnectionBefore.java" in "dble-1"
    Given stop btrace script "newConnectionAfter.java" in "dble-1"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    12	12
    14	14
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble_user_query_1.log" in host "dble-1"
    """
    ERROR
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect       | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                     | length{(8)}  | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(4)}  | dble_information  |

  @CRITICAL @btrace @auto_retry
  Scenario: borrow方法中窃取到2条排队线程创建的连接，且排队线程大于1，窃取线程会新建2条连接 #12
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4,6,8)       | success                    | schema1 |
    #add btrace before create connection in borrow function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java.log" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java.log" on "dble-1"
    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                | db      |
      | conn_2 | True    | select * from sharding_8_t1 where id in(10,12,14)  | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "3" times
    """
    get into newConnectionBorrow1
    """
    #窃取线程
    Given update file content "./assets/borrowConnectionBefore.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /borrowConnectionBefore/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "borrowConnectionBefore.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background with "1" in file name
      | conn   | toClose | sql                                               | db      |
      | conn_3 | True    | select * from sharding_8_t1 where id in(16,18)    | schema1 |
    Then check btrace "borrowConnectionBefore.java" output in "dble-1" with "2" times
    """
    get into borrowConnectionBefore
    """
    Given update file content "./assets/newConnectionAfter.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(40000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionAfter.java" in "dble-1"
    Then check btrace "newConnectionAfter.java" output in "dble-1" with "3" times
    """
    get into newConnectionAfter
    """
    #进入newConnectionAfter方法表示newConnectionBorrow1结束
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    #关闭桩其他桩
    Given sleep "50" seconds
    Given stop btrace script "borrowConnectionBefore.java" in "dble-1"
    Given stop btrace script "newConnectionAfter.java" in "dble-1"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    12	12
    14	14
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query_1.log" in host "dble-1"
    """
    16	16
    18	18
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect       | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                     | length{(9)}  | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(5)}  | dble_information  |

  @CRITICAL @btrace @auto_retry
  Scenario: 混合场景：borrowDirectly方法中窃取到2条排队线程创建的连接和1条空闲连接，且排队线程大于1，窃取线程会新建2条连接 #13
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4,6)         | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_8_t1 where id=8                 | success                    | schema1 |
    #add btrace after create connection and before get connection in borrowDirectly function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java.log" on "dble-1"
    Given delete file "/opt/dble/borrowDirectlyConnectionBefore.java" on "dble-1"
    Given delete file "/opt/dble/borrowDirectlyConnectionBefore.java.log" on "dble-1"
    #newConnectionBorrow1处插桩的目的是防止先建的连接被后面的用了，sleep很短的时间使其2个节点都进入新建连接的步骤里
    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(2000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Given update file content "./assets/newConnectionAfter.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionAfter.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                  | db      |
      | conn_3 | True    | select * from sharding_8_t1 where id in(10,12)       | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "2" times
    """
    get into newConnectionBorrow1
    """
    Then check btrace "newConnectionAfter.java" output in "dble-1" with "2" times
    """
    get into newConnectionAfter
    """
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    Given stop btrace script "newConnectionAfter.java" in "dble-1"
    Given prepare a thread execute sql "commit" with "conn_2"
    #sleep 2s，确保commit释放的连接放到连接池
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_4 | False   | begin                                                  | success                    | schema1 |
      | conn_4 | False   | select * from sharding_8_t1 where id=14                | success                    | schema1 |
      | conn_5 | False   | begin                                                  | success                    | schema1 |
      | conn_5 | False   | select * from sharding_8_t1 where id=16                | success                    | schema1 |
      | conn_6 | False   | begin                                                  | success                    | schema1 |
      | conn_6 | False   | select * from sharding_8_t1 where id=18                | success                    | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_4 | True   | commit                                                  | success                    | schema1 |
      | conn_5 | True   | commit                                                  | success                    | schema1 |
      | conn_6 | True   | commit                                                  | success                    | schema1 |
    Given destroy btrace threads list
    Given destroy sql threads list
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    12	12
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                   | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                      | length{(8)}  | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'     | length{(5)}  | dble_information  |

  @CRITICAL @btrace @auto_retry
  Scenario: 混合场景：borrow方法中窃取到2条排队线程创建的连接和1条空闲连接，且排队线程大于1，窃取线程会新建2条连接 #14
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_8_t1 where id in(2,4,6)         | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_8_t1 where id=8                 | success                    | schema1 |
    #add btrace before create connection in borrow function
    Given delete file "/opt/dble/newConnectionBorrow1.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionBorrow1.java.log" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java" on "dble-1"
    Given delete file "/opt/dble/borrowConnectionBefore.java.log" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java" on "dble-1"
    Given delete file "/opt/dble/newConnectionAfter.java.log" on "dble-1"
    Given update file content "./assets/newConnectionBorrow1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionBorrow1/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionBorrow1.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                             | db      |
      | conn_3 | True    | select * from sharding_8_t1 where id in(10,12)  | schema1 |
    Then check btrace "newConnectionBorrow1.java" output in "dble-1" with "2" times
    """
    get into newConnectionBorrow1
    """
    #窃取线程
    Given update file content "./assets/borrowConnectionBefore.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /borrowConnectionBefore/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(25000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "borrowConnectionBefore.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background with "1" in file name
      | conn   | toClose | sql                                                  | db      |
      | conn_4 | True    | select * from sharding_8_t1 where id in(14,16,18)    | schema1 |
    Then check btrace "borrowConnectionBefore.java" output in "dble-1" with "3" times
    """
    get into borrowConnectionBefore
    """
    Given update file content "./assets/newConnectionAfter.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /newConnectionAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "newConnectionAfter.java" in "dble-1"
    Then check btrace "newConnectionAfter.java" output in "dble-1" with "2" times
    """
    get into newConnectionAfter
    """
    #进入newConnectionAfter，表示newConnectionBorrow1结束，关闭桩newConnectionBorrow1
    Given stop btrace script "newConnectionBorrow1.java" in "dble-1"
    Given stop btrace script "borrowConnectionBefore.java" in "dble-1"
    Given stop btrace script "newConnectionAfter.java" in "dble-1"
    Given prepare a thread execute sql "commit" with "conn_2"
    Given sleep "30" seconds
    Given destroy btrace threads list
    Given destroy sql threads list
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    10	10
    12	12
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query_1.log" in host "dble-1"
    """
    14	14
    16	16
    18	18
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect       | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'                     | length{(8)}  | dble_information  |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'    | length{(5)}  | dble_information  |