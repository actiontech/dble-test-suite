# Copyright (C) 2016-2021 ActionTech.
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
