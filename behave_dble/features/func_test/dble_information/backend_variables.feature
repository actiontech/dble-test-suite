# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  backend_variables test

   Scenario:  backend_variables table #1
  #case desc backend_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_variables_1"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | desc backend_variables | dble_information |
    Then check resultset "backend_variables_1" has lines with following column values
      | Field-0                   | Type-1        | Null-2 | Key-3 | Default-4 | Extra-5 |

