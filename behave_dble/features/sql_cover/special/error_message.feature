# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/1/2
Feature: # Detecting the reasonableness of the alarm information returned by the front end

  @TRIVIAL @current
  Scenario: union with different number of columns #1
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose| sql                                                                                | expect    | db     |
      | test | 111111 | conn_0 | True    | drop table if exists sharding_4_t1                                                 | success   | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists schema2.global_4_t1                                           | success   | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists single_node_t1                                                | success   | schema1 |
      | test | 111111 | conn_0 | True    | create table sharding_4_t1(id int, name varchar(5))                                | success   | schema1 |
      | test | 111111 | conn_0 | True    | create table schema2.global_4_t1(id int, name varchar(5))                          | success   | schema1 |
      | test | 111111 | conn_0 | True    | create table single_node_t1(id int, name varchar(5),age int)                       | success   | schema1 |
      | test | 111111 | conn_0 | True    | select * from schema1.sharding_4_t1 union select * from schema2.global_4_t1        | success   | schema1 |
      | test | 111111 | conn_0 | True    | select * from schema1.sharding_4_t1 union select * from schema1.single_node_t1     | The used SELECT statements have a different number of columns   | schema1 |
      | test | 111111 | conn_0 | True    | alter table schema2.global_4_t1 drop column name                                   | success   | schema1 |
      | test | 111111 | conn_0 | True    | select * from schema1.single_node_t1 union select * from schema2.global_4_t1       | The used SELECT statements have a different number of columns   | schema1 |

  @regression
  Scenario: unexpected explain  from issue：837 #2
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose| sql                                                                     | expect                                                                                                     | db     |
      | test | 111111 | conn_0  | True   | explain explain select 1                                                | Inner command not route to MySQL:explain select 1                                                   |schema1  |
      | test | 111111 | conn_0  | True   | explain explain2 select 1                                               |Inner command not route to MySQL:explain2 select 1                                                   |schema1  |
      | test | 111111 | conn_0  | True   | explain kill 1                                                          |Inner command not route to MySQL:kill 1                                                               |schema1  |
      | test | 111111 | conn_0  | True   | explain unlock sharding_4_t1                                            |Inner command not route to MySQL:unlock sharding_4_t1                                                     |schema1  |
      | test | 111111 | conn_0  | True   | explain lock sharding_4_t1                                              |Inner command not route to MySQL:lock sharding_4_t1                                                        |schema1  |
      | test | 111111 | conn_0  | True   | explain create view view_test as select 1                               |Inner command not route to MySQL:create view view_test as select 1                                |schema1  |
      | test | 111111 | conn_0  | True   | explain create or replace view view_test as select 2                    |Inner command not route to MySQL:create or replace view view_test as select 2                   |schema1  |
      | test | 111111 | conn_0  | True   | explain alter view view_test as select * from sharding_4_t1 where id=1  |Inner command not route to MySQL:alter view view_test as select * from sharding_4_t1 where id=1    |schema1  |
      | test | 111111 | conn_0  | True   | explain drop view view_test                                             |Inner command not route to MySQL:drop view view_test                                                |schema1  |
      | test | 111111 | conn_0  | True   | explain begin                                                           |Inner command not route to MySQL:begin                                                               |schema1  |
      | test | 111111 | conn_0  | True   | explain use schema1                                                     |Inner command not route to MySQL:use schema1                                                          |schema1  |
      | test | 111111 | conn_0  | True   | explain commit                                                          |Inner command not route to MySQL:commit                                                               |schema1  |
      | test | 111111 | conn_0  | True   | explain rollback                                                        |Inner command not route to MySQL:rollback                                                            |schema1  |
      | test | 111111 | conn_0  | True   | explain set @a=1                                                        |Inner command not route to MySQL:set @a=1                                                             |schema1  |
      | test | 111111 | conn_0  | True   | explain select 2/*test*/                                                |success                                                                                                    |schema1  |
      | test | 111111 | conn_0  | True   | explain show create table sharding_4_t1                                 |Inner command not route to MySQL:show create table sharding_4_t1                                         |schema1  |
      | test | 111111 | conn_0  | True   | explain prepare pre_test from 'alter table test_shard add age int(10)'  |Inner command not route to MySQL:prepare pre_test from 'alter table test_shard add age int(10)'|schema1  |
      | test | 111111 | conn_0  | True   | explain select 1/*! test*/                                              |success                                                                                                    |schema1  |
      | test | 111111 | conn_0  | True   | explain load data infile my.sqll                                        |Inner command not route to MySQL:load data infile my.sqll                                            |schema1  |

  @regression
  Scenario: correlated subquery in the SELECT clause will raise an error  from issue：1087 #3
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose| sql                                                                                                                                                                        | expect                                          |db     |
      | test | 111111 | conn_0  | True   | drop table if exists sharding_4_t1                                                                                                                                     | success                                         |schema1  |
      | test | 111111 | conn_0  | True   | CREATE TABLE `sharding_4_t1` (`id` bigint(19) NOT NULL,`SENDING_DATE` datetime DEFAULT NULL)                                                                   |success                                          |schema1  |
      | test | 111111 | conn_0  | True   | SELECT COUNT(*) AS TEMP2,(SELECT COUNT(*) FROM sharding_4_t1 S WHERE MONTH(s.SENDING_DATE) = MONTH(t.SENDING_DATE)) AS TEMP1 FROM sharding_4_t1 t       |Correlated Sub Queries is not supported     |schema1  |

  @regression
  Scenario: test Unfriendly tips for select query  from issue：1053 #4
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose| sql                                                                                                                           | expect                                    |db     |
      | test | 111111 | conn_0  | True   | drop table if exists sharding_4_t1                                                                                       | success                                    |schema1  |
      | test | 111111 | conn_0  | True   | drop table if exists sharding_1_t1                                                                                       | success                                    |schema1  |
      | test | 111111 | conn_0  | True   | drop table if exists sharding_2_t1                                                                                       | success                                    |schema1  |
      | test | 111111 | conn_0  | True   | create table sharding_1_t1(id int,name char)                                                                            | success                                    |schema1  |
      | test | 111111 | conn_0  | True   | create table sharding_2_t1(id int,name char)                                                                            | success                                    |schema1  |
      | test | 111111 | conn_0  | True   | create table sharding_4_t1(id int,name char)                                                                            | success                                    |schema1  |
      | test | 111111 | conn_0  | True   | select * from sharding_1_t1 b,sharding_4_t1 c,(select * from sharding_2_t1) a on c.id=b.id and c.id=b.id       |You have an error in your SQL syntax     |schema1  |

  Scenario: test a physical database that has not been created when starting xa  from issue：1106 #5
    Then execute sql in "mysql-master1"
      | user  | passwd | conn   | toClose | sql                                  | expect  | db  |
      | test  | 111111 | conn_0 | True    | drop database if exists db3       | success |     |
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose | sql                                   | expect                                                                                           |db     |
      | test | 111111 | conn_0  | False   | set autocommit=0                    | success                                                                                          |schema1  |
      | test | 111111 | conn_0  | False   | set xa=on                            | success                                                                                          |schema1  |
      | test | 111111 | conn_0  | False   | drop table if exists test1         | Unknown database 'db3'                                                                        |schema1  |
      | test | 111111 | conn_0  | False   | commit                                | Transaction error, need to rollback.Reason:[ errNo:1049 Unknown database 'db3']       |schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                 | expect          | db    |
      | root  | 111111 | conn_1 | True    | show @@session     | length{0}      |       |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn    | toClose | sql                 | expect          |db       |
      | test  | 111111 | conn_0  | True    | rollback           | success         | schema1 |
    Then execute sql in "mysql-master1"
      | user  | passwd  | conn   | toClose | sql                                     | expect  | db  |
      | test  | 111111  | conn_0 | True    | create database if not exists db3   | success |     |