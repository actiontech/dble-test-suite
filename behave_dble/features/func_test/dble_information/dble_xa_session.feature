# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/9/2

Feature:  dble_xa_session test
@skip_restart
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
      | sharding_node | varchar(64) | NO     |       | None      |         |
  #case set autocommit=0 set xa=on
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                      | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name char)            | schema1 |
      | conn_1 | False   | set autocommit=0                                        | schema1 |
      | conn_1 | False   | set xa=on                                               | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | schema1 |




