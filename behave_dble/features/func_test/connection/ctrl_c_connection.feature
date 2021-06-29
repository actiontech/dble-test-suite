# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2020/12/7
Feature: test ctrl c processlist_id

 @btrace
  Scenario: check ctrl c processlist_id #1
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1 | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int) | success | schema1 |
#      | conn_0 | False   | begin                              | success | schema1 |
    Given update file content "./assets/BtraceSessionStage.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /setBackendResponseTime/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceSessionStage.java" in "dble-1"
    Given sleep "5" seconds
#    Given prepare a thread execute sql "insert into sharding_4_t1(id) values(1),(2),(3),(4)" with "conn_0"
    Given send ctrl c signal with "conn_0" and prepare a thread execute sql "insert into sharding_4_t1(id) values(1),(2),(3),(4)"
    Then check btrace "BtraceSessionStage.java" output in "dble-1" with "1" times
    """
    end get into setPreExecuteEnd
    """
#    Given send ctrl c signal with "conn_0" and prepare a thread execute sql "insert into sharding_4_t1(id) values(1),(2),(3),(4)" and check btrace "BtraceSessionStage.java" output in "dble-1" with "1" times
#    """
#    end get into setPreExecuteEnd
#    """
    Given sleep "15" seconds
#    Then check sql thread output in "err"
#    """
#    Query was interrupted.
#    """
    Given stop btrace script "BtraceSessionStage.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                                      | db      |
      | conn_0 | False   | select * from sharding_4_t1 | Transaction error, need to rollback.Reason: | schema1 |
      | conn_0 | False   | rollback                    | success                                     | schema1 |
      | conn_0 | False   | select * from sharding_4_t1 | success                                     | schema1 |
