# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/12/7
Feature: table type check
  there are verious types of table in dble, with show all tables user can check the table type, with raw show [full] tables
  user can get various table, but theirs' type all are basic table

  @NORMAL
  Scenario: show full tables could show config table and it was basic table #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                     | expect                       | db      |
      | conn_0 | False    | create table if not exists test(id int) | success                      | schema1 |
      | conn_0 | False    | show full tables                        | has{('test','BASE TABLE')}   | schema1 |
      | conn_0 | False    | show full tables from `schema1`         | has{('test','BASE TABLE')}   | schema1 |
      | conn_0 | True     | drop table test                         | success                      | schema1 |


    Scenario:  Directly fetch the table in dble metadata when in 8066 show tables  #2 from:DBLE0REQ-511
      Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                             | expect             |
      | conn_0 | False   | use schema1                     | success            |
      | conn_0 | False   | show tables                     | success            |
      | conn_0 | False   | drop table if exists test1      | success            |
#case table "test1" is nosharding table
      Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                          | expect         |
      | conn_1 | False    | use db3                      | success        |
      | conn_1 | False    | drop table if exists test1   | success        |
      | conn_1 | False    | create table test1 (id int)  | success        |
      Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                            | expect                         |
      | conn_0 | False   | show tables                    | hasNoStr{('test1')}            |
      | conn_0 | False   | create table test1 (id int)    | Table 'test1' already exists   |
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                            | expect                         |
      | conn_2 | False   | reload @@metadata              | success                        |
      Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                            | expect                         |
      | conn_0 | False   | show tables                    | has{('test1')}                 |
      | conn_0 | False   | drop table if exists test1     | success                        |
#case Default node in dn5 but was not in dn1
      Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                          | expect         |
      | conn_1 | False    | use db1                      | success        |
      | conn_1 | False    | drop table if exists test1   | success        |
      | conn_1 | False    | create table test1 (id int)  | success        |
      Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                            | expect                         |
      | conn_0 | False   | show tables                    | hasNoStr{('test1')}            |
      | conn_0 | False   | create table test1 (id int)    | success                        |
      | conn_0 | False   | show tables                    | has{('test1')}                 |
      | conn_0 | False   | drop table if exists test1     | success                        |
  #case table "test1" is single table
      Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                                  | expect         |
      | conn_1 | False    | use db3                              | success        |
      | conn_1 | False    | drop table if exists sharding_1_t1   | success        |
      | conn_1 | False    | create table sharding_1_t1 (id int)  | success        |
      Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect                                 |
      | conn_0 | False   | show tables                            | hasNoStr{('sharding_1_t1')}            |
      | conn_0 | False   | create table sharding_1_t1 (id int)    | Table 'sharding_1_t1' already exists   |
      Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                                  | expect         |
      | conn_1 | False    | drop table if exists sharding_1_t1   | success        |
  #case table "test1" is sharding table
      Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                                  | expect         |
      | conn_1 | False    | use db1                              | success        |
      | conn_1 | False    | drop table if exists sharding_2_t1   | success        |
      | conn_1 | False    | create table sharding_2_t1 (id int)  | success        |
      Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect                                                       |
      | conn_0 | False   | show tables                            | hasNoStr{('sharding_2_t1')}                                  |
      | conn_0 | False   | create table sharding_2_t1 (id int)    | Table 'schema1.sharding_2_t1' or table meta already exists   |
      Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                                  | expect         |
      | conn_1 | False    | drop table if exists sharding_2_t1   | success        |
  #case table "test1" is global table
      Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                                  | expect         |
      | conn_1 | False    | use db1                              | success        |
      | conn_1 | False    | drop table if exists global_4_t1     | success        |
      | conn_1 | False    | create table global_4_t1 (id int)    | success        |
      Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect                                                       |
      | conn_0 | False   | use schema2                            | success                                                      |
      | conn_0 | False   | show tables                            | hasNoStr{('global_4_t1')}                                    |
      | conn_0 | true    | create table global_4_t1 (id int)      | Table 'schema2.global_4_t1' or table meta already exists     |
      Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                                  | expect         |
      | conn_1 | true     | drop table if exists global_4_t1     | success        |