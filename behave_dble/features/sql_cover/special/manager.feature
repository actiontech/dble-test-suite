# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by MAOFEI at 2017/9/25
Feature: manager commands test
  # Enter feature description here

  @NORMAL
  Scenario Outline:  #1
    Then execute sql in "<filename>" to check manager work fine

        Examples:Types
          | filename                           |
          | manager/manager.sql                |
