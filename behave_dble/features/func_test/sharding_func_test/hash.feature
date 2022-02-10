# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature:hash sharding function test suits
  @smoke
  Scenario: hash function #1
    #test: <= 2880
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="Hash" name="hash_func">
            <property name="partitionCount">4</property>
            <property name="partitionLength">721</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Sum(count[i]*length[i]) must be less than 2880
    """
    #test: uniform
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="Hash" name="hash_func">
            <property name="partitionCount">4</property>
            <property name="partitionLength">1</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="hash_table" shardingNode="dn1,dn2,dn3,dn4" function="hash_func" shardingColumn="id"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                    | expect                  | db      |
      | conn_0 | False    | drop table if exists hash_table        | success                 | schema1 |
      | conn_0 | False    | create table hash_table(id int)        | success                 | schema1 |
      | conn_0 | False    | insert into hash_table values(null)    | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into hash_table values(-1)      | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into hash_table values(-2)      | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into hash_table values(0)       | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into hash_table values(1)       | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into hash_table values(2)       | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into hash_table values(3)       | dest_node:mysql-master2 | schema1 |
      | conn_0 | True     | insert into hash_table values(4)       | dest_node:mysql-master1 | schema1 |

     #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    {"table":"hash_table","key":"id"}
    """
    #test: data types in sharding_key
    Then Test the data types supported by the sharding column in "hashInteger.sql"
    #test: non-uniform
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="Hash" name="hash_func">
            <property name="partitionCount">3,1</property>
            <property name="partitionLength">200,300</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="hash_table" shardingNode="dn1,dn2,dn3,dn4" function="hash_func" shardingColumn="id"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                  | expect                  | db      |
      | conn_0 | False    | drop table if exists hash_table      | success                 | schema1 |
      | conn_0 | False    | create table hash_table(id int)      | success                 | schema1 |
      | conn_0 | False    | insert into hash_table values(-1)    | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into hash_table values(-2)    | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into hash_table values(-300)  | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into hash_table values(-301)  | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into hash_table values(0)     | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into hash_table values(1)     | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into hash_table values(2)     | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into hash_table values(199)   | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into hash_table values(200)   | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into hash_table values(399)   | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into hash_table values(400)   | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into hash_table values(599)   | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into hash_table values(600)   | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into hash_table values(999)   | dest_node:mysql-master1 | schema1 |
      | conn_0 | True     | insert into hash_table values(1000)  | dest_node:mysql-master1 | schema1 |
    #clearn all conf
    Given delete the following xml segment
      |file        | parent                                        | child                                             |
      |sharding.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'hash_func'}}  |
      |sharding.xml  | {'tag':'schema','kv_map':{'name':'schema1'}}  | {'tag':'shardingTable','kv_map':{'name':'hash_table'}}    |
    Then execute admin cmd "reload @@config_all"