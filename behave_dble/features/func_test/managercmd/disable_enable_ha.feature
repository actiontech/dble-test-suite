# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2019/12/11
Feature: test high-availability related commands
  ha related commands to test:
  dbGroup @@disable name='xxx' [instance='xxx']
  dbGroup @@enable name='xxx' [instance='xxx']
  dbGroup @@switch name='xxx' master='xxx'
  show @@dbinstance

  Scenario: end to end ha switch test
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     $a -DuseOuterHa=true
    """
    Given Restart dble in "dble-1" success
#   a transaction in processing
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect   | db       |
      | conn_0 | False    | drop table if exists sharding_4_t1         | success  |  schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int)         | success  |  schema1 |
      | conn_0 | False    | begin                                      | success  |  schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1),(2)    | success  |  schema1 |
    Then execute admin cmd "dbGroup @@disable name='ha_group2'"
#    check transaction is killed forcely
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                         | expect                        | db       |
      | conn_0 | true     | select * from sharding_4_t1 |  [ha_group2.hostM2] is disabled|  schema1 |

    Then check exist xml node "{'tag':'dbGroup/dbInstance','kv_map':{'name':'hostM2'}}" in " /opt/dble/conf/db.xml" in host "dble-1"
#    The expect fail msg is tmp,for github issue:#1528
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect              | db        |
      | conn_0 | true     | insert into sharding_4_t1 values(1),(2)    | error totally whack |  schema1  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_be_rs"
      | sql            |
      | show @@backend |
    Then check resultset "show_be_rs" has not lines with following column values
    | HOST-3      | PORT-4 |
    | 172.100.9.6 | 3306   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
      | sql               |
      | show @@dbinstance |
    Then check resultset "show_ds_rs" has lines with following column values
    | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4| ACTIVE-5 | DISABLED-10 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | W    |      0   | true        |
    | ha_group1  | hostM1   | 172.100.9.5   | 3306   | W    |      0   | false       |
    Given update "bootstrap.cnf" from "dble-1"

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" readWeight="1" disabled="true">
        </dbInstance>
        <dbInstance name="slave1" url="172.100.9.2:3306" user="test" password="111111" maxCon="1000" minCon="10" readWeight="2" disabled="true">
        </dbInstance>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
      | sql               |
      | show @@dbinstance |
    Then check resultset "show_ds_rs" has lines with following column values
    | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4| ACTIVE-5 | DISABLED-10 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | W    |      0   |  true      |
    | ha_group2  | slave1   | 172.100.9.2   | 3306   | R    |      0   |  true       |
    | ha_group1  | hostM1   | 172.100.9.5   | 3306   | W    |      0   |  false      |
    Then execute admin cmd "dbGroup @@switch name='ha_group2' master='slave1'"
    Then check exist xml node "{'tag':'dbGroup/dbInstance','kv_map':{'name':'hostM2','disabled':'true'}}" in " /opt/dble/conf/db.xml" in host "dble-1"
    Then check exist xml node "{'tag':'dbGroup/dbInstance','kv_map':{'name':'slave1','disabled':'true'}}" in " /opt/dble/conf/db.xml" in host "dble-1"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
      | sql               |
      | show @@dbinstance |
    Then check resultset "show_ds_rs" has lines with following column values
    | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5 | DISABLED-10 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | R      |      0   | true        |
    | ha_group2  | slave1   | 172.100.9.2   | 3306   | W      |      0   | true        |
    Then execute admin cmd "dbGroup @@enable name='ha_group2'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
      | sql               |
      | show @@dbinstance |
    Then check resultset "show_ds_rs" has lines with following column values
    | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5| DISABLED-10 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | R      |     0   | false       |
    | ha_group2  | slave1   | 172.100.9.2   | 3306   | W      |     0   | false       |
#     Then check exist xml node "{'tag':'dbGroup/dbinstance','kv_map':{'name':'hostM2'}}" in " /opt/dble/conf/db.xml" in host "dble-1"
#     Then check exist xml node "{'tag':'dbGroup/dbinstance','kv_map':{'name':'slave1'}}" in " /opt/dble/conf/db.xml" in host "dble-1"
#    dble-2 is slave1's server
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                             | expect  |
      | conn_0 | False   | set global general_log=on       | success |
      | conn_0 | False   | set global log_output='table'   | success |
      | conn_0 | True    | truncate table mysql.general_log| success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect   | db        |
      | conn_0 | False    | insert into sharding_4_t1 values(1),(2)    | success  |  schema1  |
      | conn_0 | True     | select * from sharding_4_t1                | success  |  schema1  |
    Then execute sql in "mysql-slave1"
      | sql                                                                                           | expect      | db  |
      | select count(*) from mysql.general_log where argument like'insert into sharding_4_t1 values%' | length{(1)} | db1 |
    Then execute admin cmd "dbGroup @@disable name='ha_group2' instance='slave1'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
      | sql               |
      | show @@dbinstance |
    Then check resultset "show_ds_rs" has lines with following column values
    | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5 | DISABLED-10 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | R      |      0   | false       |
    | ha_group2  | slave1   | 172.100.9.2   | 3306   | W      |      0   | true        |
    Then execute admin cmd "dbGroup @@switch name='ha_group2' master='hostM2'"
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
      | sql               |
      | show @@dbinstance |
    Then check resultset "show_ds_rs" has lines with following column values
    | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5 | DISABLED-10 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | W      |      0   | false       |
    | ha_group2  | slave1   | 172.100.9.2   | 3306   | R      |      0   | true        |