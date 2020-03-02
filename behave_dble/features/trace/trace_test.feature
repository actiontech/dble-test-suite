# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/24

Feature: track SQL and analyze SQL execution

  Scenario: turn on mysql trace and analyze sql with trace #1
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                         | expect      | db      |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_4_t1                                                          | success     | schema1 |
      | test | 111111 | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20))                                         | success     | schema1 |
      | test | 111111 | conn_0 | False   | insert into sharding_4_t1 values(1,'test1'),(2,'test2'),(3,'test3'),(4,'test4'),(5,'test5') | success     | schema1 |
      | test | 111111 | conn_0 | False   | set @@trace=1                                                                               | success     | schema1 |
      | test | 111111 | conn_0 | False   | select @@trace                                                                              | balance{1}  | schema1 |
      | test | 111111 | conn_0 | False   | select * from sharding_4_t1 where id=1                                                      | length{(1)} | schema1 |
    Then get resultset of user cmd "show trace" named "rs_A" with connection "conn_0"
    Then check resultset "rs_A" has lines with following column values
      | OPERATION-0  | DATA_NODE-4 | SQL/REF-5                                          |
      | Execute_SQL  | dn2         | SELECT * FROM sharding_4_t1 WHERE id = 1 LIMIT 100 |
      | Fetch_result | dn2         | SELECT * FROM sharding_4_t1 WHERE id = 1 LIMIT 100 |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                         | expect      | db      |
      | test | 111111 | conn_0 | False   | select * from sharding_4_t1 | length{(5)} | schema1 |
    Then get resultset of user cmd "show trace" named "rs_B" with connection "conn_0"
    Then check resultset "rs_B" has lines with following column values
      | OPERATION-0  | DATA_NODE-4 | SQL/REF-5                             |
      | Execute_SQL  | dn1         | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Execute_SQL  | dn2         | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Execute_SQL  | dn3         | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Execute_SQL  | dn4         | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Fetch_result | dn1         | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Fetch_result | dn2         | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Fetch_result | dn3         | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Fetch_result | dn4         | SELECT * FROM sharding_4_t1 LIMIT 100 |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db      |
      | test | 111111 | conn_0 | False   | insert into sharding_4_t1 values(30,'test30') | success | schema1 |
    Then get resultset of user cmd "show trace" named "rs_C" with connection "conn_0"
    Then check resultset "rs_C" has lines with following column values
      | OPERATION-0  | DATA_NODE-4 | SQL/REF-5                                       |
      | Execute_SQL  | dn3         | INSERT INTO sharding_4_t1 VALUES (30, 'test30') |
      | Fetch_result | dn3         | INSERT INTO sharding_4_t1 VALUES (30, 'test30') |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect     | db      |
      | test | 111111 | conn_0 | False   | select count(*) from sharding_4_t1 | balance{6} | schema1 |
    Then get resultset of user cmd "show trace" named "rs_D" with connection "conn_0"
    Then check resultset "rs_D" has lines with following column values
      | OPERATION-0   | DATA_NODE-4     | SQL/REF-5                                                            |
      | Fetch_result  | dn1_0           | select COUNT(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Execute_SQL   | dn2_0           | select COUNT(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Fetch_result  | dn2_0           | select COUNT(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Execute_SQL   | dn3_0           | select COUNT(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Fetch_result  | dn3_0           | select COUNT(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Execute_SQL   | dn4_0           | select COUNT(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | Fetch_result  | dn4_0           | select COUNT(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` LIMIT 100 |
      | MERGE         | merge_1         | dn1_0; dn2_0; dn3_0; dn4_0                                           |
      | AGGREGATE     | aggregate_1     | merge_1                                                              |
      | LIMIT         | limit_1         | aggregate_1                                                          |
      | SHUFFLE_FIELD | shuffle_field_1 | limit_1                                                              |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                    | expect     | db      |
      | test | 111111 | conn_0 | False   | select count(*) from sharding_4_t1 where id =(select id from sharding_4_t1 where id=1) | balance{1} | schema1 |
    Then get resultset of user cmd "show trace" named "rs_E" with connection "conn_0"
    Then check resultset "rs_E" has lines with following column values
      | OPERATION-0      | DATA_NODE-4        | SQL/REF-5                                                                                                      |
      | Execute_SQL      | dn2_0              | select `sharding_4_t1`.`id` as `autoalias_scalar` from  `sharding_4_t1` where `sharding_4_t1`.`id` = 1 LIMIT 2 |
      | Fetch_result     | dn2_0              | select `sharding_4_t1`.`id` as `autoalias_scalar` from  `sharding_4_t1` where `sharding_4_t1`.`id` = 1 LIMIT 2 |
      | MERGE            | merge_1            | dn2_0                                                                                                          |
      | LIMIT            | limit_1            | merge_1                                                                                                        |
      | SHUFFLE_FIELD    | shuffle_field_1    | limit_1                                                                                                        |
      | SCALAR_SUB_QUERY | scalar_sub_query_1 | shuffle_field_1                                                                                                |
      | Execute_SQL      | dn2_1              | scalar_sub_query_1; select COUNT(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` where `sharding_4_t1`.`id` = 1  |
      | Fetch_result     | dn2_1              | scalar_sub_query_1; select COUNT(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` where `sharding_4_t1`.`id` = 1  |
      | MERGE            | merge_2            | dn2_1                                                                                                          |
      | AGGREGATE        | aggregate_1        | merge_2                                                                                                        |
      | SHUFFLE_FIELD    | shuffle_field_2    | aggregate_1                                                                                                    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                      | expect  | db      |
      | test | 111111 | conn_0 | true    | drop table sharding_4_t1 | success | schema1 |