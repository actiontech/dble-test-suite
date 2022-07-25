# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
@setup
Feature: mysql-test-sharding-group-by test
  """
  Given rm old logs "mysql_test_sharding_group_by" if exists
  Given reset replication and none system databases
  Given reset views in "dble-1" if exists
  """

   Scenario Outline:mysql-test for sharding table #1
      Given set sql cover log dir "mysql_test_sharding_group_by"
      Then execute sql in file "<filename>"
      Given clear dirty data yield by sql

      Examples:Types
        | filename                                               |
        | mysql_test/t/sharding_group_by/group_by.sql            |
        | mysql_test/t/sharding_group_by/group_min_max.sql       |
        | mysql_test/t/sharding_group_by/group_min_max_innodb.sql|

   Scenario: #5 compare new generated results is same with the standard ones
      When compare results in "mysql_test_sharding_group_by" with the standard results in "std_mysql_test_sharding_group_by"