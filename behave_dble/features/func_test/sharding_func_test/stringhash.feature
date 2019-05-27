# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: stringhash sharding function test suits

  @BLOCKER
  Scenario: stringhash function
    #test: <= 2880
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <tableRule name="string_hash_rule">
            <rule>
                <columns>id</columns>
                <algorithm>string_hash_func</algorithm>
            </rule>
        </tableRule>
        <function class="stringhash" name="string_hash_func">
            <property name="partitionCount">4</property>
            <property name="partitionLength">721</property>
            <property name="hashSlice">0:2</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Sum(count[i]*length[i]) must be less than 2880
    """
    #test: uniform
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <function class="stringhash" name="string_hash_func">
            <property name="partitionCount">4</property>
            <property name="partitionLength">256</property>
            <property name="hashSlice">0:2</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="string_hash_table" dataNode="dn1,dn2,dn3,dn4" rule="string_hash_rule" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                         | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists string_hash_table                      | success | schema1 |
        | test | 111111 | conn_0 | False    | create table string_hash_table(id varchar(10))              | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into string_hash_table values(null)/*dest_node:dn1*/ | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into string_hash_table values('aa')/*dest_node:dn1*/ | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into string_hash_table values('bb')/*dest_node:dn1*/ | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into string_hash_table values('jj')/*dest_node:dn2*/ | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into string_hash_table values('rr')/*dest_node:dn3*/ | success | schema1 |
        | test | 111111 | conn_0 | True     | insert into string_hash_table values('zz')/*dest_node:dn4*/ | success | schema1 |

    #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    {"table":"string_hash_table","key":"id"}
    """
    #test: data types in sharding_key
    #Then Test the data types supported by the sharding column in "hashString.sql"
    #test: non-uniform
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <function class="stringhash" name="string_hash_func">
            <property name="partitionCount">2,1</property>
            <property name="partitionLength">256,512</property>
            <property name="hashSlice">0:2</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="string_hash_table" dataNode="dn1,dn2,dn3" rule="string_hash_rule" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                         | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists string_hash_table                      | success | schema1 |
        | test | 111111 | conn_0 | False    | create table string_hash_table(id varchar(10))              | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into string_hash_table values('aa')/*dest_node:dn1*/ | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into string_hash_table values('bb')/*dest_node:dn1*/ | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into string_hash_table values('jj')/*dest_node:dn2*/ | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into string_hash_table values('rr')/*dest_node:dn3*/ | success | schema1 |
        | test | 111111 | conn_0 | True     | insert into string_hash_table values('zz')/*dest_node:dn3*/ | success | schema1 |
    #clearn all conf
    Given delete the following xml segment
      |file        | parent                                        | child                                                    |
      |rule.xml    | {'tag':'root'}                                | {'tag':'tableRule','kv_map':{'name':'string_hash_rule'}} |
      |rule.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'string_hash_func'}}  |
      |schema.xml  | {'tag':'schema','kv_map':{'name':'schema1'}}   | {'tag':'table','kv_map':{'name':'string_hash_table'}}    |
    Then execute admin cmd "reload @@config_all"