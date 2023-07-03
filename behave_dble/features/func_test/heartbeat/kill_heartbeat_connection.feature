# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2020/09/01

#3.20.07#233
Feature: heartbeat basic test

  Scenario:  heartbeat is not limited by maxCon #1
    #when connections exceeded the maxCon, the heartbeat connection still can be created
    Given delete the following xml segment
      | file       | parent         | child                  |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}       |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'}     |
      | schema.xml | {'tag':'root'} | {'tag':'dataHost'}     |
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <table name="sharding_2_t1" dataNode="dn1,dn3" rule="hash-two" />
    </schema>
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
     <dataHost balance="0" maxCon="4" minCon="3" name="ha_group1" slaveThreshold="100" >
       <heartbeat>select user()</heartbeat>
       <writeHost host="hostM1" password="111111" url="172.100.9.1:3306" user="test">
       </writeHost>
    </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="dataNodeHeartbeatPeriod">2000</property>
    """
    Given restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                                                    | expect  | db     |
     | test | 111111 | conn_0 | False    | drop table if exists sharding_2_t1                     | success | schema1 |
     | test | 111111 | conn_0 | True     | create table sharding_2_t1(id int,name varchar(30))    | success | schema1 |
    Given execute linux command in "dble-1" and save result in "master1_heartbeat_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} -e "show @@backend" | awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill mysql conns in "mysql-master3" in "master1_heartbeat_id"
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect  | db       |
     | test | 111111 | conn_1 | False    | begin                       | success | schema1  |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | success | schema1  |
     | test | 111111 | conn_2 | False    | begin                       | success | schema1  |
     | test | 111111 | conn_2 | False    | select * from sharding_2_t1 | success | schema1  |
    Given sleep "2" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_A"
      | sql             |
      | show @@backend |
    Then check resultset "rs_A" has lines with following column values
      | HOST-3       | USED_FOR_HEARTBEAT-22    |
      | 172.100.9.1  | false                     |
      | 172.100.9.1  | false                     |
      | 172.100.9.1  | false                     |
      | 172.100.9.1  | false                     |
      | 172.100.9.1  | true                      |
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql              | expect  | db       |
     | test | 111111 | conn_1 | True     | commit           | success | schema1  |
     | test | 111111 | conn_2 | True     | commit           | success | schema1  |

  @btrace @skip
  Scenario: heartbeat timeout test #2
    Given delete the following xml segment
      | file       | parent         | child                  |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}       |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <table name="sharding_2_t1" dataNode="dn1,dn3" rule="hash-two" />
    </schema>
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="dataNodeHeartbeatPeriod">7000</property>
    """
    Given restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                                                    | expect  | db      |
     | test | 111111 | conn_0 | False    | drop table if exists sharding_2_t1                     | success | schema1 |
     | test | 111111 | conn_0 | True     | create table sharding_2_t1(id int,name varchar(30))    | success | schema1 |
    Given record current dble log line number in "log_linenu"
    Given delete file "/opt/dble/BtraceHeartbeat.java" on "dble-1"
    Given delete file "/opt/dble/BtraceHeartbeat.java.log" on "dble-1"
    Given update file content "./assets/BtraceHeartbeat.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /fieldEofResponse/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(12000L)/;/\}/!ba}
    """
   Given prepare a thread run btrace script "BtraceHeartbeat.java" in "dble-1"
   Given execute linux command in "dble-1" and save result in "master1_heartbeat_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} -e "show @@backend" | awk '{print $3,$NF}' | grep true |awk '{print $1}'
    """
    Given kill mysql conns in "mysql-master3" in "master1_heartbeat_id"
    Then check btrace "BtraceHeartbeat.java" output in "dble-1" with ">0" times
    """
    before fieldEofResponse
    """
    Given stop btrace script "BtraceHeartbeat.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceHeartbeat.java" on "dble-1"
    Given delete file "/opt/dble/BtraceHeartbeat.java.log" on "dble-1"
    #sleep 14s to let heartbeat timeout(2 heartbeat times)
    Given sleep "14" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    heartbeat to \[172.100.9.5:3306\] setTimeout
    """


  Scenario: set errorRetryCount=0, kill the heartbeat connection, then check the heartbeat status #3
    #1 the killed heartbeat connection, heartbeat will set error at once, and then it will recover at next heartbeat period
    Given delete the following xml segment
      | file       | parent         | child                  |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}       |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'}     |
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <table name="sharding_2_t1" dataNode="dn1,dn3" rule="hash-two" />
    </schema>
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="dataNodeHeartbeatPeriod">7000</property>
    """
    Given restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                                  | expect  | db      |
     | test | 111111 | conn_0 | False    | drop table if exists sharding_2_t1   | success | schema1 |
     | test | 111111 | conn_0 | True     | create table sharding_2_t1(id int,name varchar(30))    | success | schema1 |
    Given execute linux command in "dble-1" and save result in "master1_heartbeat_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} -e "show @@backend" | awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given record current dble log line number in "log_linenu"
    Given kill mysql conns in "mysql-master1" in "master1_heartbeat_id"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    heartbeat to \[172.100.9.5:3306\] setError
    """
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect              | db      |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | error totally whack | schema1 |

      #sleep 3s for heartbeat recover
   #  Given sleep "3" seconds
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect  | db       | timeout |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | success | schema1  | 5       |


  @btrace  @skip
    #coz case中的方法 3.20.10才适用，后续更改方法优化
  Scenario: heartbeat connection is recover failed in retry 'errorRetryCount' times, the heartbeat will set as error,and the connection pool is available in retry period #4
    Given delete the following xml segment
      | file       | parent         | child                  |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}       |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'}     |
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <table name="sharding_2_t1" dataNode="dn1,dn3" rule="hash-two" />
    </schema>
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="dataNodeHeartbeatPeriod">180000</property>
    """
    Given restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                                                    | expect  | db      |
     | test | 111111 | conn_0 | False    | drop table if exists sharding_2_t1                     | success | schema1 |
     | test | 111111 | conn_0 | True     | create table sharding_2_t1(id int,name varchar(30))    | success | schema1 |
    Given delete file "/opt/dble/BtraceHeartbeat.java" on "dble-1"
    Given delete file "/opt/dble/BtraceHeartbeat.java.log" on "dble-1"
    Given update file content "./assets/BtraceHeartbeat.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /heartbeat/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceHeartbeat.java" in "dble-1"

