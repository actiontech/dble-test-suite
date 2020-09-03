# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  backend_connections test

   Scenario:  backend_connections table #1
  #case desc backend_connections
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_connections_1"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | desc backend_connections | dble_information |
    Then check resultset "backend_connections_1" has lines with following column values
      | Field-0                   | Type-1        | Null-2 | Key-3 | Default-4 | Extra-5 |
      | backend_conn_id           | int(11)       | NO     | PRI   | None      |         |
      | db_group_name             | varchar(64)   | NO     |       | None      |         |
      | db_instance_name          | varchar(64)   | NO     |       | None      |         |
      | remote_addr               | varchar(16)   | NO     |       | None      |         |
      | remote_port               | int(11)       | NO     |       | None      |         |
      | remote_processlist_id     | int(11)       | NO     |       | None      |         |
      | local_port                | int(11)       | NO     |       | None      |         |
      | processor_id              | varchar(16)   | NO     |       | None      |         |
      | user                      | varchar(64)   | NO     |       | None      |         |
      | schema                    | varchar(16)   | NO     |       | None      |         |
      | session_conn_id           | int(11)       | NO     |       | None      |         |
      | sql                       | varchar(1024) | NO     |       | None      |         |
      | sql_execute_time          | int(11)       | NO     |       | None      |         |
      | mark_as_expired_timestamp | int(11)       | NO     |       | None      |         |
      | conn_net_in               | int(11)       | NO     |       | None      |         |
      | conn_net_out              | int(11)       | NO     |       | None      |         |
      | conn_estab_time           | int(11)       | NO     |       | None      |         |
      | borrowed_from_pool        | int(11)       | NO     |       | None      |         |
      | conn_recv_buffer          | int(11)       | NO     |       | None      |         |
      | conn_send_task_queue      | int(11)       | NO     |       | None      |         |
      | used_for_heartbeat        | varchar(5)    | NO     |       | None      |         |
      | conn_closing              | varchar(5)    | NO     |       | None      |         |
      | xa_status                 | varchar(64)   | NO     |       | None      |         |
      | in_transaction            | varchar(5)    | NO     |       | None      |         |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_connections_2"
#      | conn   | toClose | sql                       | db               |
#      | conn_0 | False   | select * from backend_connections | dble_information |
#    Then check resultset "backend_connections_2" has lines with following column values
#| db_group_name-1 | db_instance_name-2 | remote_addr-3 | remote_port-4   | processor_id-7    | user-8 | schema-9 | session_conn_id-10 | sql-11  | sql_execute_time-12 | mark_as_expired_timestamp-13 | borrowed_from_pool-17 | conn_recv_buffer-18 | conn_send_task_queue-19 | used_for_heartbeat-20 | conn_closing-21 | xa_status-22 | in_transaction-23 |
#| ha_group2       | hostM2             | 172.100.9.6   | 3306            | backendProcessor0 | test   | NULL     |            None    | None    |              470924 |                            0 |                  true |                4096 |                       0 | false                 | false           | 0            | false          |


