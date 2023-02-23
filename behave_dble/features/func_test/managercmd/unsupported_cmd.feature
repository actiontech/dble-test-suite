# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/03/31
Feature: test Unsupported  manager command

  @NORMAL
  Scenario: test Unsupported  manager command #1
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                              | expect                 | db               |
      | conn_0 | False   | switch @@datasources             | Unsupported statement  | dble_information |
      | conn_0 | False   | switch @@dbinstance              | Unsupported statement  | dble_information |
      | conn_0 | False   | show @@syslog limit=100          | Unsupported statement  | dble_information |
      | conn_0 | False   | log @@file limit 10              | Unsupported statement  | dble_information |
