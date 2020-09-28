# Copyright (C) 2016-2020 ActionTech.
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
      | in_transaction       | varchar(5)    | NO     |       | None      |         |
      | entry_id             | int(11)       | NO     |       | None      |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_2"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from session_connections | dble_information |
  #case http://10.186.18.11/jira/browse/DBLE0REQ-481
    Then check resultset "session_connections_2" has lines with following column values
      | remote_port-2 | user-5 | tenant-6 | schema-7         | sql-8                             | sql_stage-11       | in_transaction-17  | entry_id-18 |
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
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_3"
      | conn   | toClose | sql                                                                                               | db               |
      | conn_0 | False   | select remote_port,user,tenant,schema,sql,sql_stage,entry_id from session_connections | dble_information |
    Then check resultset "session_connections_3" has lines with following column values
      | remote_port-0 | user-1 | tenant-2 | schema-3         | sql-4                                                                                 | sql_stage-5        | entry_id-6 |
      | 9066          | root   | NULL     | dble_information | select remote_port,user,tenant,schema,sql,sql_stage,entry_id from session_connections | Manager connection | 1          |
      | 8066          | test1  | tenant1  | schema2          | use schema2                                                                           | Parse_SQL          | 3          |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  | db     |
      | conn_1 | False   | drop table if exists test1  | success | schema1|
      | conn_1 | False   | create table test1 (id int) | success | schema1|
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_4"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from session_connections | dble_information |
    Then check resultset "session_connections_4" has lines with following column values
      | remote_port-2 | user-5 | tenant-6 | schema-7         | sql-8                             | sql_stage-11       | in_transaction-17  | entry_id-18 |
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
    Then check resultset "session_connections_5" has lines with following column values
      | remote_port-2 | user-5 | tenant-6 | schema-7 | sql-8     | sql_stage-11 | in_transaction-17 | entry_id-18 |
      | 8066          | test   | NULL     | schema1  | set xa=on | Parse_SQL    | true              | 2           |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | insert into sharding_2_t1 values (1),(2),(3),(4) | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_6"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from session_connections | dble_information |
    Then check resultset "session_connections_6" has lines with following column values
      | remote_port-2 | user-5 | tenant-6 | schema-7 | sql-8                                            | sql_stage-11 | in_transaction-17 | entry_id-18 |
      | 8066          | test   | NULL     | schema1  | insert into sharding_2_t1 values (1),(2),(3),(4) | Finished     | true              | 2           |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  |
      | conn_1 | False   | commit                                 | success |
      | conn_1 | False   | set autocommit=1                       | success |
      | conn_1 | False   | set xa=off                             | success |
      | conn_1 | False   | drop table if exists sharding_2_t1     | success |
  #case update/delete
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                   | expect                                                                                                        |
      | conn_0 | False   | delete from session_connections where remote_port=8066                | Access denied for table 'session_connections'       |
      | conn_0 | False   | update session_connections set entry_id=2 where entry_id=1            | Access denied for table 'session_connections'       |
      | conn_0 | False   | insert into session_connections values ('a',1,2,3)                    | Access denied for table 'session_connections'       |


  @skip_restart
   Scenario:  session_variables table #2
  #case desc session_variables
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_1"
#      | conn   | toClose | sql              | db               |
#      | conn_0 | False   | desc session_variables | dble_information |
#    Then check resultset "session_variables_1" has lines with following column values
#      | Field-0         | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
#      | session_conn_id | int(11)     | NO     |       | None      |         |
#      | variable_name   | varchar(12) | NO     |       | None      |         |
#      | variable_value  | varchar(12) | NO     |       | None      |         |
#      | variable_type   | varchar(3)  | NO     |       | None      |         |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_2"
#      | conn   | toClose | sql                             | db               |
#      | conn_0 | False   | select * from session_variables | dble_information |
#    Then check resultset "session_variables_2" has lines with following column values
#      | variable_name-1          | variable_value-2  | variable_type-3 |
##      | autocommit               | true              | sys             |
#      | character_set_client     | latin1            | sys             |
#      | collation_connection     | latin1_swedish_ci | sys             |
#      | character_set_results    | latin1            | sys             |
#      | character_set_connection | latin1_swedish_ci | sys             |
#      | transaction_isolation    | repeatable-read   | sys             |
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                    | expect  |
#      | conn_1 | False   | use schema1                            | success |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_3"
#      | conn   | toClose | sql                             | db               |
#      | conn_0 | False   | select * from session_variables | dble_information |
#    Then check resultset "session_variables_3" has lines with following column values
#      | variable_name-1          | variable_value-2  | variable_type-3 |
##      | autocommit               | true              | sys             |
#      | character_set_client     | latin1            | sys             |
#      | collation_connection     | latin1_swedish_ci | sys             |
#      | character_set_results    | latin1            | sys             |
#      | character_set_connection | latin1_swedish_ci | sys             |
#      | transaction_isolation    | repeatable-read   | sys             |
#      | autocommit               | true              | sys             |
#      | character_set_client     | latin1            | sys             |
#      | collation_connection     | latin1_swedish_ci | sys             |
#      | character_set_results    | latin1            | sys             |
#      | character_set_connection | latin1_swedish_ci | sys             |
#      | transaction_isolation    | repeatable-read   | sys             |
#      | xa                       | false             | sys             |
#      | trace                    | false             | sys             |
#      | transaction_read_only    | false             | sys             |
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                    | expect  |
#      | conn_1 | False   | set autocommit=0                       | success |
#      | conn_1 | False   | set xa=on                              | success |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_4"
#      | conn   | toClose | sql                             | db               |
#      | conn_0 | true    | select * from session_variables | dble_information |
#    Then check resultset "session_variables_4" has lines with following column values
#      | variable_name-1          | variable_value-2  | variable_type-3 |
#      | autocommit               | false             | sys             |
#      | character_set_client     | latin1            | sys             |
#      | collation_connection     | latin1_swedish_ci | sys             |
#      | character_set_results    | latin1            | sys             |
#      | character_set_connection | latin1_swedish_ci | sys             |
#      | transaction_isolation    | repeatable-read   | sys             |
#      | autocommit               | false             | sys             |
#      | character_set_client     | latin1            | sys             |
#      | collation_connection     | latin1_swedish_ci | sys             |
#      | character_set_results    | latin1            | sys             |
#      | character_set_connection | latin1_swedish_ci | sys             |
#      | transaction_isolation    | repeatable-read   | sys             |
#      | xa                       | true              | sys             |
#      | trace                    | false             | sys             |
#      | transaction_read_only    | false             | sys             |
#      | tx_read_only             | false             | sys             |
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                    | expect  |
#      | conn_1 | False   | set autocommit=1                       | success |
#      | conn_1 | true    | set xa=off                             | success |

    #case change transaction_isolation http://10.186.18.11/jira/browse/DBLE0REQ-562
