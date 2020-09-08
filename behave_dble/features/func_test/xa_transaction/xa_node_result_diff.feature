# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/4

#2.20.04.0#dble-8178
  @skip #skip temporarily, and find the cause later in 2020.9.8
Feature: xa prepare/start is abnormal: some nodes prepare/start successfully and some nodes prepare/start failed.
  For xa prepared successfully nodes, need to rollback after dble restart
  For xa start failed nodes, dble need return a reasonable error message

  @btrace
  Scenario: xa prepare is abnormal: some nodes prepare successfully and some nodes prepare failed. After dble restart, the successful nodes need rollback. #1
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
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "2" times
    """
    before xa prepare
    """
    Given Restart dble in "dble-1" success
    Given destroy sql threads list
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect      | db      |
      | conn_1 | False   | select * from sharding_4_t1                             | length{(0)} | schema1 |
      | conn_1 | False   | begin                                                   | success     | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success     | schema1 |
      | conn_1 | True    | commit                                                  | success     | schema1 |
      | new    | True    | select * from sharding_4_t1                             | length{(4)} | schema1 |
      | new    | True    | delete from sharding_4_t1                               | success     | schema1 |
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace
  Scenario: xa start is abnormal: some nodes execute successfully and some nodes return errors. For the error nodes, dble need return a reasonable error message. #2
    Then execute sql in "mysql-master1"
      | sql                        | expect  |
      | set global general_log=off | success |
    Then execute sql in "mysql-master2"
      | sql                        | expect  |
      | set global general_log=off | success |
    Given execute oscmd in "mysql-master1"
    """
    rm -rf /tmp/general.log
    """
    Given execute oscmd in "mysql-master2"
    """
    rm -rf /tmp/general.log
    """
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                            |
      | conn_0 | False   | set global log_output=file                     |
      | conn_0 | False   | set global general_log_file='/tmp/general.log' |
      | conn_0 | False   | set global general_log=on                      |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                            |
      | conn_4 | False   | set global log_output=file                     |
      | conn_4 | False   | set global general_log_file='/tmp/general.log' |
      | conn_4 | False   | set global general_log=on                      |

    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaStart/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql         | expect  | db      |
      | conn_1 | False   | set xa = on | success | schema1 |
      | conn_1 | False   | begin       | success | schema1 |
    Given prepare a thread execute sql "insert into schema1.sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)" with "conn_1"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "1" times
    """
    before xa start
    """
    Given get resultset of oscmd in "dble-1" with pattern "Dble_Server.*db1" named "rs_A"
    """
    cat /opt/dble/BtraceXaDelay.java.log
    """
    Then execute sql "xa start" in "mysql-master1" with "rs_A" result
      | conn   | toClose | expect  |
      | conn_2 | False   | success |
    Then execute sql "xa start" in "mysql-master2" with "rs_A" result
      | conn   | toClose | expect  |
      | conn_3 | False   | success |
    Given destroy sql threads list
    Then check sql thread output in "err"
    """
    The XID already exists
    """
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect      | db      |
      | conn_1 | False   | rollback                    | success     | schema1 |
      | conn_1 | False   | select * from sharding_4_t1 | length{(0)} | schema1 |
    Given sleep "3" seconds
    Then get result of oscmd named "rs_B" in "mysql-master1"
    """
    grep -c -i 'rollback' /tmp/general.log
    """
    Then get result of oscmd named "rs_C" in "mysql-master1"
    """
    grep -c -i 'quit' /tmp/general.log
    """
    Then get result of oscmd named "rs_D" in "mysql-master2"
    """
    grep -c -i 'rollback' /tmp/general.log
    """
    Then get result of oscmd named "rs_E" in "mysql-master2"
    """
    grep -c -i 'quit' /tmp/general.log
    """
    Then check result "rs_B" value is "1"
    Then check result "rs_C" value is "1"
    Then check result "rs_D" value is "1"
    Then check result "rs_E" value is "1"
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                        | expect  |
      | conn_0 | True    | set global general_log=off | success |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                        | expect  |
      | conn_4 | True    | set global general_log=off | success |
    Given execute oscmd in "mysql-master1"
    """
    rm -rf /tmp/general.log
    """
    Given execute oscmd in "mysql-master2"
    """
    rm -rf /tmp/general.log
    """
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
