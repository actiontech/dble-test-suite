# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2021/7/30

# https://github.com/actiontech/dble/issues/1180
Feature: connection leak test

  # issue：https://github.com/actiontech/dble/issues/1261
  @btrace
  Scenario: modify table's configuration that has been created, reload @@config_all not hang when backend mysql disconnected             #1

    Given record current dble log line number in "log_1"
    Given delete file "/opt/dble/BtraceLineDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceLineDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                                      | db       |
       | conn_0 | False   | drop table if exists sharding_4_t1                       | schema1  |
       | conn_0 | true    | create table sharding_4_t1(id int,name varchar(30))      | schema1  |
    Given delete the following xml segment
       | file             | parent         | child            |
       | sharding.xml     | {'tag':'root'} | {'tag':'schema'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
       """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
           <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
           <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
           <shardingTable name="sharding_4_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
        </schema>
       """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
       | conn   | toClose   |  sql                                                                     |
       | conn_1 | False     |  show @@shardingNodes where schema=schema1 and table=sharding_4_t1       |
    Then check resultset "A" has lines with following column values
       | NAME-0 |SEQUENCE-1 | HOST-2         | PORT-3   | PHYSICAL_SCHEMA-4 |  USER-5 | PASSWORD-6 |
       | dn1    | 0         | 172.100.9.5    | 3306     |   db1             |  test   | 111111     |
       | dn2    | 1         | 172.100.9.6    | 3306     |   db1             |  test   | 111111     |
       | dn3    | 2         | 172.100.9.5    | 3306     |   db2             |  test   | 111111     |
       | dn4    | 3         | 172.100.9.6    | 3306     |   db2             |  test   | 111111     |
    Given prepare a thread run btrace script "BtraceLineDelay.java" in "dble-1"
    Then execute sql in "dble-1" in "admin" mode
       | conn   | toClose   | sql                        | db               |
       | conn_1 | False     | reload @@config_all        | dble_information |
    Then check btrace "BtraceLineDelay.java" output in "dble-1" with "2" times
      """
      delay for NP test
      """
    Given stop mysql in host "mysql-master1"
    Given sleep "5" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_1" in host "dble-1"
      """
      apply new config end
      """
    Given start mysql in host "mysql-master1"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
       | conn   | toClose   |  sql                                                                     |
       | conn_1 | true      |  show @@shardingNodes where schema=schema1 and table=sharding_4_t1       |
    Then check resultset "B" has lines with following column values
       | NAME-0 |SEQUENCE-1 | HOST-2         | PORT-3   | PHYSICAL_SCHEMA-4 |  USER-5 | PASSWORD-6 |
       | dn1    | 0         | 172.100.9.5    | 3306     |   db1             |  test   | 111111     |
       | dn3    | 1         | 172.100.9.5    | 3306     |   db2             |  test   | 111111     |
    Given stop btrace script "BtraceLineDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceLineDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceLineDelay.java.log" on "dble-1"

  @btrace
  Scenario: two case explained below (06 regression added)                            #2
    Given delete the following xml segment
      | file             | parent         | child                   |
      | sharding.xml     | {'tag':'root'} | {'tag':'schema'}        |
      | sharding.xml     | {'tag':'root'} | {'tag':'shardingNode'}  |
      | db.xml           | {'tag':'root'} | {'tag':'dbGroup'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
        <shardingTable name="table_b" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id">
            <childTable name="table_c" joinColumn="name" parentColumn="name" sqlMaxLimit="201">
            </childTable>
        </shardingTable>
      </schema>

        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
         <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
             <heartbeat>select user()</heartbeat>
             <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="4" minCon="0" primary="true">
             </dbInstance>
         </dbGroup>
       """
    Then execute admin cmd "reload @@config_all"

    #CASE1: close all backend connections,dble should return error message
    Then execute sql in "dble-1" in "user" mode
        | conn    | toClose   | sql                                             | db          | expect   |
        | conn_0  | False     | drop table if exists table_b                    | schema1     | success  |
        | conn_0  | False     | drop table if exists table_c                    | schema1     | success  |
        | conn_0  | False     | create table table_b(id int,name varchar(40))   | schema1     | success  |
        | conn_0  | False     | create table table_c(name varchar(40),id int)   | schema1     | success  |
        | conn_0  | False     | insert into table_b set id = 1,name = "xx"      | schema1     | success  |
    Given delete file "/opt/dble/BtraceClusterDelayquery.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelayquery.java.log" on "dble-1"
    Given update file content "./assets/BtraceClusterDelayquery.java" in "behave" with sed cmds
      """
       s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
       /synAndDoExecute/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelayquery.java" in "dble-1"
    Given prepare a thread execute sql "insert into table_c set id =5,name ="xx"" with "conn_0"
    # 心跳语句也可能进桩
    Then check btrace "BtraceClusterDelayquery.java" output in "dble-1" with ">0" times
       """
       get into query
       """
    Given restart mysql in "mysql-master1"
    Given sleep "5" seconds
    Then check sql thread output in "err"
      """
      1105, "java.io.IOException: the dbInstance[172.100.9.5:3306] can't reach. Please check the dbInstance is accessible"
      """
    Given stop btrace script "BtraceClusterDelayquery.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceClusterDelayquery.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelayquery.java.log" on "dble-1"

    #CASE2: transaction nums more than maxCon nums in the same front connection, new front connection can execute sql successfully

    #### 确定dble心跳恢复
    Then execute sql in "dble-1" in "admin" mode
    | sql                                                                                                               | expect        | db                |timeout  |
    | select * from dble_db_instance where last_heartbeat_ack='ok' and heartbeat_status='idle' and addr='172.100.9.5'   | length{(1)}   | dble_information  | 6,2     |

    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                             | db          | expect   |
      | conn_1  | False     | drop table if exists table_b                    | schema1     | success  |
      | conn_1  | False     | drop table if exists table_c                    | schema1     | success  |
      | conn_1  | False     | create table table_b(id int,name varchar(40))   | schema1     | success  |
      | conn_1  | False     | create table table_c(name varchar(40),id int)   | schema1     | success  |
      | conn_1  | False     | insert into table_b set id = 1,name = "xx"      | schema1     | success  |
      | conn_1  | False     | begin                                           | schema1     | success  |
      | conn_1  | False     | insert into table_c set id=5,name="XX";         | schema1     | success  |
      | conn_1  | False     | begin                                           | schema1     | success  |
      | conn_1  | False     | insert into table_c set id=5,name="XX";         | schema1     | success  |
      | conn_1  | False     | begin                                           | schema1     | success  |
      | conn_1  | False     | insert into table_c set id=5,name="XX";         | schema1     | success  |
      | conn_1  | False     | begin                                           | schema1     | success  |
      | conn_1  | False     | insert into table_c set id=5,name="XX";         | schema1     | success  |
      | conn_1  | False     | begin                                           | schema1     | success  |
      | conn_1  | False     | insert into table_c set id=5,name="XX";         | schema1     | success  |
      | conn_1  | False     | begin                                           | schema1     | success  |
      | conn_1  | False     | insert into table_c set id=5,name="XX";         | schema1     | success  |
      | conn_1  | False     | begin                                           | schema1     | success  |
      | conn_1  | False     | insert into table_c set id=5,name="XX";         | schema1     | success  |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                             | db          | expect   |
      | conn_2  | False     | select * from table_b                           | schema1     | success  |


