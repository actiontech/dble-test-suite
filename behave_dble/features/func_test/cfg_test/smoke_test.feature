# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2020/11/30

Feature: test with usePerformanceMode & usingAIO & useThreadUsageStat & useCostTimeStat & useSerializableMode on

  @NORMAL
  Scenario: test with usePerformanceMode & usingAIO & useThreadUsageStat & useCostTimeStat & useCompression on, and then execute query success #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DusePerformanceMode=1
    $a\-DusingAIO=1
    $a\-DuseThreadUsageStat=1
    $a\-DuseCostTimeStat=1
    $a\-DuseCompression=1
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect                        | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1              | success                       | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int)              | success                       | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1),(2),(3),(4) | success                       | schema1 |
      | conn_0 | False   | select * from sharding_4_t1 order by id         | has{((1,), (2,), (3,), (4,))} | schema1 |
      | conn_0 | False   | begin                                           | success                       | schema1 |
      | conn_0 | False   | delete from sharding_4_t1 where id in(1,3)      | success                       | schema1 |
      | conn_0 | False   | commit                                          | success                       | schema1 |
      | conn_0 | False   | select * from sharding_4_t1 order by id         | has{((2,), (4,))}             | schema1 |
      | conn_0 | True    | drop table sharding_4_t1                        | success                       | schema1 |
      
  Scenario: test with useSerializableMode on, and then execute DDL fail #2
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DuseSerializableMode=1
    """
    Then Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "user" mode and save resultset in "A"
      | conn   | toClose  | sql                                            | db          |
      | conn_0 | False    | show variables like "%autocommit%"             | schema1     |
    Then check resultset "A" has lines with following column values
      | Variable_name-0         | Value-1 |
      | autocommit              | ON      |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect                                                                    | db      |
      | conn_0 | true    | drop table if exists sharding_4_t1              | Implicit commit statement cannot be executed when xa transaction          | schema1 |
