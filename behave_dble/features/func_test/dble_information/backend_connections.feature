# Copyright (C) 2016-2021 ActionTech.
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
      | state                     | varchar(36)   | NO     |       | None      |         |
      | conn_recv_buffer          | int(11)       | NO     |       | None      |         |
      | conn_send_task_queue      | int(11)       | NO     |       | None      |         |
      | used_for_heartbeat        | varchar(5)    | NO     |       | None      |         |
      | conn_closing              | varchar(5)    | NO     |       | None      |         |
      | xa_status                 | varchar(64)   | NO     |       | None      |         |
      | in_transaction            | varchar(5)    | NO     |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                  | expect       | db               |
      | conn_0 | False   | desc backend_connections             | length{(25)} | dble_information |
      | conn_0 | False   | select * from backend_connections    | success      | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  | db      |
      | conn_1 | False   | drop table if exists test                        | success | schema1 |
      | conn_1 | False   | create table test (id int)                       | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1               | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int)              | success | schema1 |
      | conn_1 | False   | begin                                            | success | schema1 |
   #case 1:one table use four conn
      | conn_1 | False   | insert into test values (1),(2)                  | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_connections_2"
      | conn   | toClose | sql                                                                                      | db               |
      | conn_0 | False   | select user,sql,db_group_name,schema,xa_status,in_transaction from backend_connections   | dble_information |
    Then check resultset "backend_connections_2" has lines with following column values
      | user-0 | sql-1                           | db_group_name-2 | schema-3 | xa_status-4 | in_transaction-5 |
      | test   | insert into test values (1),(2) | ha_group2       | db2      | 0           | true             |
      | test   | insert into test values (1),(2) | ha_group1       | db2      | 0           | true             |
      | test   | insert into test values (1),(2) | ha_group1       | db1      | 0           | true             |
      | test   | insert into test values (1),(2) | ha_group2       | db1      | 0           | true             |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  | db      |
     #case 2:one table use two conn
      | conn_1 | False   | insert into sharding_2_t1 values (1),(2),(3),(4) | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_connections_3"
      | conn   | toClose | sql                                                                                      | db               |
      | conn_0 | False   | select user,sql,db_group_name,schema,xa_status,in_transaction from backend_connections   | dble_information |
    Then check resultset "backend_connections_3" has lines with following column values
      | user-0 | sql-1                                      | db_group_name-2 | schema-3 | xa_status-4 | in_transaction-5 |
      | test   | INSERT INTO sharding_2_t1 VALUES (1),  (3) | ha_group2       | db1      | 0           | true             |
      | test   | INSERT INTO sharding_2_t1 VALUES (2),  (4) | ha_group1       | db1      | 0           | true             |
  # case 8066 query xa =on DBLE0REQ-508
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  | db      |
      | conn_1 | False   | commit                                           | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_4_t1               | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1 (id int)              | success | schema1 |
      | conn_1 | False   | set autocommit=0                                 | success | schema1 |
      | conn_1 | False   | set xa=on                                        | success | schema1 |
      | conn_1 | False   | insert into test values (1),(2)                  | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1),(2),(3),(4) | success | schema1 |
    #case 3 :two table use four conn,the "sql" will be show lasted sql
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_connections_4"
      | conn   | toClose | sql                                                                                      | db               |
      | conn_0 | False   | select user,sql,db_group_name,schema,xa_status,in_transaction from backend_connections   | dble_information |
    Then check resultset "backend_connections_4" has lines with following column values
      | user-0 | sql-1                                      | db_group_name-2 | schema-3 | xa_status-4 | in_transaction-5 |
      | test   | insert into test values (1),(2)            | ha_group2       | db2      | 1           | true             |
      | test   | insert into test values (1),(2)            | ha_group1       | db2      | 1           | true             |
      | test   | INSERT INTO sharding_2_t1 VALUES (1),  (3) | ha_group2       | db1      | 1           | true             |
      | test   | INSERT INTO sharding_2_t1 VALUES (2),  (4) | ha_group1       | db1      | 1           | true             |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  | db      |
      | conn_1 | False   | insert into sharding_4_t1 values (1),(2),(3),(4) | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_connections_5"
      | conn   | toClose | sql                                                                                      | db               |
      | conn_0 | False   | select user,sql,db_group_name,schema,xa_status,in_transaction from backend_connections   | dble_information |
    Then check resultset "backend_connections_5" has lines with following column values
      | user-0 | sql-1                                      | db_group_name-2 | schema-3 | xa_status-4 | in_transaction-5 |
      | test   | INSERT INTO sharding_4_t1 VALUES (3)       | ha_group2       | db2      | 1           | true             |
      | test   | INSERT INTO sharding_4_t1 VALUES (2)       | ha_group1       | db2      | 1           | true             |
      | test   | INSERT INTO sharding_4_t1 VALUES (1)       | ha_group2       | db1      | 1           | true             |
      | test   | INSERT INTO sharding_4_t1 VALUES (4)       | ha_group1       | db1      | 1           | true             |
    Then check resultset "backend_connections_5" has not lines with following column values
      | user-0 | sql-1                                      | db_group_name-2 | schema-3 | xa_status-4 | in_transaction-5 |
      | test   | insert into test values (1),(2)            | ha_group2       | db2      | 1           | true             |
      | test   | insert into test values (1),(2)            | ha_group1       | db2      | 1           | true             |
      | test   | INSERT INTO sharding_2_t1 VALUES (1),  (3) | ha_group2       | db1      | 1           | true             |
      | test   | INSERT INTO sharding_2_t1 VALUES (2),  (4) | ha_group1       | db1      | 1           | true             |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql             | expect  |
      | conn_1 | False   | commit          | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_connections_6"
      | conn   | toClose | sql                                                                                      | db               |
      | conn_0 | true    | select user,sql,db_group_name,schema,xa_status,in_transaction from backend_connections   | dble_information |
    Then check resultset "backend_connections_6" has not lines with following column values
      | user-0 | sql-1                                      | db_group_name-2 | schema-3 | xa_status-4 | in_transaction-5 |
      | test   | INSERT INTO sharding_4_t1 VALUES (3)       | ha_group2       | db2      | 1           | true             |
      | test   | INSERT INTO sharding_4_t1 VALUES (2)       | ha_group1       | db2      | 1           | true             |
      | test   | INSERT INTO sharding_4_t1 VALUES (1)       | ha_group2       | db1      | 1           | true             |
      | test   | INSERT INTO sharding_4_t1 VALUES (4)       | ha_group1       | db1      | 1           | true             |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                | expect  | db      |
      | conn_1 | False   | set autocommit=1   | success | schema1 |
      | conn_1 | False   | set xa=off         | success | schema1 |
      | conn_1 | False   | drop table if exists test                        | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_4_t1               | success | schema1 |
      | conn_1 | True    | drop table if exists sharding_2_t1               | success | schema1 |


  #case change db.xml and reload
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
      Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn2" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn2,dn4" function="hash-two" shardingColumn="id" />
    </schema>

    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    """
      Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" readWeight="1"/>
        <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" readWeight="2"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_connections_4"
      | conn   | toClose | sql                                                                               | db               |
      | conn_0 | False   | select db_group_name,db_instance_name,remote_addr,schema from backend_connections | dble_information |
    Then check resultset "backend_connections_4" has lines with following column values
      | db_group_name-0 | db_instance_name-1 | remote_addr-2 |
      | ha_group2       | hostM2             | 172.100.9.6   |
      | ha_group2       | hostS1             | 172.100.9.2   |
    Then check resultset "backend_connections_4" has not lines with following column values
      | db_group_name-0 | db_instance_name-1 | remote_addr-2 |
      | ha_group1       | hostM1             | 172.100.9.5   |

   #case supported select limit/order by
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                 | expect                                                  |
      | conn_0 | False   | select user,db_group_name from backend_connections order by schema desc limit 2     | has{(('test', 'ha_group2'), ('test', 'ha_group2'))}     |
  #case supported select max/min
      | conn_0 | False   | select max(db_group_name) from backend_connections                      | has{(('ha_group2',),)}  |
      | conn_0 | False   | select min(db_group_name) from backend_connections                      | has{(('ha_group2',),)}  |
  #case unsupported update/delete/insert
      | conn_0 | False   | delete from backend_connections where user='test'                         | Access denied for table 'backend_connections'     |
      | conn_0 | False   | update backend_connections set user = 'a' where user ='test'              | Access denied for table 'backend_connections'     |
      | conn_0 | True    | insert into backend_connections values (1,'1',1,1,1)                      | Access denied for table 'backend_connections'     |
