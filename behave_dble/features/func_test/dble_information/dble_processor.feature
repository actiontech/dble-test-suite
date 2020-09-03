# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_processor test

   Scenario:  dble_processor table #1
  #case desc dble_processor
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_processor_1"
      | conn   | toClose | sql                 | db               |
      | conn_0 | False   | desc dble_processor | dble_information |
    Then check resultset "dble_processor_1" has lines with following column values
      | Field-0      | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name         | varchar(64) | NO     | PRI   | None      |         |
      | type         | varchar(7)  | NO     |       | None      |         |
      | conn_count   | int(11)     | NO     |       | None      |         |
      | conn_net_in  | int(11)     | NO     |       | None      |         |
      | conn_net_out | int(11)     | NO     |       | None      |         |

   #case select * from dble_processor
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_processor_2"
      | conn   | toClose | sql                          | db               |
      | conn_0 | False   | select * from dble_processor | dble_information |
    Then check resultset "dble_processor_2" has lines with following column values
      | name-0            | type-1  |
      | frontProcessor0   | session |
      | backendProcessor0 | session |
      | backendProcessor1 | session |
      | backendProcessor2 | session |
      | backendProcessor3 | session |
      | backendProcessor4 | session |
      | backendProcessor5 | session |
      | backendProcessor6 | session |
      | backendProcessor7 | session |