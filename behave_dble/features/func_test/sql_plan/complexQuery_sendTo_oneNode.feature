# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2020/12/01
# Update by caiwei at 2021/08/03

#2.20.04.0#dble-8184
Feature: following complex queries are able to send one datanode
      #1.explain select count(*) from sharding_two_node a where a.id =1;
      #2.explain select * from sharding_two_node a join sharding_two_node2 b on a.id = b.id where a.id =1 and b.id=1;
      #3.explain select * from sharding_two_node a join schema2.sharding_two_node2 b on a.c_flag=b.c_flag where a.id =1 and b.id=2;
      #4.explain select * from sharding_two_node a join sharding_two_node2 b on a.c_flag=b.c_flag where (a.id =1 and b.id=1) or (a.id =2 and b.id=2);
      #5.explain select * from sharding_two_node a join sharding_two_node2 b on a.id = b.id where a.id =1;
      #6.explain select * from sharding_two_node a join sharding_two_node2 b where a.id = b.id and a.id =1;
      #7.explain select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 ));
      #8.explain select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and a.c_decimal=1 and (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 ));
      #9.explain select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and (a.c_decimal=1 and (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 )));
      #10.explain select * from sharding_two_node where id =1 and c_flag = (select c_flag from sharding_two_node2 where id =1 );
      #11.explain select * from sharding_two_node a where a.id =1 and exists(select * from sharding_two_node2 b where a.c_flag=b.c_flag and b.id =1);
      #12.explain select * from sharding_two_node where id =1 union select * from sharding_two_node2 where id =1 ;

   Scenario: execute "explain sql" and check result #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <shardingTable name="a_three" shardingColumn="id" shardingNode="dn1,dn2,dn3" function="hash-three" />
        <singleTable name="test_global_1" shardingNode="dn1" />
        <globalTable name="test_global" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="aly_test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="aly_order" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="a_manager" shardingNode="dn2,dn1,dn4,dn3" function="hash-four" shardingColumn="id"/>
        <shardingTable name="sharding_two_node" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <shardingTable name="sharding_two_node2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100">
       <shardingTable name="tb_test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

     <function class="Hash" name="hash-two">
        <property name="partitionCount">2</property>
        <property name="partitionLength">512</property>
     </function>
     <function class="Hash" name="hash-three">
        <property name="partitionCount">3</property>
        <property name="partitionLength">10</property>
     </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                    | expect  | db      |
      | conn_1 | False   | drop table if exists tb_test                                                           | success | schema2 |
      | conn_1 | True    | create table tb_test(id int, c char(5))                                                | success | schema2 |
      | conn_0 | False   | drop table if exists aly_test                                                          | success | schema1 |
      | conn_0 | False   | create table aly_test(id int, c char(5))                                               | success | schema1 |
      | conn_0 | False   | drop table if exists aly_order                                                         | success | schema1 |
      | conn_0 | False   | create table aly_order(id int, c char(5))                                              | success | schema1 |
      | conn_0 | False   | drop table if exists a_manager                                                         | success | schema1 |
      | conn_0 | False   | create table a_manager(id int, c char(5))                                              | success | schema1 |
      | conn_0 | False   | drop table if exists a_three                                                           | success | schema1 |
      | conn_0 | False   | create table a_three(id int, c char(5))                                                | success | schema1 |
      | conn_0 | False   | drop table if exists test_global_1                                                     | success | schema1 |
      | conn_0 | False   | create table test_global_1(id int, cc char(5))                                         | success | schema1 |
      | conn_0 | False   | drop table if exists test_global                                                       | success | schema1 |
      | conn_0 | False   | create table test_global(id int, cc char(5))                                           | success | schema1 |
      | conn_0 | False   | insert into aly_test values(1,'a'),(1,'b'),(null,'c'),(2,'d'),(3,'c'),(4,'d'),(4,null) | success | schema1 |
      | conn_0 | False   | insert into aly_order values(1,'a'),(1,'b'),(null,null),(2,'b'),(3,'c'),(4,'e')        | success | schema1 |
      | conn_0 | False   | insert into a_manager values(1,'a'),(null,'b'),(2,'a'),(3, 'c'),(4,'d')                | success | schema1 |
      | conn_0 | False   | insert into a_three values(1,'a'),(null,'b'),(9,'b'),(10,'c'),(11,'d')                 | success | schema1 |
      | conn_0 | False   | drop table if exists sharding_two_node2                                                | success | schema1 |
      | conn_0 | False   | create table sharding_two_node2(id int, c_flag int, c_decimal float)                   | success | schema1 |
      | conn_0 | False   | drop table if exists sharding_two_node                                                 | success | schema1 |
      | conn_0 | False   | create table sharding_two_node(id int, c_flag int, c_decimal float)                    | success | schema1 |

    #used in compare result with dble
    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                                                                                    | expect  | db      |
      | conn_1 | False   | drop table if exists tb_test                                                           | success | schema2 |
      | conn_1 | True    | create table tb_test(id int, c char(5))                                                | success | schema2 |
      | conn_0 | False   | drop table if exists aly_test                                                          | success | schema1 |
      | conn_0 | False   | create table aly_test(id int, c char(5))                                               | success | schema1 |
      | conn_0 | False   | drop table if exists aly_order                                                         | success | schema1 |
      | conn_0 | False   | create table aly_order(id int, c char(5))                                              | success | schema1 |
      | conn_0 | False   | drop table if exists a_manager                                                         | success | schema1 |
      | conn_0 | False   | create table a_manager(id int, c char(5))                                              | success | schema1 |
      | conn_0 | False   | drop table if exists a_three                                                           | success | schema1 |
      | conn_0 | False   | create table a_three(id int, c char(5))                                                | success | schema1 |
      | conn_0 | False   | drop table if exists test_global_1                                                     | success | schema1 |
      | conn_0 | False   | create table test_global_1(id int, cc char(5))                                         | success | schema1 |
      | conn_0 | False   | drop table if exists test_global                                                       | success | schema1 |
      | conn_0 | False   | create table test_global(id int, cc char(5))                                           | success | schema1 |
      | conn_0 | False   | insert into aly_test values(1,'a'),(1,'b'),(null,'c'),(2,'d'),(3,'c'),(4,'d'),(4,null) | success | schema1 |
      | conn_0 | False   | insert into aly_order values(1,'a'),(1,'b'),(null,null),(2,'b'),(3,'c'),(4,'e')        | success | schema1 |
      | conn_0 | False   | insert into a_manager values(1,'a'),(null,'b'),(2,'a'),(3, 'c'),(4,'d')                | success | schema1 |
      | conn_0 | False   | insert into a_three values(1,'a'),(null,'b'),(9,'b'),(10,'c'),(11,'d')                 | success | schema1 |
      | conn_0 | False   | drop table if exists sharding_two_node2                                                | success | schema1 |
      | conn_0 | False   | create table sharding_two_node2(id int, c_flag int, c_decimal float)                   | success | schema1 |
      | conn_0 | False   | drop table if exists sharding_two_node                                                 | success | schema1 |
      | conn_0 | False   | create table sharding_two_node(id int, c_flag int, c_decimal float)                    | success | schema1 |


    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         |
      | conn_0 | False   | explain select count(*) from aly_test a where a.id =1       |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                     |
      | dn2             | BASE SQL | select count(*) from aly_test a where a.id =1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                 | db      |
      | conn_0 | False   | select count(*) from aly_test a where a.id =1       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                              |
      | conn_0 | False   | explain select id a from sharding_two_node b where b.id=1        |
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                               |
      | dn1             | BASE SQL | select id a from sharding_two_node b where b.id=1       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                     | db      |
      | conn_0 | False   | select id a from sharding_two_node b where b.id=1       | schema1 |


    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_4"
      | conn   | toClose | sql                                                                          |
      | conn_0 | False   | explain select count(*) from aly_test a where a.c='a' or a.c='b' and a.id =1 |
    Then check resultset "rs_4" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                               |
      | dn1_0           | BASE SQL      | select count(*) as `_$COUNT$_rpda_0` from  `aly_test` `a` where  (  ( `a`.`c` = 'b' AND `a`.`id` = 1) OR `a`.`c` in ('a')) LIMIT 100 |
      | dn2_0           | BASE SQL      | select count(*) as `_$COUNT$_rpda_0` from  `aly_test` `a` where  (  ( `a`.`c` = 'b' AND `a`.`id` = 1) OR `a`.`c` in ('a')) LIMIT 100 |
      | dn3_0           | BASE SQL      | select count(*) as `_$COUNT$_rpda_0` from  `aly_test` `a` where  (  ( `a`.`c` = 'b' AND `a`.`id` = 1) OR `a`.`c` in ('a')) LIMIT 100 |
      | dn4_0           | BASE SQL      | select count(*) as `_$COUNT$_rpda_0` from  `aly_test` `a` where  (  ( `a`.`c` = 'b' AND `a`.`id` = 1) OR `a`.`c` in ('a')) LIMIT 100 |
      | merge_1         | MERGE         | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                           |
      | aggregate_1     | AGGREGATE     | merge_1                                                                                                                              |
      | limit_1         | LIMIT         | aggregate_1                                                                                                                          |
      | shuffle_field_1 | SHUFFLE_FIELD | limit_1                                                                                                                              |
     Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                        | db      |
      | conn_0 | False   | select count(*) from aly_test a where a.c='a' or a.c='b' and a.id =1       | schema1 |

     Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_5"
      | conn   | toClose | sql                                                                        |
      | conn_0 | False   | explain select count(*) from aly_test a where a.id =1 group by id          |
    Then check resultset "rs_5" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                 |
      | dn2             | BASE SQL | select count(*) from aly_test a where a.id =1 group by id |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                             | db      |
      | conn_0 | False   | select count(*) from aly_test a where a.id =1 group by id       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_6"
      | conn   | toClose | sql                                                                                                            |
      | conn_0 | False   | explain select * from aly_order join test_global where aly_order.id in ( select id from aly_test where id=1)   |
    Then check resultset "rs_6" has lines with following column values
      | SHARDING_NODE-0            | TYPE-1                   | SQL/REF-2                                                                                                                     |
      | dn1_0                      | BASE SQL                 | select `aly_order`.`id`,`aly_order`.`c` from  `aly_order` ORDER BY `aly_order`.`id` ASC                                       |
      | dn2_0                      | BASE SQL                 | select `aly_order`.`id`,`aly_order`.`c` from  `aly_order` ORDER BY `aly_order`.`id` ASC                                       |
      | dn3_0                      | BASE SQL                 | select `aly_order`.`id`,`aly_order`.`c` from  `aly_order` ORDER BY `aly_order`.`id` ASC                                       |
      | dn4_0                      | BASE SQL                 | select `aly_order`.`id`,`aly_order`.`c` from  `aly_order` ORDER BY `aly_order`.`id` ASC                                       |
      | merge_and_order_1          | MERGE_AND_ORDER          | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                    |
      | shuffle_field_1            | SHUFFLE_FIELD            | merge_and_order_1                                                                                                             |
      | /*AllowDiff*/dn1_1         | BASE SQL                 | select `test_global`.`id`,`test_global`.`cc` from  `test_global`                                                              |
      | merge_1                    | MERGE                    | /*AllowDiff*/dn1_1                                                                                                            |
      | join_1                     | JOIN                     | shuffle_field_1; merge_1                                                                                                      |
      | shuffle_field_2            | SHUFFLE_FIELD            | join_1                                                                                                                        |
      | /*AllowDiff*/dn2_1         | BASE SQL                 | select DISTINCT `aly_test`.`id` as `autoalias_scalar` from  `aly_test` where `aly_test`.`id` = 1 ORDER BY `aly_test`.`id` ASC |
      | merge_2                    | MERGE                    | /*AllowDiff*/dn2_1                                                                                                            |
      | distinct_1                 | DISTINCT                 | merge_2                                                                                                                       |
      | shuffle_field_4            | SHUFFLE_FIELD            | distinct_1                                                                                                                    |
      | rename_derived_sub_query_1 | RENAME_DERIVED_SUB_QUERY | shuffle_field_4                                                                                                               |
      | shuffle_field_5            | SHUFFLE_FIELD            | rename_derived_sub_query_1                                                                                                    |
      | join_2                     | JOIN                     | shuffle_field_2; shuffle_field_5                                                                                              |
      | shuffle_field_3            | SHUFFLE_FIELD            | join_2                                                                                                                        |

   Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                        | db      |
      | conn_0 | False   | select * from aly_order join test_global where aly_order.id in ( select id from aly_test where id=1)       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_7"
      | conn   | toClose | sql                                                                        |
      | conn_0 | False   | explain select * from aly_order where id=(select 1)                        |
    Then check resultset "rs_7" has lines with following column values
      | SHARDING_NODE-0      | TYPE-1                | SQL/REF-2                                               |
      | /*AllowDiff*/dn1_0   | BASE SQL              | select 1 as `autoalias_scalar`                                                                                             |
      | merge_1              | MERGE                 | /*AllowDiff*/dn1_0                                                                                                         |
      | scalar_sub_query_1   | SCALAR_SUB_QUERY      | merge_1                                                                                                                    |
      | /*AllowDiff*/dn1_1   | BASE SQL(May No Need) | scalar_sub_query_1; select `aly_order`.`id`,`aly_order`.`c` from  `aly_order` where `aly_order`.`id` = '{NEED_TO_REPLACE}' |
      | /*AllowDiff*/dn2_0   | BASE SQL(May No Need) | scalar_sub_query_1; select `aly_order`.`id`,`aly_order`.`c` from  `aly_order` where `aly_order`.`id` = '{NEED_TO_REPLACE}' |
      | /*AllowDiff*/dn3_0   | BASE SQL(May No Need) | scalar_sub_query_1; select `aly_order`.`id`,`aly_order`.`c` from  `aly_order` where `aly_order`.`id` = '{NEED_TO_REPLACE}' |
      | /*AllowDiff*/dn4_0   | BASE SQL(May No Need) | scalar_sub_query_1; select `aly_order`.`id`,`aly_order`.`c` from  `aly_order` where `aly_order`.`id` = '{NEED_TO_REPLACE}' |
      | merge_2              | MERGE                 | /*AllowDiff*/dn1_1; dn2_0; dn3_0; dn4_0                                                                                    |
      | shuffle_field_1      | SHUFFLE_FIELD         | merge_2                                                                                                                    |
     Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                               | db      |
      | conn_0 | False   | select * from aly_order where id=(select 1)       | schema1 |

     Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_8"
      | conn   | toClose | sql                                                                                       |
      | conn_0 | False   | explain select * from aly_test a join aly_order b on a.id = b.id where a.id =1 and b.id=1 |
    Then check resultset "rs_8" has lines with following column values
      | SHARDING_NODE-0      | TYPE-1         | SQL/REF-2                                               |
      | dn2                  | BASE SQL       | select * from aly_test a join aly_order b on a.id = b.id where a.id =1 and b.id=1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                     | db      |
      | conn_0 | False   | select * from aly_test a join aly_order b on a.id = b.id where a.id =1 and b.id=1       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_9"
      | conn   | toClose | sql                                                                                       |
      | conn_0 | False   | explain select * from aly_test a join a_manager b on a.id = b.id where a.id =1 and b.id=1 |
    Then check resultset "rs_9" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn2_0           | BASE SQL      | select `a`.`id`,`a`.`c` from  `aly_test` `a` where  ( `a`.`id` = 1 AND `a`.`id` = 1) ORDER BY `a`.`id` ASC  |
      | merge_1         | MERGE         | dn2_0                                                                                                       |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                     |
      | dn1_0           | BASE SQL      | select `b`.`id`,`b`.`c` from  `a_manager` `b` where  ( `b`.`id` = 1 AND `b`.`id` = 1) ORDER BY `b`.`id` ASC |
      | merge_2         | MERGE         | dn1_0                                                                                                       |
      | shuffle_field_3 | SHUFFLE_FIELD | merge_2                                                                                                     |
      | join_1          | JOIN          | shuffle_field_1; shuffle_field_3                                                                            |
      | shuffle_field_2 | SHUFFLE_FIELD | join_1                                                                                                      |
   Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                     | db      |
      | conn_0 | False   | select * from aly_test a join a_manager b on a.id = b.id where a.id =1 and b.id=1       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_10"
      | conn   | toClose | sql                                                                                   |
      | conn_0 | False   | explain select * from aly_test a join a_three b on a.c = b.c where a.id =4 and b.id=2 |
    Then check resultset "rs_10" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn1             | BASE SQL      | select * from aly_test a join a_three b on a.c = b.c where a.id =4 and b.id=2 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                 | db      |
      | conn_0 | False   | select * from aly_test a join a_three b on a.c = b.c where a.id =4 and b.id=2       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_11"
      | conn   | toClose | sql                                                                                    |
      | conn_0 | False   | explain select * from aly_test a join a_three b on a.c = b.c where a.id =4 and b.id=10 |
    Then check resultset "rs_11" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn1_0           | BASE SQL      | select `a`.`id`,`a`.`c` from  `aly_test` `a` where `a`.`id` = 4 ORDER BY `a`.`c` ASC |
      | merge_1         | MERGE         | dn1_0                                                                                |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                              |
      | dn2_0           | BASE SQL      | select `b`.`id`,`b`.`c` from  `a_three` `b` where `b`.`id` = 10 ORDER BY `b`.`c` ASC |
      | merge_2         | MERGE         | dn2_0                                                                                |
      | shuffle_field_3 | SHUFFLE_FIELD | merge_2                                                                              |
      | join_1          | JOIN          | shuffle_field_1; shuffle_field_3                                                     |
      | shuffle_field_2 | SHUFFLE_FIELD | join_1                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                  | db      |
      | conn_0 | False   | select * from aly_test a join a_three b on a.c = b.c where a.id =4 and b.id=10       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_12"
      | conn   | toClose | sql                                                                                                |
      | conn_0 | False   | explain select * from aly_test a join a_three b on a.c = b.c where a.id = 4 and b.id=2 and b.c='a' |
    Then check resultset "rs_12" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                  |
      | dn1             | BASE SQL      | select * from aly_test a join a_three b on a.c = b.c where a.id = 4 and b.id=2 and b.c='a' |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                              | db      |
      | conn_0 | False   | select * from aly_test a join a_three b on a.c = b.c where a.id = 4 and b.id=2 and b.c='a'       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_13"
      | conn   | toClose | sql                                                                                                     |
      | conn_0 | False   | explain select * from aly_test a, test_global where a.c=test_global.cc and a.id =3 and test_global.id=1 |
    Then check resultset "rs_13" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn4             | BASE SQL      | select * from aly_test a, test_global where a.c=test_global.cc and a.id =3 and test_global.id=1    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                   | db      |
      | conn_0 | False   | select * from aly_test a, test_global where a.c=test_global.cc and a.id =3 and test_global.id=1       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_14"
      | conn   | toClose | sql                                                                                         |
      | conn_0 | False   | explain select * from aly_test a join schema2.tb_test b on a.c=b.c where a.id =1 and b.id=1 |
    Then check resultset "rs_14" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn2             | BASE SQL      | select * from aly_test a join tb_test b on a.c=b.c where a.id =1 and b.id=1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                       | db      |
      | conn_0 | False   | select * from aly_test a join schema2.tb_test b on a.c=b.c where a.id =1 and b.id=1       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_15"
      | conn   | toClose | sql                                                                                         |
      | conn_0 | False   | explain select * from aly_test a join schema2.tb_test b on a.c=b.c where a.id =1 and b.id=2 |
    Then check resultset "rs_15" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn2_0           | BASE SQL      | select `a`.`id`,`a`.`c` from  `aly_test` `a` where `a`.`id` = 1 ORDER BY `a`.`c` ASC |
      | merge_1         | MERGE         | dn2_0                                                                                |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                              |
      | dn3_0           | BASE SQL      | select `b`.`id`,`b`.`c` from  `tb_test` `b` where `b`.`id` = 2 ORDER BY `b`.`c` ASC  |
      | merge_2         | MERGE         | dn3_0                                                                                |
      | shuffle_field_3 | SHUFFLE_FIELD | merge_2                                                                              |
      | join_1          | JOIN          | shuffle_field_1; shuffle_field_3                                                     |
      | shuffle_field_2 | SHUFFLE_FIELD | join_1                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                       | db      |
      | conn_0 | False   | select * from aly_test a join schema2.tb_test b on a.c=b.c where a.id =1 and b.id=2       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_16"
      | conn   | toClose | sql                                                                                                            |
      | conn_0 | False   | explain select * from aly_test a join a_three b on a.c = b.c where (a.id =4 and b.id=1) or (a.id=4 and b.id=2) |
    Then check resultset "rs_16" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn1             | BASE SQL      | select * from aly_test a join a_three b on a.c = b.c where (a.id =4 and b.id=1) or (a.id=4 and b.id=2) |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                          | db      |
      | conn_0 | False   | select * from aly_test a join a_three b on a.c = b.c where (a.id =4 and b.id=1) or (a.id=4 and b.id=2)       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_17"
      | conn   | toClose | sql                                                                                                              |
      | conn_0 | False   | explain select * from aly_test a join aly_order b on a.c = b.c where (a.id =1 and b.id=1) or (a.id=2 and b.id=2) |
    Then check resultset "rs_17" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                               |
      | dn2_0             | BASE SQL        | select `a`.`id`,`a`.`c` from  `aly_test` `a` where  ( `a`.`id` = 1 OR `a`.`id` = 2) ORDER BY `a`.`c` ASC  |
      | dn3_0             | BASE SQL        | select `a`.`id`,`a`.`c` from  `aly_test` `a` where  ( `a`.`id` = 1 OR `a`.`id` = 2) ORDER BY `a`.`c` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER | dn2_0; dn3_0                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                         |
      | dn2_1             | BASE SQL        | select `b`.`id`,`b`.`c` from  `aly_order` `b` where  ( `b`.`id` = 1 OR `b`.`id` = 2) ORDER BY `b`.`c` ASC |
      | dn3_1             | BASE SQL        | select `b`.`id`,`b`.`c` from  `aly_order` `b` where  ( `b`.`id` = 1 OR `b`.`id` = 2) ORDER BY `b`.`c` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn2_1; dn3_1                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                         |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                          |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | where_filter_1                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                            | db      |
      | conn_0 | False   | select * from aly_test a join aly_order b on a.c = b.c where (a.id =1 and b.id=1) or (a.id=2 and b.id=2)       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_18"
      | conn   | toClose | sql                                                                                                 |
      | conn_0 | False   | explain select * from aly_test a join a_three b on a.c = b.c where (a.id =4 and b.id=1) or (a.id=3) |
    Then check resultset "rs_18" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                               |
      | dn1_0             | BASE SQL        | select `a`.`id`,`a`.`c` from  `aly_test` `a` where  ( `a`.`id` = 4 OR `a`.`id` in (3)) ORDER BY `a`.`c` ASC |
      | dn4_0             | BASE SQL        | select `a`.`id`,`a`.`c` from  `aly_test` `a` where  ( `a`.`id` = 4 OR `a`.`id` in (3)) ORDER BY `a`.`c` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn4_0                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                           |
      | dn1_1             | BASE SQL        | select `b`.`id`,`b`.`c` from  `a_three` `b` ORDER BY `b`.`c` ASC                                            |
      | dn2_0             | BASE SQL        | select `b`.`id`,`b`.`c` from  `a_three` `b` ORDER BY `b`.`c` ASC                                            |
      | dn3_0             | BASE SQL        | select `b`.`id`,`b`.`c` from  `a_three` `b` ORDER BY `b`.`c` ASC                                            |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_0; dn3_0                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                            |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | where_filter_1                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                               | db      |
      | conn_0 | False   | select * from aly_test a join a_three b on a.c = b.c where (a.id =4 and b.id=1) or (a.id=3)       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_19"
      | conn   | toClose | sql                                                                            |
      | conn_0 | False   | explain select * from aly_test a join aly_order b on a.id = b.id where a.id =1 |
    Then check resultset "rs_19" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn2             | BASE SQL      | select * from aly_test a join aly_order b on a.id = b.id where a.id =1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                          | db      |
      | conn_0 | False   | select * from aly_test a join aly_order b on a.id = b.id where a.id =1       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_20"
      | conn   | toClose | sql                                                                                   |
      | conn_0 | False   | explain select * from aly_test a join aly_order b using(id,c)  where a.id=2 or b.id=1 |
    Then check resultset "rs_20" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn2_0           | BASE SQL      | select `a`.`id`,`a`.`c` from  `aly_test` `a` join  `aly_order` `b` on `a`.`id` = `b`.`id` and (a.c = b.c) where  ( `b`.`id` in (1) OR `a`.`id` in (2)) |
      | dn3_0           | BASE SQL      | select `a`.`id`,`a`.`c` from  `aly_test` `a` join  `aly_order` `b` on `a`.`id` = `b`.`id` and (a.c = b.c) where  ( `b`.`id` in (1) OR `a`.`id` in (2)) |
      | merge_1         | MERGE         | dn2_0; dn3_0                                                                                                                                           |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                 | db      |
      | conn_0 | False   | select * from aly_test a join aly_order b using(id,c)  where a.id=2 or b.id=1       | schema1 |

     Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_21"
      | conn   | toClose | sql                                                                                   |
      | conn_0 | False   | explain select * from aly_test a join a_manager b using(id,c)  where a.id=2 or b.id=1 |
    Then check resultset "rs_21" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                               |
      | dn1_0             | BASE SQL        | select `a`.`id`,`a`.`c` from  `aly_test` `a` ORDER BY `a`.`id` ASC,`a`.`c` ASC  |
      | dn2_0             | BASE SQL        | select `a`.`id`,`a`.`c` from  `aly_test` `a` ORDER BY `a`.`id` ASC,`a`.`c` ASC  |
      | dn3_0             | BASE SQL        | select `a`.`id`,`a`.`c` from  `aly_test` `a` ORDER BY `a`.`id` ASC,`a`.`c` ASC  |
      | dn4_0             | BASE SQL        | select `a`.`id`,`a`.`c` from  `aly_test` `a` ORDER BY `a`.`id` ASC,`a`.`c` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                               |
      | dn1_1             | BASE SQL        | select `b`.`id`,`b`.`c` from  `a_manager` `b` ORDER BY `b`.`id` ASC,`b`.`c` ASC |
      | dn2_1             | BASE SQL        | select `b`.`id`,`b`.`c` from  `a_manager` `b` ORDER BY `b`.`id` ASC,`b`.`c` ASC |
      | dn3_1             | BASE SQL        | select `b`.`id`,`b`.`c` from  `a_manager` `b` ORDER BY `b`.`id` ASC,`b`.`c` ASC |
      | dn4_1             | BASE SQL        | select `b`.`id`,`b`.`c` from  `a_manager` `b` ORDER BY `b`.`id` ASC,`b`.`c` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1; dn3_1; dn4_1                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                               |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | where_filter_1                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                 | db      |
      | conn_0 | False   | select * from aly_test a join a_manager b using(id,c)  where a.id=2 or b.id=1       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_22"
      | conn   | toClose | sql                                                                             |
      | conn_0 | False   | explain select * from aly_test a join aly_order b where a.id = b.id and a.id =1 |
    Then check resultset "rs_22" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn2             | BASE SQL      | select * from aly_test a join aly_order b where a.id = b.id and a.id =1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                            | db      |
      | conn_0 | False   |  select * from aly_test a join aly_order b where a.id = b.id and a.id =1       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_23"
      | conn   | toClose | sql                                                                        |
      | conn_0 | False   | explain select * from aly_test a join aly_order b using(id)  where a.id =1 |
    Then check resultset "rs_23" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn2             | BASE SQL      | select * from aly_test a join aly_order b using(id)  where a.id =1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                       | db      |
      | conn_0 | False   |  select * from aly_test a join aly_order b using(id)  where a.id =1       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_24"
      | conn   | toClose | sql                                                                            |
      | conn_0 | False   | explain select * from aly_test a join aly_order b on a.id = b.id where a.id =1 |
    Then check resultset "rs_24" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn2             | BASE SQL      | select * from aly_test a join aly_order b on a.id = b.id where a.id =1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                            | db      |
      | conn_0 | False   |  select * from aly_test a join aly_order b on a.id = b.id where a.id =1        | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_25"
      | conn   | toClose | sql                                                                                                                                                    |
      | conn_0 | False   | explain select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 ))  |
    Then check resultset "rs_25" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn1             | BASE SQL      | select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 )) |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                 | db      |
      | conn_0 | False   | select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 ))       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_26"
      | conn   | toClose | sql                                                                                                                                                                     |
      | conn_0 | False   | explain select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and a.c_decimal=1 and (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 )) |
    Then check resultset "rs_26" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn1             | BASE SQL      | select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and a.c_decimal=1 and (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 )) |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                   | db      |
      | conn_0 | False   | select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and a.c_decimal=1 and (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 ))       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_27"
      | conn   | toClose | sql                                                                                                                                                                       |
      | conn_0 | False   | explain select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and (a.c_decimal=1 and (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 ))) |
    Then check resultset "rs_27" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn1             | BASE SQL      | select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and (a.c_decimal=1 and (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 ))) |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                   | db      |
      | conn_0 | False   | select * from sharding_two_node a join sharding_two_node2 b where a.id =b.id and (a.c_decimal=1 and (( a.id =1 and b.id=1) or ( a.c_flag=b.c_flag and a.id =2 )))       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_28"
      | conn   | toClose | sql                                                                                                                   |
      | conn_0 | False   | explain select * from sharding_two_node where id =1 and c_flag = (select c_flag from sharding_two_node2 where id =1 ) |
    Then check resultset "rs_28" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn1             | BASE SQL      | select * from sharding_two_node where id =1 and c_flag = (select c_flag from sharding_two_node2 where id =1 ) |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                 | db      |
      | conn_0 | False   | select * from sharding_two_node where id =1 and c_flag = (select c_flag from sharding_two_node2 where id =1 )       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_29"
      | conn   | toClose | sql                                                                                                                     |
      | conn_0 | False   | explain select * from sharding_two_node where id =1 and c_flag = (select c_flag from sharding_two_node2 where id =512 ) |
    Then check resultset "rs_29" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1                | SQL/REF-2                                               |
      | dn2_0              | BASE SQL              | select `sharding_two_node2`.`c_flag` as `autoalias_scalar` from  `sharding_two_node2` where `sharding_two_node2`.`id` = 512 LIMIT 2                                                                                                      |
      | merge_1            | MERGE                 | dn2_0                                                                                                                                                                                                                                    |
      | limit_1            | LIMIT                 | merge_1                                                                                                                                                                                                                                  |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                                                                                                                                  |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                                                                                                                          |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_two_node`.`id`,`sharding_two_node`.`c_flag`,`sharding_two_node`.`c_decimal` from  `sharding_two_node` where  ( `sharding_two_node`.`id` = 1 AND `sharding_two_node`.`c_flag` = '{NEED_TO_REPLACE}') |
      | merge_2            | MERGE                 | dn1_0                                                                                                                                                                                                                                    |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_2                                                                                                                                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                   | db      |
      | conn_0 | False   | select * from sharding_two_node where id =1 and c_flag = (select c_flag from sharding_two_node2 where id =512 )       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_30"
      | conn   | toClose | sql                                                                                                     |
      | conn_0 | False    | explain select * from sharding_two_node where id =1 union select * from sharding_two_node2 where id =1 |
    Then check resultset "rs_30" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn1             | BASE SQL      | select * from sharding_two_node where id =1 union select * from sharding_two_node2 where id =1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                  | db      |
      | conn_0 | False   | select * from sharding_two_node where id =1 union select * from sharding_two_node2 where id =1       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_31"
      | conn   | toClose | sql                                                                                                            |
      | conn_0 | False   | explain select * from aly_order join test_global_1 where aly_order.id in ( select id from aly_test where id=1) |
    Then check resultset "rs_31" has lines with following column values
      | SHARDING_NODE-0            | TYPE-1                   | SQL/REF-2                                                                                                                     |
      | dn1_0                      | BASE SQL                 | select `aly_order`.`id`,`aly_order`.`c` from  `aly_order` ORDER BY `aly_order`.`id` ASC                                       |
      | dn2_0                      | BASE SQL                 | select `aly_order`.`id`,`aly_order`.`c` from  `aly_order` ORDER BY `aly_order`.`id` ASC                                       |
      | dn3_0                      | BASE SQL                 | select `aly_order`.`id`,`aly_order`.`c` from  `aly_order` ORDER BY `aly_order`.`id` ASC                                       |
      | dn4_0                      | BASE SQL                 | select `aly_order`.`id`,`aly_order`.`c` from  `aly_order` ORDER BY `aly_order`.`id` ASC                                       |
      | merge_and_order_1          | MERGE_AND_ORDER          | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                    |
      | shuffle_field_1            | SHUFFLE_FIELD            | merge_and_order_1                                                                                                             |
      | /*AllowDiff*/dn1_1         | BASE SQL                 | select `test_global_1`.`id`,`test_global_1`.`cc` from  `test_global_1`                                                        |
      | merge_1                    | MERGE                    | /*AllowDiff*/dn1_1                                                                                                            |
      | join_1                     | JOIN                     | shuffle_field_1; merge_1                                                                                                      |
      | shuffle_field_2            | SHUFFLE_FIELD            | join_1                                                                                                                        |
      | /*AllowDiff*/dn2_1         | BASE SQL                 | select DISTINCT `aly_test`.`id` as `autoalias_scalar` from  `aly_test` where `aly_test`.`id` = 1 ORDER BY `aly_test`.`id` ASC |
      | merge_2                    | MERGE                    | /*AllowDiff*/dn2_1                                                                                                            |
      | distinct_1                 | DISTINCT                 | merge_2                                                                                                                       |
      | shuffle_field_4            | SHUFFLE_FIELD            | distinct_1                                                                                                                    |
      | rename_derived_sub_query_1 | RENAME_DERIVED_SUB_QUERY | shuffle_field_4                                                                                                               |
      | shuffle_field_5            | SHUFFLE_FIELD            | rename_derived_sub_query_1                                                                                                    |
      | join_2                     | JOIN                     | shuffle_field_2; shuffle_field_5                                                                                              |
      | shuffle_field_3            | SHUFFLE_FIELD            | join_2                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                          | db      |
      | conn_0 | False   | select * from aly_order join test_global_1 where aly_order.id in ( select id from aly_test where id=1)       | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_32"
      | conn   | toClose | sql                                                                                                            |
      | conn_0 | True    | explain select * from aly_test a,  test_global_1 where a.c=test_global_1.cc and a.id =3 and test_global_1.id=1 |
    Then check resultset "rs_32" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                               |
      | dn4_0           | BASE SQL      | select `a`.`id`,`a`.`c` from  `aly_test` `a` where `a`.`id` = 3 ORDER BY `a`.`c` ASC                                                    |
      | merge_1         | MERGE         | dn4_0                                                                                                                                   |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                                                 |
      | dn1_0           | BASE SQL      | select `test_global_1`.`id`,`test_global_1`.`cc` from  `test_global_1` where `test_global_1`.`id` = 1 order by `test_global_1`.`cc` ASC |
      | merge_2         | MERGE         | dn1_0                                                                                                                                   |
      | join_1          | JOIN          | shuffle_field_1; merge_2                                                                                                                |
      | shuffle_field_2 | SHUFFLE_FIELD | join_1                                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                          | db      |
      | conn_0 | False   | select * from aly_test a,  test_global_1 where a.c=test_global_1.cc and a.id =3 and test_global_1.id=1       | schema1 |

#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                     | expect  | db      |
#      | conn_1 | true    | drop table if exists tb_test            | success | schema2 |
#      | conn_0 | False   | drop table if exists aly_test           | success | schema1 |
#      | conn_0 | False   | drop table if exists aly_order          | success | schema1 |
#      | conn_0 | False   | drop table if exists a_manager          | success | schema1 |
#      | conn_0 | False   | drop table if exists a_three            | success | schema1 |
#      | conn_0 | False   | drop table if exists test_global_1      | success | schema1 |
#      | conn_0 | False   | drop table if exists test_global        | success | schema1 |
#      | conn_0 | False   | drop table if exists sharding_two_node2 | success | schema1 |
#      | conn_0 | true    | drop table if exists sharding_two_node  | success | schema1 |
#    Then execute sql in "mysql" in "mysql" mode
#      | conn   | toClose | sql                                     | expect  | db      |
#      | conn_1 | true    | drop table if exists tb_test            | success | schema2 |
#      | conn_0 | False   | drop table if exists aly_test           | success | schema1 |
#      | conn_0 | False   | drop table if exists aly_order          | success | schema1 |
#      | conn_0 | False   | drop table if exists a_manager          | success | schema1 |
#      | conn_0 | False   | drop table if exists a_three            | success | schema1 |
#      | conn_0 | False   | drop table if exists test_global_1      | success | schema1 |
#      | conn_0 | False   | drop table if exists test_global        | success | schema1 |
#      | conn_0 | False   | drop table if exists sharding_two_node2 | success | schema1 |
#      | conn_0 | true    | drop table if exists sharding_two_node  | success | schema1 |

  # DBLE0REQ-504  3.21.06.0 added
#  Scenario: add some complex query optimized can send to one datanode    #2
#
#    Given delete the following xml segment
#      |file           | parent          | child                     |
#      |sharding.xml   |{'tag':'root'}   | {'tag':'schema'}          |
#    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
#      """
#        <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
#            <globalTable name="gtable1" shardingNode="dn1,dn2,dn3" />
#            <globalTable name="gtable2" shardingNode="dn1,dn2,dn3" />
#            <shardingTable name="ptable" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
#                <childTable name="ctable" joinColumn="fid" parentColumn="id" />
#            </shardingTable>
#            <shardingTable name="tabler" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
#        </schema>
#      """
#    Then execute admin cmd "reload @@config_all"
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                                                                    | expect  | db      |
#      | conn_0 | False   | drop table if exists gtable1                                                           | success | schema1 |
#      | conn_0 | False   | create table gtable1(name varchar(50),test_id int)                                     | success | schema1 |
#      | conn_0 | False   | drop table if exists gtable2                                                           | success | schema1 |
#      | conn_0 | False   | create table gtable2(name varchar(50),test_id int)                                     | success | schema1 |
#      | conn_0 | False   | drop table if exists ctable                                                            | success | schema1 |
#      | conn_0 | False   | create table ctable(fid int, name varchar(50),test_id int)                             | success | schema1 |
#      | conn_0 | False   | drop table if exists tabler                                                            | success | schema1 |
#      | conn_0 | False   | create table tabler(id int,name varchar(50), test_id int)                              | success | schema1 |
#      | conn_0 | False   | insert into gtable1 values('dog',1),('cat',2),('pander',3),('deer',4),('monkey',5),('lion',1) | success | schema1 |
#      | conn_0 | False   | insert into gtable2 values('cat',1),('dog',2),('deer',3),('monkey',4),('lion',5),('pander',1) | success | schema1 |
#      | conn_0 | Fals    | insert into tabler values(1,'L',6),(2,'D',5),(3,'P',1),(4,'C',3),(5,'M',4),(6,'D',2)   | success | schema1 |
#      | conn_0 | False   | insert into ctable(fid, name, test_id) values(1,'lion_c',1)                            | success | schema1 |
#      | conn_0 | False   | insert into ctable(fid, name, test_id) values(2,'deer_a',2)                            | success | schema1 |
#      | conn_0 | False   | insert into ctable(fid, name, test_id) values(3,'pander_o',3)                          | success | schema1 |
#      | conn_0 | False   | insert into ctable(fid, name, test_id) values(4,'cat_s',4)                            | success | schema1 |
#      | conn_0 | False   | insert into ctable(fid, name, test_id) values(5,'monkey_j',5)                         | success | schema1 |
#      | conn_0 | False   | insert into ctable(fid, name, test_id) values(6,'dog_w',6)                            | success | schema1 |
#
#    #used in compare result with dble
#    Then execute sql in "mysql" in "mysql" mode
#      | conn   | toClose | sql                                                                                    | expect  | db      |
#      | conn_0 | False   | drop table if exists gtable1                                                           | success | schema1 |
#      | conn_0 | False   | create table gtable1(name varchar(50),test_id int)                                     | success | schema1 |
#      | conn_0 | False   | drop table if exists gtable2                                                           | success | schema1 |
#      | conn_0 | False   | create table gtable2(name varchar(50),test_id int)                                     | success | schema1 |
#      | conn_0 | False   | drop table if exists ctable                                                            | success | schema1 |
#      | conn_0 | False   | create table ctable(fid int, name varchar(50),test_id int)                             | success | schema1 |
#      | conn_0 | False   | drop table if exists tabler                                                            | success | schema1 |
#      | conn_0 | False   | create table tabler(id int,name varchar(50), test_id int)                              | success | schema1 |
#      | conn_0 | False   | insert into gtable1 values('dog',1),('cat',2),('pander',3),('deer',4),('monkey',5),('lion',1) | success | schema1 |
#      | conn_0 | False   | insert into gtable2 values('cat',1),('dog',2),('deer',3),('monkey',4),('lion',5),('pander',1) | success | schema1 |
#      | conn_0 | Fals    | insert into tabler values(1,'L',6),(2,'D',5),(3,'P',1),(4,'C',3),(5,'M',4),(6,'D',2)   | success | schema1 |
#      | conn_0 | False   | insert into ctable(fid, name, test_id) values(1,'lion_c',1)                            | success | schema1 |
#      | conn_0 | False   | insert into ctable(fid, name, test_id) values(2,'deer_a',2)                            | success | schema1 |
#      | conn_0 | False   | insert into ctable(fid, name, test_id) values(3,'pander_o',3)                          | success | schema1 |
#      | conn_0 | False   | insert into ctable(fid, name, test_id) values(4,'cat_s',4)                            | success | schema1 |
#      | conn_0 | False   | insert into ctable(fid, name, test_id) values(5,'monkey_j',5)                         | success | schema1 |
#      | conn_0 | False   | insert into ctable(fid, name, test_id) values(6,'dog_w',6)                            | success | schema1 |
#
#    # globalTable1 && globalTable1
#    Given execute sql in "dble-1" in "user" mode
#      |conn   | toClose | sql                                                                                                                 | db      | expect     |
#      |conn_1 | False   | explain select a.name from gtable1 a join gtable1 b on a.test_id = b.test_id where a.test_id = 3                    | schema1 | length{(1)}|
#      |conn_1 | False   | explain select a.name from gtable1 a inner join gtable1 b on a.test_id = b.test_id where a.test_id = 3              | schema1 | length{(1)}|
#      |conn_1 | False   | explain select a.name from gtable1 a cross join gtable1 b on a.test_id = b.test_id where a.test_id = 3              | schema1 | length{(1)}|
#      |conn_1 | False   | explain select a.name from gtable1 a STRAIGHT_JOIN gtable1 b on a.test_id = b.test_id where a.test_id = 3           | schema1 | length{(1)}|
#      |conn_1 | False   | explain select a.name from gtable1 a left join gtable1 b on a.name = b.name where b.test_id = 1                     | schema1 | length{(1)}|
#      |conn_1 | False   | explain select a.name from gtable1 a right join gtable1 b on a.name = b.name where b.test_id = 1                    | schema1 | length{(1)}|
#      |conn_1 | true    | explain select a.name from gtable1 a where a.test_id = 1 union all select b.name from gtable1 b where b.test_id = 1 | schema1 | length{(1)}|
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                         | db      |
#      | conn_1 | False  | select a.name from gtable1 a join gtable1 b on a.test_id = b.test_id where a.test_id = 3                     | schema1 |
#      |conn_1 | False   | select a.name from gtable1 a inner join gtable1 b on a.test_id = b.test_id where a.test_id = 3               | schema1 |
#      |conn_1 | False   |  select a.name from gtable1 a cross join gtable1 b on a.test_id = b.test_id where a.test_id = 3              | schema1 |
#      |conn_1 | False   |  select a.name from gtable1 a STRAIGHT_JOIN gtable1 b on a.test_id = b.test_id where a.test_id = 3           | schema1 |
#      |conn_1 | False   |  select a.name from gtable1 a left join gtable1 b on a.name = b.name where b.test_id = 1                     | schema1 |
#      |conn_1 | False   |  select a.name from gtable1 a right join gtable1 b on a.name = b.name where b.test_id = 1                    | schema1 |
#      |conn_1 | true    |  select a.name from gtable1 a where a.test_id = 1 union all select b.name from gtable1 b where b.test_id = 1 | schema1 |
#
#
#      #shardingTable && shardingTable
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "A"
#      |conn   | toClose | sql                                                                                                                     | db      |
#      |conn_2 | False   | explain select a.name from tabler a left join tabler b on a.id = b.id where a.id = 1                                    | schema1 |
#    Then check resultset "A" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                    |
#      | dn2             | BASE SQL   | select a.name from tabler a left join tabler b on a.id = b.id where a.id = 1 |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                | db      |
#      | conn_2 | False   | select a.name from tabler a left join tabler b on a.id = b.id where a.id = 1       | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "B"
#      |conn   | toClose | sql                                                                                                                     | db      |
#      |conn_2 | False   | explain select a.id from tabler a left join tabler b on a.id = b.id left join tabler c on a.id = c.id where a.id = 1    |schema1  |
#    Then check resultset "B" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                                    |
#      | dn2             | BASE SQL   | select a.id from tabler a left join tabler b on a.id = b.id left join tabler c on a.id = c.id where a.id = 1 |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                | db      |
#      | conn_2 | False   | select a.id from tabler a left join tabler b on a.id = b.id left join tabler c on a.id = c.id where a.id = 1       | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "C"
#      |conn   | toClose | sql                                                                                                                      | db      |
#      |conn_2 | False   | explain select a.name from tabler a right join tabler b on a.id = b.id where a.id = 1                                    | schema1 |
#    Then check resultset "C" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                     |
#      | dn2             | BASE SQL   | select a.name from tabler a right join tabler b on a.id = b.id where a.id = 1 |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                 | db      |
#      | conn_2 | False   | select a.name from tabler a right join tabler b on a.id = b.id where a.id = 1       | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "D"
#      |conn   | toClose | sql                                                                                                                      | db      |
#      |conn_2 | False   | explain select a.id from tabler a left join tabler b on a.id = b.id right join tabler c on a.id = c.id where a.id = 1    |schema1  |
#    Then check resultset "D" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                                     |
#      | dn2             | BASE SQL   | select a.id from tabler a left join tabler b on a.id = b.id right join tabler c on a.id = c.id where a.id = 1 |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                 | db      |
#      | conn_2 | False   | select a.id from tabler a left join tabler b on a.id = b.id right join tabler c on a.id = c.id where a.id = 1       | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "E"
#      |conn   | toClose | sql                                                                                                                      | db      |
#      |conn_2 | False   | explain select a.name from tabler a where a.id = 5 union all select b.name from tabler b where b.id = 1                  | schema1 |
#    Then check resultset "E" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                        |
#      | dn2             | BASE SQL   | select a.name from tabler a where a.id = 5 union all select b.name from tabler b where b.id = 1  |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                   | db      |
#      | conn_2 | False   | select a.name from tabler a where a.id = 5 union all select b.name from tabler b where b.id = 1       | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "F"
#      |conn   | toClose | sql                                                                                                                   | db      |
#      |conn_2 | False   | explain select a.name from tabler a left join tabler b on a.name = b.name and b.id = 2 where a.id = 2                  | schema1 |
#    Then check resultset "F" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                       |
#      | dn3             | BASE SQL   | select a.name from tabler a left join tabler b on a.name = b.name and b.id = 2 where a.id = 2   |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                 | db      |
#      | conn_2 | False   | select a.name from tabler a left join tabler b on a.name = b.name and b.id = 2 where a.id = 2       | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "G"
#      |conn   | toClose | sql                                                                                                                      | db      |
#      |conn_2 | False   | explain select a.name,a.test_id,b.id from tabler a right join tabler b on a.name = b.name and a.id =3 where b.id = 3     |schema1  |
#    Then check resultset "G" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                                    |
#      | dn4             | BASE SQL   | select a.name,a.test_id,b.id from tabler a right join tabler b on a.name = b.name and a.id =3 where b.id = 3 |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                | db      |
#      | conn_2 | False   | select a.name,a.test_id,b.id from tabler a right join tabler b on a.name = b.name and a.id =3 where b.id = 3       | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "H"
#      |conn   | toClose | sql                                                                                                       | db      |
#      |conn_2 | False   | explain select a.name from tabler a inner join tabler b on a.name = b.name where a.id =2 and b.id = 2     |schema1  |
#    Then check resultset "H" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                     |
#      | dn3             | BASE SQL   | select a.name from tabler a inner join tabler b on a.name = b.name where a.id =2 and b.id = 2 |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                 | db      |
#      | conn_2 | False   | select a.name from tabler a inner join tabler b on a.name = b.name where a.id =2 and b.id = 2       | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "I"
#      |conn   | toClose | sql                                                                                                                                                                                                                 | db      |
#      |conn_2 | False   | explain select a.name from tabler a inner join tabler b on a.name = b.name and b.id = 2 where a.id = 2 union all select a.name from tabler a left join tabler b on a.name = b.name and b.id = 2 where a.id = 2     |schema1  |
#    Then check resultset "I" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                                                                                                                              |
#      | dn3             | BASE SQL   | select a.name from tabler a inner join tabler b on a.name = b.name and b.id = 2 where a.id = 2 union all select a.name from tabler a left join tabler b on a.name = b.name and b.id = 2 where a.id = 2 |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
#      | conn_2 | False   | select a.name from tabler a inner join tabler b on a.name = b.name and b.id = 2 where a.id = 2 union all select a.name from tabler a left join tabler b on a.name = b.name and b.id = 2 where a.id = 2    | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "J"
#      |conn   | toClose | sql                                                                                                            | db      |
#      |conn_2 | False   | explain select a.name from tabler a CROSS join tabler b on a.test_id = b.test_id where a.id = 1 and b.id=5     |schema1  |
#    Then check resultset "J" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                          |
#      | dn2             | BASE SQL   | select a.name from tabler a CROSS join tabler b on a.test_id = b.test_id where a.id = 1 and b.id=5 |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                  | db      |
#      | conn_2 | False   | select a.name from tabler a CROSS join tabler b on a.test_id = b.test_id where a.id = 1 and b.id=5   | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "K"
#      |conn   | toClose | sql                                                                                                              | db      |
#      |conn_2 | true    | explain select a.name from tabler a STRAIGHT_JOIN tabler b on a.test_id = b.test_id where a.id = 1 and b.id=5    |schema1  |
#    Then check resultset "K" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                             |
#      | dn2             | BASE SQL   | select a.name from tabler a STRAIGHT_JOIN tabler b on a.test_id = b.test_id where a.id = 1 and b.id=5 |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                     | db      |
#      | conn_2 | False   | select a.name from tabler a STRAIGHT_JOIN tabler b on a.test_id = b.test_id where a.id = 1 and b.id=5   | schema1 |
#
#    #globalTable1 && globaleTable2
#     Given execute sql in "dble-1" in "user" mode
#       |conn   | toClose | sql                                                                                                                 | db      | expect     |
#       |conn_3 | False   | explain select a.name from gtable1 a join gtable2 b on a.test_id = b.test_id where a.test_id=1 and b.test_id=5      | schema1 | length{(1)}|
#       |conn_3 | False   | explain select a.name from gtable1 a inner join gtable2 b on a.test_id = b.test_id where a.test_id=1 and b.test_id=5| schema1 | length{(1)}|
#       |conn_3 | False   | explain select a.name from gtable1 a cross join gtable2 b on a.test_id = b.test_id where a.test_id=1 and b.test_id=5| schema1 | length{(1)}|
#       |conn_3 | False   | explain select a.name from gtable1 a STRAIGHT_JOIN gtable2 b on a.test_id = b.test_id where a.test_id=1 and b.test_id=5| schema1 | length{(1)}|
#       |conn_3 | False   | explain select a.name from gtable1 a left join gtable2 b on a.test_id = b.test_id where a.test_id = 1               | schema1 | length{(1)}|
#       |conn_3 | False   | explain select a.name from gtable1 a right join gtable2 b on a.test_id = b.test_id where a.test_id = 1              | schema1 | length{(1)}|
#       |conn_3 | False   | explain select a.name from gtable1 a where a.test_id = 5 union all select b.name from gtable2 b where b.test_id = 1 | schema1 | length{(1)}|
#       |conn_3 | False   | explain select a.name from gtable1 a join gtable2 b on a.test_id = b.test_id join gtable1 c on a.test_id = c.test_id where a.test_id = 1 | schema1 | length{(1)}|
#       |conn_3 | False   | explain select a.name from gtable1 a inner join gtable2 b on a.test_id = b.test_id inner join gtable1 c on a.test_id = c.test_id where a.test_id = 1 | schema1 | length{(1)}|
#       |conn_3 | False   | explain select a.name from gtable1 a CROSS join gtable2 b on a.test_id = b.test_id CROSS join gtable1 c on a.test_id = c.test_id where a.test_id = 1 | schema1 | length{(1)}|
#       |conn_3 | true    | explain select a.name from gtable1 a STRAIGHT_JOIN gtable2 b on a.test_id = b.test_id STRAIGHT_JOIN gtable1 c on a.test_id = c.test_id where a.test_id = 1| schema1 | length{(1)}|
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                                        | db      |
#       | conn_3 | False   |select a.name from gtable1 a join gtable2 b on a.test_id = b.test_id where a.test_id=1 and b.test_id=5                                      | schema1 |
#       | conn_3 | False   |select a.name from gtable1 a inner join gtable2 b on a.test_id = b.test_id where a.test_id=1 and b.test_id=5                                | schema1 |
#       | conn_3 | False   |select a.name from gtable1 a cross join gtable2 b on a.test_id = b.test_id where a.test_id=1 and b.test_id=5                                | schema1 |
#       | conn_3 | False   |select a.name from gtable1 a STRAIGHT_JOIN gtable2 b on a.test_id = b.test_id where a.test_id=1 and b.test_id=5                             | schema1 |
#       | conn_3 | False   |select a.name from gtable1 a left join gtable2 b on a.test_id = b.test_id where a.test_id = 1                                               | schema1 |
#       | conn_3 | False   |select a.name from gtable1 a right join gtable2 b on a.test_id = b.test_id where a.test_id = 1                                              | schema1 |
#       | conn_3 | False   |select a.name from gtable1 a where a.test_id = 5 union all select b.name from gtable2 b where b.test_id = 1                                 | schema1 |
#       | conn_3 | False   |select a.name from gtable1 a join gtable2 b on a.test_id = b.test_id join gtable1 c on a.test_id = c.test_id where a.test_id = 1            | schema1 |
#       | conn_3 | False   |select a.name from gtable1 a inner join gtable2 b on a.test_id = b.test_id inner join gtable1 c on a.test_id = c.test_id where a.test_id = 1| schema1 |
#       | conn_3 | False   | select a.name from gtable1 a CROSS join gtable2 b on a.test_id = b.test_id CROSS join gtable1 c on a.test_id = c.test_id where a.test_id = 1| schema1 |
#       | conn_3 | False   |select a.name from gtable1 a STRAIGHT_JOIN gtable2 b on a.test_id = b.test_id STRAIGHT_JOIN gtable1 c on a.test_id = c.test_id where a.test_id = 1     | schema1 |
#
#    #globalTable && shardingTable
#    # exists issue :http://10.186.18.11/jira/browse/DBLE0REQ-1241, wait to update here
#     Given execute single sql in "dble-1" in "user" mode and save resultset in "L"
#       |conn   | toClose | sql                                                                                        | db      |
#       |conn_4 | False  | explain select a.name from gtable1 a join tabler b on a.test_id = b.test_id where b.id=5    |schema1  |
#     Then check resultset "L" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                       |
#       | dn2             | BASE SQL   | select a.name from gtable1 a join tabler b on a.test_id = b.test_id where b.id=5|
#     Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                  | db      |
#       | conn_4 | False   |select a.name from gtable1 a join tabler b on a.test_id = b.test_id where b.id=5                                      | schema1 |
#
#     Given execute single sql in "dble-1" in "user" mode and save resultset in "M"
#       |conn   | toClose | sql                                                                                              | db      |
#       |conn_4 | False  | explain select a.name from gtable1 a inner join tabler b on a.test_id = b.test_id where b.id=5    |schema1  |
#     Then check resultset "M" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                             |
#       | dn2             | BASE SQL   | select a.name from gtable1 a inner join tabler b on a.test_id = b.test_id where b.id=5|
#     Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                  | db      |
#       | conn_4 | False   |select a.name from gtable1 a inner join tabler b on a.test_id = b.test_id where b.id=5                                | schema1 |
#
#     Given execute single sql in "dble-1" in "user" mode and save resultset in "N"
#       |conn   | toClose | sql                                                                                              | db      |
#       |conn_4 | False  | explain select a.name from gtable1 a cross join tabler b on a.test_id = b.test_id where b.id=5    |schema1  |
#     Then check resultset "N" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                             |
#       | dn2             | BASE SQL   | select a.name from gtable1 a cross join tabler b on a.test_id = b.test_id where b.id=5|
#     Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                  | db      |
#       | conn_4 | False   |select a.name from gtable1 a cross join tabler b on a.test_id = b.test_id where b.id=5                                | schema1 |
#
#     Given execute single sql in "dble-1" in "user" mode and save resultset in "O"
#       |conn   | toClose | sql                                                                                                 | db      |
#       |conn_4 | False  | explain select a.name from gtable1 a STRAIGHT_JOIN tabler b on a.test_id = b.test_id where b.id=5    |schema1  |
#     Then check resultset "O" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                |
#       | dn2             | BASE SQL   | select a.name from gtable1 a STRAIGHT_JOIN tabler b on a.test_id = b.test_id where b.id=5|
#     Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                  | db      |
#       | conn_4 | False   |select a.name from gtable1 a STRAIGHT_JOIN tabler b on a.test_id = b.test_id where b.id=5                             | schema1 |
#
#    #shardingTable && childTable
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "P"
#       |conn   | toClose | sql                                                                                                     | db      |
#       |conn_5 | False   |explain select a.name from tabler a join ctable b on a.test_id = b.test_id where a.id=1 and b.fid=5      |schema1  |
#    Then check resultset "P" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                  |
#       | dn2             | BASE SQL   | select a.name from tabler a join ctable b on a.test_id = b.test_id where a.id=1 and b.fid=5|
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                  | db      |
#       | conn_5 | False   |select a.name from tabler a join ctable b on a.test_id = b.test_id where a.id=1 and b.fid=5                            | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "Q"
#       |conn   | toClose | sql                                                                                                           | db      |
#       |conn_5 | False   |explain select a.name from tabler a inner join ctable b on a.test_id = b.test_id where a.id=1 and b.fid=5      |schema1  |
#    Then check resultset "Q" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                        |
#       | dn2             | BASE SQL   | select a.name from tabler a inner join ctable b on a.test_id = b.test_id where a.id=1 and b.fid=5|
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                         | db      |
#       | conn_5 | False   |select a.name from tabler a inner join ctable b on a.test_id = b.test_id where a.id=1 and b.fid=5                            | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "R"
#       |conn   | toClose | sql                                                                                                           | db      |
#       |conn_5 | False   |explain select a.name from tabler a cross join ctable b on a.test_id = b.test_id where a.id=1 and b.fid=5      |schema1  |
#    Then check resultset "R" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                        |
#       | dn2             | BASE SQL   | select a.name from tabler a cross join ctable b on a.test_id = b.test_id where a.id=1 and b.fid=5|
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                         | db      |
#       | conn_5 | False   |select a.name from tabler a cross join ctable b on a.test_id = b.test_id where a.id=1 and b.fid=5                            | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "S"
#       |conn   | toClose | sql                                                                                                              | db      |
#       |conn_5 | False   |explain select a.name from tabler a STRAIGHT_JOIN ctable b on a.test_id = b.test_id where a.id=1 and b.fid=5      |schema1  |
#    Then check resultset "S" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                            |
#       | dn2             | BASE SQL   | select a.name from tabler a STRAIGHT_JOIN ctable b on a.test_id = b.test_id where a.id=1 and b.fid=5|
#   Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                            | db      |
#       | conn_5 | False   |select a.name from tabler a STRAIGHT_JOIN ctable b on a.test_id = b.test_id where a.id=1 and b.fid=5                            | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "T"
#       |conn   | toClose | sql                                                                                                                 | db      |
#       |conn_5 | False   |explain select a.fid from ctable a join tabler b on a.fid = b.id join ctable c on a.fid = c.fid where a.fid = 1      |schema1  |
#    Then check resultset "T" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                        |
#       | dn2             | BASE SQL   | select a.fid from ctable a join tabler b on a.fid = b.id join ctable c on a.fid = c.fid where a.fid = 1|
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                              | db      |
#       | conn_5 | False   |select a.fid from ctable a join tabler b on a.fid = b.id join ctable c on a.fid = c.fid where a.fid = 1                           | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "TT"
#       |conn   | toClose | sql                                                                                                       | db      |
#       |conn_5 | False   |explain select a.name from tabler a join ctable b on a.name=b.name and a.id=1 and b.fid=1 where a.id=1     |schema1  |
#    Then check resultset "TT" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                     |
#       | dn2             | BASE SQL   | select a.name from tabler a join ctable b on a.name=b.name and a.id=1 and b.fid=1 where a.id=1|
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                    | db      |
#       | conn_5 | False   |select a.name from tabler a join ctable b on a.name=b.name and a.id=1 and b.fid=1 where a.id=1                          | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "U"
#       |conn   | toClose | sql                                                                                       | db      |
#       |conn_5 | False   | explain select a.name from tabler a left join ctable b on a.id = b.fid where a.id = 1     |schema1  |
#    Then check resultset "U" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                    |
#       | dn2             | BASE SQL   | select a.name from tabler a left join ctable b on a.id = b.fid where a.id = 1|
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                   | db      |
#       | conn_5 | False   |select a.name from tabler a left join ctable b on a.id = b.fid where a.id = 1                          | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "V"
#       |conn   | toClose | sql                                                                                        | db      |
#       |conn_5 | False   | explain select a.name from tabler a right join ctable b on a.id = b.fid where a.id = 1     |schema1  |
#    Then check resultset "V" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                     |
#       | dn2             | BASE SQL   | select a.name from tabler a right join ctable b on a.id = b.fid where a.id = 1|
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                   | db      |
#       | conn_5 | False   |select a.name from tabler a right join ctable b on a.id = b.fid where a.id = 1                          | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "W"
#       |conn   | toClose | sql                                                                                                         | db      |
#       |conn_5 | False   | explain select a.name from tabler a where a.id = 5 union all select b.name from ctable b where b.fid = 1    |schema1  |
#    Then check resultset "W" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                        |
#       | dn2             | BASE SQL   | select a.name from tabler a where a.id = 5 union all select b.name from ctable b where b.fid = 1 |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                   | db      |
#       | conn_5 | False   |select a.name from tabler a where a.id = 5 union all select b.name from ctable b where b.fid = 1       | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "X"
#       |conn   | toClose | sql                                                                                                                                                                                                                 | db      |
#       |conn_5 | False   | explain select a.name from tabler a inner join ctable b on a.name = b.name and b.fid = 2 where a.id = 2 union all select a.name from  tabler a inner join ctable b on a.name = b.name and b.fid = 2 where a.id = 2  |schema1  |
#    Then check resultset "X" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                       |
#       | dn3             | BASE SQL   | select a.name from tabler a inner join ctable b on a.name = b.name and b.fid = 2 where a.id = 2 union all select a.name from  tabler a inner join ctable b on a.name = b.name and b.fid = 2 where a.id = 2|
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                                                                                                             | db      |
#       | conn_5 | False   |select a.name from tabler a inner join ctable b on a.name = b.name and b.fid = 2 where a.id = 2 union all select a.name from  tabler a inner join ctable b on a.name = b.name and b.fid = 2 where a.id = 2       | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "Y"
#       |conn   | toClose | sql                                                                                                       | db      |
#       |conn_5 | False   | explain select name from tabler where id = 5  and test_id = (select test_id from ctable where fid = 5)    |schema1  |
#    Then check resultset "Y" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                       |
#       | dn2             | BASE SQL   | select name from tabler where id = 5  and test_id = (select test_id from ctable where fid = 5)  |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                   | db      |
#       | conn_5 | False   |select name from tabler where id = 5  and test_id = (select test_id from ctable where fid = 5)       | schema1 |
#
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "Z"
#       |conn   | toClose | sql                                                                                                                                                                                         | db      |
#       |conn_5 | False   | explain select a.fid from ctable a join tabler b on a.fid = b.id where a.fid=(select min(test_id) from ctable c where c.fid=1) and b.id=(select min(test_id) from tabler d where d.id=1)    |schema1  |
#    Then check resultset "Z" has lines with following column values
#       | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                                                                                                         |
#       | dn2             | BASE SQL   | select a.fid from ctable a join tabler b on a.fid = b.id where a.fid=(select min(test_id) from ctable c where c.fid=1) and b.id=(select min(test_id) from tabler d where d.id=1)  |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#       | conn   | toClose | sql                                                                                                                                                                                   | db      |
#       | conn_5 | False   |select a.fid from ctable a join tabler b on a.fid = b.id where a.fid=(select min(test_id) from ctable c where c.fid=1) and b.id=(select min(test_id) from tabler d where d.id=1)       | schema1 |
#
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                                                                    | expect  | db      |
#      | conn_6 | False   | drop table if exists gtable1                                                           | success | schema1 |
#      | conn_6 | False   | drop table if exists gtable2                                                           | success | schema1 |
#      | conn_6 | False   | drop table if exists ctable                                                            | success | schema1 |
#      | conn_6 | true    | drop table if exists tabler                                                            | success | schema1 |
#    Then execute sql in "mysql" in "mysql" mode
#      | conn   | toClose | sql                                                                                    | expect  | db      |
#      | conn_6 | False   | drop table if exists gtable1                                                           | success | schema1 |
#      | conn_6 | False   | drop table if exists gtable2                                                           | success | schema1 |
#      | conn_6 | False   | drop table if exists ctable                                                            | success | schema1 |
#      | conn_6 | true    | drop table if exists tabler                                                            | success | schema1 |