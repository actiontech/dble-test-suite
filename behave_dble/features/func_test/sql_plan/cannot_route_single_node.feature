# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/9

Feature: following complex queries are not able to send one datanode
      #1. explain select * from sharding_two_node a join sharding_two_node2 b on a.c_flag=b.c_flag where a.id =1 or b.id=1
      #2. explain select * from sharding_two_node a join sharding_two_node2 b on a.c_flag=b.c_flag where (a.id =1 and b.id=1) or (a.id =513 and b.id=513)
      #3. explain select * from sharding_two_node a join sharding_two_node2 b where (a.id = b.id and a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 )
      #4. explain select * from sharding_two_node a join sharding_two_node2 b where a.c_flag=b.c_flag and a.id =2
      #5. explain select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and (a.c_decimal=1 or (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 )))
      #6. explain select * from sharding_two_node where c_flag = (select c_flag from sharding_two_node2 where id =1 )
      #7. explain select * from sharding_two_node where id =1 union select * from sharding_two_node2

  Scenario: execute "explain sql" and check result
    Given add xml segment to node with attribute "{'tag':'user','kv_map':{'name':'test'}}" in "server.xml"
    """
    <property name="schemas">schema1,mytest</property>
    """
    Given add xml segment to node with attribute "{'tag':'function','kv_map':{'name':'two-long'}}" in "rule.xml"
    """
    <property name="partitionLength">512</property>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="mytest" sqlMaxLimit="100" dataNode="dn5">
    <table name="sharding_two_node" dataNode="dn1,dn2" rule="hash-two"/>
    <table name="sharding_two_node2" dataNode="dn1,dn2" rule="hash-two"/>
    </schema>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                  | expect  | db     |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_two_node2                              | success | mytest |
      | test | 111111 | conn_0 | False   | create table sharding_two_node2(id int, c_flag int, c_decimal float) | success | mytest |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_two_node                               | success | mytest |
      | test | 111111 | conn_0 | False   | create table sharding_two_node(id int, c_flag int, c_decimal float)  | success | mytest |

    Then get resultset of user cmd "explain select * from sharding_two_node a join sharding_two_node2 b on a.c_flag=b.c_flag where a.id =1 or b.id=1" named "rs_A" with connection "conn_0"
    Then check resultset "rs_A" has lines with following column values
      | DATA_NODE-0       | TYPE-1          | SQL/REF-2                                                                                             |
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
    Then get resultset of user cmd "explain select * from sharding_two_node a join sharding_two_node2 b on a.c_flag=b.c_flag where (a.id =1 and b.id=1) or (a.id =513 and b.id=513)" named "rs_B" with connection "conn_0"
    Then check resultset "rs_B" has lines with following column values
      | DATA_NODE-0       | TYPE-1          | SQL/REF-2                                                                                                                                      |
      | dn1_0             | BASE SQL        | select `a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` where (`a`.`id` = 1) OR (`a`.`id` = 513) ORDER BY `a`.`c_flag` ASC  |
      | dn2_0             | BASE SQL        | select `a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` where (`a`.`id` = 1) OR (`a`.`id` = 513) ORDER BY `a`.`c_flag` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                              |
      | dn1_1             | BASE SQL        | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b` where (`b`.`id` = 1) OR (`b`.`id` = 513) ORDER BY `b`.`c_flag` ASC |
      | dn2_1             | BASE SQL        | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b` where (`b`.`id` = 1) OR (`b`.`id` = 513) ORDER BY `b`.`c_flag` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                              |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                               |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | where_filter_1                                                                                                                                 |

    Then get resultset of user cmd "explain select * from sharding_two_node a join sharding_two_node2 b where (a.id = b.id and a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 )" named "rs_C" with connection "conn_0"
    Then check resultset "rs_C" has lines with following column values
      | DATA_NODE-0     | TYPE-1        | SQL/REF-2                                                                                                         |
      | dn1_0           | BASE SQL      | select `a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` where (`a`.`id` = 1) OR (`a`.`id` = 2) |
      | merge_1         | MERGE         | dn1_0                                                                                                             |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                           |
      | dn1_1           | BASE SQL      | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b`                                       |
      | dn2_0           | BASE SQL      | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b`                                       |
      | merge_2         | MERGE         | dn1_1; dn2_0                                                                                                      |
      | shuffle_field_3 | SHUFFLE_FIELD | merge_2                                                                                                           |
      | join_1          | JOIN          | shuffle_field_1; shuffle_field_3                                                                                  |
      | where_filter_1  | WHERE_FILTER  | join_1                                                                                                            |
      | shuffle_field_2 | SHUFFLE_FIELD | where_filter_1                                                                                                    |

    Then get resultset of user cmd "explain select * from sharding_two_node a join sharding_two_node2 b where a.c_flag=b.c_flag and a.id =2" named "rs_D" with connection "conn_0"
    Then check resultset "rs_D" has lines with following column values
      | DATA_NODE-0       | TYPE-1          | SQL/REF-2                                                                                                               |
      | dn1_0             | BASE SQL        | select `a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` where `a`.`id` = 2 ORDER BY `a`.`c_flag` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_1                                                                                                                 |
      | dn1_1             | BASE SQL        | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b` ORDER BY `b`.`c_flag` ASC                   |
      | dn2_0             | BASE SQL        | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal` from  `sharding_two_node2` `b` ORDER BY `b`.`c_flag` ASC                   |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                  |

    Then get resultset of user cmd "explain select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and (a.c_decimal=1 or (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 )))" named "rs_E" with connection "conn_0"
    Then check resultset "rs_E" has lines with following column values
      | DATA_NODE-0     | TYPE-1        | SQL/REF-2                                                                                                                                                                                                                                                                                                                                                       |
      | dn1_0           | BASE SQL      | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal`,`a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` join  `sharding_two_node2` `b` on `a`.`id` = `b`.`id` where ((`a`.`id` = 1) OR (`a`.`id` = 2) OR (a.c_decimal IN (1))) AND (((`a`.`id` = 1) AND (`b`.`id` = 1)) OR ((`a`.`c_flag` = `b`.`c_flag`) AND (`a`.`id` = 2)) OR (a.c_decimal IN (1))) |
      | dn2_0           | BASE SQL      | select `b`.`id`,`b`.`c_flag`,`b`.`c_decimal`,`a`.`id`,`a`.`c_flag`,`a`.`c_decimal` from  `sharding_two_node` `a` join  `sharding_two_node2` `b` on `a`.`id` = `b`.`id` where ((`a`.`id` = 1) OR (`a`.`id` = 2) OR (a.c_decimal IN (1))) AND (((`a`.`id` = 1) AND (`b`.`id` = 1)) OR ((`a`.`c_flag` = `b`.`c_flag`) AND (`a`.`id` = 2)) OR (a.c_decimal IN (1))) |
      | merge_1         | MERGE         | dn1_0; dn2_0                                                                                                                                                                                                                                                                                                                                                    |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                                                                                                                                                                                                                                                                         |

    Then get resultset of user cmd "explain select * from sharding_two_node where c_flag = (select c_flag from sharding_two_node2 where id =1 )" named "rs_F" with connection "conn_0"
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

    Then get resultset of user cmd "explain select * from sharding_two_node where id =1 union select * from sharding_two_node2" named "rs_G" with connection "conn_0"
    Then check resultset "rs_G" has lines with following column values
      | DATA_NODE-0     | TYPE-1        | SQL/REF-2                                                                                                                                                     |
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