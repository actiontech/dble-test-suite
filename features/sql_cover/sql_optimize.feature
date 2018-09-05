# Created by zhaohongjie at 2018/9/5
Feature: subquery should be optimized for ER/Global table join #dble github issue #685
  # Enter feature description here

  Scenario: # Enter scenario name here
    Then execute sql in "dble-1" use "test"
        | user | passwd | conn   | toClose  | sql                                   | expect            | db     |
        | testA| testA  | conn_0 | False    | show databases                        | has{('mytestA',)},hasnot{('mytestB',)}  |        |
        | testA| testA  | conn_0 | False    | use mytestB                           | Access denied for user |   |
        | testA| testA  | conn_0 | False    | drop table if exists mytestA.test2    | success           |        |
        | testA| testA  | conn_0 | False    | create table mytestA.test2(id int)    | success           |        |
        | testA| testA  | conn_0 | True     | drop table if exists mytestA.test2    | success           |        |
        | testB| testB  | conn_1 | False    | show databases                        | has{('mytestB',)},hasnot{('mytestA',)}  |        |
        | testB| testB  | conn_1 | False    | use mytestA                           | Access denied for user |   |
