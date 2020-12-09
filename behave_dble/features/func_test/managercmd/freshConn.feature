# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2020/9/10
#modified by wujinling at 2020/12/09

Feature:#test fresh backend connection pool

  Scenario: #Use check session transaction ISOLATION level for any changes to confirm whether the connection pool has been refreshed
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level REPEATABLE READ             | success    | db1 |
    Given execute sql in "mysql-master2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level REPEATABLE READ             | success    | db1 |
    Given execute sql in "mysql-slave1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level REPEATABLE READ             | success    | db1 |
    Given execute sql in "mysql-slave2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level REPEATABLE READ             | success    | db1 |
    Given Restart dble in "dble-1" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="150" minCon="10" readWeight="1" primary="true"/>
          <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="150" minCon="10" readWeight="1"/>
          <dbInstance name="hostM3" password="111111" url="172.100.9.3:3306" user="test" maxCon="150" minCon="10" readWeight="2"/>
      </dbGroup>
    """
    Given execute admin cmd "reload @@config_all" success
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "mysql-master2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "mysql-slave1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "mysql-slave2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql      | expect            | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1   | success          | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int)   | success          | schema1 |
      | conn_0 | False    | begin   | success          | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1),(2),(3),(4)    | success          | schema1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | fresh conn where dbGroup ='ha_group2' and dbInstance='hostM2' | success |
    # ha_group2 master not fresh session.tx_isolation is old
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  hasStr{REPEATABLE-READ}         | schema1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | fresh conn where dbGroup ='ha_group2' and dbInstance='hostM1,hostM3' | success |
    #ha_group2 master fresh session.tx_isolation is new
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}         | schema1 |
    # ha_group1 not fresh session.tx_isolation is old
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}         | schema1 |
    #connection in Transaction is old
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect                  | db      |
      | conn_0 | False   | SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}         | schema1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                        | expect  |
      | fresh conn where dbGroup ='ha_group1' | success |
    # ha_group1 fresh session.tx_isolation is new
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect                                 | db      |
      | conn_1 | True    | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}         | schema1 |
    #connection in Transaction is old
    Then execute sql in "dble-1" in "user" mode                               
      | conn   | toClose | sql                              | expect                         | db      |
      | conn_0 | False   | SELECT @@session.tx_isolation | has{('REPEATABLE-READ',),} | schema1 |
      | conn_0 | True    | commit                           | success                       | schema1 |
    Then execute sql in "dble-1" in "user" mode                               
      | conn   | toClose | sql                               | expect                       | db      |
      | conn_0 | True    | SELECT @@session.tx_isolation | has{('REPEATABLE-READ',),} | schema1 |
    Given execute sql in "dble-1" in "user" mode                              
      | conn   | toClose | sql                                                   | expect  | db      |
      | conn_0 | False   | begin                                                 | success | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1),(2),(3),(4) | success | schema1 |
    Given execute sql in "mysql-master1"                                      
      | conn   | toClose | sql                                                           | expect  | db  |
      | conn_1 | True    | set global transaction ISOLATION level REPEATABLE READ | success | db1 |
    Given execute sql in "mysql-master2"                                      
      | conn   | toClose | sql                                                           | expect  | db  |
      | conn_1 | True    | set global transaction ISOLATION level REPEATABLE READ | success | db1 |
    Given execute sql in "mysql-slave1"                                       
      | conn   | toClose | sql                                                           | expect  | db  |
      | conn_1 | True    | set global transaction ISOLATION level REPEATABLE READ | success | db1 |
    Given execute sql in "mysql-slave2"                                       
      | conn   | toClose | sql                                                           | expect  | db  |
      | conn_1 | True    | set global transaction ISOLATION level REPEATABLE READ | success | db1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | fresh conn where dbGroup ='ha_group1' and dbInstance='hostM1,hostM1' | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}         | schema1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | fresh conn where dbGroup ='ha_group2' and dbInstance='hostM1,hostM1,hostM2' | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}         | schema1 |
    When execute sql in "dble-1" in "admin" mode                              
      | sql                                                | expect  |
      | fresh conn forced where dbGroup ='ha_group1' | success |
    When execute sql in "dble-1" in "admin" mode                              
      | sql                                                | expect  |
      | fresh conn forced where dbGroup ='ha_group2' | success |
    Then execute sql in "dble-1" in "user" mode                               
      | conn   | toClose | sql                              | expect                        | db      |
      | conn_1 | True    | SELECT @@session.tx_isolation | has{('REPEATABLE-READ',),} | schema1 |

  @btrace @cur
  Scenario: #execute fresh command during executing reload command, fresh command will return error #2
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
    Given update file content "./assets/BtraceFreshConnLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /reloadWithoutCluster/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceFreshConnLock.java" in "dble-1"
    #将结果存在变量中，然后获取结果
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose | sql                                       |
      | root | 111111 | conn_0 | True    | reload @@config_all |
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    get reload lock
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect                                                                                  |
      | conn_1 | True    | fresh conn where dbGroup ='ha_group1'            | may be other mutex events that cause interrupt, try again later                 |
    Given stop btrace script "BtraceFreshConnLock.java" in "dble-1"
    Given destroy btrace threads list
    #sleep 10s for waiting btrace end and fresh command return ok
    Given sleep "10" seconds
    #检查fresh 返回ok
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    XXXX
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect           |
      | conn_2 | True    | fresh conn where dbGroup ='ha_group1'            | success          |
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"

  @btrace
  Scenario: #fresh connection multi-times at the same time, other fresh command will return error #3
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
    Given update file content "./assets/BtraceFreshConnLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /freshConnGetRealodLocekAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceFreshConnLock.java" in "dble-1"
    #将结果存在变量中，然后获取结果
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose | sql                                       |
      | root | 111111 | conn_0 | True    | fresh conn where dbGroup ='ha_group1' |
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    freshConnGetRealodLocekAfter
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect                                                                                  |
      | conn_1 | True    | fresh conn where dbGroup ='ha_group1'            | may be other mutex events that cause interrupt, try again later                 |
    Given stop btrace script "BtraceFreshConnLock.java" in "dble-1"
    Given destroy btrace threads list
    #sleep 10s for waiting btrace end and the first fresh command return ok
    Given sleep "10" seconds
    #检查fresh 返回ok
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    XXXX
    """
    #after the first fresh command return ok, then execute other fresh command will return ok
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect           |
      | conn_2 | True    | fresh conn where dbGroup ='ha_group1'            | success          |
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"

  @btrace
  Scenario: #execute sql during executing fresh command, sql will hang #4
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
    Given update file content "./assets/BtraceFreshConnLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /stopConnGetFrenshLocekAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceFreshConnLock.java" in "dble-1"
    #将结果存在变量中，然后获取结果
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose | sql                                       |
      | root | 111111 | conn_0 | True    | fresh conn where dbGroup ='ha_group1' |
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    stopConnGetFrenshLocekAfter
    """
    #执行sql 语句hang住
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | expect      | db      |
      | conn_1 | True    | drop table if exists sharding_4_t1 | hang | schema1 |
    Given stop btrace script "BtraceFreshConnLock.java" in "dble-1"
    Given destroy btrace threads list
    #sleep 10s for waiting btrace end and the first fresh command return ok
    Given sleep "10" seconds
    #hang完之后sql返回ok
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    XXXX
    """
    #after the first fresh command return ok, then execute other fresh command will return ok
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | expect      | db      |
      | conn_2 | True    | drop table if exists sharding_4_t1  | success     | schema1 |
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"

  @btrace
  Scenario: #execute fresh command during executing sql, fresh command will hang #5
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
    Given update file content "./assets/BtraceFreshConnLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /getConnGetFrenshLocekAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceFreshConnLock.java" in "dble-1"
    #将结果存在变量中，然后获取结果
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                                    | db      |
      | conn_0 | False   | create table if not exists sharding_4_t1(id int) | schema1 |
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    freshConnGetRealodLocekAfter
    """
    #hang完之后fresh返回ok
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect                                                                                  |
      | conn_1 | True    | fresh conn where dbGroup ='ha_group1'            | hang                                                         |

    Given stop btrace script "BtraceFreshConnLock.java" in "dble-1"
    Given destroy btrace threads list
    #sleep 10s for waiting btrace end and the first fresh command return ok
    Given sleep "10" seconds
    #检查sql 返回ok
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    XXXX
    """
    #after the sql return ok, then execute other fresh command will return ok
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect           |
      | conn_2 | True    | fresh conn where dbGroup ='ha_group1'            | success          |
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"

















