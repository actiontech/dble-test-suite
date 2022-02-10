# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/6/5
Feature: xa transaction test

  Scenario: #Complex query in xa transaction   from issue:#1116  #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                | expect   | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                                 | success  | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,pad int)                                                         | success  | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)                                            | success  | schema1 |
      | conn_0 | False   | set xa=1                                                                                           | success  | schema1 |
      | conn_0 | False   | begin                                                                                              | success  | schema1 |
      | conn_0 | False   | SELECT * FROM( SELECT 1 FROM sharding_4_t1 T where id in(1,2) ORDER BY id) S                       | success  | schema1 |
      | conn_0 | True    | commit                                                                                             | success  | schema1 |
      | conn_1 | False   | set xa=1                                                                                           | success  | schema1 |
      | conn_1 | False   | begin                                                                                              | success  | schema1 |
      | conn_1 | False   | explain select 1 from sharding_4_t1 a,sharding_4_t1 b where a.id in(1,2) and b.id in(1,2) limit 1  | success  | schema1 |
      | conn_1 | False   | select 1 from sharding_4_t1 a,sharding_4_t1 b where a.id in(1,2) and b.id in(1,2) limit 1          | success  | schema1 |
      | conn_1 | True    | commit                                                                                             | success  | schema1 |
