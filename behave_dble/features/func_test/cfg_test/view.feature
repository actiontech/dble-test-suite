# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/5/7 update by quexiuping  2021/6/4
Feature: #view test except sql cover


  @restore_view
  Scenario:  start dble when the view related table does not exist in configuration  from issue:1100 #1
     """
    {'restore_view':{'dble-1':{'schema1':'view_test'}}}
    """
     Then  execute sql in "dble-1" in "user" mode
       | conn   | toClose  | sql                                           | expect  | db      |
       | conn_0 | False    | drop table if exists test                     | success | schema1 |
       | conn_0 | False    | create table test(id int)                     | success | schema1 |
       | conn_0 | False    | drop view if exists schema1.view_test         | success | schema1 |
       | conn_0 | True     | create view view_test as select * from test   | success | schema1 |
     Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
     <schema name="schema1" sqlMaxLimit="100">
        <globalTable name="test1" shardingNode="dn1,dn3" />
    </schema>
    """
     Then execute admin cmd "reload @@config_all"
     Then execute sql in "dble-1" in "user" mode
       | sql                       | expect                                  | db      |
       | select * from view_test   | Table 'schema1.view_test' doesn't exist | schema1 |
     Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
    """
     Then execute admin cmd "reload @@config_all"
     Then execute sql in "dble-1" in "user" mode
       | conn   | toClose  | sql                               | expect    | db      |
       | conn_0 | False    | select * from schema1.view_test   | success   | schema1 |
       | conn_0 | True     | drop view view_test               | success   | schema1 |
      #github :2063
     Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
       """
       <schema name="schema2" sqlMaxLimit="100" shardingNode="dn1">
          <shardingTable name="test1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
          <shardingTable name="test2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
       </schema>
       """
     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
       <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
       """
     Then execute admin cmd "reload @@config"
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                             | expect  | db      |
      | conn_0 | False   | drop table if exists test1                                                      | success | schema2 |
      | conn_0 | False   | create table test1(id int,code varchar(10))                                     | success | schema2 |
      | conn_0 | False   | drop table if exists test2                                                      | success | schema2 |
      | conn_0 | False   | create table test2(id int,code varchar(10))                                     | success | schema2 |
      | conn_0 | False   | create view test_view(id,name) AS select * from test1 union select * from test2 | success | schema2 |
      | conn_0 | False   | drop view schema2.test_view                                                     | success | schema2 |
      | conn_0 | False   | drop table if exists test1                                                      | success | schema2 |
      | conn_0 | True    | drop table if exists test2                                                      | success | schema2 |



  Scenario: for vertical node view: create view in mysql, then after execute reload @@metadata command the view is available in dble #2
     Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
         <singleTable name="sharding_1_t1" shardingNode="dn2" sqlMaxLimit="100"/>
         <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      <schema name="schema2" sqlMaxLimit="100" shardingNode="dn1">
      </schema>

    """
     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                                                  | expect  | db  |
      | conn_0 | False   | drop table if exists test10                                          | success | db1 |
      | conn_0 | False   | create table test10(id int,name varchar(10),age int)                 | success | db1 |
      | conn_0 | False   | insert into test10 values(1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5)     | success | db1 |
      | conn_0 | False   | drop view if exists view_test10                                      | success | db1 |
      | conn_0 | True    | create view view_test10 as select * from test10                      | success | db1 |
      | conn_0 | False   | drop table if exists nosharding                                      | success | db3 |
      | conn_0 | False   | create table nosharding(id int,name varchar(10),age int)             | success | db3 |
      | conn_0 | False   | insert into nosharding values(1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5) | success | db3 |
      | conn_0 | False   | drop view if exists view_nosharding                                  | success | db3 |
      | conn_0 | True    | create view view_nosharding as select * from nosharding              | success | db3 |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                                                 | expect  | db  |
      | conn_0 | False   | drop table if exists sharding_1_t1                                  | success | db1 |
      | conn_0 | False   | create table sharding_1_t1(id int,name varchar(10),age int)         | success | db1 |
      | conn_0 | False   | insert into sharding_1_t1 values(1,1,1),(2,2,2),(3,3,3),(5,5,5)     | success | db1 |
      | conn_0 | False   | drop view if exists view_sharding_1_t1                              | success | db1 |
      | conn_0 | True    | create view view_sharding_1_t1 as select id,name from sharding_1_t1 | success | db1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                            | expect                                                                                                 | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                             | success                                                                                                | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(10),age int)    | success                                                                                                | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1,1),(2,2,2),(3,3,3)        | success                                                                                                | schema1 |
      | conn_0 | False   | show tables                                                    | hasStr{view_nosharding},hasStr{sharding_1_t1},hasnot{('view_sharding_1_t1'),},hasnot{('view_test10'),} | schema1 |
      | conn_0 | False   | show tables                                                    | hasStr{view_test10},hasnot{('view_sharding_1_t1'),},hasnot{('view_nosharding'),}                       | schema2 |
      | conn_0 | False   | show all tables where Table_type='VIEW'                        | hasStr{view_nosharding},hasnot{('view_sharding_1_t1'),},hasnot{('view_test10'),}                       | schema1 |
      | conn_0 | False   | show all tables where Table_type='VIEW'                        | hasStr{view_test10},hasnot{('view_sharding_1_t1'),},hasnot{('view_nosharding'),}                       | schema2 |
      | conn_0 | False   | show full tables where Table_type='VIEW'                       | hasStr{view_test10},hasnot{('view_sharding_1_t1'),},hasnot{('view_nosharding'),}                       | schema2 |
      | conn_0 | False   | show create table schema2.view_test10                          | length{(1)}                                                                                            | schema1 |
      | conn_0 | False   | show create table schema1.view_nosharding                      | length{(1)}                                                                                            | schema1 |
      | conn_0 | False   | show create table view_sharding_1_t1                           | Table 'db3.view_sharding_1_t1' doesn't exist                                                           | schema1 |
      | conn_0 | False   | select * from schema2.view_test10                              | length{(5)}                                                                                            | schema1 |
      | conn_0 | False   | select * from view_nosharding                                  | length{(5)}                                                                                            | schema1 |
      | conn_0 | False   | select * from view_sharding_1_t1                               | Table 'db3.view_sharding_1_t1' doesn't exist                                                           | schema1 |
      | conn_0 | False   | select * from schema2.view_test10 join schema1.view_nosharding | table view_test10 doesn't exist!You should create it OR reload metadata                                | schema1 |
      | conn_0 | False   | select * from schema2.view_test10 join sharding_4_t1           | table view_test10 doesn't exist!You should create it OR reload metadata                                | schema1 |
      | conn_0 | True    | select * from view_nosharding join sharding_4_t1               | table view_nosharding doesn't exist!You should create it OR reload metadata                            | schema1 |

    Then execute admin cmd "reload @@metadata"
    #only can manuplate vertical-node-view in dble after reload metadata
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                  | expect                                                 | db      |
      | conn_0 | False   | show tables                                          | hasStr{sharding_1_t1}, hasnot{('view_sharding_1_t1'),} | schema1 |
      | conn_0 | False   | show all tables                                      | hasStr{sharding_1_t1}, hasnot{('view_sharding_1_t1'),} | schema1 |
      | conn_0 | False   | show full tables                                     | hasStr{sharding_1_t1}, hasnot{('view_sharding_1_t1'),} | schema1 |
      | conn_0 | False   | select * from schema2.view_test10 join sharding_1_t1 | length{(20)}                                           | schema1 |
      | conn_0 | False   | select * from schema2.view_test10 join sharding_4_t1 | length{(15)}                                           | schema1 |
       #vertical-node-view can drop in dble
      | conn_0 | False   | drop view schema2.view_test10                        | success                                                | schema1 |
      | conn_0 | False   | drop table schema2.test10                            | success                                                | schema1 |
       # none-vertical-node-view can't drop in dble
      | conn_0 | False   | drop view view_nosharding                            | Unknown view 'view_nosharding'                         | schema1 |
      | conn_0 | True    | drop view view_sharding_1_t1                         | Unknown view 'view_sharding_1_t1'                      | schema1 |
       # none-vertical-node-table can drop in dble
      | conn_0 | True    | drop table nosharding                                | success                                                | schema1 |
      | conn_0 | True    | drop table sharding_1_t1                             | success                                                | schema1 |



  Scenario: create some view ,drop view in dble from DBLE0REQ-1163  #3

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn1" />
      <schema name="schema2" sqlMaxLimit="100" shardingNode="dn2" />
      <schema name="schema3" sqlMaxLimit="100" shardingNode="dn3" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_0 | False   | drop view if exists view1,view2,view3               | success | schema1 |
      | conn_0 | False   | drop table if exists test1                          | success | schema1 |
      | conn_0 | False   | drop table if exists test2                          | success | schema1 |
      | conn_0 | False   | drop table if exists test3                          | success | schema1 |
      | conn_0 | False   | create table test1 (id int)                         | success | schema1 |
      | conn_0 | False   | create table test2 (id int)                         | success | schema1 |
      | conn_0 | False   | create table test3 (id int)                         | success | schema1 |
      | conn_0 | False   | create view view1 as select * from test1            | success | schema1 |
      | conn_0 | False   | create view view2 as select * from test1            | success | schema1 |
      | conn_0 | False   | create view view3 as select * from test1            | success | schema1 |
      | conn_0 | False   | drop view view1,view2,view3                         | success | schema1 |

      | conn_0 | False   | create view view1 as select * from test1            | success | schema1 |
      | conn_0 | False   | create view view2 as select * from test2            | success | schema1 |
      | conn_0 | False   | create view view3 as select * from test3            | success | schema1 |
      | conn_0 | False   | drop view schema1.view1,view2,view3                 | success | schema1 |

      | conn_0 | False   | drop table if exists test1                          | success | schema1 |
      | conn_0 | False   | drop table if exists test2                          | success | schema1 |
      | conn_0 | False   | drop table if exists test3                          | success | schema1 |
      | conn_0 | False   | drop table if exists schema1.test1                  | success | schema1 |
      | conn_0 | False   | drop table if exists schema2.test2                  | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.test3                  | success | schema1 |

      | conn_0 | False   | drop view if exists schema1.view1,schema2.view2,schema3.view3 | success | schema1 |
      | conn_0 | False   | create table schema1.test1 (id int)                           | success | schema1 |
      | conn_0 | False   | create table schema2.test2 (id int)                           | success | schema1 |
      | conn_0 | False   | create table schema3.test3 (id int)                           | success | schema1 |
      | conn_1 | true    | create view view1 as select * from schema1.test1              | success | schema1 |
      | conn_2 | true    | create view view2 as select * from schema2.test2              | success | schema2 |
      | conn_3 | true    | create view view3 as select * from schema3.test3              | success | schema3 |
      | conn_0 | False   | drop view schema1.view1,schema2.view2,schema3.view3           | success | schema1 |

      | conn_0 | False   | create view view1 as select * from schema1.test1    | success              | schema1 |
      | conn_0 | False   | drop view schema1.view1,schema2.view2               | Unknown view 'view2' | schema1 |
      | conn_0 | False   | drop view schema1.view1                             | success              | schema1 |

      | conn_0 | False   | drop table if exists schema1.test1              | success | schema1 |
      | conn_0 | False   | drop table if exists schema2.test2              | success | schema1 |
      | conn_0 | true    | drop table if exists schema3.test3              | success | schema1 |