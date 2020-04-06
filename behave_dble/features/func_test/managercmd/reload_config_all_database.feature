# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/19
#2.19.11.0#dble-7851
Feature: execute manager cmd "create database @@datanode"

  Scenario: modify dataNode in schema.xml and execute manager cmd "create database @@datanode" to create database
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_A"
      | sql            |
      | show @@backend |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="dn1" name="dn2" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    <dataNode dataHost="ha_group2" database="dn2" name="dn4" />
    <dataNode dataHost="ha_group1" database="db3" name="dn5" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                  | expect  |
      | create database @@datanode='dn2,dn4' | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_B"
      | sql            |
      | show @@backend |
    Then check resultsets "rs_A" including resultset "rs_B" in following columns
      | column     | column_index |
      | BACKEND_ID | 1            |
      | MYSQLID    | 2            |
      | HOST       | 3            |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1 | schema1 |
      | conn_0 | True    | create table sharding_4_t1(id int) | schema1 |
    Given sleep "3" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_C"
      | sql            |
      | show @@backend |
    Then check resultset "rs_C" has lines with following column values
      | HOST-3      | SCHEMA-12 |
      | 172.100.9.6 | dn1       |
      | 172.100.9.6 | dn2       |