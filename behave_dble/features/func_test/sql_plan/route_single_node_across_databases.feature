# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/9
#2.19.11.0#dble-7875
Feature: two logical databases: declare the database of all tables when querying or declare the database of partial tables when querying

  Scenario: create two logical databases by configuration, declare the database of all tables when querying or declare the database of partial tables when querying #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2" readOnly="false"/>
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
    <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="two-long" shardingColumn="id"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100">
    <shardingTable name="sharding_2_t2" shardingNode="dn1,dn2" function="two-long" shardingColumn="id"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <function name="two-long" class="Hash">
    <property name="partitionCount">2</property>
    <property name="partitionLength">512</property>
    </function>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                | expect                                                                                                                    | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1                                                                                 | success                                                                                                                   | schema1 |
      | conn_0 | False   | create table sharding_2_t1(id int, c_flag int, c_decimal float)                                                    | success                                                                                                                   | schema1 |
      | conn_0 | False   | drop table if exists sharding_2_t2                                                                                 | success                                                                                                                   | schema2 |
      | conn_0 | True    | create table sharding_2_t2(id int, c_flag int, c_decimal float)                                                    | success                                                                                                                   | schema2 |
      | conn_0 | True    | explain select * from schema1.sharding_2_t1 a join schema2.sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1 | hasStr{('dn1', 'BASE SQL', 'select * from sharding_2_t1 a join sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1')} |         |
      | conn_0 | True    | explain select * from schema1.sharding_2_t1 a join sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1         | hasStr{('dn1', 'BASE SQL', 'select * from sharding_2_t1 a join sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1')} | schema2 |
      | conn_0 | True    | explain select * from sharding_2_t1 a join schema2.sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1         | hasStr{('dn1', 'BASE SQL', 'select * from sharding_2_t1 a join sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1')} | schema1 |
