# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
# Created by MAOFEI at 2017/9/25
Feature: manager commands test
  # Enter feature description here

  @NORMAL
  Scenario Outline:
    Then execute sql in "<filename>" to check manager work fine

        Examples:Types
          | filename                           |
          | manager/manager.sql                |
