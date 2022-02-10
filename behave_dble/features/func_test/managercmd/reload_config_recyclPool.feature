# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/17
#2.19.11.0#dble-7853
Feature: reload @@config_all and recycl pool

  Scenario: modifiy dbGroup url and execute reload @@config_all #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1              | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int)              | schema1 |
      | conn_0 | False   | begin                                           | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1),(2),(3),(4) | schema1 |
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_A"
      | sql            |
      | show @@backend |
    Then check resultset "rs_A" has lines with following column values
      | HOST-3      | STATE-10 |
      | 172.100.9.5 | IDLE       |
      | 172.100.9.5 | IN USE        |
      | 172.100.9.6 | IDLE       |
      | 172.100.9.6 | IN USE        |
    Then check resultset "rs_A" has not lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
    Given update file content "{install_dir}/dble/conf/db.xml" in "dble-1" with sed cmds
    """
    s/172.100.9.6/172.100.9.4/g
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_B"
      | sql            |
      | show @@backend |
    Then check resultset "rs_B" has lines with following column values
      | HOST-3      | STATE-10 |
      | 172.100.9.4 | IDLE       |
      | 172.100.9.4 | IDLE        |
      | 172.100.9.5 | IDLE       |
      | 172.100.9.5 | IN USE        |
      | 172.100.9.6 | IN USE        |
    Then check resultset "rs_B" has not lines with following column values
      | HOST-3      | STATE-10 |
      | 172.100.9.6 | IDLE       |
    Then check "rs_B" only has "2" connection of "172.100.9.6"

    Given update file content "{install_dir}/dble/conf/db.xml" in "dble-1" with sed cmds
    """
    s/172.100.9.4/172.100.9.2/g
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_C"
      | sql            |
      | show @@backend |
    Then check resultset "rs_C" has lines with following column values
      | HOST-3      | STATE-10 |
      | 172.100.9.2 | IDLE       |
      | 172.100.9.2 | IDLE       |
      | 172.100.9.5 | IDLE       |
      | 172.100.9.5 | IN USE        |
      | 172.100.9.6 | IN USE        |
    Then check resultset "rs_C" has not lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
    Then check "rs_C" only has "2" connection of "172.100.9.6"

    Given update file content "{install_dir}/dble/conf/db.xml" in "dble-1" with sed cmds
    """
    s/172.100.9.5/172.100.9.6/g
    """
    Then execute admin cmd "reload @@config_all -f"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_D"
      | sql            |
      | show @@backend |
    Then check resultset "rs_D" has lines with following column values
      | HOST-3      | STATE-10 |
      | 172.100.9.6 | IDLE       |
      | 172.100.9.6 | IDLE        |
      | 172.100.9.2 | IDLE       |
      | 172.100.9.2 | IDLE        |
    Then check resultset "rs_D" has not lines with following column values
      | HOST-3      |
      | 172.100.9.5 |