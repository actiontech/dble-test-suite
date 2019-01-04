# Created by maofei at 2019/1/2
Feature: # Detecting the reasonableness of the alarm information returned by the front end

  Scenario: # union with different number of columns
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose| sql                          | expect    | db     |
      | test | 111111 | conn_0 | True    | drop table if exists aly_test | success   | mytest |
      | test | 111111 | conn_0 | True    | drop table if exists test_global | success   | mytest |
      | test | 111111 | conn_0 | True    | drop table if exists test | success   | mytest |
      | test | 111111 | conn_0 | True    | create table aly_test(id int, name varchar(5))| success   | mytest |
      | test | 111111 | conn_0 | True    | create table test_global(id int, name varchar(5))| success   | mytest |
      | test | 111111 | conn_0 | True    | create table test(id int, name varchar(5),age int)| success   | mytest |
      | test | 111111 | conn_0 | True    | select * from mytest.aly_test union select * from mytest.test_global| The used SELECT statements have a different number of columns   | mytest |
      | test | 111111 | conn_0 | True    | select * from mytest.aly_test union select * from mytest.test| The used SELECT statements have a different number of columns   | mytest |
      | test | 111111 | conn_0 | True    | alter table test_global drop column name | success   | mytest |
      | test | 111111 | conn_0 | True    | select * from aly_test union select * from test_global | success   | mytest |
      | test | 111111 | conn_0 | True    | select * from mytest.test union select * from mytest.test_global| The used SELECT statements have a different number of columns   | mytest |

