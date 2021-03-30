# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/03/30

Feature: test xml

  Scenario: DBLE0REQ-1019 #1
    # set xml haven't schema  shardingNode  dbGroup shardingUser, Simulate dmp initialization
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml  | {'tag':'root'} | {'tag':'shardingNode'} |
      | db.xml        | {'tag':'root'} | {'tag':'dbGroup'}      |
      | user.xml      | {'tag':'root'} | {'tag':'shardingUser'} |
    Then execute admin cmd "reload @@config"
    Given Restart dble in "dble-1" success

    # set xml have effective value,mysql 1m2s
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10"/>
        <dbInstance name="hostS2" password="111111" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10"/>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1"/>
    """
    Then execute admin cmd "reload @@config"
    # ddl not hang
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                  | expect       | db      |
      | conn_1  | false   | drop table if exists test            | success      | schema1 |
      | conn_1  | false   | create table test (id int)           | success      | schema1 |
      | conn_1  | false   | create view view_test as select * from test             | success      | schema1 |
      | conn_1  | true    | select * from view_test                                 | success      | schema1 |