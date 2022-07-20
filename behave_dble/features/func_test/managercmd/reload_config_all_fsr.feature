# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/19
#2.19.11.0#dble-7857
Feature: reload @@config_all -fsr

  Scenario: execute "reload @@config_all -fsr" or "reload @@config_all -f -s -r" causing backend connection rebuild and transaction rollback
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

    # 1 execute "reload @@config_all -fsr" can rebuild backend connection
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_A"
      | sql            |
      | show @@backend |
    Then execute admin cmd "reload @@config_all -fsr"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_B"
      | sql            |
      | show @@backend |
    Then check resultsets "rs_A" does not including resultset "rs_B" in following columns
      | column     | column_index |
      | BACKEND_ID | 1            |
      | MYSQLID    | 2            |
    Then check resultset "rs_A" has lines with following column values
      | HOST-3      |
      | 172.100.9.5 |
    Then check resultset "rs_B" has lines with following column values
      | HOST-3      |
      | 172.100.9.5 |

    #2 if add new shardingNode in sharding.xml, execute "reload @@config_all -fsr" can add new backend connection
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Then execute admin cmd "reload @@config_all -fsr"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_C"
      | sql            |
      | show @@backend |
    Then check resultsets "rs_C" does not including resultset "rs_B" in following columns
      | column     | column_index |
      | BACKEND_ID | 1            |
      | MYSQLID    | 2            |
    Then check resultset "rs_B" has not lines with following column values
      | HOST-3      |USED_FOR_HEARTBEAT-22|
      | 172.100.9.6 |false                |
    Then check resultset "rs_C" has lines with following column values
      | HOST-3      |
      | 172.100.9.5 |
      | 172.100.9.6 |

    #3 execute "config_all -fsr" can close backend connection in transaction and rebuild all connection
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup name="ha_group1" rwSplitMode="0" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" url="172.100.9.5:3306" user="test" password="111111" maxCon="1000" minCon="10" primary="true" readWeight="1">
        </dbInstance>
        <dbInstance name="hostS1" url="172.100.9.2:3306" user="testx" password="errpwd" maxCon="1000" minCon="10" readWeight="2">
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
    Then execute admin cmd "reload @@config_all -fsr"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_D"
      | sql            |
      | show @@backend |
    Then check resultsets "rs_D" does not including resultset "rs_C" in following columns
      | column     | column_index |
      | BACKEND_ID | 1            |
      | MYSQLID    | 2            |
    Then check resultset "rs_D" has not lines with following column values
      | HOST-3      |
      | 172.100.9.6 |
      | 172.100.9.2 |
    Then check resultset "rs_D" has lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
      | 172.100.9.5 |
    Then execute sql in "dble-1" in "user" mode
      | sql                                    | expect      | db      |
      | select * from sharding_4_t1 where id=2 | length{(0)} | schema1 |

    #4 execute "config_all -f -s -r" can close backend connection in transaction and rebuild all connection
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1               | schema1 |
      | conn_1 | False   | create table sharding_4_t1 (id int)              | schema1 |
      | conn_1 | False   | begin                                            | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values (1),(2),(3),(4) | schema1 |
    Given update file content "{install_dir}/dble/conf/db.xml" in "dble-1" with sed cmds
    """
    s/172.100.9.4/172.100.9.6/g
    """
    Then execute admin cmd "reload @@config_all -f -s -r"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_E"
      | sql            |
      | show @@backend |
    Then check resultsets "rs_E" does not including resultset "rs_D" in following columns
      | column     | column_index |
      | BACKEND_ID | 1            |
      | MYSQLID    | 2            |
    Then check resultset "rs_E" has lines with following column values
      | HOST-3      |
      | 172.100.9.6 |
      | 172.100.9.5 |
    Then check resultset "rs_E" has not lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect      | db      |
      | drop table if exists sharding_4_t1 | length{(0)} | schema1 |