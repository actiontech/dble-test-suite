# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2021/2/24

Feature:manager Cmd

  Scenario: enable/disable @@statistic and show @@statistic  #1
   #CASE PREPARE rwSplitUser AND shardingUser
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config"

   # CASE TEST "disable @@statistic"
    Then execute admin cmd "disable @@statistic"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | show @@statistic        | dble_information |
    Then check resultset "version_1" has lines with following column values
      | NAME-0                                  | VALUE-1 |
      | statistic                               | OFF     |
      | associateTablesByEntryByUserTableSize   | 1024    |
      | frontendByBackendByEntryByUserTableSize | 1024    |
      | tableByUserByEntryTableSize             | 1024    |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(0)} | dble_information |

    # rwSplitUser AND shardingUser do_execute_query,three table values is none
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                | success | schema1 |
      | conn_1 | False   | drop table if exists test                         | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20)) | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))          | success | schema1 |
      | conn_1 | true    | insert into sharding_4_t1 values (1,1)            | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_2 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_2 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_2 | true    | insert into test_table values (1,2)           | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(0)} |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(0)} |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(0)} |

   #case check dble_information.dble_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_2"
      | conn   | toClose | sql                     | db               |
      | conn_0 | true    | select * from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')       | dble_information |
    Then check resultset "version_2" has lines with following column values
      | variable_name-0                         | variable_value-1 | comment-2                                                      | read_only-3 |
      | enableStatistic                         | false            | Enable statistic sql, the default is false                     | false       |
      | associateTablesByEntryByUserTableSize   | 1024             | AssociateTablesByEntryByUser table size, the default is 1024   | false       |
      | frontendByBackendByEntryByUserTableSize | 1024             | FrontendByBackendByEntryByUser table size, the default is 1024 | false       |
      | tableByUserByEntryTableSize             | 1024             | TableByUserByEntry table size, the default is 1024             | false       |

   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      enableStatistic=0
      """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_3"
      | conn   | toClose | sql                     | db               |
      | conn_0 | true    | show @@statistic        | dble_information |
    Then check resultset "version_3" has lines with following column values
      | NAME-0                                  | VALUE-1 |
      | statistic                               | OFF     |
      | associateTablesByEntryByUserTableSize   | 1024    |
      | frontendByBackendByEntryByUserTableSize | 1024    |
      | tableByUserByEntryTableSize             | 1024    |

   # CASE TEST "enable @@statistic"
    Then execute admin cmd "enable @@statistic"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_4"
      | conn   | toClose | sql                     | db               |
      | conn_0 | true    | show @@statistic        | dble_information |
    Then check resultset "version_4" has lines with following column values
      | NAME-0                                  | VALUE-1 |
      | statistic                               | ON      |
      | associateTablesByEntryByUserTableSize   | 1024    |
      | frontendByBackendByEntryByUserTableSize | 1024    |
      | tableByUserByEntryTableSize             | 1024    |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(0)} | dble_information |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry               | length{(0)} | dble_information |

    # rwSplitUser AND shardingUser do_execute_query,three table has some values
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                            | expect  | db      |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1)                                         | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                  | success | schema1 |
      | conn_1 | true    | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                 | expect  | db  |
      | rwS1 | 111111 | conn_2 | true    | insert into test_table values (1,2) | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(3)} | dble_information |

   #case check dble_information.dble_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_5"
      | conn   | toClose | sql                     | db               |
      | conn_0 | true    | select * from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')       | dble_information |
    Then check resultset "version_5" has lines with following column values
      | variable_name-0                         | variable_value-1 | comment-2                                                      | read_only-3 |
      | enableStatistic                         | true             | Enable statistic sql, the default is false                     | false       |
      | associateTablesByEntryByUserTableSize   | 1024             | AssociateTablesByEntryByUser table size, the default is 1024   | false       |
      | frontendByBackendByEntryByUserTableSize | 1024             | FrontendByBackendByEntryByUser table size, the default is 1024 | false       |
      | tableByUserByEntryTableSize             | 1024             | TableByUserByEntry table size, the default is 1024             | false       |

    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(3)} | dble_information |
    Then execute admin cmd "disable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(3)} | dble_information |
    Then execute admin cmd "disable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(3)} | dble_information |
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(0)} | dble_information |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry               | length{(0)} | dble_information |

   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      enableStatistic=1
      """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_6"
      | conn   | toClose | sql                     | db               |
      | conn_0 | true    | show @@statistic        | dble_information |
    Then check resultset "version_6" has lines with following column values
      | NAME-0                                  | VALUE-1 |
      | statistic                               | ON      |
      | associateTablesByEntryByUserTableSize   | 1024    |
      | frontendByBackendByEntryByUserTableSize | 1024    |
      | tableByUserByEntryTableSize             | 1024    |



  Scenario: reload @@statistic_table_size = ? [where table='?' | where table in (dble_information.tableA,...)]  Illegal value  #2
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                     | expect                            |
      | conn_0 | False   | reload @@statistic_table_size = -1                      | tableSize must be greater than 0  |
      | conn_0 | False   | reload @@statistic_table_size = 0                       | tableSize must be greater than 0  |
      | conn_0 | False   | reload @@statistic_table_size = 99999999999999          | tableSize setting is not correct  |
      | conn_0 | False   | reload @@statistic_table_size = 999%                    | tableSize setting is not correct  |
      | conn_0 | False   | reload @@statistic_table_size = 999.99                  | tableSize setting is not correct  |
      | conn_0 | False   | reload @@statistic_table_size = 10 where table ='sql_statistic_by_asociate_tables_by_entry_by_user'       | Table `dble_information`.`sql_statistic_by_asociate_tables_by_entry_by_user` don't belong to statistic tables   |
      | conn_0 | False   | reload @@statistic_table_size = 10 where table ='sql_statistic_by_frontend_by_backend_by_entry_by_u'      | Table `dble_information`.`sql_statistic_by_frontend_by_backend_by_entry_by_u` don't belong to statistic tables  |
      | conn_0 | False   | reload @@statistic_table_size = 10 where table ='sql_statistic_by_table_by_user_by_ent'                   | Table `dble_information`.`sql_statistic_by_table_by_user_by_ent` don't belong to statistic tables               |
      | conn_0 | False   | reload @@statistic_table_size = 10 where table in (sql_statistic_by_associate_tables_by_)                 | Table `dble_information`.`sql_statistic_by_associate_tables_by_` don't belong to statistic tables               |
      | conn_0 | False   | reload @@statistic_table_size = 10 where table in (sql_statistic_by_table_by_user_by_ent,sql_statistic)   | Table `dble_information`.`sql_statistic_by_table_by_user_by_ent` don't belong to statistic tables               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | true    | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | true             |
      | associateTablesByEntryByUserTableSize   | 1024             |
      | frontendByBackendByEntryByUserTableSize | 1024             |
      | tableByUserByEntryTableSize             | 1024             |


  Scenario: reload @@statistic_table_size = ?   #3
    #CASE PREPARE env
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema2">
        <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="test2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    #1 more than one rwSplitUsers can use the same dbGroup
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config"

    Then execute admin cmd "enable @@statistic"
    # the size value is default
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | true             |
      | associateTablesByEntryByUserTableSize   | 1024             |
      | frontendByBackendByEntryByUserTableSize | 1024             |
      | tableByUserByEntryTableSize             | 1024             |

    #do query create data
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1)                                                  | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1)                                                  | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | False   | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | true    | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,2)           | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(6)} | dble_information |
    # set size =2,check table length =2
    Then execute admin cmd "reload @@statistic_table_size = 2"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=2
      tableByUserByEntryTableSize=2
      associateTablesByEntryByUserTableSize=2
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(2)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(2)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(2)} | dble_information |
    #check dble_information.dble_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | true             |
      | associateTablesByEntryByUserTableSize   | 2                |
      | frontendByBackendByEntryByUserTableSize | 2                |
      | tableByUserByEntryTableSize             | 2                |

    # set size =4
    Then execute admin cmd "reload @@statistic_table_size = 4"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=4
      tableByUserByEntryTableSize=4
      associateTablesByEntryByUserTableSize=4
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1)                                                  | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1)                                                  | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | False   | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | true    | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,2)           | success | db1 |
    #check table length =4
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(4)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(4)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(4)} | dble_information |
    #check dble_information.dble_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | true             |
      | associateTablesByEntryByUserTableSize   | 4                |
      | frontendByBackendByEntryByUserTableSize | 4                |
      | tableByUserByEntryTableSize             | 4                |



    Then execute admin cmd "disable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(4)} |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(4)} |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(4)} |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | false            |
      | associateTablesByEntryByUserTableSize   | 4                |
      | frontendByBackendByEntryByUserTableSize | 4                |
      | tableByUserByEntryTableSize             | 4                |
    Then execute admin cmd "reload @@statistic_table_size = 1"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=1
      tableByUserByEntryTableSize=1
      associateTablesByEntryByUserTableSize=1
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(1)} |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(1)} |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(1)} |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | false            |
      | associateTablesByEntryByUserTableSize   | 1                |
      | frontendByBackendByEntryByUserTableSize | 1                |
      | tableByUserByEntryTableSize             | 1                |

    Then execute admin cmd "enable @@statistic"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | true             |
      | associateTablesByEntryByUserTableSize   | 1                |
      | frontendByBackendByEntryByUserTableSize | 1                |
      | tableByUserByEntryTableSize             | 1                |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(0)} |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(0)} |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(0)} |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1)                                                  | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1)                                                  | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | False   | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | true    | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,2)           | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(1)} |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(1)} |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(1)} |

    Then execute admin cmd "disable @@statistic"
    Then execute admin cmd "reload @@statistic_table_size = 10"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=10
      tableByUserByEntryTableSize=10
      associateTablesByEntryByUserTableSize=10
      """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | false            |
      | associateTablesByEntryByUserTableSize   | 10               |
      | frontendByBackendByEntryByUserTableSize | 10               |
      | tableByUserByEntryTableSize             | 10               |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(1)} |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(1)} |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(1)} |
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1)                                                  | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1)                                                  | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | true    | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | true    | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,2)           | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(5)} |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(5)} |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry               | length{(6)} |


  Scenario: reload @@statistic_table_size = ? where table =''   #4
    #CASE PREPARE env
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema2">
        <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="test2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    #1 more than one rwSplitUsers can use the same dbGroup
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config"

    Then execute admin cmd "enable @@statistic"
    #do query create data
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1)                                                  | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1)                                                  | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | False   | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name               | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where b.id =1 | success | schema1 |
      | conn_1 | true    | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,2)           | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(6)} | dble_information |

    Then execute admin cmd "reload @@statistic_table_size = 1 where table ='dble_information.sql_statistic_by_associate_tables_by_entry_by_user'"
    Then execute admin cmd "reload @@statistic_table_size = 2 where table ='sql_statistic_by_frontend_by_backend_by_entry_by_user'"
    Then execute admin cmd "reload @@statistic_table_size = 3 where table ='sql_statistic_by_table_by_user_by_entry'"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=2
      tableByUserByEntryTableSize=3
      associateTablesByEntryByUserTableSize=1
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(2)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(3)} | dble_information |
    #check dble_information.dble_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | true             |
      | associateTablesByEntryByUserTableSize   | 1                |
      | frontendByBackendByEntryByUserTableSize | 2                |
      | tableByUserByEntryTableSize             | 3                |

    Then execute admin cmd "reload @@statistic_table_size = 3 where table ='sql_statistic_by_associate_tables_by_entry_by_user'"
    Then execute admin cmd "reload @@statistic_table_size = 3 where table ='dble_information.sql_statistic_by_frontend_by_backend_by_entry_by_user'"
    Then execute admin cmd "reload @@statistic_table_size = 4 where table ='sql_statistic_by_table_by_user_by_entry'"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=3
      tableByUserByEntryTableSize=4
      associateTablesByEntryByUserTableSize=3
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1)                                                  | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1)                                                  | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | False   | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | true    | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,2)           | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(3)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(3)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(4)} | dble_information |
    #check dble_information.dble_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | true             |
      | associateTablesByEntryByUserTableSize   | 3                |
      | frontendByBackendByEntryByUserTableSize | 3                |
      | tableByUserByEntryTableSize             | 4                |


    Then execute admin cmd "disable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(3)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(3)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(4)} | dble_information |
    Then execute admin cmd "reload @@statistic_table_size = 2 where table ='sql_statistic_by_associate_tables_by_entry_by_user'"
    Then execute admin cmd "reload @@statistic_table_size = 1 where table ='sql_statistic_by_frontend_by_backend_by_entry_by_user'"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=1
      tableByUserByEntryTableSize=4
      associateTablesByEntryByUserTableSize=2
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(2)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(4)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | false            |
      | associateTablesByEntryByUserTableSize   | 2                |
      | frontendByBackendByEntryByUserTableSize | 1                |
      | tableByUserByEntryTableSize             | 4                |

    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1)                                                  | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1)                                                  | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | False   | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | true    | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,2)           | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(2)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(4)} | dble_information |
    Then execute admin cmd "disable @@statistic"
    Then execute admin cmd "reload @@statistic_table_size = 6 where table ='sql_statistic_by_associate_tables_by_entry_by_user'"
    Then execute admin cmd "reload @@statistic_table_size = 12 where table ='sql_statistic_by_frontend_by_backend_by_entry_by_user'"
    Then execute admin cmd "reload @@statistic_table_size = 13 where table ='sql_statistic_by_table_by_user_by_entry'"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=12
      tableByUserByEntryTableSize=13
      associateTablesByEntryByUserTableSize=6
      """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | false            |
      | associateTablesByEntryByUserTableSize   | 6                |
      | frontendByBackendByEntryByUserTableSize | 12               |
      | tableByUserByEntryTableSize             | 13               |
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1),(2,2)                                            | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1),(2,2)                                            | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | true    | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join schema2.test2 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | true    | select * from schema2.test1 a inner join schema2.test1 b on a.name=b.name where a.id =1 | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,2)           | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(6)} |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(5)} |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry               | length{(6)} |


  Scenario: reload @@statistic_table_size = ? where table in ( , )   #5
    #CASE PREPARE env
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema2">
        <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="test2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    #1 more than one rwSplitUsers can use the same dbGroup
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config"

    Then execute admin cmd "enable @@statistic"
    #do query create data
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1)                                                  | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1)                                                  | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | False   | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name               | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where b.id =1 | success | schema1 |
      | conn_1 | true    | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,2)           | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(6)} | dble_information |

    Then execute admin cmd "reload @@statistic_table_size = 2 where table in (sql_statistic_by_associate_tables_by_entry_by_user,sql_statistic_by_frontend_by_backend_by_entry_by_user)"
    Then execute admin cmd "reload @@statistic_table_size = 3 where table in (sql_statistic_by_frontend_by_backend_by_entry_by_user,dble_information.sql_statistic_by_associate_tables_by_entry_by_user)"
    Then execute admin cmd "reload @@statistic_table_size = 4 where table in ('sql_statistic_by_table_by_user_by_entry',dble_information.sql_statistic_by_associate_tables_by_entry_by_user)"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=3
      tableByUserByEntryTableSize=4
      associateTablesByEntryByUserTableSize=4
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(4)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(3)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(4)} | dble_information |
    #check dble_information.dble_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | true             |
      | associateTablesByEntryByUserTableSize   | 4                |
      | frontendByBackendByEntryByUserTableSize | 3                |
      | tableByUserByEntryTableSize             | 4                |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                  | expect      | db               |
      | conn_0 | False   | truncate sql_statistic_by_associate_tables_by_entry_by_user          | success     | dble_information |
      | conn_0 | False   | truncate table sql_statistic_by_frontend_by_backend_by_entry_by_user | success     | dble_information |
      | conn_0 | False   | truncate dble_information.sql_statistic_by_table_by_user_by_entry    | success     | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user     | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user  | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry                | length{(0)} | dble_information |

    Then execute admin cmd "reload @@statistic_table_size = 5 where table in (sql_statistic_by_associate_tables_by_entry_by_user,sql_statistic_by_frontend_by_backend_by_entry_by_user,sql_statistic_by_table_by_user_by_entry)"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=5
      tableByUserByEntryTableSize=5
      associateTablesByEntryByUserTableSize=5
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1)                                                  | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1)                                                  | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | False   | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | true    | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,2)           | success | db1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(5)} | dble_information |
    #check dble_information.dble_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | true             |
      | associateTablesByEntryByUserTableSize   | 5                |
      | frontendByBackendByEntryByUserTableSize | 5                |
      | tableByUserByEntryTableSize             | 5                |

    Then execute admin cmd "disable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(5)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(5)} | dble_information |

    Then execute admin cmd "reload @@statistic_table_size = 2 where table in (sql_statistic_by_associate_tables_by_entry_by_user,sql_statistic_by_frontend_by_backend_by_entry_by_user,sql_statistic_by_table_by_user_by_entry)"
    Then execute admin cmd "reload @@statistic_table_size = 1 where table in (sql_statistic_by_associate_tables_by_entry_by_user,sql_statistic_by_table_by_user_by_entry)"
    Then execute admin cmd "reload @@statistic_table_size = 2 where table in (sql_statistic_by_frontend_by_backend_by_entry_by_user,sql_statistic_by_table_by_user_by_entry)"
    Then execute admin cmd "reload @@statistic_table_size = 3 where table in (sql_statistic_by_associate_tables_by_entry_by_user,sql_statistic_by_frontend_by_backend_by_entry_by_user)"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=3
      tableByUserByEntryTableSize=2
      associateTablesByEntryByUserTableSize=3
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(3)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(3)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(2)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | false            |
      | associateTablesByEntryByUserTableSize   | 3                |
      | frontendByBackendByEntryByUserTableSize | 3                |
      | tableByUserByEntryTableSize             | 2                |
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1)                                                  | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1)                                                  | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | False   | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | true    | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,2)           | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(3)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(3)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(2)} | dble_information |
    Then execute admin cmd "disable @@statistic"
    Then execute admin cmd "reload @@statistic_table_size = 7 where table in (sql_statistic_by_frontend_by_backend_by_entry_by_user,sql_statistic_by_table_by_user_by_entry)"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=7
      tableByUserByEntryTableSize=7
      associateTablesByEntryByUserTableSize=3
      """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | false            |
      | associateTablesByEntryByUserTableSize   | 3                |
      | frontendByBackendByEntryByUserTableSize | 7                |
      | tableByUserByEntryTableSize             | 7                |

    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1),(2,2)                                            | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1),(2,2)                                            | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | true    | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join schema2.test2 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select 1                                                                                | success | schema1 |
      | conn_1 | False   | select 2                                                                                | success | schema1 |
      | conn_1 | False   | select 3                                                                                | success | schema1 |
      | conn_1 | False   | select 4                                                                                | success | schema1 |
      | conn_1 | true    | select 5                                                                                | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values (1,2)           | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | select 1                                      | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | select 2                                      | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(3)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(6)} | dble_information |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry               | length{(7)} | dble_information |

    Then execute admin cmd "reload @@statistic_table_size = 20 where table in (sql_statistic_by_frontend_by_backend_by_entry_by_user,sql_statistic_by_table_by_user_by_entry,sql_statistic_by_associate_tables_by_entry_by_user)"
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontendByBackendByEntryByUserTableSize=20
      tableByUserByEntryTableSize=20
      associateTablesByEntryByUserTableSize=20
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1),(2,2)                                            | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1),(2,2)                                            | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | true    | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join schema2.test2 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select 1                                                                                | success | schema1 |
      | conn_1 | true    | select 5                                                                                | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values (1,2)           | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | select 2                                      | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(6)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(6)} | dble_information |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry               | length{(8)} | dble_information |


  Scenario: check bootstrap.cnf   #6
    #case check defalut values
    Then check following text exist "N" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
      """
      -DenableStatistic=0
      -DstatisticTableSize=1024
      -DstatisticQueueSize=4096
      """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | true    | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | false            |
      | associateTablesByEntryByUserTableSize   | 1024             |
      | frontendByBackendByEntryByUserTableSize | 1024             |
      | tableByUserByEntryTableSize             | 1024             |



    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DstatisticQueueSize=10
    $a -DenableStatistic=-1
    $a -DassociateTablesByEntryByUserTableSize=0
    $a -DfrontendByBackendByEntryByUserTableSize=44%
    $a -DtableByUserByEntryTableSize=-1
    """
    Then restart dble in "dble-1" failed for
    """
    Property \[ statisticQueueSize \] '10' in bootstrap.cnf is illegal, size must not be less than 1 and must be a power of 2, you may need use the default value 4096 replaced
    Property \[ enableStatistic \] '-1' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
    property \[ frontendByBackendByEntryByUserTableSize \] '44%' data type should be int
    Property \[ tableByUserByEntryTableSize \] '-1' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
    Property \[ associateTablesByEntryByUserTableSize \] '0' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DenableStatistic/d
    /DassociateTablesByEntryByUserTableSize/d
    /DfrontendByBackendByEntryByUserTableSize/d
    /DtableByUserByEntryTableSize/d
    /DstatisticQueueSize/d
    /# processor/a -DenableStatistic=1
    /# processor/a -DassociateTablesByEntryByUserTableSize=1
    /# processor/a -DfrontendByBackendByEntryByUserTableSize=2
    /# processor/a -DtableByUserByEntryTableSize=3
    /# processor/a -DstatisticQueueSize=2048
    """
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | true    | select variable_name,variable_value from dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | true             |
      | associateTablesByEntryByUserTableSize   | 1                |
      | frontendByBackendByEntryByUserTableSize | 2                |
      | tableByUserByEntryTableSize             | 3                |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
      """
      DenableStatistic=1
      DassociateTablesByEntryByUserTableSize=1
      DfrontendByBackendByEntryByUserTableSize=2
      DtableByUserByEntryTableSize=3
      DstatisticQueueSize=2048
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema2">
        <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="test2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    #1 more than one rwSplitUsers can use the same dbGroup
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1),(2,2)                                            | success | schema1 |
      | conn_1 | False   | insert into test values (1,1)                                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1),(2,2)                                            | success | schema1 |
      | conn_2 | False   | insert into test1 values (1,1)                                                          | success | schema2 |
      | conn_2 | true    | insert into test2 values (1,1)                                                          | success | schema2 |
      | conn_1 | False   | select * from test a inner join sharding_4_t1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select * from schema2.test1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from schema2.test2 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join schema2.test2 b on a.name=b.name where a.id =1 | success | schema1 |
      | conn_1 | False   | select * from test a inner join schema2.test1 b on a.name=b.name where a.id =1          | success | schema1 |
      | conn_1 | False   | select 1                                                                                | success | schema1 |
      | conn_1 | true    | select 5                                                                                | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values (1,2)           | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | select 2                                      | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(2)} | dble_information |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry               | length{(3)} | dble_information |


  Scenario: desc table and unsupported dml  #7
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                        | expect       | db               |
      | conn_0 | False   | desc sql_statistic_by_associate_tables_by_entry_by_user    | length{(8)}  | dble_information |
      | conn_0 | False   | desc sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(23)} | dble_information |
      | conn_0 | False   | desc sql_statistic_by_table_by_user_by_entry               | length{(17)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_1"
      | conn   | toClose | sql                                                     | db               |
      | conn_0 | False   | desc sql_statistic_by_associate_tables_by_entry_by_user | dble_information |
    Then check resultset "table_1" has lines with following column values
      | Field-0                  | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |
      | entry                    | int(11)      | NO     | PRI   | None      |         |
      | user                     | varchar(20)  | NO     | PRI   | None      |         |
      | associate_tables         | varchar(200) | NO     | PRI   | None      |         |
      | sql_select_count         | int(11)      | NO     |       | None      |         |
      | sql_select_examined_rows | int(11)      | NO     |       | None      |         |
      | sql_select_rows          | int(11)      | NO     |       | None      |         |
      | sql_select_time          | int(11)      | NO     |       | None      |         |
      | last_update_time         | varchar(26)  | NO     |       | None      |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_2"
      | conn   | toClose | sql                                                        | db               |
      | conn_0 | False   | desc sql_statistic_by_frontend_by_backend_by_entry_by_user | dble_information |
    Then check resultset "table_2" has lines with following column values
      | Field-0          | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | entry            | int(11)     | NO     | PRI   | None      |         |
      | user             | varchar(20) | NO     | PRI   | None      |         |
      | frontend_host    | varchar(20) | NO     | PRI   | None      |         |
      | backend_host     | varchar(20) | NO     | PRI   | None      |         |
      | backend_port     | int(6)      | NO     | PRI   | None      |         |
      | sharding_node    | varchar(20) | NO     | PRI   | None      |         |
      | db_instance      | varchar(20) | NO     | PRI   | None      |         |
      | tx_count         | int(11)     | NO     |       | None      |         |
      | tx_rows          | int(11)     | NO     |       | None      |         |
      | tx_time          | int(11)     | NO     |       | None      |         |
      | sql_insert_count | int(11)     | NO     |       | None      |         |
      | sql_insert_rows  | int(11)     | NO     |       | None      |         |
      | sql_insert_time  | int(11)     | NO     |       | None      |         |
      | sql_update_count | int(11)     | NO     |       | None      |         |
      | sql_update_rows  | int(11)     | NO     |       | None      |         |
      | sql_update_time  | int(11)     | NO     |       | None      |         |
      | sql_delete_count | int(11)     | NO     |       | None      |         |
      | sql_delete_rows  | int(11)     | NO     |       | None      |         |
      | sql_delete_time  | int(11)     | NO     |       | None      |         |
      | sql_select_count | int(11)     | NO     |       | None      |         |
      | sql_select_rows  | int(11)     | NO     |       | None      |         |
      | sql_select_time  | int(11)     | NO     |       | None      |         |
      | last_update_time | varchar(26) | NO     |       | None      |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_3"
      | conn   | toClose | sql                                             | db               |
      | conn_0 | False   | desc sql_statistic_by_table_by_user_by_entry    | dble_information |
    Then check resultset "table_3" has lines with following column values
      | Field-0                  | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | entry                    | int(11)     | NO     | PRI   | None      |         |
      | user                     | varchar(20) | NO     | PRI   | None      |         |
      | table                    | varchar(20) | NO     | PRI   | None      |         |
      | sql_insert_count         | int(11)     | NO     |       | None      |         |
      | sql_insert_rows          | int(11)     | NO     |       | None      |         |
      | sql_insert_time          | int(11)     | NO     |       | None      |         |
      | sql_update_count         | int(11)     | NO     |       | None      |         |
      | sql_update_rows          | int(11)     | NO     |       | None      |         |
      | sql_update_time          | int(11)     | NO     |       | None      |         |
      | sql_delete_count         | int(11)     | NO     |       | None      |         |
      | sql_delete_rows          | int(11)     | NO     |       | None      |         |
      | sql_delete_time          | int(11)     | NO     |       | None      |         |
      | sql_select_count         | int(11)     | NO     |       | None      |         |
      | sql_select_examined_rows | int(11)     | NO     |       | None      |         |
      | sql_select_rows          | int(11)     | NO     |       | None      |         |
      | sql_select_time          | int(11)     | NO     |       | None      |         |
      | last_update_time         | varchar(26) | NO     |       | None      |         |
    #case unsupported update/delete/insert
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                         | expect                                                                             | db               |
      | conn_0 | False   | delete from sql_statistic_by_associate_tables_by_entry_by_user where entry=1                | Access denied for table 'sql_statistic_by_associate_tables_by_entry_by_user'       | dble_information |
      | conn_0 | False   | update sql_statistic_by_associate_tables_by_entry_by_user set entry=22 where entry=1        | Access denied for table 'sql_statistic_by_associate_tables_by_entry_by_user'       | dble_information |
      | conn_0 | True    | insert into sql_statistic_by_associate_tables_by_entry_by_user (entry) values (22)          | Access denied for table 'sql_statistic_by_associate_tables_by_entry_by_user'       | dble_information |
      | conn_0 | False   | delete from sql_statistic_by_frontend_by_backend_by_entry_by_user where entry=1                | Access denied for table 'sql_statistic_by_frontend_by_backend_by_entry_by_user'       | dble_information |
      | conn_0 | False   | update sql_statistic_by_frontend_by_backend_by_entry_by_user set entry=22 where entry=1        | Access denied for table 'sql_statistic_by_frontend_by_backend_by_entry_by_user'       | dble_information |
      | conn_0 | True    | insert into sql_statistic_by_frontend_by_backend_by_entry_by_user (entry) values (22)          | Access denied for table 'sql_statistic_by_frontend_by_backend_by_entry_by_user'       | dble_information |
      | conn_0 | False   | delete from sql_statistic_by_table_by_user_by_entry where entry=1                | Access denied for table 'sql_statistic_by_table_by_user_by_entry'       | dble_information |
      | conn_0 | False   | update sql_statistic_by_table_by_user_by_entry set entry=22 where entry=1        | Access denied for table 'sql_statistic_by_table_by_user_by_entry'       | dble_information |
      | conn_0 | True    | insert into sql_statistic_by_table_by_user_by_entry (entry) values (22)          | Access denied for table 'sql_statistic_by_table_by_user_by_entry'       | dble_information |



   Scenario: add btrace check manage cmd
    Given delete file "/opt/dble/BtraceAboutsqlStatistic.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutsqlStatistic.java.log" on "dble-1"
    Given update file content "./assets/BtraceAboutsqlStatistic.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /updateTableMaxSize/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceAboutsqlStatistic.java" in "dble-1"
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                 | db               |
      | conn_0 | True    | reload @@statistic_table_size = 100 | dble_information |
    Then check btrace "BtraceAboutsqlStatistic.java" output in "dble-1"
    """
    reload tablesize
    """
    Given sleep "3" seconds
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                 | db               |
      | conn_1 | True    | reload @@statistic_table_size = 111 | dble_information |
    Given sleep "7" seconds
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                | db               |
      | conn_0 | True    | show @@statistic                   | dble_information |
    Given sleep "8" seconds

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | false            |
      | associateTablesByEntryByUserTableSize   | 111              |
      | frontendByBackendByEntryByUserTableSize | 111              |
      | tableByUserByEntryTableSize             | 111              |

    #case reload @@statistic_table_size = 200 where table =
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                                                                                   | db               |
      | conn_0 | True    | reload @@statistic_table_size = 200 where table ='sql_statistic_by_associate_tables_by_entry_by_user' | dble_information |
    Given sleep "3" seconds
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                                                                                   | db               |
      | conn_0 | True    | reload @@statistic_table_size = 222 where table ='sql_statistic_by_associate_tables_by_entry_by_user' | dble_information |
    Given sleep "7" seconds
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                | db               |
      | conn_0 | True    | show @@statistic                   | dble_information |
    Given sleep "8" seconds

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | false            |
      | associateTablesByEntryByUserTableSize   | 222              |
      | frontendByBackendByEntryByUserTableSize | 111              |
      | tableByUserByEntryTableSize             | 111              |

    #case reload @@statistic_table_size = 200 where table in
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                                                                                                                                             | db               |
      | conn_0 | True    | reload @@statistic_table_size = 300 where table in (sql_statistic_by_associate_tables_by_entry_by_user,sql_statistic_by_frontend_by_backend_by_entry_by_user)   | dble_information |
    Given sleep "3" seconds
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                                                                                                                                             | db               |
      | conn_0 | True    | reload @@statistic_table_size = 333 where table in (sql_statistic_by_frontend_by_backend_by_entry_by_user,sql_statistic_by_table_by_user_by_entry)              | dble_information |
    Given sleep "7" seconds
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                | db               |
      | conn_0 | True    | show @@statistic                   | dble_information |
    Given sleep "8" seconds

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | false            |
      | associateTablesByEntryByUserTableSize   | 300              |
      | frontendByBackendByEntryByUserTableSize | 333              |
      | tableByUserByEntryTableSize             | 333              |

    #case reload and enable
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                              | db               |
      | conn_0 | True    | reload @@statistic_table_size = 555              | dble_information |
    Given sleep "3" seconds
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                | db               |
      | conn_0 | True    | enable @@statistic                 | dble_information |
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                | db               |
      | conn_0 | True    | show @@statistic                   | dble_information |
    Given sleep "8" seconds

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | true             |
      | associateTablesByEntryByUserTableSize   | 555              |
      | frontendByBackendByEntryByUserTableSize | 555              |
      | tableByUserByEntryTableSize             | 555              |

    #case reload and disable
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                              | db               |
      | conn_0 | True    | reload @@statistic_table_size = 666              | dble_information |
    Given sleep "3" seconds
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                | db               |
      | conn_0 | True    | disable @@statistic                | dble_information |
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                                | db               |
      | conn_0 | True    | show @@statistic                   | dble_information |
    Given sleep "8" seconds

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | true    | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')      | dble_information |
    Then check resultset "version_1" has lines with following column values
      | variable_name-0                         | variable_value-1 |
      | enableStatistic                         | false            |
      | associateTablesByEntryByUserTableSize   | 666              |
      | frontendByBackendByEntryByUserTableSize | 666              |
      | tableByUserByEntryTableSize             | 666              |


    Given stop btrace script "BtraceAboutsqlStatistic.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceAboutsqlStatistic.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutsqlStatistic.java.log" on "dble-1"