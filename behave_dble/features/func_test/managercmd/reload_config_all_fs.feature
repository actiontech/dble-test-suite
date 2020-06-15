# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/17
#2.19.11.0#dble-7854
Feature: execute manager cmd: "reload @@config_all -fs" or "reload @@config_all -f -s", transaction will be closed successfully

  Scenario: open transaction, and execute "reload @@config_all -fs" or "reload @@config_all -f -s", transaction closed successfully
    #1 reload @@config_all -fs : sharding.xml is unchanged, backend connection is unchanged too
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode name="dn1" dbGroup="ha_group1" database="db1"/>
    <shardingNode name="dn2" dbGroup="ha_group1" database="db2"/>
    <shardingNode name="dn3" dbGroup="ha_group1" database="db3"/>
    <shardingNode name="dn4" dbGroup="ha_group1" database="db4"/>
    <shardingNode name="dn5" dbGroup="ha_group1" database="db5"/>
    """
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_A"
      | sql            |
      | show @@backend |
    Then execute admin cmd "reload @@config_all -fs"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_B"
      | sql            |
      | show @@backend |
    Then check resultsets "rs_A" and "rs_B" are same in following columns
      | column  | column_index |
      | MYSQLID | 2            |
      | HOST    | 3            |

    #2 reload @@config_all -fs : add shardingnode, backend add node connections too
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
    """
       <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
       <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
       <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
       <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
       <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Then execute admin cmd "reload @@config_all -fs"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_C"
      | sql            |
      | show @@backend |
    Then check resultset "rs_B" has not lines with following column values
      | HOST-3      |
      | 172.100.9.6 |
    Then check resultset "rs_C" has lines with following column values
      | HOST-3      |
      | 172.100.9.5 |
      | 172.100.9.6 |

    # 3 reload @@config_all -fs : open transaction, add bad dbInstance, execute 'reload @@config_all -fs', transaction closed successfully
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10"  readWeight="1" primary="true">
         </dbInstance>
         <dbInstance name="hostS1" url="172.100.9.2:3306" user="testx" password="111111" maxCon="1000" minCon="10" readWeight="2">
         </dbInstance>
      </dbGroup>
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1              | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int)              | schema1 |
      | conn_0 | False   | begin                                           | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1),(2),(3),(4) | schema1 |
    Then execute admin cmd "reload @@config_all -fs"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_D"
      | sql            |
      | show @@backend |
    Then check resultset "rs_D" has lines with following column values
      | HOST-3      |
      | 172.100.9.5 |
      | 172.100.9.6 |
    Then check resultset "rs_D" has not lines with following column values
      | HOST-3      |
      | 172.100.9.2 |
    Then execute sql in "dble-1" in "user" mode
      | sql                                      | expect      | db      |
      | select * from sharding_4_t1 where id = 2 | length{(0)} | schema1 |

    # 4 reload @@config_all -f -s : open transaction, add bad dbInstance, execute 'reload @@config_all -f -s', transaction closed successfully
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | db      |
      | conn_1 | false   | drop table if exists sharding_4_t1              | schema1 |
      | conn_1 | false   | create table sharding_4_t1(id int)              | schema1 |
      | conn_1 | false   | begin                                           | schema1 |
      | conn_1 | false   | insert into sharding_4_t1 values(1),(2),(3),(4) | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup name="ha_group2" rwSplitMode="0" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" url="172.100.9.4:3306" user="test" password="111111" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all -f -s"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_E"
      | sql            |
      | show @@backend |
    Then check resultset "rs_E" has lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
      | 172.100.9.5 |
    Then check resultset "rs_E" has not lines with following column values
      | HOST-3      |
      | 172.100.9.6 |
      | 172.100.9.2 |
    Then execute sql in "dble-1" in "user" mode
      | sql                                      | expect      | db      |
      | select * from sharding_4_t1 where id = 2 | length{(0)} | schema1 |