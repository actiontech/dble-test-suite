# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2018/11/6

Feature: show @@connection.sql test
 ###注意这个case的session不能重复，不然会导致后面一条sql覆盖前面一条sql。该版本的 show @@ xxx.sql应该有一定的问题。有issue修复/DBLE0REQ-2107
 #### 加上auto_retry是因为机器时间回溯 导致case失败

  @TRIVIAL @auto_retry
  Scenario: query execute time <1ms #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                    | db       |
      | conn_0 | False    | select sleep(0.0001)   | schema1  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "conn_rs_A"       
      | conn   | toClose  | sql                   |
      | conn_1 | False    | show @@connection.sql |
    Then removal result set "conn_rs_A" contains "@@connection" part
    Given sleep "2" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "conn_rs_B"
      | conn   | toClose  | sql                   |
      | conn_2 | False    | show @@connection.sql |
    Then removal result set "conn_rs_B" contains "@@connection" part
    Then check resultsets "conn_rs_A" and "conn_rs_B" are same in following columns
      | column              | column_index |
      | START_TIME          | 5            |
      | EXECUTE_TIME        | 6            |
      | SQL                 | 7            |

  @TRIVIAL  @auto_retry
  Scenario: query execute time >1ms #2
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                    | db       |
      | conn_0 | False    | select sleep(0.0001)   | schema1  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "conn_rs_C"
      | conn   | toClose  | sql                   |
      | conn_1 | False    | show @@connection.sql |
    Then removal result set "conn_rs_C" contains "@@connection" part
    Given sleep "2" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "conn_rs_D"
      | conn   | toClose  | sql                   |
      | conn_2 | False    | show @@connection.sql |
    Then removal result set "conn_rs_D" contains "@@connection" part
    Then check resultsets "conn_rs_C" and "conn_rs_D" are same in following columns
      | column              | column_index |
      | START_TIME          | 5              |
      | EXECUTE_TIME        | 6              |
      | SQL                 | 7              |

  @TRIVIAL  @auto_retry
  Scenario: multiple session with multiple query display #3
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                    | db       |
      | conn_0 | False    | select sleep(1)        | schema1  |
      | conn_1 | False    | select sleep(0.1)      | schema1   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "conn_rs_E"
      | conn   | toClose  | sql                   |
      | conn_3 | False    | show @@connection.sql |
    Then removal result set "conn_rs_E" contains "@@connection" part
    Given sleep "2" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "conn_rs_F"
      | conn   | toClose  | sql                   |
      | conn_4 | False    | show @@connection.sql |
    Then removal result set "conn_rs_F" contains "@@connection" part
    Then check resultsets "conn_rs_E" and "conn_rs_F" are same in following columns
      | column              | column_index |
      | START_TIME          | 5              |
      | EXECUTE_TIME        | 6              |
      | SQL                 | 7              |