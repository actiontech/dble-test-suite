# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/2/26

  #2.19.11.0#dble-7874
Feature: multiple reload

  Scenario: execute reload @@config_all with different session at the same time after init metadata successed #1
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <table name="test1" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test2" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test3" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test4" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test5" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test6" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
    </schema>
        <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
        <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test1         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test2         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test3         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test4         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test5         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test6         | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test1(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test2(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test3(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test4(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test5(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test6(id int,age int) | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn | toClose | sql                 | expect  | db |
      | root | 111111 | new  | true    | reload @@config_all | success |    |
      | root | 111111 | new  | true    | reload @@config_all | success |    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                        | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test1 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test2 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test3 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test4 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test5 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test6 | success | schema1 |

  Scenario: execute reload @@metadata with different session at the same time after init metadata successed #2
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <table name="test1" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test2" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test3" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test4" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test5" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test6" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
    </schema>
        <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
        <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test1         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test2         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test3         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test4         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test5         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test6         | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test1(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test2(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test3(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test4(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test5(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test6(id int,age int) | success | schema1 |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect  | db      |
      | test | 111111 | conn_0 | true    | alter table test2 add name char(9) | success | schema1 |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect  | db      |
      | test | 111111 | conn_0 | true    | alter table test1 add name char(9) | success | schema1 |
    Then get resultset of admin cmd "check full @@metadata where schema='schema1'" named "metadata_rs_a"
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
      | user | passwd | conn | toClose | sql               | expect  | db |
      | root | 111111 | new  | true    | reload @@metadata | success |    |
      | root | 111111 | new  | true    | reload @@metadata | success |    |
    Then get resultset of admin cmd "check full @@metadata where schema='schema1'" named "metadata_rs_e"
    Then check resultset "metadata_rs_e" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test3   | 1                          | 1                      |
      | schema1  | test4   | 1                          | 1                      |
      | schema1  | test5   | 1                          | 1                      |
      | schema1  | test1   | 1                          | 1                      |
      | schema1  | test2   | 1                          | 1                      |
      | schema1  | test6   | 1                          | 1                      |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                             | expect  | db      |
      | test | 111111 | conn_0 | true    | insert into test1 values(1,1,1) | success | schema1 |
      | test | 111111 | conn_0 | true    | insert into test2 values(1,1,1) | success | schema1 |
      | test | 111111 | conn_0 | true    | insert into test3 values(1,1)   | success | schema1 |
      | test | 111111 | conn_0 | true    | insert into test4 values(1,1)   | success | schema1 |
      | test | 111111 | conn_0 | true    | insert into test5 values(1,1)   | success | schema1 |
      | test | 111111 | conn_0 | true    | insert into test6 values(1,1)   | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                        | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test1 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test2 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test3 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test4 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test5 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test6 | success | schema1 |

  @btrace
  Scenario: execute reload @@config_all with different session at the same time after init metadata failed #3
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <table name="test1" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test2" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test3" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test4" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test5" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test6" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
    </schema>
        <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
        <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test1         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test2         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test3         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test4         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test5         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test6         | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test1(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test2(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test3(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test4(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test5(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test6(id int,age int) | success | schema1 |
    Then execute admin cmd "reload @@config_all -r"
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /getSpecialNodeTablesHandlerFinished/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose | sql                    | db      |
      | root | 111111 | conn_0 | True    | reload @@config_all -r | schema1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
    """
    get into getSpecialNodeTablesHandlerFinished
    """
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql              | expect  | db  |
      | test | 111111 | conn_0 | True    | drop table test5 | success | db1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1" with "2" times
    """
    get into getSpecialNodeTablesHandlerFinished
    """
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql              | expect  | db  |
      | test | 111111 | conn_0 | True    | drop table test5 | success | db2 |
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn | toClose | sql                    | expect  | db |
      | root | 111111 | new  | true    | reload @@config_all -r | success |    |
      | root | 111111 | new  | true    | reload @@config_all -r | success |    |
    Then get resultset of admin cmd "check full @@metadata where schema='schema1'" named "metadata_rs_a"
    Then check resultset "metadata_rs_a" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test3   | 1                          | 1                      |
      | schema1  | test4   | 1                          | 1                      |
      | schema1  | test5   | 0                          | 0                      |
      | schema1  | test1   | 1                          | 1                      |
      | schema1  | test2   | 1                          | 1                      |
      | schema1  | test6   | 1                          | 1                      |
    Then get resultset of admin cmd "check full @@metadata where consistent_in_memory=0" named "metadata_rs_b"
    Then check resultset "metadata_rs_b" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test5   | 0                          | 0                      |
    Then get resultset of admin cmd "check full @@metadata where consistent_in_memory=1" named "metadata_rs_c"
    Then check resultset "metadata_rs_c" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test3   | 1                          | 1                      |
      | schema1  | test4   | 1                          | 1                      |
      | schema1  | test1   | 1                          | 1                      |
      | schema1  | test2   | 1                          | 1                      |
      | schema1  | test6   | 1                          | 1                      |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                           | expect              | db      |
      | test | 111111 | conn_0 | True    | insert into test1 values(1,1) | success             | schema1 |
      | test | 111111 | conn_0 | True    | insert into test2 values(1,1) | success             | schema1 |
      | test | 111111 | conn_0 | True    | insert into test3 values(1,1) | success             | schema1 |
      | test | 111111 | conn_0 | True    | insert into test4 values(1,1) | success             | schema1 |
      | test | 111111 | conn_0 | True    | insert into test5 values(1,1) | error totally whack | schema1 |
      | test | 111111 | conn_0 | True    | insert into test6 values(1,1) | success             | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                        | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test1 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test2 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test3 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test4 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test5 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test6 | success | schema1 |

  @btrace
  Scenario: execute reload @@metadata with different session at the same time after init metadata failed #4
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <table name="test1" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test2" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test3" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test4" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test5" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
        <table name="test6" dataNode="dn1,dn2" rule="hash-two" cacheKey="id"/>
    </schema>
        <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
        <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test1         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test2         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test3         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test4         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test5         | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test6         | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test1(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test2(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test3(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test4(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test5(id int,age int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test6(id int,age int) | success | schema1 |
    Then execute admin cmd "reload @@config_all -r"
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /getSpecialNodeTablesHandlerFinished/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose | sql               | db      |
      | root | 111111 | conn_0 | True    | reload @@metadata | schema1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
    """
    get into getSpecialNodeTablesHandlerFinished
    """
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql              | expect  | db  |
      | test | 111111 | conn_0 | True    | drop table test5 | success | db1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1" with "2" times
    """
    get into getSpecialNodeTablesHandlerFinished
    """
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql              | expect  | db  |
      | test | 111111 | conn_0 | True    | drop table test5 | success | db2 |
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn | toClose | sql               | expect  | db |
      | root | 111111 | new  | true    | reload @@metadata | success |    |
      | root | 111111 | new  | true    | reload @@metadata | success |    |
    Then get resultset of admin cmd "check full @@metadata where schema='schema1'" named "metadata_rs_e"
    Then check resultset "metadata_rs_e" has lines with following column values
      | schema-0 | table-1 | consistent_in_data_nodes-4 | consistent_in_memory-5 |
      | schema1  | test3   | 1                          | 1                      |
      | schema1  | test4   | 1                          | 1                      |
      | schema1  | test5   | 0                          | 0                      |
      | schema1  | test1   | 1                          | 1                      |
      | schema1  | test2   | 1                          | 1                      |
      | schema1  | test6   | 1                          | 1                      |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                           | expect              | db      |
      | test | 111111 | conn_0 | True    | insert into test1 values(1,1) | success             | schema1 |
      | test | 111111 | conn_0 | True    | insert into test2 values(1,1) | success             | schema1 |
      | test | 111111 | conn_0 | True    | insert into test3 values(1,1) | success             | schema1 |
      | test | 111111 | conn_0 | True    | insert into test4 values(1,1) | success             | schema1 |
      | test | 111111 | conn_0 | True    | insert into test5 values(1,1) | error totally whack | schema1 |
      | test | 111111 | conn_0 | True    | insert into test6 values(1,1) | success             | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                        | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test1 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test2 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test3 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test4 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test5 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test6 | success | schema1 |