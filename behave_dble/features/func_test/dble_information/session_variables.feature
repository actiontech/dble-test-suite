# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  session_variables test

   Scenario:  session_variables table #1
  #case desc session_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_1"
      | conn   | toClose | sql              | db               |
      | conn_0 | False   | desc session_variables | dble_information |
    Then check resultset "session_variables_1" has lines with following column values
      | Field-0       | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_2"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | select * from session_variables | dble_information |
    Then check resultset "session_variables_2" has lines with following column values
