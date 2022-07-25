# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
@setup
Feature: mysql-test-sharding-join test
  """
  Given rm old logs "mysql_test_sharding_join" if exists
  Given reset replication and none system databases
  Given reset views in "dble-1" if exists
  """

   Scenario Outline:sql cover for sharding table #2
      Given set sql cover log dir "mysql_test_sharding_join"
      Then execute sql in file "<filename>"
      Given clear dirty data yield by sql

      Examples:Types
        | filename                                              |
        | mysql_test/t/sharding_join/join.sql                   |
        | mysql_test/t/sharding_join/join_nested.sql            |
        | mysql_test/t/sharding_join/join_outer.sql             |
        | mysql_test/t/sharding_join/join_outer_innodb.sql      |

   Scenario: #5 compare new generated results is same with the standard ones
      When compare results in "mysql_test_sharding_join" with the standard results in "std_mysql_test_sharding_join"