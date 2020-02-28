# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/19
#2.19.11.0#dble-7851
Feature: execute manager cmd "create database @@datanode"

  Scenario: modify dataNode in schema.xml and execute manager cmd "create database @@datanode" to create database
    Then get resultset of admin cmd "show @@backend" named "rs_A"
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
      | user | passwd | conn   | toClose | sql                                  | expect  | db |
      | root | 111111 | conn_0 | True    | create database @@datanode='dn2,dn4' | success |    |
    Then get resultset of admin cmd "show @@backend" named "rs_B"
    Then check resultsets "rs_A" including resultset "rs_B" in following columns
      | column     | column_index |
      | BACKEND_ID | 1            |
      | MYSQLID    | 2            |
      | HOST       | 3            |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_4_t1 | success | schema1 |
      | test | 111111 | conn_0 | True    | create table sharding_4_t1(id int) | success | schema1 |
    Given sleep "3" seconds
    Then get resultset of admin cmd "show @@backend" named "rs_C"
    Then check resultset "rs_C" has lines with following column values
      | HOST-3      | SCHEMA-12 |
      | 172.100.9.6 | dn1       |
      | 172.100.9.6 | dn2       |