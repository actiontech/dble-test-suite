# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/11/11

Feature: execute pause in different scenario

  Scenario: resume datanodes which not stop data flow #1
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                  | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists sharding_4_t1                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table sharding_4_t1 (id int,name varchar(20)) | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql    | expect             | db |
      | root | 111111 | conn_0 | True    | resume | No dataNode paused |    |

  Scenario: execute manager cmd "pause @@DataNode" many times #2
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                  | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists sharding_4_t1                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table sharding_4_t1 (id int,name varchar(20)) | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | false   | begin                                                   | success | schema1 |
      | test | 111111 | conn_0 | false   | insert into sharding_4_t1 values(1,1),(2,1),(3,1),(4,1) | success | schema1 |
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | sql                                                                        | db      |
      | root | 111111 | pause @@DataNode = 'dn1,dn2,dn3' and timeout =10 ,queue = 1,wait_limit = 5 | schema1 |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn | toClose | sql                                                                        | expect                                        | db |
      | root | 111111 | new  | false   | pause @@DataNode = 'dn1,dn2,dn3' and timeout =10 ,queue = 1,wait_limit = 5 | Some dataNodes is paused, please resume first |    |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn | toClose | sql                                                                        | expect                                              | db |
      | root | 111111 | new  | false   | pause @@DataNode = 'dn1,dn2,dn3' and timeout =10 ,queue = 1,wait_limit = 5 | The backend connection recycle failure,try it later |    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                          | expect  | db      |
      | test | 111111 | conn_0 | false   | select *  from sharding_4_t1 | success | schema1 |
      | test | 111111 | conn_0 | true    | commit                       | success | schema1 |

  Scenario: execute "resume" before the pause command expires #3
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                  | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists sharding_4_t1                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table sharding_4_t1 (id int,name varchar(20)) | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | false   | begin                                                   | success | schema1 |
      | test | 111111 | conn_0 | false   | insert into sharding_4_t1 values(1,1),(2,1),(3,1),(4,1) | success | schema1 |
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | sql                                                                        | db      |
      | root | 111111 | pause @@DataNode = 'dn1,dn2,dn3' and timeout =10 ,queue = 1,wait_limit = 5 | schema1 |
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn | toClose | sql    | expect  | db |
      | root | 111111 | new  | false   | resume | success |    |
    Then check log "/tmp/dble_query.log" output in "dble-1"
    """
    Pause resume when recycle connection ,pause revert
    """
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                          | expect  | db |
      | test | 111111 | conn_0 | false   | select *  from sharding_4_t1 | success |    |
      | test | 111111 | conn_0 | true    | commit                       | success |    |
