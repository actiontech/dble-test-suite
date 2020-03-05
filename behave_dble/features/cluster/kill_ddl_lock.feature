# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/2/26

# 2.19.11.0#dble-7860
Feature: check 'kill @@ddl_lock where schema=? and table=?' work normal

  @btrace
  Scenario: check 'kill @@ddl_lock where schema=? and table=?' work normal #1
    Given stop dble cluster and zk service
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema2" sqlMaxLimit="100" dataNode="dn1">
        <table name="test" dataNode="dn1,dn2" type="global"/>
    </schema>
    <schema name="schema1" sqlMaxLimit="100" dataNode="dn4">
        <table name="test" dataNode="dn3,dn4" type="global"/>
    </schema>
    <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
    <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
    <dataNode name="dn3" dataHost="ha_group1" database="db3"/>
    <dataNode name="dn4" dataHost="ha_group1" database="db4"/>
        <dataHost balance="0" maxCon="5" minCon="4" name="ha_group1" switchType="1" slaveThreshold="100">
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM1" url="172.100.9.5:3306" password="111111" user="test"/>
    </dataHost>

    """
   Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
      <user name="test">
         <property name="password">111111</property>
         <property name="schemas">schema1,schema2</property>
      </user>
      <user name="root">
         <property name="password">111111</property>
         <property name="manager">true</property>
      </user>
    """
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order

    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                                     | expect                               | db |
      | root | 111111 | conn_0 | True    | create database @@dataNode='dn$1-4'                     | success                              |    |
      | root | 111111 | conn_0 | True    | show @@help                                             | hasStr{show @@ddl}                   |    |
      | root | 111111 | conn_0 | True    | show @@help                                             | hasStr{kill @@ddl_lock where schema} |    |
      | root | 111111 | conn_0 | True    | kill @@ddl_lock where schema='schema1' and table='test' | success                              |    |
      | root | 111111 | conn_0 | True    | kill @@ddl_lock where schema=schema1 and table=test     | success                              |    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                       | expect  | db      |
      | test | 111111 | conn_0 | false   | drop table if exists test | success | schema1 |
    Given change btrace "BtraceDelayAfterDdl.java" locate "./assets" with sed cmds
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
      | user | passwd | conn   | toClose | sql                                                 | expect                            | db |
      | root | 111111 | conn_2 | false   | show @@ddl                                          | hasStr{drop table if exists test} |    |
      | root | 111111 | conn_2 | false   | kill @@ddl_lock where schema=schema1 and table=test | success                           |    |
      | root | 111111 | conn_2 | true    | show @@ddl                                          | hasNoStr{drop table if exists test} |    |
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                                 | expect                            | db |
      | root | 111111 | conn_1 | false   | show @@ddl                                          | hasStr{drop table if exists test} |    |
      | root | 111111 | conn_1 | false   | kill @@ddl_lock where schema=schema1 and table=test | success                           |    |
      | root | 111111 | conn_1 | false   | show @@ddl                                          | hasNoStr{drop table if exists test} |    |
      | root | 111111 | conn_1 | true    | reload @@metadata                                   | success                           |    |
    Then get resultset of admin cmd "show @@backend.statistics" named "rs_A"
    Then check resultset "rs_A" has lines with following column values
      | TOTAL-3 |
      | 5       |
    Given stop btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceDelayAfterDdl.java" on "dble-1"
    Given delete file "/opt/dble/BtraceDelayAfterDdl.java.log" on "dble-1"
    Given destroy sql threads list
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                            | expect      | db      |
      | test | 111111 | new    | true    | create table test(id int)      | success     | schema1 |
      | test | 111111 | new    | true    | insert into test values(1),(2) | success     | schema1 |
      | test | 111111 | conn_4 | false   | begin                          | success     | schema1 |
      | test | 111111 | conn_4 | false   | select * from test             | length{(2)} | schema1 |
      | test | 111111 | conn_1 | false   | begin                          | success     | schema1 |
      | test | 111111 | conn_1 | false   | select * from test             | length{(2)} | schema1 |
      | test | 111111 | conn_2 | false   | begin                          | success     | schema1 |
      | test | 111111 | conn_2 | false   | select * from test             | length{(2)} | schema1 |
      | test | 111111 | conn_3 | false   | begin                          | success     | schema1 |
      | test | 111111 | conn_3 | false   | select * from test             | length{(2)} | schema1 |
      | test | 111111 | conn_4 | true    | commit                         | success     | schema1 |
      | test | 111111 | conn_1 | true    | commit                         | success     | schema1 |
      | test | 111111 | conn_2 | true    | commit                         | success     | schema1 |
      | test | 111111 | conn_3 | true    | commit                         | success     | schema1 |
      | test | 111111 | new    | true    | drop table if exists test      | success     | schema1 |
