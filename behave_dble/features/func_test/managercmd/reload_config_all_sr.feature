# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/18
#2.19.11.0#dble-7856
Feature: reload @@config_all -sr

  Scenario: open transaction and execute "reload @@config_all -sr" or "reload @@config_all -s -r" will rebuild connections except connections in transaction
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode name="dn1" dbGroup="ha_group1" database="db1"/>
    <shardingNode name="dn2" dbGroup="ha_group1" database="db2"/>
    <shardingNode name="dn3" dbGroup="ha_group1" database="db3"/>
    <shardingNode name="dn4" dbGroup="ha_group1" database="db4"/>
    <shardingNode name="dn5" dbGroup="ha_group1" database="db5"/>
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "create database @@shardingNode ='dn1,dn2,dn3,dn4'"
    # 1 execute "reload @@config_all -sr" will rebuild backend conn
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_A"
      | sql            |
      | show @@backend |
    Then execute admin cmd "reload @@config_all -rs"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_B"
      | sql            |
      | show @@backend |
    Then check resultsets "rs_A" does not including resultset "rs_B" in following columns
      | column     | column_index |
      | BACKEND_ID | 1            |
      | MYSQLID    | 2            |

    #2 add shardingNode, then execute "reload @@config_all -sr" will rebuild backend conn and add new backend conn
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Then execute admin cmd "reload @@config_all -sr"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_C"
      | sql            |
      | show @@backend |
    Then check resultsets "rs_C" does not including resultset "rs_B" in following columns
      | column     | column_index |
      | BACKEND_ID | 1            |
      | MYSQLID    | 2            |
    Then check resultset "rs_B" has not lines with following column values
      | HOST-3      |USED_FOR_HEARTBEAT-22|
      | 172.100.9.6 |fasle                |
    Then check resultset "rs_C" has lines with following column values
      | HOST-3      |
      | 172.100.9.5 |
      | 172.100.9.6 |

    #3 add dbInstance with err password and start the transaction, then execute "reload config_all -sr" will rebuild connections except connections in transaction
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup name="ha_group1" rwSplitMode="0" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" url="172.100.9.5:3306" user="test" password="111111" maxCon="1000" minCon="10" primary="true" readWeight="1">
        </dbInstance>
        <dbInstance name="hostS1" url="172.100.9.2:3306" user="test" password="errpwd" maxCon="1000" minCon="10" readWeight="2">
        </dbInstance>
    </dbGroup>
    <dbGroup name="ha_group2" rwSplitMode="0" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" url="172.100.9.4:3306" user="test" password="111111" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | db      |
      | conn_0 | false   | drop table if exists sharding_4_t1               | schema1 |
      | conn_0 | false   | create table sharding_4_t1 (id int)              | schema1 |
      | conn_0 | False   | begin                                            | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values (1),(2),(3),(4) | schema1 |
    Then execute admin cmd "reload @@config_all -rs"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_D"
      | sql            |
      | show @@backend |
    Then check resultset "rs_D" has not lines with following column values
      | HOST-3      |
      | 172.100.9.2 |
    Then check resultset "rs_D" has lines with following column values
    #need discuss
      | HOST-3      | STATE-10 |
      | 172.100.9.4 | IDLE       |
      | 172.100.9.5 | IN USE        |
      | 172.100.9.6 | IN USE        |
    Then check "rs_D" only has "2" connection of "172.100.9.6"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect      | db      |
      | conn_0 | false   | commit                                 | success     | schema1 |
      | conn_0 | true    | select * from sharding_4_t1 where id=2 | length{(1)} | schema1 |
    Given sleep "6" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_E"
      | sql            |
      | show @@backend |
    Then check resultset "rs_E" has not lines with following column values
      | HOST-3      |
      | 172.100.9.6 |

    #4 start the transaction and change dbGroup, then execute "reload config_all -s -r" will rebuild connections except connections in transaction
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | db      |
      | conn_0 | false   | drop table if exists sharding_4_t1               | schema1 |
      | conn_0 | false   | create table sharding_4_t1 (id int)              | schema1 |
      | conn_0 | False   | begin                                            | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values (1),(2),(3),(4) | schema1 |
    Given update file content "{install_dir}/dble/conf/db.xml" in "dble-1" with sed cmds
    """
    s/172.100.9.4/172.100.9.6/g
    """
    Then execute admin cmd "reload @@config_all -r -s"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_G"
      | sql            |
      | show @@backend |
    Then check "rs_G" only has "2" connection of "172.100.9.4"
    Then check resultset "rs_G" has lines with following column values
      | HOST-3      | STATE-10 |
      | 172.100.9.4 | IN USE        |
      | 172.100.9.5 | IN USE        |
      | 172.100.9.6 | IDLE       |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                      | expect      | db      |
      | conn_0 | False   | commit                                   | success     | schema1 |
      | conn_0 | true    | select * from sharding_4_t1 where id = 2 | length{(1)} | schema1 |
