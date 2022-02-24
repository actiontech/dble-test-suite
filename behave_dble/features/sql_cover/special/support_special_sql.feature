# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/9/24
  Feature: support special sql

   Scenario: can support special sql like when when two sharding_table inner join select DATEDIFF()   #1
#case https://github.com/actiontech/dble/issues/1913
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_2_t2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                              | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1                                                                               | success | schema1 |
      | conn_0 | False   | drop table if exists sharding_2_t2                                                                               | success | schema1 |
      | conn_0 | False   | CREATE TABLE sharding_2_t1 (id int(11),APPLY_TIME DATE,CREAT_TIME DATETIME)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 | success | schema1 |
      | conn_0 | False   | CREATE TABLE sharding_2_t2 (id int(11),APPLY_TIME DATE)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4                     | success | schema1 |
      | conn_0 | False   | INSERT INTO sharding_2_t1  (id,APPLY_TIME,CREAT_TIME) VALUES (1,'2020-07-08','2020-07-01 21:34:50')              | success | schema1 |
      | conn_0 | False   | INSERT INTO sharding_2_t2  (id,APPLY_TIME) VALUES (1,'2020-07-08')                                               | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "7A"
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_0 | False   | SELECT tb.id,tb.APPLY_TIME,tb.CREAT_TIME,CURDATE(),DATEDIFF(tb.APPLY_TIME, CURDATE()) T1,DATEDIFF(tb.APPLY_TIME, NOW()) T2,DATEDIFF('2020-07-08', '2020-07-02') T3,DATEDIFF(tb.CREAT_TIME, CURDATE()) T4 FROM sharding_2_t1 tb INNER JOIN sharding_2_t2 tb1 ON tb.APPLY_TIME=tb1.APPLY_TIME WHERE tb1.APPLY_TIME='2020-07-08'           | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "7B"
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_0 | False   | SELECT tb.id,tb.APPLY_TIME,tb.CREAT_TIME,CURDATE(),DATEDIFF(tb.APPLY_TIME, CURDATE()) T1,DATEDIFF(tb.APPLY_TIME, NOW()) T2,DATEDIFF('2020-07-08', '2020-07-02') T3,DATEDIFF(tb.CREAT_TIME, CURDATE()) T4 FROM sharding_2_t1 tb WHERE tb.id=1           | success | schema1 |
    Then check resultsets "7A" and "7B" are same in following columns
      | column     | column_index |
      | id         | 0            |
      | APPLY_TIME | 1            |
      | CREAT_TIME | 2            |
      | CURDATE()  | 3            |
      | T1         | 4            |
      | T2         | 5            |
      | T3         | 6            |
      | T4         | 7            |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1        | success | schema1 |
      | conn_0 | true    | drop table if exists sharding_2_t2        | success | schema1 |