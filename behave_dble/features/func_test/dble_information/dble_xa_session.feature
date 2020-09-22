# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/9/2

Feature:  dble_xa_session test

  @skip
@skip_restart
@btrace @restore_mysql_service
   Scenario:  dble_xa_session  table #1
    """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
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
  #case set brace
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
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
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_1"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "1" times
    """
    before xa commit
    """
    Given stop mysql in host "mysql-master1"
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_xa_session_2"
      | conn   | toClose | sql                           | db               |
      | conn_2 | False   | select * from dble_xa_session | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_xa_session_3"
      | conn   | toClose | sql                           | db               |
      | conn_2 | False   | show @@session.xa             | dble_information |
    Then check resultset "dble_xa_session_2" has lines with following column values
      | xa_state-2           | sharding_node-3 |
      | XA COMMIT FAIL STAGE | dn1             |
      | XA COMMIT FAIL STAGE | dn1             |
    Then check resultset "dble_xa_session_3" has lines with following column values
      |  XA_STATE-2           | SHARDING_NODES-3 |
      |  XA COMMIT FAIL STAGE | dn3 dn1          |
    Then check resultsets "dble_xa_session_2" and "dble_xa_session_3" are same in following columns
      | column     | column_index |
      | front_id   | 0            |
      | xa_id      | 1            |
      | xa_state   | 2            |
    Given start mysql in host "mysql-master1"

  #case update/delete
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect                                        |
      | conn_0 | False   | delete from dble_xa_session where xa_state='XA COMMIT FAIL STAGE'                       | Access denied for table 'dble_xa_session'     |
      | conn_0 | False   | update dble_xa_session set xa_state = 'a' where xa_state='XA COMMIT FAIL STAGE'         | Access denied for table 'dble_xa_session'     |
      | conn_0 | False   | insert into dble_xa_session values (1,'1',1,1,1)                                        | Access denied for table 'dble_xa_session'     |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_1 | False   | set autocommit=1                                        | schema1 |
      | conn_1 | False   | set xa=off                                              | schema1 |
      | conn_1 | False   | drop table if exists sharding_4_t1                      | schema1 |
