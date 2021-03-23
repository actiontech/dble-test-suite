# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2021/3/22

Feature:manager Cmd

  Scenario: desc table and unsupported dml  #1
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                 | expect        | db               |
      | conn_0 | False   | desc sql_log                        | length{(12)}  | dble_information |
      | conn_0 | False   | desc sql_log_by_tx_by_entry_by_user | length{(10)}  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_1"
      | conn   | toClose | sql          | db               |
      | conn_0 | False   | desc sql_log | dble_information |
    Then check resultset "table_1" has lines with following column values
      | Field-0       | Type-1        | Null-2 | Key-3 | Default-4 | Extra-5 |
      | sql_id        | int(11)       | NO     | PRI   | None      |         |
      | sql_stmt      | varchar(1024) | NO     |       | None      |         |
      | sql_type      | varchar(16)   | NO     |       | None      |         |
      | tx_id         | int(11)       | NO     | PRI   | None      |         |
      | entry         | int(11)       | NO     |       | None      |         |
      | user          | varchar(20)   | NO     |       | None      |         |
      | source_host   | varchar(20)   | NO     |       | None      |         |
      | source_port   | int(11)       | NO     |       | None      |         |
      | rows          | int(11)       | NO     |       | None      |         |
      | examined_rows | int(11)       | NO     |       | None      |         |
      | start_time    | int(11)       | NO     |       | None      |         |
      | duration      | int(11)       | NO     |       | None      |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_2"
      | conn   | toClose | sql                                 | db               |
      | conn_0 | False   | desc sql_log_by_tx_by_entry_by_user | dble_information |
    Then check resultset "table_2" has lines with following column values
      | Field-0       | Type-1        | Null-2 | Key-3 | Default-4 | Extra-5 |
      | tx_id         | int(11)       | NO     | PRI   | None      |         |
      | entry         | int(11)       | NO     | PRI   | None      |         |
      | user          | varchar(20)   | NO     | PRI   | None      |         |
      | source_host   | varchar(20)   | NO     |       | None      |         |
      | source_port   | int(11)       | NO     |       | None      |         |
      | sql_ids       | varchar(1024) | NO     |       | None      |         |
      | sql_count     | int(11)       | NO     |       | None      |         |
      | tx_duration   | int(11)       | NO     |       | None      |         |
      | busy_time     | int(11)       | NO     |       | None      |         |
      | examined_rows | int(11)       | NO     |       | None      |         |

    #case unsupported update/delete/insert
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                              | expect                                                   | db               |
      | conn_0 | False   | delete from sql_log where entry=1                                | Access denied for table 'sql_log'                        | dble_information |
      | conn_0 | False   | update sql_log set entry=22 where entry=1                        | Access denied for table 'sql_log'                        | dble_information |
      | conn_0 | True    | insert into sql_log (entry) values (22)                          | Access denied for table 'sql_log'                        | dble_information |
      | conn_0 | False   | delete from sql_log_by_tx_by_entry_by_user where entry=1         | Access denied for table 'sql_log_by_tx_by_entry_by_user' | dble_information |
      | conn_0 | False   | update sql_log_by_tx_by_entry_by_user set entry=22 where entry=1 | Access denied for table 'sql_log_by_tx_by_entry_by_user' | dble_information |
      | conn_0 | True    | insert into sql_log_by_tx_by_entry_by_user (entry) values (22)   | Access denied for table 'sql_log_by_tx_by_entry_by_user' | dble_information |


  Scenario: samplingRate in bootstrap.cnf   #2

    #case check defalut values
    Then check following text exist "N" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
      """
      -DsamplingRate=0
      -DtableSqlLogSize=1024
      """
    #error values
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DsamplingRate=-1
    $a -DtableSqlLogSize=-1
    """
    Then restart dble in "dble-1" failed for
    """
    Property [ samplingRate ] '-1' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
    Property [ tableSqlLogSize ] '-1' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DsamplingRate=1000
    $a -DtableSqlLogSize=99.99
    """
    Then restart dble in "dble-1" failed for
    """
    Property [ samplingRate ] '1000' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
    property [ tableSqlLogSize ] '99.99' data type should be int
    """

   #case set correct values
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DsamplingRate/d
    /DtableSqlLogSize/d
    /# processor/a -DsamplingRate=100
    /# processor/a -DtableSqlLogSize=100
    """
    Given Restart dble in "dble-1" success
