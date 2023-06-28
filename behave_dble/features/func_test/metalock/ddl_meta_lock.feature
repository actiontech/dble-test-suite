# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# created by caiwei at 2022/02/17

Feature: about ddl metalock test

  # issue: http://10.186.18.11/jira/browse/DBLE0REQ-1615
  Scenario: When one session obtain ddl metalock and execute ddl, other session can not execute ddl  #1

    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="processors">10</property>
    <property name="processorExecutor">10</property>
    """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1 | schema1 |
      | conn_0 | True    | create table sharding_2_t1(id int) | schema1 |
    Given prepare a thread run btrace script "BtraceAddMetaLockForOnce.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      |conn  | toClose | sql                                   | db      |
      |conn_1| False   |truncate table sharding_2_t1           | schema1 |
    Then check btrace "BtraceAddMetaLockForOnce.java" output in "dble-1"
      """
      get into addMetaLock,start sleep
      """

    #make sure other session execute ddl failed no matter how many times when other session is obtain metalock
    Then execute sql in "dble-1" in "user" mode
      |conn  | toClose | sql                                   | db      | expect                                                 |
      |conn_2| False   |truncate table sharding_2_t1           | schema1 | SCHEMA[schema1], TABLE[sharding_2_t1] is doing DDL     |
      |conn_2| False   |truncate table sharding_2_t1           | schema1 | SCHEMA[schema1], TABLE[sharding_2_t1] is doing DDL     |
      |conn_2| False   |truncate table sharding_2_t1           | schema1 | SCHEMA[schema1], TABLE[sharding_2_t1] is doing DDL     |
      |conn_2| False   |truncate table sharding_2_t1           | schema1 | SCHEMA[schema1], TABLE[sharding_2_t1] is doing DDL     |
    #make sure btrace time over
    Given sleep "15" seconds

    Given stop btrace script "BtraceAddMetaLockForOnce.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceAddMetaLockForOnce.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAddMetaLockForOnce.java" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      |conn  | toClose | sql                                 | db      |
      |conn_2| true    | drop table if exists sharding_2_t1  | schema1 |
