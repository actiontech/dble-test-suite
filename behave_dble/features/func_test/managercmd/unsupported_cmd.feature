# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/03/31
Feature: test Unsupported  manager command

  @NORMAL
  Scenario: test Unsupported  manager command #1
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                              | expect                 | db               |
      | conn_0 | False   | switch @@datasources             | Unsupported statement  | dble_information |
      | conn_0 | False   | switch @@dbinstance              | Unsupported statement  | dble_information |
