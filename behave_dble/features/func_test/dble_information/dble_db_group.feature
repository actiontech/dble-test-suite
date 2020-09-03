# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_db_group test

   Scenario:  dble_db_group table #1
  #case desc dble_db_group
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | desc dble_db_group | dble_information |
    Then check resultset "dble_db_group_1" has lines with following column values
      | Field-0   | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_2"
      | conn   | toClose | sql                              | db               |
      | conn_0 | False   | select * from dble_db_group | dble_information |
    Then check resultset "dble_db_group_2" has lines with following column values
      | name-0 | db_group-1 | db_schema-2 | pause-3 |
