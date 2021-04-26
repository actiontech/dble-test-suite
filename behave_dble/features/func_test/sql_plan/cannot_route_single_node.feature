# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/9
#2.19.11.0#dble-7876
Feature: following complex queries are not able to send one shardingnode
      #1. explain select * from sharding_two_node a join sharding_two_node2 b on a.c_flag=b.c_flag where a.id =1 or b.id=1
      #2. explain select * from sharding_two_node a join sharding_two_node2 b on a.c_flag=b.c_flag where (a.id =1 and b.id=1) or (a.id =513 and b.id=513)
      #3. explain select * from sharding_two_node a join sharding_two_node2 b where (a.id = b.id and a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 )
      #4. explain select * from sharding_two_node a join sharding_two_node2 b where a.c_flag=b.c_flag and a.id =2
      #5. explain select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and (a.c_decimal=1 or (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 )))
      #6. explain select * from sharding_two_node where c_flag = (select c_flag from sharding_two_node2 where id =1 )
      #7. explain select * from sharding_two_node where id =1 union select * from sharding_two_node2

   Scenario: execute "explain sql" and check result
    Given add xml segment to node with attribute "{'tag':'function','kv_map':{'name':'hash-two'}}" in "sharding.xml"
    """
    <property name="partitionLength">512</property>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
    <shardingTable name="sharding_two_node" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    <shardingTable name="sharding_two_node2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                  | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_two_node2                              | success | schema1 |
      | conn_0 | False   | create table sharding_two_node2(id int, c_flag int, c_decimal float) | success | schema1 |
      | conn_0 | False   | drop table if exists sharding_two_node                               | success | schema1 |
      | conn_0 | False   | create table sharding_two_node(id int, c_flag int, c_decimal float)  | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_A"
      | conn   | toClose | sql                                                                                                             |
      | conn_0 | False   | explain select * from sharding_two_node a join sharding_two_node2 b on a.c_flag=b.c_flag where a.id =1 or b.id=1|
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` ORDER BY `a`.`c_flag` ASC  |
      | dn2_0             | BASE SQL        | select `a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` ORDER BY `a`.`c_flag` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b` ORDER BY `b`.`c_flag` ASC |
      | dn2_1             | BASE SQL        | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b` ORDER BY `b`.`c_flag` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                      |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | where_filter_1                                                                                        |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_B"
      | conn   | toClose | sql                                                                                                                                            |
      | conn_0 | False   | explain select * from sharding_two_node a join sharding_two_node2 b on a.c_flag=b.c_flag where (a.id =1 and b.id=1) or (a.id =513 and b.id=513)|
    Then check resultset "rs_B" has lines with following column values
      | DATA_NODE-0       | TYPE-1          | SQL/REF-2                                                                                                                                      |
      | dn1_0             | BASE SQL        | select `a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` where  ( `a`.`id` = 1 OR `a`.`id` = 513) ORDER BY `a`.`c_flag` ASC  |
      | dn2_0             | BASE SQL        | select `a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` where  ( `a`.`id` = 1 OR `a`.`id` = 513) ORDER BY `a`.`c_flag` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                              |
      | dn1_1             | BASE SQL        | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b` where  ( `b`.`id` = 1 OR `b`.`id` = 513) ORDER BY `b`.`c_flag` ASC |
      | dn2_1             | BASE SQL        | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b` where  ( `b`.`id` = 1 OR `b`.`id` = 513) ORDER BY `b`.`c_flag` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                              |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                               |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | where_filter_1                                                                                                                                 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_C"
      | conn   | toClose | sql                                                                                                                                                |
      | conn_0 | False   | explain select * from sharding_two_node a join sharding_two_node2 b where (a.id = b.id and a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 )|
    Then check resultset "rs_C" has lines with following column values
      | DATA_NODE-0     | TYPE-1        | SQL/REF-2                                                                                                         |
      | dn1_0           | BASE SQL      | select `a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` where  ( `a`.`id` = 1 OR `a`.`id` = 2) |
      | merge_1         | MERGE         | dn1_0                                                                                                             |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                           |
      | dn1_1           | BASE SQL      | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b`                                       |
      | dn2_0           | BASE SQL      | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b`                                       |
      | merge_2         | MERGE         | dn1_1; dn2_0                                                                                                      |
      | shuffle_field_3 | SHUFFLE_FIELD | merge_2                                                                                                           |
      | join_1          | JOIN          | shuffle_field_1; shuffle_field_3                                                                                  |
      | where_filter_1  | WHERE_FILTER  | join_1                                                                                                            |
      | shuffle_field_2 | SHUFFLE_FIELD | where_filter_1                                                                                                    |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_D"
      | conn   | toClose | sql                                                                                                     |
      | conn_0 | False   | explain select * from sharding_two_node a join sharding_two_node2 b where a.c_flag=b.c_flag and a.id =2 |
    Then check resultset "rs_D" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                               |
      | dn1_0             | BASE SQL        | select `a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` where `a`.`id` = 2 ORDER BY `a`.`c_flag` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_1                                                                                                                 |
      | dn1_1             | BASE SQL        | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b` ORDER BY `b`.`c_flag` ASC                   |
      | dn2_0             | BASE SQL        | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b` ORDER BY `b`.`c_flag` ASC                   |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_E"
      | conn   | toClose | sql                                                                                                                                                                            |
      | conn_0 | False   | explain select b.*,a.* from sharding_two_node a join sharding_two_node2 b where a.id =b.id and (a.c_decimal=1 or (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 ))) |
    Then check resultset "rs_E" has lines with following column values
      | DATA_NODE-0     | TYPE-1        | SQL/REF-2                                                                                                                                                                                                                                                                                                                                                       |
      | dn1_0           | BASE SQL      | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal`,`a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` join  `sharding_two_node2` `b` on `a`.`id` = `b`.`id` where  (  ( `a`.`id` = 1 OR `a`.`id` = 2 OR `a`.`c_decimal` in (1)) AND  (  ( `a`.`id` = 1 AND `b`.`id` = 1) OR  ( `a`.`c_flag` = `b`.`c_flag` AND `a`.`id` = 2) OR `a`.`c_decimal` in (1))) |
      | dn2_0           | BASE SQL      | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal`,`a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` join  `sharding_two_node2` `b` on `a`.`id` = `b`.`id` where  (  ( `a`.`id` = 1 OR `a`.`id` = 2 OR `a`.`c_decimal` in (1)) AND  (  ( `a`.`id` = 1 AND `b`.`id` = 1) OR  ( `a`.`c_flag` = `b`.`c_flag` AND `a`.`id` = 2) OR `a`.`c_decimal` in (1))) |
      | merge_1         | MERGE         | dn1_0; dn2_0                                                                                                                                                                                                                                                                                                                                                    |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                                                                                                                                                                                                                                                                         |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_F"
      | conn   | toClose | sql                                                                                                         |
      | conn_0 | False   | explain select * from sharding_two_node where c_flag = (select c_flag from sharding_two_node2 where id =1 ) |
    Then check resultset "rs_F" has lines with following column values
      | DATA_NODE-0        | TYPE-1                | SQL/REF-2                                                                                                                                                                                           |
      | dn1_0              | BASE SQL              | select `sharding_two_node2`.`c_flag` as `autoalias_scalar` from  `sharding_two_node2` where `sharding_two_node2`.`id` = 1 LIMIT 2                                                                   |
      | merge_1            | MERGE                 | dn1_0                                                                                                                                                                                               |
      | limit_1            | LIMIT                 | merge_1                                                                                                                                                                                             |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                                                                                             |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                                                                                     |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_two_node`.`id`,`sharding_two_node`.`c_flag`,`sharding_two_node`.`c_decimal` from  `sharding_two_node` where `sharding_two_node`.`c_flag` = '{NEED_TO_REPLACE}' |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_two_node`.`id`,`sharding_two_node`.`c_flag`,`sharding_two_node`.`c_decimal` from  `sharding_two_node` where `sharding_two_node`.`c_flag` = '{NEED_TO_REPLACE}' |
      | merge_2            | MERGE                 | dn1_1; dn2_0                                                                                                                                                                                        |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_2                                                                                                                                                                                             |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_G"
      | conn   | toClose | sql                                                                                        |
      | conn_0 | False   | explain select * from sharding_two_node where id =1 union select * from sharding_two_node2 |
    Then check resultset "rs_G" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                                                                                     |
      | dn1_0           | BASE SQL      | select `sharding_two_node`.`id`,`sharding_two_node`.`c_flag`,`sharding_two_node`.`c_decimal` from  `sharding_two_node` where `sharding_two_node`.`id` = 1     |
      | merge_1         | MERGE         | dn1_0                                                                                                                                                         |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                                                                       |
      | dn1_1           | BASE SQL      | select `sharding_two_node2`.`id` as `id`,`sharding_two_node2`.`c_flag` as `c_flag`,`sharding_two_node2`.`c_decimal` as `c_decimal` from  `sharding_two_node2` |
      | dn2_0           | BASE SQL      | select `sharding_two_node2`.`id` as `id`,`sharding_two_node2`.`c_flag` as `c_flag`,`sharding_two_node2`.`c_decimal` as `c_decimal` from  `sharding_two_node2` |
      | merge_2         | MERGE         | dn1_1; dn2_0                                                                                                                                                  |
      | shuffle_field_3 | SHUFFLE_FIELD | merge_2                                                                                                                                                       |
      | union_all_1     | UNION_ALL     | shuffle_field_1; shuffle_field_3                                                                                                                              |
      | distinct_1      | DISTINCT      | union_all_1                                                                                                                                                   |
      | shuffle_field_2 | SHUFFLE_FIELD | distinct_1                                                                                                                                                    |

    #add case https://github.com/actiontech/dble/issues/1714
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_H"
      | conn   | toClose | sql                                                                                                                                                               |
      | conn_0 | False   | explain select * from ( select a.id aid,b.id bid,3 mark from sharding_two_node2 a left join sharding_two_node b on a.id= b.id where a.id >3) t where t.mark IN(3) |
    Then check resultset "rs_H" has lines with following column values
      | SHARDING_NODE-0            | TYPE-1                   | SQL/REF-2                                                                                                                                                                |
      | dn1_0                      | BASE SQL                 | select `a`.`id` as `aid`,`b`.`id` as `bid` from  `sharding_two_node2` `a` left join  `sharding_two_node` `b` on `a`.`id` = `b`.`id` where  ( `a`.`id` > 3 AND 3 in (3))  |
      | dn2_0                      | BASE SQL                 | select `a`.`id` as `aid`,`b`.`id` as `bid` from  `sharding_two_node2` `a` left join  `sharding_two_node` `b` on `a`.`id` = `b`.`id` where  ( `a`.`id` > 3 AND 3 in (3))  |
      | merge_1                    | MERGE                    | dn1_0; dn2_0                                                                                                                                                             |
      | shuffle_field_1            | SHUFFLE_FIELD            | merge_1                                                                                                                                                                  |
      | rename_derived_sub_query_1 | RENAME_DERIVED_SUB_QUERY | shuffle_field_1                                                                                                                                                          |
      | shuffle_field_2            | SHUFFLE_FIELD            | rename_derived_sub_query_1                                                                                                                                               |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                  | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_two_node2                              | success | schema1 |
      | conn_0 | true    | drop table if exists sharding_two_node                               | success | schema1 |


    # add case DBLE0REQ-1064
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                          | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_two_node2                                                                      | success | schema1 |
      | conn_0 | False   | create table sharding_two_node2(`id` int(11) DEFAULT NULL,`name` char(20) COLLATE utf8mb4_bin DEFAULT NULL)  | success | schema1 |
      | conn_0 | False   | drop table if exists sharding_two_node                                                                       | success | schema1 |
      | conn_0 | False   | create table sharding_two_node(`id` int(11) DEFAULT NULL,`name` char(20) COLLATE utf8mb4_bin DEFAULT NULL)   | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                         |
      | conn_0 | False   | explain select a.* from sharding_two_node2 a where a.id =2 or a.id in (select b.id from sharding_two_node b ) order by a.id |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn1_0             | BASE SQL              | select `b`.`id` as `autoalias_scalar` from  `sharding_two_node` `b`                                                                                            |
      | dn2_0             | BASE SQL              | select `b`.`id` as `autoalias_scalar` from  `sharding_two_node` `b`                                                                                            |
      | merge_1           | MERGE                 | dn1_0; dn2_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                        |
      | in_sub_query_1    | IN_SUB_QUERY          | shuffle_field_1                                                                                                                                                |
      | dn1_1             | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id`,`a`.`name` from  `sharding_two_node2` `a` where  ( `a`.`id` in ('{NEED_TO_REPLACE}') OR `a`.`id` in (2)) ORDER BY `a`.`id` ASC |
      | dn2_1             | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id`,`a`.`name` from  `sharding_two_node2` `a` where  ( `a`.`id` in ('{NEED_TO_REPLACE}') OR `a`.`id` in (2)) ORDER BY `a`.`id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                  | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_two_node2                              | success | schema1 |
      | conn_0 | true    | drop table if exists sharding_two_node                               | success | schema1 |