# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/9/2

Feature:  processlist test

   Scenario:  processlist  table #1
  #case desc processlist
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "processlist_1"
      | conn   | toClose | sql              | db               |
      | conn_0 | False   | desc processlist | dble_information |
    Then check resultset "processlist_1" has lines with following column values
      | Field-0          | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |