# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/16
#2.19.11.0#dble-7848
Feature: reload @@config_all -f

  Scenario: execute manager cmd "reload @@config_all -f" after add or change shardingNode/dbGroup #1
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
      """
      <shardingNode name="dn1" dbGroup="ha_group1" database="db1"/>
      <shardingNode name="dn2" dbGroup="ha_group1" database="db2"/>
      <shardingNode name="dn3" dbGroup="ha_group1" database="db3"/>
      <shardingNode name="dn4" dbGroup="ha_group1" database="db4"/>
      <shardingNode name="dn5" dbGroup="ha_group1" database="db5"/>
      """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "create database @@shardingNode ='dn1,dn2,dn3,dn4,dn5'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql            |
      | show @@backend |
    Then execute admin cmd "reload @@config_all -f"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
      | sql            |
      | show @@backend |
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
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
      """
      <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
      <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
      <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
      """
    Then execute admin cmd "reload @@config_all -f"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
      | sql            |
      | show @@backend |
    Then check resultset "C" has lines with following column values
      | PORT-4 | HOST-3      |
      | 3306   | 172.100.9.5 |
      | 3306   | 172.100.9.6 |
    Then check resultset "B" has not lines with following column values
      | PORT-4 | HOST-3      |
      | 3306   | 172.100.9.6 |


    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostW1" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all -f"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "D"
      | sql            |
      | show @@backend |
    Then check resultset "D" has not lines with following column values
      | PORT-4 | HOST-3      |
      | 3306   | 172.100.9.6 |
    Then check resultset "D" has lines with following column values
      | PORT-4 | HOST-3      |
      | 3306   | 172.100.9.4 |
      | 3306   | 172.100.9.5 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <shardingNode name="dn1" dbGroup="ha_group1" database="db1"/>
      <shardingNode name="dn2" dbGroup="ha_group1" database="db2"/>
      <shardingNode name="dn3" dbGroup="ha_group1" database="db3"/>
      <shardingNode name="dn4" dbGroup="ha_group1" database="db4"/>
      <shardingNode name="dn5" dbGroup="ha_group1" database="db5"/>
      """
    Then execute admin cmd "reload @@config_all -f"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1              | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int)              | success | schema1 |
      | conn_0 | False   | begin                                           | success | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(1),(2),(3),(4) | success | schema1 |
    Then execute admin cmd "reload @@config_all -f"
    Then execute sql in "dble-1" in "user" mode
      | sql                                      | expect      | db      |
      | select * from sharding_4_t1 where id = 2 | length{(0)} | schema1 |