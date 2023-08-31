# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2023/04/25
# DBLE0REQ-2196
#1、被操作的表格是全局表或者分片表，其余所有表格都是全局表，并且分片范围都能覆盖被操作的表格（需注意“分片范围”指的是配置文件里面配的表分片范围，而不是经过 where 二次筛选后的范围。)
#2、被操作的表格是单节点表，where条件中的所有表格都有条件能路由到同一个节点
@skip #未合并
Feature: test special supported multi_table update

  Background: prepare for special supported multi_table update
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>

        <shardingTable name="shard_12" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <shardingTable name="shard_34" shardingNode="dn3,dn4" function="hash-two" shardingColumn="id"/>

        <globalTable name="global_12" shardingNode="dn1,dn2"/>
        <globalTable name="global_12_2" shardingNode="dn1,dn2"/>
        <globalTable name="global_34" shardingNode="dn3,dn4"/>
        <globalTable name="global_23" shardingNode="dn2,dn3"/>
        <globalTable name="global_1234" shardingNode="dn1,dn2,dn3,dn4"/>
        <globalTable name="global_36" shardingNode="dn3,dn6"/>
        <globalTable name="global_56" shardingNode="dn5,dn6"/>

        <singleTable name="sing_1" shardingNode="dn1" />
        <singleTable name="sing_1_2" shardingNode="dn1" />
        <singleTable name="sing_3" shardingNode="dn3" />
      </schema>

      <schema shardingNode="dn3" name="schema2" sqlMaxLimit="100">
      </schema>

      <schema shardingNode="dn1" name="schema3" sqlMaxLimit="100">
    	  <shardingTable name="sharding_2_t3" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <shardingTable name="sharding_4_t3" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>

      <schema shardingNode="dn4" name="schema4" sqlMaxLimit="100">
      </schema>

      <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
      <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
      <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
      <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3,schema4" />
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1; drop table if exists sharding_4_t1             | success | schema1 |
      | conn_0 | False   | drop table if exists shard_12; drop table if exists shard_34                       | success | schema1 |
      | conn_0 | False   | drop table if exists global_12; drop table if exists global_12_2                   | success | schema1 |
      | conn_0 | False   | drop table if exists global_23; drop table if exists global_34                     | success | schema1 |
      | conn_0 | False   | drop table if exists global_1234; drop table if exists global_36                   | success | schema1 |
      | conn_0 | False   | drop table if exists global_56                                                     | success | schema1 |
      | conn_0 | False   | drop table if exists sing_1;drop table if exists sing_1_2                          | success | schema1 |
      | conn_0 | False   | drop table if exists sing_3;drop table if exists noshard_5                         | success | schema1 |
      | conn_0 | False   | drop table if exists schema2.vertical_3;drop table if exists schema2.vertical_3_2  | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.sharding_2_t3                                         | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.sharding_4_t3                                         | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.noshard_1;drop table if exists schema3.noshard_1_2    | success | schema1 |
      | conn_0 | False   | drop table if exists schema4.vertical_4                                            | success | schema1 |
      | conn_0 | False   | create table sharding_2_t1 (id int, shard_2_name varchar(20), p_id int)            | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1 (id int, shard_4_name varchar(20), p_id int)            | success | schema1 |
      | conn_0 | False   | create table shard_12 (id int, shard_12_name varchar(20), p_id int)                | success | schema1 |
      | conn_0 | False   | create table shard_34 (id int, shard_34_name varchar(20), p_id int)                | success | schema1 |
      | conn_0 | False   | create table global_12 (id int, global_12_name varchar(20), p_id int)              | success | schema1 |
      | conn_0 | False   | create table global_12_2 (id int, global_12_name varchar(20), p_id int)            | success | schema1 |
      | conn_0 | False   | create table global_23 (id int, global_23_name varchar(20), p_id int)              | success | schema1 |
      | conn_0 | False   | create table global_34 (id int, global_34_name varchar(20), p_id int)              | success | schema1 |
      | conn_0 | False   | create table global_1234 (id int, global_1234_name varchar(20), p_id int)          | success | schema1 |
      | conn_0 | False   | create table global_36 (id int, global_36_name varchar(20), p_id int)              | success | schema1 |
      | conn_0 | False   | create table global_56 (id int, global_56_name varchar(20), p_id int)              | success | schema1 |
      | conn_0 | False   | create table sing_1 (id int, sing_1_name varchar(20), p_id int)                    | success | schema1 |
      | conn_0 | False   | create table sing_1_2 (id int, sing_1_name varchar(20), p_id int)                  | success | schema1 |
      | conn_0 | False   | create table sing_3 (id int, sing_3_name varchar(20), p_id int)                    | success | schema1 |
      | conn_0 | False   | create table noshard_5 (id int, noshard_5_name varchar(20), p_id int)              | success | schema1 |
      | conn_0 | False   | create table schema2.vertical_3 (id int, vertical_3_name varchar(20), p_id int)    | success | schema1 |
      | conn_0 | False   | create table schema2.vertical_3_2 (id int, vertical_3_name varchar(20), p_id int)  | success | schema1 |
      | conn_0 | False   | create table schema3.sharding_2_t3 (id int, shard_2_name varchar(20), p_id int)    | success | schema1 |
      | conn_0 | False   | create table schema3.sharding_4_t3 (id int, shard_4_name varchar(20), p_id int)    | success | schema1 |
      | conn_0 | False   | create table schema3.noshard_1 (id int, noshard_1_name varchar(20), p_id int)      | success | schema1 |
      | conn_0 | False   | create table schema3.noshard_1_2 (id int, noshard_1_name varchar(20), p_id int)    | success | schema1 |
      | conn_0 | False   | create table schema4.vertical_4 (id int, vertical_4_name varchar(20), p_id int)    | success | schema1 |
      | conn_0 | False   | insert into sharding_2_t1 values (1, 'sharding_2_t1_1', 1),(2, 'sharding_2_t1_2', 1),(3, 'sharding_2_t1_3', 1),(4, 'sharding_2_t1_4', 2),(5, 'sharding_2_t1_5', 2),(6, 'sharding_2_t1_6', 2) | success | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values (1, 'sharding_4_t1_1', 1),(2, 'sharding_4_t1_2', 1),(3, 'sharding_4_t1_3', 1),(4, 'sharding_4_t1_4', 2),(5, 'sharding_4_t1_5', 2),(6, 'sharding_4_t1_6', 2) | success | schema1 |
      | conn_0 | False   | insert into global_12 values (1, 'global_12_1', 1),(2, 'global_12_2', 1),(3, 'global_12_3', 1),(4, 'global_12_4', 2),(5, 'global_12_5', 2),(6, 'global_12_6', 2) | success | schema1 |
      | conn_0 | False   | insert into global_12_2 values (1, 'global_12_1', 12),(2, 'global_12_2', 12),(3, 'global_12_3', 12),(4, 'global_12_4', 22),(5, 'global_12_5', 22),(6, 'global_12_6', 22) | success | schema1 |
      | conn_0 | False   | insert into global_1234 values (1, 'global_1234_1', 1),(2, 'global_1234_2', 1),(3, 'global_1234_3', 1),(4, 'global_1234_4', 2),(5, 'global_1234_5', 2),(6, 'global_1234_6', 2) | success | schema1 |
      | conn_0 | False   | insert into global_56 values (1, 'global_56_1', 1),(2, 'global_56_2', 1),(3, 'global_56_3', 1),(4, 'global_56_4', 2),(5, 'global_56_5', 2),(6, 'global_56_6', 2) | success | schema1 |
      | conn_0 | False   | insert into sing_1 values (1, 'sing_1_1', 1),(2, 'sing_1_2', 1),(3, 'sing_1_3', 1),(4, 'sing_1_4', 2),(5, 'sing_1_5', 2),(6, 'sing_1_6', 2) | success | schema1 |
      | conn_0 | False   | insert into sing_1_2 values (1, 'sing_1_1', 1),(2, 'sing_1_2', 1),(3, 'sing_1_3', 1),(4, 'sing_1_4', 2),(5, 'sing_1_5', 2),(6, 'sing_1_6', 2) | success | schema1 |
      | conn_0 | False   | insert into sing_3 values (1, 'sing_3_1', 1),(2, 'sing_3_2', 1),(3, 'sing_3_3', 1),(4, 'sing_3_4', 2),(5, 'sing_3_5', 2),(6, 'sing_3_6', 2) | success | schema1 |
      | conn_0 | False   | insert into noshard_5 values (1, 'noshard_5_1', 1),(2, 'noshard_5_2', 1),(3, 'noshard_5_3', 1),(4, 'noshard_5_4', 2),(5, 'noshard_5_5', 2),(6, 'noshard_5_6', 2) | success | schema1 |
      | conn_0 | False   | insert into shard_12 values (1, 'shard_12_1', 1),(2, 'shard_12_2', 1),(3, 'shard_12_3', 1),(4, 'shard_12_4', 2),(5, 'shard_12_5', 2),(6, 'shard_12_6', 2) | success | schema1 |
      | conn_0 | False   | insert into shard_34 values (1, 'shard_34_1', 1),(2, 'shard_34_2', 1),(3, 'shard_34_3', 1),(4, 'shard_34_4', 2),(5, 'shard_34_5', 2),(6, 'shard_34_6', 2) | success | schema1 |
      | conn_0 | False   | insert into schema2.vertical_3 values (1, 'vertical_3_1', 1),(2, 'vertical_3_2', 1),(3, 'vertical_3_3', 1),(4, 'vertical_3_4', 2),(5, 'vertical_3_5', 2),(6, 'vertical_3_6', 2) | success | schema1 |
      | conn_0 | False   | insert into schema2.vertical_3_2 values (1, 'vertical_3_1', 1),(2, 'vertical_3_2', 1),(3, 'vertical_3_3', 1),(4, 'vertical_3_4', 2),(5, 'vertical_3_5', 2),(6, 'vertical_3_6', 2) | success | schema1 |
      | conn_0 | False   | insert into schema3.sharding_2_t3 values (1, 'sharding_2_t3_1', 1),(2, 'sharding_2_t3_2', 1),(3, 'sharding_2_t3_3', 1),(4, 'sharding_2_t3_4', 2),(5, 'sharding_2_t3_5', 2),(6, 'sharding_2_t3_6', 2) | success | schema1 |
      | conn_0 | False   | insert into schema3.sharding_4_t3 values (1, 'sharding_4_t3_1', 1),(2, 'sharding_4_t3_2', 1),(3, 'sharding_4_t3_3', 1),(4, 'sharding_4_t3_4', 2),(5, 'sharding_4_t3_5', 2),(6, 'sharding_4_t3_6', 2) | success | schema1 |
      | conn_0 | False   | insert into schema3.noshard_1 values (1, 'noshard_1_1', 1),(2, 'noshard_1_2', 1),(3, 'noshard_1_3', 1),(4, 'noshard_1_4', 2),(5, 'noshard_1_5', 2),(6, 'noshard_1_6', 2) | success | schema1 |
      | conn_0 | False   | insert into schema3.noshard_1_2 values (1, 'noshard_1_1', 1),(2, 'noshard_1_2', 1),(3, 'noshard_1_3', 1),(4, 'noshard_1_4', 2),(5, 'noshard_1_5', 2),(6, 'noshard_1_6', 2) | success | schema1 |
      | conn_0 | True    | insert into schema4.vertical_4 values (1, 'vertical_4_1', 1),(2, 'vertical_4_2', 1),(3, 'vertical_4_3', 1),(4, 'vertical_4_4', 2),(5, 'vertical_4_5', 2),(6, 'vertical_4_6', 2) | success | schema1 |

  Scenario: check update set subquery #1
    # case 1: update sharding table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                 | expect                                         | db      |
      # case 1.1: sharding table + global table
      # shardingTable: dn1,dn2 globalTable: dn1,dn2 -> support
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name=(select id-1 from global_12 b where a.id=b.id), p_id=p_id-1                 | success                                        | schema1 |
      | conn_0 | False   | select * from sharding_2_t1 order by id                                                                             | has{((1, '0', 0), (2, '1', 0), (3, '2', 0), (4, '3', 1), (5, '4', 1), (6, '5', 1))} | schema1 |
      # shardingTable: dn1,dn2 globalTable: dn1,dn2,dn3,dn4 -> support
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name=(select p_id from global_1234 b where a.id=b.id) where p_id>0               | success                                        | schema1 |
      | conn_0 | False   | select * from sharding_2_t1 order by id                                                                             | has{((1, '0', 0), (2, '1', 0), (3, '2', 0), (4, '2', 1), (5, '2', 1), (6, '2', 1))} | schema1 |
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name=(select id+1 from global_23 b where a.id=b.id), p_id=p_id+1                 | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name=(select id+1 from global_34 b where a.id=b.id), p_id=p_id+1                 | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_4_t1 a set shard_4_name=(select id+1 from global_12 b where a.id=b.id), p_id=p_id+1                 | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_4_t1 a set shard_4_name=(select id+1 from global_36 b where a.id=b.id), p_id=p_id+1                 | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_4_t1 a set shard_4_name=(select id+1 from global_56 b where a.id=b.id), p_id=p_id+1                 | This `Complex Update Syntax` is not supported! | schema1 |
      # case 1.2: sharding table + sharding table
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name=(select id+1 from shard_12 b where a.id=b.id), p_id=p_id+1                  | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name=(select id+1 from shard_34 b where a.id=b.id), p_id=p_id+1                  | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name=(select id+1 from sharding_4_t1 b where a.id=b.id), p_id=p_id+1             | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_4_t1 a set shard_4_name=(select id+1 from sharding_2_t1 b where a.id=b.id), p_id=p_id+1             | This `Complex Update Syntax` is not supported! | schema1 |
      # case 1.3: sharding table + single table
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name=(select id+1 from sing_1 b where a.id=b.id), p_id=p_id+1                    | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name=(select id+1 from sing_3 b where a.id=b.id), p_id=p_id+1                    | This `Complex Update Syntax` is not supported! | schema1 |
      # case 1.4: sharding table + no sharding table
      | conn_0 | False   | update schema3.sharding_2_t3 a set shard_2_name=(select id+1 from schema3.noshard_1 b where a.id=b.id), p_id=p_id+1 | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name=(select id+1 from noshard_5 b where a.id=b.id), p_id=p_id+1                 | This `Complex Update Syntax` is not supported! | schema1 |
      # case 1.5: sharding table + vertica table
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name=(select id+1 from  schema2.vertical_3 b where a.id=b.id), p_id=p_id+1       | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | True    | update sharding_4_t1 a set shard_4_name=(select id+1 from  schema2.vertical_3 b where a.id=b.id), p_id=p_id+1       | This `Complex Update Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                         | db      |
      | conn_0 | false   | explain update sharding_2_t1 a set shard_2_name=(select id-1 from global_12 b where a.id=b.id), p_id=p_id-1 | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                           |
      | dn1             | BASE SQL | update sharding_2_t1 a set shard_2_name=(select id-1 from global_12 b where a.id=b.id), p_id=p_id-1 |
      | dn2             | BASE SQL | update sharding_2_t1 a set shard_2_name=(select id-1 from global_12 b where a.id=b.id), p_id=p_id-1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                                                                           | db      |
      | conn_0 | false   | explain update sharding_2_t1 a set shard_2_name=(select p_id from global_1234 b where a.id=b.id) where p_id>0 | schema1 |
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                             |
      | dn1             | BASE SQL | update sharding_2_t1 a set shard_2_name=(select p_id from global_1234 b where a.id=b.id) where p_id>0 |
      | dn2             | BASE SQL | update sharding_2_t1 a set shard_2_name=(select p_id from global_1234 b where a.id=b.id) where p_id>0 |

    # case 2: update global table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                             | expect                                         | db      |
      # case 2.1: global table + global table
      # globalTable1: dn1,dn2 globalTable2: dn1,dn2 -> support
      | conn_0 | False   | update global_12 a set global_12_name=(select id-1 from global_12_2 b where a.id=b.id), p_id=p_id-1             | success                                        | schema1 |
      | conn_0 | False   | select * from global_12                                                                                         | has{((1, '0', 0), (2, '1', 0), (3, '2', 0), (4, '3', 1), (5, '4', 1), (6, '5', 1))} | schema1 |
      # globalTable1: dn1,dn2 globalTable2: dn1,dn2,dn3,dn4 -> support
      | conn_0 | False   | update global_12 a set global_12_name=(select p_id from global_1234 b where a.id=b.id) where a.p_id=1           | success                                        | schema1 |
      | conn_0 | False   | select * from global_12                                                                                         | has{((1, '0', 0), (2, '1', 0), (3, '2', 0), (4, '2', 1), (5, '2', 1), (6, '2', 1))} | schema1 |
      | conn_0 | False   | update global_12 a set global_12_name=(select id+1 from global_23 b where a.id=b.id), p_id=p_id+1               | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update global_1234 a set global_1234_name=(select id+1 from global_34 b where a.id=b.id), p_id=p_id+1           | This `Complex Update Syntax` is not supported! | schema1 |
      # case 2.2: global table + sharding table
      | conn_0 | False   | update global_12 a set global_12_name=(select id+1 from sharding_2_t1 b where a.id=b.id), p_id=p_id+1           | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update global_12 a set global_12_name=(select id+1 from sharding_4_t1 b where a.id=b.id), p_id=p_id+1           | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update global_12 a set global_12_name=(select id+1 from shard_34 b where a.id=b.id), p_id=p_id+1                | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update global_1234 a set global_1234_name=(select id+1 from shard_34 b where a.id=b.id), p_id=p_id+1            | This `Complex Update Syntax` is not supported! | schema1 |
      # case 2.3: global table + single table
      | conn_0 | False   | update global_12 a set global_12_name=(select id+1 from sing_1 b where a.id=b.id), p_id=p_id+1                  | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update global_12 a set global_12_name=(select id+1 from sing_3 b where a.id=b.id), p_id=p_id+1                  | This `Complex Update Syntax` is not supported! | schema1 |
      # case 2.4: global table + no sharding table
      | conn_0 | False   | update global_12 a set global_12_name=(select id+1 from schema3.noshard_1 b where a.id=b.id), p_id=p_id+1       | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update global_12 a set global_12_name=(select id+1 from noshard_5 b where a.id=b.id), p_id=p_id+1               | This `Complex Update Syntax` is not supported! | schema1 |
      # case 2.5: global table + vertical table
      | conn_0 | False   | update global_12 a set global_12_name=(select id+1 from schema2.vertical_3 b where a.id=b.id), p_id=p_id+1      | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | True    | update global_1234 a set global_1234_name=(select id+1 from schema2.vertical_3 b where a.id=b.id), p_id=p_id+1  | This `Complex Update Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_3"
      | conn   | toClose | sql                                                                                                         | db      |
      | conn_0 | false   | explain update global_12 a set global_12_name=(select id-1 from global_12_2 b where a.id=b.id), p_id=p_id-1 | schema1 |
    Then check resultset "rs_3" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                           |
      | dn1             | BASE SQL | update global_12 a set global_12_name=(select id-1 from global_12_2 b where a.id=b.id), p_id=p_id-1 |
      | dn2             | BASE SQL | update global_12 a set global_12_name=(select id-1 from global_12_2 b where a.id=b.id), p_id=p_id-1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_4"
      | conn   | toClose | sql                                                                                                           | db      |
      | conn_0 | false   | explain update global_12 a set global_12_name=(select p_id from global_1234 b where a.id=b.id) where a.p_id=1 | schema1 |
    Then check resultset "rs_4" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                             |
      | dn1             | BASE SQL | update global_12 a set global_12_name=(select p_id from global_1234 b where a.id=b.id) where a.p_id=1 |
      | dn2             | BASE SQL | update global_12 a set global_12_name=(select p_id from global_1234 b where a.id=b.id) where a.p_id=1 |

    # case 3: update single table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                   | expect                                         | db      |
      # case 3.1: single table + global table
      # singleTable: dn1 globalTable: dn1,dn2 -> support
      | conn_0 | False   | update sing_1 a set sing_1_name=(select id-1 from global_12 b where a.id=b.id), p_id=p_id-1           | success                                        | schema1 |
      | conn_0 | False   | select * from sing_1                                                                                  | has{ ((1, '0', 0), (2, '1', 0), (3, '2', 0), (4, '3', 1), (5, '4', 1), (6, '5', 1))} | schema1 |
      | conn_0 | False   | update sing_1 a set sing_1_name=(select id+1 from global_34 b where a.id=b.id), p_id=p_id+1           | This `Complex Update Syntax` is not supported! | schema1 |
      # case 3.2: single table + sharding table
      | conn_0 | False   | update sing_1 a set sing_1_name=(select id+1 from shard_34 b where a.id=b.id), p_id=p_id+1            | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sing_1 a set sing_1_name=(select id-1 from shard_12 b where a.id=b.id)                         | This `Complex Update Syntax` is not supported! | schema1 |
      # singleTable: dn1 shardingTable: dn1,dn2 shardingNode=dn1 -> support
      | conn_0 | False   | update sing_1 a set sing_1_name=(select id-1 from shard_12 b where a.id=b.id and b.id=2)              | success                                        | schema1 |
      | conn_0 | False   | select * from sing_1                                                                                  | has{((1, None, 0), (2, '1', 0), (3, None, 0), (4, None, 1), (5, None, 1), (6, None, 1))} | schema1 |
      # case 3.3: single table + single table
      # singleTable1: dn1 singleTable2: dn1 -> support
      | conn_0 | False   | update sing_1 a set sing_1_name=(select id-1 from sing_1_2 b where a.id=b.id), p_id=p_id-1            | success                                        | schema1 |
      | conn_0 | False   | select * from sing_1                                                                                  | has{((1, '0', -1), (2, '1', -1), (3, '2', -1), (4, '3', 0), (5, '4', 0), (6, '5', 0))} | schema1 |
      | conn_0 | False   | update sing_1 a set sing_1_name=(select id+1 from sing_3 b where a.id=b.id), p_id=p_id+1              | This `Complex Update Syntax` is not supported! | schema1 |
      # case 3.4: single table + no sharding table
      # singleTable: dn1 noShardingTable: dn1 -> support
      | conn_0 | False   | update sing_1 a set sing_1_name=(select p_id from schema3.noshard_1 b where a.id=b.id), p_id=p_id-1   | success                                        | schema1 |
      | conn_0 | False   | select * from sing_1                                                                                  | has{((1, '1', -2), (2, '1', -2), (3, '1', -2), (4, '2', -1), (5, '2', -1), (6, '2', -1))} | schema1 |
      | conn_0 | False   | update sing_1 a set sing_1_name=(select id+1 from noshard_5 b where a.id=b.id), p_id=p_id+1           | This `Complex Update Syntax` is not supported! | schema1 |
      # case 3.5: single table + vertical table
      # singleTable: dn3 verticalTable: dn3 -> support
      | conn_0 | False   | update sing_3 a set sing_3_name=(select id-1 from schema2.vertical_3 b where a.id=b.id)               | success                                        | schema1 |
      | conn_0 | False   | select * from sing_3                                                                                  | has{((1, '0', 1), (2, '1', 1), (3, '2', 1), (4, '3', 2), (5, '4', 2), (6, '5', 2))} | schema1 |
      | conn_0 | True    | update sing_1 a set sing_1_name=(select id+1 from schema2.vertical_3 b where a.id=b.id), p_id=p_id+1  | This `Complex Update Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_5"
      | conn   | toClose | sql                                                                                                 | db      |
      | conn_0 | false   | explain update sing_1 a set sing_1_name=(select id-1 from global_12 b where a.id=b.id), p_id=p_id-1 | schema1 |
    Then check resultset "rs_5" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                   |
      | dn1             | BASE SQL | update sing_1 a set sing_1_name=(select id-1 from global_12 b where a.id=b.id), p_id=p_id-1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_6"
      | conn   | toClose | sql                                                                                                | db      |
      | conn_0 | false   | explain update sing_1 a set sing_1_name=(select id-1 from sing_1_2 b where a.id=b.id), p_id=p_id-1 | schema1 |
    Then check resultset "rs_6" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                 |
      | dn1             | BASE SQL | update sing_1 a set sing_1_name=(select id-1 from sing_1_2 b where a.id=b.id), p_id=p_id-1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_7"
      | conn   | toClose | sql                                                                                                | db      |
      | conn_0 | false   | explain update sing_1 a set sing_1_name=(select id-1 from sing_1_2 b where a.id=b.id), p_id=p_id-1 | schema1 |
    Then check resultset "rs_7" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                  |
      | dn1             | BASE SQL | update sing_1 a set sing_1_name=(select id-1 from sing_1_2 b where a.id=b.id), p_id=p_id-1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_8"
      | conn   | toClose | sql                                                                                                         | db      |
      | conn_0 | false   | explain update sing_1 a set sing_1_name=(select p_id from schema3.noshard_1 b where a.id=b.id), p_id=p_id-1 | schema1 |
    Then check resultset "rs_8" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                   |
      | dn1             | BASE SQL | update sing_1 a set sing_1_name=(select p_id from noshard_1 b where a.id=b.id), p_id=p_id-1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_9"
      | conn   | toClose | sql                                                                                             | db      |
      | conn_0 | false   | explain update sing_3 a set sing_3_name=(select id-1 from schema2.vertical_3 b where a.id=b.id) | schema1 |
    Then check resultset "rs_9" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                       |
      | dn3             | BASE SQL | update sing_3 a set sing_3_name=(select id-1 from vertical_3 b where a.id=b.id) |

    # case 4: update no sharding table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                           | expect                                         | db      |
      # case 4.1: no sharding table + global table
      # noShardingTable: dn5   globalTable: dn5,dn6 -> support
      | conn_0 | False   | update noshard_5 a set noshard_5_name=(select id-1 from global_56 b where a.id=b.id), p_id=p_id-1             | success                                        | schema1 |
      | conn_0 | False   | select * from noshard_5                                                                                       | has{((1, '0', 0), (2, '1', 0), (3, '2', 0), (4, '3', 1), (5, '4', 1), (6, '5', 1))} | schema1 |
      | conn_0 | False   | update noshard_5 a set noshard_5_name=(select id+1 from global_12 b where a.id=b.id), p_id=p_id+1             | This `Complex Update Syntax` is not supported! | schema1 |
      # case 4.2: no sharding table + sharding table
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name=(select id+1 from shard_34 b where a.id=b.id), p_id=p_id+1      | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name=(select id+1 from shard_12 b where a.id=b.id)                   | This `Complex Update Syntax` is not supported! | schema1 |
      # noShardingTable: dn1 shardingTable: dn1,dn2 shardingNode=dn1 -> support
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name=(select id-1 from shard_12 b where a.id=b.id and b.id=2)        | success                                   | schema1 |
      | conn_0 | False   | select * from schema3.noshard_1                                                                               | has{((1, None, 1), (2, '1', 1), (3, None, 1), (4, None, 2), (5, None, 2), (6, None, 2))} | schema1 |
      # case 4.3: no sharding table + single table
      # noShardingTable: dn1 singleTable: dn1 -> support
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name=(select p_id from sing_1 b where a.id=b.id) where p_id=1        | success                                        | schema1 |
      | conn_0 | False   | select * from schema3.noshard_1                                                                               | has{((1, '-2', 1), (2, '-2', 1), (3, '-2', 1), (4, None, 2), (5, None, 2), (6, None, 2))} | schema1 |
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name=(select id+2 from sing_3 b where a.id=b.id), p_id=p_id+1   | This `Complex Update Syntax` is not supported! | schema1 |
      # case 4.4: no sharding table + no sharding table
      # noShardingTable1: dn1 noShardingTable2: dn1 -> support
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name=(select noshard_1_name from schema3.noshard_1_2 b where a.id=b.id) | success                                        | schema1 |
      | conn_0 | False   | select * from schema3.noshard_1                                                                                  | has{((1, 'noshard_1_1', 1), (2, 'noshard_1_2', 1), (3, 'noshard_1_3', 1), (4, 'noshard_1_4', 2), (5, 'noshard_1_5', 2), (6, 'noshard_1_6', 2))} | schema1 |
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name=(select id+1 from noshard_5 b where a.id=b.id), p_id=p_id+1 | This `Complex Update Syntax` is not supported! | schema1 |
      # case 4.5: no sharding table + vertical table
      # noShardingTable: dn3 verticalTable: dn3 -> support
      | conn_0 | False   | update schema2.sing_3 a set sing_3_name=(select id-1 from schema2.vertical_3 b where a.id=b.id), p_id=p_id-1  | success                                        | schema1 |
      | conn_0 | True    | select * from schema2.sing_3                                                                                  | has{((1, '0', 0), (2, '1', 0), (3, '2', 0), (4, '3', 1), (5, '4', 1), (6, '5', 1))} | schema1 |
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name=(select id+1 from schema2.vertical_3 b where a.id=b.id)         | This `Complex Update Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_10"
      | conn   | toClose | sql                                                                                                       | db      |
      | conn_0 | false   | explain update noshard_5 a set noshard_5_name=(select id-1 from global_56 b where a.id=b.id), p_id=p_id-1 | schema1 |
    Then check resultset "rs_10" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                         |
      | dn5             | BASE SQL | update noshard_5 a set noshard_5_name=(select id-1 from global_56 b where a.id=b.id), p_id=p_id-1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_11"
      | conn   | toClose | sql                                                                                                            | db      |
      | conn_0 | false   | explain update schema3.noshard_1 a set noshard_1_name=(select id-1 from shard_12 b where a.id=b.id and b.id=2) | schema1 |
    Then check resultset "rs_11" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                      |
      | dn1             | BASE SQL | update noshard_1 a set noshard_1_name=(select id-1 from shard_12 b where a.id=b.id and b.id=2) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_12"
      | conn   | toClose | sql                                                                                                            | db      |
      | conn_0 | false   | explain update schema3.noshard_1 a set noshard_1_name=(select p_id from sing_1 b where a.id=b.id) where p_id=1 | schema1 |
    Then check resultset "rs_12" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                      |
      | dn1             | BASE SQL | update noshard_1 a set noshard_1_name=(select p_id from sing_1 b where a.id=b.id) where p_id=1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_13"
      | conn   | toClose | sql                                                                                                                      | db      |
      | conn_0 | false   | explain update schema3.noshard_1 a set noshard_1_name=(select noshard_1_name from schema3.noshard_1_2 b where a.id=b.id) | schema1 |
    Then check resultset "rs_13" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                        |
      | dn1             | BASE SQL | update noshard_1 a set noshard_1_name=(select noshard_1_name from noshard_1_2 b where a.id=b.id) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_14"
      | conn   | toClose | sql                                                                                                                  | db      |
      | conn_0 | false   | explain update schema2.sing_3 a set sing_3_name=(select id-1 from schema2.vertical_3 b where a.id=b.id), p_id=p_id-1 | schema1 |
    Then check resultset "rs_14" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                    |
      | dn3             | BASE SQL | update sing_3 a set sing_3_name=(select id-1 from vertical_3 b where a.id=b.id), p_id=p_id-1 |
    
    # case 5: update vertical table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                  | expect                                         | db      |
      # case 5.1: vertical table + global table
      # verticalTable: dn3   globalTable: dn1,dn2,dn3,dn4 -> support
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name=(select id-1 from global_1234 b where a.id=b.id), p_id=p_id-1        | success                                        | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                                     | has{((1, '0', 0), (2, '1', 0), (3, '2', 0), (4, '3', 1), (5, '4', 1), (6, '5', 1))} | schema1 |
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name=(select id+1 from global_12 b where a.id=b.id), p_id=p_id+1          | This `Complex Update Syntax` is not supported! | schema1 |
      # case 5.2: vertical table + sharding table
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name=(select id+1 from shard_12 b where a.id=b.id), p_id=p_id+1           | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name=(select shard_34_name from shard_34 b where a.id=b.id)               | This `Complex Update Syntax` is not supported! | schema1 |
      # verticalTable: dn3  shardingTable: dn3,dn4 shardingNode=dn3 -> support
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name=(select shard_34_name from shard_34 b where a.id=b.id and b.id=2)    | success                                        | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                                     | has{((1, None, 0), (2, 'shard_34_2', 0), (3, None, 0), (4, None, 1), (5, None, 1), (6, None, 1))} | schema1 |
      # case 5.3: vertical table + single table
      # verticalTable: dn3  singleTable: dn3 -> support
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name=(select concat(sing_3_name,'abc') from sing_3 b where a.id=b.id) where p_id=0 | success                                 | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                                      | has{((1, '0abc', 0), (2, '1abc', 0), (3, '2abc', 0), (4, None, 1), (5, None, 1), (6, None, 1))} | schema1 |
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name=(select id+1 from sing_1 b where a.id=b.id), p_id=p_id+1   | This `Complex Update Syntax` is not supported! | schema1 |
      # case 5.4: vertical table + no sharding table
      # verticalTable: dn3  noShardingTable: dn3 -> support
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name=(select p_id from schema2.sing_3 b where a.id=b.id) where p_id>0     | success                                        | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                                     | has{((1, '0abc', 0), (2, '1abc', 0), (3, '2abc', 0), (4, '1', 1), (5, '1', 1), (6, '1', 1))} | schema1 |
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name=(select id+1 from schema1.noshard_5 b where a.id=b.id), p_id=p_id+1  | This `Complex Update Syntax` is not supported! | schema1 |
      # case 5.5: vertical table + vertical table
      # verticalTable1: dn3  verticalTable2: dn3 -> support
      | conn_0 | True    | update schema2.vertical_3 a set vertical_3_name=(select p_id from schema2.vertical_3_2 b where a.id=b.id), p_id=(select id from schema2.vertical_3_2 c where a.id=c.id) | success | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                                     | has{((1, '1', 1), (2, '1', 2), (3, '1', 3), (4, '2', 4), (5, '2', 5), (6, '2', 6))} | schema1 |
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name=(select id+1 from schema4.vertical_4 b where a.id=b.id), p_id=p_id+1 | This `Complex Update Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_15"
      | conn   | toClose | sql                                                                                                                   | db      |
      | conn_0 | false   | explain update schema2.vertical_3 a set vertical_3_name=(select id-1 from global_1234 b where a.id=b.id), p_id=p_id-1 | schema1 |
    Then check resultset "rs_15" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                             |
      | dn3             | BASE SQL | update vertical_3 a set vertical_3_name=(select id-1 from global_1234 b where a.id=b.id), p_id=p_id-1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_16"
      | conn   | toClose | sql                                                                                                                                   | db      |
      | conn_0 | false   | explain update schema2.vertical_3 a set vertical_3_name=(select concat(sing_3_name,'abc') from sing_3 b where a.id=b.id) where p_id=0 | schema1 |
    Then check resultset "rs_16" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                             |
      | dn3             | BASE SQL | update vertical_3 a set vertical_3_name=(select concat(sing_3_name,'abc') from sing_3 b where a.id=b.id) where p_id=0 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_17"
      | conn   | toClose | sql                                                                                                                      | db      |
      | conn_0 | false   | explain update schema2.vertical_3 a set vertical_3_name=(select p_id from schema2.sing_3 b where a.id=b.id) where p_id>0 | schema1 |
    Then check resultset "rs_17" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                        |
      | dn3             | BASE SQL | update vertical_3 a set vertical_3_name=(select p_id from sing_3 b where a.id=b.id) where p_id>0 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_18"
      | conn   | toClose | sql                                                                                                                      | db      |
      | conn_0 | false   | explain update schema2.vertical_3 a set vertical_3_name=(select p_id from schema2.vertical_3_2 b where a.id=b.id), p_id=(select id from schema2.vertical_3_2 c where a.id=c.id) | schema1 |
    Then check resultset "rs_18" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                                                       |
      | dn3             | BASE SQL | update vertical_3 a set vertical_3_name=(select p_id from vertical_3_2 b where a.id=b.id), p_id=(select id from vertical_3_2 c where a.id=c.id) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_19"
      | conn   | toClose | sql                                                                                                                       | db      |
      | conn_0 | true    | explain update schema2.vertical_3 a set vertical_3_name=(select shard_34_name from shard_34 b where a.id=b.id and b.id=2) | schema1 |
    Then check resultset "rs_19" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                 |
      | dn3             | BASE SQL | update vertical_3 a set vertical_3_name=(select shard_34_name from shard_34 b where a.id=b.id and b.id=2) |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1; drop table if exists sharding_4_t1             | success | schema1 |
      | conn_0 | False   | drop table if exists shard_12; drop table if exists shard_34                       | success | schema1 |
      | conn_0 | False   | drop table if exists global_12; drop table if exists global_12_2                   | success | schema1 |
      | conn_0 | False   | drop table if exists global_23; drop table if exists global_34                     | success | schema1 |
      | conn_0 | False   | drop table if exists global_1234; drop table if exists global_36                   | success | schema1 |
      | conn_0 | False   | drop table if exists global_56                                                     | success | schema1 |
      | conn_0 | False   | drop table if exists sing_1;drop table if exists sing_1_2                          | success | schema1 |
      | conn_0 | False   | drop table if exists sing_3;drop table if exists noshard_5                         | success | schema1 |
      | conn_0 | False   | drop table if exists schema2.vertical_3;drop table if exists schema2.vertical_3_2  | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.sharding_2_t3                                         | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.sharding_4_t3                                         | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.noshard_1;drop table if exists schema3.noshard_1_2    | success | schema1 |
      | conn_0 | False   | drop table if exists schema4.vertical_4                                            | success | schema1 |

  Scenario: check update where subquery #2
    # case 1: update sharding table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                      | expect                                         | db      |
      # case 1.1: sharding table + global table
      # shardingTable: dn1,dn2 globalTable: dn1,dn2 -> support
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name='test1' where a.p_id=(select p_id from global_12 b where a.id=b.id)              | success                                        | schema1 |
      | conn_0 | False   | select * from sharding_2_t1 order by id                                                                                  | has{((1, 'test1', 1), (2, 'test1', 1), (3, 'test1', 1), (4, 'test1', 2), (5, 'test1', 2), (6, 'test1', 2))} | schema1 |
      # shardingTable: dn1,dn2 globalTable: dn1,dn2,dn3,dn4 -> support
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name='test2' where a.p_id=(select id from global_1234 b where a.id=b.id)              | success                                        | schema1 |
      | conn_0 | False   | select * from sharding_2_t1 order by id                                                                                  | has{((1, 'test2', 1), (2, 'test1', 1), (3, 'test1', 1), (4, 'test1', 2), (5, 'test1', 2), (6, 'test1', 2))} | schema1 |
      | conn_0 | False   | update sharding_2_t1 a set p_id =1 where shard_2_name= (select id from global_23 b where a.id=b.id)                      | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name='test' where a.p_id=(select p_id from global_34 b where a.id=b.id)               | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_4_t1 a set shard_4_name='test' where p_id=(select p_id from global_12 b where a.id=b.id)                 | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_4_t1 a set shard_4_name='test' where p_id=(select p_id from global_36 b where a.id=b.id)                 | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_4_t1 a set shard_4_name='test' where p_id=(select p_id from global_56 b where a.id=b.id)                 | This `Complex Update Syntax` is not supported! | schema1 |
      # case 1.2: sharding table + sharding table
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name='test' where p_id=(select p_id from shard_12 b where a.id=b.id)                  | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name='test' where p_id=(select p_id from shard_34 b where a.id=b.id)                  | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name='test' where p_id=(select p_id from sharding_4_t1 b where a.id=b.id)             | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_4_t1 a set shard_4_name='test' where p_id=(select p_id from sharding_2_t1 b where a.id=b.id)             | This `Complex Update Syntax` is not supported! | schema1 |
      # case 1.3: sharding table + single table
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name='test' where p_id=(select p_id from sing_1 b where a.id=b.id)                    | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name='test' where p_id=(select p_id from sing_3 b where a.id=b.id)                    | This `Complex Update Syntax` is not supported! | schema1 |
      # case 1.4: sharding table + no sharding table
      | conn_0 | False   | update schema3.sharding_2_t3 a set shard_2_name='test' where p_id=(select p_id from schema3.noshard_1 b where a.id=b.id) | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name='test' where p_id=(select p_id from noshard_5 b where a.id=b.id)                 | This `Complex Update Syntax` is not supported! | schema1 |
      # case 1.5: sharding table + vertica table
      | conn_0 | False   | update sharding_2_t1 a set shard_2_name='test' where p_id=(select p_id from schema2.vertical_3 b where a.id=b.id)        | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | True    | update sharding_4_t1 a set shard_4_name='test' where p_id=(select p_id from schema2.vertical_3 b where a.id=b.id)        | This `Complex Update Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                  | db      |
      | conn_0 | false   | explain update sharding_2_t1 a set shard_2_name='test1' where a.p_id=(select p_id from global_12 b where a.id=b.id)  | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                   |
      | dn1             | BASE SQL | update sharding_2_t1 a set shard_2_name='test1' where a.p_id=(select p_id from global_12 b where a.id=b.id) |
      | dn2             | BASE SQL | update sharding_2_t1 a set shard_2_name='test1' where a.p_id=(select p_id from global_12 b where a.id=b.id) |
      
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                                                                                 | db      |
      | conn_0 | True    | explain update sharding_2_t1 a set shard_2_name='test2' where a.p_id=(select id from global_1234 b where a.id=b.id) | schema1 |
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                   |
      | dn1             | BASE SQL | update sharding_2_t1 a set shard_2_name='test2' where a.p_id=(select id from global_1234 b where a.id=b.id) |
      | dn2             | BASE SQL | update sharding_2_t1 a set shard_2_name='test2' where a.p_id=(select id from global_1234 b where a.id=b.id) |

    # case 2: update global table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                 | expect                                         | db      |
      # case 2.1: global table + global table
      # globalTable1: dn1,dn2 globalTable2: dn1,dn2 -> support
      | conn_0 | False   | update global_12 a set global_12_name='test' where p_id=(select p_id from global_12_2 b where a.id=b.id)            | success                                        | schema1 |
      | conn_0 | False   | select * from global_12                                                                                             | has{((1, 'global_12_1', 1), (2, 'global_12_2', 1), (3, 'global_12_3', 1), (4, 'global_12_4', 2), (5, 'global_12_5', 2), (6, 'global_12_6', 2))} | schema1 |
      # globalTable1: dn1,dn2 globalTable2: dn1,dn2,dn3,dn4 -> support
      | conn_0 | False   | update global_12 a set global_12_name='test' where p_id=(select id from global_1234 b where a.id=b.id)              | success                                        | schema1 |
      | conn_0 | False   | select * from global_12                                                                                             | has{((1, 'test', 1), (2, 'global_12_2', 1), (3, 'global_12_3', 1), (4, 'global_12_4', 2), (5, 'global_12_5', 2), (6, 'global_12_6', 2))} | schema1 |
      | conn_0 | False   | update global_12 a set global_12_name='test' where p_id=(select p_id from global_23 b where a.id=b.id)              | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update global_1234 a set global_1234_name='test' where p_id=(select p_id from global_34 b where a.id=b.id)          | This `Complex Update Syntax` is not supported! | schema1 |
      # case 2.2: global table + sharding table
      | conn_0 | False   | update global_12 a set global_12_name='test' where p_id=(select p_id from sharding_2_t1 b where a.id=b.id)          | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update global_12 a set global_12_name='test' where p_id=(select p_id from sharding_4_t1 b where a.id=b.id)          | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update global_12 a set global_12_name='test' where p_id=(select p_id from shard_34 b where a.id=b.id)               | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update global_1234 a set global_1234_name='test' where p_id=(select p_id from shard_34 b where a.id=b.id)           | This `Complex Update Syntax` is not supported! | schema1 |
      # case 2.3: global table + single table
      | conn_0 | False   | update global_12 a set global_12_name='test' where p_id=(select p_id from sing_1 b where a.id=b.id)                 | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update global_12 a set global_12_name='test' where p_id=(select p_id from sing_3 b where a.id=b.id)                 | This `Complex Update Syntax` is not supported! | schema1 |
      # case 2.4: global table + no sharding table
      | conn_0 | False   | update global_12 a set global_12_name='test' where p_id=(select p_id from schema3.noshard_1 b where a.id=b.id)      | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update global_12 a set global_12_name='test' where p_id=(select p_id from noshard_5 b where a.id=b.id)              | This `Complex Update Syntax` is not supported! | schema1 |
      # case 2.5: global table + vertical table
      | conn_0 | False   | update global_12 a set global_12_name='test' where p_id=(select p_id from schema2.vertical_3 b where a.id=b.id)     | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | True    | update global_1234 a set global_1234_name='test' where p_id=(select p_id from schema2.vertical_3 b where a.id=b.id) | This `Complex Update Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_3"
      | conn   | toClose | sql                                                                                                               | db      |
      | conn_0 | false   | explain update global_12 a set global_12_name='test' where p_id=(select p_id from global_12_2 b where a.id=b.id)  | schema1 |
    Then check resultset "rs_3" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                |
      | dn1             | BASE SQL | update global_12 a set global_12_name='test' where p_id=(select p_id from global_12_2 b where a.id=b.id) |
      | dn2             | BASE SQL | update global_12 a set global_12_name='test' where p_id=(select p_id from global_12_2 b where a.id=b.id) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_4"
      | conn   | toClose | sql                                                                                                               | db      |
      | conn_0 | false   | explain update global_12 a set global_12_name='test' where p_id=(select p_id from global_12_2 b where a.id=b.id)  | schema1 |
    Then check resultset "rs_4" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                |
      | dn1             | BASE SQL | update global_12 a set global_12_name='test' where p_id=(select p_id from global_12_2 b where a.id=b.id) |
      | dn2             | BASE SQL | update global_12 a set global_12_name='test' where p_id=(select p_id from global_12_2 b where a.id=b.id) |

    # case 3: update single table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                        | expect                                         | db      |
      # case 3.1: single table + global table
      # singleTable: dn1 globalTable: dn1,dn2 -> support
      | conn_0 | False   | update sing_1 a set sing_1_name='test',p_id=p_id-1 where p_id=(select p_id from global_12 b where a.id=b.id) | success                                      | schema1 |
      | conn_0 | False   | select * from sing_1                                                                                       | has{((1, 'test', 0), (2, 'test', 0), (3, 'test', 0), (4, 'test',1), (5, 'test', 1), (6, 'test', 1))} | schema1 |
      | conn_0 | False   | update sing_1 a set sing_1_name='test' where p_id=(select p_id from global_34 b where a.id=b.id)           | This `Complex Update Syntax` is not supported! | schema1 |
      # case 3.2: single table + sharding table
      | conn_0 | False   | update sing_1 a set sing_1_name='test' where p_id=(select p_id from shard_34 b where a.id=b.id)            | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update sing_1 a set sing_1_name='test' where p_id=(select p_id from shard_12 b where a.id=b.id)            | This `Complex Update Syntax` is not supported! | schema1 |
      # singleTable: dn1 shardingTable: dn1,dn2 shardingNode=dn1 -> support
      | conn_0 | False   | update sing_1 a set sing_1_name='aaa'  where p_id<(select p_id from shard_12 b where a.id=b.id and b.id=6) | success                                        | schema1 |
      | conn_0 | False   | select * from sing_1                                                                                       | has{((1, 'test', 0), (2, 'test', 0), (3, 'test', 0), (4, 'test', 1), (5, 'test', 1), (6, 'aaa', 1))} | schema1 |
      # case 3.3: single table + single table
      # singleTable1: dn1 singleTable2: dn1 -> support
      | conn_0 | False   | update sing_1 a set sing_1_name='bbb' where p_id<(select p_id from sing_1_2 b where a.id=b.id)             | success                                        | schema1 |
      | conn_0 | False   | select * from sing_1                                                                                       | has{((1, 'bbb', 0), (2, 'bbb', 0), (3, 'bbb', 0), (4, 'bbb', 1), (5, 'bbb', 1), (6, 'bbb', 1))} | schema1 |
      | conn_0 | False   | update sing_1 a set sing_1_name='test' where p_id=(select p_id from sing_3 b where a.id=b.id)              | This `Complex Update Syntax` is not supported! | schema1 |
      # case 3.4: single table + no sharding table
      # singleTable: dn1 noShardingTable: dn1 -> support
      | conn_0 | False   | update sing_1 a set sing_1_name='test' where id=(select p_id from schema3.noshard_1 b where a.id=b.id)     | success                                        | schema1 |
      | conn_0 | False   | select * from sing_1                                                                                       | has{((1, 'test', 0), (2, 'bbb', 0), (3, 'bbb', 0), (4, 'bbb', 1), (5, 'bbb', 1), (6, 'bbb', 1))} | schema1 |
      | conn_0 | False   | update sing_1 a set sing_1_name='test' where p_id=(select p_id from noshard_5 b where a.id=b.id)           | This `Complex Update Syntax` is not supported! | schema1 |
      # case 3.5: single table + vertical table
      # singleTable: dn3 verticalTable: dn3 -> support
      | conn_0 | False   | update sing_3 a set sing_3_name='ccc' where p_id=(select p_id from schema2.vertical_3 b where a.id=b.id)   | success                                        | schema1 |
      | conn_0 | False   | select * from sing_3                                                                                       | has{((1, 'ccc', 1), (2, 'ccc', 1), (3, 'ccc', 1), (4, 'ccc', 2), (5, 'ccc', 2), (6, 'ccc', 2))} | schema1 |
      | conn_0 | True    | update sing_1 a set sing_1_name='test' where p_id=(select p_id from schema2.vertical_3 b where a.id=b.id)  | This `Complex Update Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_5"
      | conn   | toClose | sql                                                                                                                   | db      |
      | conn_0 | false   | explain update sing_1 a set sing_1_name='test',p_id=p_id-1 where p_id=(select p_id from global_12 b where a.id=b.id)  | schema1 |
    Then check resultset "rs_5" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                     |
      | dn1             | BASE SQL |  update sing_1 a set sing_1_name='test',p_id=p_id-1 where p_id=(select p_id from global_12 b where a.id=b.id) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_6"
      | conn   | toClose | sql                                                                                                                | db      |
      | conn_0 | false   | explain update sing_1 a set sing_1_name='aaa' where p_id<(select p_id from shard_12 b where a.id=b.id and b.id=6)  | schema1 |
    Then check resultset "rs_6" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                 |
      | dn1             | BASE SQL | update sing_1 a set sing_1_name='aaa' where p_id<(select p_id from shard_12 b where a.id=b.id and b.id=6) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_7"
      | conn   | toClose | sql                                                                                                     | db      |
      | conn_0 | false   | explain update sing_1 a set sing_1_name='bbb' where p_id<(select p_id from sing_1_2 b where a.id=b.id)  | schema1 |
    Then check resultset "rs_7" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                      |
      | dn1             | BASE SQL | update sing_1 a set sing_1_name='bbb' where p_id<(select p_id from sing_1_2 b where a.id=b.id) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_8"
      | conn   | toClose | sql                                                                                                     | db      |
      | conn_0 | false   | explain update sing_1 a set sing_1_name='test' where id=(select p_id from schema3.noshard_1 b where a.id=b.id)  | schema1 |
    Then check resultset "rs_8" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                      |
      | dn1             | BASE SQL | update sing_1 a set sing_1_name='test' where id=(select p_id from noshard_1 b where a.id=b.id) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_9"
      | conn   | toClose | sql                                                                                                              | db      |
      | conn_0 | false   | explain update sing_3 a set sing_3_name='ccc' where p_id=(select p_id from schema2.vertical_3 b where a.id=b.id) | schema1 |
    Then check resultset "rs_9" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                        |
      | dn3             | BASE SQL | update sing_3 a set sing_3_name='ccc' where p_id=(select p_id from vertical_3 b where a.id=b.id) |

    # case 4: update no sharding table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                         | expect                                         | db      |
      # case 4.1: no sharding table + global table
      # noShardingTable: dn5   globalTable: dn5,dn6 -> support
      | conn_0 | False   | update noshard_5 a set noshard_5_name='test',p_id=p_id-1 where p_id=(select p_id from global_56 b where a.id=b.id)          | success                                        | schema1 |
      | conn_0 | False   | select * from noshard_5                                                                                                     | has{((1, 'test', 0), (2, 'test', 0), (3, 'test', 0), (4, 'test', 1), (5, 'test', 1), (6, 'test', 1))} | schema1 |
      | conn_0 | False   | update noshard_5 a set noshard_5_name='test' where p_id=(select p_id from global_12 b where a.id=b.id)                      | This `Complex Update Syntax` is not supported! | schema1 |
      # case 4.2: no sharding table + sharding table
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name='test' where p_id=(select p_id from shard_34 b where a.id=b.id)               | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name='test' where p_id=(select p_id from schema3.sharding_2_t3 b where a.id=b.id)  | This `Complex Update Syntax` is not supported! | schema1 |
      # noShardingTable: dn1 shardingTable: dn1,dn2 shardingNode=dn1 -> support
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name='test' where p_id=(select p_id from schema3.sharding_2_t3 b where a.id=b.id and b.id=2) | success                              | schema1 |
      | conn_0 | False   | select * from schema3.noshard_1                                                                                             | has{((1, 'noshard_1_1', 1), (2, 'test', 1), (3, 'noshard_1_3', 1), (4, 'noshard_1_4', 2), (5, 'noshard_1_5', 2), (6, 'noshard_1_6', 2))} | schema1 |
      # case 4.3: no sharding table + single table
      # noShardingTable: dn1 singleTable: dn1 -> support
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name='aaa' where p_id>(select p_id from sing_1 b where a.id=b.id and b.id=2)       | success                                        | schema1 |
      | conn_0 | False   | select * from schema3.noshard_1                                                                                             | has{((1, 'noshard_1_1', 1), (2, 'aaa', 1), (3, 'noshard_1_3', 1), (4, 'noshard_1_4', 2), (5, 'noshard_1_5', 2), (6, 'noshard_1_6', 2))} | schema1 |
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name='test' where p_id=(select p_id from sing_3 b where a.id=b.id and b.id=2)      | This `Complex Update Syntax` is not supported! | schema1 |
      # case 4.4: no sharding table + no sharding table
      # noShardingTable1: dn1 noShardingTable2: dn1 -> support
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name='bbb' where p_id=(select p_id from schema3.noshard_1_2 b where a.id=b.id)     | success                                        | schema1 |
      | conn_0 | False   | select * from schema3.noshard_1                                                                                             | has{((1, 'bbb', 1), (2, 'bbb', 1), (3, 'bbb', 1), (4, 'bbb', 2), (5, 'bbb', 2), (6, 'bbb', 2))} | schema1 |
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name='test' where p_id=(select p_id from noshard_5 b where a.id=b.id)              | This `Complex Update Syntax` is not supported! | schema1 |
      # case 4.5: no sharding table + vertical table
      # noShardingTable: dn3 verticalTable: dn3 -> support
      | conn_0 | False   | update schema2.sing_3 a set sing_3_name='ccc' where p_id=(select p_id from schema2.vertical_3 b where a.id=b.id) and p_id=2 | success                                        | schema1 |
      | conn_0 | True    | select * from schema2.sing_3                                                                                                | has{((1, 'ccc', 1), (2, 'ccc', 1), (3, 'ccc', 1), (4, 'ccc', 2), (5, 'ccc', 2), (6, 'ccc', 2))} | schema1 |
      | conn_0 | False   | update schema3.noshard_1 a set noshard_1_name='test' where p_id=(select p_id from schema2.vertical_3 b where a.id=b.id)     | This `Complex Update Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_10"
      | conn   | toClose | sql                                                                                                                        | db      |
      | conn_0 | false   | explain update noshard_5 a set noshard_5_name='test',p_id=p_id-1 where p_id=(select p_id from global_56 b where a.id=b.id) | schema1 |
    Then check resultset "rs_10" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                          |
      | dn5             | BASE SQL | update noshard_5 a set noshard_5_name='test',p_id=p_id-1 where p_id=(select p_id from global_56 b where a.id=b.id) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_11"
      | conn   | toClose | sql                                                                                                                            | db      |
      | conn_0 | false   | explain update schema3.noshard_1 a set noshard_1_name='aaa' where p_id>(select p_id from sing_1 b where a.id=b.id and b.id=2)  | schema1 |
    Then check resultset "rs_11" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                     |
      | dn1             | BASE SQL | update noshard_1 a set noshard_1_name='aaa' where p_id>(select p_id from sing_1 b where a.id=b.id and b.id=2) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_12"
      | conn   | toClose | sql                                                                                                                             | db      |
      | conn_0 | false   | explain update schema3.noshard_1 a set noshard_1_name='bbb' where p_id=(select p_id from schema3.noshard_1_2 b where a.id=b.id) | schema1 |
    Then check resultset "rs_12" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                               |
      | dn1             | BASE SQL | update noshard_1 a set noshard_1_name='bbb' where p_id=(select p_id from noshard_1_2 b where a.id=b.id) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_13"
      | conn   | toClose | sql                                                                                                                                 | db      |
      | conn_0 | false   | explain update schema2.sing_3 a set sing_3_name='ccc' where p_id=(select p_id from schema2.vertical_3 b where a.id=b.id) and p_id=2 | schema1 |
    Then check resultset "rs_13" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                   |
      | dn3             | BASE SQL | update sing_3 a set sing_3_name='ccc' where p_id=(select p_id from vertical_3 b where a.id=b.id) and p_id=2 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_14"
      | conn   | toClose | sql                                                                                                                                 | db      |
      | conn_0 | false   | explain update schema3.noshard_1 a set noshard_1_name='test' where p_id=(select p_id from shard_12 b where a.id=b.id and b.id=2)    | schema1 |
    Then check resultset "rs_14" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                        |
      | dn1             | BASE SQL | update noshard_1 a set noshard_1_name='test' where p_id=(select p_id from shard_12 b where a.id=b.id and b.id=2) |

    # case 5: update vertical table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                        | expect                                         | db      |
      # case 5.1: vertical table + global table
      # verticalTable: dn3   globalTable: dn1,dn2,dn3,dn4 -> support
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name='test' where p_id=(select p_id from global_1234 b where a.id=b.id)         | success                                        | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                                           | has{((1, 'test', 1), (2, 'test', 1), (3, 'test', 1), (4, 'test', 2), (5, 'test', 2), (6, 'test', 2))} | schema1 |
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name='test' where p_id=(select p_id from global_12 b where a.id=b.id)           | This `Complex Update Syntax` is not supported! | schema1 |
      # case 5.2: vertical table + sharding table
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name='test' where p_id=(select p_id from shard_12 b where a.id=b.id)            | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name='test' where p_id=(select p_id from shard_34 b where a.id=b.id)            | This `Complex Update Syntax` is not supported! | schema1 |
      # verticalTable: dn3  shardingTable: dn3,dn4 shardingNode=dn3 -> support
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name='aaa'  where p_id=(select p_id from shard_34 b where a.id=b.id and b.id=2) | success                                        | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                                           | has{((1, 'test', 1), (2, 'aaa', 1), (3, 'test', 1), (4, 'test', 2), (5, 'test', 2), (6, 'test', 2))} | schema1 |
      # case 5.3: vertical table + single table
      # verticalTable: dn3  singleTable: dn3 -> support
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name='bbb' where p_id=(select p_id from schema2.sing_3 b where a.id=b.id)       | success                                        | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                                           | has{((1, 'bbb', 1), (2, 'bbb', 1), (3, 'bbb', 1), (4, 'bbb', 2), (5, 'bbb', 2), (6, 'bbb', 2))} | schema1 |
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name='test' where p_id=(select p_id from sing_1 b where a.id=b.id)              | This `Complex Update Syntax` is not supported! | schema1 |
      # case 5.4: vertical table + no sharding table
      # verticalTable: dn3  noShardingTable: dn3 -> support
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name='ccc',p_id=p_id-1 where p_id=(select p_id from schema2.sing_3 b where a.id=b.id) | success                                        | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                                           | has{((1, 'ccc', 0), (2, 'ccc', 0), (3, 'ccc', 0), (4, 'ccc', 1), (5, 'ccc', 1), (6, 'ccc', 1))} | schema1 |
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name='test' where p_id=(select p_id from schema1.noshard_5 b where a.id=b.id)   | This `Complex Update Syntax` is not supported! | schema1 |
      # case 5.5: vertical table + vertical table
      # verticalTable1: dn3  verticalTable2: dn3 -> support
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name='ddd' where id=(select p_id from schema2.vertical_3_2 b where a.id=b.id)   | success                                        | schema1 |
      | conn_0 | True    | select * from schema2.vertical_3                                                                                           | has{((1, 'ddd', 0), (2, 'ccc', 0), (3, 'ccc', 0), (4, 'ccc', 1), (5, 'ccc', 1), (6, 'ccc', 1))} | schema1 |
      | conn_0 | False   | update schema2.vertical_3 a set vertical_3_name='test' where p_id=(select p_id from schema4.vertical_4 b where a.id=b.id)  | This `Complex Update Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_15"
      | conn   | toClose | sql                                                                                                                        | db      |
      | conn_0 | false   | explain update schema2.vertical_3 a set vertical_3_name='test' where p_id=(select p_id from global_1234 b where a.id=b.id) | schema1 |
    Then check resultset "rs_15" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                  |
      | dn3             | BASE SQL | update vertical_3 a set vertical_3_name='test' where p_id=(select p_id from global_1234 b where a.id=b.id) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_16"
      | conn   | toClose | sql                                                                                                                               | db      |
      | conn_0 | false   | explain update schema2.vertical_3 a set vertical_3_name='aaa' where p_id=(select p_id from shard_34 b where a.id=b.id and b.id=2) | schema1 |
    Then check resultset "rs_16" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                         |
      | dn3             | BASE SQL | update vertical_3 a set vertical_3_name='aaa' where p_id=(select p_id from shard_34 b where a.id=b.id and b.id=2) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_17"
      | conn   | toClose | sql                                                                                                                          | db      |
      | conn_0 | false   | explain update schema2.vertical_3 a set vertical_3_name='bbb' where p_id=(select p_id from schema2.sing_3 b where a.id=b.id) | schema1 |
    Then check resultset "rs_17" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                            |
      | dn3             | BASE SQL | update vertical_3 a set vertical_3_name='bbb' where p_id=(select p_id from sing_3 b where a.id=b.id) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_18"
      | conn   | toClose | sql                                                                                                                                      | db      |
      | conn_0 | false   | explain update schema2.vertical_3 a set vertical_3_name='ccc',p_id=p_id-1 where p_id=(select p_id from schema2.sing_3 b where a.id=b.id) | schema1 |
    Then check resultset "rs_18" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                        |
      | dn3             | BASE SQL | update vertical_3 a set vertical_3_name='ccc',p_id=p_id-1 where p_id=(select p_id from sing_3 b where a.id=b.id) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_19"
      | conn   | toClose | sql                                                                                                                              | db      |
      | conn_0 | true    | explain update schema2.vertical_3 a set vertical_3_name='ddd' where id=(select p_id from schema2.vertical_3_2 b where a.id=b.id) | schema1 |
    Then check resultset "rs_19" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                                                |
      | dn3             | BASE SQL | update vertical_3 a set vertical_3_name='ddd' where id=(select p_id from vertical_3_2 b where a.id=b.id) |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1; drop table if exists sharding_4_t1             | success | schema1 |
      | conn_0 | False   | drop table if exists shard_12; drop table if exists shard_34                       | success | schema1 |
      | conn_0 | False   | drop table if exists global_12; drop table if exists global_12_2                   | success | schema1 |
      | conn_0 | False   | drop table if exists global_23; drop table if exists global_34                     | success | schema1 |
      | conn_0 | False   | drop table if exists global_1234; drop table if exists global_36                   | success | schema1 |
      | conn_0 | False   | drop table if exists global_56                                                     | success | schema1 |
      | conn_0 | False   | drop table if exists sing_1;drop table if exists sing_1_2                          | success | schema1 |
      | conn_0 | False   | drop table if exists sing_3;drop table if exists noshard_5                         | success | schema1 |
      | conn_0 | False   | drop table if exists schema2.vertical_3;drop table if exists schema2.vertical_3_2  | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.sharding_2_t3                                         | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.sharding_4_t3                                         | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.noshard_1;drop table if exists schema3.noshard_1_2    | success | schema1 |
      | conn_0 | False   | drop table if exists schema4.vertical_4                                            | success | schema1 |

    Scenario: check delete where subquery #3
    # case 1: delete sharding table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                              | expect                                         | db      |
      # case 1.1: sharding table + global table
      # shardingTable: dn1,dn2 globalTable: dn1,dn2 -> support
      | conn_0 | False   | delete from sharding_2_t1 where p_id=(select p_id from global_12 b where b.id=1)                 | success                                        | schema1 |
      | conn_0 | False   | select * from sharding_2_t1                                                                      | has{((4, 'sharding_2_t1_4', 2), (5, 'sharding_2_t1_5', 2), (6, 'sharding_2_t1_6', 2))} | schema1 |
      # shardingTable: dn1,dn2 globalTable: dn1,dn2,dn3,dn4 -> support
      | conn_0 | False   | delete from sharding_2_t1 where p_id=(select p_id from global_1234 b where b.id=6)               | success                                        | schema1 |
      | conn_0 | False   | select * from sharding_2_t1                                                                      | length{(0)}                                    | schema1 |
      | conn_0 | False   | delete from sharding_2_t1 where p_id=(select p_id from global_23 b where b.id=1)                 | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from sharding_2_t1 where p_id=(select p_id from global_23 b where b.id=2)                 | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from sharding_2_t1 where p_id=(select p_id from global_34 b where b.id=1)                 | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from sharding_4_t1 where p_id=(select p_id from global_12 b where b.id=1)                 | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from sharding_4_t1 where p_id=(select p_id from global_36 b where b.id=1)                 | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from sharding_4_t1 where p_id=(select p_id from global_56 b where b.id=1)                 | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 1.2: sharding table + sharding table
      | conn_0 | False   | delete from sharding_2_t1 where p_id=(select p_id from shard_12 b where b.id=1)                  | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from sharding_2_t1 where p_id=(select p_id from shard_34 b where b.id=1)                  | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from sharding_2_t1 where p_id=(select p_id from sharding_4_t1 b where b.id=1)             | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from sharding_4_t1 where p_id=(select p_id from sharding_2_t1 b where b.id=1)             | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 1.3: sharding table + single table
      | conn_0 | False   | delete from sharding_2_t1 where p_id=(select p_id from sing_1 b where b.id=1)                    | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from sharding_2_t1 where p_id=(select p_id from sing_3 b where b.id=1)                    | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 1.4: sharding table + no sharding table
      | conn_0 | False   | delete from schema3.sharding_2_t3 where p_id=(select p_id from schema3.noshard_1 b where b.id=1) | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from sharding_2_t1 where p_id=(select p_id from noshard_5 b where b.id=1)                 | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 1.5: sharding table + vertica table
      | conn_0 | False   | delete from sharding_2_t1 where p_id=(select p_id from schema2.vertical_3 b where b.id=1)        | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | True    | delete from shard_34 where p_id=(select p_id from schema2.vertical_3 b where b.id=1)             | This `Complex Delete Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                      | db      |
      | conn_0 | false   | explain delete from sharding_2_t1 where p_id=(select p_id from global_12 b where b.id=1) | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                        |
      | dn1             | BASE SQL | delete from sharding_2_t1 where p_id=(select p_id from global_12 b where b.id=1) |
      | dn2             | BASE SQL | delete from sharding_2_t1 where p_id=(select p_id from global_12 b where b.id=1) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                                                        | db      |
      | conn_0 | false   | explain delete from sharding_2_t1 where p_id=(select p_id from global_1234 b where b.id=6) | schema1 |
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                          |
      | dn1             | BASE SQL | delete from sharding_2_t1 where p_id=(select p_id from global_1234 b where b.id=6) |
      | dn2             | BASE SQL | delete from sharding_2_t1 where p_id=(select p_id from global_1234 b where b.id=6) |

    # case 2: delete global table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                       | expect                                         | db      |
      # case 2.1: global table + global table
      # globalTable1: dn1,dn2 globalTable2: dn1,dn2 -> support
      | conn_0 | False   | delete from global_12 where p_id=(select p_id-10 from global_12_2 b where b.id=1)         | success                                        | schema1 |
      | conn_0 | False   | select * from global_12                                                                   | has{((1, 'global_12_1', 1), (2, 'global_12_2', 1), (3, 'global_12_3', 1))} | schema1 |
      # globalTable1: dn1,dn2 globalTable2: dn1,dn2,dn3,dn4 -> support
      | conn_0 | False   | delete from global_12 where p_id=(select p_id from global_1234 b where b.id=1)            | success                                        | schema1 |
      | conn_0 | False   | select * from global_12                                                                   | length{(0)}                                    | schema1 |
      | conn_0 | False   | delete from global_12 where p_id=(select p_id from global_23 b where b.id=1)              | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from global_1234 where p_id=(select p_id from global_34 b where b.id=1)            | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 2.2: global table + sharding table
      | conn_0 | False   | delete from global_12 where p_id=(select p_id from sharding_2_t1 b where b.id=1)          | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from global_12 where p_id=(select p_id from sharding_4_t1 b where b.id=1)          | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from global_12 where p_id=(select p_id from shard_34 b where b.id=1)               | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from global_1234 where p_id=(select p_id from shard_34 b where b.id=1)             | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 2.3: global table + single table
      | conn_0 | False   | delete from global_12 where p_id=(select p_id from sing_1 b where b.id=1)                 | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from global_12 where p_id=(select p_id from sing_3 b where b.id=1)                 | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 2.4: global table + no sharding table
      | conn_0 | False   | delete from global_12 where p_id=(select p_id from schema3.noshard_1 b where b.id=1)      | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from global_12 where p_id=(select p_id from noshard_5 b where b.id=1)              | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 2.5: global table + vertical table
      | conn_0 | False   | delete from global_12 where p_id=(select p_id from schema2.vertical_3 b where b.id=1)     | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | True    | delete from global_1234 where p_id=(select p_id from schema2.vertical_3 b where b.id=1)   | This `Complex Delete Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_3"
      | conn   | toClose | sql                                                                                       | db      |
      | conn_0 | false   | explain delete from global_12 where p_id=(select p_id-10 from global_12_2 b where b.id=1) | schema1 |
    Then check resultset "rs_3" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                         |
      | dn1             | BASE SQL | delete from global_12 where p_id=(select p_id-10 from global_12_2 b where b.id=1) |
      | dn2             | BASE SQL | delete from global_12 where p_id=(select p_id-10 from global_12_2 b where b.id=1) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_4"
      | conn   | toClose | sql                                                                                     | db      |
      | conn_0 | false   | explain delete from global_12 where p_id=(select p_id from global_1234 b where b.id=1)  | schema1 |
    Then check resultset "rs_4" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                      |
      | dn1             | BASE SQL | delete from global_12 where p_id=(select p_id from global_1234 b where b.id=1) |
      | dn2             | BASE SQL | delete from global_12 where p_id=(select p_id from global_1234 b where b.id=1) |

    # case 3: delete single table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                | expect                                         | db      |
      | conn_0 | False   | insert into global_12 values (1, 'global_12_1', 1),(2, 'global_12_2', 1),(3, 'global_12_3', 2),(4, 'global_12_4', 2),(5, 'global_12_5', 3),(6, 'global_12_6', 3) | success | schema1 |
      # case 3.1: single table + global table
      # singleTable: dn1 globalTable: dn1,dn2 -> support
      | conn_0 | False   | delete from sing_1 where p_id=(select p_id from global_12 b where b.id=1)          | success                                        | schema1 |
      | conn_0 | False   | select * from sing_1                                                               | has{((4, 'sing_1_4',2), (5, 'sing_1_5', 2), (6, 'sing_1_6', 2))} | schema1 |
      | conn_0 | False   | delete from sing_1 where p_id=(select p_id from global_34 b where b.id=1)          | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 3.2: single table + sharding table
      | conn_0 | False   | delete from sing_1 where p_id=(select p_id from shard_34 b where b.id=1)           | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from sing_1 where p_id=(select p_id from shard_12 b where b.id=1)           | This `Complex Delete Syntax` is not supported! | schema1 |
      # singleTable: dn1 shardingTable: dn1,dn2 shardingNode=dn1 -> support
      | conn_0 | False   | delete from sing_1 where p_id=(select p_id from shard_12 b where b.id=6)           | success                                        | schema1 |
      | conn_0 | False   | select * from sing_1                                                               | length{(0)}                                    | schema1 |
      | conn_0 | False   | insert into sing_1 values (1, 'sing_1_1', 1),(2, 'sing_1_2', 1),(3, 'sing_1_3', 2),(4, 'sing_1_4', 2),(5, 'sing_1_5', 3),(6, 'sing_1_6', 3) | success | schema1 |
      # case 3.3: single table + single table
      # singleTable1: dn1 singleTable2: dn1 -> support
      | conn_0 | False   | delete from sing_1 where p_id=(select p_id from sing_1_2 b where b.id=1)           | success                                        | schema1 |
      | conn_0 | False   | select * from sing_1                                                               | has{((3, 'sing_1_3', 2), (4, 'sing_1_4', 2), (5, 'sing_1_5', 3), (6, 'sing_1_6', 3))} | schema1 |
      | conn_0 | False   | delete from sing_1 a where p_id=(select p_id from sing_3 b where b.id=1)           | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 3.4: single table + no sharding table
      # singleTable: dn1 noShardingTable: dn1 -> support
      | conn_0 | False   | delete from sing_1 where p_id=(select p_id from schema3.noshard_1 b where b.id=4)  | success                                        | schema1 |
      | conn_0 | False   | select * from sing_1                                                               | has{((5, 'sing_1_5', 3), (6, 'sing_1_6', 3))}  | schema1 |
      | conn_0 | False   | delete from sing_1 where p_id=(select p_id from noshard_5 b where b.id=1)          | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 3.5: single table + vertical table
      # singleTable: dn3 verticalTable: dn3 -> support
      | conn_0 | False   | delete from sing_3 where p_id=(select p_id from schema2.vertical_3 b where b.id=1) | success                                        | schema1 |
      | conn_0 | False   | select * from sing_3                                                               | has{((4, 'sing_3_4',2), (5, 'sing_3_5', 2), (6, 'sing_3_6', 2))} | schema1 |
      | conn_0 | True    | delete from sing_1 where p_id=(select p_id from schema2.vertical_3 b where b.id=1) | This `Complex Delete Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_5"
      | conn   | toClose | sql                                                                               | db      |
      | conn_0 | false   | explain delete from sing_1 where p_id=(select p_id from global_12 b where b.id=1) | schema1 |
    Then check resultset "rs_5" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                 |
      | dn1             | BASE SQL | delete from sing_1 where p_id=(select p_id from global_12 b where b.id=1) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_6"
      | conn   | toClose | sql                                                                               | db      |
      | conn_0 | false   | explain delete from sing_1 where p_id=(select p_id from shard_12 b where b.id=6)  | schema1 |
    Then check resultset "rs_6" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                |
      | dn1             | BASE SQL | delete from sing_1 where p_id=(select p_id from shard_12 b where b.id=6) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_7"
      | conn   | toClose | sql                                                                               | db      |
      | conn_0 | false   | explain delete from sing_1 where p_id=(select p_id from sing_1_2 b where b.id=1)  | schema1 |
    Then check resultset "rs_7" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                 |
      | dn1             | BASE SQL | delete from sing_1 where p_id=(select p_id from sing_1_2 b where b.id=1)  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_8"
      | conn   | toClose | sql                                                                                        | db      |
      | conn_0 | false   | explain delete from sing_1 where p_id=(select p_id from schema3.noshard_1 b where b.id=4)  | schema1 |
    Then check resultset "rs_8" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                 |
      | dn1             | BASE SQL | delete from sing_1 where p_id=(select p_id from noshard_1 b where b.id=4) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_9"
      | conn   | toClose | sql                                                                                        | db      |
      | conn_0 | false   | explain delete from sing_3 where p_id=(select p_id from schema2.vertical_3 b where b.id=1) | schema1 |
    Then check resultset "rs_9" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                  |
      | dn3             | BASE SQL | delete from sing_3 where p_id=(select p_id from vertical_3 b where b.id=1) |

    # case 4: delete no sharding table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                              | expect                                         | db      |
      | conn_0 | False   | insert into sing_1 values (1, 'sing_1_1', 1),(2, 'sing_1_2', 1),(3, 'sing_1_3', 2),(4, 'sing_1_4', 2),(5, 'sing_1_5', 3),(6, 'sing_1_6', 3) | success | schema1 |
      # case 4.1: no sharding table + global table
      # noShardingTable: dn5   globalTable: dn5,dn6 -> support
      | conn_0 | False   | delete from noshard_5 where p_id=(select p_id from global_56 b where b.id=1)                     | success                                        | schema1 |
      | conn_0 | False   | select * from noshard_5                                                                          | has{((4, 'noshard_5_4',2), (5, 'noshard_5_5', 2), (6, 'noshard_5_6', 2))} | schema1 |
      | conn_0 | False   | delete  from noshard_5 where p_id=(select p_id from global_12 b where b.id=1)                    | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 4.2: no sharding table + sharding table
      | conn_0 | False   | delete from schema3.noshard_1 where p_id=(select p_id from shard_34 b where b.id=1)              | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from schema3.noshard_1 where p_id=(select p_id from schema3.sharding_2_t3 b where b.id=1) | This `Complex Delete Syntax` is not supported! | schema1 |
      # noShardingTable: dn1 shardingTable: dn1,dn2 shardingNode=dn1 -> support
      | conn_0 | False   | delete from schema3.noshard_1 where p_id=(select p_id from schema3.sharding_2_t3 b where b.id=2) | success                                        | schema1 |
      | conn_0 | False   | select * from schema3.noshard_1                                                                  | has{((4, 'noshard_1_4', 2), (5, 'noshard_1_5', 2), (6, 'noshard_1_6', 2))} | schema1 |
      # case 4.3: no sharding table + single table
      # noShardingTable: dn1 singleTable: dn1 -> support
      | conn_0 | False   | delete from schema3.noshard_1 where p_id=(select p_id from sing_1 b where b.id=4)                | success                                        | schema1 |
      | conn_0 | False   | select * from schema3.noshard_1                                                                  | length{(0)}                                    | schema1 |
      | conn_0 | False   | delete from schema3.noshard_1 where p_id=(select p_id from sing_3 b where b.id=2)                | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | insert into schema3.noshard_1 values (1, 'noshard_1_1', 1),(2, 'noshard_1_2', 1),(3, 'noshard_1_3', 2),(4, 'noshard_1_4', 2),(5, 'noshard_1_5', 3),(6, 'noshard_1_6', 3) | success | schema1 |
      # case 4.4: no sharding table + no sharding table
      # noShardingTable1: dn1 noShardingTable2: dn1 -> support
      | conn_0 | False   | delete from schema3.noshard_1 where p_id=(select p_id from schema3.noshard_1_2 b where b.id=1)   | success                                        | schema1 |
      | conn_0 | False   | select * from schema3.noshard_1                                                                  | has{((3, 'noshard_1_3', 2), (4, 'noshard_1_4', 2), (5, 'noshard_1_5', 3), (6, 'noshard_1_6', 3))} | schema1 |
      | conn_0 | False   | delete from schema3.noshard_1 where p_id=(select p_id from noshard_5 b where b.id=1);            | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 4.5: no sharding table + vertical table
      # noShardingTable: dn3 verticalTable: dn3 -> support
      | conn_0 | False   | delete from schema2.sing_3 where p_id=(select p_id from schema2.vertical_3 b where b.id=1)       | success                                        | schema1 |
      | conn_0 | True    | select * from schema2.sing_3                                                                     | has{((4, 'sing_3_4',2), (5, 'sing_3_5', 2), (6, 'sing_3_6', 2))} | schema1 |
      | conn_0 | False   | delete from schema3.noshard_1 where p_id=(select p_id from schema2.vertical_3 b where b.id=1)    | This `Complex Delete Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_10"
      | conn   | toClose | sql                                                                                  | db      |
      | conn_0 | false   | explain delete from noshard_5 where p_id=(select p_id from global_56 b where b.id=1) | schema1 |
    Then check resultset "rs_10" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                    |
      | dn5             | BASE SQL | delete from noshard_5 where p_id=(select p_id from global_56 b where b.id=1) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_11"
      | conn   | toClose | sql                                                                                          | db      |
      | conn_0 | false   | explain delete from schema3.noshard_1 where p_id=(select p_id from shard_12 b where b.id=2)  | schema1 |
    Then check resultset "rs_11" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                   |
      | dn1             | BASE SQL | delete from noshard_1 where p_id=(select p_id from shard_12 b where b.id=2) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_12"
      | conn   | toClose | sql                                                                                       | db      |
      | conn_0 | false   | explain delete from schema3.noshard_1 where p_id=(select p_id from sing_1 b where b.id=4) | schema1 |
    Then check resultset "rs_12" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                 |
      | dn1             | BASE SQL | delete from noshard_1 where p_id=(select p_id from sing_1 b where b.id=4) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_13"
      | conn   | toClose | sql                                                                                                    | db      |
      | conn_0 | false   | explain delete from schema3.noshard_1 where p_id=(select p_id from schema3.noshard_1_2 b where b.id=1) | schema1 |
    Then check resultset "rs_13" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                      |
      | dn1             | BASE SQL | delete from noshard_1 where p_id=(select p_id from noshard_1_2 b where b.id=1) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_14"
      | conn   | toClose | sql                                                                                                   | db      |
      | conn_0 | false   | explain delete from schema2.sing_3 where p_id=(select p_id from schema2.vertical_3 b where b.id=1)    | schema1 |
    Then check resultset "rs_14" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                  |
      | dn3             | BASE SQL | delete from sing_3 where p_id=(select p_id from vertical_3 b where b.id=1) |

    # case 5: delete vertical table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                           | expect                                         | db      |
      # case 5.1: vertical table + global table
      # verticalTable: dn3   globalTable: dn1,dn2,dn3,dn4 -> support
      | conn_0 | False   | delete from schema2.vertical_3 where p_id=(select p_id from global_1234 b where b.id=1)                       | success                                        | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                              | has{((4, 'vertical_3_4', 2), (5, 'vertical_3_5', 2), (6, 'vertical_3_6', 2))} | schema1 |
      | conn_0 | False   | delete from schema2.vertical_3 where p_id=(select p_id from global_12 b where b.id=1)                         | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 5.2: vertical table + sharding table
      | conn_0 | False   | delete from schema2.vertical_3 where p_id=(select p_id from shard_12 b where b.id=1)                          | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_0 | False   | delete from schema2.vertical_3 where p_id=(select p_id from shard_34 b where b.id=1)                          | This `Complex Delete Syntax` is not supported! | schema1 |
      # verticalTable: dn3  shardingTable: dn3,dn4 shardingNode=dn3 -> support
      | conn_0 | False   | delete from schema2.vertical_3 where p_id=(select p_id from shard_34 b where b.id=4)                          | success                                        | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                              | length{(0)}                                    | schema1 |
      | conn_0 | False   | insert into schema2.vertical_3 values (1, 'vertical_3_1', 1),(2, 'vertical_3_2', 1),(3, 'vertical_3_3', 2),(4, 'vertical_3_4', 2),(5, 'vertical_3_5', 3),(6, 'vertical_3_6', 3) | success | schema1 |
      # case 5.3: vertical table + single table
      # verticalTable: dn3  singleTable: dn3 -> support
      | conn_0 | False   | delete from schema2.vertical_3 where p_id=(select p_id from sing_3 b where b.id=4)                            | success                                        | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                              | has{((1, 'vertical_3_1', 1), (2, 'vertical_3_2', 1), (5, 'vertical_3_5', 3), (6, 'vertical_3_6', 3))} | schema1 |
      | conn_0 | False   | delete from schema2.vertical_3 where p_id=(select p_id from sing_1 b where b.id=1)                            | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 5.4: vertical table + no sharding table
      # verticalTable: dn3  noShardingTable: dn3 -> support
      | conn_0 | False   | delete from schema2.vertical_3 where p_id>(select p_id from schema2.sing_3 b where b.id=4)                    | success                                        | schema1 |
      | conn_0 | False   | select * from schema2.vertical_3                                                                              | has{((1, 'vertical_3_1', 1), (2, 'vertical_3_2', 1))} | schema1 |
      | conn_0 | False   | delete from schema2.vertical_3 where p_id=(select p_id from schema1.noshard_5 b where b.id=1)                 | This `Complex Delete Syntax` is not supported! | schema1 |
      # case 5.5: vertical table + vertical table
      # verticalTable1: dn3  verticalTable2: dn3 -> support
      | conn_0 | False   | delete from schema2.vertical_3 where p_id=(select p_id from schema2.vertical_3_2 b where b.id=1)              | success                                        | schema1 |
      | conn_0 | True    | select * from schema2.vertical_3                                                                              | length{(0)}                                    | schema1 |
      | conn_0 | False   | delete from schema2.vertical_3 where p_id=(select p_id from schema4.vertical_4 b where b.id=1)                | This `Complex Delete Syntax` is not supported! | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_15"
      | conn   | toClose | sql                                                                                             | db      |
      | conn_0 | false   | explain delete from schema2.vertical_3 where p_id=(select p_id from global_1234 b where b.id=1) | schema1 |
    Then check resultset "rs_15" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                       |
      | dn3             | BASE SQL | delete from vertical_3 where p_id=(select p_id from global_1234 b where b.id=1) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_16"
      | conn   | toClose | sql                                                                                          | db      |
      | conn_0 | false   | explain delete from schema2.vertical_3 where p_id=(select p_id from shard_34 b where b.id=2) | schema1 |
    Then check resultset "rs_16" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                    |
      | dn3             | BASE SQL | delete from vertical_3 where p_id=(select p_id from shard_34 b where b.id=2) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_17"
      | conn   | toClose | sql                                                                                        | db      |
      | conn_0 | false   | explain delete from schema2.vertical_3 where p_id=(select p_id from sing_3 b where b.id=1) | schema1 |
    Then check resultset "rs_17" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                  |
      | dn3             | BASE SQL | delete from vertical_3 where p_id=(select p_id from sing_3 b where b.id=1) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_18"
      | conn   | toClose | sql                                                                                                | db      |
      | conn_0 | false   | explain delete from schema2.vertical_3 where p_id=(select p_id from schema2.sing_3 b where b.id=1) | schema1 |
    Then check resultset "rs_18" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                  |
      | dn3             | BASE SQL | delete from vertical_3 where p_id=(select p_id from sing_3 b where b.id=1) |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_19"
      | conn   | toClose | sql                                                                                                      | db      |
      | conn_0 | true    | explain delete from schema2.vertical_3 where p_id=(select p_id from schema2.vertical_3_2 b where b.id=1) | schema1 |
    Then check resultset "rs_19" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                        |
      | dn3             | BASE SQL | delete from vertical_3 where p_id=(select p_id from vertical_3_2 b where b.id=1) |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1; drop table if exists sharding_4_t1             | success | schema1 |
      | conn_0 | False   | drop table if exists shard_12; drop table if exists shard_34                       | success | schema1 |
      | conn_0 | False   | drop table if exists global_12; drop table if exists global_12_2                   | success | schema1 |
      | conn_0 | False   | drop table if exists global_23; drop table if exists global_34                     | success | schema1 |
      | conn_0 | False   | drop table if exists global_1234; drop table if exists global_36                   | success | schema1 |
      | conn_0 | False   | drop table if exists global_56                                                     | success | schema1 |
      | conn_0 | False   | drop table if exists sing_1;drop table if exists sing_1_2                          | success | schema1 |
      | conn_0 | False   | drop table if exists sing_3;drop table if exists noshard_5                         | success | schema1 |
      | conn_0 | False   | drop table if exists schema2.vertical_3;drop table if exists schema2.vertical_3_2  | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.sharding_2_t3                                         | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.sharding_4_t3                                         | success | schema1 |
      | conn_0 | False   | drop table if exists schema3.noshard_1;drop table if exists schema3.noshard_1_2    | success | schema1 |
      | conn_0 | False   | drop table if exists schema4.vertical_4                                            | success | schema1 |