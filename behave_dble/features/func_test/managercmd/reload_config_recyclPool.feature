# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/17
#2.19.11.0#dble-7853
Feature: reload @@config_all and recycl pool

  Scenario: modifiy datahost url and execute reload @@config_all #1
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                             | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_4_t1              | success | schema1 |
      | test | 111111 | conn_0 | False   | create table sharding_4_t1(id int)              | success | schema1 |
      | test | 111111 | conn_0 | False   | begin                                           | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into sharding_4_t1 values(1),(2),(3),(4) | success | schema1 |
    Then execute admin cmd "reload @@config_all"
    Then get resultset of admin cmd "show @@backend" named "rs_A"
    Then check resultset "rs_A" has lines with following column values
      | HOST-3      | BORROWED-10 |
      | 172.100.9.5 | false       |
      | 172.100.9.5 | true        |
      | 172.100.9.6 | false       |
      | 172.100.9.6 | true        |
    Then check resultset "rs_A" has not lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
    Given update file content "{install_dir}/dble/conf/schema.xml" in "dble-1" with sed cmds
    """
    s/172.100.9.6/172.100.9.4/g
    """
    Then execute admin cmd "reload @@config_all"
    Then get resultset of admin cmd "show @@backend" named "rs_B"
    Then check resultset "rs_B" has lines with following column values
      | HOST-3      | BORROWED-10 |
      | 172.100.9.4 | false       |
      | 172.100.9.4 | true        |
      | 172.100.9.5 | false       |
      | 172.100.9.5 | true        |
      | 172.100.9.6 | true        |
    Then check resultset "rs_B" has not lines with following column values
      | HOST-3      | BORROWED-10 |
      | 172.100.9.6 | false       |
    Then check "rs_B" only has "2" connection of "172.100.9.6"

    Given update file content "{install_dir}/dble/conf/schema.xml" in "dble-1" with sed cmds
    """
    s/172.100.9.4/172.100.9.2/g
    """
    Then execute admin cmd "reload @@config_all"
    Then get resultset of admin cmd "show @@backend" named "rs_C"
    Then check resultset "rs_C" has lines with following column values
      | HOST-3      | BORROWED-10 |
      | 172.100.9.2 | false       |
      | 172.100.9.2 | true        |
      | 172.100.9.5 | false       |
      | 172.100.9.5 | true        |
      | 172.100.9.6 | true        |
    Then check resultset "rs_C" has not lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
    Then check "rs_C" only has "2" connection of "172.100.9.6"

    Given update file content "{install_dir}/dble/conf/schema.xml" in "dble-1" with sed cmds
    """
    s/172.100.9.5/172.100.9.6/g
    """
    Then execute admin cmd "reload @@config_all -f"
    Then get resultset of admin cmd "show @@backend" named "rs_D"
    Then check resultset "rs_D" has lines with following column values
      | HOST-3      | BORROWED-10 |
      | 172.100.9.6 | false       |
      | 172.100.9.6 | true        |
      | 172.100.9.2 | false       |
      | 172.100.9.2 | true        |
    Then check resultset "rs_D" has not lines with following column values
      | HOST-3      |
      | 172.100.9.5 |