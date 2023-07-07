# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/16
#2.19.11.0#dble-7848
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
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql            |
      | show @@backend |
    Then execute admin cmd "reload @@config_all -f"
    #sleep 2s，等待所有连接回收及新建成功
    Given sleep "2" seconds
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
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
      """
      <dataNode dataHost="ha_group1" database="db1" name="dn1" />
      <dataNode dataHost="ha_group2" database="db1" name="dn2" />
      <dataNode dataHost="ha_group1" database="db2" name="dn3" />
      <dataNode dataHost="ha_group2" database="db2" name="dn4" />
      <dataNode dataHost="ha_group1" database="db3" name="dn5" />
      """
    Then execute admin cmd "reload @@config_all -f"
    #sleep 2s，等待所有连接回收及新建成功
    Given sleep "2" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
      | sql            |
      | show @@backend |
    Then check resultset "C" has lines with following column values
      | PORT-4 | HOST-3      |
      | 3306   | 172.100.9.5 |
      | 3306   | 172.100.9.6 |
    Then check resultset "B" has not lines with following column values
      | PORT-4 | HOST-3      | USED_FOR_HEARTBEAT-22 |
      | 3306   | 172.100.9.6 | false                 |


    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group2" slaveThreshold="100">
    <heartbeat>show slave status</heartbeat>
    <writeHost host="hostW1" url="172.100.9.4:3306" password="111111" user="test"/>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all -f"
    #sleep 2s，等待所有连接回收及新建成功
    Given sleep "2" seconds
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
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1              | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int)              | success | schema1 |
      | conn_0 | False   | begin                                           | success | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(1),(2),(3),(4) | success | schema1 |
    Then execute admin cmd "reload @@config_all -f"
    Then execute sql in "dble-1" in "user" mode
      | sql                                      | expect      | db      |
      | select * from sharding_4_t1 where id = 2 | length{(0)} | schema1 |
      | drop table if exists sharding_4_t1       | success     | schema1 |


  Scenario:  case from github issue:1526#2
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
      """
      <property name="useOuterHa">true</property>
      """
    Given Restart dble in "dble-1" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
      """
      <schema dataNode="dn2" name="schema1" sqlMaxLimit="100">
          <table name="sharding2" dataNode="dn1,dn2" rule="hash-two" />
      </schema>
      <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group2" slaveThreshold="100" >
        <heartbeat>select 1</heartbeat>
        <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
          <readHost host="slave1" password="111111" url="172.100.9.6:3307" user="test"/>
        </writeHost>
      </dataHost>
      """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  | db      |
      | conn_0 | False   | drop table if exists test              | success | schema1 |
      | conn_0 | False   | create table test(id int)              | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                | expect  |
      | dataHost @@disable name='ha_group2'                | success |
      | reload @@config_all -f                             | success |
      | dataHost @@switch name='ha_group2' master='slave1' | success |
      | dataHost @@enable name='ha_group2'                 | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  | db      | timeout |
      | conn_0 | False   | insert into test values(1),(2),(3),(4) | success | schema1 | 11,2    |
      | conn_0 | true    | drop table if exists test              | success | schema1 | 11,2    |