# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2020/09/01

#3.20.07#233
Feature: heartbeat basic test
  Scenario:  heartbeat is not limited by maxCon #1
    #when connections exceeded the maxCon, the heartbeat connection still can be created
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
      | sharding.xml | {'tag':'root'} | {'tag':'function'}     |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
     Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <function class="Hash" name="hash-two">
        <property name="partitionCount">2</property>
        <property name="partitionLength">1</property>
    </function>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="4" minCon="3" primary="true">
           <property name="heartbeatPeriodMillis">2000</property>
        </dbInstance>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                                                    | expect  | db     |
     | test | 111111 | conn_0 | False    | drop table if exists sharding_2_t1                     | success | schema1 |
     | test | 111111 | conn_0 | True     | create table sharding_2_t1(id int,name varchar(30))    | success | schema1 |
    Given execute linux command in "dble-1" and save result in "master1_heartbeat_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" | awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill mysql conns in "mysql-master1" in "master1_heartbeat_id"
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect  | db       |
     | test | 111111 | conn_1 | False    | begin                       | success | schema1  |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | success | schema1  |
     | test | 111111 | conn_2 | False    | begin                       | success | schema1  |
     | test | 111111 | conn_2 | False    | select * from sharding_2_t1 | success | schema1  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_A"
      | sql             |
      | show @@backend |
    Then check resultset "rs_A" has lines with following column values
      | HOST-3       | USED_FOR_HEARTBEAT-22    |
      | 172.100.9.5  | false                     |
      | 172.100.9.5  | false                     |
      | 172.100.9.5  | false                     |
      | 172.100.9.5  | false                     |
      | 172.100.9.5  | true                      |
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql              | expect  | db       |
     | test | 111111 | conn_1 | True     | commit           | success | schema1  |
     | test | 111111 | conn_2 | True     | commit           | success | schema1  |

  @btrace
  Scenario: heartbeat timeout test #2
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
      | sharding.xml | {'tag':'root'} | {'tag':'function'}     |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
     Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <function class="Hash" name="hash-two">
        <property name="partitionCount">2</property>
        <property name="partitionLength">1</property>
    </function>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat timeout="4">select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
           <property name="heartbeatPeriodMillis">5000</property>
        </dbInstance>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
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
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" | awk '{print $3,$NF}' | grep true |awk '{print $1}'
    """
    Given kill mysql conns in "mysql-master1" in "master1_heartbeat_id"
    Then check btrace "BtraceHeartbeat.java" output in "dble-1"
    """
    before fieldEofResponse
    """
    Given stop btrace script "BtraceHeartbeat.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceHeartbeat.java" on "dble-1"
    Given delete file "/opt/dble/BtraceHeartbeat.java.log" on "dble-1"
    #sleep 10s to let heartbeat timeout(2 heartbeat times)
    Given sleep "10" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    heartbeat to \[172.100.9.5:3306\] setTimeout
    """


  Scenario: set errorRetryCount=0, kill the heartbeat connection, then check the heartbeat status #3
    #1 the killed heartbeat connection, heartbeat will set error at once, and then it will recover at next heartbeat period
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat errorRetryCount="0">select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
           <property name="heartbeatPeriodMillis">3000</property>
        </dbInstance>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                                  | expect  | db      |
     | test | 111111 | conn_0 | False    | drop table if exists sharding_2_t1   | success | schema1 |
     | test | 111111 | conn_0 | True     | create table sharding_2_t1(id int,name varchar(30))    | success | schema1 |
    Given execute linux command in "dble-1" and save result in "master1_heartbeat_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" | awk '{print $3, $NF}' | grep true | awk '{print $1}'
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
    Given sleep "3" seconds
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect  | db     |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | success | schema1 |


  @btrace
  Scenario: heartbeat connection is recover failed in retry 'errorRetryCount' times, the heartbeat will set as error,and the connection pool is available in retry period #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat errorRetryCount="3" timeout="300">select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
           <property name="heartbeatPeriodMillis">180000</property>
        </dbInstance>
     </dbGroup>

    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                                                    | expect  | db      |
     | test | 111111 | conn_0 | False    | drop table if exists sharding_2_t1                     | success | schema1 |
     | test | 111111 | conn_0 | True     | create table sharding_2_t1(id int,name varchar(30))    | success | schema1 |
    Given delete file "/opt/dble/BtraceHeartbeat.java" on "dble-1"
    Given delete file "/opt/dble/BtraceHeartbeat.java.log" on "dble-1"
    Given update file content "./assets/BtraceHeartbeat.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /heartbeat/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(2000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceHeartbeat.java" in "dble-1"

    Given record current dble log line number in "log_linenu"
    Given execute linux command in "dble-1" and save result in "master1_heartbeat_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" | awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill mysql conns in "mysql-master1" in "master1_heartbeat_id"
    #the first time retry failed, and connection pool is available
    Then check btrace "BtraceHeartbeat.java" output in "dble-1" with "1" times
    """
    before heartbeat
    """
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect  | db     |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | success | schema1 |
    Given execute linux command in "dble-1" and save result in "master1_heartbeat_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" | awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill mysql conns in "mysql-master1" in "master1_heartbeat_id"
    #the second time retry failed, and connection pool is available
    Then check btrace "BtraceHeartbeat.java" output in "dble-1" with "2" times
    """
    before heartbeat
    """
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect  | db     |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | success | schema1 |
    Given execute linux command in "dble-1" and save result in "master1_heartbeat_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" | awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill mysql conns in "mysql-master1" in "master1_heartbeat_id"
    #the 3trd time retry failed, the heartbeat set error and connection pool is not available
    Then check btrace "BtraceHeartbeat.java" output in "dble-1" with "3" times
    """
    before heartbeat
    """
    Given execute linux command in "dble-1" and save result in "master1_heartbeat_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" | awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill mysql conns in "mysql-master1" in "master1_heartbeat_id"
    #DBLE0REQ-960
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    heartbeat conn for sql\[select user()\] is closed, due to stream closed by peer, we will try again immediately
    retry to do heartbeat for the 3 times
    """
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                           | expect   | db      |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1   | success  | schema1 |
    Given stop btrace script "BtraceHeartbeat.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceHeartbeat.java" on "dble-1"
    Given delete file "/opt/dble/BtraceHeartbeat.java.log" on "dble-1"

  @btrace
  Scenario: heartbeat connection recover success in retry 'errorRetryCount' times, the heartbeat will set as Ok,and the connection pool is available in retry period #5
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
      | db.xml | {'tag':'root'} | {'tag':'dbGroup'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat errorRetryCount="3" timeout="300">select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
           <property name="heartbeatPeriodMillis">120000</property>
        </dbInstance>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
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
    Given execute linux command in "dble-1" and save result in "master1_heartbeat_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" | awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill mysql conns in "mysql-master1" in "master1_heartbeat_id"
    #the first time retry failed,and connection pool is available
    Then check btrace "BtraceHeartbeat.java" output in "dble-1" with "1" times
    """
    before heartbeat
    """
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose  | sql                         | expect  | db      |
     | test | 111111 | conn_1 | False    | select * from sharding_2_t1 | success | schema1 |
    Given sleep "3" seconds
    Given execute linux command in "dble-1" and save result in "master1_heartbeat_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" | awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill mysql conns in "mysql-master1" in "master1_heartbeat_id"
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
    Given execute linux command in "dble-1" and save result in "master1_heartbeat_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" | awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill mysql conns in "mysql-master1" in "master1_heartbeat_id"
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
