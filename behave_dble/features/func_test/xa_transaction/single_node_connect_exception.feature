# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/2/26
# modified by wjl1619 at 2020/04/21

#2.20.04.0#dble-8177
Feature: backend node disconnect,causing xa abnormal

  @btrace
  Scenario: backend node connection is abnormal, causing xa prepare is abnormal, transaction automatic rollback #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | success | schema1 |
      | conn_0 | False   | set autocommit=0                                        | success | schema1 |
      | conn_0 | False   | set xa = on                                             | success | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaPrepare/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa end
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_A"
       | sql               |
       | show @@session  |
    Then get first mysqlId of "mysql-master1" from "rs_A" named "mysqlID1"
    Then kill mysql connection by "mysqlID1" in "mysql-master1"
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect      | db      |
      | new    | True    | select * from sharding_4_t1                             | length{(0)} | schema1 |
      | conn_0 | false   | begin                                                   | success     | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success     | schema1 |
      | conn_0 | true    | commit                                                  | success     | schema1 |
      | new    | true    | select * from sharding_4_t1                             | length{(4)} | schema1 |
      | new    | true    | drop table if exists sharding_4_t1                      | success     | schema1 |
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"

  @btrace
  Scenario:backend node connection is abnormal, causing xa end is abnormal, transaction manual rollback
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Dprocessors=1/c -Dprocessors=2
    /-DprocessorExecutor=1/c -DprocessorExecutor=2
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                  | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name char)       | success | schema1 |
      | conn_1 | False   | set xa = on                                             | success | schema1 |
      | conn_1 | False   | begin                                                    | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaEnd/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_1"
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_B"
       | sql               |
       | show @@session  |
    Then get first mysqlId of "mysql-master1" from "rs_B" named "mysqlID2"
    Then kill mysql connection by "mysqlID2" in "mysql-master1"
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect      | db      |
      | conn_1 | false   | select * from sharding_4_t1                             | rollback    | schema1 |
      | conn_1 | false   | rollback                                                | success     | schema1 |
      | conn_1 | false   | begin                                                   | success     | schema1 |
      | conn_1 | false   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success     | schema1 |
      | conn_1 | false   | commit                                                  | success     | schema1 |
      | conn_1 | True   | select * from sharding_4_t1                             | length{(4)} | schema1 |
     #DDL is not allowed to be executed in xa transaction in 3.20.07, so we need use a new connect to drop table.
      | new | true    | drop table if exists sharding_4_t1                      | success     | schema1 |
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
