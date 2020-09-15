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
#      | sql_stage            | int(11)       | NO     |       | None      |         |
      | conn_net_in          | int(11)       | NO     |       | None      |         |
      | conn_net_out         | int(11)       | NO     |       | None      |         |
      | conn_estab_time      | int(11)       | NO     |       | None      |         |
      | conn_recv_buffer     | int(11)       | NO     |       | None      |         |
      | conn_send_task_queue | int(11)       | NO     |       | None      |         |
#      | in_transaction       | int(11)       | NO     |       | None      |         |
      | entry_id             | int(11)       | NO     |       | None      |         |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_2"
#      | conn   | toClose | sql                               | db               |
#      | conn_0 | False   | select * from session_connections | dble_information |
  #case http://10.186.18.11/jira/browse/DBLE0REQ-481
#    Then check resultset "session_connections_2" has lines with following column values
#      | remote_addr-1 | remote_port-2 | user-5 | tenant-6 | schema-7          | sql-8                             | sql_stage-11       | in_transaction-17  | entry_id-18 |
#      | 127.0.0.1     | 9066          | root   | None     | dble_information  | select * from session_connections | Manager connection | Manager connection |         |

  #case change user.xml and reload success,check remote_addr,remote_port,user,tenant,schema,sql,sql_stage,entry_id
    Given delete the following xml segment
      | file         | parent         | child                  |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |
      Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
	   <managerUser name="root" password="111111"/>
	   <shardingUser name="test" password="111111" schemas="schema1"/>
       <shardingUser name="test1" password="111111" schemas="schema2" tenant="tenant1"/>
       <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_group1" maxCon="20"/>
    """
      Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
       <schema shardingNode="dn1" name="schema2" sqlMaxLimit="1000" />
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | user          | passwd | conn   | toClose | sql         | expect   |
      | test1:tenant1 | 111111 | conn_2 | False   | use schema2 | success  |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_3"
#      | conn   | toClose | sql                                                                                               | db               |
#      | conn_0 | False   | select remote_addr,remote_port,user,tenant,schema,sql,sql_stage,entry_id from session_connections | dble_information |
#    Then check resultset "session_connections_3" has lines with following column values
#| remote_addr-0 | remote_port-1 | user-3 | tenant-4  | schema-5  | sql-6                                                                                          | sql_stage-7               | entry_id-8 |
#| 127.0.0.1   | 9066        | root  | NULL    | NULL    | select remote_addr,remote_port,user,tenant,schema,sql,sql_stage,entry_id from session_connections       | Manager connection        |      |
#| 127.0.0.1   | 8066        | test1 | tenant1 | schema2 | show tables                                                                                             | First_Node_Fetched_Result |      |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  | db     |
      | conn_1 | False   | drop table if exists test1  | success | schema1|
      | conn_1 | False   | create table test1 (id int) | success | schema1|
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_4"
#      | conn   | toClose | sql                               | db               |
#      | conn_0 | False   | select * from session_connections | dble_information |
#    Then check resultset "session_connections_4" has lines with following column values
#      | remote_addr-1 | remote_port-2 | user-5 | tenant-6 | schema-7 | sql-8                             | sql_stage-11       | in_transaction-17  | entry_id-18 |
#      | 127.0.0.1     | 8066          | test   | NULL     | schema1  | create table test1 (id int)       | Finished           | false              |         |
#      | 127.0.0.1     | 9066          | root   | NULL     |          | select * from session_connections | Manager connection | Manager connection |         |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  |
      | conn_1 | False   | use schema1                            | success |
      | conn_1 | False   | drop table if exists sharding_2_t1     | success |
      | conn_1 | False   | create table sharding_2_t1 (id int)    | success |
      | conn_1 | False   | set autocommit=0                       | success |
      | conn_1 | False   | set xa=on                              | success |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_5"
#      | conn   | toClose | sql                               | db               |
#      | conn_0 | False   | select * from session_connections | dble_information |
#    Then check resultset "session_connections_5" has lines with following column values
#      | remote_addr-1 | remote_port-2 | user-5 | tenant-6 | schema-7 | sql-8           | sql_stage-11      | in_transaction-17  | entry_id-18 |
#      | 127.0.0.1     | 8066          | test   | NULL     | schema1  | set xa=on       | Parse_SQL         | true               |         |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | insert into sharding_2_t1 values (1),(2),(3),(4) | success |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_6"
#      | conn   | toClose | sql                               | db               |
#      | conn_0 | False   | select * from session_connections | dble_information |
#    Then check resultset "session_connections_6" has lines with following column values
#      | remote_addr-1 | remote_port-2 | user-5 | tenant-6 | schema-7 | sql-8                                                | sql_stage-11      | in_transaction-17  | entry_id-18 |
#      | 127.0.0.1     | 8066          | test   | NULL     | schema1  | insert into sharding_2_t1 values (1),(2),(3),(4)     |  Finished         | true               |         |
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                       | expect  |
#      | conn_1 | False   | commit                    | success |
#      | conn_1 | False   | set autocommit=1          | success |
#      | conn_1 | False   | set xa=off                | success |

#   #case select limit/order by/where like
#      Then execute sql in "dble-1" in "admin" mode
#      | conn   | toClose | sql                                                         | expect                                                                         |
#      | conn_0 | False   | use dble_information                                        | success                                                                        |
#
#      | conn_0 | False   | select * from dble_thread_pool order by limit 1                      | length{(1)}                                                     |
#      | conn_0 | False   | select * from dble_thread_pool where name like '%Business%' | has{(('BusinessExecutor', 1, 1, 0), ('backendBusinessExecutor', 8, 0, 0))}     |
#      | conn_0 | False   | select size from dble_thread_pool                           | has{((1,), (1,), (8,), (8,), (8,))}                                            |
#  #case select max/min from
#      | conn_0 | False   | select max(size) from dble_thread_pool                      | has{((8,),)}  |
#      | conn_0 | False   | select min(size) from dble_thread_pool                      | has{((1,),)}  |
#  #case where [sub-query]
##      | conn_0 | False   | select size from dble_thread_pool where name in (select name from dble_thread_pool where active_count>1) | has{(('BusinessExecutor', 1, 1, 0), ('backendBusinessExecutor', 8, 0, 0))}     |
#  #case select field from
##      | conn_0 | False   | select name from dble_thread_pool where active_count > 0                         | has{('BusinessExecutor'),('complexQueryExecutor'),('writeToBackendExecutor')}                                    |
#  #case update/delete
#      | conn_0 | False   | delete from dble_thread_pool where size=1                   | Access denied for table 'dble_thread_pool'                                                                                                        |
#      | conn_0 | False   | update dble_thread_pool set size=2 where name='Timer'       | Access denied for table 'dble_thread_pool'                                                                                                        |
#      | conn_0 | False   | insert into dble_thread_pool values ('a',1,2,3)             | update syntax error, not support insert with syntax :[LOW_PRIORITY \| DELAYED \| HIGH_PRIORITY] [IGNORE][ON DUPLICATE KEY UPDATE assignment_list] |


   Scenario:  session_variables table #2
  #case desc session_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_1"
      | conn   | toClose | sql              | db               |
      | conn_0 | False   | desc session_variables | dble_information |
    Then check resultset "session_variables_1" has lines with following column values
      | Field-0       | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_2"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | select * from session_variables | dble_information |
    Then check resultset "session_variables_2" has lines with following column values
