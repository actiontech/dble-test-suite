# Copyright (C) 2016-2020 ActionTech.
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
    <dataHost balance="0" maxCon="5" minCon="5" name="ha_group1" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
    </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="5" minCon="5" name="ha_group2" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
    </writeHost>
    </dataHost>
    """
    Given Restart dble in "dble-1" success
    Then get resultset of admin cmd "show @@processlist" named "pro_rs_A"
    Then check resultset "pro_rs_A" has lines with following column values
      | Front_Id-0 | Datanode-1  | BconnID-2   | User-3    | db-5   | Command-6  | Time-7  | Info-9  |
      |    2        | NULL         | NULL         | root      | NULL   | NULL        | 0       | NULL    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose  | sql                                                     | expect    | db         |
      | test | 111111 | conn_0 | False    | drop table if exists test1                           | success   |  schema1  |
      | test | 111111 | conn_0 | False    | create table test1(id int,name varchar(20))        | success   |  schema1  |
       | test | 111111 | conn_0 | False    | drop table if exists test_shard                     | success   |  schema1  |
      | test | 111111 | conn_0 | False    | create table test_shard(id int,name varchar(20))   | success   |  schema1  |
      | test | 111111 | conn_0 | False    | begin                                                    | success   |  schema1  |
      | test | 111111 | conn_0 | False    | select * from test_shard                              | success   |  schema1  |
    Then get resultset of admin cmd "show @@processlist" named "pro_rs_B"
    Then check resultset "pro_rs_B" has lines with following column values
      | Front_Id-0 | Datanode-1 | User-3 | db-5 | Command-6 | Info-9 |
      | 3           | dn1         | test   | db1   | Sleep     | None   |
      | 3           | dn2         | test   | db1   | Sleep     | None   |
      | 3           | dn3         | test   | db2   | Sleep     | None   |
      | 3           | dn4         | test   | db2   | Sleep     | None   |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose  | sql                        | expect    | db         |
      | test | 111111 | conn_1 | False    | begin                      | success   |  schema1  |
      | test | 111111 | conn_1 | False    | select * from test1        | success   |  schema1  |
    Then get resultset of admin cmd "show @@processlist" named "pro_rs_C"
    Then check resultset "pro_rs_C" has lines with following column values
      | Front_Id-0 | Datanode-1   | User-3    | db-5   | Command-6    | Info-9  |
      |    3        | dn1           | test       | db1    | Sleep         | None    |
      |    3        | dn2           | test       | db1    | Sleep         | None    |
      |    3        | dn3           | test       | db2    | Sleep         | None    |
      |    3        | dn4           | test       | db2    | Sleep         | None    |
      |    5        | dn1           | test       | db1    | Sleep         | None    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose  | sql       | expect    | db         |
      | test | 111111 | conn_1 | True     | commit    | success   |  schema1  |
    Then get resultset of admin cmd "show @@processlist" named "pro_rs_D"
    Then check resultset "pro_rs_D" has not lines with following column values
      | Front_Id-0 | Datanode-1   | User-3  | db-5   | Command-6    | Info-9  |
      |    5        | dn1           | test    | db1    | Sleep         | None    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose  | sql                                | expect    | db         |
      | test | 111111 | conn_1 | False    | begin                             | success   |  schema1  |
      | test | 111111 | conn_1 | False    | select * from test_shard       | success   |  schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                    | expect                  | db     |
      | root  | 111111 | conn_2 | True    | show @@processlist   | error totally whack   |         |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose  | sql                    | expect    | db         |
      | test | 111111 | conn_1 | True    | commit                  | success   |  schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                    | expect    | db     |
      | root  | 111111 | conn_2 | True    | show @@processlist   | success   |        |
