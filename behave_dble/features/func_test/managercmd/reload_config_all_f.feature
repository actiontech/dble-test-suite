# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/16

Feature: reload @@config_all -f

  Scenario: execute manager cmd "reload @@config_all -f" after add or change dataNode/dataHost #1
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
      """
      <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
      <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
      <dataNode name="dn3" dataHost="ha_group1" database="db3"/>
      <dataNode name="dn4" dataHost="ha_group1" database="db4"/>
      <dataNode name="dn5" dataHost="ha_group1" database="db5"/>
      """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4,dn5'"
    Then get resultset of admin cmd "show @@backend" named "A"
    Then execute admin cmd "reload @@config_all -f"
    Then get resultset of admin cmd "show @@backend" named "B"
    Then check resultsets "B" including resultset "A" in following columns
      | column         | column_index |
      | processor      | 0            |
      | BACKEND_ID     | 1            |
      | MYSQLID        | 2            |
      | HOST           | 3            |
      | PORT           | 4            |
      | LOACL_TCP_PORT | 5            |
      | CLOSED         | 9            |
      | SYS_VARIABLES  | 18           |
      | USER_VARIABLES | 19           |
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
      """
      <dataNode dataHost="ha_group1" database="db1" name="dn1" />
      <dataNode dataHost="ha_group2" database="db1" name="dn2" />
      <dataNode dataHost="ha_group1" database="db2" name="dn3" />
      <dataNode dataHost="ha_group2" database="db2" name="dn4" />
      <dataNode dataHost="ha_group1" database="db3" name="dn5" />
      """
    Then execute admin cmd "reload @@config_all -f"
    Then get resultset of admin cmd "show @@backend" named "C"
    Then check resultset "C" has lines with following column values
      | PORT-4 | HOST-3      |
      | 3306   | 172.100.9.5 |
      | 3306   | 172.100.9.6 |
    Then check resultset "B" has not lines with following column values
      | PORT-4 | HOST-3      |
      | 3306   | 172.100.9.6 |


    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group2" switchType="2" slaveThreshold="100">
    <heartbeat>show slave status</heartbeat>
    <writeHost host="hostW1" url="172.100.9.4:3306" password="111111" user="test"/>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all -f"
    Then get resultset of admin cmd "show @@backend" named "D"
    Then check resultset "D" has not lines with following column values
      | PORT-4 | HOST-3      |
      | 3306   | 172.100.9.6 |
    Then check resultset "D" has lines with following column values
      | PORT-4 | HOST-3      |
      | 3306   | 172.100.9.4 |
      | 3306   | 172.100.9.5 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
      """
      <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
      <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
      <dataNode name="dn3" dataHost="ha_group1" database="db3"/>
      <dataNode name="dn4" dataHost="ha_group1" database="db4"/>
      <dataNode name="dn5" dataHost="ha_group1" database="db5"/>
      """
    Then execute admin cmd "reload @@config_all -f"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                             | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_4_t1              | success | schema1 |
      | test | 111111 | conn_0 | False   | create table sharding_4_t1(id int)              | success | schema1 |
      | test | 111111 | conn_0 | False   | begin                                           | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into sharding_4_t1 values(1),(2),(3),(4) | success | schema1 |
    Then execute admin cmd "reload @@config_all -f"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                      | expect      | db      |
      | test | 111111 | conn_1 | True    | select * from sharding_4_t1 where id = 2 | length{(0)} | schema1 |