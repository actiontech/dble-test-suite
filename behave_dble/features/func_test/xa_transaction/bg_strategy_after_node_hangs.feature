# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/26

#2.20.04.0#dble-8174
  @skip
Feature: retry policy after xa transaction commit failed for mysql service stopped

  @btrace @skip
  Scenario: mysql node hangs causing xa transaction fail to commit,restart mysql node before the front end attempts to commit 5 times , #1
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | schema1 |
      | conn_0 | False   | set autocommit=0                                        | schema1 |
      | conn_0 | False   | set xa=on                                               | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    /beforeInnerRetry/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa prepare
    """
    Given stop mysql in host "mysql-master1"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "1" times
    """
    before inner retry
    """
    Given start mysql in host "mysql-master1"
    Given sleep "10" seconds
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect      | db      |
      | conn_1 | False   | select * from sharding_4_t1 | length{(4)} | schema1 |
      | conn_1 | True    | delete from sharding_4_t1   | success     | schema1 |
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace
  Scenario: mysql node hangs causing xa transaction fail to commit, automatic recovery in background attempts#2
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | success | schema1 |
      | conn_0 | False   | set autocommit=0                                        | success | schema1 |
      | conn_0 | False   | set xa=on                                               | success | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa commit
    """
    Given stop mysql in host "mysql-master1"
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /beforeAddXaToQueue/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds

     Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before add xa
    """
    Given sleep "10" seconds
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given execute oscmd in "dble-1" and "5" less than result
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Given start mysql in host "mysql-master1"
    Given sleep "10" seconds
    Then execute oscmd many times in "dble-1" and result is same
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect      | db      |
      | conn_1 | False   | select * from sharding_4_t1 | length{(4)} | schema1 |
      | conn_1 | True    | delete from sharding_4_t1   | success     | schema1 |
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace
  Scenario:mysql node hangs causing xa transaction fail to commit, close background attempts, execute 'kill @@session.xa' #3
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | schema1 |
      | conn_0 | False   | set autocommit=0                                        | schema1 |
      | conn_0 | False   | set xa=on                                               | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa prepare
    """
    Given stop mysql in host "mysql-master1"
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_A"
      | sql               |
      | show @@session.xa |
    Then execute admin cmd "kill @@xa_session" with "rs_A" result
    Then execute oscmd many times in "dble-1" and result is same
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Given start mysql in host "mysql-master1"
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect                     | db      |
      | conn_1 | false   | select * from sharding_4_t1            | length{(2)}                | schema1 |
      | conn_1 | false   | delete from sharding_4_t1 where id = 1 | success                    | schema1 |
      | conn_1 | false   | delete from sharding_4_t1 where id = 2 | Lock wait timeout exceeded | schema1 |
      | conn_1 | false   | delete from sharding_4_t1 where id = 3 | success                    | schema1 |
      | conn_1 | True    | delete from sharding_4_t1 where id = 4 | Lock wait timeout exceeded | schema1 |
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect      | db      |
      | conn_1 | false   | select * from sharding_4_t1 | length{(2)} | schema1 |
      | conn_1 | True    | delete from sharding_4_t1   | success     | schema1 |
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace
  Scenario: mysql node hangs causing xa transaction fail to commit, restart dble causing xa commit again #4
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | schema1 |
      | conn_0 | False   | set autocommit=0                                        | schema1 |
      | conn_0 | False   | set xa=on                                               | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa prepare
    """
    Given stop mysql in host "mysql-master1"
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then restart dble in "dble-1" failed for
    """
     Fail to recover xa when dble start, please check backend mysql
    """
    Given start mysql in host "mysql-master1"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect      | db      |
      | conn_1 | False   | select * from sharding_4_t1            | length{(4)} | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id = 1 | success     | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id = 2 | success     | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id = 3 | success     | schema1 |
      | conn_1 | True    | delete from sharding_4_t1 where id = 4 | success     | schema1 |
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace
  Scenario: mysql node hangs causing xa transaction perpare to fail and keep rolling back,but recovered during background attempts #5
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | schema1 |
      | conn_0 | False   | set autocommit=0                                        | schema1 |
      | conn_0 | False   | set xa=on                                               | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaPrepare/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    /beforeAddXaToQueue/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa end
    """
    Given stop mysql in host "mysql-master1"
    Given destroy sql threads list
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "5" times
    """
    before add xa
    """
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given execute oscmd in "dble-1" and "5" less than result
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Given start mysql in host "mysql-master1"
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect      | db      |
      | conn_1 | False   | select * from sharding_4_t1            | length{(0)} | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id = 1 | success     | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id = 2 | success     | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id = 3 | success     | schema1 |
      | conn_1 | True    | delete from sharding_4_t1 where id = 4 | success     | schema1 |
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"