# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/2/26

# 2.19.11.0#dble-7860
Feature: check 'kill @@ddl_lock where schema=? and table=?' work normal
  @btrace
  Scenario: check 'kill @@ddl_lock where schema=? and table=?' work normal #1
    Given reset dble registered nodes in zk
    Given delete the following xml segment
      | file              | parent         | child              |
      | sharding.xml     | {'tag':'root'} | {'tag':'shardingNode'} |
      | db.xml     | {'tag':'root'} | {'tag':'dbGroup'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema2" sqlMaxLimit="100" shardingNode="dn1">
        <globalTable name="test" shardingNode="dn1,dn2"/>
    </schema>
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn4">
        <globalTable name="test" shardingNode="dn3,dn4"/>
    </schema>
    <shardingNode name="dn1" dbGroup="ha_group1" database="db1"/>
    <shardingNode name="dn2" dbGroup="ha_group1" database="db2"/>
    <shardingNode name="dn3" dbGroup="ha_group1" database="db3"/>
    <shardingNode name="dn4" dbGroup="ha_group1" database="db4"/>

    """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
     <heartbeat>select user()</heartbeat>
     <dbInstance name="hostM1" url="172.100.9.5:3306" password="111111" user="test" maxCon="5" minCon="4" primary="true"/>
     </dbGroup>
    """
     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"  readOnly="false"/>
    <shardingUser name="test" password="111111" schemas="schema1,schema2" readOnly="false"/>
    """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                     | expect                               |
      | conn_0 | False   | create database @@shardingNode='dn$1-4'                     | success                              |
      | conn_0 | False   | show @@help                                             | hasStr{show @@ddl}                   |
      | conn_0 | False   | show @@help                                             | hasStr{kill @@ddl_lock where schema} |
      | conn_0 | False   | kill @@ddl_lock where schema='schema1' and table='test' | success                              |
      | conn_0 | True    | kill @@ddl_lock where schema=schema1 and table=test     | success                              |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                       | expect  | db      |
      | conn_0 | false   | drop table if exists test | success | schema1 |
    Given update file content "./assets/BtraceDelayAfterDdl.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayAfterDdlExecuted/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given sleep "10" seconds
    Given prepare a thread execute sql "drop table if exists test" with "conn_0"
    Then check btrace "BtraceDelayAfterDdl.java" output in "dble-1"
    """
    get into delayAfterDdlExecuted
    """
    Then execute sql in "dble-2" in "admin" mode
      | conn   | toClose | sql                                                 | expect                              |
      | conn_2 | false   | show @@ddl                                          | hasStr{drop table if exists test}   |
      | conn_2 | false   | kill @@ddl_lock where schema=schema1 and table=test | success                             |
      | conn_2 | true    | show @@ddl                                          | hasNoStr{drop table if exists test} |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect                              |
      | conn_1 | false   | show @@ddl                                          | hasStr{drop table if exists test}   |
      | conn_1 | false   | kill @@ddl_lock where schema=schema1 and table=test | success                             |
      | conn_1 | false   | show @@ddl                                          | hasNoStr{drop table if exists test} |
      | conn_1 | true    | reload @@metadata                                   | success                             |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "rs_A"
      | sql                       |
      | show @@backend.statistics |
    Then check resultset "rs_A" has lines with following column values
      | TOTAL-3 |
      | 5      |
    Given stop btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceDelayAfterDdl.java" on "dble-1"
    Given delete file "/opt/dble/BtraceDelayAfterDdl.java.log" on "dble-1"
    Given destroy sql threads list
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                            | expect      | db      |
      | new    | true    | create table test(id int)      | success     | schema1 |
      | new    | true    | insert into test values(1),(2) | success     | schema1 |
      | conn_4 | false   | begin                          | success     | schema1 |
      | conn_4 | false   | select * from test             | length{(2)} | schema1 |
      | conn_1 | false   | begin                          | success     | schema1 |
      | conn_1 | false   | select * from test             | length{(2)} | schema1 |
      | conn_2 | false   | begin                          | success     | schema1 |
      | conn_2 | false   | select * from test             | length{(2)} | schema1 |
      | conn_3 | false   | begin                          | success     | schema1 |
      | conn_3 | false   | select * from test             | length{(2)} | schema1 |
      | conn_4 | true    | commit                         | success     | schema1 |
      | conn_1 | true    | commit                         | success     | schema1 |
      | conn_2 | true    | commit                         | success     | schema1 |
      | conn_3 | true    | commit                         | success     | schema1 |
      | new    | true    | drop table if exists test      | success     | schema1 |
