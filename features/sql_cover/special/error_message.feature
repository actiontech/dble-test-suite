# Created by maofei at 2019/1/2
Feature: # Detecting the reasonableness of the alarm information returned by the front end

  @TRIVIAL
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

  @regression
  Scenario: # unexpected explain  from issue：837
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose| sql                                                                        | expect                                                                                                     | db     |
      | test | 111111 | conn_0  | True   | explain explain select 1                                                 | Inner command not route to MySQL:explain select 1                                                   |mytest  |
      | test | 111111 | conn_0  | True   | explain explain2 select 1                                                |Inner command not route to MySQL:explain2 select 1                                                   |mytest  |
      | test | 111111 | conn_0  | True   | explain kill 1                                                             |Inner command not route to MySQL:kill 1                                                               |mytest  |
      | test | 111111 | conn_0  | True   | explain unlock aly_test                                                   |Inner command not route to MySQL:unlock aly_test                                                     |mytest  |
      | test | 111111 | conn_0  | True   | explain lock aly_test                                                      |Inner command not route to MySQL:lock aly_test                                                        |mytest  |
      | test | 111111 | conn_0  | True   | explain create view view_test as select 1                                |Inner command not route to MySQL:create view view_test as select 1                                |mytest  |
      | test | 111111 | conn_0  | True   | explain create or replace view view_test as select 2                    |Inner command not route to MySQL:create or replace view view_test as select 2                   |mytest  |
      | test | 111111 | conn_0  | True   | explain alter view view_test as select * from aly_test where id=1     |Inner command not route to MySQL:alter view view_test as select * from aly_test where id=1    |mytest  |
      | test | 111111 | conn_0  | True   | explain drop view view_test                                                |Inner command not route to MySQL:drop view view_test                                                |mytest  |
      | test | 111111 | conn_0  | True   | explain begin                                                                 |Inner command not route to MySQL:begin                                                               |mytest  |
      | test | 111111 | conn_0  | True   | explain use mytest                                                           |Inner command not route to MySQL:use mytest                                                          |mytest  |
      | test | 111111 | conn_0  | True   | explain commit                                                               |Inner command not route to MySQL:commit                                                               |mytest  |
      | test | 111111 | conn_0  | True   | explain rollback                                                             |Inner command not route to MySQL:rollback                                                            |mytest  |
      | test | 111111 | conn_0  | True   | explain set @a=1                                                             |Inner command not route to MySQL:set @a=1                                                             |mytest  |
      | test | 111111 | conn_0  | True   | explain select 2/*test*/                                                    |success                                                                                                    |mytest  |
      | test | 111111 | conn_0  | True   | explain show create table aly_test                                         |Inner command not route to MySQL:show create table aly_test                                         |mytest  |
      | test | 111111 | conn_0  | True   | explain prepare pre_test from 'alter table test_shard add age int(10)' |Inner command not route to MySQL:prepare pre_test from 'alter table test_shard add age int(10)'|mytest  |
      | test | 111111 | conn_0  | True   | explain select 1/*! test*/                                                  |success                                                                                                    |mytest  |
      | test | 111111 | conn_0  | True   | explain load data infile my.sqll                                           |Inner command not route to MySQL:load data infile my.sqll                                            |mytest  |