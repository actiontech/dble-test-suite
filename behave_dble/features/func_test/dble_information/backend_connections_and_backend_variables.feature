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
      | borrowed_from_pool        | varchar(5)    | NO     |       | None      |         |
      | conn_recv_buffer          | int(11)       | NO     |       | None      |         |
      | conn_send_task_queue      | int(11)       | NO     |       | None      |         |
      | used_for_heartbeat        | varchar(5)    | NO     |       | None      |         |
      | conn_closing              | varchar(5)    | NO     |       | None      |         |
      | xa_status                 | varchar(64)   | NO     |       | None      |         |
      | in_transaction            | varchar(5)    | NO     |       | None      |         |

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
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql             | expect  |
      | conn_1 | False   | use schema1     | success |
      | conn_1 | False   | commit          | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_connections_3"
      | conn   | toClose | sql                                                                       | db               |
      | conn_0 | False   | select user,sql,schema,xa_status,in_transaction from backend_connections  | dble_information |
    Then check resultset "backend_connections_3" has not lines with following column values
      | user-0 | sql-1                                          | schema-2 | xa_status-3 | in_transaction-4 |
      | test   | insert into test values (1),(2)                | db2      | 1           | true             |
      | test   | insert into test values (1),(2)                | db2      | 1           | true             |
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
      | conn_1 | False   | drop table if exists sharding_2_t1               | success |
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
      | conn_0 | False   | insert into backend_connections values (1,'1',1,1,1)                      | Access denied for table 'backend_connections'     |

@skip_restart
   Scenario:  backend_variables table #2
  #case desc backend_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_variables_1"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | desc backend_variables   | dble_information |
    Then check resultset "backend_variables_1" has lines with following column values
      | Field-0         | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | backend_conn_id | int(11)     | NO     |       | None      |         |
      | variable_name   | varchar(12) | NO     |       | None      |         |
      | variable_value  | varchar(12) | NO     |       | None      |         |
      | variable_type   | varchar(3)  | NO     |       | None      |         |
  #case select * from backend_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_variables_2"
      | conn   | toClose | sql                             | db               |
      | conn_0 | true    | select * from backend_variables | dble_information |
    Then check resultset "backend_variables_2" has lines with following column values
      | variable_name-1          | variable_value-2   | variable_type-3 |
      | autocommit               | true               | sys             |
      | character_set_client     | utf8mb4            | sys             |
      | collation_connection     | utf8mb4_general_ci | sys             |
      | character_set_results    | utf8mb4            | sys             |
      | character_set_connection | utf8mb4_general_ci | sys             |
      | transaction_isolation    | repeatable-read    | sys             |
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DtxIsolation=2
    $a -Dautocommit=0
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  |
      | conn_1 | False   | use schema1                            | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_variables_3"
      | conn   | toClose | sql                                                                                                        | db               |
      | conn_0 | true    | select * from backend_variables where variable_name='autocommit' or variable_name='transaction_isolation'  | dble_information |
      Then check resultset "backend_variables_3" has lines with following column values
      | variable_name-1       | variable_value-2 | variable_type-3 |
      | autocommit            | false            | sys             |
      | transaction_isolation | read-committed   | sys             |