#    Given record current dble log line number in "log_linenu"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "master1_heartbeat_id"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |timeout|
      | conn_0 | True    | select remote_processlist_id from backend_connections where used_for_heartbeat='true' and remote_addr='172.100.9.5'                      | length{(1)}   | dble_information  |3,1    |
    Then kill the redundant connections if "master1_heartbeat_id" is more then expect value "0" in "mysql-master1"
    #the first time retry failed, and connection pool is available
    Then check btrace "BtraceHeartbeat.java" output in "dble-1" with "1" times
    """
    before heartbeat
    """
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect  | db      |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | success | schema1 |

    #需要超过桩的时间才能建立心跳连接，日志中出现“[heartbeat]do heartbeat,conn is BackendConnection。。。”后才能查到心跳连接
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "master1_heartbeat_id"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |timeout|
      | conn_0 | True    | select remote_processlist_id from backend_connections where used_for_heartbeat='true' and remote_addr='172.100.9.5'                      | length{(1)}   | dble_information  |3,1    |
    Then kill the redundant connections if "master1_heartbeat_id" is more then expect value "0" in "mysql-master1"
    #the second time retry failed, and connection pool is available
    Then check btrace "BtraceHeartbeat.java" output in "dble-1" with "2" times
    """
    before heartbeat
    """
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect  | db     |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | success | schema1 |

    Given sleep "5" seconds
    Given record current dble log line number in "log_linenu"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "master1_heartbeat_id"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |timeout|
      | conn_0 | True    | select remote_processlist_id from backend_connections where used_for_heartbeat='true' and remote_addr='172.100.9.5'                      | length{(1)}   | dble_information  |3,1    |
    Then kill the redundant connections if "master1_heartbeat_id" is more then expect value "0" in "mysql-master1"
    #the 3trd time retry failed, the heartbeat set error and connection pool is not available
    Then check btrace "BtraceHeartbeat.java" output in "dble-1" with "3" times
    """
    before heartbeat
    """
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "master1_heartbeat_id"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |timeout|
      | conn_0 | True    | select remote_processlist_id from backend_connections where used_for_heartbeat='true' and remote_addr='172.100.9.5'                      | length{(1)}   | dble_information  |3,1    |
    Then kill the redundant connections if "master1_heartbeat_id" is more then expect value "0" in "mysql-master1"
    Given stop btrace script "BtraceHeartbeat.java" in "dble-1"
    Given destroy btrace threads list
    #在心跳setError之后, 并且有sql对该db下发查询，发现心跳error持续时间超过timeout配置的值，就会打印 "error heartbeat continued for more than"（此时连接池不可用）
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1" retry "5,1" times
    """
    heartbeat to \[172.100.9.5:3306\] setError
    is closed, due to stream closed, we will try again immediately
    retry to do heartbeat for the 3 times
    """
    #sleep 1s (timeout配置的时间为1s) 使其进入心跳timeout逻辑
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                          | expect               | db      |timeout|
     | test | 111111 | conn_1 | True    | select * from sharding_2_t1   | error totally whack  | schema1 |3,1    |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1" retry "3,1" times
    """
    error heartbeat continued for more than
    """
    Given delete file "/opt/dble/BtraceHeartbeat.java" on "dble-1"
    Given delete file "/opt/dble/BtraceHeartbeat.java.log" on "dble-1"

  @btrace  @skip
        #coz case中的方法 3.20.10才适用，后续更改方法优化
  Scenario: heartbeat connection recover success in retry 'errorRetryCount' times, the heartbeat will set as Ok,and the connection pool is available in retry period #5
    Given delete the following xml segment
      | file       | parent         | child                  |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}       |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'}     |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <table name="sharding_2_t1" dataNode="dn1,dn3" rule="hash-two" />
    </schema>
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="dataNodeHeartbeatPeriod">120000</property>
    """
    Given restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                                                    | expect  | db      |
     | test | 111111 | conn_0 | False    | drop table if exists sharding_2_t1                     | success | schema1 |
     | test | 111111 | conn_0 | True     | create table sharding_2_t1(id int,name varchar(30))    | success | schema1 |
    Given delete file "/opt/dble/BtraceHeartbeat.java" on "dble-1"
    Given delete file "/opt/dble/BtraceHeartbeat.java.log" on "dble-1"
    Given update file content "./assets/BtraceHeartbeat.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /heartbeat/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceHeartbeat.java" in "dble-1"

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "master1_heartbeat_id"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |timeout|
      | conn_0 | True    | select remote_processlist_id from backend_connections where used_for_heartbeat='true' and remote_addr='172.100.9.5'                      | length{(1)}   | dble_information  |3,1    |
    Then kill the redundant connections if "master1_heartbeat_id" is more then expect value "0" in "mysql-master1"

    #the first time retry failed,and connection pool is available
    Then check btrace "BtraceHeartbeat.java" output in "dble-1" with "1" times
    """
    before heartbeat
    """
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect  | db      |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | success | schema1 |
    #需要超过桩的时间才能建立心跳连接，日志中出现“[heartbeat]do heartbeat,conn is BackendConnection。。。”后才能查到心跳连接
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "master1_heartbeat_id"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |timeout|
      | conn_0 | True    | select remote_processlist_id from backend_connections where used_for_heartbeat='true' and remote_addr='172.100.9.5'                      | length{(1)}   | dble_information  |4,1    |
    Then kill the redundant connections if "master1_heartbeat_id" is more then expect value "0" in "mysql-master1"
    #the second time retry failed,and connection pool is available
    Then check btrace "BtraceHeartbeat.java" output in "dble-1" with "2" times
    """
    before heartbeat
    """
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect  | db      |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | success | schema1 |
    Given record current dble log line number in "log_linenu"
    #sleep 5s coz issue: DBLE0REQ-701
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "master1_heartbeat_id"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |timeout|
      | conn_0 | True    | select remote_processlist_id from backend_connections where used_for_heartbeat='true' and remote_addr='172.100.9.5'                      | length{(1)}   | dble_information  |4,1    |
    Then kill the redundant connections if "master1_heartbeat_id" is more then expect value "0" in "mysql-master1"
    #the 3trd time retry success, the heartbeat setOk and connection pool is available

    Then check btrace "BtraceHeartbeat.java" output in "dble-1" with "3" times
    """
    before heartbeat
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    retry to do heartbeat for the 3 times
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    heartbeat to \[172.100.9.5:3306\] setError
    """
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect  | db     |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | success | schema1 |
    Given stop btrace script "BtraceHeartbeat.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceHeartbeat.java" on "dble-1"
    Given delete file "/opt/dble/BtraceHeartbeat.java.log" on "dble-1"