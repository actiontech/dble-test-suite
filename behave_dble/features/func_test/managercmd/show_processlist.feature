# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/3/11
Feature: #test show @@processlist

  Scenario: use `show @@processlist` to view the correspondence between front and backend session #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
      <table name="test_shard" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
      <table name="test1" dataNode="dn1"/>
    </schema>
    <dataHost balance="0" maxCon="5" minCon="5" name="ha_group1" slaveThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
      </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="5" minCon="5" name="ha_group2" slaveThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
      </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                              | db       |
      | conn_0 | False    | drop table if exists test1                       | schema1  |
      | conn_0 | False    | create table test1(id int,name varchar(20))      | schema1  |
      | conn_0 | False    | drop table if exists test_shard                  | schema1  |
      | conn_0 | False    | create table test_shard(id int,name varchar(20)) | schema1  |
      | conn_0 | False    | begin                                            | schema1  |
      | conn_0 | False    | select * from test_shard                         | schema1  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "pro_rs_B"
      | sql                |
      | show @@processlist |
    Then check resultset "pro_rs_B" has lines with following column values
      | Datanode-1 | User-3 | db-5 | Command-6 | Info-9 |
      | dn1        | test   | db1  | Sleep     | None   |
      | dn2        | test   | db1  | Sleep     | None   |
      | dn3        | test   | db2  | Sleep     | None   |
      | dn4        | test   | db2  | Sleep     | None   |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                 | db       |
      | conn_1 | False    | begin               | schema1  |
      | conn_1 | False    | select * from test1 | schema1  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "pro_rs_C"
      | sql                |
      | show @@processlist |
    Then check resultset "pro_rs_C" has lines with following column values
      | Datanode-1 | User-3 | db-5 | Command-6 | Info-9 |
      | dn1        | test   | db1  | Sleep     | None   |
      | dn2        | test   | db1  | Sleep     | None   |
      | dn3        | test   | db2  | Sleep     | None   |
      | dn4        | test   | db2  | Sleep     | None   |
      | dn1        | test   | db1  | Sleep     | None   |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql    | db       |
      | conn_1 | True     | commit | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                | except       |
      | conn_3 | True     | show @@processlist | length{(0)}  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                      | db       |
      | conn_1 | False    | begin                    | schema1  |
      | conn_1 | False    | select * from test_shard | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | sql                  | expect                                     |
      | show @@processlist   | backend connection acquisition exception   |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql     | expect    | db       |
      | conn_1 | True    | commit  | success   | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | sql                  |
      | show @@processlist   |
