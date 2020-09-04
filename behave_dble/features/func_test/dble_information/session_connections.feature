# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  session_connections test
@skip_restart
   Scenario:  session_connections table #1
  #case desc session_connections
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_1"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | desc session_connections | dble_information |
    Then check resultset "session_connections_1" has lines with following column values
      | Field-0              | Type-1        | Null-2 | Key-3 | Default-4 | Extra-5 |
      | session_conn_id      | int(11)       | NO     | PRI   | None      |         |
      | remote_addr          | varchar(64)   | NO     |       | None      |         |
      | remote_port          | int(11)       | NO     |       | None      |         |
      | local_port           | int(11)       | NO     |       | None      |         |
      | processor_id         | varchar(64)   | NO     |       | None      |         |
      | user                 | varchar(64)   | NO     |       | None      |         |
      | tenant               | varchar(64)   | NO     |       | None      |         |
      | schema               | varchar(64)   | NO     |       | None      |         |
      | sql                  | varchar(1024) | NO     |       | None      |         |
      | sql_execute_time     | int(11)       | NO     |       | None      |         |
      | sql_start_timestamp  | int(11)       | NO     |       | None      |         |
      | sql_stage            | int(11)       | NO     |       | None      |         |
      | conn_net_in          | int(11)       | NO     |       | None      |         |
      | conn_net_out         | int(11)       | NO     |       | None      |         |
      | conn_estab_time      | int(11)       | NO     |       | None      |         |
      | conn_recv_buffer     | int(11)       | NO     |       | None      |         |
      | conn_send_task_queue | int(11)       | NO     |       | None      |         |
      | in_transaction       | int(11)       | NO     |       | None      |         |
      | entry_id             | int(11)       | NO     |       | None      |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_2"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | select * from session_connections | dble_information |
  #case http://10.186.18.11/jira/browse/DBLE0REQ-481
#    Then check resultset "session_connections_2" has lines with following column values
#      | remote_addr-1 | remote_port-2 | user-5 | tenant-6 | schema-7          | sql-8                             | sql_stage-11       | in_transaction-17  | entry_id-18 |
#      | 127.0.0.1     | 9066          | root   | None     | dble_information  | select * from session_connections | Manager connection | Manager connection | None        |

  #case check Field
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  | db      |
      | conn_1 | False   | drop table if exists test1  | success | schema1 |
      | conn_1 | False   | create table test1 (id int) | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_3"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from session_connections | dble_information |
    Then check resultset "session_connections_3" has lines with following column values
      | remote_addr-1 | remote_port-2 | user-5 | tenant-6 | schema-7 | sql-8                             | sql_stage-11       | in_transaction-17  | entry_id-18 |
      | 127.0.0.1     | 8066          | test   | NULL     | schema1  | create table test1 (id int)       | Finished           | false              | NULL        |
      | 127.0.0.1     | 9066          | root   | NULL     | NULL     | select * from session_connections | Manager connection | Manager connection | NULL        |
  #case change user.xml and reload
