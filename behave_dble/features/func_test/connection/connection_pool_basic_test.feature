# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2021/02/21

Feature: connection pool basic test

  @CRITICAL
  Scenario: test front-end asynchronous  #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                     | success                    | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20))    | success                    | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(4,'4')                | success                    | schema1 |
      | conn_0 | False   | drop table if exists test                              | success                    | schema1 |
      | conn_0 | False   | create table test(id int,name varchar(20))             | success                    | schema1 |
      | conn_0 | True    | insert into test values(1,'1'),(2,'2'),(3,'3'),(4,'4') | success                    | schema1 |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                                             | expect  | db  |
      | conn_0 | False   | begin                                                           | success | db1 |
      | conn_0 | False   | insert into sharding_4_t1 values(8,'8')                         | success | db1 |
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                           | db      |
      | conn_1 | False   | update sharding_4_t1 set name='jojo'          | schema1 |
    #sleep 5s and check insert sharding_4_t1 still hang
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                            | expect                     | db      |
      | conn_0 | True    | select * from test                                             | success                    | schema1 |
      | conn_0 | True    | select * from sharding_4_t1                                    | hasnot{((8, 'jojo'),)}       | schema1 |

  @CRITICAL
  Scenario: seize connection when available connections are not enough   #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="10" minCon="4" primary="true">
             <property name="heartbeatPeriodMillis">180000</property>
             <property name="timeBetweenEvictionRunsMillis">180000</property>
        </dbInstance>
     </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                     | success                    | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20))    | success                    | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(2,2)                  | success                    | schema1 |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                            | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                            | success                    | schema1 |
    #add btrace before create connection
    Given delete file "/opt/dble/BtraceAboutConnection.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutConnection.java.log" on "dble-1"
    Given update file content "./assets/BtraceAboutConnection.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /getConnection/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceAboutConnection.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                             | db      |
      | conn_3 | False   | select * from sharding_4_t1 where id=2          | schema1 |
    Then check btrace "BtraceAboutConnection.java" output in "dble-1" with "1" times
    """
    getting connection
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    2	2
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect                     | db      |
      | conn_1 | True    | commit                                                     | success                    | schema1 |
    #sleep 5s to wait hang over and then get the released connection
    Given sleep "5" seconds
    Given stop btrace script "BtraceAboutConnection.java" in "dble-1"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
    """
    2	2
    """


  @CRITICAL
  Scenario: test initial connection pool: except heartbeat connection the other connection is in idle status #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                      | expect        | db                |
      | conn_0 | True    | select * from backend_connections where state!='idle' and used_for_heartbeat='false'      | length{(0)}  | dble_information  |
    Then execute admin cmd "reload @@config_all -r"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                      | expect        | db                |
      | conn_0 | True    | select * from backend_connections where state!='idle' and used_for_heartbeat='false'      | length{(0)}  | dble_information  |


  @CRITICAL
  Scenario: connection expansion: kill the connections until the idle connections less than minCon, after timeBetweenEvictionRunsMillis the connections will increase to minCon #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10" primary="true">
             <property name="heartbeatPeriodMillis">180000</property>
             <property name="timeBetweenEvictionRunsMillis">5000</property>
        </dbInstance>
     </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Given execute linux command in "dble-1" and save result in "dble_idle_connections"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} -Ddble_information -e "select remote_processlist_id from backend_connections where used_for_heartbeat='false' and db_instance_name='M1' "
    """
    Given kill mysql conns in "mysql-master1" in "dble_idle_connections"
    #由于kill连接和查询间隔太快，会偶发查询的时候还没kill完成，会查多余预期条数的连接。改成重试查询kill完成了
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                      | expect        | db                |timeout|
      | conn_0 | True    | select * from backend_connections where state='idle' and used_for_heartbeat='false'      | length{(10)}  | dble_information  | 10,0.5|
    #sleep 5s to go into scaling period
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                      | expect       | db                |timeout|
      | conn_0 | True    | select * from backend_connections where state='idle' and used_for_heartbeat='false'      | length{(20)} | dble_information  | 5,1   |

  @CRITICAL
  Scenario: connection expansion: use the active connections until the idle connections less than minCon, after timeBetweenEvictionRunsMillis the connections will increase to minCon #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10" primary="true">
             <property name="heartbeatPeriodMillis">180000</property>
             <property name="timeBetweenEvictionRunsMillis">5000</property>
        </dbInstance>
     </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_idle_connections_10"
      | conn   | toClose | sql                                                                                                                                    | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'  | success       | dble_information  |
    Then kill the redundant connections if "dble_idle_connections_10" is more then expect value "10" in "mysql-master1"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_idle_connections_11"
      | conn   | toClose | sql                                                                                                                                     | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.6'   | success       | dble_information  |
    Then kill the redundant connections if "dble_idle_connections_11" is more then expect value "10" in "mysql-master2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                     | success                    | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20))    | success                    | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(2,2)                  | success                    | schema1 |
      | conn_1 | False   | begin                                                  | success                    | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                            | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                            | success                    | schema1 |
    #sleep 5s to go into scaling period
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect         | db                |timeout|
      | conn_0 | True    | select * from backend_connections where state='idle' and used_for_heartbeat='false'                 | length{(16)}   | dble_information  | 5,1   |
      | conn_0 | True    | select * from backend_connections where state='in use' and used_for_heartbeat='false'               | length{(8)}    | dble_information  |       |


  @CRITICAL
  Scenario: connection shrink: idle connections > minCon and the idle connection's idle time >= idleTimeout, the connection will be  recycle  #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="20" minCon="4" primary="true">
             <property name="heartbeatPeriodMillis">180000</property>
             <property name="idleTimeout">3000</property>
             <property name="timeBetweenEvictionRunsMillis">5000</property>
        </dbInstance>
     </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="20" minCon="4" primary="true">
             <property name="idleTimeout">30000</property>
        </dbInstance>
    </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_idle_connections_20"
      | conn   | toClose | sql                                                                                                                                    | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'  | success       | dble_information  |
    Then kill the redundant connections if "dble_idle_connections_20" is more then expect value "4" in "mysql-master1"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_idle_connections_21"
      | conn   | toClose | sql                                                                                                                                     | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.6'   | success       | dble_information  |
    Then kill the redundant connections if "dble_idle_connections_21" is more then expect value "4" in "mysql-master2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                        | success                    | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20))       | success                    | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(2,2)                     | success                    | schema1 |
      | conn_1 | False   | begin                                                     | success                    | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                               | success                    | schema1 |
      | conn_2 | False   | begin                                                     | success                    | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                               | success                    | schema1 |
      | conn_3 | False   | begin                                                     | success                    | schema1 |
      | conn_3 | False   | select * from sharding_4_t1                               | success                    | schema1 |
      | conn_4 | False   | begin                                                     | success                    | schema1 |
      | conn_4 | False   | select * from sharding_4_t1                               | success                    | schema1 |
      | conn_5 | False   | begin                                                     | success                    | schema1 |
      | conn_5 | False   | select * from sharding_4_t1                               | success                    | schema1 |
      | conn_1 | False   | commit                                                    | success                    | schema1 |
      | conn_2 | False   | commit                                                    | success                    | schema1 |
      | conn_3 | False   | commit                                                    | success                    | schema1 |
      | conn_4 | False   | commit                                                    | success                    | schema1 |
      | conn_5 | False   | commit                                                    | success                    | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                      | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle'      | length{(20)}  | dble_information  |
    #sleep 8s to wait connections idle timeout and into scaling period
    Given sleep "8" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect        | db                |timeout|
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle'     | length{(14)}  | dble_information  |3,1    |


  @CRITICAL
  Scenario: connection shrink: idle connections < minCon and the idle connection's idle time >= idleTimeout, the idle connections will not be  recycle  #7
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="20" minCon="6" primary="true">
             <property name="heartbeatPeriodMillis">180000</property>
             <property name="idleTimeout">3000</property>
             <property name="timeBetweenEvictionRunsMillis">5000</property>
        </dbInstance>
     </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="20" minCon="6" primary="true">
             <property name="idleTimeout">30000</property>
        </dbInstance>
    </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_idle_connections_30"
      | conn   | toClose | sql                                                                                                                                    | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'  | success       | dble_information  |
    Then kill the redundant connections if "dble_idle_connections_30" is more then expect value "6" in "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                  | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20)) | success | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(2,2)               | success | schema1 |
      | conn_1 | False   | begin                                               | success | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                         | success | schema1 |
      | conn_2 | False   | begin                                               | success | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                         | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_A"
      | conn   | toClose | sql                                                                                                               | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5' | length{(2)}   | dble_information  |
    #sleep 8s to wait connections idle timeout and into scaling period
    Given sleep "8" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_B"
      | conn   | toClose | sql                                                                                                               | expect        | db                |timeout|
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5' | length{(6)}   | dble_information  |3,1    |
    #idle_connection_B contains idle_connection_A
    Then check resultsets "idle_connection_B" including resultset "idle_connection_A" in following columns
      | column                | column_index |
      | backend_conn_id       | 0            |
      | db_group_name         | 1            |
      | db_instance_name      | 2            |
      | remote_processlist_id | 5            |
      | state                 | 18           |

  @CRITICAL
  Scenario: connection shrink: idle connections = minCon and the idle connection's idle time >= idleTimeout, the idle connections will not be  recycle  #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="20" minCon="6" primary="true">
             <property name="heartbeatPeriodMillis">180000</property>
             <property name="idleTimeout">1000</property>
             <property name="timeBetweenEvictionRunsMillis">5000</property>
        </dbInstance>
     </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="20" minCon="6" primary="true">
             <property name="idleTimeout">1000</property>
        </dbInstance>
    </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_idle_connections_40"
      | conn   | toClose | sql                                                                                                                                    | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'  | success       | dble_information  |
    Then kill the redundant connections if "dble_idle_connections_40" is more then expect value "6" in "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                  | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20)) | success | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(2,2)               | success | schema1 |
      | conn_1 | False   | begin                                               | success | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                         | success | schema1 |
      | conn_2 | False   | begin                                               | success | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                         | success | schema1 |
      | conn_1 | True    | commit                                              | success | schema1 |
      | conn_2 | True    | commit                                              | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_A"
      | conn   | toClose | sql                                                                                                               | expect      | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5' | length{(6)} | dble_information  |
    #sleep 5s to wait connections idle timeout and into scaling period
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_B"
      | conn   | toClose | sql                                                                                                               | expect      | db                |timeout|
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5' | length{(6)} | dble_information  | 5,1   |
    #idle_connection_B is the same with idle_connection_A
    Then check resultsets "idle_connection_B" including resultset "idle_connection_A" in following columns
      | column                | column_index |
      | backend_conn_id       | 0            |
      | db_group_name         | 1            |
      | db_instance_name      | 2            |
      | remote_processlist_id | 5            |

  @CRITICAL
  Scenario: connection shrink: idle connections > minCon and the idle connection's idle time < idleTimeout, the idle connections will not be  recycle  #9
        Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="20" minCon="6" primary="true">
             <property name="heartbeatPeriodMillis">180000</property>
             <property name="idleTimeout">60000</property>
             <property name="timeBetweenEvictionRunsMillis">3000</property>
        </dbInstance>
     </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_idle_connections_50"
      | conn   | toClose | sql                                                                                                                                    | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'  | success       | dble_information  |
    Then kill the redundant connections if "dble_idle_connections_50" is more then expect value "6" in "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                         | success                    | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20))        | success                    | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(2,2)                      | success                    | schema1 |
      | conn_1 | False   | begin                                                      | success                    | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                                | success                    | schema1 |
      | conn_2 | False   | begin                                                      | success                    | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                                | success                    | schema1 |
      | conn_3 | False   | begin                                                      | success                    | schema1 |
      | conn_3 | False   | select * from sharding_4_t1                                | success                    | schema1 |
      | conn_4 | False   | begin                                                      | success                    | schema1 |
      | conn_4 | False   | select * from sharding_4_t1                                | success                    | schema1 |
      | conn_1 | True    | commit                                                     | success                    | schema1 |
      | conn_2 | True    | commit                                                     | success                    | schema1 |
      | conn_3 | True    | commit                                                     | success                    | schema1 |
      | conn_4 | True    | commit                                                     | success                    | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_A"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'                        | length{(8)}   | dble_information  |
    #sleep 3s to wait connections idle timeout and into scaling period
    Given sleep "3" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_B"
      | conn   | toClose | sql                                                                                                                                      | expect         | db                |timeout|
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'                        | length{(8)}    | dble_information  |3,1    |
    #idle_connection_B contains idle_connection_A
    Then check resultsets "idle_connection_B" including resultset "idle_connection_A" in following columns
      | column                     | column_index |
      | backend_conn_id            | 0            |
      | db_group_name              | 1            |
      | db_instance_name           | 2            |
      | remote_processlist_id      | 5            |
      | state                      | 18           |

  @CRITICAL
  Scenario: connection shrink: idle connections > minCon and the idle connection's idle time >= idleTimeout, the idle connections will be  recycle  #10
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="20" minCon="4" primary="true">
             <property name="heartbeatPeriodMillis">180000</property>
             <property name="idleTimeout">1000</property>
             <property name="timeBetweenEvictionRunsMillis">10000</property>
        </dbInstance>
     </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_idle_connections_60"
      | conn   | toClose | sql                                                                                                                                    | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'  | success       | dble_information  |
    Then kill the redundant connections if "dble_idle_connections_60" is more then expect value "4" in "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                         | success                    | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20))        | success                    | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(2,2)                      | success                    | schema1 |
      | conn_1 | False   | begin                                                      | success                    | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                                | success                    | schema1 |
      | conn_2 | False   | begin                                                      | success                    | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                                | success                    | schema1 |
      | conn_3 | False   | begin                                                      | success                    | schema1 |
      | conn_3 | False   | select * from sharding_4_t1                                | success                    | schema1 |
      | conn_1 | True    | commit                                                     | success                    | schema1 |
      | conn_2 | True    | commit                                                     | success                    | schema1 |
      | conn_3 | True    | commit                                                     | success                    | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_A"
      | conn   | toClose | sql                                                                                                                       | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'         | length{(6)}   | dble_information  |
    #sleep 1s to wait connections idle timeout and the idle connections have not been restored
    Given sleep "1" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_B"
      | conn   | toClose | sql                                                                                                                      | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'        | length{(6)}   | dble_information  |
    #idle_connection_B contains idle_connection_A
    Then check resultsets "idle_connection_B" including resultset "idle_connection_A" in following columns
      | column                      | column_index |
      | backend_conn_id             | 0            |
      | db_group_name               | 1            |
      | db_instance_name            | 2            |
      | remote_processlist_id       | 5            |
      | state                       | 18           |
    #sleep 10s to wait into default scaling period
    # 由于扩缩容任务是“延迟”类型的定时任务，所以实际进入下个扩缩容需要的时间要大于配置的周期
    Given sleep "10" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_C"
      | conn   | toClose | sql                                                                                                                               | expect        | db                | timeout |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'                 | length{(4)}   | dble_information  | 5,1     |



  @skip #DBLE0REQ-1867未合并
  Scenario: 当空闲链接被占用又没到扩缩容的时间，新增一个sql1会等待连接，这个时候再来一个sql2 borrow了一根链接给前一个sql1使用，前一个sql1使用的时候也会给sql2使用  issue:DBLE0REQ-1867  #11
     Given delete file "/opt/dble/newConnectionAfter*" on "dble-1"
     Given delete file "/opt/dble/borrowDirectlyConnectionBefore*" on "dble-1"
     Given delete file "/opt/dble/logs/dble_user_query.log" on "dble-1"
     Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /-Dprocessors=/d
      /-DprocessorExecutor=/d
      $a -Dprocessors=8
      $a -DprocessorExecutor=8
      """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="20" minCon="4" primary="true">
             <property name="heartbeatPeriodMillis">180000</property>
             <property name="timeBetweenEvictionRunsMillis">10000000</property>
              <property name="connectionTimeout">20000</property>
        </dbInstance>
      </dbGroup>
      """
     Given Restart dble in "dble-1" success
    ###最小的空闲链接 minCon="4" 4根
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                    | expect       | db                | timeout |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'  | length{(4)}  | dble_information  | 10,3    |

    ###两个事务，占用掉4跟链接
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect                     | db      |
      | conn_3 | False   | drop table if exists sharding_4_t1                         | success                    | schema1 |
      | conn_3 | False   | create table sharding_4_t1(id int,name varchar(20))        | success                    | schema1 |
      | conn_3 | False   | insert into sharding_4_t1 values(2,2),(4,4)                | success                    | schema1 |
      | conn_1 | False   | begin;select * from sharding_4_t1                          | success                    | schema1 |
      | conn_2 | False   | begin;select * from sharding_4_t1                          | success                    | schema1 |

    ###验证4跟链接被占用掉
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                    | expect       | db                | timeout |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'  | length{(0)}  | dble_information  | 10,3    |

       ####getWaiterCountAfter是复现的桩 ，修复后的桩要用borrowDirectlyConnectionBefore
     Given update file content "./assets/borrowDirectlyConnectionBefore.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
      /borrowDirectlyConnectionBefore/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
      """
     Given update file content "./assets/newConnectionAfter.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
      /newConnectionAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
      """

      ####这个8066的session开启事务并用桩hang住
     Given prepare a thread run btrace script "borrowDirectlyConnectionBefore.java" in "dble-1"
     Given execute sqls in "dble-1" at background and result addition
      | conn     | toClose | sql                                           | db      |
      | conn_3   | False   | begin;select * from sharding_4_t1 where id=2  | schema1 |
    ###验证没有新起链接
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                    | expect       | db                | timeout |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'  | length{(0)}  | dble_information  | 10,3    |
     Then check btrace "borrowDirectlyConnectionBefore.java" output in "dble-1"
      """
      get into borrowDirectlyConnectionBefore
      """
     Given stop btrace script "borrowDirectlyConnectionBefore.java" in "dble-1"
     Given destroy btrace threads list
    ### 这个8066 session的事务占用着  准备等下一个8066的语句新增的链接，所以查询还是没有空闲的链接
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                    | expect       | db                | timeout |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'  | length{(0)}  | dble_information  | 10,3    |
     ###确认select id=2 没有返回结果
     Then check following text exist "N" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
      """
      2
      """
      ###新的8066session执行sql去新增链接给上一步的8066执行的sql用
     Given prepare a thread run btrace script "newConnectionAfter.java" in "dble-1"
     Given execute sqls in "dble-1" at background and result addition
      | conn   | toClose | sql                                       | db      |
      | new1    | False    | select * from sharding_4_t1 where id=4  | schema1 |
     Then check btrace "newConnectionAfter.java" output in "dble-1"
      """
      get into newConnectionAfter
      """

    Given stop btrace script "newConnectionAfter.java" in "dble-1"
    Given destroy btrace threads list
    ####sleep time = btrace time  borrowDirectlyConnectionBefore
    Given sleep "20" seconds
   ####出桩了，select id=2  返回结果，这根链接是select id=4 创建出来的
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
      """
      2
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
      """
      4
      """
    ####sleep time = btrace time + connectionTimeout  newConnectionAfter 30+20-20（这个-20是前面sleep 的时间 ）
    Given sleep "35" seconds
    Then check following text exist "N" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
      """
      Connection is not available, request timed out after
      """
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1"
      """
      2
      4
      """
     Given delete file "/opt/dble/newConnectionAfter*" on "dble-1"
     Given delete file "/opt/dble/borrowDirectlyConnectionBefore*" on "dble-1"
     Given delete file "/opt/dble/logs/dble_user_query.log" on "dble-1"