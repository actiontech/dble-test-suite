# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by chenhuiming at 2020/7/2

Feature: config multi implicit ERtable

  Scenario: config multi implicit ERtable in one schema #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema dataNode="dn5" name="schema1" sqlMaxLimit="100">
          <table type="global" name="test" dataNode="dn1,dn2,dn3,dn4" />
          <table name="table1" dataNode="dn1,dn2" rule="hash-two"/>
          <table name="table2" dataNode="dn1,dn2" rule="hash-two"/>
          <table name="table3" dataNode="dn1,dn2" rule="hash-two"/>
      </schema>
    """
    Then execute admin cmd "reload @@config_all"

  Scenario: config multi implicit ERtable in different schema #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn5" name="schema1" sqlMaxLimit="100">
            <table type="global" name="test" dataNode="dn1,dn2,dn3,dn4" />
            <table name="table1" dataNode="dn1,dn2" rule="hash-two"/>
            <table name="table2" dataNode="dn1,dn2" rule="hash-two"/>
        </schema>
        <schema dataNode="dn5" name="schema2" sqlMaxLimit="100">
            <table type="global" name="test" dataNode="dn1,dn2,dn3,dn4" />
            <table name="table3" shardingNode="dn1,dn2" rule="hash-two"/>
            <table name="table4" shardingNode="dn1,dn2" rule="hash-two"/>
        </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
       <user name="test">
         <property name="password">111111</property>
         <property name="schemas">schema1,schema2</property>
       </user>
    """
    Then execute admin cmd "reload @@config_all"














