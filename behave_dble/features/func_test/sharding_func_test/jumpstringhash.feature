# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: jumpstringhash sharding function test suits

  Scenario: jumpstringhash function #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="jumpStringHash" name="jump_string_hash_func">
            <property name="partitionCount">4</property>
            <property name="hashSlice">0:2</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="jump_string_hash_table" shardingNode="dn1,dn2,dn3,dn4" function="jump_string_hash_func" shardingColumn="id"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                 | expect                  | db      |
      | conn_0 | False    | drop table if exists jump_string_hash_table         | success                 | schema1 |
      | conn_0 | False    | create table jump_string_hash_table(id varchar(10)) | success                 | schema1 |
      | conn_0 | False    | insert into jump_string_hash_table values(null)     | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into jump_string_hash_table values('aa')     | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into jump_string_hash_table values('af')     | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into jump_string_hash_table values('rr')     | dest_node:mysql-master1 | schema1 |
      | conn_0 | True     | insert into jump_string_hash_table values('zz')     | dest_node:mysql-master2 | schema1 |

    #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    {"table":"jump_string_hash_table","key":"id"}
    """
    #clearn all conf
    Given delete the following xml segment
      |file        | parent                                        | child                                                    |
      |sharding.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'jump_string_hash_func'}}  |
      |sharding.xml  | {'tag':'schema','kv_map':{'name':'schema1'}}   | {'tag':'shardingTable','kv_map':{'name':'jump_string_hash_table'}}    |
    Then execute admin cmd "reload @@config_all"