#   #case check dble_information.dble_variables
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_2"
#      | conn   | toClose | sql                     | db               |
#      | conn_0 | true    | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'samplingRate','tableSqlLogSize')       | dble_information |
#    Then check resultset "version_2" has lines with following column values
#      | variable_name-0 | variable_value-1|
#      | enableStatistic | false           |
#      | samplingRate    | 100             |
#      | tableSqlLogSize | 100             |
#   #case check bootstrap.dynamic.cnf
#    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
#      """
#      samplingRate=100
#      tableSqlLogSize=100
#      """

   #samplingRate 100% but disable @@statistic
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect      | db               |
      | conn_0 | False   | select * from sql_log                        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user | length{(0)} | dble_information |
   # samplingRate 100% and enable @@statistic
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect      | db               |
      | conn_0 | False   | select * from sql_log                        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user | length{(0)} | dble_information |


  Scenario: test samplingRate=0 and sql_statistic has values   #3

    #CASE PREPARE env
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema2">
        <globalTable name="global2" shardingNode="dn1,dn2,dn3,dn4" />
        <singleTable name="sing1" shardingNode="dn1" />
        <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>

    <schema shardingNode="dn1" name="schema3" >
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
    <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    <rwSplitUser name="rwS2" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config"

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DsamplingRate/d
    /DtableSqlLogSize/d
    /# processor/a -DsamplingRate=0
    /# processor/a -DtableSqlLogSize=100
    """
    Given Restart dble in "dble-1" success

    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect      | db               |
      | conn_0 | False   | select * from sql_log                        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user | length{(0)} | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect  | db      |
      | conn_1 | False   | drop table if exists test1                | success | schema1 |
      | conn_1 | False   | create table test1 (id int,name char(20)) | success | schema1 |
      | conn_1 | False   | insert into test1 values (1,1),(2,2)      | success | schema1 |
      | conn_1 | False   | select * from test1                       | success | schema1 |
      | conn_1 | False   | update test1 set name= '3' where id=1     | success | schema1 |
      | conn_1 | False   | delete from test1 where id=6              | success | schema1 |
      | conn_1 | False   | select 5                                  | success | schema1 |
      | conn_1 | False   | show databases                            | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values (1,2)           | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | select 2                                      | success | db1 |
      | rwS2 | 111111 | conn_4 | False   | drop table if exists test_table               | success | db2 |
      | rwS2 | 111111 | conn_4 | False   | create table test_table(id int,name char(20)) | success | db2 |
      | rwS2 | 111111 | conn_4 | False   | insert into test_table values (1,2)           | success | db2 |
      | rwS2 | 111111 | conn_4 | true    | select 2                                      | success | db2 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(3)} | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(6)} | dble_information |
      | conn_0 | False   | select * from sql_log                                               | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user                        | length{(0)} | dble_information |


  Scenario: test samplingRate=100 and simple sql   #4
    #CASE PREPARE env
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
    <shardingUser name="test" password="111111" schemas="schema1"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config"

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DsamplingRate/d
    /DtableSqlLogSize/d
    /# processor/a -DsamplingRate=100
    /# processor/a -DtableSqlLogSize=100
    """
    Given Restart dble in "dble-1" success

    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect      | db               |
      | conn_0 | False   | select * from sql_log                        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user | length{(0)} | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect  | db      |
      | conn_1 | False   | drop table if exists test1                | success | schema1 |
      | conn_1 | False   | create table test1 (id int,name char(20)) | success | schema1 |
      | conn_1 | False   | insert into test1 values (1,1),(2,2)      | success | schema1 |
      | conn_1 | False   | select * from test1                       | success | schema1 |
      | conn_1 | False   | update test1 set name= '3' where id=1     | success | schema1 |
      | conn_1 | False   | delete from test1 where id=6              | success | schema1 |
      | conn_1 | False   | select 5                                  | success | schema1 |
      | conn_1 | False   | show databases                            | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values (1,2)           | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | select 2                                      | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect       | db               |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | length{(2)}  | dble_information |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(4)}  | dble_information |
      | conn_0 | False   | select * from sql_log                                               | length{(12)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user                        | length{(12)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                    | sql_type-2 | tx_id-3 | entry-4 | user-5 | source_host-6 | source_port-7 | rows-8 | examined_rows-9 |
      | 1        | drop table if exists test1                    | 1          | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 2        | create table test1 (id int,name char(20))     | 2          | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 3        | insert into test1 values (1,1),(2,2)          | 3          | 3       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2               |
      | 4        | select * from test1                           | 4          | 4       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2               |
      | 5        | update test1 set name= '3' where id=1         | 5          | 5       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1               |
      | 6        | delete from test1 where id=6                  | 6          | 6       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 7        | select 5                                      | 7          | 7       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1               |
      | 8        | show databases                                | 8          | 8       | 2       | test   | 172.100.9.8   | 8066          | 1      | 0               |
      | 9        | drop table if exists test_table               | 9          | 9       | 3       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |
      | 10       | create table test_table(id int,name char(20)) | 10         | 10      | 3       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |
      | 11       | insert into test_table values (1,2)           | 11         | 11      | 3       | rwS1   | 172.100.9.8   | 8066          | 1      | 1               |
      | 12       | select 2                                      | 12         | 12      | 3       | rwS1   | 172.100.9.8   | 8066          | 1      | 1               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1         | 1           | 0               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 2         | 1           | 0               |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 3         | 1           | 2               |
      | 4       | 2       | test   | 172.100.9.8   | 8066          | 4         | 1           | 2               |
      | 5       | 2       | test   | 172.100.9.8   | 8066          | 5         | 1           | 1               |
      | 6       | 2       | test   | 172.100.9.8   | 8066          | 6         | 1           | 0               |
      | 7       | 2       | test   | 172.100.9.8   | 8066          | 7         | 1           | 1               |
      | 8       | 2       | test   | 172.100.9.8   | 8066          | 8         | 1           | 0               |
      | 9       | 3       | rwS1   | 172.100.9.8   | 8066          | 9         | 1           | 0               |
      | 10      | 3       | rwS1   | 172.100.9.8   | 8066          | 10        | 1           | 0               |
      | 11      | 3       | rwS1   | 172.100.9.8   | 8066          | 11        | 1           | 1               |
      | 12      | 3       | rwS1   | 172.100.9.8   | 8066          | 12        | 1           | 1               |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | truncate dble_information.sql_log                     | success      | dble_information |
      | conn_0 | False   | truncate sql_log_by_tx_by_entry_by_user               | success      | dble_information |
      | conn_0 | False   | select * from sql_log                                 | length{(0)}  | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user          | length{(0)}  | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect  | db      |
      | conn_1 | true    | drop table if exists test1                | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | true    | drop table if exists test_table               | success | db1 |


  Scenario: test samplingRate=100 and complex sql   #5
    #CASE PREPARE env
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema2">
        <globalTable name="global2" shardingNode="dn1,dn2,dn3,dn4" />
        <singleTable name="sing1" shardingNode="dn1" />
        <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
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
    <shardingUser name="test" password="111111" schemas="schema1,schema2,"/>
    <shardingUser name="test1" password="111111" schemas="schema1,schema2"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config"
    #case for mysql 5.7 shrdinguser
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                  | expect  | db      |
      | conn_1 | False   | drop table if exists test                                                            | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                   | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.global2                                                 | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.sharding2                                               | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.sing1                                                   | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                             | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                    | success | schema1 |
      | conn_1 | False   | create table schema2.global2 (id int,name char(20))                                  | success | schema1 |
      | conn_1 | False   | create table schema2.sharding2 (id int,name char(20))                                | success | schema1 |
      | conn_1 | False   | create table schema2.sing1 (id int,name char(20))                                    | success | schema1 |
      | conn_1 | False   | insert into test values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')              | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')     | success | schema1 |
      | conn_1 | False   | insert into schema2.global2 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')   | success | schema1 |
      | conn_1 | False   | insert into schema2.sharding2 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_1 | true    | insert into schema2.sing1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')     | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DsamplingRate/d
    /DtableSqlLogSize/d
    /# processor/a -DsamplingRate=100
    /# processor/a -DtableSqlLogSize=100
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "enable @@statistic"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | insert into sharding_2_t1(id, name) select id,name from schema2.sharding2                                              | success | schema1 |
      | conn_1 | False   | insert into test(id, name) select id,name from schema2.global2                                                         | success | schema1 |
      | conn_1 | False   | insert into schema2.sing1(id, name) select id,name from schema2.sing1                                                  | success | schema1 |
      | conn_1 | False   | insert into schema2.sharding2(id, name) select id,name from schema2.sharding2                                          | success | schema1 |
      | conn_1 | False   | select * from test a inner join sharding_2_t1 b on a.name=b.name where a.id =1                                         | success | schema1 |
      | conn_1 | False   | select * from schema2.global2 a inner join sharding_2_t1 b on a.name=b.name where a.id =1                              | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join schema2.sing1 b on a.name=b.name where a.id =1                                | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 where name in (select name from schema2.sharding2 where id !=1)                            | success | schema1 |
      | conn_1 | False   | update test set name= '3' where name = (select name from schema2.global2 order by id desc limit 1)                     | success | schema1 |
      | conn_1 | False   | update test set name= '4' where name in (select name from schema2.global2 )                                            | success | schema1 |
      | conn_1 | False   | update sharding_2_t1 a,schema2.sharding2 b set a.name=b.name where a.id=2 and b.id=2                                   | success | schema1 |
      | conn_1 | False   | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding2 where sharding_2_t1.id=1 and schema2.sharding2.id =1 | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                                                                             | sql_type-2 | tx_id-3 | entry-4 | user-5 | source_host-6 | source_port-7 | rows-8 | examined_rows-9 |
      | 1        | insert into sharding_2_t1(id, name) select id,name from schema2.sharding2                                              | 1          | 1       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4               |
      | 2        | insert into test(id, name) select id,name from schema2.global2                                                         | 2          | 2       | 2       | test   | 172.100.9.8   | 8066          | 4      | 16              |
      | 3        | insert into schema2.sing1(id, name) select id,name from schema2.sing1                                                  | 3          | 3       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4               |
      | 4        | insert into schema2.sharding2(id, name) select id,name from schema2.sharding2                                          | 4          | 4       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4               |
      | 5        | select * from test a inner join sharding_2_t1 b on a.name=b.name where a.id =1                                         | 5          | 5       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4               |
      | 6        | select * from schema2.global2 a inner join sharding_2_t1 b on a.name=b.name where a.id =1                              | 6          | 6       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2               |
      | 7        | select * from sharding_2_t1 a inner join schema2.sing1 b on a.name=b.name where a.id =1                                | 7          | 7       | 2       | test   | 172.100.9.8   | 8066          | 4      | 10              |
      | 8        | select * from sharding_2_t1 where name in (select name from schema2.sharding2 where id !=1)                            | 8          | 8       | 2       | test   | 172.100.9.8   | 8066          | 6      | 11              |
      | 9        | update test set name= '3' where name = (select name from schema2.global2 order by id desc limit 1)                     | 9          | 9       | 2       | test   | 172.100.9.8   | 8066          | 2      | 8               |
      | 10       | update test set name= '4' where name in (select name from schema2.global2 )                                            | 10         | 10      | 2       | test   | 172.100.9.8   | 8066          | 6      | 24              |
      | 11       | update sharding_2_t1 a,schema2.sharding2 b set a.name=b.name where a.id=2 and b.id=2                                   | 11         | 11      | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 12       | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding2 where sharding_2_t1.id=1 and schema2.sharding2.id =1 | 12         | 12      | 2       | test   | 172.100.9.8   | 8066          | 2      | 2               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1         | 1           | 4               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 2         | 1           | 16              |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 3         | 1           | 4               |
      | 4       | 2       | test   | 172.100.9.8   | 8066          | 4         | 1           | 4               |
      | 5       | 2       | test   | 172.100.9.8   | 8066          | 5         | 1           | 4               |
      | 6       | 2       | test   | 172.100.9.8   | 8066          | 6         | 1           | 2               |
      | 7       | 2       | test   | 172.100.9.8   | 8066          | 7         | 1           | 10              |
      | 8       | 2       | test   | 172.100.9.8   | 8066          | 8         | 1           | 11              |
      | 9       | 2       | test   | 172.100.9.8   | 8066          | 9         | 1           | 8               |
      | 10      | 2       | test   | 172.100.9.8   | 8066          | 10        | 1           | 24              |
      | 11      | 2       | test   | 172.100.9.8   | 8066          | 11        | 1           | 0               |
      | 12      | 2       | test   | 172.100.9.8   | 8066          | 12        | 1           | 2               |

    #case mysql 8.0 shrdinguser   sql_id:13-24
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                               | expect  | db      |
      | test1 | 111111 | conn_2 | False   | drop table if exists no_sharding_t1                               | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists schema2.no_shar                              | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists sharding_2_t1                                | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists schema2.sharding2                            | success | schema1 |
      | test1 | 111111 | conn_2 | False   | create table no_sharding_t1(id int, name varchar(20),age int)     | success | schema1 |
      | test1 | 111111 | conn_2 | False   | create table sharding_2_t1(id int, name varchar(20),age int)      | success | schema1 |
      | test1 | 111111 | conn_2 | False   | create table schema2.no_shar(id int, name varchar(20),age int)    | success | schema1 |
      | test1 | 111111 | conn_2 | False   | create table schema2.sharding2(id int, name varchar(20),age int)  | success | schema1 |
      | test1 | 111111 | conn_2 | False   | insert into no_sharding_t1 values (1,'name1',1),(2,'name2',2)     | success | schema1 |
      | test1 | 111111 | conn_2 | False   | insert into sharding_2_t1 values (1,'name1',1),(2,'name2',2)      | success | schema1 |
      | test1 | 111111 | conn_2 | False   | insert into schema2.no_shar values (1,'name1',1),(2,'name2',2)    | success | schema1 |
      | test1 | 111111 | conn_2 | False   | insert into schema2.sharding2 values (1,'name1',1),(2,'name2',2)  | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | truncate dble_information.sql_log                     | success      | dble_information |
      | conn_0 | False   | truncate sql_log_by_tx_by_entry_by_user               | success      | dble_information |
      | conn_0 | False   | select * from sql_log                                 | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user          | length{(0)}  | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                                                                                           | expect  | db      |
      | test1 | 111111 | conn_2 | False   | insert into no_sharding_t1(id,name,age) select id,name,age from schema2.no_shar                                               | success | schema1 |
      | test1 | 111111 | conn_2 | False   | update no_sharding_t1 set name='test_name' where id in (select id from schema2.no_shar)                                       | success | schema1 |
      | test1 | 111111 | conn_2 | False   | update no_sharding_t1 set age=age+1 where name != (select name from schema2.no_shar where name ='name1')                      | success | schema1 |
      | test1 | 111111 | conn_2 | False   | select n.id,s.name from no_sharding_t1 n join schema2.no_shar s on n.id=s.id                                                  | success | schema1 |
      | test1 | 111111 | conn_2 | False   | select * from no_sharding_t1 where age <> (select age from schema2.no_shar where id !=1)                                      | success | schema1 |
      | test1 | 111111 | conn_2 | False   | delete from schema2.no_shar where name in ((select age from (select name,age from no_sharding_t1 order by id desc) as tmp))   | success | schema1 |

      | test1 | 111111 | conn_2 | False   | insert into sharding_2_t1 (id) select id from schema2.sharding2                                                              | success | schema1 |
      | test1 | 111111 | conn_2 | False   | update sharding_2_t1 a,schema2.sharding2 b set a.age=b.age+1 where a.id=2 and b.id=2                                         | success | schema1 |
      | test1 | 111111 | conn_2 | False   | select n.id,s.name from sharding_2_t1 n join schema2.sharding2 s on n.id=s.id                                                | success | schema1 |
      | test1 | 111111 | conn_2 | False   | select * from sharding_2_t1 where age <> (select age from schema2.sharding2 where id !=1)                                    | success | schema1 |
      | test1 | 111111 | conn_2 | False   | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding2 where sharding_2_t1.id=1 and schema2.sharding2.id =1       | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                                                                                  | sql_type-2 | tx_id-3 | entry-4 | user-5 | source_host-6 | source_port-7 | rows-8 | examined_rows-9 |
      | 25       | insert into no_sharding_t1(id,name,age) select id,name,age from schema2.no_shar                                             | 25         | 25      | 3       | test1  | 172.100.9.8   | 8066          | 2      | 2               |
      | 26       | update no_sharding_t1 set name='test_name' where id in (select id from schema2.no_shar)                                     | 26         | 26      | 3       | test1  | 172.100.9.8   | 8066          | 4      | 4               |
#      |     27 | update no_sharding_t1 set age=age+1 where name != (select name from schema2.no_shar where name ='name1')                      | 27         | 27      | 3       | test1  | 172.100.9.8   | 8066          | 4      | 4               |
      | 28       | select n.id,s.name from no_sharding_t1 n join schema2.no_shar s on n.id=s.id                                                | 28         | 28      | 3       | test1  | 172.100.9.8   | 8066          | 4      | 4               |
      | 29       | select * from no_sharding_t1 where age <> (select age from schema2.no_shar where id !=1)                                    | 29         | 29      | 3       | test1  | 172.100.9.8   | 8066          | 2      | 2               |
      | 30       | delete from schema2.no_shar where name in ((select age from (select name,age from no_sharding_t1 order by id desc) as tmp)) | 30         | 30      | 3       | test1  | 172.100.9.8   | 8066          | 0      | 0               |
      | 31       | insert into sharding_2_t1 (id) select id from schema2.sharding2                                                             | 31         | 31      | 3       | test1  | 172.100.9.8   | 8066          | 2      | 2               |
#     |     32  | update sharding_2_t1 a,schema2.sharding2 b set a.age=b.age+1 where a.id=2 and b.id=2                                        | 32       |    32 |     3 | test1 | 172.100.9.8 |        8066 |    2 |             2 |
      | 33       | select n.id,s.name from sharding_2_t1 n join schema2.sharding2 s on n.id=s.id                                               | 33         | 33      | 3       | test1  | 172.100.9.8   | 8066          | 4      | 4               |
      | 34       | select * from sharding_2_t1 where age <> (select age from schema2.sharding2 where id !=1)                                   | 34         | 34      | 3       | test1  | 172.100.9.8   | 8066          | 3      | 4               |
      | 35       | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding2 where sharding_2_t1.id=1 and schema2.sharding2.id =1      | 35         | 35      | 3       | test1  | 172.100.9.8   | 8066          | 2      | 2               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 25      | 3       | test1  | 172.100.9.8   | 8066          | 25        | 1           | 2               |
      | 26      | 3       | test1  | 172.100.9.8   | 8066          | 26        | 1           | 4               |
      | 27      | 3       | test1  | 172.100.9.8   | 8066          | 27        | 1           | 4               |
      | 28      | 3       | test1  | 172.100.9.8   | 8066          | 28        | 1           | 4               |
      | 29      | 3       | test1  | 172.100.9.8   | 8066          | 29        | 1           | 2               |
      | 30      | 3       | test1  | 172.100.9.8   | 8066          | 30        | 1           | 0               |
      | 31      | 3       | test1  | 172.100.9.8   | 8066          | 31        | 1           | 2               |
      | 32      | 3       | test1  | 172.100.9.8   | 8066          | 32        | 1           | 2               |
      | 33      | 3       | test1  | 172.100.9.8   | 8066          | 33        | 1           | 4               |
      | 34      | 3       | test1  | 172.100.9.8   | 8066          | 34        | 1           | 4               |
      | 35      | 3       | test1  | 172.100.9.8   | 8066          | 35        | 1           | 2               |

      # rwSplitUser sql_id:36-41
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table                           | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name varchar(20),age int)  | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values (1,'1',1),(2, '2',2)        | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table1                          | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table1(id int,name varchar(20),age int) | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table1 values (1,'1',1),(2, '2',2)       | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | truncate dble_information.sql_log                     | success      | dble_information |
      | conn_0 | False   | truncate sql_log_by_tx_by_entry_by_user               | success      | dble_information |
      | conn_0 | False   | select * from sql_log                                 | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user          | length{(0)}  | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                 | expect  | db      |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table(id,name,age) select id,name,age from test_table1                                             | success | schema1 |
      | rwS1 | 111111 | conn_3 | False   | update test_table set name='test_name' where id in (select id from test_table1 )                                    | success | schema1 |
      | rwS1 | 111111 | conn_3 | False   | update test_table a,test_table1 b set a.age=b.age+1 where a.id=2 and b.id=2                                         | success | schema1 |
      | rwS1 | 111111 | conn_3 | False   | select n.id,s.name from test_table n join test_table1 s on n.id=s.id                                                | success | schema1 |
      | rwS1 | 111111 | conn_3 | False   | select * from test_table where age <> (select age from test_table1 where id !=1)                                    | success | schema1 |
      | rwS1 | 111111 | conn_3 | False   | select * from test_table where age <> (select age from test_table1 where id !=1)                                    | success | schema1 |
      | rwS1 | 111111 | conn_3 | False   | delete test_table from test_table,test_table1 where test_table.id=1 and test_table1.id =1                           | success | schema1 |
      | rwS1 | 111111 | conn_3 | False   | delete from test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp)) | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                                                                          | sql_type-2 | tx_id-3 | entry-4 | user-5 | source_host-6 | source_port-7 | rows-8 | examined_rows-9 |
      | 42       | insert into test_table(id,name,age) select id,name,age from test_table1                                             | 42         | 42      | 4       | rwS1   | 172.100.9.8   | 8066          | 2      | 2               |
      | 43       | update test_table set name='test_name' where id in (select id from test_table1 )                                    | 43         | 43      | 4       | rwS1   | 172.100.9.8   | 8066          | 4      | 4               |
