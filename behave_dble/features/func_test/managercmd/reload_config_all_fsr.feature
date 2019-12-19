# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/19

Feature: reload @@config_all -fsr

  Scenario: open transaction, and execute "reload @@config_all -fsr" or "reload @@config_all -f -s -r", transaction closed successfully
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
      | schema.xml | {'tag':'root'} | {'tag':'dataHost'} |
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" switchType="2" slaveThreshold="100">
    <heartbeat>show slave status</heartbeat>
    <writeHost host="hostM1" url="172.100.9.5:3306" password="111111" user="test">
    </writeHost>
    </dataHost>
    <dataNode name="dn5" dataHost="ha_group1" database="db5"/>
    <dataNode name="dn4" dataHost="ha_group1" database="db4"/>
    <dataNode name="dn3" dataHost="ha_group1" database="db3"/>
    <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
    <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
    """
    Given Restart dble in "dble-1" success

    # 1 reload @@config_all -fsr, schema.xml is unchanged, backend connection is unchanged
    Then get resultset of admin cmd "show @@backend" named "rs_A"
    Then execute admin cmd "reload @@config_all -fsr"
    Then get resultset of admin cmd "show @@backend" named "rs_B"
    Then check resultsets "rs_A" does not including resultset "rs_B" in following columns
      | column     | column_index |
      | BACKEND_ID | 1            |
      | MYSQLID    | 2            |
      | HOST       | 3            |
      | PORT       | 4            |

    #2 reload @@config_all -fsr: add dataNode, rebuild backend conn , add new backend conn
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
      | schema.xml | {'tag':'root'} | {'tag':'dataHost'} |
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group2" slaveThreshold="100" switchType="1">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
      </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" switchType="1">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
      </writeHost>
    </dataHost>
    <dataNode dataHost="ha_group1" database="db3" name="dn5" />
    <dataNode dataHost="ha_group2" database="db2" name="dn4" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    <dataNode dataHost="ha_group2" database="db1" name="dn2" />
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
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

    #3 Start the transaction, add readHost, Reload config_all -fsr succeeds, the transaction connection is closed, and all connections are rebuilt
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'dataHost'} |
    Given add xml segment to node with attribute "{'tag':'root','prev':'dataNode'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group2" slaveThreshold="100" switchType="1">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="172.100.9.4:3306" user="test">
      </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" switchType="1">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
      <readHost host="hostS1" url="172.100.9.2:3306" password="111111" user="test"/>
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
    Then check resultset "rs_D" has lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
      | 172.100.9.5 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                                    | expect      | db      |
      | test | 111111 | new  | true    | select * from sharding_4_t1 where id=2 | length{(0)} | schema1 |

    #4 Start the transaction, add readHost, Reload config_all -f -s -r succeeds, the transaction connection is closed, and all connections are rebuilt
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                              | expect  | db      |
      | test | 111111 | conn_1 | False   | drop table if exists sharding_4_t1               | success | schema1 |
      | test | 111111 | conn_1 | False   | create table sharding_4_t1 (id int)              | success | schema1 |
      | test | 111111 | conn_1 | False   | begin                                            | success | schema1 |
      | test | 111111 | conn_1 | False   | insert into sharding_4_t1 values (1),(2),(3),(4) | success | schema1 |
    Given change file "schema.xml" in "dble-1" locate "install_dir" with sed cmds
    """
    s/172.100.9.4/172.100.9.6/g
    """
    Then execute admin cmd "reload @@config_all -f -s -r"
    Then get resultset of admin cmd "show @@backend" named "rs_E"
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