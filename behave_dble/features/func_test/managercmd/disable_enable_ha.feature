# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2019/12/11
Feature: test high-availability related commands
  ha related commands to test:
  dataHost @@disable name='xxx' [node='xxx']
  dataHost @@enable name='xxx' [node='xxx']
  dataHost @@switch name='xxx' master='xxx'
  show @@datasource

  Scenario: end to end ha switch test
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
     """
     <property name="useOuterHa">true</property>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="100" minCon="1" name="ha_group2" slaveThreshold="100" switchType="1">
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
        </writeHost>
    </dataHost>
    """
    Given Restart dble in "dble-1" success
#   a transaction in processing
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                        | expect   | db       |
        | test | 111111 | conn_0 | False    | drop table if exists sharding_4_t1         | success  |  schema1  |
        | test | 111111 | conn_0 | False    | create table sharding_4_t1(id int)         | success  |  schema1  |
        | test | 111111 | conn_0 | False    | begin                                      | success  |  schema1  |
        | test | 111111 | conn_0 | False    | insert into sharding_4_t1 values(1),(2)    | success  |  schema1  |
    Then execute admin cmd "dataHost @@disable name='ha_group2'"
#    check transaction is killed forcely
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                              | expect     | db       |
        | test | 111111 | conn_0 | true     | select * from sharding_4_t1      | ha command disable datasource|  schema1 |
    Then check exist xml node "{'tag':'dataHost/writeHost','kv_map':{'host':'hostM2','disabled':'true'}}" in "/opt/dble/conf/schema.xml" in host "dble-1"
#    The expect fail msg is tmp,for github issue:#1528
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                        | expect              | db       |
        | test | 111111 | conn_0 | true     | insert into sharding_4_t1 values(1),(2)    | error totally whack |  schema1  |
    Then get resultset of admin cmd "show @@backend" named "show_be_rs"
    Then check resultset "show_be_rs" has not lines with following column values
    | HOST-3      | PORT-4 |
    | 172.100.9.6 | 3306   |
    Then get resultset of admin cmd "show @@datasource" named "show_ds_rs"
    Then check resultset "show_ds_rs" has lines with following column values
    | DATAHOST-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4| ACTIVE-5 | DISABLED-11 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | W    |      0   | true        |
    | ha_group1  | hostM1   | 172.100.9.5   | 3306   | W    |      1   | false       |
    Given update "schema.xml" from "dble-1"
    Given add xml segment to node with attribute "{'tag':'dataHost/writeHost','kv_map':{'host':'hostM2'}}" in "schema.xml"
    """
    <readHost host="slave1" user="test" password="111111" url="172.100.9.2:3306" disabled="true"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then get resultset of admin cmd "show @@datasource" named "show_ds_rs"
    Then check resultset "show_ds_rs" has lines with following column values
    | DATAHOST-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4| ACTIVE-5 | DISABLED-11 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | W    |      0   |  true       |
    | ha_group2  | slave1   | 172.100.9.2   | 3306   | R    |      0   |  true       |
    | ha_group1  | hostM1   | 172.100.9.5   | 3306   | W    |      1   |  false      |
    Then execute admin cmd "dataHost @@switch name='ha_group2' master='slave1'"
    Then check exist xml node "{'tag':'dataHost/writeHost/readHost','kv_map':{'host':'hostM2','disabled':'true'}}" in "/opt/dble/conf/schema.xml" in host "dble-1"
    Then check exist xml node "{'tag':'dataHost/writeHost','kv_map':{'host':'slave1','disabled':'true'}}" in "/opt/dble/conf/schema.xml" in host "dble-1"
    Then get resultset of admin cmd "show @@datasource" named "show_ds_rs"
    Then check resultset "show_ds_rs" has lines with following column values
    | DATAHOST-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5 | DISABLED-11 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | R      |      0   | true        |
    | ha_group2  | slave1   | 172.100.9.2   | 3306   | W      |      0   | true        |
    Then execute admin cmd "dataHost @@enable name='ha_group2'"
    Then get resultset of admin cmd "show @@datasource" named "show_ds_rs"
    Then check resultset "show_ds_rs" has lines with following column values
    | DATAHOST-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5 | DISABLED-11 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | R      |      1   | false       |
    | ha_group2  | slave1   | 172.100.9.2   | 3306   | W      |      1   | false       |
    Then check exist xml node "{'tag':'dataHost/writeHost/readHost','kv_map':{'host':'hostM2','disabled':'false'}}" in "/opt/dble/conf/schema.xml" in host "dble-1"
    Then check exist xml node "{'tag':'dataHost/writeHost','kv_map':{'host':'slave1','disabled':'false'}}" in "/opt/dble/conf/schema.xml" in host "dble-1"
#    dble-2 is slave1's server
    Then execute sql in "mysql-slave1"
      | user  | passwd    | conn   | toClose | sql                             | expect  | db     |
      | test  | 111111    | conn_0 | False   | set global general_log=on       | success |   |
      | test  | 111111    | conn_0 | False   | set global log_output='table'   | success |   |
      | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |   |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose  | sql                                        | expect   | db        |
      | test | 111111 | conn_0 | False    | insert into sharding_4_t1 values(1),(2)    | success  |  schema1  |
      | test | 111111 | conn_0 | True     | select * from sharding_4_t1                | success  |  schema1  |
    Then execute sql in "mysql-slave1"
      | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
      | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'insert into sharding_4_t1 values%' | length{(1)} | db1 |
    Then execute admin cmd "dataHost @@disable name='ha_group2' node='slave1'"
    Then get resultset of admin cmd "show @@datasource" named "show_ds_rs"
    Then check resultset "show_ds_rs" has lines with following column values
    | DATAHOST-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5 | DISABLED-11 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | R      |      1   | false       |
    | ha_group2  | slave1   | 172.100.9.2   | 3306   | W      |      0   | true        |
    Then execute admin cmd "dataHost @@switch name='ha_group2' master='hostM2'"
    Given Restart dble in "dble-1" success
    Then get resultset of admin cmd "show @@datasource" named "show_ds_rs"
    Then check resultset "show_ds_rs" has lines with following column values
    | DATAHOST-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5 | DISABLED-11 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | W      |      1   | false       |
    | ha_group2  | slave1   | 172.100.9.2   | 3306   | R      |      0   | true        |