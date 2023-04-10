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