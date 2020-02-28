# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/19
#2.19.11.0#dble-7852
Feature: execute manager cmd "reload @@config_all" and check fault tolerance

  Scenario: execute "reload @@config_all" when another ddl is executing
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists sharding_4_t1 | success | schema1 |
    Given change btrace "BtraceClusterDelay.java" locate "./assets" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /removeMetaLock/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | user | passwd | conn   | toClose | sql                                | db      |
      | test | 111111 | conn_0 | False   | create table sharding_4_t1(id int) | schema1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
    """
    delay in removeMetaLock
    """
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                 | expect                                                                  | db      |
      | root | 111111 | conn_0 | True    | reload @@config_all | Reload config failure.The reason is There is other session is doing DDL | schema1 |
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"