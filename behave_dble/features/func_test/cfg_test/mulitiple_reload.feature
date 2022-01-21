# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/2/26

  #2.19.11.0#dble-7874
Feature: multiple reload

  Scenario: execute reload @@config_all with different session at the same time after init metadata successed #1
    Given delete the following xml segment
      | file       | parent         | child              |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <shardingTable name="test1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test3" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test4" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test5" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test6" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn2" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_0 | False   | drop table if exists test1         | success | schema1 |
      | conn_0 | False   | drop table if exists test2         | success | schema1 |
      | conn_0 | False   | drop table if exists test3         | success | schema1 |
      | conn_0 | False   | drop table if exists test4         | success | schema1 |
      | conn_0 | False   | drop table if exists test5         | success | schema1 |
      | conn_0 | False   | drop table if exists test6         | success | schema1 |
      | conn_0 | False   | create table test1(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test2(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test3(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test4(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test5(id int,age int) | success | schema1 |
      | conn_0 | True    | create table test6(id int,age int) | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn | toClose | sql                 | expect  |
      | new  | False   | reload @@config_all | success |
      | new  | true    | reload @@config_all | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                        | expect  | db      |
      | conn_0 | False   | drop table if exists test1 | success | schema1 |
      | conn_0 | False   | drop table if exists test2 | success | schema1 |
      | conn_0 | False   | drop table if exists test3 | success | schema1 |
      | conn_0 | False   | drop table if exists test4 | success | schema1 |
      | conn_0 | False   | drop table if exists test5 | success | schema1 |
      | conn_0 | True    | drop table if exists test6 | success | schema1 |

  Scenario: execute reload @@metadata with different session at the same time after init metadata successed #2
    Given delete the following xml segment
      | file       | parent         | child              |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <shardingTable name="test1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test3" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test4" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test5" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test6" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn2" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_0 | False   | drop table if exists test1         | success | schema1 |
      | conn_0 | False   | drop table if exists test2         | success | schema1 |
      | conn_0 | False   | drop table if exists test3         | success | schema1 |
      | conn_0 | False   | drop table if exists test4         | success | schema1 |
      | conn_0 | False   | drop table if exists test5         | success | schema1 |
      | conn_0 | False   | drop table if exists test6         | success | schema1 |
      | conn_0 | False   | create table test1(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test2(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test3(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test4(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test5(id int,age int) | success | schema1 |
      | conn_0 | True    | create table test6(id int,age int) | success | schema1 |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect  | db      |
      | alter table test2 add name char(9) | success | schema1 |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect  | db      |
      | alter table test1 add name char(9) | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "metadata_rs_a"
      | sql                                          |
      | check full @@metadata where schema='schema1' |
    Then check resultset "metadata_rs_a" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test1   | 1                          | 1                      |
      | schema1  | test2   | 1                          | 1                      |
      | schema1  | test3   | 1                          | 1                      |
      | schema1  | test4   | 1                          | 1                      |
      | schema1  | test5   | 1                          | 1                      |
      | schema1  | test6   | 1                          | 1                      |
    Then record reloadTime of "test2" from "metadata_rs_a" named "A"
    Then get resultset when reload time "equal" record time "A" named "metadata_rs_b"
    Then check resultset "metadata_rs_b" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test2   | 1                          | 1                      |
    Then check resultset "metadata_rs_b" has not lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test1   | 1                          | 1                      |
      | schema1  | test3   | 1                          | 1                      |
      | schema1  | test4   | 1                          | 1                      |
      | schema1  | test5   | 1                          | 1                      |
      | schema1  | test6   | 1                          | 1                      |
    Then get resultset when reload time "lt" record time "A" named "metadata_rs_c"
    Then check resultset "metadata_rs_c" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test2   | 1                          | 1                      |
      | schema1  | test3   | 1                          | 1                      |
      | schema1  | test4   | 1                          | 1                      |
      | schema1  | test5   | 1                          | 1                      |
      | schema1  | test6   | 1                          | 1                      |
    Then check resultset "metadata_rs_c" has not lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test1   | 1                          | 1                      |
    Then get resultset when reload time "gt" record time "A" named "metadata_rs_d"
    Then check resultset "metadata_rs_d" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test1   | 1                          | 1                      |
      | schema1  | test2   | 1                          | 1                      |
    Then check resultset "metadata_rs_d" has not lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test3   | 1                          | 1                      |
      | schema1  | test4   | 1                          | 1                      |
      | schema1  | test5   | 1                          | 1                      |
      | schema1  | test6   | 1                          | 1                      |
    Then execute sql in "dble-1" in "admin" mode
      | conn | toClose | sql               | expect  |
      | new  | true    | reload @@metadata | success |
      | new  | true    | reload @@metadata | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "metadata_rs_e"
      | sql                                          |
      | check full @@metadata where schema='schema1' |
    Then check resultset "metadata_rs_e" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test3   | 1                          | 1                      |
      | schema1  | test4   | 1                          | 1                      |
      | schema1  | test5   | 1                          | 1                      |
      | schema1  | test1   | 1                          | 1                      |
      | schema1  | test2   | 1                          | 1                      |
      | schema1  | test6   | 1                          | 1                      |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                             | expect  | db      |
      | conn_0 | False   | insert into test1 values(1,1,1) | success | schema1 |
      | conn_0 | False   | insert into test2 values(1,1,1) | success | schema1 |
      | conn_0 | False   | insert into test3 values(1,1)   | success | schema1 |
      | conn_0 | False   | insert into test4 values(1,1)   | success | schema1 |
      | conn_0 | False   | insert into test5 values(1,1)   | success | schema1 |
      | conn_0 | true    | insert into test6 values(1,1)   | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                        | expect  | db      |
      | conn_0 | False   | drop table if exists test1 | success | schema1 |
      | conn_0 | False   | drop table if exists test2 | success | schema1 |
      | conn_0 | False   | drop table if exists test3 | success | schema1 |
      | conn_0 | False   | drop table if exists test4 | success | schema1 |
      | conn_0 | False   | drop table if exists test5 | success | schema1 |
      | conn_0 | True    | drop table if exists test6 | success | schema1 |

  @btrace
  Scenario: execute reload @@config_all with different session at the same time after init metadata failed #3
    Given delete the following xml segment
      | file       | parent         | child              |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <shardingTable name="test1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test3" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test4" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test5" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test6" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn2" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_0 | False   | drop table if exists test1         | success | schema1 |
      | conn_0 | False   | drop table if exists test2         | success | schema1 |
      | conn_0 | False   | drop table if exists test3         | success | schema1 |
      | conn_0 | False   | drop table if exists test4         | success | schema1 |
      | conn_0 | False   | drop table if exists test5         | success | schema1 |
      | conn_0 | False   | drop table if exists test6         | success | schema1 |
      | conn_0 | False   | create table test1(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test2(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test3(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test4(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test5(id int,age int) | success | schema1 |
      | conn_0 | True    | create table test6(id int,age int) | success | schema1 |
    Then execute admin cmd "reload @@config_all -r"
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /getSpecialNodeTablesHandlerFinished/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Then execute admin cmd  in "dble-1" at background
      | sql                    | db      |
      | reload @@config_all -r | schema1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
    """
    get into getSpecialNodeTablesHandlerFinished
    """
    Then execute sql in "mysql-master1"
      | sql              | expect  | db  |
      | drop table test5 | success | db1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1" with "2" times
    """
    get into getSpecialNodeTablesHandlerFinished
    """
    Then execute sql in "mysql-master1"
      | sql              | expect  | db  |
      | drop table test5 | success | db2 |
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn | toClose | sql                    | expect  |
      | new  | true    | reload @@config_all -r | success |
      | new  | true    | reload @@config_all -r | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "metadata_rs_a"
      | sql                                          |
      | check full @@metadata where schema='schema1' |
    Then check resultset "metadata_rs_a" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test3   | 1                          | 1                      |
      | schema1  | test4   | 1                          | 1                      |
      | schema1  | test5   | 0                          | 0                      |
      | schema1  | test1   | 1                          | 1                      |
      | schema1  | test2   | 1                          | 1                      |
      | schema1  | test6   | 1                          | 1                      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "metadata_rs_b"
      | sql                                                |
      | check full @@metadata where consistent_in_memory=0 |
    Then check resultset "metadata_rs_b" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test5   | 0                          | 0                      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "metadata_rs_c"
      | sql                                                |
      | check full @@metadata where consistent_in_memory=1 |
    Then check resultset "metadata_rs_c" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test3   | 1                          | 1                      |
      | schema1  | test4   | 1                          | 1                      |
      | schema1  | test1   | 1                          | 1                      |
      | schema1  | test2   | 1                          | 1                      |
      | schema1  | test6   | 1                          | 1                      |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                           | expect              | db      |
      | conn_0 | False   | insert into test1 values(1,1) | success             | schema1 |
      | conn_0 | False   | insert into test2 values(1,1) | success             | schema1 |
      | conn_0 | False   | insert into test3 values(1,1) | success             | schema1 |
      | conn_0 | False   | insert into test4 values(1,1) | success             | schema1 |
      | conn_0 | False   | insert into test5 values(1,1) | error totally whack | schema1 |
      | conn_0 | True    | insert into test6 values(1,1) | success             | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                        | expect  | db      |
      | conn_0 | False   | drop table if exists test1 | success | schema1 |
      | conn_0 | False   | drop table if exists test2 | success | schema1 |
      | conn_0 | False   | drop table if exists test3 | success | schema1 |
      | conn_0 | False   | drop table if exists test4 | success | schema1 |
      | conn_0 | False   | drop table if exists test5 | success | schema1 |
      | conn_0 | True    | drop table if exists test6 | success | schema1 |

  @btrace
  Scenario: execute reload @@metadata with different session at the same time after init metadata failed #4
    Given delete the following xml segment
      | file       | parent         | child              |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <shardingTable name="test1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test3" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test4" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test5" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="test6" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn2" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_0 | False   | drop table if exists test1         | success | schema1 |
      | conn_0 | False   | drop table if exists test2         | success | schema1 |
      | conn_0 | False   | drop table if exists test3         | success | schema1 |
      | conn_0 | False   | drop table if exists test4         | success | schema1 |
      | conn_0 | False   | drop table if exists test5         | success | schema1 |
      | conn_0 | False   | drop table if exists test6         | success | schema1 |
      | conn_0 | False   | create table test1(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test2(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test3(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test4(id int,age int) | success | schema1 |
      | conn_0 | False   | create table test5(id int,age int) | success | schema1 |
      | conn_0 | True    | create table test6(id int,age int) | success | schema1 |
    Then execute admin cmd "reload @@config_all -r"
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /getSpecialNodeTablesHandlerFinished/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Then execute admin cmd  in "dble-1" at background
      | sql               |
      | reload @@metadata |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
    """
    get into getSpecialNodeTablesHandlerFinished
    """
    Then execute sql in "mysql-master1"
      | sql              | expect  | db  |
      | drop table test5 | success | db1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1" with "2" times
    """
    get into getSpecialNodeTablesHandlerFinished
    """
    Then execute sql in "mysql-master1"
      | sql              | expect  | db  |
      | drop table test5 | success | db2 |
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn | toClose | sql               | expect  |
      | new  | true    | reload @@metadata | success |
      | new  | true    | reload @@metadata | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "metadata_rs_e"
      | sql                                          |
      | check full @@metadata where schema='schema1' |
    Then check resultset "metadata_rs_e" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test3   | 1                          | 1                      |
      | schema1  | test4   | 1                          | 1                      |
      | schema1  | test5   | 0                          | 0                      |
      | schema1  | test1   | 1                          | 1                      |
      | schema1  | test2   | 1                          | 1                      |
      | schema1  | test6   | 1                          | 1                      |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                           | expect              | db      |
      | conn_0 | False   | insert into test1 values(1,1) | success             | schema1 |
      | conn_0 | False   | insert into test2 values(1,1) | success             | schema1 |
      | conn_0 | False   | insert into test3 values(1,1) | success             | schema1 |
      | conn_0 | False   | insert into test4 values(1,1) | success             | schema1 |
      | conn_0 | False   | insert into test5 values(1,1) | error totally whack | schema1 |
      | conn_0 | True    | insert into test6 values(1,1) | success             | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                        | expect  | db      |
      | conn_0 | False   | drop table if exists test1 | success | schema1 |
      | conn_0 | False   | drop table if exists test2 | success | schema1 |
      | conn_0 | False   | drop table if exists test3 | success | schema1 |
      | conn_0 | False   | drop table if exists test4 | success | schema1 |
      | conn_0 | False   | drop table if exists test5 | success | schema1 |
      | conn_0 | True    | drop table if exists test6 | success | schema1 |