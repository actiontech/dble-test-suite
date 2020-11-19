# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/2/26

# 2.19.11.0#dble-7859
Feature: show the ddl statement being executed in different scenario

  @btrace
  Scenario: one database with one table #1
    Given stop dble cluster and zk service
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <globalTable name="test" shardingNode="dn3,dn4"/>
      </schema>
    """
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql         | expect                               |
      | conn_0 | False   | show @@help | hasStr{show @@ddl}                   |
      | conn_0 | False   | show @@help | hasStr{kill @@ddl_lock where schema} |
      | conn_0 | False   | show @@ddl  | length{(0)}                          |
      | conn_0 | True    | show @@DDL  | length{(0)}                          |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                       | expect  | db      |
      | conn_1 | False   | drop table if exists test | success | schema1 |
    Given update file content "./assets/BtraceDelayAfterDdl.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayAfterDdlExecuted/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given sleep "10" seconds
    Given prepare a thread execute sql "drop table if exists test" with "conn_1"
    Then check btrace "BtraceDelayAfterDdl.java" output in "dble-1"
    """
    get into delayAfterDdlExecuted
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql        | expect                            |
      | show @@ddl | hasStr{drop table if exists test} |
    Then execute sql in "dble-2" in "admin" mode
      | sql        | expect                            |
      | show @@ddl | hasStr{drop table if exists test} |
    Given destroy sql threads list
    Then execute sql in "dble-1" in "admin" mode
      | sql        | expect      |
      | show @@ddl | length{(0)} |
    Then execute sql in "dble-2" in "admin" mode
      | sql        | expect      |
      | show @@ddl | length{(0)} |
    Given stop btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceDelayAfterDdl.java" on "dble-1"
    Given delete file "/opt/dble/BtraceDelayAfterDdl.java.log" on "dble-1"


  @btrace
  Scenario: different database with same name of table #2
    Given stop dble cluster and zk service
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <globalTable name="test" shardingNode="dn3,dn4"/>
      </schema>
      <schema name="schema2" sqlMaxLimit="100" shardingNode="dn1">
        <globalTable name="test" shardingNode="dn1,dn2"/>
      </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"  readOnly="false"/>
    <shardingUser name="test" password="111111" schemas="schema1,schema2" readOnly="false"/>
    """
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                       | expect  | db      |
      | conn_1 | False   | drop table if exists test | success | schema1 |
      | conn_2 | False   | drop table if exists test | success | schema2 |
    Given update file content "./assets/BtraceDelayAfterDdl.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayAfterDdlExecuted/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given sleep "10" seconds
    Given prepare a thread execute sql "create table test(id int)" with "conn_1"
    Given prepare a thread execute sql "create table test(id int)" with "conn_2"
    Then check btrace "BtraceDelayAfterDdl.java" output in "dble-1" with "2" times
    """
    get into delayAfterDdlExecuted
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql        | expect                            |
      | show @@ddl | hasStr{create table test(id int)} |
      | show @@ddl | hasStr{create table test(id int)} |
    Then execute sql in "dble-2" in "admin" mode
      | sql        | expect                            |
      | show @@ddl | hasStr{create table test(id int)} |
      | show @@ddl | hasStr{create table test(id int)} |
    Given destroy sql threads list
    Then execute sql in "dble-1" in "admin" mode
      | sql        | expect      |
      | show @@ddl | length{(0)} |
      | show @@ddl | length{(0)} |
    Then execute sql in "dble-2" in "admin" mode
      | sql        | expect      |
      | show @@ddl | length{(0)} |
      | show @@ddl | length{(0)} |
    Given stop btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceDelayAfterDdl.java" on "dble-1"
    Given delete file "/opt/dble/BtraceDelayAfterDdl.java.log" on "dble-1"

  @btrace
  Scenario: same database with different table #3
    Given stop dble cluster and zk service
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <globalTable name="test1" shardingNode="dn1,dn2"/>
        <globalTable name="test2" shardingNode="dn3,dn4"/>
      </schema>
    """
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                        | expect  | db      |
      | conn_1 | False   | drop table if exists test1 | success | schema1 |
      | conn_2 | False   | drop table if exists test2 | success | schema1 |
    Given update file content "./assets/BtraceDelayAfterDdl.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayAfterDdlExecuted/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given sleep "10" seconds
    Given prepare a thread execute sql "drop table if exists test1" with "conn_1"
    Given prepare a thread execute sql "drop table if exists test2" with "conn_2"
    Then check btrace "BtraceDelayAfterDdl.java" output in "dble-1" with "2" times
    """
    get into delayAfterDdlExecuted
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql        | expect                             |
      | show @@ddl | hasStr{drop table if exists test1} |
      | show @@ddl | hasStr{drop table if exists test2} |
    Then execute sql in "dble-2" in "admin" mode
      | sql        | expect                             |
      | show @@ddl | hasStr{drop table if exists test1} |
      | show @@ddl | hasStr{drop table if exists test2} |
    Given destroy sql threads list
    Then execute sql in "dble-1" in "admin" mode
      | sql        | expect      |
      | show @@ddl | length{(0)} |
      | show @@ddl | length{(0)} |
    Then execute sql in "dble-2" in "admin" mode
      | sql        | expect      |
      | show @@ddl | length{(0)} |
      | show @@ddl | length{(0)} |
    Given stop btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceDelayAfterDdl.java" on "dble-1"
    Given delete file "/opt/dble/BtraceDelayAfterDdl.java.log" on "dble-1"