# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26


Feature:  backend_variables test

   Scenario:  backend_variables table #1
  #case desc backend_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_variables_1"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | desc backend_variables   | dble_information |
    Then check resultset "backend_variables_1" has lines with following column values
      | Field-0         | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | backend_conn_id | int(11)     | NO     | PRI   | None      |         |
      | variable_name   | varchar(12) | NO     | PRI   | None      |         |
      | variable_value  | varchar(12) | NO     |       | None      |         |
      | variable_type   | varchar(3)  | NO     |       | None      |         |
    ###根据默认配置minCon="10" 加一根心跳 backend_connections总数22   backend_variables=22*8
    ###但是，初始化连接池创建连接的时候，可能会和检测元数据并发，导致多建一根连接（对应连接包含关键字：createByWaiter:true），而空闲连接默认最长需要90s后才会被回收
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'    | success       | dble_information  |
    Then kill the redundant connections if "rs_1" is more then expect value "10" in "mysql-master1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                               | expect        | db               |
      | conn_0 | False   | desc backend_variables            | length{(4)}   | dble_information |
      | conn_0 | False   | select * from backend_connections | length{(22)}  | dble_information |
      | conn_0 | False   | select * from backend_variables   | length{(176)} | dble_information |

    #case select * from backend_variables  就是一根链接下有固定的8个初始值，可以有其他设置的值
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
      | transaction_read_only    | false              | sys             |
      | tx_read_only             | false              | sys             |

    ###修改xml配置测试链接的参数变更
    Given delete the following xml segment
      | file            | parent         | child                  |
      | db.xml          | {'tag':'root'} | {'tag':'dbGroup'}      |
      | sharding.xml    | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml    | {'tag':'root'} | {'tag':'shardingNode'} |

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="10" minCon="4" primary="true">
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
    ###根据minCon="4" 加一根心跳 backend_connections总数5   backend_variables=5*8
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'    | success       | dble_information  |
    Then kill the redundant connections if "rs_2" is more then expect value "4" in "mysql-master1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                               | expect       | db               |
      | conn_0 | False   | select * from backend_connections | length{(5)}  | dble_information |
      | conn_0 | False   | select * from backend_variables   | length{(40)} | dble_information |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | expect          |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='true'                               | length{(5)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='false'                              | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='repeatable-read'         | length{(5)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='read-uncommitted'        | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='utf8mb4'                  | length{(5)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='utf8mb4_general_ci'       | length{(5)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='utf8mb4'                 | length{(5)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='utf8mb4_general_ci'   | length{(5)}     |

   #case set sharding table to change autocommit and change transaction_isolation
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1               | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int)              | success | schema1 |
      | conn_1 | False   | set autocommit=0                                 | success | schema1 |
      | conn_1 | False   | set xa=on                                        | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1),(2),(3),(4) | success | schema1 |
    #case 通过backend_connections 这张表下发的sql 得到对应的backend_conn_id
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
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='true'                               | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='false'                              | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='repeatable-read'         | length{(5)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='read-uncommitted'        | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='utf8mb4'                  | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='utf8mb4_general_ci'       | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='utf8mb4'                 | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='utf8mb4_general_ci'   | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='latin1'                   | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='latin1_swedish_ci'        | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='latin1'                  | length{(2)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='latin1_swedish_ci'    | length{(2)}     |
        #### 变更级别
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                            | expect  |
      | conn_1 | False   | SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED       | success |
      | conn_1 | False   | insert into sharding_2_t1 values (5)                           | success |
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                | expect          |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='true'                         | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='false'                        | length{(2)}     |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | commit                                           | success |
      | conn_1 | False   | set autocommit=1                                 | success |
      | conn_1 | False   | set xa=off                                       | success |
      | conn_1 | False   | select * from sharding_2_t1                      | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                | expect          |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='true'                         | length{(5)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='false'                        | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='repeatable-read'   | length{(3)}     |
      | conn_0 | true    | select * from backend_variables where variable_name='transaction_isolation' and variable_value='read-uncommitted'  | length{(2)}     |

    #case set vertical table to change autocommit transaction_isolation character
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | drop table if exists test                        | success |
      | conn_1 | False   | create table test (id int)                       | success |
      | conn_1 | False   | set autocommit=0                                 | success |
      | conn_1 | False   | set xa=on                                        | success |
      | conn_1 | False   | insert into test values (1),(2),(3),(4)          | success |
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | expect          |
      | conn_0 | False   | use dble_information                                                                                                     | success         |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='true'                               | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='autocommit' and variable_value='false'                              | length{(1)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='utf8mb4'                  | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='utf8mb4_general_ci'       | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='utf8mb4'                 | length{(3)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='utf8mb4_general_ci'   | length{(3)}     |
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
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='utf8mb4'                  | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='utf8mb4_general_ci'       | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='utf8mb4'                 | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='utf8mb4_general_ci'   | length{(4)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='latin1'                   | length{(1)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='latin1_swedish_ci'        | length{(1)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='latin1'                  | length{(1)}     |
      | conn_0 | true    | select * from backend_variables where variable_name='character_set_connection' and variable_value='latin1_swedish_ci'    | length{(1)}     |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | True    | commit                                           | success |


     #case change bootstrap.cnf to check
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DtxIsolation=2
    $a -Dautocommit=0
    $a -Dcharset=latin1
    """
    Given Restart dble in "dble-1" success
    ###根据minCon="4" 加一根心跳 backend_connections总数5   backend_variables=5*8
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_3"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'    | success       | dble_information  |
    Then kill the redundant connections if "rs_3" is more then expect value "4" in "mysql-master1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                               | expect       | db               |
      | conn_0 | False   | select * from backend_connections | length{(5)}  | dble_information |
      | conn_0 | False   | select * from backend_variables   | length{(40)} | dble_information |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | expect          |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='repeatable-read'         | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='transaction_isolation' and variable_value='read-committed'          | length{(5)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='utf8mb4'                  | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='utf8mb4_general_ci'       | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='utf8mb4'                 | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='utf8mb4_general_ci'   | length{(0)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_client' and variable_value='latin1'                   | length{(5)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='collation_connection' and variable_value='latin1_swedish_ci'        | length{(5)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_results' and variable_value='latin1'                  | length{(5)}     |
      | conn_0 | False   | select * from backend_variables where variable_name='character_set_connection' and variable_value='latin1_swedish_ci'    | length{(5)}     |
    #case check variable_type='user'
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_1 | False   | begin                                           | success | schema1 |
      | conn_1 | False   | set @a=1                                        | success | schema1 |
      | conn_1 | False   | insert into test values (1),(2),(3),(4)         | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                           | expect                          |
      | conn_0 | False   | select variable_name,variable_value,variable_type from backend_variables where variable_type='user'           | has{(('@A', '1', 'user'),)}     |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_1 | True    | drop table if exists test                       | success | schema1 |
   #case  unsupported dml
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect                                          |
      | conn_0 | False   | delete from backend_variables where variable_name='autocommit'                         | Access denied for table 'backend_variables'     |
      | conn_0 | False   | update backend_variables set variable_name='' where variable_name='autocommit'         | Access denied for table 'backend_variables'     |
      | conn_0 | True    | insert into backend_variables values (1,'1','1','1')                                   | Access denied for table 'backend_variables'     |