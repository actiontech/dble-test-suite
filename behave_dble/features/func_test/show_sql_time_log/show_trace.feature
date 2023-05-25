# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/24
# Created by Rita at 2019/3/29

Feature: verify  function of "show trace" and   track SQL and analyze SQL execution

  ## 2.19.11.0#dble-7872
  ##功能为session 级别。
  ##select @@trace;set trace =1;
  ##todo:其他用户

   Scenario: turn on mysql trace and analyze sql with trace #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                         | expect      | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                          | success     | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20))                                         | success     | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,'test1'),(2,'test2'),(3,'test3'),(4,'test4'),(5,'test5') | success     | schema1 |
      | conn_0 | False   | set @@trace=1                                                                               | success     | schema1 |
      | conn_0 | False   | select @@trace                                                                              | has{(('1',),)}  | schema1 |
      | conn_0 | False   | select * from sharding_4_t1 where id=1                                                      | length{(1)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_A"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_A" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                          |
      | Execute_SQL  | dn2         | select * from sharding_4_t1 where id=1 |
      | Fetch_result | dn2         | select * from sharding_4_t1 where id=1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                         | expect      | db      |
      | test | 111111 | conn_0 | False   | select * from sharding_4_t1 | length{(5)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_B"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_B" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                             |
      | Execute_SQL  | dn1             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Execute_SQL  | dn2             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Execute_SQL  | dn3             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Execute_SQL  | dn4             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Fetch_result | dn1             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Fetch_result | dn2             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Fetch_result | dn3             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Fetch_result | dn4             | SELECT * FROM sharding_4_t1 LIMIT 100 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                           | expect  | db      |
      | conn_0 | False   | insert into sharding_4_t1 values(30,'test30') | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_C"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_C" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                       |
      | Execute_SQL  | dn3             | INSERT INTO sharding_4_t1 VALUES (30, 'test30') |
      | Fetch_result | dn3             | INSERT INTO sharding_4_t1 VALUES (30, 'test30') |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect     | db      |
      | conn_0 | False   | select count(*) from sharding_4_t1 | balance{6} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_D"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_D" has lines with following column values
      | OPERATION-0   | SHARDING_NODE-4     | SQL/REF-5                                                            |
      | Execute_SQL   | dn1_0               | select count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Fetch_result  | dn1_0               | select count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Execute_SQL   | dn2_0               | select count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Fetch_result  | dn2_0               | select count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Execute_SQL   | dn3_0               | select count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Fetch_result  | dn3_0               | select count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Execute_SQL   | dn4_0               | select count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Fetch_result  | dn4_0               | select count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | MERGE         | merge_1             | dn1_0; dn2_0; dn3_0; dn4_0                                           |
      | AGGREGATE     | aggregate_1         | merge_1                                                              |
      | LIMIT         | limit_1             | aggregate_1                                                          |
      | SHUFFLE_FIELD | shuffle_field_1     | limit_1                                                              |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                    | expect     | db      |
      | test | 111111 | conn_0 | False   | select count(*) from sharding_4_t1 where id =(select id from sharding_4_t1 where id=1) | balance{1} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_E"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_E" has lines with following column values
      | OPERATION-0      | SHARDING_NODE-4    | SQL/REF-5                                                                                                      |
      | Execute_SQL      | dn2_0              | select `sharding_4_t1`.`id` as `autoalias_scalar` from  `sharding_4_t1` where `sharding_4_t1`.`id` = 1 LIMIT 2 |
      | Fetch_result     | dn2_0              | select `sharding_4_t1`.`id` as `autoalias_scalar` from  `sharding_4_t1` where `sharding_4_t1`.`id` = 1 LIMIT 2 |
      | MERGE            | merge_1            | dn2_0                                                                                                          |
      | LIMIT            | limit_1            | merge_1                                                                                                        |
      | SHUFFLE_FIELD    | shuffle_field_1    | limit_1                                                                                                        |
      | SCALAR_SUB_QUERY | scalar_sub_query_1 | shuffle_field_1                                                                                                |
      | Execute_SQL      | dn2_1              | scalar_sub_query_1; select count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` where `sharding_4_t1`.`id` = 1  |
      | Fetch_result     | dn2_1              | scalar_sub_query_1; select count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` where `sharding_4_t1`.`id` = 1  |
      | MERGE            | merge_2            | dn2_1                                                                                                          |
      | AGGREGATE        | aggregate_1        | merge_2                                                                                                        |
      | SHUFFLE_FIELD    | shuffle_field_2    | aggregate_1                                                                                                    |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                      | expect                               | db      |
      #case DBLE0REQ-257: if an illegal command is executed before 'show trace' is executed, execute 'show trace' don't returns to NPE
      | conn_0 | False   | show @@trace             | You have an error in your SQL syntax | schema1 |
      | conn_0 | False   | show trace               | success | schema1 |
      | conn_0 | true    | drop table sharding_4_t1 | success | schema1 |

    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"



  Scenario: "show trace" should return results after executing "join" with right table contains a lot of useless data  github issue #1058 #2

     Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
            <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
            <shardingTable name="sharding_2_t2" shardingNode="dn3,dn4" function="hash-two" shardingColumn="id" />
        </schema>
      """
    Then execute admin cmd "reload @@config"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                               | expect   | db      |
      | conn_0 | False    | drop table if exists sharding_2_t1                | success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t2                | success  | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int,name char(20))  | success  | schema1 |
      | conn_0 | False    | create table sharding_2_t2(id int,name char(20))  | success  | schema1 |
      | conn_0 | False    | insert into sharding_2_t1 values(1,'namea')       | success  | schema1 |
      | conn_0 | False     | insert into sharding_2_t1 values(1,'nameb')      | success  | schema1 |
    Then connect "dble-1" to insert "10000" of data for "sharding_2_t2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                | expect       | db      |
      | conn_0 | False    | set trace=1                                                        | success      | schema1 |
      | conn_0 | False    | select * from sharding_2_t1 a,sharding_2_t2 b where a.id = b.id    | success      | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_E"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_E" has lines with following column values
      | OPERATION-0           | SHARDING_NODE-4   | SQL/REF-5                                                                  |
      | Read_SQL              | -                 | -                                                                          |
      | Parse_SQL             | -                 | -                                                                          |
      | Try_Route_Calculation | -                 | -                                                                          |
      | Try_to_Optimize       | -                 | -                                                                          |
      | Execute_SQL           | dn1_0             | select `a`.`id`,`a`.`name` from  `sharding_2_t1` `a` ORDER BY `a`.`id` ASC |
      | Fetch_result          | dn1_0             | select `a`.`id`,`a`.`name` from  `sharding_2_t1` `a` ORDER BY `a`.`id` ASC |
      | Execute_SQL           | dn2_0             | select `a`.`id`,`a`.`name` from  `sharding_2_t1` `a` ORDER BY `a`.`id` ASC |
      | Fetch_result          | dn2_0             | select `a`.`id`,`a`.`name` from  `sharding_2_t1` `a` ORDER BY `a`.`id` ASC |
      | MERGE_AND_ORDER       | merge_and_order_1 | dn1_0; dn2_0                                                               |
      | SHUFFLE_FIELD         | shuffle_field_1   | merge_and_order_1                                                          |
      | Execute_SQL           | dn3_0             | select `b`.`id`,`b`.`name` from  `sharding_2_t2` `b` ORDER BY `b`.`id` ASC |
      | Fetch_result          | dn3_0             | select `b`.`id`,`b`.`name` from  `sharding_2_t2` `b` ORDER BY `b`.`id` ASC |
      | Execute_SQL           | dn4_0             | select `b`.`id`,`b`.`name` from  `sharding_2_t2` `b` ORDER BY `b`.`id` ASC |
      | Fetch_result          | dn4_0             | select `b`.`id`,`b`.`name` from  `sharding_2_t2` `b` ORDER BY `b`.`id` ASC |
      | MERGE_AND_ORDER       | merge_and_order_2 | dn3_0; dn4_0                                                               |
      | SHUFFLE_FIELD         | shuffle_field_3   | merge_and_order_2                                                          |
      | JOIN                  | join_1            | shuffle_field_1; shuffle_field_3                                           |
      | SHUFFLE_FIELD         | shuffle_field_2   | join_1                                                                     |
      | Write_to_Client       | -                 | -                                                                          |
      | Over_All              | -                 | -                                                                          |