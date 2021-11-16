# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2021/8/2

  #DBLE0REQ-911
Feature: The impact of testing operators on shardingTable routing

  Scenario: group by and order by‘s sharding column condition should not take as routing condition   #1

    #prepare the test sharding table
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                         | db      |
      | conn_0  | False   |drop table if exists sharding_2_t1                           | schema1 |
      | conn_0  | False   |create table sharding_2_t1(id int, a int)                    | schema1 |
      | conn_0  | true    |insert into sharding_2_t1 values(1,1),(2,2),(3,3),(4,4),(5,5)| schema1 |
    # group by [id condition]
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                     | db    | expect |
      | conn_1  | False   | select count(id) from sharding_2_t1 group by id=1       |schema1| has{((4,),(1,))}|
    Given execute single sql in "dble-1" in "user" mode and save resultset in "A"
      | conn     | toClose | sql                                                        | db      |
      | conn_1   | true    | explain select count(id) from sharding_2_t1 group by id=1  | schema1 |

# for DBLE0REQ-1467 begin
#    Then check resultset "A" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                               |
#      | dn1_0             | BASE SQL        | select count(id) as `_$COUNT$_rpda_0`,id = 1 as `rpda_1`,sharding_2_t1.id = 1 as `rpda_2` from  `sharding_2_t1` GROUP BY `sharding_2_t1`.`id` = 1 ORDER BY `sharding_2_t1`.`id` = 1 ASC |
#      | dn2_0             | BASE SQL        | select count(id) as `_$COUNT$_rpda_0`,id = 1 as `rpda_1`,sharding_2_t1.id = 1 as `rpda_2` from  `sharding_2_t1` GROUP BY `sharding_2_t1`.`id` = 1 ORDER BY `sharding_2_t1`.`id` = 1 ASC |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                            |
#      | aggregate_1       | AGGREGATE       | merge_and_order_1                                                                                                                                                                       |
#      | order_1           | ORDER           | aggregate_1                                                                                                                                                                             |
#      | limit_1           | LIMIT           | order_1                                                                                                                                                                                 |
#      | shuffle_field_1   | SHUFFLE_FIELD   | limit_1                                                                                                                                                                                 |
# for DBLE0REQ-1467 end

    #group by id having [ id condition ]
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                               | db    | expect      |
      | conn_2  | False   | select count(id) from sharding_2_t1 group by id having id=1       |schema1| has{((1,),)}|
    Given execute single sql in "dble-1" in "user" mode and save resultset in "B"
      | conn     | toClose | sql                                                                  | db      |
      | conn_2   | true    | explain select count(id) from sharding_2_t1 group by id having id=1  | schema1 |
    Then check resultset "B" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                       |
      | dn1_0             | BASE SQL        | select count(id) as `_$COUNT$_rpda_0`,`sharding_2_t1`.`id` from  `sharding_2_t1` where `sharding_2_t1`.`id` = 1 GROUP BY `sharding_2_t1`.`id` ORDER BY `sharding_2_t1`.`id` ASC |
      | dn2_0             | BASE SQL        | select count(id) as `_$COUNT$_rpda_0`,`sharding_2_t1`.`id` from  `sharding_2_t1` where `sharding_2_t1`.`id` = 1 GROUP BY `sharding_2_t1`.`id` ORDER BY `sharding_2_t1`.`id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                    |
      | aggregate_1       | AGGREGATE       | merge_and_order_1                                                                                                                                                               |
      | limit_1           | LIMIT           | aggregate_1                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   |  limit_1                                                                                                                                                                        |
    #group by id having [ subquery ]
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                                                                  | db    | expect                         |
      | conn_3  | False   | select count(id) from sharding_2_t1 group by id having select id from sharding_2_t1 where id=1       |schema1| has{((1,),(1,),(1,),(1,),(1,))}|
    Given execute single sql in "dble-1" in "user" mode and save resultset in "C"
      | conn     | toClose | sql                                                                                                     | db      |
      | conn_3   | true    | explain select count(id) from sharding_2_t1 group by id having select id from sharding_2_t1 where id=1  | schema1 |
    Then check resultset "C" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                       |
      | dn2_0              | BASE SQL              | select `sharding_2_t1`.`id` as `autoalias_scalar` from  `sharding_2_t1` where `sharding_2_t1`.`id` = 1 LIMIT 2                                                           |
      | merge_1            | MERGE                 | dn2_0                                                                                                                                                                    |
      | limit_1            | LIMIT                 | merge_1                                                                                                                                                                  |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                                                                                  |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                                                                                          |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select count(id) as `_$COUNT$_rpda_0`,`sharding_2_t1`.`id` from  `sharding_2_t1` where '{NEED_TO_REPLACE}' GROUP BY `sharding_2_t1`.`id` ORDER BY `sharding_2_t1`.`id` ASC |
      | dn2_1              | BASE SQL(May No Need) | scalar_sub_query_1; select count(id) as `_$COUNT$_rpda_0`,`sharding_2_t1`.`id` from  `sharding_2_t1` where '{NEED_TO_REPLACE}' GROUP BY `sharding_2_t1`.`id` ORDER BY `sharding_2_t1`.`id` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER       | dn1_0; dn2_1                                                                                                                                                                                   |
      | aggregate_1        | AGGREGATE             | merge_and_order_1                                                                                                                                                                              |
      | shuffle_field_2    | SHUFFLE_FIELD         | aggregate_1                                                                                                                                                                                    |
      #group by id in [ id condition ]
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                               | db    | expect          |
      | conn_4  | False   | select count(id) from sharding_2_t1 group by id in(1)             |schema1| has{((4,),(1,))}|
    Given execute single sql in "dble-1" in "user" mode and save resultset in "D"
      | conn     | toClose | sql                                                                  | db      |
      | conn_4   | true    | explain select count(id) from sharding_2_t1 group by id in(1)        | schema1 |

# for DBLE0REQ-1467 begin
#    Then check resultset "D" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                           |
#      | dn1_0             | BASE SQL        | select count(id) as `_$COUNT$_rpda_0`,id IN (1) as `rpda_1`,sharding_2_t1.id IN (1) as `rpda_2` from  `sharding_2_t1` GROUP BY `sharding_2_t1`.`id` in (1) ORDER BY `sharding_2_t1`.`id` in (1) ASC |
#      | dn2_0             | BASE SQL        | select count(id) as `_$COUNT$_rpda_0`,id IN (1) as `rpda_1`,sharding_2_t1.id IN (1) as `rpda_2` from  `sharding_2_t1` GROUP BY `sharding_2_t1`.`id` in (1) ORDER BY `sharding_2_t1`.`id` in (1) ASC |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                        |
#      | order_1           | ORDER           | aggregate_1                                                                                                                                                                                         |
#      | limit_1           | LIMIT           | order_1                                                                                                                                                                                             |
#      | shuffle_field_1   | SHUFFLE_FIELD   | limit_1                                                                                                                                                                                             |
# for DBLE0REQ-1467 end

     #order by [id condition]
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                             | db    | expect                              |
      | conn_5  | False   | select * from sharding_2_t1 order by id=1       |schema1| has{((2,2),(4,4),(3,3),(5,5),(1,1))}|
    Given execute single sql in "dble-1" in "user" mode and save resultset in "E"
      | conn     | toClose | sql                                                | db      |
      | conn_5   | true    | explain select * from sharding_2_t1 order by id=1  | schema1 |
    Then check resultset "E" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                |
      | dn1_0             | BASE SQL        | select `sharding_2_t1`.`id`,`sharding_2_t1`.`a`,id = 1 as `rpda_0` from  `sharding_2_t1` ORDER BY `sharding_2_t1`.`id` = 1 ASC LIMIT 100 |
      | dn2_0             | BASE SQL        | select `sharding_2_t1`.`id`,`sharding_2_t1`.`a`,id = 1 as `rpda_0` from  `sharding_2_t1` ORDER BY `sharding_2_t1`.`id` = 1 ASC LIMIT 100 |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                             |
      | limit_1           | LIMIT           | merge_and_order_1                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | limit_1                                                                                                                                  |
      #order by id [in condition]
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                  | db    | expect                              |
      | conn_6  | False   | select * from sharding_2_t1 order by id in(1)        |schema1| has{((3,3),(5,5),(2,2),(4,4),(1,1))}|
    Given execute single sql in "dble-1" in "user" mode and save resultset in "F"
      | conn     | toClose | sql                                                | db      |
      | conn_6   | true    | explain select * from sharding_2_t1 order by id in(1)  | schema1 |
    Then check resultset "F" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                      |
      | dn1_0             | BASE SQL        | select `sharding_2_t1`.`id`,`sharding_2_t1`.`a`,id IN (1) as `rpda_0` from  `sharding_2_t1` ORDER BY `sharding_2_t1`.`id` in (1) ASC LIMIT 100 |
      | dn2_0             | BASE SQL        | select `sharding_2_t1`.`id`,`sharding_2_t1`.`a`,id IN (1) as `rpda_0` from  `sharding_2_t1` ORDER BY `sharding_2_t1`.`id` in (1) ASC LIMIT 100 |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                   |
      | limit_1           | LIMIT           | merge_and_order_1                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | limit_1                                                                                                                                        |

  Scenario: Extract some operators as where sharding column condition to verify no impact on routing     #2
     # not
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                              | db    | expect                              |
      | conn_7  | False   | select * from sharding_2_t1 where not id=1       |schema1| has{((3,3),(5,5),(2,2),(4,4))}      |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "G"
      | conn     | toClose | sql                                                  | db      |
      | conn_7   | true    | explain  select * from sharding_2_t1 where not id=1  | schema1 |
    Then check resultset "G" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                              |
      | dn1               | BASE SQL        | SELECT * FROM sharding_2_t1 WHERE NOT id = 1 LIMIT 100 |
      | dn2               | BASE SQL        | SELECT * FROM sharding_2_t1 WHERE NOT id = 1 LIMIT 100 |
    # !
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                              | db    | expect                              |
      | conn_8  | False   | select * from sharding_2_t1 where id !=1         |schema1| has{((3,3),(5,5),(2,2),(4,4))}      |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "H"
      | conn     | toClose | sql                                                  | db      |
      | conn_8   | true    | explain  select * from sharding_2_t1 where id !=1    | schema1 |
    Then check resultset "H" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                           |
      | dn1               | BASE SQL        | SELECT * FROM sharding_2_t1 WHERE id != 1 LIMIT 100 |
      | dn2               | BASE SQL        | SELECT * FROM sharding_2_t1 WHERE id != 1 LIMIT 100 |
    # or
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                     | db    | expect                                    |
      | conn_9  | False   | select * from sharding_2_t1 where id = 1 or 1 = 1       |schema1| has{((1,1),(2,2),(3,3),(4,4),(5,5))}      |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I"
      | conn     | toClose | sql                                                           | db      |
      | conn_9   | true    | explain  select * from sharding_2_t1 where id = 1 or 1 = 1    | schema1 |
    Then check resultset "I" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                   |
      | dn1               | BASE SQL        | SELECT * FROM sharding_2_t1 WHERE id = 1  OR 1 = 1 LIMIT 100 |
      | dn2               | BASE SQL        | SELECT * FROM sharding_2_t1 WHERE id = 1  OR 1 = 1 LIMIT 100 |
    # EXISTS
    Given execute sql in "dble-1" in "user" mode
      | conn     | toClose | sql                                                                                      | db    | expect                                    |
      | conn_10  | False   | select * from sharding_2_t1 where EXISTS (select * from sharding_2_t1 where id=1)        |schema1| has{((1,1),(2,2),(3,3),(4,4),(5,5))}      |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "J"
      | conn      | toClose | sql                                                                                            | db      |
      | conn_10   | true    | explain  select * from sharding_2_t1 where EXISTS (select * from sharding_2_t1 where id=1)     | schema1 |
    Then check resultset "J" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                   |
      | dn2_0              | BASE SQL              | select `sharding_2_t1`.`id`,`sharding_2_t1`.`a` from  `sharding_2_t1` where `sharding_2_t1`.`id` = 1 LIMIT 1 |
      | merge_1            | MERGE                 | dn2_0                                                                                                        |
      | limit_1            | LIMIT                 | merge_1                                                                                                      |
      | shuffle_field_1    | SHUFFLE_FIELD         | limit_1                                                                                                      |
      | scalar_sub_query_1 | SCALAR_SUB_QUERY      | shuffle_field_1                                                                                              |
      | dn1_0              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_2_t1`.`id`,`sharding_2_t1`.`a` from  `sharding_2_t1` where 1 = 1        |
      | dn2_1              | BASE SQL(May No Need) | scalar_sub_query_1; select `sharding_2_t1`.`id`,`sharding_2_t1`.`a` from  `sharding_2_t1` where 1 = 1        |
      | merge_2            | MERGE                 | dn1_0; dn2_1                                                                                                 |
      | shuffle_field_2    | SHUFFLE_FIELD         | merge_2                                                                                                      |
    # LIKE
    Given execute sql in "dble-1" in "user" mode
      | conn     | toClose | sql                                                     | db    | expect             |
      | conn_11  | False   | select * from sharding_2_t1 where id LIKE 1             |schema1| has{((1,1),)}      |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "K"
      | conn     | toClose | sql                                                            | db      |
      | conn_11   | true    | explain  select * from sharding_2_t1 where id LIKE 1          | schema1 |
    Then check resultset "K" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                             |
      | dn1               | BASE SQL        | SELECT * FROM sharding_2_t1 WHERE id LIKE 1 LIMIT 100 |
      | dn2               | BASE SQL        | SELECT * FROM sharding_2_t1 WHERE id LIKE 1 LIMIT 100 |

