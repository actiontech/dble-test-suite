# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/11/27
Feature: test default db change right; cross db table with same name not affected by others; and cross db sql works right

  Background: config for this test suites
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
            <globalTable shardingNode="dn1,dn2" name="test1" />
            <shardingTable shardingNode="dn1,dn2,dn3,dn4" name="test2" function="hash-four" shardingColumn="id" />
    </schema>
    <schema name="testdb" sqlMaxLimit="100">
            <shardingTable shardingNode="dn3,dn4" name="test1" function="hash-two" shardingColumn="id" />
            <shardingTable shardingNode="dn1,dn2,dn3,dn4" name="test3" function="hash-four" shardingColumn="id" />
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
     """
     <shardingUser name="test" password="111111" schemas="schema1,testdb" readOnly="false"/>
    """
    Then execute admin cmd "reload @@config_all"

  @BLOCKER @skip_restart
  Scenario: default db not set;cross db table not affected by others; and cross db sql works right #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect  |
      | conn_0 | False   | drop table if exists test1                      | No database selected |
      | conn_0 | False   | drop table if exists schema1.test1              | success |
      | conn_0 | False   | drop table if exists schema1.test               | success |
      | conn_0 | False   | drop table if exists testdb.test1               | success |
      | conn_0 | False   | use schema1                                     | success |
      | conn_0 | False   | create table test1(id int,c int)                | success |
      | conn_0 | False   | use testdb                                      | success |
      | conn_0 | False   | create table test1(id int)                      | success |
      | conn_0 | False   | select c from schema1.test1                     | success |
#      | conn_0 | False   | select * from test1 join schema1.test1 using(id) | success |    #865
      | conn_0 | False   | select * from test1 join testdb.test1 using(id) | Not unique table/alias |
#      | conn_0 | False   | select * from schema1.test1 join testdb.test1 using(id) | success |    #865
      | conn_0 | False   | drop table test1                                | success |
      | conn_0 | False   | select c from schema1.test1                     | success |
      | conn_0 | True    | select c from test1                             | Table 'db2.test1' doesn't exist |
