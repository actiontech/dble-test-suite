# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2019/10/11
Feature: verify table name or schema name enclosed by backquotes can work fine

  Scenario: explain right when table name enclosed by backquotes #1
    #from github issue #1323,#1324
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                          | expect   | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                           | success  | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name char(20))             | success  | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(1,'aaa'),(2,'bbb'),(3,'ccc') | success  | schema1 |
    Then get query plan and make sure it is optimized
      |query                                                        | expect_result_count |
      | explain select * from sharding_4_t1                         | 4  |
      | explain select * from `sharding_4_t1`                       | 4  |
      | explain select * from schema1.sharding_4_t1                 | 4  |
      | explain select * from schema1.`sharding_4_t1`               | 4  |
      | explain select * from `schema1`.sharding_4_t1               | 4  |
      | explain select * from `schema1`.`sharding_4_t1`             | 4  |
      | explain select * from sharding_4_t1 where id=2              | 1  |
      | explain select * from `sharding_4_t1` where id=2            | 1  |
      | explain select * from schema1.sharding_4_t1 where id=2      | 1  |
      | explain select * from schema1.`sharding_4_t1` where id=2    | 1  |
      | explain select * from `schema1`.sharding_4_t1 where id=2    | 1  |
      | explain select * from `schema1`.`sharding_4_t1` where id=2  | 1  |
  Scenario: execute with hint when explain table name enclosed by backquotes,explain right when column alias enclosed by backquotes #2
    #from github issue #1375
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                    | expect         | db      |
      | conn_0 | False    |   drop table if exists sharding_enum_string_t1                                                                         | success        | schema1 |
      | conn_0 | False    |   create table sharding_enum_string_t1(id_0 int,id char(3))                                                            | success        | schema1 |
      | conn_0 | False    |   insert into sharding_enum_string_t1 values(1,'aaa'),(2,'bbb'),(3,'ccc')                                              | success        | schema1 |
      | conn_0 | False    |   select * from sharding_enum_string_t1                                                                                | length{(3)}    | schema1 |
      | conn_0 | False    |  /*!dble:shardingnode=dn2*/ select * from `sharding_enum_string_t1` where id='bbb'                                         | length{(1)}    | schema1 |
      | conn_0 | False    |  /*!dble:shardingnode=dn2*/ select * from `db1`.`sharding_enum_string_t1` where id='bbb'                                   | length{(1)}    |         |
      | conn_0 | False    |   explain select `a`.`id_0` as `sid` from `sharding_enum_string_t1` as `a` where id in ('aaa', 'bbb') having `sid` > 1 | success        | schema1 |
      | conn_0 | False    |   explain select `a`.`id_0` as `sid` from `sharding_enum_string_t1` as `a` where id in ('aaa', 'bbb') having sid > 1   | success        | schema1 |
      | conn_0 | False    |   explain select `a`.`id_0` as sid from `sharding_enum_string_t1` as `a` where id in ('aaa', 'bbb') having sid > 1     | success        | schema1 |
      | conn_0 | False    |   select `a`.`id_0` as `sid` from `sharding_enum_string_t1` as `a` where id in ('aaa', 'bbb') having `sid` > 1         | hasStr{(2,)}   | schema1 |
      | conn_0 | False    |   select `a`.`id_0` as `sid` from `sharding_enum_string_t1` as `a` where id in ('aaa', 'bbb') having sid > 1           | length{(1)}    | schema1 |
      | conn_0 | True     |   select `a`.`id_0` as sid from `sharding_enum_string_t1` as `a` where id in ('aaa', 'bbb') having sid > 1             | length{(1)}    | schema1 |