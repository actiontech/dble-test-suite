# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/5/6


 Feature: check set autocommit=0 then set autocommit=1


  Scenario: check set autocommit=0 then set autocommit=1  #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect      | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | success     | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | success     | schema1 |
      | conn_0 | False   | set autocommit=0                                        | success     | schema1 |
      | conn_0 | False   | set autocommit=1                                        | success     | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success     | schema1 |
      | conn_0 | False   | rollback                                                | success     | schema1 |
      | conn_0 | True    | select * from sharding_4_t1                             | length{(4)} | schema1 |


    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect      | db      |
      | conn_0 | False   | drop table if exists test                      | success     | schema1 |
      | conn_0 | False   | create table test(id int,name char)            | success     | schema1 |
      | conn_0 | False   | begin                                          | success     | schema1 |
      | conn_0 | False   | set autocommit=0                               | success     | schema1 |
      | conn_0 | False   | set autocommit=1                               | success     | schema1 |
      | conn_0 | False   | insert into test values(1,1),(2,2),(3,3),(4,4) | success     | schema1 |
      | conn_0 | False   | select * from test                             | length{(4)} | schema1 |
      | conn_0 | False   | drop table if exists test                      | success     | schema1 |
      | conn_0 | True    | drop table if exists sharding_4_t1             | success     | schema1 |
