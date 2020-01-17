# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/11/15

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
    Then get resultset of admin cmd "show @@backend" named "A"
    Then execute admin cmd "reload @@config_all -r"
    Then get resultset of admin cmd "show @@backend" named "B"
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
    Then get resultset of admin cmd "show @@backend" named "C"
    Then check resultset "B" has not lines with following column values
      | HOST-3      |
      | 172.100.9.6 |
    Then check resultset "C" has lines with following column values
      | HOST-3      |
      | 172.100.9.5 |
      | 172.100.9.6 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group2" switchType="2" slaveThreshold="100">
    <heartbeat>show slave status</heartbeat>
    <writeHost host="hostW1" url="172.100.9.4:3306" password="111111" user="test"/>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all -r"
    Then get resultset of admin cmd "show @@backend" named "D"
    Then check resultset "D" has not lines with following column values
      | HOST-3      |
      | 172.100.9.6 |
    Then check resultset "D" has lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
      | 172.100.9.5 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                 | expect  | db      |
      | test | 111111 | conn_0 | true    | drop table if exists sharding_4_t1  | success | schema1 |
      | test | 111111 | conn_0 | true    | create table sharding_4_t1(id int)  | success | schema1 |
      | test | 111111 | conn_0 | false   | begin                               | success | schema1 |
      | test | 111111 | conn_0 | false   | insert into sharding_4_t1 values(1) | success | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
      """
      <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
      <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
      <dataNode name="dn3" dataHost="ha_group1" database="db3"/>
      <dataNode name="dn4" dataHost="ha_group1" database="db4"/>
      <dataNode name="dn5" dataHost="ha_group1" database="db5"/>
      """
    Then execute admin cmd "reload @@config_all -r"
    Then get resultset of admin cmd "show @@backend" named "E"
    Then check "E" only has "1" connection of "172.100.9.4"
    Then check resultset "E" has lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
      | 172.100.9.5 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                    | expect      | db      |
      | test | 111111 | conn_0 | false   | commit                                 | success     | schema1 |
      | test | 111111 | conn_0 | false   | select * from sharding_4_t1 where id=1 | length{(0)} | schema1 |
    Then get resultset of admin cmd "show @@backend" named "F"
    Then check resultset "F" has not lines with following column values
      | HOST-3      |
      | 172.100.9.4 |