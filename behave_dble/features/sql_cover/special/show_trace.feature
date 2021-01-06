# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by Rita at 2019/3/29
Feature: verify  function of "show trace"

  Scenario: "show trace" should return results after executing "join" with right table contains a lot of useless data #1
    #github issue #1058
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                               | expect   | db      |
      | conn_0 | False    | drop table if exists sharding_2_t1                | success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t2                | success  | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int,name char(20))  | success  | schema1 |
      | conn_0 | False    | create table sharding_2_t2(id int,name char(20))  | success  | schema1 |
      | conn_0 | False    | insert into sharding_2_t1 values(1,'namea')       | success  | schema1 |
      | conn_0 | False     | insert into sharding_2_t1 values(1,'nameb')      | success  | schema1 |
    Then connect "dble-1" to insert "10000" of data for "sharding_2_t2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                | expect       | db      |
      | conn_0 | False    | set trace=1                                                        | success      | schema1 |
      | conn_0 | False    | select * from sharding_2_t1 a,sharding_2_t2 b where a.id = b.id    | success      | schema1 |
      | conn_0 | True     | show trace                                                         | length{20}   | schema1 |

