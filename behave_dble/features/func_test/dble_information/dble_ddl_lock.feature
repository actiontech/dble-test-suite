# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/9/2

Feature:  dble_ddl_lock test
@skip_restart
   Scenario:  dble_ddl_lock  table #1
  #case desc dble_ddl_lock
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_ddl_lock_1"
      | conn   | toClose | sql                | db               |
      | conn_0 | False   | desc dble_ddl_lock | dble_information |
    Then check resultset "dble_ddl_lock_1" has lines with following column values
      | Field-0 | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |
      | schema  | varchar(64)  | NO     | PRI   | None      |         |
      | table   | varchar(64)  | NO     | PRI   | None      |         |
      | sql     | varchar(500) | NO     |       | None      |         |


