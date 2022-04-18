# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/7/28

# DBLE0REQ-1055
Feature: test inSubQueryTransformToJoin in bootstrap.cnf

  Scenario: check inSubQueryTransformToJoin in bootstrap.cnf - illegal values #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DinSubQueryTransformToJoin/d
    $a -DinSubQueryTransformToJoin=1
    """
    Then restart dble in "dble-1" failed for
    """
    Property \[ inSubQueryTransformToJoin \] '1' data type should be boolean
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DinSubQueryTransformToJoin=1/c -DinSubQueryTransformToJoin=False123
    """
    Then restart dble in "dble-1" failed for
    """
    Property \[ inSubQueryTransformToJoin \] 'False123' data type should be boolean
    """

  Scenario: check inSubQueryTransformToJoin in bootstrap.cnf - default values : false #2
    # check default values
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | sql             |
      | show @@sysparam |
    Then check resultset "join_rs1" has lines with following column values
      | PARAM_NAME-0              | PARAM_VALUE-1 |
      | inSubQueryTransformToJoin | false         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                             | db               |
      | conn_0 | True    | select variable_name, variable_value from dble_variables where variable_name like '%inSubQueryTransformToJoin%' | dble_information |
    Then check resultset "join_rs2" has lines with following column values
      | variable_name-0           | variable_value-1 |
      | inSubQueryTransformToJoin | false            |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DinSubQueryTransformToJoin=/d
    $a -DinSubQueryTransformToJoin=False
    """
    Then restart dble in "dble-1" success
        Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs3"
      | sql             |
      | show @@sysparam |
    Then check resultset "join_rs3" has lines with following column values
      | PARAM_NAME-0              | PARAM_VALUE-1 |
      | inSubQueryTransformToJoin | false         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                             | db               |
      | conn_2 | True    | select variable_name, variable_value from dble_variables where variable_name like '%inSubQueryTransformToJoin%' | dble_information |
    Then check resultset "join_rs4" has lines with following column values
      | variable_name-0           | variable_value-1 |
      | inSubQueryTransformToJoin | false            |

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <singleTable name="single_t1"  shardingNode="dn1" />
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                             | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1;drop table if exists no_sharding_t1;drop table if exists single_t1                           | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1 (id int, name char(10), age int)                                                                     | success | schema1 |
      | conn_1 | False   | create table no_sharding_t1 (id int, nick varchar(10), code int)                                                                | success | schema1 |
      | conn_1 | False   | create table single_t1(id int, code int)                                                                                        | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4),(5,'aa',15),(6,'bb',16),(7,'cc',17),(8,'dd',18)        | success | schema1 |
      | conn_1 | False   | insert into no_sharding_t1 values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4),(5,'a',15),(6,'a',16),(7,'b',17),(8,'b',18)           | success | schema1 |
      | conn_1 | False   | insert into single_t1 values (1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8)                                                    | success | schema1 |

    # Columns contain in-subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain select a.id, select max(b.id) from no_sharding_t1 b where b.id in (select distinct d.id from single_t1 d) as name FROM sharding_4_t1 a ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn1_0              | BASE SQL              | select  distinct `d`.`id` as `autoalias_scalar` from  `single_t1` `d`                                                          |
      | merge_1            | MERGE                 | dn1_0                                                                                                                          |
      | in_sub_query_1     | IN_SUB_QUERY          | merge_1                                                                                                                        |
      | dn5_0              | BASE SQL(May No Need) | in_sub_query_1; select max(b.id) as `_$MAX$_rpda_0` from  `no_sharding_t1` `b` where `b`.`id` in ('{NEED_TO_REPLACE}') LIMIT 2 |
      | merge_2            | MERGE                 | dn5_0                                                                                                                          |
      | aggregate_1        | AGGREGATE             | merge_2                                                                                                                        |
      | limit_1            | LIMIT                 | aggregate_1                                                                                                                    |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                        |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                            |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                            |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                            |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                            |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                     |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                              |
    # Columns contain = subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs6"
      | conn   | toClose | sql                                                                                                                                                     | expect  | db      |
      | conn_1 | False   | explain select a.id, select max(b.id) from no_sharding_t1 b where b.id = (select max(d.id) from single_t1 d) as name FROM sharding_4_t1 a ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs6" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn1_0              | BASE SQL              | select max(d.id) as `autoalias_scalar` from  `single_t1` `d` limit 0,2                                                          |
      | merge_1            | MERGE                 | dn1_0                                                                                                                           |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                         |
      | dn5_0              | BASE SQL(May No Need) | scalar_sub_query_1; select max(b.id) as `_$MAX$_rpda_0` from  `no_sharding_t1` `b` where `b`.`id` = '{NEED_TO_REPLACE}' LIMIT 2 |
      | merge_2            | MERGE                 | dn5_0                                                                                                                           |
      | aggregate_1        | AGGREGATE             | merge_2                                                                                                                         |
      | limit_1            | LIMIT                 | aggregate_1                                                                                                                     |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                         |
      | scalar_sub_query_2 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                 |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                             |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                             |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                             |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                             |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                      |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                               |

    # where contain in-subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs7"
      | conn   | toClose | sql                                                                                                     | expect  | db      |
      | conn_1 | False   | explain SELECT a.* FROM sharding_4_t1 a WHERE a.id in (SELECT b.id FROM no_sharding_t1 b) ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs7" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0             | BASE SQL              | select  distinct `b`.`id` as `autoalias_scalar` from  `no_sharding_t1` `b`                                                                   |
      | merge_1           | MERGE                 | dn5_0                                                                                                                                        |
      | in_sub_query_1    | IN_SUB_QUERY          | merge_1                                                                                                                                      |
      | dn1_0             | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`id` ASC |
      | dn2_0             | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`id` ASC |
      | dn3_0             | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`id` ASC |
      | dn4_0             | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                            |
    # where contain = subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs8"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain SELECT a.* FROM sharding_4_t1 a WHERE a.id =(SELECT b.id FROM no_sharding_t1 b WHERE b.id =1 limit 1) ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs8" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select `b`.`id` as `autoalias_scalar` from  `no_sharding_t1` `b` where `b`.`id` = 1 limit 0,1                                                 |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                         |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                       |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                    |
      | shuffle_field_1    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                             |

    # join contain in-subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs9"
      | conn   | toClose | sql                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain SELECT c.* FROM sharding_4_t1 c JOIN single_t1 b on (SELECT a.id FROM single_t1 a WHERE a.id IN ( SELECT cc.id FROM no_sharding_t1 cc limit 1)) = c.id order by c.id | success | schema1 |
    Then check resultset "join_rs9" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select  distinct `cc`.`id` as `autoalias_scalar` from  `no_sharding_t1` `cc` limit 0,1                                                        |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                         |
      | in_sub_query_1     | IN_SUB_QUERY          | merge_1                                                                                                                                       |
      | dn1_0              | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id` as `autoalias_scalar` from  `single_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') LIMIT 2                   |
      | merge_2            | MERGE                 | dn1_0                                                                                                                                         |
      | limit_1            | LIMIT                 | merge_2                                                                                                                                       |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                                       |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                               |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_1; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                    |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                             |
      | dn1_2              | BASE SQL(May No Need) | scalar_sub_query_1; select `b`.`id`,`b`.`code` from  `single_t1` `b`                                                                          |
      | merge_3            | MERGE                 | dn1_2                                                                                                                                         |
      | join_1             | JOIN                  | shuffle_field_2; merge_3                                                                                                                      |
      | shuffle_field_3    | SHUFFLE_FIELD         | join_1                                                                                                                                        |
    # join contain = subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs10"
      | conn   | toClose | sql                                                                                                                                                                        | expect  | db      |
      | conn_1 | False   | explain SELECT c.* FROM sharding_4_t1 c JOIN single_t1 b on (SELECT a.id FROM single_t1 a WHERE a.id =( SELECT cc.id FROM no_sharding_t1 cc limit 1)) = c.id order by c.id | success | schema1 |
    Then check resultset "join_rs10" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select `cc`.`id` as `autoalias_scalar` from  `no_sharding_t1` `cc` limit 0,1                                                                  |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                         |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                       |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` as `autoalias_scalar` from  `single_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' LIMIT 2                  |
      | merge_2            | MERGE                 | dn1_0                                                                                                                                         |
      | limit_1            | LIMIT                 | merge_2                                                                                                                                       |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                                       |
      | scalar_sub_query_2 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                               |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_2; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                    |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                             |
      | dn1_2              | BASE SQL(May No Need) | scalar_sub_query_2; select `b`.`id`,`b`.`code` from  `single_t1` `b`                                                                          |
      | merge_3            | MERGE                 | dn1_2                                                                                                                                         |
      | join_1             | JOIN                  | shuffle_field_2; merge_3                                                                                                                      |
      | shuffle_field_3    | SHUFFLE_FIELD         | join_1                                                                                                                                        |

    # order by contain in-subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain SELECT a.* FROM sharding_4_t1 a WHERE a.age>5 ORDER BY (select c.id from no_sharding_t1 c where 1=1 and c.id in (select d.id from single_t1 d) order by c.id limit 1) | success | schema1 |
    Then check resultset "join_rs11" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select `c`.`id` as `autoalias_scalar` from  `no_sharding_t1` `c` where  ( 1 = 1 AND 1 = 0) ORDER BY autoalias_scalar ASC LIMIT 1        |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                   |
      | limit_1            | LIMIT                 | merge_1                                                                                                                                 |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                                 |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                         |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                              |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                       |
    # order by contain = subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain select a.* from sharding_4_t1 a where a.age>5 order by (select c.id from no_sharding_t1 c where 1=1 and c.id=(select max(d.id) from single_t1 d) order by c.id limit 1) | success | schema1 |
    Then check resultset "join_rs12" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select `c`.`id` as `autoalias_scalar` from  `no_sharding_t1` `c` where  ( 1 = 1 AND NULL) ORDER BY autoalias_scalar ASC LIMIT 1         |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                   |
      | limit_1            | LIMIT                 | merge_1                                                                                                                                 |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                                 |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                         |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                              |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                       |

    # having contain in-subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain select a.id from sharding_4_t1 a where 1=1 group by a.id having a.id in (select b.id from single_t1 b where b.code>5) order by a.id | success | schema1 |
    Then check resultset "join_rs13" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn1_0             | BASE SQL              | select  distinct `b`.`id` as `autoalias_scalar` from  `single_t1` `b` where `b`.`code` > 5                                                |
      | merge_1           | MERGE                 | dn1_0                                                                                                                                     |
      | in_sub_query_1    | IN_SUB_QUERY          | merge_1                                                                                                                                   |
      | dn1_1             | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') GROUP BY `a`.`id` ORDER BY `a`.`id` ASC |
      | dn2_0             | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') GROUP BY `a`.`id` ORDER BY `a`.`id` ASC |
      | dn3_0             | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') GROUP BY `a`.`id` ORDER BY `a`.`id` ASC |
      | dn4_0             | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') GROUP BY `a`.`id` ORDER BY `a`.`id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                |
      | aggregate_1       | AGGREGATE             | merge_and_order_1                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | aggregate_1                                                                                                                               |
    # having contain = subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain select a.id from sharding_4_t1 a where 1=1 group by a.id having a.id=(select max(b.id) from single_t1 b where b.code>5) order by a.id | success | schema1 |
    Then check resultset "join_rs14" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn1_0              | BASE SQL              | select max(b.id) as `autoalias_scalar` from  `single_t1` `b` where `b`.`code` > 5 limit 0,2                                                |
      | merge_1            | MERGE                 | dn1_0                                                                                                                                      |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                    |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' GROUP BY `a`.`id` ORDER BY `a`.`id` ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' GROUP BY `a`.`id` ORDER BY `a`.`id` ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' GROUP BY `a`.`id` ORDER BY `a`.`id` ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' GROUP BY `a`.`id` ORDER BY `a`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                 |
      | aggregate_1        | AGGREGATE             | merge_and_order_1                                                                                                                          |
      | shuffle_field_1    | SHUFFLE_FIELD         | aggregate_1                                                                                                                                |

    # Nested subquery contain in-subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs15"
      | conn   | toClose | sql                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain SELECT a.* FROM sharding_4_t1 a WHERE a.id IN (select b.id from single_t1 b where 1=1 and b.id in (SELECT c.id FROM no_sharding_t1 c)) ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs15" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn5_0             | BASE SQL              | select  distinct `c`.`id` as `autoalias_scalar` from  `no_sharding_t1` `c`                                                                   |
      | merge_1           | MERGE                 | dn5_0                                                                                                                                        |
      | in_sub_query_1    | IN_SUB_QUERY          | merge_1                                                                                                                                      |
      | dn1_0             | BASE SQL(May No Need) | in_sub_query_1; select DISTINCT `b`.`id` as `autoalias_scalar` from  `single_t1` `b` where  ( 1 = 1 AND `b`.`id` in ('{NEED_TO_REPLACE}'))   |
      | merge_2           | MERGE                 | dn1_0                                                                                                                                        |
      | distinct_1        | DISTINCT              | merge_2                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD         | distinct_1                                                                                                                                   |
      | in_sub_query_2    | IN_SUB_QUERY          | shuffle_field_1                                                                                                                              |
      | dn1_1             | BASE SQL(May No Need) | in_sub_query_2; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`id` ASC |
      | dn2_0             | BASE SQL(May No Need) | in_sub_query_2; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`id` ASC |
      | dn3_0             | BASE SQL(May No Need) | in_sub_query_2; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`id` ASC |
      | dn4_0             | BASE SQL(May No Need) | in_sub_query_2; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                            |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs16"
      | conn   | toClose | sql                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain SELECT a.* FROM sharding_4_t1 a WHERE a.id in (select b.id from single_t1 b where 1=1 and b.id =(SELECT max(c.id) FROM no_sharding_t1 c where c.code=1)) ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs16" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select max(c.id) as `autoalias_scalar` from  `no_sharding_t1` `c` where `c`.`code` = 1 limit 0,2                                             |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                        |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                      |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select DISTINCT `b`.`id` as `autoalias_scalar` from  `single_t1` `b` where  ( 1 = 1 AND `b`.`id` = '{NEED_TO_REPLACE}')  |
      | merge_2            | MERGE                 | dn1_0                                                                                                                                        |
      | distinct_1         | DISTINCT              | merge_2                                                                                                                                      |
      | shuffle_field_1    | SHUFFLE_FIELD         | distinct_1                                                                                                                                   |
      | in_sub_query_1     | IN_SUB_QUERY          | shuffle_field_1                                                                                                                              |
      | dn1_1              | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`id` ASC |
      | dn2_0              | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`id` ASC |
      | dn3_0              | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`id` ASC |
      | dn4_0              | BASE SQL(May No Need) | in_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                   |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                            |
    # Nested subquery contain = subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs17"
      | conn   | toClose | sql                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain SELECT a.* FROM sharding_4_t1 a WHERE a.id =(select max(b.id) from single_t1 b where 1=1 and b.id =(SELECT max(c.id) FROM no_sharding_t1 c where c.code=1)) ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs17" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select max(c.id) as `autoalias_scalar` from  `no_sharding_t1` `c` where `c`.`code` = 1 limit 0,2                                              |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                         |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                       |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select max(b.id) as `_$MAX$_rpda_0` from  `single_t1` `b` where  ( 1 = 1 AND `b`.`id` = '{NEED_TO_REPLACE}') LIMIT 2      |
      | merge_2            | MERGE                 | dn1_0                                                                                                                                         |
      | aggregate_1        | AGGREGATE             | merge_2                                                                                                                                       |
      | limit_1            | LIMIT                 | aggregate_1                                                                                                                                   |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                                       |
      | scalar_sub_query_2 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                               |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                    |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                             |

    # = any() subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs18"
      | conn   | toClose | sql                                                                                                          | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where id = any(select id from single_t1 where code=1) order by name desc | success | schema1 |
    Then check resultset "join_rs18" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn1_0             | BASE SQL              | select  distinct `single_t1`.`id` as `autoalias_scalar` from  `single_t1` where `single_t1`.`code` = 1                                                                                                  |
      | merge_1           | MERGE                 | dn1_0                                                                                                                                                                                                   |
      | in_sub_query_1    | IN_SUB_QUERY          | merge_1                                                                                                                                                                                                 |
      | dn1_1             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | dn2_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | dn3_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | dn4_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                       |
    # other any() subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs19"
      | conn   | toClose | sql                                                                                                           | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where id <> any(select id from single_t1 where code=1) order by name desc | success | schema1 |
    Then check resultset "join_rs19" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1                | SQL/REF-2 |
      | dn1_0               | BASE SQL              | select `single_t1`.`id` as `autoalias_scalar` from  `single_t1` where `single_t1`.`code` = 1                                                                                                                     |
      | merge_1             | MERGE                 | dn1_0                                                                                                                                                                                                            |
      | all_any_sub_query_1 | ALL_ANY_SUB_QUERY     | merge_1                                                                                                                                                                                                          |
      | dn1_1               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn2_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn3_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn4_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | merge_and_order_1   | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                                                                                       |
      | shuffle_field_1     | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                |

    # = some() subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs20"
      | conn   | toClose | sql                                                                                                                | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where id = some(select id from no_sharding_t1 where code=1) order by name desc | success | schema1 |
    Then check resultset "join_rs20" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn5_0             | BASE SQL              | select  distinct `no_sharding_t1`.`id` as `autoalias_scalar` from  `no_sharding_t1` where `no_sharding_t1`.`code` = 1                                                                                   |
      | merge_1           | MERGE                 | dn5_0                                                                                                                                                                                                   |
      | in_sub_query_1    | IN_SUB_QUERY          | merge_1                                                                                                                                                                                                 |
      | dn1_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | dn2_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | dn3_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | dn4_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                       |
    # other some() subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where id != some(select id from no_sharding_t1 where code=1) order by name desc | success | schema1 |
    Then check resultset "join_rs21" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1                | SQL/REF-2 |
      | dn5_0               | BASE SQL              | select `no_sharding_t1`.`id` as `autoalias_scalar` from  `no_sharding_t1` where `no_sharding_t1`.`code` = 1                                                                                                      |
      | merge_1             | MERGE                 | dn5_0                                                                                                                                                                                                            |
      | all_any_sub_query_1 | ALL_ANY_SUB_QUERY     | merge_1                                                                                                                                                                                                          |
      | dn1_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn2_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn3_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn4_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | merge_and_order_1   | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                       |
      | shuffle_field_1     | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                |

    # = all() subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where age = all(select code from no_sharding_t1 where code>2) order by name desc | success | schema1 |
    Then check resultset "join_rs22" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1                | SQL/REF-2 |
      | dn5_0               | BASE SQL              | select `no_sharding_t1`.`code` as `autoalias_scalar` from  `no_sharding_t1` where `no_sharding_t1`.`code` > 2                                                                                                    |
      | merge_1             | MERGE                 | dn5_0                                                                                                                                                                                                            |
      | all_any_sub_query_1 | ALL_ANY_SUB_QUERY     | merge_1                                                                                                                                                                                                          |
      | dn1_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` = '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn2_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` = '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn3_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` = '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn4_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` = '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | merge_and_order_1   | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                       |
      | shuffle_field_1     | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                |
    # other all() subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where age <> all(select code from no_sharding_t1 where code>2) order by name desc | success | schema1 |
    Then check resultset "join_rs23" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn5_0             | BASE SQL              | select  distinct `no_sharding_t1`.`code` as `autoalias_scalar` from  `no_sharding_t1` where `no_sharding_t1`.`code` > 2                                                                                       |
      | merge_1           | MERGE                 | dn5_0                                                                                                                                                                                                         |
      | in_sub_query_1    | IN_SUB_QUERY          | merge_1                                                                                                                                                                                                       |
      | dn1_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` not  in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | dn2_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` not  in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | dn3_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` not  in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | dn4_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` not  in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                             |

    # not subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                               | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where not id=(select max(id) from no_sharding_t1) order by id | success | schema1 |
    Then check resultset "join_rs24" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select max(id) as `autoalias_scalar` from  `no_sharding_t1` limit 0,2                                                                                                                                         |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                                                                                         |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                                                                                       |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where  ( NOT `sharding_4_t1`.`id` = '{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`id` ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where  ( NOT `sharding_4_t1`.`id` = '{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`id` ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where  ( NOT `sharding_4_t1`.`id` = '{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`id` ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where  ( NOT `sharding_4_t1`.`id` = '{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                    |
      | shuffle_field_1    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                             |

    # exists subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs25"
      | conn   | toClose | sql                                                                                                              | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where exists (select id from no_sharding_t1 where code=1) order by name desc | success | schema1 |
    Then check resultset "join_rs25" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select `no_sharding_t1`.`id` as `autoalias_scalar`,1 from  `no_sharding_t1` where `no_sharding_t1`.`code` = 1 limit 0,1                                             |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                                               |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                                             |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where 1 = 1 ORDER BY `sharding_4_t1`.`name` DESC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where 1 = 1 ORDER BY `sharding_4_t1`.`name` DESC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where 1 = 1 ORDER BY `sharding_4_t1`.`name` DESC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where 1 = 1 ORDER BY `sharding_4_t1`.`name` DESC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                          |
      | shuffle_field_1    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                  | expect  | db      |
      # Columns contain in-subquery
      | conn_1 | False   | select a.id, select max(b.id) from no_sharding_t1 b where b.id in (select distinct d.id from single_t1 d) as name FROM sharding_4_t1 a ORDER BY a.id | has{((1,8),(2,8),(3,8),(4,8),(5,8),(6,8),(7,8),(8,8))} | schema1 |
      # Columns contain = subquery
      | conn_1 | False   | select a.id, select max(b.id) from no_sharding_t1 b where b.id = (select max(d.id) from single_t1 d) as name FROM sharding_4_t1 a ORDER BY a.id      | has{((1,8),(2,8),(3,8),(4,8),(5,8),(6,8),(7,8),(8,8))} | schema1 |
      # where contain in-subquery
      | conn_1 | False   | SELECT a.* FROM sharding_4_t1 a WHERE a.id in (SELECT b.id FROM no_sharding_t1 b) ORDER BY a.id | has{((1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4),(5,'aa',15),(6,'bb',16),(7,'cc',17),(8,'dd',18))} | schema1 |
      # where contain = subquery
      | conn_1 | False   | SELECT a.* FROM sharding_4_t1 a WHERE a.id =(SELECT b.id FROM no_sharding_t1 b WHERE b.id =1 limit 1) ORDER BY a.id | has{((1,'a',1))} | schema1 |
      # join contain in-subquery
      | conn_1 | False   | SELECT c.* FROM sharding_4_t1 c JOIN single_t1 b on (SELECT a.id FROM single_t1 a WHERE a.id IN ( SELECT cc.id FROM no_sharding_t1 cc limit 1)) = c.id order by c.id | has{((1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),)} | schema1 |
      # join contain = subquery
      | conn_1 | False   | SELECT c.* FROM sharding_4_t1 c JOIN single_t1 b on (SELECT a.id FROM single_t1 a WHERE a.id =( SELECT cc.id FROM no_sharding_t1 cc limit 1)) = c.id order by c.id | has{((1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),)} | schema1 |
      # order by contain in-subquery
      | conn_1 | False   | SELECT a.* FROM sharding_4_t1 a WHERE a.age>5 ORDER BY (select c.id from no_sharding_t1 c where 1=1 and c.id in (select d.id from single_t1 d) order by c.id limit 1) | has{((5,'aa',15),(6,'bb',16),(7,'cc',17),(8,'dd',18))} | schema1 |
      # order by contain = subquery
      | conn_1 | False   | select a.* from sharding_4_t1 a where a.age>5 order by (select c.id from no_sharding_t1 c where 1=1 and c.id=(select max(d.id) from single_t1 d) order by c.id limit 1) | has{((5,'aa',15),(6,'bb',16),(7,'cc',17),(8,'dd',18))} | schema1 |
      # having contain in-subquery
      | conn_1 | False   | select a.id from sharding_4_t1 a where 1=1 group by a.id having a.id in (select b.id from single_t1 b where b.code>5) order by a.id | has{((6,),(7,),(8,))} | schema1 |
      # having contain = subquery
      | conn_1 | False   | select a.id from sharding_4_t1 a where 1=1 group by a.id having a.id=(select max(b.id) from single_t1 b where b.code>5) order by a.id | has{((8,))} | schema1 |
      # Nested subquery contain in-subquery
      | conn_1 | False   | SELECT a.* FROM sharding_4_t1 a WHERE a.id IN (select b.id from single_t1 b where 1=1 and b.id in (SELECT c.id FROM no_sharding_t1 c)) ORDER BY a.id | has{((1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4),(5,'aa',15),(6,'bb',16),(7,'cc',17),(8,'dd',18))} | schema1 |
      | conn_1 | False   | SELECT a.* FROM sharding_4_t1 a WHERE a.id in (select b.id from single_t1 b where 1=1 and b.id =(SELECT max(c.id) FROM no_sharding_t1 c where c.code=1)) ORDER BY a.id | has{((1,'a',1))} | schema1 |
      # Nested subquery contain = subquery
      | conn_1 | False   | SELECT a.* FROM sharding_4_t1 a WHERE a.id =(select max(b.id) from single_t1 b where 1=1 and b.id =(SELECT max(c.id) FROM no_sharding_t1 c where c.code=1)) ORDER BY a.id | has{((1,'a',1))} | schema1 |
      # = any() subquery
      | conn_1 | False   | select * from sharding_4_t1 where id = any(select id from single_t1 where code=1) order by name desc | has{((1,'a',1))} | schema1 |
      # other any() subquery
      | conn_1 | False   | select * from sharding_4_t1 where id <> any(select id from single_t1 where code=1) order by name desc | has{((8,'dd',18), (4,'d',4), (7,'cc',17), (3,'c',3), (6,'bb',16), (2,'b',2), (5,'aa',15))} | schema1 |
      # = some() subquery
      | conn_1 | False   | select * from sharding_4_t1 where id = some(select id from no_sharding_t1 where code=1) order by name desc | has{((1,'a',1))} | schema1 |
      # other some() subquery
      | conn_1 | False   | select * from sharding_4_t1 where id != some(select id from no_sharding_t1 where code=1) order by name desc | has{((8,'dd',18), (4,'d',4), (7,'cc',17), (3,'c',3), (6,'bb',16), (2,'b',2), (5,'aa',15))} | schema1 |
      # = all() subquery
      | conn_1 | False   | select * from sharding_4_t1 where age = all(select code from no_sharding_t1 where code>2) order by name desc | success | schema1 |
      # other all() subquery
      | conn_1 | False   | select * from sharding_4_t1 where age <> all(select code from no_sharding_t1 where code>2) order by name desc | has{((1,'a',1),(2,'b',2))} | schema1 |
      # not subquery
      | conn_1 | False   | select * from sharding_4_t1 where not id=(select max(id) from no_sharding_t1) order by id                     | has{((1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4),(5,'aa',15),(6,'bb',16),(7,'cc',17))} | schema1 |
      # exists subquery
      | conn_1 | False   | select * from sharding_4_t1 where exists (select id from no_sharding_t1 where code=1) order by name desc      | has{((8,'dd',18),(4,'d',4),(7,'cc',17),(3,'c',3),(6,'bb',16),(2,'b',2),(5,'aa',15),(1,'a',1))} | schema1 |
      | conn_1 | True    | drop table if exists sharding_4_t1;drop table if exists no_sharding_t1;drop table if exists single_t1         | success | schema1 |


  Scenario: check inSubQueryTransformToJoin in bootstrap.cnf - valid values : true #3
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DinSubQueryTransformToJoin=/d
    $a -DinSubQueryTransformToJoin=true
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | sql             |
      | show @@sysparam |
    Then check resultset "join_rs1" has lines with following column values
      | PARAM_NAME-0              | PARAM_VALUE-1 |
      | inSubQueryTransformToJoin | true          |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                      | db               |
      | conn_0 | True    | select variable_name, variable_value from dble_variables where variable_name='inSubQueryTransformToJoin' | dble_information |
    Then check resultset "join_rs2" has lines with following column values
      | variable_name-0           | variable_value-1 |
      | inSubQueryTransformToJoin | true             |

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <singleTable name="single_t1"  shardingNode="dn1" />
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                             | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1;drop table if exists no_sharding_t1;drop table if exists single_t1                           | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1 (id int, name char(10), age int)                                                                     | success | schema1 |
      | conn_1 | False   | create table no_sharding_t1 (id int, nick varchar(10), code int)                                                                | success | schema1 |
      | conn_1 | False   | create table single_t1(id int, code int)                                                                                        | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4),(5,'aa',15),(6,'bb',16),(7,'cc',17),(8,'dd',18)        | success | schema1 |
      | conn_1 | False   | insert into no_sharding_t1 values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4),(5,'a',15),(6,'a',16),(7,'b',17),(8,'b',18)           | success | schema1 |
      | conn_1 | False   | insert into single_t1 values (1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8)                                                    | success | schema1 |

    # Columns contain in-subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain select a.id, select max(b.id) from no_sharding_t1 b where b.id in (select distinct d.id from single_t1 d) as name FROM sharding_4_t1 a ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select `b`.`id` from  `no_sharding_t1` `b`                                                                                                       |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                            |
      | shuffle_field_1    | SHUFFLE_FIELD         | merge_1                                                                                                                                          |
      | dn1_0              | BASE SQL              | select `autoalias_single_t1`.`autoalias_scalar` from (select  distinct `d`.`id` as `autoalias_scalar` from  `single_t1` `d`) autoalias_single_t1 |
      | merge_2            | MERGE                 | dn1_0                                                                                                                                            |
      | join_1             | JOIN                  | shuffle_field_1; merge_2                                                                                                                         |
      | where_filter_1     | WHERE_FILTER          | join_1                                                                                                                                           |
      | aggregate_1        | AGGREGATE             | where_filter_1                                                                                                                                   |
      | limit_1            | LIMIT                 | aggregate_1                                                                                                                                      |
      | shuffle_field_2    | SHUFFLE_FIELD         | limit_1                                                                                                                                          |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | shuffle_field_2                                                                                                                                  |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                              |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                              |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                              |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                              |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                       |
      | shuffle_field_3    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                |
    # Columns contain = subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs6"
      | conn   | toClose | sql                                                                                                                                                     | expect  | db      |
      | conn_1 | False   | explain select a.id, select max(b.id) from no_sharding_t1 b where b.id = (select max(d.id) from single_t1 d) as name FROM sharding_4_t1 a ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs6" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn1_0              | BASE SQL              | select max(d.id) as `autoalias_scalar` from  `single_t1` `d` limit 0,2                                                          |
      | merge_1            | MERGE                 | dn1_0                                                                                                                           |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                         |
      | dn5_0              | BASE SQL(May No Need) | scalar_sub_query_1; select max(b.id) as `_$MAX$_rpda_0` from  `no_sharding_t1` `b` where `b`.`id` = '{NEED_TO_REPLACE}' LIMIT 2 |
      | merge_2            | MERGE                 | dn5_0                                                                                                                           |
      | aggregate_1        | AGGREGATE             | merge_2                                                                                                                         |
      | limit_1            | LIMIT                 | aggregate_1                                                                                                                     |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                         |
      | scalar_sub_query_2 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                 |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                             |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                             |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                             |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                             |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                      |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                               |

    # where contain in-subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs7"
      | conn   | toClose | sql                                                                                                     | expect  | db      |
      | conn_1 | False   | explain SELECT a.* FROM sharding_4_t1 a WHERE a.id in (SELECT b.id FROM no_sharding_t1 b) ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs7" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                                                                                                                                     |
      | dn2_0             | BASE SQL        | select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                                                                                                                                     |
      | dn3_0             | BASE SQL        | select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                                                                                                                                     |
      | dn4_0             | BASE SQL        | select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                                                                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                        |
      | dn5_0             | BASE SQL        | select `autoalias_no_sharding_t1`.`autoalias_scalar` from (select  distinct `b`.`id` as `autoalias_scalar` from  `no_sharding_t1` `b` order by autoalias_scalar ASC) autoalias_no_sharding_t1 order by `autoalias_no_sharding_t1`.`autoalias_scalar` ASC |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                                                    |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                                                                   |
    # where contain = subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs8"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain SELECT a.* FROM sharding_4_t1 a WHERE a.id =(SELECT b.id FROM no_sharding_t1 b WHERE b.id =1 limit 1) ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs8" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select `b`.`id` as `autoalias_scalar` from  `no_sharding_t1` `b` where `b`.`id` = 1 limit 0,1                                                 |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                         |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                       |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                    |
      | shuffle_field_1    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                             |

    # join contain in-subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs9"
      | conn   | toClose | sql                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain SELECT c.* FROM sharding_4_t1 c JOIN single_t1 b on (SELECT a.id FROM single_t1 a WHERE a.id IN ( SELECT cc.id FROM no_sharding_t1 cc limit 1)) = c.id order by c.id | success | schema1 |
    Then check resultset "join_rs9" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn1_0              | BASE SQL              | select `a`.`id` from  `single_t1` `a`                                                                                                                                       |
      | merge_1            | MERGE                 | dn1_0                                                                                                                                                                       |
      | shuffle_field_1    | SHUFFLE_FIELD         | merge_1                                                                                                                                                                     |
      | order_1            | ORDER                 | shuffle_field_1                                                                                                                                                             |
      | dn5_0              | BASE SQL              | select `autoalias_no_sharding_t1`.`autoalias_scalar` from (select  distinct `cc`.`id` as `autoalias_scalar` from  `no_sharding_t1` `cc` limit 0,1) autoalias_no_sharding_t1 |
      | merge_2            | MERGE                 | dn5_0                                                                                                                                                                       |
      | order_2            | ORDER                 | merge_2                                                                                                                                                                     |
      | join_1             | JOIN                  | order_1; order_2                                                                                                                                                            |
      | where_filter_1     | WHERE_FILTER          | join_1                                                                                                                                                                      |
      | limit_1            | LIMIT                 | where_filter_1                                                                                                                                                              |
      | shuffle_field_2    | SHUFFLE_FIELD         | limit_1                                                                                                                                                                     |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | shuffle_field_2                                                                                                                                                             |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_1; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC                               |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC                               |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC                               |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC                               |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                                                  |
      | shuffle_field_3    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                           |
      | dn1_2              | BASE SQL(May No Need) | scalar_sub_query_1; select `b`.`id`,`b`.`code` from  `single_t1` `b`                                                                                                        |
      | merge_3            | MERGE                 | dn1_2                                                                                                                                                                       |
      | join_2             | JOIN                  | shuffle_field_3; merge_3                                                                                                                                                    |
      | shuffle_field_4    | SHUFFLE_FIELD         | join_2                                                                                                                                                                      |
    # join contain = subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs10"
      | conn   | toClose | sql                                                                                                                                                                        | expect  | db      |
      | conn_1 | False   | explain SELECT c.* FROM sharding_4_t1 c JOIN single_t1 b on (SELECT a.id FROM single_t1 a WHERE a.id =( SELECT cc.id FROM no_sharding_t1 cc limit 1)) = c.id order by c.id | success | schema1 |
    Then check resultset "join_rs10" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select `cc`.`id` as `autoalias_scalar` from  `no_sharding_t1` `cc` limit 0,1                                                                  |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                         |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                       |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` as `autoalias_scalar` from  `single_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' LIMIT 2                  |
      | merge_2            | MERGE                 | dn1_0                                                                                                                                         |
      | limit_1            | LIMIT                 | merge_2                                                                                                                                       |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                                       |
      | scalar_sub_query_2 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                               |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_2; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `c`.`id`,`c`.`name`,`c`.`age` from  `sharding_4_t1` `c` where '{NEED_TO_REPLACE}' = `c`.`id` ORDER BY `c`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                    |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                             |
      | dn1_2              | BASE SQL(May No Need) | scalar_sub_query_2; select `b`.`id`,`b`.`code` from  `single_t1` `b`                                                                          |
      | merge_3            | MERGE                 | dn1_2                                                                                                                                         |
      | join_1             | JOIN                  | shuffle_field_2; merge_3                                                                                                                      |
      | shuffle_field_3    | SHUFFLE_FIELD         | join_1                                                                                                                                        |

    # order by contain in-subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain SELECT a.* FROM sharding_4_t1 a WHERE a.age>5 ORDER BY (select c.id from no_sharding_t1 c where 1=1 and c.id in (select d.id from single_t1 d) order by c.id limit 1) | success | schema1 |
    Then check resultset "join_rs11" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select `c`.`id` as `autoalias_scalar` from  `no_sharding_t1` `c` where  ( 1 = 1 AND 1 = 0) ORDER BY autoalias_scalar ASC LIMIT 1        |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                   |
      | limit_1            | LIMIT                 | merge_1                                                                                                                                 |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                                 |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                         |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                              |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                       |
    # order by contain = subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain select a.* from sharding_4_t1 a where a.age>5 order by (select c.id from no_sharding_t1 c where 1=1 and c.id=(select max(d.id) from single_t1 d) order by c.id limit 1) | success | schema1 |
    Then check resultset "join_rs12" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select `c`.`id` as `autoalias_scalar` from  `no_sharding_t1` `c` where  ( 1 = 1 AND NULL) ORDER BY autoalias_scalar ASC LIMIT 1         |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                   |
      | limit_1            | LIMIT                 | merge_1                                                                                                                                 |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                                 |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                         |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`age` > 5 ORDER BY '{NEED_TO_REPLACE}' ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                              |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                       |

    # having contain in-subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain select a.id from sharding_4_t1 a where 1=1 group by a.id having a.id in (select b.id from single_t1 b where b.code>5) order by a.id | success | schema1 |
    Then check resultset "join_rs13" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                                                                                                                                                           |
      | dn2_0             | BASE SQL        | select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                                                                                                                                                           |
      | dn3_0             | BASE SQL        | select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                                                                                                                                                           |
      | dn4_0             | BASE SQL        | select `a`.`id` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                                                                                                                                                           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                         |
      | dn1_1             | BASE SQL        | select `autoalias_single_t1`.`autoalias_scalar` from (select  distinct `b`.`id` as `autoalias_scalar` from  `single_t1` `b` where `b`.`code` > 5 order by autoalias_scalar ASC) autoalias_single_t1 order by `autoalias_single_t1`.`autoalias_scalar` ASC |
      | merge_1           | MERGE           | dn1_1                                                                                                                                                                                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                  |
      | aggregate_1       | AGGREGATE       | join_1                                                                                                                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | aggregate_1                                                                                                                                                                                                                                               |

    # having contain = subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain select a.id from sharding_4_t1 a where 1=1 group by a.id having a.id=(select max(b.id) from single_t1 b where b.code>5) order by a.id | success | schema1 |
    Then check resultset "join_rs14" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn1_0              | BASE SQL              | select max(b.id) as `autoalias_scalar` from  `single_t1` `b` where `b`.`code` > 5 limit 0,2                                                |
      | merge_1            | MERGE                 | dn1_0                                                                                                                                      |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                    |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' GROUP BY `a`.`id` ORDER BY `a`.`id` ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' GROUP BY `a`.`id` ORDER BY `a`.`id` ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' GROUP BY `a`.`id` ORDER BY `a`.`id` ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `a`.`id` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' GROUP BY `a`.`id` ORDER BY `a`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                 |
      | aggregate_1        | AGGREGATE             | merge_and_order_1                                                                                                                          |
      | shuffle_field_1    | SHUFFLE_FIELD         | aggregate_1                                                                                                                                |

    # Nested subquery contain in-subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs15"
      | conn   | toClose | sql                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain SELECT a.* FROM sharding_4_t1 a WHERE a.id IN (select b.id from single_t1 b where 1=1 and b.id in (SELECT c.id FROM no_sharding_t1 c)) ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs15" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn1_0                      | BASE SQL                 | select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                                                                                                                                     |
      | dn2_0                      | BASE SQL                 | select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                                                                                                                                     |
      | dn3_0                      | BASE SQL                 | select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                                                                                                                                     |
      | dn4_0                      | BASE SQL                 | select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                                                                                                                                     |
      | merge_and_order_1          | MERGE_AND_ORDER          | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                                                               |
      | shuffle_field_1            | SHUFFLE_FIELD            | merge_and_order_1                                                                                                                                                                                                                                        |
      | dn1_1                      | BASE SQL                 | select `b`.`id` from  `single_t1` `b` ORDER BY `b`.`id` ASC                                                                                                                                                                                   |
      | merge_1                    | MERGE                    | dn1_1                                                                                                                                                                                                                                                    |
      | shuffle_field_3            | SHUFFLE_FIELD            | merge_1                                                                                                                                                                                                                                                  |
      | dn5_0                      | BASE SQL                 | select `autoalias_no_sharding_t1`.`autoalias_scalar` from (select  distinct `c`.`id` as `autoalias_scalar` from  `no_sharding_t1` `c` order by autoalias_scalar ASC) autoalias_no_sharding_t1 order by `autoalias_no_sharding_t1`.`autoalias_scalar` ASC |
      | merge_2                    | MERGE                    | dn5_0                                                                                                                                                                                                                                                    |
      | join_2                     | JOIN                     | shuffle_field_3; merge_2                                                                                                                                                                                                                                 |
      | distinct_1                 | DISTINCT                 | join_2                                                                                                                                                                                                                                                   |
      | shuffle_field_4            | SHUFFLE_FIELD            | distinct_1                                                                                                                                                                                                                                               |
      | rename_derived_sub_query_1 | RENAME_DERIVED_SUB_QUERY | shuffle_field_4                                                                                                                                                                                                                                          |
      | shuffle_field_5            | SHUFFLE_FIELD            | rename_derived_sub_query_1                                                                                                                                                                                                                               |
      | join_1                     | JOIN                     | shuffle_field_1; shuffle_field_5                                                                                                                                                                                                                         |
      | shuffle_field_2            | SHUFFLE_FIELD            | join_1                                                                                                                                                                                                                                                   |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs16"
      | conn   | toClose | sql                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain SELECT a.* FROM sharding_4_t1 a WHERE a.id in (select b.id from single_t1 b where 1=1 and b.id =(SELECT max(c.id) FROM no_sharding_t1 c where c.code=1)) ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs16" has lines with following column values
      | SHARDING_NODE-0            | TYPE-1                   | SQL/REF-2 |
      | dn5_0                      | BASE SQL                 | select max(c.id) as `autoalias_scalar` from  `no_sharding_t1` `c` where `c`.`code` = 1 limit 0,2                                                            |
      | merge_1                    | MERGE                    | dn5_0                                                                                                                                                       |
      | scalar_sub_query_1         | SCALAR_SUB_QUERY         | merge_1                                                                                                                                                     |
      | dn1_0                      | BASE SQL(May No Need)    | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                    |
      | dn2_0                      | BASE SQL(May No Need)    | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                    |
      | dn3_0                      | BASE SQL(May No Need)    | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                    |
      | dn4_0                      | BASE SQL(May No Need)    | scalar_sub_query_1; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` ORDER BY `a`.`id` ASC                                                    |
      | merge_and_order_1          | MERGE_AND_ORDER          | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                  |
      | shuffle_field_1            | SHUFFLE_FIELD            | merge_and_order_1                                                                                                                                           |
      | dn1_1                      | BASE SQL(May No Need)    | scalar_sub_query_1; select DISTINCT `b`.`id` as `autoalias_scalar` from  `single_t1` `b` where `b`.`id` = '{NEED_TO_REPLACE}' ORDER BY autoalias_scalar ASC |
      | merge_2                    | MERGE                    | dn1_1                                                                                                                                                       |
      | distinct_1                 | DISTINCT                 | merge_2                                                                                                                                                     |
      | shuffle_field_3            | SHUFFLE_FIELD            | distinct_1                                                                                                                                                  |
      | rename_derived_sub_query_1 | RENAME_DERIVED_SUB_QUERY | shuffle_field_3                                                                                                                                             |
      | shuffle_field_4            | SHUFFLE_FIELD            | rename_derived_sub_query_1                                                                                                                                  |
      | join_1                     | JOIN                     | shuffle_field_1; shuffle_field_4                                                                                                                            |
      | shuffle_field_2            | SHUFFLE_FIELD            | join_1                                                                                                                                                      |
    # Nested subquery contain = subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs17"
      | conn   | toClose | sql                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain SELECT a.* FROM sharding_4_t1 a WHERE a.id =(select max(b.id) from single_t1 b where 1=1 and b.id =(SELECT max(c.id) FROM no_sharding_t1 c where c.code=1)) ORDER BY a.id | success | schema1 |
    Then check resultset "join_rs17" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select max(c.id) as `autoalias_scalar` from  `no_sharding_t1` `c` where `c`.`code` = 1 limit 0,2                                              |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                         |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                       |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select max(b.id) as `_$MAX$_rpda_0` from  `single_t1` `b` where  ( 1 = 1 AND `b`.`id` = '{NEED_TO_REPLACE}') LIMIT 2      |
      | merge_2            | MERGE                 | dn1_0                                                                                                                                         |
      | aggregate_1        | AGGREGATE             | merge_2                                                                                                                                       |
      | limit_1            | LIMIT                 | aggregate_1                                                                                                                                   |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                                       |
      | scalar_sub_query_2 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                               |
      | dn1_1              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_2; select `a`.`id`,`a`.`name`,`a`.`age` from  `sharding_4_t1` `a` where `a`.`id` = '{NEED_TO_REPLACE}' ORDER BY `a`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                    |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                             |

    # = any() subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs18"
      | conn   | toClose | sql                                                                                                          | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where id = any(select id from single_t1 where code=1) order by name desc | success | schema1 |
    Then check resultset "join_rs18" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` ORDER BY `sharding_4_t1`.`id` ASC                                                                                                                                      |
      | dn2_0             | BASE SQL        | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` ORDER BY `sharding_4_t1`.`id` ASC                                                                                                                                      |
      | dn3_0             | BASE SQL        | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` ORDER BY `sharding_4_t1`.`id` ASC                                                                                                                                      |
      | dn4_0             | BASE SQL        | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` ORDER BY `sharding_4_t1`.`id` ASC                                                                                                                                      |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                     |
      | dn1_1             | BASE SQL        | select `autoalias_single_t1`.`autoalias_scalar` from (select  distinct `single_t1`.`id` as `autoalias_scalar` from  `single_t1` where `single_t1`.`code` = 1 order by `single_t1`.`id` ASC) autoalias_single_t1 order by `autoalias_single_t1`.`autoalias_scalar` ASC |
      | merge_1           | MERGE           | dn1_1                                                                                                                                                                                                                                                                 |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                              |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                               |
    # other any() subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs19"
      | conn   | toClose | sql                                                                                                           | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where id <> any(select id from single_t1 where code=1) order by name desc | success | schema1 |
    Then check resultset "join_rs19" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn1_0               | BASE SQL              | select `single_t1`.`id` as `autoalias_scalar` from  `single_t1` where `single_t1`.`code` = 1                                                                                                                     |
      | merge_1             | MERGE                 | dn1_0                                                                                                                                                                                                            |
      | all_any_sub_query_1 | ALL_ANY_SUB_QUERY     | merge_1                                                                                                                                                                                                          |
      | dn1_1               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn2_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn3_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn4_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | merge_and_order_1   | MERGE_AND_ORDER       | dn1_1; dn2_0; dn3_0; dn4_0                                                                                                                                                                                       |
      | shuffle_field_1     | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                |

    # = some() subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs20"
      | conn   | toClose | sql                                                                                                                | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where id = some(select id from no_sharding_t1 where code=1) order by name desc | success | schema1 |
    Then check resultset "join_rs20" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` ORDER BY `sharding_4_t1`.`id` ASC                                                                                                                                                                         |
      | dn2_0             | BASE SQL        | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` ORDER BY `sharding_4_t1`.`id` ASC                                                                                                                                                                         |
      | dn3_0             | BASE SQL        | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` ORDER BY `sharding_4_t1`.`id` ASC                                                                                                                                                                         |
      | dn4_0             | BASE SQL        | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` ORDER BY `sharding_4_t1`.`id` ASC                                                                                                                                                                         |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                        |
      | dn5_0             | BASE SQL        | select `autoalias_no_sharding_t1`.`autoalias_scalar` from (select  distinct `no_sharding_t1`.`id` as `autoalias_scalar` from  `no_sharding_t1` where `no_sharding_t1`.`code` = 1 order by `no_sharding_t1`.`id` ASC) autoalias_no_sharding_t1 order by `autoalias_no_sharding_t1`.`autoalias_scalar` ASC |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                                                                                                    |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                                                 |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                                                  |
    # other some() subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where id != some(select id from no_sharding_t1 where code=1) order by name desc | success | schema1 |
    Then check resultset "join_rs21" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1                | SQL/REF-2 |
      | dn5_0               | BASE SQL              | select `no_sharding_t1`.`id` as `autoalias_scalar` from  `no_sharding_t1` where `no_sharding_t1`.`code` = 1                                                                                                      |
      | merge_1             | MERGE                 | dn5_0                                                                                                                                                                                                            |
      | all_any_sub_query_1 | ALL_ANY_SUB_QUERY     | merge_1                                                                                                                                                                                                          |
      | dn1_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn2_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn3_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn4_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`id` <> '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | merge_and_order_1   | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                       |
      | shuffle_field_1     | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                |
    # = all() subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where age = all(select code from no_sharding_t1 where code>2) order by name desc | success | schema1 |
    Then check resultset "join_rs22" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1                | SQL/REF-2 |
      | dn5_0               | BASE SQL              | select `no_sharding_t1`.`code` as `autoalias_scalar` from  `no_sharding_t1` where `no_sharding_t1`.`code` > 2                                                                                                    |
      | merge_1             | MERGE                 | dn5_0                                                                                                                                                                                                            |
      | all_any_sub_query_1 | ALL_ANY_SUB_QUERY     | merge_1                                                                                                                                                                                                          |
      | dn1_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` = '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn2_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` = '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn3_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` = '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | dn4_0               | BASE SQL(May No Need) | all_any_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` = '{ALL_SUB_QUERY_RESULTS}' ORDER BY `sharding_4_t1`.`name` DESC |
      | merge_and_order_1   | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                       |
      | shuffle_field_1     | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                |
    # other all() subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where age <> all(select code from no_sharding_t1 where code>2) order by name desc | success | schema1 |
    Then check resultset "join_rs23" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn5_0             | BASE SQL              | select `no_sharding_t1`.`code` as `autoalias_scalar` from  `no_sharding_t1` where `no_sharding_t1`.`code` > 2                                                                                                 |
      | merge_1           | MERGE                 | dn5_0                                                                                                                                                                                                         |
      | in_sub_query_1    | IN_SUB_QUERY          | merge_1                                                                                                                                                                                                       |
      | dn1_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` not  in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | dn2_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` not  in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | dn3_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` not  in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | dn4_0             | BASE SQL(May No Need) | in_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where `sharding_4_t1`.`age` not  in ('{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`name` DESC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                             |

    # not subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                               | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where not id=(select max(id) from no_sharding_t1) order by id | success | schema1 |
    Then check resultset "join_rs24" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select max(id) as `autoalias_scalar` from  `no_sharding_t1` limit 0,2                                                                                                                                         |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                                                                                         |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                                                                                       |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where  ( NOT `sharding_4_t1`.`id` = '{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`id` ASC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where  ( NOT `sharding_4_t1`.`id` = '{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`id` ASC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where  ( NOT `sharding_4_t1`.`id` = '{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`id` ASC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where  ( NOT `sharding_4_t1`.`id` = '{NEED_TO_REPLACE}') ORDER BY `sharding_4_t1`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                    |
      | shuffle_field_1    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                             |

    # exists subquery
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs25"
      | conn   | toClose | sql                                                                                                              | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where exists (select id from no_sharding_t1 where code=1) order by name desc | success | schema1 |
    Then check resultset "join_rs25" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn5_0              | BASE SQL              | select `no_sharding_t1`.`id` as `autoalias_scalar`,1 from  `no_sharding_t1` where `no_sharding_t1`.`code` = 1 limit 0,1                                             |
      | merge_1            | MERGE                 | dn5_0                                                                                                                                                               |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | merge_1                                                                                                                                                             |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where 1 = 1 ORDER BY `sharding_4_t1`.`name` DESC |
      | dn2_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where 1 = 1 ORDER BY `sharding_4_t1`.`name` DESC |
      | dn3_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where 1 = 1 ORDER BY `sharding_4_t1`.`name` DESC |
      | dn4_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` where 1 = 1 ORDER BY `sharding_4_t1`.`name` DESC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                          |
      | shuffle_field_1    | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                  | expect  | db      |
      # Columns contain in-subquery
      | conn_1 | False   | select a.id, select max(b.id) from no_sharding_t1 b where b.id in (select distinct d.id from single_t1 d) as name FROM sharding_4_t1 a ORDER BY a.id | has{((1,8),(2,8),(3,8),(4,8),(5,8),(6,8),(7,8),(8,8))} | schema1 |
      # Columns contain = subquery
      | conn_1 | False   | select a.id, select max(b.id) from no_sharding_t1 b where b.id = (select max(d.id) from single_t1 d) as name FROM sharding_4_t1 a ORDER BY a.id      | has{((1,8),(2,8),(3,8),(4,8),(5,8),(6,8),(7,8),(8,8))} | schema1 |
      # where contain in-subquery
      | conn_1 | False   | SELECT a.* FROM sharding_4_t1 a WHERE a.id in (SELECT b.id FROM no_sharding_t1 b) ORDER BY a.id | has{((1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4),(5,'aa',15),(6,'bb',16),(7,'cc',17),(8,'dd',18))} | schema1 |
      # where contain = subquery
      | conn_1 | False   | SELECT a.* FROM sharding_4_t1 a WHERE a.id =(SELECT b.id FROM no_sharding_t1 b WHERE b.id =1 limit 1) ORDER BY a.id | has{((1,'a',1),)} | schema1 |
      # join contain in-subquery
      | conn_1 | False   | SELECT c.* FROM sharding_4_t1 c JOIN single_t1 b on (SELECT a.id FROM single_t1 a WHERE a.id IN ( SELECT cc.id FROM no_sharding_t1 cc limit 1)) = c.id order by c.id | has{((1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),)} | schema1 |
      # join contain = subquery
      | conn_1 | False   | SELECT c.* FROM sharding_4_t1 c JOIN single_t1 b on (SELECT a.id FROM single_t1 a WHERE a.id =( SELECT cc.id FROM no_sharding_t1 cc limit 1)) = c.id order by c.id | has{((1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),(1,'a',1),)} | schema1 |
      # order by contain in-subquery
      | conn_1 | False   | SELECT a.* FROM sharding_4_t1 a WHERE a.age>5 ORDER BY (select c.id from no_sharding_t1 c where 1=1 and c.id in (select d.id from single_t1 d) order by c.id limit 1) | has{((5,'aa',15),(6,'bb',16),(7,'cc',17),(8,'dd',18))} | schema1 |
      # order by contain = subquery
      | conn_1 | False   | select a.* from sharding_4_t1 a where a.age>5 order by (select c.id from no_sharding_t1 c where 1=1 and c.id=(select max(d.id) from single_t1 d) order by c.id limit 1) | has{((5,'aa',15),(6,'bb',16),(7,'cc',17),(8,'dd',18))} | schema1 |
      # having contain in-subquery
      | conn_1 | False   | select a.id from sharding_4_t1 a where 1=1 group by a.id having a.id in (select b.id from single_t1 b where b.code>5) order by a.id | has{((6,),(7,),(8,))} | schema1 |
      # having contain = subquery
      | conn_1 | False   | select a.id from sharding_4_t1 a where 1=1 group by a.id having a.id=(select max(b.id) from single_t1 b where b.code>5) order by a.id | has{((8,),)} | schema1 |
      # Nested subquery contain in-subquery
      | conn_1 | False   | SELECT a.* FROM sharding_4_t1 a WHERE a.id IN (select b.id from single_t1 b where 1=1 and b.id in (SELECT c.id FROM no_sharding_t1 c)) ORDER BY a.id | has{((1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4),(5,'aa',15),(6,'bb',16),(7,'cc',17),(8,'dd',18))} | schema1 |
      | conn_1 | False   | SELECT a.* FROM sharding_4_t1 a WHERE a.id in (select b.id from single_t1 b where 1=1 and b.id =(SELECT max(c.id) FROM no_sharding_t1 c where c.code=1)) ORDER BY a.id | has{((1,'a',1),)} | schema1 |
      # Nested subquery contain = subquery
      | conn_1 | False   | SELECT a.* FROM sharding_4_t1 a WHERE a.id =(select max(b.id) from single_t1 b where 1=1 and b.id =(SELECT max(c.id) FROM no_sharding_t1 c where c.code=1)) ORDER BY a.id | has{((1,'a',1),)} | schema1 |
      # = any() subquery
      | conn_1 | False   | select * from sharding_4_t1 where id = any(select id from single_t1 where code=1) order by name desc | has{((1,'a',1),)} | schema1 |
      # other any() subquery
      | conn_1 | False   | select * from sharding_4_t1 where id <> any(select id from single_t1 where code=1) order by name desc | has{((8,'dd',18), (4,'d',4), (7,'cc',17), (3,'c',3), (6,'bb',16), (2,'b',2), (5,'aa',15))} | schema1 |
      # = some() subquery
      | conn_1 | False   | select * from sharding_4_t1 where id = some(select id from no_sharding_t1 where code=1) order by name desc | has{((1,'a',1),)} | schema1 |
      # other some() subquery
      | conn_1 | False   | select * from sharding_4_t1 where id != some(select id from no_sharding_t1 where code=1) order by name desc | has{((8,'dd',18), (4,'d',4), (7,'cc',17), (3,'c',3), (6,'bb',16), (2,'b',2), (5,'aa',15))} | schema1 |
      # = all() subquery
      | conn_1 | False   | select * from sharding_4_t1 where age = all(select code from no_sharding_t1 where code>2) order by name desc | success | schema1 |
      # other all() subquery
      | conn_1 | False   | select * from sharding_4_t1 where age <> all(select code from no_sharding_t1 where code>2) order by name desc | has{((1,'a',1),(2,'b',2))} | schema1 |
      # not subquery
      | conn_1 | False   | select * from sharding_4_t1 where not id=(select max(id) from no_sharding_t1) order by id                     | has{((1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4),(5,'aa',15),(6,'bb',16),(7,'cc',17))} | schema1 |
      # exists subquery
      | conn_1 | False   | select * from sharding_4_t1 where exists (select id from no_sharding_t1 where code=1) order by name desc      | has{((8,'dd',18),(4,'d',4),(7,'cc',17),(3,'c',3),(6,'bb',16),(2,'b',2),(5,'aa',15),(1,'a',1))} | schema1 |
      | conn_1 | True    | drop table if exists sharding_4_t1;drop table if exists no_sharding_t1;drop table if exists single_t1         | success | schema1 |
