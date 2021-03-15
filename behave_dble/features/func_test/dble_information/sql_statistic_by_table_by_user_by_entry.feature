# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2021/2/24

Feature:test sql_statistic_by_table_by_user_by_entry


   Scenario: sql_statistic_by_table_by_user_by_entry   #1
    #CASE PREPARE env
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema2">
        <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn4" />
        <singleTable name="sing1" shardingNode="dn1" />
        <shardingTable name="test2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
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
    Then execute admin cmd "enable @@statistic"

    #do query create data
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists sing1                                                              | success | schema2 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                       | success | schema1 |
      | conn_2 | False   | create table test1 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table test2 (id int,name char(20))                                               | success | schema2 |
      | conn_2 | False   | create table sing1 (id int,name char(20))                                               | success | schema2 |
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
      | rwS2 | 111111 | conn_4 | False   | drop table if exists test_table               | success | db2 |
      | rwS2 | 111111 | conn_4 | False   | create table test_table(id int,name char(20)) | success | db2 |
      | rwS2 | 111111 | conn_4 | False   | insert into test_table values (1,2)           | success | db2 |
      | rwS2 | 111111 | conn_4 | true    | select 2                                      | success | db2 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect       | db               |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(10)} | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | False   | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.test          | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 2                  | 2                           | 2                  |
      | 2       | test   | schema1.sharding_4_t1 | 1                  | 2                 | 0                  | 0                 | 0                  | 0                 | 4                  | 8                           | 4                  |
      | 2       | test   | schema1.sharding_2_t1 | 1                  | 2                 | 0                  | 0                 | 0                  | 0                 | 2                  | 5                           | 2                  |
      | 2       | test   | schema2.test1         | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 2                  | 2                           | 2                  |
      | 2       | test   | null                  | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 2                  | 2                           | 2                  |
      | 2       | test   | schema2.test2         | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 2                  | 5                           | 2                  |
      | 3       | rwS1   | db1.test_table        | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                           | 0                  |
      | 3       | rwS1   | null                  | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 1                           | 1                  |
      | 4       | rwS2   | null                  | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 1                           | 1                  |
      | 4       | rwS2   | db2.test_table        | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                           | 0                  |
    #case test "user"
    Given delete the following xml segment
      | file        | parent           | child                    |
      | user.xml    | {'tag':'root'}   | {'tag':'managerUser'}    |
      | user.xml    | {'tag':'root'}   | {'tag':'shardingUser'}   |
      | user.xml    | {'tag':'root'}   | {'tag':'rwSplitUser'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test1" password="111111" schemas="schema1,schema2,schema3"/>
    <rwSplitUser name="rwS3" password="111111" dbGroup="ha_group3" />
    <rwSplitUser name="rwS4" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS3  | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS3  | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS3  | 111111 | conn_3 | False   | insert into test_table values (1,2)           | success | db1 |
      | rwS3  | 111111 | conn_3 | true    | select 2                                      | success | db1 |
      | rwS4  | 111111 | conn_4 | False   | drop table if exists test_table               | success | db2 |
      | rwS4  | 111111 | conn_4 | False   | create table test_table(id int,name char(20)) | success | db2 |
      | rwS4  | 111111 | conn_4 | False   | insert into test_table values (1,2)           | success | db2 |
      | rwS4  | 111111 | conn_4 | true    | select 2                                      | success | db2 |
      | test1 | 111111 | conn_5 | False   | drop table if exists test_table               | success | schema1 |
      | test1 | 111111 | conn_5 | False   | create table test_table(id int,name char(20)) | success | schema1 |
      | test1 | 111111 | conn_5 | False   | insert into test_table values (1,2)           | success | schema1 |
      | test1 | 111111 | conn_5 | true    | select 2                                      | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect       | db               |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(16)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | False   | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test1  | null                  | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 1                           | 1                  |
      | 2       | test1  | schema1.test_table    | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                           | 0                  |
      | 2       | test   | schema1.test          | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 2                  | 2                           | 2                  |
      | 2       | test   | schema1.sharding_4_t1 | 1                  | 2                 | 0                  | 0                 | 0                  | 0                 | 4                  | 8                           | 4                  |
      | 2       | test   | schema1.sharding_2_t1 | 1                  | 2                 | 0                  | 0                 | 0                  | 0                 | 2                  | 5                           | 2                  |
      | 2       | test   | schema2.test1         | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 2                  | 2                           | 2                  |
      | 2       | test   | schema2.test2         | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 2                  | 5                           | 2                  |
      | 2       | test   | null                  | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 2                  | 2                           | 2                  |
      | 3       | rwS3   | db1.test_table        | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                           | 0                  |
      | 3       | rwS3   | null                  | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 1                           | 1                  |
      | 3       | rwS1   | db1.test_table        | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                           | 0                  |
      | 3       | rwS1   | null                  | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 1                           | 1                  |
      | 4       | rwS4   | null                  | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 1                           | 1                  |
      | 4       | rwS2   | null                  | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 1                           | 1                  |
      | 4       | rwS2   | db2.test_table        | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                           | 0                  |
      | 4       | rwS4   | db2.test_table        | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                           | 0                  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect       | db               |
      | conn_0 | False   | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry limit 10      | length{(10)}       | dble_information |
      | conn_0 | False   | truncate table sql_statistic_by_table_by_user_by_entry              | success      | dble_information |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry               | length{(0)}  | dble_information |

    #case test "table" about view
    Given delete the following xml segment
      | file        | parent           | child                    |
      | user.xml    | {'tag':'root'}   | {'tag':'managerUser'}    |
      | user.xml    | {'tag':'root'}   | {'tag':'shardingUser'}   |
      | user.xml    | {'tag':'root'}   | {'tag':'rwSplitUser'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config"
     Then  execute sql in "dble-1" in "user" mode
       | conn   | toClose  | sql                                           | expect    | db      |
       | conn_0 | False    | drop view if exists schema1.view_test         | success   | schema1 |
       | conn_0 | False    | create view view_test as select * from test   | success   | schema1 |
       | conn_0 | true     | select * from schema1.view_test               | success   | schema1 |
       | conn_0 | true     | drop view view_test                           | success   | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | False   | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2           | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.view_test | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 1                           | 1                  |

    #case select table1 join table1,check "sql_select_count"
    Then  execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                      | expect    | db      |
      | conn_1 | False    | select * from test a join test b on a.name=b.name where a.id =1          | success   | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | False   | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2           | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.test      | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 1                           | 1                  |
    Then  execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                         | expect    | db      |
      | conn_1 | False    | select * from sharding_4_t1 a join sharding_4_t1 b on a.name=b.name         | success   | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | False   | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2                    | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.sharding_4_t1      | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 4                           | 2                  |

    #complex sql todo:add more case
   Then  execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                         | expect    | db      |
      | conn_1 | False    | insert into sharding_4_t1 values (3,3),(4,4),(5,5),(6,6)                    | success   | schema1 |
      | conn_1 | False    | select * from sharding_4_t1 a join sharding_4_t1 b on a.name=b.name         | success   | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | False   | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2                    | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.sharding_4_t1      | 1                  | 4                 | 0                  | 0                 | 0                  | 0                 | 2                  | 16                           | 8                  |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                      | expect       | db               |
      | conn_0 | False   | truncate table dble_information.sql_statistic_by_table_by_user_by_entry  | success      | dble_information |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry                    | length{(0)}  | dble_information |

    #case check "singtable"  insert delete update select  "count" "rows"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | expect  | db      |
      | conn_2 | False   | insert into sing1 values (1,1)                    | success | schema2 |
      | conn_2 | False   | insert into sing1 values (2,2)                    | success | schema2 |
      | conn_2 | False   | insert into sing1 values (3,3)                    | success | schema2 |
      | conn_2 | False   | insert into sing1 values (4,4)                    | success | schema2 |
      | conn_2 | False   | insert into sing1 values (1,1),(2,null)           | success | schema2 |
      | conn_2 | False   | insert into sing1 values (1,1),(2,null),(3,'a')   | success | schema2 |
      | conn_2 | False   | select * from sing1                               | success | schema2 |
      | conn_2 | False   | select * from sing1 where id =66                  | success | schema2 |
      | conn_2 | False   | select * from sing1 where id =1                   | success | schema2 |
      | conn_2 | False   | update sing1 set id=5 where id =1                 | success | schema2 |
      | conn_2 | False   | update sing1 set name='a' where id =3             | success | schema2 |
      | conn_2 | False   | update sing1 set name='b' where name ='4'         | success | schema2 |
      | conn_2 | False   | delete from sing1 where id =3                     | success | schema2 |
      | conn_2 | False   | delete from sing1 where id =4                     | success | schema2 |
      | conn_2 | true    | delete from sing1 where name ='b'                 | success | schema2 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | true    | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2        | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema2.sing1  | 6                  | 9                 | 3                  | 5                 | 3                  | 3                 | 3                  | 12                          | 12                 |

    #case check "globaltable"  insert delete update select  "count" "rows"
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  | db      |
      | conn_2 | False   | insert into test values (1,1)                    | success | schema1 |
      | conn_2 | False   | insert into test values (2,2)                    | success | schema1 |
      | conn_2 | False   | insert into test values (3,3)                    | success | schema1 |
      | conn_2 | False   | insert into test values (4,4)                    | success | schema1 |
      | conn_2 | False   | insert into test values (1,1),(2,null)           | success | schema1 |
      | conn_2 | False   | insert into test values (1,1),(2,null),(3,'a')   | success | schema1 |
      | conn_2 | False   | select * from test                               | success | schema1 |
      | conn_2 | False   | select * from test where id =66                  | success | schema1 |
      | conn_2 | False   | select * from test where id =1                   | success | schema1 |
      | conn_2 | False   | update test set id=5 where id =1                 | success | schema1 |
      | conn_2 | False   | update test set name='a' where id =3             | success | schema1 |
      | conn_2 | False   | update test set name='b' where name ='4'         | success | schema1 |
      | conn_2 | False   | delete from test where id =3                     | success | schema1 |
      | conn_2 | False   | delete from test where id =4                     | success | schema1 |
      | conn_2 | true    | delete from test where name ='b'                 | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | true    | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2      | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.test | 6                  | 9                 | 3                  | 6                 | 3                  | 3                 | 3                  | 14                          | 14                 |

    #case check "shardingtable"  insert delete update select  "count" "rows"
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect  | db      |
      | conn_2 | False   | insert into sharding_4_t1 values (1,1)                    | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values (2,2)                    | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values (3,3)                    | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values (4,4)                    | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values (1,1),(2,null)           | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values (1,1),(2,null),(3,'a')   | success | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                               | success | schema1 |
      | conn_2 | False   | select * from sharding_4_t1 where id =66                  | success | schema1 |
      | conn_2 | False   | select * from sharding_4_t1 where id =1                   | success | schema1 |
      | conn_2 | False   | update sharding_4_t1 set name='a' where id =3             | success | schema1 |
      | conn_2 | False   | update sharding_4_t1 set name='b' where name ='4'         | success | schema1 |
      | conn_2 | False   | delete from sharding_4_t1 where id =3                     | success | schema1 |
      | conn_2 | False   | delete from sharding_4_t1 where id =4                     | success | schema1 |
      | conn_2 | true    | delete from sharding_4_t1 where name ='b'                 | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | true    | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.sharding_4_t1 | 6                  | 9                 | 2                  | 4                 | 3                  | 5                 | 3                  | 19                          | 19                 |

    #case check "noshardingtable"  insert delete update select  "count" "rows"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_2 | False   | drop table if exists noshard                        | success | schema1 |
      | conn_2 | False   | create table noshard (id int,name char(20))         | success | schema1 |
      | conn_2 | False   | insert into noshard values (1,1)                    | success | schema1 |
      | conn_2 | False   | insert into noshard values (2,2)                    | success | schema1 |
      | conn_2 | False   | insert into noshard values (3,3)                    | success | schema1 |
      | conn_2 | False   | insert into noshard values (4,4)                    | success | schema1 |
      | conn_2 | False   | insert into noshard values (1,1),(2,null)           | success | schema1 |
      | conn_2 | False   | insert into noshard values (1,1),(2,null),(3,'a')   | success | schema1 |
      | conn_2 | False   | select * from noshard                               | success | schema1 |
      | conn_2 | False   | select * from noshard where id =66                  | success | schema1 |
      | conn_2 | False   | select * from noshard where id =1                   | success | schema1 |
      | conn_2 | False   | update noshard set id=5 where id =1                 | success | schema1 |
      | conn_2 | False   | update noshard set name='a' where id =3             | success | schema1 |
      | conn_2 | False   | update noshard set name='b' where name ='4'         | success | schema1 |
      | conn_2 | False   | delete from noshard where id =3                     | success | schema1 |
      | conn_2 | False   | delete from noshard where id =4                     | success | schema1 |
      | conn_2 | true    | delete from noshard where name ='b'                 | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | true    | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2         | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.noshard | 6                  | 9                 | 3                  | 5                 | 3                  | 3                 | 3                  | 12                          | 12                 |

    #case check "vertical table"  insert delete update select  "count" "rows"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                  | expect  | db      |
      | conn_2 | False   | drop table if exists vertical                        | success | schema3 |
      | conn_2 | False   | create table vertical (id int,name char(20))         | success | schema3 |
      | conn_2 | False   | insert into vertical values (1,1)                    | success | schema3 |
      | conn_2 | False   | insert into vertical values (2,2)                    | success | schema3 |
      | conn_2 | False   | insert into vertical values (3,3)                    | success | schema3 |
      | conn_2 | False   | insert into vertical values (4,4)                    | success | schema3 |
      | conn_2 | False   | insert into vertical values (1,1),(2,null)           | success | schema3 |
      | conn_2 | False   | insert into vertical values (1,1),(2,null),(3,'a')   | success | schema3 |
      | conn_2 | False   | select * from vertical                               | success | schema3 |
      | conn_2 | False   | select * from vertical where id =66                  | success | schema3 |
      | conn_2 | False   | select * from vertical where id =1                   | success | schema3 |
      | conn_2 | False   | update vertical set id=5 where id =1                 | success | schema3 |
      | conn_2 | False   | update vertical set name='a' where id =3             | success | schema3 |
      | conn_2 | False   | update vertical set name='b' where name ='4'         | success | schema3 |
      | conn_2 | False   | delete from vertical where id =3                     | success | schema3 |
      | conn_2 | False   | delete from vertical where id =4                     | success | schema3 |
      | conn_2 | true    | delete from vertical where name ='b'                 | success | schema3 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | true    | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2          | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema3.vertical | 6                  | 9                 | 3                  | 5                 | 3                  | 3                 | 3                  | 12                          | 12                 |

    #case check "rwSplitUser"  insert delete update select  "count" "rows"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values (2,2)           | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | delete from test_table where id =1            | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | select * from test_table where id =1          | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | select * from test_table where id =22         | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | select * from test_table                      | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | update test_table set id=10 where id=1        | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | update test_table set id=10 where id=2        | success | db1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | true    | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2         | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 3       | rwS1   | db1.test_table  | 1                  | 1                 | 2                  | 1                 | 1                  | 1                 | 3                  | 1                           | 1                  |

     #case test "table" about "drop table",don't affect the result
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_2 | true    | drop table if exists vertical                | success | schema3 |
      | conn_2 | true    | drop table if exists sing1                   | success | schema2 |
      | conn_2 | False   | drop table if exists test                    | success | schema1 |
      | conn_2 | False   | drop table if exists sharding_4_t1           | success | schema1 |
      | conn_2 | true    | drop table if exists noshard                 | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                     | expect  | db  |
      | rwS1 | 111111 | conn_3 | true    | drop table if exists test_table         | success | db1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | true    | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.noshard       | 6                  | 9                 | 3                  | 5                 | 3                  | 3                 | 3                  | 12                          | 12                 |
      | 2       | test   | schema2.sing1         | 6                  | 9                 | 3                  | 5                 | 3                  | 3                 | 3                  | 12                          | 12                 |
      | 2       | test   | schema1.test          | 6                  | 9                 | 3                  | 6                 | 3                  | 3                 | 3                  | 14                          | 14                 |
      | 2       | test   | schema1.sharding_4_t1 | 6                  | 9                 | 2                  | 4                 | 3                  | 5                 | 3                  | 19                          | 19                 |
      | 2       | test   | schema3.vertical      | 6                  | 9                 | 3                  | 5                 | 3                  | 3                 | 3                  | 12                          | 12                 |
      | 3       | rwS1   | db1.test_table        | 1                  | 1                 | 2                  | 1                 | 1                  | 1                 | 3                  | 1                           | 1                  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                  | expect                             | db      |
      | conn_2 | true    | insert into vertical values (3,3)                    | Table 'db1.vertical' doesn't exist | schema3 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | true    | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2          | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema3.vertical | 7                  | 9                 | 3                  | 5                 | 3                  | 3                 | 3                  | 12                          | 12                 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect       | db               |
      | conn_0 | False   | truncate table sql_statistic_by_table_by_user_by_entry              | success      | dble_information |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry               | length{(0)}  | dble_information |

    #case transaction
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                  | expect  | db      |
      | conn_1 | False   | begin                                                | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1),(2,2)         | success | schema1 |
      | conn_1 | true    | rollback                                             | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | true    | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.sharding_2_t1 | 1                  | 2                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                           | 0                  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                  | expect  | db      |
      | conn_1 | False   | begin                                                | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,1),(2,2)         | success | schema1 |
      | conn_1 | true    | commit                                               | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | true    | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.sharding_2_t1 | 2                  | 4                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                           | 0                  |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect  | db      |
      | conn_1 | False   | set autocommit=0                    | success | schema1 |
      | conn_1 | False   | set xa=on                           | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1         | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | true    | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.sharding_2_t1 | 2                  | 4                 | 0                  | 0                 | 0                  | 0                 | 1                  | 4                           | 4                  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect  | db      |
      | conn_1 | False   | set autocommit=1                    | success | schema1 |
      | conn_1 | False   | set xa=off                          | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | true    | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.sharding_2_t1 | 2                  | 4                 | 0                  | 0                 | 0                  | 0                 | 1                  | 4                           | 4                  |



    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect       | db               |
      | conn_0 | False   | truncate table sql_statistic_by_table_by_user_by_entry              | success      | dble_information |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry               | length{(0)}  | dble_information |

    Then execute admin cmd "reload @@statistic_table_size = 4 where table ='sql_statistic_by_table_by_user_by_entry'"

    #case Syntax error sql will not be counted --shardinguser
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect    | db      |
      | conn_1 | False   | SELECT DATABASE()                    | success   | schema1 |
      | conn_1 | False   | SELECT USER()                        | success   | schema1 |
      | conn_1 | False   | SELECT 1                             | success   | schema1 |
      | conn_1 | False   | SELECT 2                             | success   | schema1 |
      # to general.log check has none
      | conn_1 | true    | show tables                          | success   | schema1 |
      # "use schema" implicitly sent "SELECT DATABASE() "
      | conn_1 | False   | use schema1                          | success                               | schema1 |
      | conn_1 | False   | use schema66                         | Unknown database 'schema66'           | schema1 |
      # to general.log check has "select user"
      | conn_1 | False   | select user                          | Unknown column 'user' in 'field list' | schema1 |
      #case "explain"/"explain2"
      | conn_1 | False   | explain select * from sharding_2_t1                          | success | schema1 |
      | conn_1 | False   | explain2 select * from sharding_2_t1                         | success | schema1 |

    #case Syntax error sql will not be counted --rwSplitUser
     Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                   | expect                               | db  |
      | rwS1 | 111111 | conn_3 | true    | use db11                              | Unknown database 'db11'              | db1 |
      | rwS1 | 111111 | conn_3 | true    | delete from test_table where id =1    | Table 'db1.test_table' doesn't exist | db1 |
      | rwS1 | 111111 | conn_3 | true    | select * froom test_table where id =1 | error in your SQL syntax             | db1 |
      | rwS1 | 111111 | conn_3 | true    | explain select * from  test_table     | success                              | db2 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | False   | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2 | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | null    | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 5                  | 2                           | 4                  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect       | db               |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(1)}  | dble_information |
      | conn_0 | False   | truncate table sql_statistic_by_table_by_user_by_entry              | success      | dble_information |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry               | length{(0)}  | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect                                | db      |
      #case schema1 has default shardingnode table test100-103 would sent to "dn5"
      | conn_1 | False   | select * from test100                 | Table 'db3.test100' doesn't exist      | schema1 |
      | conn_1 | False   | insert into test101 values (1)        | Table 'db3.test101' doesn't exist      | schema1 |
      | conn_1 | False   | delete from test102                   | Table 'db3.test102' doesn't exist      | schema1 |
      | conn_1 | true    | update test103 set id =2 where id =1  | Table 'db3.test103' doesn't exist      | schema1 |
      #case schema2 has not default shardingnode
      | conn_2 | False   | select * from test1000                | Table 'schema2.test1000' doesn't exist | schema2 |
      | conn_2 | False   | insert into test1001 values (1)       | Table 'schema2.test1001' doesn't exist | schema2 |
      | conn_2 | False   | delete from test1002                  | Table 'schema2.test1002' doesn't exist | schema2 |
      | conn_2 | true    | update test1003 set id =2 where id =1 | Table 'schema2.test1003' doesn't exist | schema2 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | False   | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_examined_rows,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | entry-0 | user-1 | table-2         | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | schema1.test103 | 0                  | 0                 | 1                  | 0                 | 0                  | 0                 | 0                  | 0                           | 0                  |
      | 2       | test   | schema1.test100 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 0                           | 0                  |
      | 2       | test   | schema1.test101 | 1                  | 0                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                           | 0                  |
      | 2       | test   | schema1.test102 | 0                  | 0                 | 0                  | 0                 | 1                  | 0                 | 0                  | 0                           | 0                  |
    Then check resultset "resulte_1" has not lines with following column values
      | entry-0 | user-1 | table-2 | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_examined_rows-10 | sql_select_rows-11 |
      | 2       | test   | null    | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 5                  | 2                           | 4                  |


    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect       | db               |
      | conn_0 | False   | select * from sql_statistic_by_table_by_user_by_entry               | length{(4)}  | dble_information |
      | conn_0 | False   | truncate table sql_statistic_by_table_by_user_by_entry              | success      | dble_information |
      | conn_0 | true    | select * from sql_statistic_by_table_by_user_by_entry               | length{(0)}  | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                      | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                               | success | schema1 |
      | conn_1 | true    | drop table if exists sharding_2_t1                                                      | success | schema1 |
      | conn_2 | False   | drop table if exists test1                                                              | success | schema2 |
      | conn_2 | False   | drop table if exists test2                                                              | success | schema2 |
      | conn_2 | true    | drop table if exists sing1                                                              | success | schema2 |
