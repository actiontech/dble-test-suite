# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
Feature: nosharding table sql cover test

    Scenario: remove old logs #this is a prestep to after scenarios
      Given rm old logs "sql_cover_log" if exists

    Scenario Outline:sqls special for nosharding table test #1
      Then execute sql in file "<filename>"
      Given clear dirty data yield by sql

      Examples:Types
        | filename                                    |
        | nosharding_special/db.sql                   |
#        | nosharding_special/test.sql                   |

    Scenario: #5 compare new generated results is same with the standard ones
        When compare results with the standard results in "std_result_nosharding"