#      | 44       | update test_table a,test_table1 b set a.age=b.age+1 where a.id=2 and b.id=2                                         | 44         | 44      | 4       | rwS1   | 172.100.9.8   | 8066          | 2      | 2               |
      | 45       | select n.id,s.name from test_table n join test_table1 s on n.id=s.id                                                | 45         | 45      | 4       | rwS1   | 172.100.9.8   | 8066          | 4      | 4               |
      | 46       | select * from test_table where age <> (select age from test_table1 where id !=1)                                    | 46         | 46      | 4       | rwS1   | 172.100.9.8   | 8066          | 4      | 4               |
      | 47       | select * from test_table where age <> (select age from test_table1 where id !=1)                                    | 47         | 47      | 4       | rwS1   | 172.100.9.8   | 8066          | 4      | 4               |
      | 48       | delete test_table from test_table,test_table1 where test_table.id=1 and test_table1.id =1                           | 48         | 48      | 4       | rwS1   | 172.100.9.8   | 8066          | 2      | 2               |
      | 49       | delete from test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp)) | 49         | 49      | 4       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 42      | 4       | rwS1   | 172.100.9.8   | 8066          | 42        | 1           | 2               |
      | 43      | 4       | rwS1   | 172.100.9.8   | 8066          | 43        | 1           | 4               |
      | 44      | 4       | rwS1   | 172.100.9.8   | 8066          | 44        | 1           | 2               |
      | 45      | 4       | rwS1   | 172.100.9.8   | 8066          | 45        | 1           | 4               |
      | 46      | 4       | rwS1   | 172.100.9.8   | 8066          | 46        | 1           | 4               |
      | 47      | 4       | rwS1   | 172.100.9.8   | 8066          | 47        | 1           | 4               |
      | 48      | 4       | rwS1   | 172.100.9.8   | 8066          | 48        | 1           | 2               |
      | 49      | 4       | rwS1   | 172.100.9.8   | 8066          | 49        | 1           | 0               |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                  | expect  | db      |
      | conn_1 | False   | drop table if exists test                                                            | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                   | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.global2                                                 | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.sharding2                                               | success | schema1 |
      | conn_1 | true    | drop table if exists schema2.sing1                                                   | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                               | expect  | db      |
      | test1 | 111111 | conn_2 | False   | drop table if exists no_sharding_t1                               | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists schema2.no_shar                              | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists sharding_2_t1                                | success | schema1 |
      | test1 | 111111 | conn_2 | true    | drop table if exists schema2.sharding2                            | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | rwS1 | 111111 | conn_3 | true    | drop table if exists test_table                           | success | db1 |


  Scenario: test samplingRate=100 and sharding user hint sql  #6
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_1 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_1 | True     | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DsamplingRate/d
    /DtableSqlLogSize/d
    /# processor/a -DsamplingRate=100
    /# processor/a -DtableSqlLogSize=100
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "enable @@statistic"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                       | expect  | db      |
      | conn_1 | False    | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1                                    | success | schema1 |
      | conn_1 | False    | /*!dble:shardingNode=dn1*/ insert into sharding_4_t1 values(666, 'name666')               | success | schema1 |
      | conn_1 | False    | /*!dble:shardingNode=dn1*/ update sharding_4_t1 set name = 'dn1' where id=666             | success | schema1 |
      | conn_1 | True     | /*!dble:shardingNode=dn1*/ delete from sharding_4_t1 where id=666                         | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                                    | sql_type-2 | tx_id-3 | entry-4 | user-5 | source_host-6 | source_port-7 | rows-8 | examined_rows-9 |
      | 1        | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1                        | 1          | 1       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1               |
      | 2        | /*!dble:shardingNode=dn1*/ insert into sharding_4_t1 values(666, 'name666')   | 2          | 2       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1               |
      | 3        | /*!dble:shardingNode=dn1*/ update sharding_4_t1 set name = 'dn1' where id=666 | 3          | 3       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1               |
      | 4        | /*!dble:shardingNode=dn1*/ delete from sharding_4_t1 where id=666             | 4          | 4       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1               |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1         | 1           | 1               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 2         | 1           | 1               |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 3         | 1           | 1               |
      | 4       | 2       | test   | 172.100.9.8   | 8066          | 4         | 1           | 1               |


  Scenario: test samplingRate=100 and transaction sql  ---- shardinguser  #7
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_1 | False    | drop table if exists sharding_2_t1                                              | success | schema1 |
      | conn_1 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_1 | False    | create table sharding_2_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_1 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_1 | true     | insert into sharding_2_t1 values(1,'name1'),(2,'name2')                         | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DsamplingRate/d
    /DtableSqlLogSize/d
    /# processor/a -DsamplingRate=100
    /# processor/a -DtableSqlLogSize=100
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect      | db               |
      | conn_0 | False   | select * from sql_log                        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user | length{(0)} | dble_information |

   #case  begin ... commit
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | False    | begin                                                                           | success | schema1 |
      | conn_1 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_1 | False    | insert into sharding_4_t1 values(5,'name5')                                     | success | schema1 |
      | conn_1 | False    | commit                                                                          | success | schema1 |

      | conn_1 | False    | start transaction                                                               | success | schema1 |
      | conn_1 | False    | update sharding_4_t1 set name='dn2' where id=1                                  | success | schema1 |
      | conn_1 | False    | delete from sharding_4_t1 where id=5                                            | success | schema1 |
      | conn_1 | False    | update sharding_4_t1 set name='dn1' where id=100                                | success | schema1 |
      | conn_1 | False    | commit                                                                          | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                       | sql_type-2 | tx_id-3 | entry-4 | user-5 | source_host-6 | source_port-7 | rows-8 | examined_rows-9 |
      | 1        | begin                                            | 1          | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 2        | select * from sharding_4_t1                      | 2          | 1       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4               |
      | 3        | insert into sharding_4_t1 values(5,'name5')      | 3          | 1       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1               |
      | 4        | commit                                           | 4          | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 5        | start transaction                                | 5          | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 6        | update sharding_4_t1 set name='dn2' where id=1   | 6          | 2       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1               |
      | 7        | delete from sharding_4_t1 where id=5             | 7          | 2       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1               |
      | 8        | update sharding_4_t1 set name='dn1' where id=100 | 8          | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 9        | commit                                           | 9          | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1,2,3,4   | 4           | 5               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 5,6,7,8,9 | 5           | 2               |

    #case  begin ... rollback
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_2 | False    | begin                                                                           | success | schema1 |
      | conn_2 | False    | insert into sharding_4_t1 values(5,'name5'),(6,'name6')                         | success | schema1 |
      | conn_2 | False    | delete from sharding_4_t1 where id=6                                            | success | schema1 |
      | conn_2 | False    | rollback                                                                        | success | schema1 |

      | conn_2 | False    | start transaction                                                               | success | schema1 |
      | conn_2 | False    | select * from sharding_4_t1 where id=2                                          | success | schema1 |
      | conn_2 | False    | update sharding_4_t1 set name='dn4' where id=3                                  | success | schema1 |
      | conn_2 | False    | update sharding_4_t1 set name='dn1' where id=100                                | success | schema1 |
      | conn_2 | False    | rollback                                                                        | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                              | sql_type-2 | tx_id-3 | entry-4 | user-5 | source_host-6 | source_port-7 | rows-8 | examined_rows-9 |
      | 10       | begin                                                   | 10         | 3       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 11       | insert into sharding_4_t1 values(5,'name5'),(6,'name6') | 11         | 3       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2               |
      | 12       | delete from sharding_4_t1 where id=6                    | 12         | 3       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1               |
      | 13       | rollback                                                | 13         | 3       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 14       | start transaction                                       | 14         | 4       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 15       | select * from sharding_4_t1 where id=2                  | 15         | 4       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1               |
      | 16       | update sharding_4_t1 set name='dn4' where id=3          | 16         | 4       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1               |
      | 17       | update sharding_4_t1 set name='dn1' where id=100        | 17         | 4       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 18       | rollback                                                | 18         | 4       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5      | sql_count-6 | examined_rows-9 |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 10,11,12,13    | 4           | 3               |
      | 4       | 2       | test   | 172.100.9.8   | 8066          | 14,15,16,17,18 | 5           | 2               |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | truncate dble_information.sql_log                     | success      | dble_information |
      | conn_0 | False   | truncate sql_log_by_tx_by_entry_by_user               | success      | dble_information |
      | conn_0 | False   | select * from sql_log                                 | length{(0)}  | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user          | length{(0)}  | dble_information |

    #case  begin ... start transaction
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_2 | False    | start transaction                                                               | success | schema1 |
      | conn_2 | False    | delete from sharding_2_t1                                                       | success | schema1 |

      | conn_2 | False    | begin                                                                           | success | schema1 |
      | conn_2 | true     | delete from sharding_4_t1                                                       | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                | sql_type-2 | tx_id-3 | entry-4 | user-5 | source_host-6 | source_port-7 | rows-8 | examined_rows-9 |
      | 19       | start transaction         | 19         | 5       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 20       | delete from sharding_2_t1 | 20         | 5       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2               |
      | 21       | begin                     | 21         | 5       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 22       | begin                     | 22         | 5       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 23       | delete from sharding_4_t1 | 23         | 6       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4               |
      | 24       | exit                      | 24         | 6       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 5       | 2       | test   | 172.100.9.8   | 8066          | 19,20,21  | 3           | 2               |
      | 6       | 2       | test   | 172.100.9.8   | 8066          | 22,23,24  | 3           | 4               |

    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_3 | False    | set autocommit=0                                                                | success | schema1 |
      | conn_3 | False    | update sharding_4_t1 set name='test_name'                                       | success | schema1 |
      | conn_3 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_3 | False    | commit                                                                          | success | schema1 |

      | conn_3 | False    | delete from sharding_4_t1 where id in (3, 4)                                    | success | schema1 |
      | conn_3 | False    | insert into sharding_4_t1 values(3,'name3'),(4,'name4')                         | success | schema1 |
      | conn_3 | False    | rollback                                                                        | success | schema1 |

      | conn_3 | True     | delete from sharding_4_t1                                                       | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                              | sql_type-2 | tx_id-3 | entry-4 | user-5 | source_host-6 | source_port-7 | rows-8 | examined_rows-9 |
      | 1        | set autocommit=0                                        | 1          | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 2        | update sharding_4_t1 set name='test_name'               | 2          | 1       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4               |
      | 3        | select * from sharding_4_t1                             | 3          | 1       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4               |
      | 4        | commit                                                  | 4          | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 5        | commit                                                  | 5          | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 6        | delete from sharding_4_t1 where id in (3, 4)            | 6          | 2       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2               |
      | 7        | insert into sharding_4_t1 values(3,'name3'),(4,'name4') | 7          | 2       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2               |
      | 8        | rollback                                                | 8          | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 9        | rollback                                                | 9          | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
      | 10       | delete from sharding_4_t1                               | 10         | 3       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4               |
      | 11       | exit                                                    | 11         | 3       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0               |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1,2,3,4   | 4           | 8               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 5,6,7,8   | 4           | 4               |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 9,10,11   | 3           | 4               |

    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                             | expect  | db      |
      | conn_11 | False    | begin                                                                           | success | schema1 |
      | conn_11 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_11 | False    | insert into sharding_4_t1 values(5,'name5')                                     | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | select * from sql_log                                 | length{(0)}  | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user          | length{(0)}  | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                             | expect  | db      |
      | conn_12 | False    | start transaction                                                               | success | schema1 |
      | conn_12 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_12 | False    | insert into sharding_4_t1 values(5,'name5')                                     | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | select * from sql_log                                 | length{(0)}  | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user          | length{(0)}  | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                             | expect  | db      |
      | conn_6  | true     | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_6  | true     | drop table if exists sharding_2_t1                                              | success | schema1 |


 @skip_restart
  Scenario: test samplingRate=100 and transaction sql  ---- rwSplitUser  #8
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
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table                           | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name varchar(20),age int)  | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,'1',1),(2, '2',2)        | success | db1 |
      | rwS1 | 111111 | conn_4 | False   | drop table if exists test_table1                          | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | create table test_table1(id int,name varchar(20),age int) | success | db2 |
      | rwS1 | 111111 | conn_4 | true    | insert into test_table1 values (1,'1',1),(2, '2',2)       | success | db2 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DsamplingRate/d
    /DtableSqlLogSize/d
    /# processor/a -DsamplingRate=100
    /# processor/a -DtableSqlLogSize=100
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect      | db               |
      | conn_0 | False   | select * from sql_log                        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user | length{(0)} | dble_information |

    #case  begin ... commit
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                              | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | begin                                            | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | select * from test_table                         | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values(5,'name5',5)       | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | commit                                           | success | db1 |

      | rwS1 | 111111 | conn_4 | False   | start transaction                                  | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | update test_table1 set age =33 where id=1          | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | delete from test_table1 where id=5                 | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | update test_table1 set age =44 where id=100        | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | commit                                             | success | db2 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                  | sql_type-2 | tx_id-3 | entry-4 | user-5 | source_host-6 | source_port-7 | rows-8 | examined_rows-9 |
      | 1        | begin                                       | 1          | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |
      | 2        | select * from test_table                    | 2          | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 2      | 2               |
      | 3        | insert into test_table values(5,'name5',5)  | 3          | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1               |
      | 4        | commit                                      | 4          | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |
      | 5        | start transaction                           | 5          | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |
      | 6        | update test_table1 set age =33 where id=1   | 6          | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1               |
      | 7        | delete from test_table1 where id=5          | 7          | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |
      | 8        | update test_table1 set age =44 where id=100 | 8          | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |
      | 9        | commit                                      | 9          | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 1,2,3,4   | 4           | 3               |
      | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 5,6,7,8,9 | 5           | 1               |

    #case  begin ... rollback
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                      | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | begin                                                    | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values(5,'name5',5),(6,'name6',6) | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | delete from test_table where id=6                        | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | rollback                                                 | success | db1 |

      | rwS1 | 111111 | conn_4 | False   | start transaction                                        | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | select * from test_table1 where id=2                     | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | update test_table1 set age=age+1 where id=1              | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | update test_table1 set age=age*3 where id=2              | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | rollback                                                 | success | db2 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                               | sql_type-2 | tx_id-3 | entry-4 | user-5 | source_host-6 | source_port-7 | rows-8 | examined_rows-9 |
      | 10       | begin                                                    | 10         | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |
      | 11       | insert into test_table values(5,'name5',5),(6,'name6',6) | 11         | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 2      | 2               |
      | 12       | delete from test_table where id=6                        | 12         | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1               |
      | 13       | rollback                                                 | 13         | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |
      | 14       | start transaction                                        | 14         | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |
      | 15       | select * from test_table1 where id=2                     | 15         | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1               |
