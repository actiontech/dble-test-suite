# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26


Feature:  backend_connections test
@skip_restart
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


  # case 8066 set xa=on http://10.186.18.11/jira/browse/DBLE0REQ-508
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | use schema1                                      | success |
      | conn_1 | False   | drop table if exists test                        | success |
      | conn_1 | False   | create table test (id int)                       | success |
      | conn_1 | False   | drop table if exists sharding_2_t1               | success |
      | conn_1 | False   | create table sharding_2_t1 (id int)              | success |
      | conn_1 | False   | set autocommit=0                                 | success |
      | conn_1 | False   | set xa=on                                        | success |
      | conn_1 | False   | insert into test values (1),(2)                  | success |
      | conn_1 | False   | insert into sharding_2_t1 values (1),(2),(3),(4) | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_connections_2"
      | conn   | toClose | sql                                                                        | db               |
      | conn_0 | False   | select user,sql,schema,xa_status,in_transaction from backend_connections   | dble_information |
    Then check resultset "backend_connections_2" has lines with following column values
      | user-0 | sql-1                                         | schema-2 | xa_status-3 | in_transaction-4 |
      | test   | insert into test values (1),(2)               | db2      | 1           | true             |
      | test   | insert into test values (1),(2)               | db2      | 1           | true             |
      | test   | INSERT INTO sharding_2_t1 VALUES (1),  (3)    | db1      | 1           | true             |
      | test   | INSERT INTO sharding_2_t1 VALUES (2),  (4)    | db1      | 1           | true             |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql             | expect  |
      | conn_1 | False   | commit          | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_connections_3"
      | conn   | toClose | sql                                                                       | db               |
      | conn_0 | False   | select user,sql,schema,xa_status,in_transaction from backend_connections  | dble_information |
    Then check resultset "backend_connections_3" has not lines with following column values
      | user-0 | sql-1                                         | schema-2 | xa_status-3 | in_transaction-4 |
      | test   | insert into test values (1),(2)               | db2      | 1           | true             |
      | test   | insert into test values (1),(2)               | db2      | 1           | true             |
      | test   | INSERT INTO sharding_2_t1 VALUES (1),  (3)    | db1      | 1           | true             |
      | test   | INSERT INTO sharding_2_t1 VALUES (2),  (4)    | db1      | 1           | true             |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                | expect  |
      | conn_1 | False   | set autocommit=1   | success |
      | conn_1 | False   | set xa=off         | success |
  #case change db.xml and reload
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
      Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn3" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id" />
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
      Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" readWeight="1">
        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" readWeight="2">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_connections_4"
      | conn   | toClose | sql                                                                               | db               |
      | conn_0 | False   | select db_group_name,db_instance_name,remote_addr,schema from backend_connections | dble_information |
    Then check resultset "backend_connections_4" has lines with following column values
      | db_group_name-0 | db_instance_name-1 | remote_addr-2 |
      | ha_group1       | hostM1             | 172.100.9.5   |
      | ha_group1       | hostM1             | 172.100.9.5   |
      | ha_group1       | hostM1             | 172.100.9.5   |
      | ha_group1       | hostS1             | 172.100.9.2   |
    Then check resultset "backend_connections_4" has not lines with following column values
      | db_group_name-0 | db_instance_name-1 | remote_addr-2 |
      | ha_group2       | hostM2             | 172.100.9.6   |
      | ha_group2       | hostM2             | 172.100.9.6   |
      | ha_group2       | hostM2             | 172.100.9.6   |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | drop table if exists test                        | success |
      | conn_1 | true    | drop table if exists sharding_2_t1               | success |
   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                 | expect                                                  |
      | conn_0 | False   | select user,db_group_name from backend_connections order by schema desc limit 2     | has{(('test', 'ha_group1'), ('test', 'ha_group1'))}     |
      | conn_0 | False   | select user,db_group_name from backend_connections where schema like '%2%'          | has{(('test', 'ha_group1'),)}                           |
  #case select max/min
      | conn_0 | False   | select max(db_group_name) from backend_connections                      | has{(('ha_group1',),)}  |
      | conn_0 | False   | select min(db_group_name) from backend_connections                      | has{(('ha_group1',),)}  |
  #case update/delete
      | conn_0 | False   | delete from backend_connections where user='test'                         | Access denied for table 'backend_connections'     |
      | conn_0 | False   | update backend_connections set user = 'a' where user ='test'              | Access denied for table 'backend_connections'     |
      | conn_0 | true    | insert into backend_connections values (1,'1',1,1,1)                      | Access denied for table 'backend_connections'     |

    Scenario:  backend_variables table #2
  #case desc backend_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_variables_1"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | desc backend_variables | dble_information |
    Then check resultset "backend_variables_1" has lines with following column values
      | Field-0         | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | backend_conn_id | int(11)     | NO     |       | None      |         |
      | variable_name   | varchar(12) | NO     |       | None      |         |
      | variable_value  | varchar(12) | NO     |       | None      |         |
      | variable_type   | varchar(3)  | NO     |       | None      |         |
  #case select * from backend_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_variables_2"
      | conn   | toClose | sql                             | db               |
      | conn_0 | False   | select * from backend_variables | dble_information |
    Then check resultset "backend_variables_2" has lines with following column values
      | variable_name-1          | variable_value-2   | variable_type-3 |
      | autocommit               | true               | sys             |
      | character_set_client     | utf8mb4            | sys             |
      | collation_connection     | utf8mb4_general_ci | sys             |
      | character_set_results    | utf8mb4            | sys             |
      | character_set_connection | utf8mb4_general_ci | sys             |
      | transaction_isolation    | repeatable-read    | sys             |
    Given delete the following xml segment
      | file            | parent         | child                  |
      | db.xml          | {'tag':'root'} | {'tag':'dbGroup'}      |
      | sharding.xml    | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml    | {'tag':'root'} | {'tag':'shardingNode'} |

      Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="4" minCon="3" primary="true">
          <property name="connectionTimeout">1000</property>
        </dbInstance>
    </dbGroup>
    """
      Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id" />
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | expect          |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='true'                               | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='false'                              | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='repeatable-read'         | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='read-uncommitted'        | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='utf8mb4'                  | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='utf8mb4_general_ci'       | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='utf8mb4'                 | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='utf8mb4_general_ci'   | length{(4)}     |

   #case set sharding table to change autocommit and change transaction_isolation
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | use schema1                                      | success |
      | conn_1 | False   | drop table if exists sharding_2_t1               | success |
      | conn_1 | False   | create table sharding_2_t1 (id int)              | success |
      | conn_1 | False   | set autocommit=0                                 | success |
      | conn_1 | False   | set xa=on                                        | success |
      | conn_1 | False   | insert into sharding_2_t1 values (1),(2),(3),(4) | success |
 #case select
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_variables_3"
      | conn   | toClose | sql                                                                                                                                                                 | db               |
      | conn_0 | False   | select * from backend_variables where backend_conn_id in (select backend_conn_id from backend_connections where sql='INSERT INTO sharding_2_t1 VALUES (2),  (4)')   | dble_information |
    Then check resultset "backend_variables_3" has lines with following column values
      | variable_name-1          | variable_value-2   | variable_type-3 |
      | autocommit               | false              | sys             |
      | character_set_client     | latin1             | sys             |
      | collation_connection     | latin1_swedish_ci  | sys             |
      | character_set_results    | latin1             | sys             |
      | character_set_connection | latin1_swedish_ci  | sys             |
      | transaction_isolation    | repeatable-read    | sys             |

     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | expect          |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='true'                               | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='false'                              | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='repeatable-read'         | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='read-uncommitted'        | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='utf8mb4'                  | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='utf8mb4_general_ci'       | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='utf8mb4'                 | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='utf8mb4_general_ci'   | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='latin1'                   | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='latin1_swedish_ci'        | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='latin1'                  | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='latin1_swedish_ci'    | length{(2)}     |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                            | expect  |
      | conn_1 | False   | SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED       | success |
      | conn_1 | False   | insert into sharding_2_t1 values (5)                           | success |
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                | expect          |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='true'                         | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='false'                        | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='repeatable-read'   | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='read-uncommitted'  | length{(1)}     |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | commit                                           | success |
      | conn_1 | False   | set autocommit=1                                 | success |
      | conn_1 | False   | set xa=off                                       | success |
      | conn_1 | true    | drop table if exists sharding_2_t1               | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                | expect          |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='true'                         | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='false'                        | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='repeatable-read'   | length{(2)}     |
      | conn_0 | true    | select * from backend_variables where variable_name='transaction_isolation' and variable_value='read-uncommitted'  | length{(2)}     |
 #case set vertical table to change autocommit transaction_isolation character
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | use schema1                                      | success |
      | conn_1 | False   | drop table if exists test                        | success |
      | conn_1 | False   | create table test (id int)                       | success |
      | conn_1 | False   | set autocommit=0                                 | success |
      | conn_1 | False   | set xa=on                                        | success |
      | conn_1 | False   | insert into test values (1),(2),(3),(4)          | success |
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | expect          |
      | conn_0 | False   | use dble_information                                                                                                     | success         |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='true'                               | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='false'                              | length{(1)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='repeatable-read'         | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='read-uncommitted'        | length{(1)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='utf8mb4'                  | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='utf8mb4_general_ci'       | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='utf8mb4'                 | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='utf8mb4_general_ci'   | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='latin1'                   | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='latin1_swedish_ci'        | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='latin1'                  | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='latin1_swedish_ci'    | length{(2)}     |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | set names utf8mb4                                | success |
      | conn_1 | False   | insert into test values (1),(2),(3),(4)          | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | expect          |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='utf8mb4'                  | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='utf8mb4_general_ci'       | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='utf8mb4'                 | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='utf8mb4_general_ci'   | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='latin1'                   | length{(1)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='latin1_swedish_ci'        | length{(1)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='latin1'                  | length{(1)}     |
      | conn_0 | true    | select * from backend_variables where variable_name='character_set_connection' and variable_value='latin1_swedish_ci'    | length{(1)}     |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | commit                                           | success |
      | conn_1 | False   | set autocommit=1                                 | success |
      | conn_1 | False   | set xa=off                                       | success |
      | conn_1 | true    | drop table if exists test                        | success |
 #case change bootstrap.cnf to check
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DtxIsolation=2
    $a -Dautocommit=0
    $a -Dcharset=latin1
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | expect          |
      | conn_0 | False   | use dble_information                                                                                                     | success         |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='true'                               | length{(1)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='false'                              | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='repeatable-read'         | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='read-committed'          | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='utf8mb4'                  | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='utf8mb4_general_ci'       | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='utf8mb4'                 | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='utf8mb4_general_ci'   | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='latin1'                   | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='latin1_swedish_ci'        | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='latin1'                  | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='latin1_swedish_ci'    | length{(4)}     |

  #case update/delete
      | conn_0 | False   | delete from backend_variables where variable_name='autocommit'                         | Access denied for table 'backend_variables'     |
      | conn_0 | False   | update backend_variables set variable_name='' where variable_name='autocommit'         | Access denied for table 'backend_variables'     |
      | conn_0 | true    | insert into backend_variables values (1,'1','1','1')                                   | Access denied for table 'backend_variables'     |




