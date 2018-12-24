# Created by zhaohongjie at 2018/12/7
Feature: table type check
  there are verious types of table in dble, with show all tables user can check the table type, with raw show [full] tables
  user can get various table, but theirs' type all are basic table

  @regression
  Scenario: show full tables could show config table and it was basic table #1
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                     | expect                       | db     |
        | test | 111111 | conn_0 | False    | create table if not exists test(id int) | success                      | mytest |
        | test | 111111 | conn_0 | False    | show full tables                        | has{('test','BASE TABLE')}   | mytest |
        | test | 111111 | conn_0 | False    | show full tables from `mytest`        | has{('test','BASE TABLE')}   | mytest |
        | test | 111111 | conn_0 | True     | drop table test                         | success                      | mytest |
