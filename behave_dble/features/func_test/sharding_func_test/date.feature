# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature:Date sharding function
  @BLOCKER
  Scenario: Date sharding function #1
    #test: sBeginDate not configured
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sEndDate">2018-01-31</property>
            <property name="sPartionDay">10</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    java.lang.RuntimeException: sBeginDate can not be null
    """

    #test: sBegin < sEndDate-nodes*sPartition+1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sBeginDate">2017-01-01</property>
            <property name="sEndDate">2018-01-31</property>
            <property name="sPartionDay">10</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="date_table" shardingNode="dn1,dn2,dn3,dn4" function="date_func" shardingColumn="id" />
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    please make sure table shardingnode size = function partition size
    """

    #test: set sBeginDate and defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sBeginDate">2017-12-01</property>
            <property name="sEndDate">2018-01-8</property>
            <property name="sPartionDay">10</property>
            <property name="defaultNode">3</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                          | expect                  | db      |
      | conn_0 | False    | drop table if exists date_table                              | success                 | schema1 |
      | conn_0 | False    | create table date_table(id date)                             | success                 | schema1 |
      | conn_0 | False    | insert into date_table values(null)                          | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into date_table values('2017-11-11')                  | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-01')                  | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-11')                  | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-21')                  | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-31')                  | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into date_table values('2018-1-8')                    | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into date_table values('2018-01-9')                   | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | drop table if exists date_table                              | success                 | schema1 |
      | conn_0 | False    | create table date_table(id timestamp, c timestamp)           | success                 | schema1 |
      | conn_0 | True     | insert into date_table values (null,null)                    | Sharding column can't be null when the table in MySQL column is not null   | schema1 |

    #test: set sEndDate and no defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sBeginDate">2017-12-01</property>
            <property name="sEndDate">2018-01-8</property>
            <property name="sPartionDay">10</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                          | expect                         | db      |
      | conn_0 | False    | drop table if exists date_table              | success                        | schema1 |
      | conn_0 | False    | create table date_table(id date)             | success                        | schema1 |
      | conn_0 | False    | insert into date_table values(null)          | can't find any valid shardingNode | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-01')  | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-11')  | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-21')  | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-31')  | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into date_table values('2018-01-8')   | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into date_table values('2018-01-9')   | dest_node:mysql-master2        | schema1 |
      | conn_0 | True     | insert into date_table values('2017-11-11')  | can't find any valid shardingNode | schema1 |

     #test: not sEndDate and set defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sBeginDate">2017-12-01</property>
            <property name="sPartionDay">10</property>
            <property name="defaultNode">3</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                           | expect                         | db      |
      | conn_0 | False    | drop table if exists date_table               | success                        | schema1 |
      | conn_0 | False    | create table date_table(id date)              | success                        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-11-11')   | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-01')   | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-11')   | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-21')   | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-31')   | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into date_table values('2018-1-8')     | dest_node:mysql-master2        | schema1 |
      | conn_0 | True     | insert into date_table values('2018-11-11')   | can't find any valid shardingNode | schema1 |

    #test: set not sEndDate and not defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sBeginDate">2017-12-01</property>
            <property name="sPartionDay">10</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                         | expect                         | db      |
      | conn_0 | False    | drop table if exists date_table             | success                        | schema1 |
      | conn_0 | False    | create table date_table(id date)            | success                        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-01') | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-11') | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-21') | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-12-31') | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into date_table values('2018-1-8')   | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into date_table values('2017-11-11') | can't find any valid shardingNode | schema1 |
      | conn_0 | True     | insert into date_table values('2018-11-11') | can't find any valid shardingNode | schema1 |

    #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    {"table":"date_table","key":"id"}
    """
     #test: data types in sharding_key
    Then Test the data types supported by the sharding column in "date.sql"

    #clearn all conf
    Given delete the following xml segment
      |file        | parent                                        | child                                             |
      |sharding.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'date_func'}}  |
      |sharding.xml  | {'tag':'schema','kv_map':{'name':'schema1'}}  | {'tag':'shardingTable','kv_map':{'name':'date_table'}}    |
    Then execute admin cmd "reload @@config_all"
