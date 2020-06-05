# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: stringhash sharding function test suits

  @BLOCKER
  Scenario: stringhash function #1
    #test: <= 2880
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
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
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="stringhash" name="string_hash_func">
            <property name="partitionCount">4</property>
            <property name="partitionLength">256</property>
            <property name="hashSlice">0:2</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="string_hash_table" shardingNode="dn1,dn2,dn3,dn4" function="string_hash_func" shardingColumn="id"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                             | expect                  | db      |
      | conn_0 | False    | drop table if exists string_hash_table          | success                 | schema1 |
      | conn_0 | False    | create table string_hash_table(id varchar(10))  | success                 | schema1 |
      | conn_0 | False    | insert into string_hash_table values(null)      | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into string_hash_table values('aa')      | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into string_hash_table values('bb')      | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into string_hash_table values('jj')      | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into string_hash_table values('rr')      | dest_node:mysql-master1 | schema1 |
      | conn_0 | True     | insert into string_hash_table values('zz')      | dest_node:mysql-master2 | schema1 |

    #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    {"table":"string_hash_table","key":"id"}
    """
    #test: data types in sharding_key
    #Then Test the data types supported by the sharding column in "hashString.sql"
    #test: non-uniform
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="stringhash" name="string_hash_func">
            <property name="partitionCount">2,1</property>
            <property name="partitionLength">256,512</property>
            <property name="hashSlice">0:2</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="string_hash_table" shardingNode="dn1,dn2,dn3" function="string_hash_func" shardingColumn="id" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                             | expect                  | db      |
      | conn_0 | False    | drop table if exists string_hash_table          | success                 | schema1 |
      | conn_0 | False    | create table string_hash_table(id varchar(10))  | success                 | schema1 |
      | conn_0 | False    | insert into string_hash_table values('aa')      | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into string_hash_table values('bb')      | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into string_hash_table values('jj')      | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into string_hash_table values('rr')      | dest_node:mysql-master1 | schema1 |
      | conn_0 | True     | insert into string_hash_table values('zz')      | dest_node:mysql-master1 | schema1 |
    #clearn all conf
    Given delete the following xml segment
      |file        | parent                                        | child                                                    |
      |sharding.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'string_hash_func'}}  |
      |sharding.xml  | {'tag':'schema','kv_map':{'name':'schema1'}}  | {'tag':'shardingTable','kv_map':{'name':'string_hash_table'}}    |
    Then execute admin cmd "reload @@config_all"