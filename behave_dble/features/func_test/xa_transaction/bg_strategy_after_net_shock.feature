# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/2

#2.20.04.0#dble-8175
@skip
Feature: retry policy after xa transaction commit failed for network anomaly

  @btrace
  Scenario: mysql node network shock causing xa transaction fail to commit, recovery network before the front end attempts to commit 5 times #1
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
    before xa prepare
    """
    Given execute oscmd in "mysql-master1"
    """
    iptables -A INPUT -s 172.100.9.1 -j REJECT
    """
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa commit
    """
    Given execute oscmd in "mysql-master1"
    """
    iptables -D INPUT -s 172.100.9.1 -j REJECT
    """
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect      | db      |
      | conn_1 | False   | select * from sharding_4_t1 | length{(4)} | schema1 |
      | conn_1 | True    | delete from sharding_4_t1   | success     | schema1 |
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace
  Scenario: mysql node network shock causing xa transaction fail to commit, automatic recovery in background attempts #2
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
    before xa prepare
    """
    Given execute oscmd in "mysql-master1"
    """
    iptables -A INPUT -s 172.100.9.1 -j REJECT
    """
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given sleep "10" seconds
    Given execute oscmd in "dble-1" and "5" less than result
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Given execute oscmd in "mysql-master1"
    """
    iptables -D INPUT -s 172.100.9.1 -j REJECT
    """
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
  Scenario:  mysql node network shock causing xa transaction fail to commit, close background attempts, execute 'kill @@session.xa' and 'xa commit'  #3
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
    before xa prepare
    """
    Given execute oscmd in "mysql-master1"
    """
    iptables -A INPUT -s 172.100.9.1 -j REJECT
    """
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
    Given execute oscmd in "mysql-master1"
    """
    iptables -D INPUT -s 172.100.9.1 -j REJECT
    """
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect                     | db      |
      | conn_1 | false   | select * from sharding_4_t1            | length{(2)}                | schema1 |
      | conn_1 | false   | delete from sharding_4_t1 where id = 1 | success                    | schema1 |
      | conn_1 | false   | delete from sharding_4_t1 where id = 2 | Lock wait timeout exceeded | schema1 |
      | conn_1 | false   | delete from sharding_4_t1 where id = 3 | success                    | schema1 |
      | conn_1 | True    | delete from sharding_4_t1 where id = 4 | Lock wait timeout exceeded | schema1 |
    Then restart dble in "dble-1" failed for
    """
    Fail to recover xa when dble start, please check backend mysql
    """
    Given restart mysql in "mysql-master1"
    Given execute single sql in "mysql-master1" and save resultset in "rs_A"
      | sql          |
      | xa recover   |
    Then execute cmd "xa commit" with "rs_A" in mysql "mysql-master1"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                         | expect      | db      |
      | test | 111111 | conn_1 | false   | select * from sharding_4_t1 | length{(2)} | schema1 |
      | test | 111111 | conn_1 | True    | delete from sharding_4_t1   | success     | schema1 |
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace
  Scenario: mysql node network shock causing xa transaction perpare to fail and keep rolling back,but recovered during background attempts #4
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
    /delayBeforeXaPrepare/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa end
    """
    Given execute oscmd in "mysql-master1"
    """
    iptables -A INPUT -s 172.100.9.1 -j REJECT
    """
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given execute oscmd in "mysql-master1"
    """
    iptables -D INPUT -s 172.100.9.1 -j REJECT
    """
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | sql                         | expect      | db      |
      | select * from sharding_4_t1 | length{(0)} | schema1 |
    Then restart dble in "dble-1" failed for
    """
    Fail to recover xa when dble start, please check backend mysql
    """
    Given restart mysql in "mysql-master1"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect  | db      |
      | drop table if exists sharding_4_t1 | success | schema1 |
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"