#      | 16       | update test_table1 set age=age+1 where id=1              | 16         | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1               |
      | 17       | update test_table1 set age=age*3 where id=2              | 17         | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1               |
      | 18       | rollback                                                 | 18         | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5      | sql_count-6 | examined_rows-9 |
      | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 10,11,12,13    | 4           | 3               |
      | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 14,15,16,17,18 | 5           | 3               |

    #case  begin ... start transaction
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose | sql                          | expect  | db  |
      | rwS1 | 111111 | conn_31 | False   | start transaction            | success | db1 |
      | rwS1 | 111111 | conn_31 | False   | delete from test_table       | success | db1 |

      | rwS1 | 111111 | conn_31 | False   | begin                        | success | db1 |
      | rwS1 | 111111 | conn_31 | true    | delete from db2.test_table   | success | db1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                       | sql_type-2 | tx_id-3 | entry-4 | user-5 | source_host-6 | source_port-7 | rows-8 | examined_rows-9 |
|     19 | start transaction                                        | 19       |     5 |     1 | rwS1 | 172.100.9.8 |        8066 |    0 |             0 |
|     20 | delete from test_table                                   | 20       |     5 |     1 | rwS1 | 172.100.9.8 |        8066 |    3 |             3 |
|     21 | begin                                                    | 21       |     5 |     1 | rwS1 | 172.100.9.8 |        8066 |    0 |             0 |
|     22 | delete from db2.test_table                               | 22       |     6 |     1 | rwS1 | 172.100.9.8 |        8066 |    1 |             1 |
|     23 | exit                                                     | 23       |     6 |     1 | rwS1 | 172.100.9.8 |        8066 |    0 |             0 |


    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
