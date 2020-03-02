# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/9

Feature: two logical databases: declare the database of all tables when querying or declare the database of partial tables when querying

  Scenario: create two logical databases by configuration, declare the database of all tables when querying or declare the database of partial tables when querying #1
    Given add xml segment to node with attribute "{'tag':'user','kv_map':{'name':'test'}}" in "server.xml"
    """
    <property name="schemas">schema1,schema2</property>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" dataNode="dn5">
    <table name="sharding_2_t1" dataNode="dn1,dn2" rule="hash-two"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100">
    <table name="sharding_2_t2" dataNode="dn1,dn2" rule="hash-two"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
    <function name="two-long" class="Hash">
    <property name="partitionCount">2</property>
    <property name="partitionLength">512</property>
    </function>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                | expect                                                                                                                    | db      |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_2_t1                                                                                 | success                                                                                                                   | schema1 |
      | test | 111111 | conn_0 | False   | create table sharding_2_t1(id int, c_flag int, c_decimal float)                                                    | success                                                                                                                   | schema1 |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_2_t2                                                                                 | success                                                                                                                   | schema2 |
      | test | 111111 | conn_0 | True    | create table sharding_2_t2(id int, c_flag int, c_decimal float)                                                    | success                                                                                                                   | schema2 |
      | test | 111111 | conn_0 | True    | explain select * from schema1.sharding_2_t1 a join schema2.sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1 | hasStr{('dn1', 'BASE SQL', 'select * from sharding_2_t1 a join sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1')} |         |
      | test | 111111 | conn_0 | True    | explain select * from schema1.sharding_2_t1 a join sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1         | hasStr{('dn1', 'BASE SQL', 'select * from sharding_2_t1 a join sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1')} | schema2 |
      | test | 111111 | conn_0 | True    | explain select * from sharding_2_t1 a join schema2.sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1         | hasStr{('dn1', 'BASE SQL', 'select * from sharding_2_t1 a join sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1')} | schema1 |
