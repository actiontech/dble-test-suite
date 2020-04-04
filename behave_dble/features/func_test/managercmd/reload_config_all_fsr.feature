# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/19
#2.19.11.0#dble-7857
Feature: reload @@config_all -fsr

  Scenario: execute "reload @@config_all -fsr" or "reload @@config_all -f -s -r" causing backend connection rebuild and transaction rollback
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
    <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
    <dataNode name="dn3" dataHost="ha_group1" database="db3"/>
    <dataNode name="dn4" dataHost="ha_group1" database="db4"/>
    <dataNode name="dn5" dataHost="ha_group1" database="db5"/>
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4'"

    # 1 execute "reload @@config_all -fsr" can rebuild backend connection
    Then get resultset of admin cmd "show @@backend" named "rs_A"
    Then execute admin cmd "reload @@config_all -fsr"
    Then get resultset of admin cmd "show @@backend" named "rs_B"
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

    #2 if add new dataNode in schema.xml, execute "reload @@config_all -fsr" can add new backend connection
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="db1" name="dn2" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    <dataNode dataHost="ha_group2" database="db2" name="dn4" />
    <dataNode dataHost="ha_group1" database="db3" name="dn5" />
    """
    Then execute admin cmd "reload @@config_all -fsr"
    Then get resultset of admin cmd "show @@backend" named "rs_C"
    Then check resultsets "rs_C" does not including resultset "rs_B" in following columns
      | column     | column_index |
      | BACKEND_ID | 1            |
      | MYSQLID    | 2            |
    Then check resultset "rs_B" has not lines with following column values
      | HOST-3      |
      | 172.100.9.6 |
    Then check resultset "rs_C" has lines with following column values
      | HOST-3      |
      | 172.100.9.5 |
      | 172.100.9.6 |

    #3 execute "config_all -fsr" can close backend connection in transaction and rebuild all connection
    Given add xml segment to node with attribute "{'tag':'root','prev':'dataNode'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
      <readHost host="hostS1" url="172.100.9.2:3306" password="111111" user="testx"/>
      </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group2" slaveThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="172.100.9.4:3306" user="test">
      </writeHost>
    </dataHost>
    """
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                              | expect  | db      |
      | test | 111111 | conn_0 | false   | drop table if exists sharding_4_t1               | success | schema1 |
      | test | 111111 | conn_0 | false   | create table sharding_4_t1 (id int)              | success | schema1 |
      | test | 111111 | conn_0 | False   | begin                                            | success | schema1 |
      | test | 111111 | conn_0 | false   | insert into sharding_4_t1 values (1),(2),(3),(4) | success | schema1 |
    Then execute admin cmd "reload @@config_all -fsr"
    Then get resultset of admin cmd "show @@backend" named "rs_D"
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
      | user | passwd | conn | toClose | sql                                    | expect      | db      |
      | test | 111111 | new  | true    | select * from sharding_4_t1 where id=2 | length{(0)} | schema1 |

    #4 execute "config_all -f -s -r" can close backend connection in transaction and rebuild all connection
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                              | expect  | db      |
      | test | 111111 | conn_1 | False   | drop table if exists sharding_4_t1               | success | schema1 |
      | test | 111111 | conn_1 | False   | create table sharding_4_t1 (id int)              | success | schema1 |
      | test | 111111 | conn_1 | False   | begin                                            | success | schema1 |
      | test | 111111 | conn_1 | False   | insert into sharding_4_t1 values (1),(2),(3),(4) | success | schema1 |
    Given update file content "{install_dir}/dble/conf/schema.xml" in "dble-1" with sed cmds
    """
    s/172.100.9.4/172.100.9.6/g
    """
    Then execute admin cmd "reload @@config_all -f -s -r"
    Then get resultset of admin cmd "show @@backend" named "rs_E"
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
      | user | passwd | conn | toClose | sql                                | expect      | db      |
      | test | 111111 | new  | True    | drop table if exists sharding_4_t1 | length{(0)} | schema1 |