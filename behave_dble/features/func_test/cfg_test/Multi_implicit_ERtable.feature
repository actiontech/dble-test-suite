# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by chenhuiming at 2020/7/2

Feature: config multi implicit ERtable

  Scenario: config multi implicit ERtable in one schema #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
          <shardingTable name="table1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
          <shardingTable name="table2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
          <shardingTable name="table3" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
      </schema>
    """
    Then execute admin cmd "reload @@config_all"

  Scenario: config multi implicit ERtable in different schema #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
            <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
            <shardingTable name="table1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
            <shardingTable name="table2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        </schema>
        <schema shardingNode="dn5" name="schema2" sqlMaxLimit="100">
            <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
            <shardingTable name="table3" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
            <shardingTable name="table4" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2" readOnly="false"/>
    """
    Then execute admin cmd "reload @@config_all"














