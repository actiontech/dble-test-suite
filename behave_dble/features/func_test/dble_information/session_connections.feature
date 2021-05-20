# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  session_connections test


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
      | sql_stage            | varchar(64)   | NO     |       | None      |         |
      | conn_net_in          | int(11)       | NO     |       | None      |         |
      | conn_net_out         | int(11)       | NO     |       | None      |         |
      | conn_estab_time      | int(11)       | NO     |       | None      |         |
      | conn_recv_buffer     | int(11)       | NO     |       | None      |         |
      | conn_send_task_queue | int(11)       | NO     |       | None      |         |
      | conn_recv_task_queue | int(11)       | NO     |       | None      |         |
      | in_transaction       | varchar(5)    | NO     |       | None      |         |
      | entry_id             | int(11)       | NO     |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                  | expect         | db               |
      | conn_0 | False   | desc session_connections             | length{(20)}   | dble_information |
      | conn_0 | False   | select * from session_connections    | length{(1)}    | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_2"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from session_connections | dble_information |
    Then check resultset "session_connections_2" has lines with following column values
      | remote_port-2 | user-5 | tenant-6 | schema-7         | sql-8                             | sql_stage-11       | in_transaction-18  | entry_id-19 |
      | 9066          | root   | NULL     | dble_information | select * from session_connections | Manager connection | Manager connection | 1           |
  #case change user.xml and reload success,check remote_addr,remote_port,user,tenant,schema,sql,sql_stage,entry_id
    Given delete the following xml segment
      | file         | parent         | child                  |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
	   <managerUser name="root" password="111111"/>
	   <shardingUser name="test" password="111111" schemas="schema1"/>
       <shardingUser name="test1" password="111111" schemas="schema2" tenant="tenant1"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
       <schema shardingNode="dn1" name="schema2" sqlMaxLimit="1000" />
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | user          | passwd | conn   | toClose | sql         | expect   |
      | test1:tenant1 | 111111 | conn_2 | False   | use schema2 | success  |
      | test1:tenant1 | 111111 | conn_2 | False   | show tables | success  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_3"
      | conn   | toClose | sql                                                                                               | db               |
      | conn_0 | False   | select remote_port,user,tenant,schema,sql,sql_stage,entry_id from session_connections             | dble_information |
    Then check resultset "session_connections_3" has lines with following column values
      | remote_port-0 | user-1 | tenant-2 | schema-3         | sql-4                                                                                 | sql_stage-5        | entry_id-6 |
      | 9066          | root   | NULL     | dble_information | select remote_port,user,tenant,schema,sql,sql_stage,entry_id from session_connections | Manager connection | 1          |
      | 8066          | test1  | tenant1  | schema2          | show tables                                                                           | Finished           | 3          |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  | db     |
      | conn_1 | False   | drop table if exists test1  | success | schema1|
      | conn_1 | False   | create table test1 (id int) | success | schema1|
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_4"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from session_connections | dble_information |
    Then check resultset "session_connections_4" has lines with following column values
      | remote_port-2 | user-5 | tenant-6 | schema-7         | sql-8                             | sql_stage-11       | in_transaction-18  | entry_id-19 |
      | 8066          | test   | NULL     | schema1          | create table test1 (id int)       | Finished           | false              | 2           |
      | 9066          | root   | NULL     | dble_information | select * from session_connections | Manager connection | Manager connection | 1           |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  |
      | conn_1 | False   | drop table if exists test1             | success |
      | conn_1 | False   | drop table if exists sharding_2_t1     | success |
      | conn_1 | False   | create table sharding_2_t1 (id int)    | success |
      | conn_1 | False   | set autocommit=0                       | success |
      | conn_1 | False   | set xa=on                              | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_5"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from session_connections | dble_information |
#case DBLE0REQ-774
    Then check resultset "session_connections_5" has lines with following column values
      | remote_port-2 | user-5 | tenant-6 | schema-7 | sql-8     | sql_stage-11 | in_transaction-18 | entry_id-19 |
      | 8066          | test   | NULL     | schema1  | set xa=on | Finished     | true              | 2           |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | insert into sharding_2_t1 values (1),(2),(3),(4) | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_6"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from session_connections | dble_information |
    Then check resultset "session_connections_6" has lines with following column values
      | remote_port-2 | user-5 | tenant-6 | schema-7 | sql-8                                            | sql_stage-11 | in_transaction-18 | entry_id-19 |
      | 8066          | test   | NULL     | schema1  | insert into sharding_2_t1 values (1),(2),(3),(4) | Finished     | true              | 2           |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  |
      | conn_1 | False   | commit                                 | success |
      | conn_1 | False   | set autocommit=1                       | success |
      | conn_1 | False   | set xa=off                             | success |
      | conn_1 | True    | drop table if exists sharding_2_t1     | success |
  #case unsupported update/delete/insert
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                   | expect                                                                                                        |
      | conn_0 | False   | delete from session_connections where remote_port=8066                | Access denied for table 'session_connections'       |
      | conn_0 | False   | update session_connections set entry_id=2 where entry_id=1            | Access denied for table 'session_connections'       |
      | conn_0 | True    | insert into session_connections values ('a',1,2,3)                    | Access denied for table 'session_connections'       |
