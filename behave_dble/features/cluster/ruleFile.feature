# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by mayingle at 2020/09/08

Feature: adding ruleFile way which is different from mapFile (ZK cluster mode)

  Scenario: Enum sharding with ruleFile way which is different from mapFile #1
    #test: type:integer not default node
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <function class="enum" name="enum_func">
          <property name="ruleFile">enum.txt</property>
          <property name="defaultNode">-1</property>
          <property name="type">0</property>
      </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="enum_table" shardingNode="dn1,dn2,dn3,dn4" function="enum_func" shardingColumn="id" />
    """
    When replace new conf file "enum.txt" on "dble-1"
    """
    0=0
    aaa=0
    1=1
    bbb=1
    2=2
    3=3
    """
    When replace new conf file "enum.txt" on "dble-2"
    """
    0=0
    aaa=0
    1=1
    bbb=1
    2=2
    3=3
    """
    When replace new conf file "enum.txt" on "dble-3"
    """
    0=0
    aaa=0
    1=1
    bbb=1
    2=2
    3=3
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                   | expect                               | db      |
      | conn_0 | False    | drop table if exists enum_table       | success                              | schema1 |
      | conn_0 | False    | create table enum_table(id int)       | success                              | schema1 |
      | conn_0 | False    | insert into enum_table values (null)  | can't find any valid shardingNode       | schema1 |
      | conn_0 | False    | insert into enum_table values (0)     | dest_node:mysql-master1              | schema1 |
      | conn_0 | False    | insert into enum_table values (1)     | dest_node:mysql-master2              | schema1 |
      | conn_0 | False    | insert into enum_table values (2)     | dest_node:mysql-master1              | schema1 |
      | conn_0 | False    | insert into enum_table values (3)     | dest_node:mysql-master2              | schema1 |
      | conn_0 | False    | insert into enum_table values (-1)    | can't find any valid shardingNode       | schema1 |
      | conn_0 | False    | insert into enum_table values (4)     | can't find any valid shardingNode       | schema1 |
      | conn_0 | False    | insert into enum_table values (5)     | can't find any valid shardingNode       | schema1 |
      | conn_0 | True     | insert into enum_table values ('aaa') | Please check if the format satisfied | schema1 |

    # check zk that the result is right
    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "enum.txt" on dble-1


    #test: type:string default node
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="Enum" name="enum_func">
            <property name="ruleFile">enum.txt</property>
            <property name="type">1</property>
            <property name="defaultNode">3</property>
        </function>
    """
    When replace new conf file "enum.txt" on "dble-1"
    """
    aaa=0
    bbb=1
    ccc=2
    ddd=3
    1=1
    2=2
    3=3
    """
    When replace new conf file "enum.txt" on "dble-2"
    """
    aaa=0
    bbb=1
    ccc=2
    ddd=3
    1=1
    2=2
    3=3
    """
    When replace new conf file "enum.txt" on "dble-3"
    """
    aaa=0
    bbb=1
    ccc=2
    ddd=3
    1=1
    2=2
    3=3
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                      | expect                  | db      |
      | conn_0 | False    | drop table if exists enum_table          | success                 | schema1 |
      | conn_0 | False    | create table enum_table(id varchar(10))  | success                 | schema1 |
      | conn_0 | False    | insert into enum_table values(null)      | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into enum_table values(0)         | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into enum_table values(1)         | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into enum_table values(2)         | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into enum_table values(3)         | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into enum_table values('aaa')     | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into enum_table values('bbb')     | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into enum_table values('ccc')     | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into enum_table values('ddd')     | dest_node:mysql-master2 | schema1 |
      | conn_0 | True     | insert into enum_table values('eee')     | dest_node:mysql-master2 | schema1 |

    #test: data types in sharding_key
    Then Test the data types supported by the sharding column in "enum.sql"
    #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    {"table":"enum_table","key":"id"}
    """

    # check zk that the result is right
    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "enum.txt" on dble-1

    #clearn all conf
    Given delete file "/opt/dble/conf/enum.txt" on "dble-1"
    Given delete file "/opt/dble/conf/enum.txt" on "dble-2"
    Given delete file "/opt/dble/conf/enum.txt" on "dble-3"
    Given delete the following xml segment
      |file        | parent                                        | child                                  |
      |sharding.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'enum_func'}}  |
      |sharding.xml  | {'tag':'schema','kv_map':{'name':'schema1'}}  | {'tag':'shardingTable','kv_map':{'name':'enum_table'}}    |
    Then execute admin cmd "reload @@config_all"





  Scenario: Numberrange sharding with ruleFile way (ZK cluster mode) #2
    #test: set defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="numberrange" name="numberrange_func">
            <property name="ruleFile">partition.txt</property>
            <property name="defaultNode">3</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="numberrange_table" shardingNode="dn1,dn2,dn3,dn4" function="numberrange_func" shardingColumn="id" />
    """
    When replace new conf file "partition.txt" on "dble-1"
    """
    0-255=0
    256-500=1
    501-755=2
    756-1000=3
    """
    When replace new conf file "partition.txt" on "dble-2"
    """
    0-255=0
    256-500=1
    501-755=2
    756-1000=3
    """
    When replace new conf file "partition.txt" on "dble-3"
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
     # check zk that the result is right
    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "partition.txt" on dble-1


    #test: not defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="numberrange" name="numberrange_func">
            <property name="ruleFile">partition.txt</property>
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

    # check zk that the result is right
    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "partition.txt" on dble-1

    #clearn all conf
    Given delete file "/opt/dble/conf/partition.txt" on "dble-1"
    Given delete file "/opt/dble/conf/partition.txt" on "dble-2"
    Given delete file "/opt/dble/conf/partition.txt" on "dble-3"
    Given delete the following xml segment
      |file        | parent                                        | child                                  |
      |sharding.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'numberrange_func'}}  |
      |sharding.xml  | {'tag':'schema','kv_map':{'name':'schema1'}}   | {'tag':'shardingTable','kv_map':{'name':'numberrange_table'}}    |
    Then execute admin cmd "reload @@config_all"




  Scenario: PatternRange sharding with ruleFile way (ZK cluster mode) #3
    #test: set defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="PatternRange" name="patternrange_func">
            <property name="ruleFile">patternrange.txt</property>
            <property name="patternValue">1000</property>
            <property name="defaultNode">3</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="patternrange_table" shardingNode="dn1,dn2,dn3,dn4" function="patternrange_func" shardingColumn="id"/>
    """
    When replace new conf file "patternrange.txt" on "dble-1"
    """
    0-255=0
    256-500=1
    501-755=2
    756-1000=3
    """
    When replace new conf file "patternrange.txt" on "dble-2"
    """
    0-255=0
    256-500=1
    501-755=2
    756-1000=3
    """
    When replace new conf file "patternrange.txt" on "dble-3"
    """
    0-255=0
    256-500=1
    501-755=2
    756-1000=3
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                          | expect                  | db      |
      | conn_0 | False    | drop table if exists patternrange_table      | success                 | schema1 |
      | conn_0 | False    | create table patternrange_table(id int)      | success                 | schema1 |
      | conn_0 | False    | insert into patternrange_table values(null)  | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into patternrange_table values(-1)    | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into patternrange_table values(0)     | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into patternrange_table values(255)   | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into patternrange_table values(256)   | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into patternrange_table values(500)   | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into patternrange_table values(501)   | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into patternrange_table values(755)   | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into patternrange_table values(756)   | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into patternrange_table values(1000)  | dest_node:mysql-master1 | schema1 |
      | conn_0 | True     | insert into patternrange_table values(1001)  | dest_node:mysql-master1 | schema1 |

        #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    {"table":"patternrange_table","key":"id"}
    """

    # check zk that the result is right
    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "patternrange.txt" on dble-1


    #test: not defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="PatternRange" name="patternrange_func">
            <property name="ruleFile">patternrange.txt</property>
            <property name="patternValue">1000</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                          | expect                         | db      |
      | conn_0 | False    | drop table if exists patternrange_table      | success                        | schema1 |
      | conn_0 | False    | create table patternrange_table(id int)      | success                        | schema1 |
      | conn_0 | False    | insert into patternrange_table values(0)     | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into patternrange_table values(255)   | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into patternrange_table values(256)   | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into patternrange_table values(500)   | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into patternrange_table values(501)   | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into patternrange_table values(755)   | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into patternrange_table values(756)   | dest_node:mysql-master2        | schema1 |
      | conn_0 | False    | insert into patternrange_table values(1000)  | dest_node:mysql-master1        | schema1 |
      | conn_0 | True     | insert into patternrange_table values(1001)  | dest_node:mysql-master1        | schema1 |
      | conn_0 | False    | insert into patternrange_table values(null)  | can't find any valid shardingNode | schema1 |
      | conn_0 | True     | insert into patternrange_table values(-1)    | can't find any valid shardingNode | schema1 |
      | conn_0 | True     | insert into patternrange_table values(-2)    | can't find any valid shardingNode | schema1 |

    #test: data types in sharding_key
    Then Test the data types supported by the sharding column in "range.sql"

    # check zk that the result is right
    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "patternrange.txt" on dble-1

    #clearn all conf
    Given delete file "/opt/dble/conf/patternrange.txt" on "dble-1"
    Given delete file "/opt/dble/conf/patternrange.txt" on "dble-2"
    Given delete file "/opt/dble/conf/patternrange.txt" on "dble-3"
    Given delete the following xml segment
      |file        | parent                                        | child                                  |
      |sharding.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'patternrange_func'}}  |
      |sharding.xml  | {'tag':'schema','kv_map':{'name':'schema1'}}  | {'tag':'shardingTable','kv_map':{'name':'patternrange_table'}}    |
    Then execute admin cmd "reload @@config_all"