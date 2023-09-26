# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2023/8/30

Feature: code coverage
  
  @skip_restart
  Scenario: Initialize the code coverage
    Given check code coverage and change bootstrap conf

  @skip_restart
  Scenario: general code coverage html report after run all case
    Given execute command to general code coverage html report