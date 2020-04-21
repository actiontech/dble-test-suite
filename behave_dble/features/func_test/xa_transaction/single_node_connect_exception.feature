# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/2/26
# modified by wjl1619 at 2020/04/21

# 2.19.11.0#dble-7870
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
    Given change btrace "BtraceXaDelay.java" locate "./assets" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaPrepare/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa end
    """
    Then get resultset of admin cmd "show @@session" named "rs_A"
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
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="processors">2</property>
    <property name="processorExecutor">2</property>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name char)            | success | schema1 |
      | conn_1 | False   | set autocommit=0                                        | success | schema1 |
      | conn_1 | False   | set xa = on                                             | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given change btrace "BtraceXaDelay.java" locate "./assets" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaEnd/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_1"
    Given sleep "5" seconds
    Then get resultset of admin cmd "show @@session" named "rs_B"
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
      | conn_1 | false   | select * from sharding_4_t1                             | length{(4)} | schema1 |
      | conn_1 | true    | drop table if exists sharding_4_t1                      | success     | schema1 |
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
