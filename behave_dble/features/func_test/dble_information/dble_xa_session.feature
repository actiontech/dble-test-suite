# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/9/2

Feature:  dble_xa_session test
@skip_restart
  @btrace
   Scenario:  dble_xa_session  table #1
  #case desc dble_xa_session
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_xa_session_1"
      | conn   | toClose | sql                  | db               |
      | conn_0 | False   | desc dble_xa_session | dble_information |
    Then check resultset "dble_xa_session_1" has lines with following column values
      | Field-0       | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | front_id      | int(11)     | NO     | PRI   | None      |         |
      | xa_id         | varchar(20) | NO     |       | None      |         |
      | xa_state      | varchar(20) | NO     |       | None      |         |
      | sharding_node | varchar(64) | NO     | PRI   | None      |         |
  #case set autocommit=0 set xa=on
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DxaRetryCount=1
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                      | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name char)            | schema1 |
      | conn_1 | False   | set autocommit=0                                        | schema1 |
      | conn_1 | False   | set xa=on                                               | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(1000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_1"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "1" times
    """
    before xa commit
    """
    Given stop mysql in host "mysql-master1"
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
#    Given destroy sql threads list
    Given sleep "10" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_xa_session_2"
      | conn   | toClose | sql                           | db               |
      | conn_0 | False   | select * from dble_xa_session | dble_information |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_xa_session_3"
#      | sql               |
#      | show @@session.xa |