#    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
#    """
#    $a -DtxIsolation=2
#    $a -Dautocommit=0
#    """
#    Given Restart dble in "dble-1" success
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                    | expect  |
#      | conn_1 | False   | use schema1                            | success |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_5"
#      | conn   | toClose | sql                                                                                                        | db               |
#      | conn_0 | False   | select * from session_variables where variable_name='transaction_isolation' or variable_name='autocommit'  | dble_information |
#    Then check resultset "session_variables_5" has lines with following column values
#      | variable_name-1          | variable_value-2  | variable_type-3 |
#|  autocommit            | false           | sys           |
#|          transaction_isolation | read-committed | sys           |
#|             autocommit            | false           | sys           |
#|          transaction_isolation | read-committed  | sys           |


#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                                                             | expect  |
#      | conn_1 | False   | SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED                        | success |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_6"
#      | conn   | toClose | sql                                                                         | db               |
#      | conn_0 | False   | select * from session_variables where variable_name='transaction_isolation' | dble_information |
#    Then check resultset "session_variables_6" has lines with following column values
#      | variable_name-1          | variable_value-2  | variable_type-3 |

#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                                                             | expect  |
#      | conn_1 | False   | set @@session.tx_isolation ='read-committed'                        | success |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_7"
#      | conn   | toClose | sql                                                                         | db               |
#      | conn_0 | False   | select * from session_variables where variable_name='transaction_isolation' | dble_information |
#    Then check resultset "session_variables_7" has lines with following column values
#      | variable_name-1          | variable_value-2  | variable_type-3 |



  #case  SET @@tx_read_only=  or set @@session.transaction_read_only=
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect  |
      | conn_1 | False   | set @@session.transaction_read_only=1 | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect  |
      | conn_2 | False   | use schema1                           | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_8"
      | conn   | toClose | sql                                                                                                         | db               |
      | conn_0 | False   | select * from session_variables where variable_name='transaction_read_only' or variable_name='tx_read_only' | dble_information |
    Then check resultset "session_variables_8" has lines with following column values
      | variable_name-1       | variable_value-2 | variable_type-3 |
      | transaction_read_only | true             | sys             |
      | tx_read_only          | true             | sys             |
      | transaction_read_only | false            | sys             |
      | tx_read_only          | false            | sys             |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                  | expect  |
      | conn_1 | False   | SET @@tx_read_only=0 | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_9"
      | conn   | toClose | sql                                                                                                         | db               |
      | conn_0 | False   | select * from session_variables where variable_name='transaction_read_only' or variable_name='tx_read_only' | dble_information |
    Then check resultset "session_variables_9" has lines with following column values
      | variable_name-1       | variable_value-2 | variable_type-3 |
      | transaction_read_only | false            | sys             |
      | tx_read_only          | false            | sys             |
      | transaction_read_only | false            | sys             |
      | tx_read_only          | false            | sys             |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                    |
      | conn_1 | False   | SET @@global.tx_read_only=1 | unsupport global          |

  #case  set @@character_set_results='utf8mb4'
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  |
      | conn_1 | False   | set @@character_set_results='utf8mb4'  | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect  |
      | conn_2 | False   | set @@collation_connection='utf8_unicode_ci'   | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_10"
      | conn   | toClose | sql                                                                                                                 | db               |
      | conn_0 | False   | select * from session_variables where variable_name='character_set_results' or variable_name='collation_connection' | dble_information |
    Then check resultset "session_variables_10" has lines with following column values
      | variable_name-1       | variable_value-2  | variable_type-3 |
      | collation_connection  | latin1_swedish_ci | sys             |
      | character_set_results | latin1            | sys             |
      | collation_connection  | latin1_swedish_ci | sys             |
      | character_set_results | utf8mb4           | sys             |
      | collation_connection  | utf8_unicode_ci   | sys             |
      | character_set_results | latin1            | sys             |
  #case  set @a=1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql         | expect  |
      | conn_1 | False   | set @a=1    | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql         | expect  |
      | conn_2 | False   | set @a=2    | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_10"
      | conn   | toClose | sql                                                                                                                 | db               |
      | conn_0 | False   | select * from session_variables where variable_name='character_set_results' or variable_name='collation_connection' | dble_information |
    Then check resultset "session_variables_10" has lines with following column values
      | variable_name-1       | variable_value-2  | variable_type-3 |
      | @A                    | 1                 | user            |
      | @A                    | 2                 | user            |


#    #case update/delete
#      Then execute sql in "dble-1" in "admin" mode
#      | conn   | toClose | sql                                                                    | expect                                            |
#      | conn_0 | False   | delete from session_variables where variable_type='sys'                | Access denied for table 'session_variables'       |
#      | conn_0 | False   | update session_variables set sys='user' where variable_type='sys'      | Access denied for table 'session_variables'       |
#      | conn_0 | True    | insert into session_variables values ('a',1,2,3)                       | Access denied for table 'session_variables'       |