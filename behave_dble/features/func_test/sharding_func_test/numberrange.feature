# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: numberrange sharding function test suits

  @BLOCKER
  Scenario: numberrange function #1
    #test: set defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="numberrange" name="numberrange_func">
            <property name="mapFile">partition.txt</property>
            <property name="defaultNode">3</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="numberrange_table" shardingNode="dn1,dn2,dn3,dn4" function="numberrange_func" shardingColumn="id" />
    """
    When Add some data in "partition.txt"
    """
    0-255=0
    256-500=1
    501-755=2
    756-1000=3
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                         | expect                  | db      |
      | conn_0 | False    | drop table if exists numberrange_table      | success                 | schema1 |
      | conn_0 | False    | create table numberrange_table(id int)      | success                 | schema1 |
      | conn_0 | False    | insert into numberrange_table values(null)  | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into numberrange_table values(-1)    | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into numberrange_table values(0)     | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into numberrange_table values(255)   | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into numberrange_table values(256)   | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into numberrange_table values(500)   | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into numberrange_table values(501)   | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into numberrange_table values(755)   | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into numberrange_table values(756)   | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into numberrange_table values(1000)  | dest_node:mysql-master2 | schema1 |
      | conn_0 | True     | insert into numberrange_table values(1001)  | dest_node:mysql-master2 | schema1 |

    #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    {"table":"numberrange_table","key":"id"}
    """
    #test: not defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="numberrange" name="numberrange_func">
            <property name="mapFile">partition.txt</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect                         | db      |
      | conn_0 | False    | drop table if exists numberrange_table     | success                        | schema1 |
      | conn_0 | False    | create table numberrange_table(id int)     | success                        | schema1 |
      | conn_0 | False    | insert into numberrange_table values(0)    | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into numberrange_table values(255)  | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into numberrange_table values(256)  | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into numberrange_table values(500)  | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into numberrange_table values(501)  | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into numberrange_table values(755)  | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into numberrange_table values(756)  | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into numberrange_table values(1000) | dest_node:mysql-master2        | schema1 |
      | conn_0 | True     | insert into numberrange_table values(1001) | can't find any valid shardingNode | schema1 |
      | conn_0 | False    | insert into numberrange_table values(null) | can't find any valid shardingNode | schema1 |
      | conn_0 | True     | insert into numberrange_table values(-1)   | can't find any valid shardingNode | schema1 |
      | conn_0 | True     | insert into numberrange_table values(-2)   | can't find any valid shardingNode | schema1 |

    #test: data types in sharding_key
    Then Test the data types supported by the sharding column in "range.sql"
    #clearn all conf
    Given delete the following xml segment
      |file        | parent                                        | child                                  |
      |sharding.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'numberrange_func'}}  |
      |sharding.xml  | {'tag':'schema','kv_map':{'name':'schema1'}}   | {'tag':'shardingTable','kv_map':{'name':'numberrange_table'}}    |
    Then execute admin cmd "reload @@config_all"