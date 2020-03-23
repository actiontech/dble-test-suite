# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/17
#2.19.11.0#dble-7854
Feature: execute manager cmd: "reload @@config_all -fs" or "reload @@config_all -f -s", transaction will be closed successfully

  @skip #for issue http://10.186.18.11/jira/browse/DBLE0REQ-181
  Scenario: open transaction, and execute "reload @@config_all -fs" or "reload @@config_all -f -s", transaction closed successfully
    #1 reload @@config_all -fs : schema.xml is unchanged, backend connection is unchanged too
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
    <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
    <dataNode name="dn3" dataHost="ha_group1" database="db3"/>
    <dataNode name="dn4" dataHost="ha_group1" database="db4"/>
    <dataNode name="dn5" dataHost="ha_group1" database="db5"/>
    """
    Given Restart dble in "dble-1" success
    Then get resultset of admin cmd "show @@backend" named "rs_A"
    Then execute admin cmd "reload @@config_all -fs"
    Then get resultset of admin cmd "show @@backend" named "rs_B"
    Then check resultsets "rs_A" and "rs_B" are same in following columns
      | column  | column_index |
      | MYSQLID | 2            |
      | HOST    | 3            |

    #2 reload @@config_all -fs : add datanode, backend add node connections too
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
    """
       <dataNode dataHost="ha_group1" database="db1" name="dn1" />
       <dataNode dataHost="ha_group2" database="db1" name="dn2" />
       <dataNode dataHost="ha_group1" database="db2" name="dn3" />
       <dataNode dataHost="ha_group2" database="db2" name="dn4" />
       <dataNode dataHost="ha_group1" database="db3" name="dn5" />
    """
    Then execute admin cmd "reload @@config_all -fs"
    Then get resultset of admin cmd "show @@backend" named "rs_C"
    Then check resultset "rs_B" has not lines with following column values
      | HOST-3      |
      | 172.100.9.6 |
    Then check resultset "rs_C" has lines with following column values
      | HOST-3      |
      | 172.100.9.5 |
      | 172.100.9.6 |

    # 3 reload @@config_all -fs : open transaction, add bad readHost, execute 'reload @@config_all -fs', transaction closed successfully
    Given add xml segment to node with attribute "{'tag':'dataHost/writeHost','kv_map':{'host':'hostM1'}}" in "schema.xml"
    """
        <readHost host="hostS1" url="172.100.9.2:3306" password="111111" user="testx"/>
    """
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                             | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_4_t1              | success | schema1 |
      | test | 111111 | conn_0 | False   | create table sharding_4_t1(id int)              | success | schema1 |
      | test | 111111 | conn_0 | False   | begin                                           | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into sharding_4_t1 values(1),(2),(3),(4) | success | schema1 |
    Then execute admin cmd "reload @@config_all -fs"
    Then get resultset of admin cmd "show @@backend" named "rs_D"
    Then check resultset "rs_D" has lines with following column values
      | HOST-3      |
      | 172.100.9.5 |
      | 172.100.9.6 |
    Then check resultset "rs_D" has not lines with following column values
      | HOST-3      |
      | 172.100.9.2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                                      | expect      | db      |
      | test | 111111 | new  | true    | select * from sharding_4_t1 where id = 2 | length{(0)} | schema1 |

    # 4 reload @@config_all -f -s : open transaction, add bad readHost, execute 'reload @@config_all -f -s', transaction closed successfully
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                             | expect  | db      |
      | test | 111111 | conn_1 | false   | drop table if exists sharding_4_t1              | success | schema1 |
      | test | 111111 | conn_1 | false   | create table sharding_4_t1(id int)              | success | schema1 |
      | test | 111111 | conn_1 | false   | begin                                           | success | schema1 |
      | test | 111111 | conn_1 | false   | insert into sharding_4_t1 values(1),(2),(3),(4) | success | schema1 |
    Given add xml segment to node with attribute "{'tag':'root','prev':'dataNode'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group2" slaveThreshold="100" >
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM2" password="111111" url="172.100.9.4:3306" user="test">
    </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all -f -s"
    Then get resultset of admin cmd "show @@backend" named "rs_E"
    Then check resultset "rs_E" has lines with following column values
      | HOST-3      |
      | 172.100.9.4 |
      | 172.100.9.5 |
    Then check resultset "rs_E" has not lines with following column values
      | HOST-3      |
      | 172.100.9.6 |
      | 172.100.9.2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                                      | expect      | db      |
      | test | 111111 | new  | true    | select * from sharding_4_t1 where id = 2 | length{(0)} | schema1 |