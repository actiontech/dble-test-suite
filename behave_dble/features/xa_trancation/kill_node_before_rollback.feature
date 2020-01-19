# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/26

Feature: xa_transaction: kill node before transaction rollback

  Scenario: begin transaction and insert data , kill one node before transaction rollback #1
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                | expect                                                                                                                                                     | db      |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_4_t1                                                                 | success                                                                                                                                                    | schema1 |
      | test | 111111 | conn_0 | False   | create table sharding_4_t1 (id int,customerid int,accountno varchar(20),amount decimal(10,2))      | success                                                                                                                                                    | schema1 |
      | test | 111111 | conn_0 | False   | set autocommit = 0                                                                                 | success                                                                                                                                                    | schema1 |
      | test | 111111 | conn_0 | False   | set xa=1                                                                                           | success                                                                                                                                                    | schema1 |
      | test | 111111 | conn_0 | False   | begin                                                                                              | success                                                                                                                                                    | schema1 |
      | test | 111111 | conn_0 | False   | insert into sharding_4_t1 values(1,1,'a0301',0),(2,2,'a0601',0), (3,3,'a0301',0),(4,601,'a0601',0) | success                                                                                                                                                    | schema1 |
      | test | 111111 | conn_0 | False   | select * from sharding_4_t1 order by id                                                            | hasStr{((1L, 1L, 'a0301', Decimal('0.00')), (2L, 2L, 'a0601', Decimal('0.00')), (3L, 3L, 'a0301', Decimal('0.00')), (4L, 601L, 'a0601', Decimal('0.00')))} | schema1 |
    Given stop mysql in host "mysql-master1"
    Given sleep "3" seconds
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql      | expect  | db      |
      | test | 111111 | conn_0 | False   | rollback | success | schema1 |
    Given sleep "3" seconds
    Given start mysql in host "mysql-master1"
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                         | expect      | db      |
      | test | 111111 | conn_0 | False   | select * from sharding_4_t1 | length{(0)} | schema1 |
      | test | 111111 | conn_0 | True    | drop table sharding_4_t1    | success     | schema1 |

