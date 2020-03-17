# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/13 下午12:14
# @Author  : irene-coming
Feature: if dble rebuild conn pool with reload, then global vars dble use deeply will be redetected, and the detected result affets whether reload success
#global vars:lower_case_table_names,autocommit,transaction_isolation,read_only

  @restore_general_log
  Scenario: Backend Global vars are same with dble config,do dble reload -r which makes conn pool recreated will success, check the global var values is redetected.#1
    """
    {'restore_general_log':['mysql-master1','mysql-master2']}
    """
# if conn pool is not recreated, global var will not be redetected
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    When execute admin cmd "reload @@config_all -r" success
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    con query sql:select @@lower_case_table_names,@@autocommit, @@read_only,@@tx_isolation
    """
    Then check general log in host "mysql-master1" has not "set @@autocommit"
    Then check general log in host "mysql-master2" has not ""

  @restore_general_log
  Scenario: Backend Global vars are different with dble config,do dble reload -r which makes conn pool recreated will failed
    """
    {'restore_general_log':['mysql-master1','mysql-master2']}
    """
    Given execute sql in "mysql-master"
      | user  | passwd    | conn   | toClose | sql                     | expect  | db     |
      | test  | 111111    | conn_0 | True    | set global autocommit=0 | success | db1 |
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    When execute admin cmd "reload @@config_all -r" success
    Then check general log in host "mysql-master1" has "set global autocommit=1"
    Then check general log in host "mysql-master2" has not "set global autocommit=1"