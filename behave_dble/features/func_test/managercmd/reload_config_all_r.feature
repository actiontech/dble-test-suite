# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/11/15
#2.19.11.0#dble-7849
Feature: reload @@config_all -r

  Scenario: execute manager cmd "reload @@config_all -r" after add or change dataNode/dataHost #1
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
      """
      <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
      <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
      <dataNode name="dn3" dataHost="ha_group1" database="db3"/>
      <dataNode name="dn4" dataHost="ha_group1" database="db4"/>
      <dataNode name="dn5" dataHost="ha_group1" database="db5"/>
      """
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql            |
      | show @@backend |
    Then execute admin cmd "reload @@config_all -r"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
      | sql            |
      | show @@backend |
    Then check resultsets "B" including resultset "A" in following columns
      | column | column_index |
      | HOST   | 3            |
    Then check resultsets "B" does not including resultset "A" in following columns
      | column     | column_index |
      | BACKEND_ID | 1            |
      | MYSQLID    | 2            |

    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
      """
      <dataNode dataHost="ha_group1" database="db1" name="dn1" />
      <dataNode dataHost="ha_group2" database="db1" name="dn2" />
      <dataNode dataHost="ha_group1" database="db2" name="dn3" />
      <dataNode dataHost="ha_group2" database="db2" name="dn4" />
      <dataNode dataHost="ha_group1" database="db3" name="dn5" />
      """
    Then execute admin cmd "reload @@config_all -r"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
      | sql            |
      | show @@backend |
    Then check resultset "B" has not lines with following column values
      | HOST-3      |
      | 172.100.9.6 |
    Then check resultset "C" has lines with following column values
      | HOST-3      |
      | 172.100.9.5 |
      | 172.100.9.6 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group2" slaveThreshold="100">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostW1" url="172.100.9.4:3306" password="111111" user="test"/>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all -r"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "D"
      | sql            |
      | show @@backend |
    Then check resultset "D" has not lines with following column values
      | HOST-3      |
      | 172.100.9.6 |
    Then check resultset "D" has lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
      | 172.100.9.5 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | db      |
      | conn_0 | false   | drop table if exists sharding_4_t1  | schema1 |
      | conn_0 | false   | create table sharding_4_t1(id int)  | schema1 |
      | conn_0 | false   | begin                               | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values(1) | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
      """
      <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
      <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
      <dataNode name="dn3" dataHost="ha_group1" database="db3"/>
      <dataNode name="dn4" dataHost="ha_group1" database="db4"/>
      <dataNode name="dn5" dataHost="ha_group1" database="db5"/>
      """
    Then execute admin cmd "reload @@config_all -r"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "E"
      | sql            |
      | show @@backend |
    Then check "E" only has "1" connection of "172.100.9.4"
    Then check resultset "E" has lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
      | 172.100.9.5 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect      | db      |
      | conn_0 | false   | commit                                 | success     | schema1 |
      | conn_0 | True    | select * from sharding_4_t1 where id=1 | length{(0)} | schema1 |
# dble recycle transaction conn at 5 seconds, so wait 6s here
    Given sleep "6" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "F"
      | sql            |
      | show @@backend |
    Then check resultset "F" has not lines with following column values
      | HOST-3      |
      | 172.100.9.4 |