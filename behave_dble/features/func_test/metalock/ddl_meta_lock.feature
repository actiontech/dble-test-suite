# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2019/6/25
@skip
Feature: ddl metalock in dble test suites
  # this is a sample for using btrace

  Scenario: ddl metalock in dble released when client interruption occured during select 1 phrase #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1 | schema1 |
      | conn_0 | True    | create table sharding_4_t1(id int) | schema1 |
    Given prepare a thread run btrace script "BtraceAddMetaLock.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | sql                                   | db      |
      | truncate table sharding_4_t1/*id123*/ | schema1 |
    Then check btrace "BtraceAddMetaLock.java" output in "dble-1"
    """
    enter metalock and start sleep
    """
    Given kill mysql query in "dble-1" forcely
    """
    truncate table sharding_4_t1/*id123*/
    """
    Given stop btrace script "BtraceAddMetaLock.java" in "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | sql                           | db      |
      | truncate table sharding_4_t1  | schema1 |
    Given destroy btrace threads list