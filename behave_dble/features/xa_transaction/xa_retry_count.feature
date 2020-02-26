# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/3

#2.19.11.0#dble-7869
Feature: change xaRetryCount value and check result

  Scenario: Setting xaRetryCount to an illegal value, dble report warning #1
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="xaRetryCount">-1</property>
    """
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql    | expect                                                                          | db |
      | root | 111111 | conn_0 | True    | dryrun | hasStr{Property [ xaRetryCount ] '-1' in server.xml is illegal, use 0 replaced} |    |
    Given Restart dble in "dble-1" success
    Then check "dble.log" in "dble-1" has the warnings
      | TYPE-0 | LEVEL-1 | DETAIL-2                                                                |
      | Xml    | WARNING | Property [ xaRetryCount ] '-1' in server.xml is illegal, use 0 replaced |

  @btrace
  Scenario: Setting xaRetryCount to 3 , dble report 3 warnings, recovery node by manual, check data not lost #2
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="xaRetryCount">3</property>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | test | 111111 | conn_0 | False   | create table sharding_4_t1(id int,name char)            | success | schema1 |
      | test | 111111 | conn_0 | False   | set autocommit=0                                        | success | schema1 |
      | test | 111111 | conn_0 | False   | set xa=on                                               | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given change btrace "BtraceXaDelay.java" locate "./assets" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
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
    Given sleep "10" seconds
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Then check result "rs_A" value is "3"
    Given start mysql in host "mysql-master1"
    Given sleep "15" seconds
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                  | expect      | db      |
      | test | 111111 | conn_1 | False   | select * from sharding_4_t1          | length{(4)} | schema1 |
      | test | 111111 | conn_1 | False   | delete from sharding_4_t1 where id=1 | success     | schema1 |
      | test | 111111 | conn_1 | False   | delete from sharding_4_t1 where id=2 | success     | schema1 |
      | test | 111111 | conn_1 | False   | delete from sharding_4_t1 where id=3 | success     | schema1 |
      | test | 111111 | conn_1 | True    | delete from sharding_4_t1 where id=4 | success     | schema1 |
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace
  Scenario: recover mysql node in xaRetryCount and check data not lost #3
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_1 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | test | 111111 | conn_1 | False   | create table sharding_4_t1(id int,name char)            | success | schema1 |
      | test | 111111 | conn_1 | False   | set autocommit=0                                        | success | schema1 |
      | test | 111111 | conn_1 | False   | set xa=on                                               | success | schema1 |
      | test | 111111 | conn_1 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given change btrace "BtraceXaDelay.java" locate "./assets" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    /beforeAddXaToQueue/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_1"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa prepare
    """
    Given stop mysql in host "mysql-master1"
    Given destroy sql threads list
    Then check btrace "BtraceXaDelay.java" output in "dble-1"
    """
    before add xa
    """
    Given start mysql in host "mysql-master1"
    Given sleep "15" seconds
    Then get result of oscmd named "rs_B" in "dble-1"
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Then check result "rs_B" value less than "3"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                  | expect      | db      |
      | test | 111111 | conn_2 | False   | select * from sharding_4_t1          | length{(2)} | schema1 |
      | test | 111111 | conn_2 | False   | delete from sharding_4_t1 where id=1 | success     | schema1 |
      | test | 111111 | conn_2 | False   | delete from sharding_4_t1 where id=2 | success     | schema1 |
      | test | 111111 | conn_2 | False   | delete from sharding_4_t1 where id=3 | success     | schema1 |
      | test | 111111 | conn_2 | True    | delete from sharding_4_t1 where id=4 | success     | schema1 |
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"