|     5 |     1 | rwS1 | 172.100.9.8 |        8066 | 19,20,21       |         3 |               3 |
|     6 |     1 | rwS1 | 172.100.9.8 |        8066 | 22,23          |         2 |              1 |


# @skip_restart
#  Scenario: test samplingRate=100 and xa transaction sql  ---- shardinguser  #9

# @skip_restart
#  Scenario: test samplingRate=100 and implict commit   #10



# @skip_restart
#  Scenario: test samplingRate=100 and error sql   #11


   Scenario: test samplingRate>0 and samplingRate<100   #12
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DsamplingRate/d
    /DtableSqlLogSize/d
    /# processor/a -DsamplingRate=40
    /# processor/a -DtableSqlLogSize=10
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | toClose | sql                                         | expect   | db      |
      | False   | drop table if exists test                   | success  | schema1 |
      | True    | create table test(id int,name varchar(20))  | success  | schema1 |
    Then connect "dble-1" to insert "10000" of data for "test"
    Given execute sql "500" times in "dble-1" at concurrent
      | sql                                | db      |
      | select name from test where id ={} | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect       | db               |
      | conn_0 | False   | select * from sql_log                        | length{(10)} | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user | length{(10)} | dble_information |

#    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
#    """
#    /DsamplingRate/d
#    /DtableSqlLogSize/d
#    /# processor/a -DsamplingRate=50
#    /# processor/a -DtableSqlLogSize=1000000
#    """
#    Given Restart dble in "dble-1" success
#    Given execute sql "10000" times in "dble-1" at concurrent
#      | sql                                | db      |
#      | select name from test where id ={} | schema1 |
#
#    Then execute sql in "dble-1" in "admin" mode
#      | conn   | toClose | sql                                          | expect         | db               |
#      | conn_0 | False   | select * from sql_log                        | length{(5000)} | dble_information |
#      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user | length{(5000)} | dble_information |














 @skip
  Scenario: reload @@samplingRate   #2
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

   # CASE TEST "disable @@statistic" and  "reload @@samplingRate"
    Then execute admin cmd "disable @@statistic"
#    Then execute admin cmd "reload @@samplingRate=0"
#
#   #case check dble_information.dble_variables
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_2"
#      | conn   | toClose | sql                     | db               |
#      | conn_0 | true    | select * from dble_information.dble_variables where variable_name in ('enableStatistic' ,'associateTablesByEntryByUserTableSize','tableByUserByEntryTableSize','frontendByBackendByEntryByUserTableSize')       | dble_information |
#    Then check resultset "version_2" has lines with following column values
#      | variable_name-0                         | variable_value-1 | comment-2                                                      | read_only-3 |
#      | enableStatistic                         | false            | Enable statistic sql, the default is false                     | false       |
#      | associateTablesByEntryByUserTableSize   | 1024             | AssociateTablesByEntryByUser table size, the default is 1024   | false       |
#      | frontendByBackendByEntryByUserTableSize | 1024             | FrontendByBackendByEntryByUser table size, the default is 1024 | false       |
#      | tableByUserByEntryTableSize             | 1024             | TableByUserByEntry table size, the default is 1024             | false       |
#
#



