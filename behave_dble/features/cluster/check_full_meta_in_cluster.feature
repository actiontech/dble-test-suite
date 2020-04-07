# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2019/10/15
Feature:check metadata is right in cluster after alter table failed or succeed
#github issue #1038

  @CRITICAL @skip_restart
  Scenario: check metadata is right in cluster after alter table failed or succeed #1
      Then execute sql in "dble-2" in "user" mode
      | user | passwd | conn   | toClose  | sql                         | expect   | db       |
      | test | 111111 | conn_0 | True     | drop table if exists test  | success  | schema1   |
      | test | 111111 | conn_0 | True     | create table test(id int)  | success  | schema1   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_dble1_0"
      | sql                                                           |
      | check full @@metadata where schema='schema1' and table='test' |
      Then execute sql in "dble-2" in "user" mode
      | user | passwd | conn   | toClose  | sql                         | expect   | db       |
      | test | 111111 | conn_0 | True     | alter table test drop c   | Can't DROP                        |   schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_dble1_1"
      | sql                                                           |
      | check full @@metadata where schema='schema1' and table='test' |
      Then check resultsets "rs_dble1_0" and "rs_dble1_1" are same in following columns
      |column               | column_index |
      |schema          | 1              |
      |table        | 2              |
      |reload_time                  | 3              |
      |table_structure                  | 4             |
      Then execute sql in "dble-2" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect                               | db |
      | test | 111111 | conn_0 | True    | alter table test add col_c int | success |  schema1  |
      Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                                                   | expect         | db |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='schema1' and table='test' | hasStr{col_c} |    |