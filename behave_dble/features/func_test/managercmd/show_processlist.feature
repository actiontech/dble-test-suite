# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/3/11
Feature: #test show @@processlist

  Scenario: use `show @@processlist` to view the correspondence between front and backend session #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <shardingTable name="test_shard" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <singleTable  name="test1" shardingNode="dn1"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0"  name="ha_group1" delayThreshold="100" >
    <heartbeat>select user()</heartbeat>
    <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" primary="true" maxCon="4" minCon="4">
    </dbInstance>
    </dbGroup>
    <dbGroup rwSplitMode="0"  name="ha_group2" delayThreshold="100" >
    <heartbeat>select user()</heartbeat>
    <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" primary="true" maxCon="4" minCon="4">
    </dbInstance>
    </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "pro_rs_A"
      | sql                |
      | show @@processlist |
    Then check resultset "pro_rs_A" has lines with following column values
      | Front_Id-0 | shardingNode-1  | MysqlId-2   | User-3    | db-5   | Command-6  | Time-7  | Info-9  |
      |    2        | NULL       | NULL        | root      | NULL   | NULL       | 0       | NULL    |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                              | db        |
      | conn_0 | False    | drop table if exists test1                       |  schema1  |
      | conn_0 | False    | create table test1(id int,name varchar(20))      |  schema1  |
      | conn_0 | False    | drop table if exists test_shard                  |  schema1  |
      | conn_0 | False    | create table test_shard(id int,name varchar(20)) |  schema1  |
      | conn_0 | False    | begin                                            |  schema1  |
      | conn_0 | False    | select * from test_shard                         |  schema1  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "pro_rs_B"
      | sql                |
      | show @@processlist |
    Then check resultset "pro_rs_B" has lines with following column values
      | Front_Id-0 | shardingNode-1 | User-3 | db-5 | Command-6 | Info-9 |
      | 3          | dn1        | test   | db1  | Sleep     | None   |
      | 3          | dn2        | test   | db1  | Sleep     | None   |
      | 3          | dn3        | test   | db2  | Sleep     | None   |
      | 3          | dn4        | test   | db2  | Sleep     | None   |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                 | db        |
      | conn_1 | False    | begin               |  schema1  |
      | conn_1 | False    | select * from test1 |  schema1  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "pro_rs_C"
      | sql                |
      | show @@processlist |
    Then check resultset "pro_rs_C" has lines with following column values
      | Front_Id-0 | shardingNode-1   | User-3    | db-5   | Command-6    | Info-9  |
      |    3        | dn1         | test      | db1    | Sleep        | None    |
      |    3        | dn2         | test      | db1    | Sleep        | None    |
      |    3        | dn3         | test      | db2    | Sleep        | None    |
      |    3        | dn4         | test      | db2    | Sleep        | None    |
      |    5        | dn1         | test      | db1    | Sleep        | None    |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql    | db        |
      | conn_1 | True     | commit |  schema1  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "pro_rs_D"
      | sql                |
      | show @@processlist |
    Then check resultset "pro_rs_D" has not lines with following column values
      | Front_Id-0 | shardingNode-1   | User-3  | db-5   | Command-6    | Info-9  |
      |    5       | dn1          | test    | db1    | Sleep        | None    |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                      | db        |
      | conn_1 | False    | begin                    |  schema1  |
      | conn_1 | False    | select * from test_shard |  schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | sql                  | expect                |
      | show @@processlist   | error totally whack   |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql     | expect    | db        |
      | conn_1 | True    | commit  | success   |  schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | sql                  |
      | show @@processlist   |
