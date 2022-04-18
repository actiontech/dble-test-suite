# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/7/14

Feature: test recordTxn in bootstrap.cnf - DBLE0REQ-853

  Scenario: check recordTxn #1
    Given delete file "/opt/dble/txlogs/server-tx.log" on "dble-1"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DrecordTxn=1
    """
    Then Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "record_rs1"
      | conn   | toClose | sql                                                                                             | db               |
      | conn_0 | true    | select variable_name, variable_value from dble_variables where variable_name like '%recordTxn%' | dble_information |
    Then check resultset "record_rs1" has lines with following column values
      | variable_name-0 | variable_value-1 |
      | recordTxn       | 1                |

    # check ddl
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_1 | false   | drop table if exists sharding_4_t1                               | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" in host "dble-1"
    """
    ConnID:3, XID:0
    [[]dn1[]]select 1;
    [[]dn2[]]select 1;
    [[]dn3[]]select 1;
    [[]dn4[]]select 1;
    [[]dn1[]]drop table if exists sharding_4_t1;
    [[]dn2[]]drop table if exists sharding_4_t1;
    [[]dn3[]]drop table if exists sharding_4_t1;
    [[]dn4[]]drop table if exists sharding_4_t1;
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_3_1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_1 | false   | create table sharding_4_t1(id int, age int)                      | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_3_1" in host "dble-1"
    """
    ConnID:3, XID:1
    [[]dn1[]]select 1;
    [[]dn2[]]select 1;
    [[]dn3[]]select 1;
    [[]dn4[]]select 1;
    [[]dn1[]]create table sharding_4_t1(id int, age int);
    [[]dn2[]]create table sharding_4_t1(id int, age int);
    [[]dn3[]]create table sharding_4_t1(id int, age int);
    [[]dn4[]]create table sharding_4_t1(id int, age int);
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_3_2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_1 | false   | alter table sharding_4_t1 add column name CHAR(15)               | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_3_2" in host "dble-1"
    """
    ConnID:3, XID:2
    [[]dn1[]]select 1;
    [[]dn2[]]select 1;
    [[]dn3[]]select 1;
    [[]dn4[]]select 1;
    [[]dn1[]]alter table sharding_4_t1 add column name CHAR(15);
    [[]dn2[]]alter table sharding_4_t1 add column name CHAR(15);
    [[]dn3[]]alter table sharding_4_t1 add column name CHAR(15);
    [[]dn4[]]alter table sharding_4_t1 add column name CHAR(15);
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_3_3"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_1 | false   | truncate table sharding_4_t1                                     | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_3_3" in host "dble-1"
    """
    ConnID:3, XID:3
    [[]dn1[]]select 1;
    [[]dn2[]]select 1;
    [[]dn3[]]select 1;
    [[]dn4[]]select 1;
    [[]dn1[]]truncate table sharding_4_t1;
    [[]dn2[]]truncate table sharding_4_t1;
    [[]dn3[]]truncate table sharding_4_t1;
    [[]dn4[]]truncate table sharding_4_t1;
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_3_4"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_1 | false   | create index my_index on sharding_4_t1 (id)                      | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_3_4" in host "dble-1"
    """
    ConnID:3, XID:4
    [[]dn1[]]select 1;
    [[]dn2[]]select 1;
    [[]dn3[]]select 1;
    [[]dn4[]]select 1;
    [[]dn1[]]create index my_index on sharding_4_t1 (id);
    [[]dn2[]]create index my_index on sharding_4_t1 (id);
    [[]dn3[]]create index my_index on sharding_4_t1 (id);
    [[]dn4[]]create index my_index on sharding_4_t1 (id);
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_3_5"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_1 | false   | drop index my_index on sharding_4_t1                             | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_3_5" in host "dble-1"
    """
    ConnID:3, XID:5
    [[]dn1[]]select 1;
    [[]dn2[]]select 1;
    [[]dn3[]]select 1;
    [[]dn4[]]select 1;
    [[]dn1[]]drop index my_index on sharding_4_t1;
    [[]dn2[]]drop index my_index on sharding_4_t1;
    [[]dn3[]]drop index my_index on sharding_4_t1;
    [[]dn4[]]drop index my_index on sharding_4_t1;
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_3_6"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_1 | false   | lock table sharding_4_t1 read                                    | success | schema1 |
      | conn_1 | false   | unlock tables                                                    | success | schema1 |
      | conn_1 | false   | create view test_view2 as select * from sharding_4_t1            | success | schema1 |
      | conn_1 | false   | drop view test_view2                                             | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_3_6" in host "dble-1"
    """
    ConnID:3, XID:6
    [[]dn1[]] LOCK TABLES sharding_4_t1 READ;
    [[]dn2[]] LOCK TABLES sharding_4_t1 READ;
    [[]dn3[]] LOCK TABLES sharding_4_t1 READ;
    [[]dn4[]] LOCK TABLES sharding_4_t1 READ;
    """
    Then check following text exist "N" in file "/opt/dble/txlogs/server-tx.log" after line "1og_3_6" in host "dble-1"
    """
    unlock tables;
    create view test_view2 as select * from sharding_4_t1;
    drop view test_view2;
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_3_7"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_1 | false   | drop table if exists no_sharding_t1                              | success | schema1 |
      | conn_1 | false   | create table no_sharding_t1(id int, age int)                     | success | schema1 |
      | conn_1 | false   | alter table no_sharding_t1 add column name CHAR(15)              | success | schema1 |
      | conn_1 | false   | truncate table no_sharding_t1                                    | success | schema1 |
      | conn_1 | false   | create index my_index on no_sharding_t1 (id)                     | success | schema1 |
      | conn_1 | false   | drop index my_index on no_sharding_t1                            | success | schema1 |
      | conn_1 | false   | lock table no_sharding_t1 read                                   | success | schema1 |
      | conn_1 | false   | unlock tables                                                    | success | schema1 |
      | conn_1 | false   | create view test_view as select * from no_sharding_t1            | success | schema1 |
      | conn_1 | true    | drop view test_view                                              | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_3_7" in host "dble-1"
    """
    ConnID:3, XID:13
    [[]dn5[]] LOCK TABLES no_sharding_t1 READ;
    """
    Then check following text exist "N" in file "/opt/dble/txlogs/server-tx.log" after line "1og_3_7" in host "dble-1"
    """
    drop table if exists no_sharding_t1;
    create table no_sharding_t1(id int, age int);
    alter table no_sharding_t1 add column name CHAR(15);
    truncate table no_sharding_t1;
    create index my_index on no_sharding_t1 (id);
    drop index my_index on no_sharding_t1;
    unlock tables;
    create view test_view as select * from no_sharding_t1;
    drop view test_view;
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_3_8"

  # check dml, dql
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                               | expect  | db      |
      | conn_2 | false   | insert into sharding_4_t1 values (1,10,11)                                                        | success | schema1 |
      | conn_2 | false   | update sharding_4_t1 set age=20 where id=1                                                        | success | schema1 |
      | conn_2 | false   | delete from sharding_4_t1 where id=1                                                              | success | schema1 |
      | conn_2 | false   | insert into sharding_4_t1 values (2,20,22),(3,30,33),(4,40,44),(5,50,55)                          | success | schema1 |
      | conn_2 | false   | update sharding_4_t1 set age=20 where id in (2, 3)                                                | success | schema1 |
      | conn_2 | false   | delete from sharding_4_t1                                                                         | success | schema1 |
      | conn_2 | false   | select * from sharding_4_t1 where id=3                                                            | success | schema1 |
      | conn_2 | false   | select * from sharding_4_t1                                                                       | success | schema1 |
      | conn_2 | false   | insert into no_sharding_t1 values (11,10,1)                                                       | success | schema1 |
      | conn_2 | false   | update no_sharding_t1 set age=20 where id=11                                                      | success | schema1 |
      | conn_2 | false   | delete from no_sharding_t1 where id=11                                                            | success | schema1 |
      | conn_2 | false   | insert into no_sharding_t1 values (12,20,2),(13,30,3),(14,40,4),(15,50,5)                         | success | schema1 |
      | conn_2 | false   | update no_sharding_t1 set age=20 where id in (11, 12)                                             | success | schema1 |
      | conn_2 | false   | delete from no_sharding_t1                                                                        | success | schema1 |
      | conn_2 | false   | select * from no_sharding_t1 where id=13                                                          | success | schema1 |
      | conn_2 | false   | select * from no_sharding_t1                                                                      | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "1og_3_8" in host "dble-1"
    """
    ConnID:4, XID:0
    [[]dn1[]]INSERT INTO sharding_4_t1
    VALUES (4, 40, 44);
    [[]dn2[]]INSERT INTO sharding_4_t1
    VALUES (5, 50, 55);
    [[]dn3[]]INSERT INTO sharding_4_t1
    VALUES (2, 20, 22);
    [[]dn4[]]INSERT INTO sharding_4_t1
    VALUES (3, 30, 33);
    ConnID:4, XID:1
    [[]dn3[]]update sharding_4_t1 set age=20 where id in (2, 3);
    [[]dn4[]]update sharding_4_t1 set age=20 where id in (2, 3);
    ConnID:4, XID:2
    [[]dn1[]]delete from sharding_4_t1;
    [[]dn2[]]delete from sharding_4_t1;
    [[]dn3[]]delete from sharding_4_t1;
    [[]dn4[]]delete from sharding_4_t1;
    """
    Then check following text exist "N" in file "/opt/dble/txlogs/server-tx.log" after line "1og_3_8" in host "dble-1"
    """
    VALUES (1, 10, 11)
    update sharding_4_t1 set age=20 where id=1
    delete from sharding_4_t1 where id=1
    select * from sharding_4_t1 where id=3
    select * from sharding_4_t1
    INSERT INTO no_sharding_t1
    VALUES (11, 10, 1)
    update no_sharding_t1 set age=20 where id=11
    delete from no_sharding_t1 where id=11
    INSERT INTO no_sharding_t1
    VALUES (12, 20, 2)
    VALUES (13, 30, 3)
    VALUES (14, 40, 4)
    VALUES (15, 50, 5)
    update no_sharding_t1 set age=20 where id in (11, 12)
    delete from no_sharding_t1
    select * from no_sharding_t1 where id=13
    select * from no_sharding_t1
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_2 | false   | drop table if exists sharding_4_t1                               | success | schema1 |
      | conn_2 | true    | drop table if exists no_sharding_t1                              | success | schema1 |


  Scenario: check recordTxn in transaction #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="sing1" shardingNode="dn1" />
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
    </schema>
    """
    Then execute admin cmd "reload @@config"

    Given delete file "/opt/dble/txlogs/server-tx.log" on "dble-1"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DrecordTxn=1
    """
    Then Restart dble in "dble-1" success

    # check ddl in transaction
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      | expect  | db      |
      | conn_3 | false   | begin                                                    | success | schema1 |
      | conn_3 | false   | drop table if exists test                                | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_1" in host "dble-1"
    """
    ConnID:2, XID:0
    begin
    [[]dn1[]]select 1;
    [[]dn2[]]select 1;
    [[]dn3[]]select 1;
    [[]dn4[]]select 1;
    [[]dn1[]]drop table if exists test;
    [[]dn2[]]drop table if exists test;
    [[]dn3[]]drop table if exists test;
    [[]dn4[]]drop table if exists test;
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;create table test(id int, age int)                      | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_2" in host "dble-1"
    """
    ConnID:2, XID:1
    begin
    [[]dn1[]]select 1;
    [[]dn2[]]select 1;
    [[]dn3[]]select 1;
    [[]dn4[]]select 1;
    [[]dn1[]]create table test(id int, age int);
    [[]dn2[]]create table test(id int, age int);
    [[]dn3[]]create table test(id int, age int);
    [[]dn4[]]create table test(id int, age int);
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_3"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;alter table test add column name CHAR(15)               | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_3" in host "dble-1"
    """
    ConnID:2, XID:2
    begin
    [[]dn1[]]select 1;
    [[]dn2[]]select 1;
    [[]dn3[]]select 1;
    [[]dn4[]]select 1;
    [[]dn1[]]alter table test add column name CHAR(15);
    [[]dn2[]]alter table test add column name CHAR(15);
    [[]dn3[]]alter table test add column name CHAR(15);
    [[]dn4[]]alter table test add column name CHAR(15);
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_4"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;truncate table test                                     | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_4" in host "dble-1"
    """
    ConnID:2, XID:3
    begin
    [[]dn1[]]select 1;
    [[]dn2[]]select 1;
    [[]dn3[]]select 1;
    [[]dn4[]]select 1;
    [[]dn1[]]truncate table test;
    [[]dn2[]]truncate table test;
    [[]dn3[]]truncate table test;
    [[]dn4[]]truncate table test;
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_5"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;create index my_index_1 on test (id);rollback           | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_5" in host "dble-1"
    """
    ConnID:2, XID:4
    begin
    [[]dn1[]]select 1;
    [[]dn2[]]select 1;
    [[]dn3[]]select 1;
    [[]dn4[]]select 1;
    [[]dn1[]]CREATE INDEX my_index_1 ON test (id);
    [[]dn2[]]CREATE INDEX my_index_1 ON test (id);
    [[]dn3[]]CREATE INDEX my_index_1 ON test (id);
    [[]dn4[]]CREATE INDEX my_index_1 ON test (id);
    """
    Then check following text exist "N" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_5" in host "dble-1"
    """
    ConnID:2, XID:5
    rollback
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_6"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;drop index my_index_1 on test;commit                    | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_6" in host "dble-1"
    """
    ConnID:2, XID:6
    begin
    [[]dn1[]]select 1;
    [[]dn2[]]select 1;
    [[]dn3[]]select 1;
    [[]dn4[]]select 1;
    [[]dn1[]]DROP INDEX my_index_1 ON test;
    [[]dn2[]]DROP INDEX my_index_1 ON test;
    [[]dn3[]]DROP INDEX my_index_1 ON test;
    [[]dn4[]]DROP INDEX my_index_1 ON test;
    """
    Then check following text exist "N" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_6" in host "dble-1"
    """
    ConnID:2, XID:7
    commit
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_7"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;drop table if exists sing1                              | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_7" in host "dble-1"
    """
    ConnID:2, XID:8
    begin
    [[]dn1[]]drop table if exists sing1
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_8"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;create table sing1(id int, age int)                     | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_8" in host "dble-1"
    """
    ConnID:2, XID:9
    begin
    [[]dn1[]]create table sing1(id int, age int)
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_9"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;alter table sing1 add column name CHAR(15)              | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_9" in host "dble-1"
    """
    ConnID:2, XID:10
    begin
    [[]dn1[]]alter table sing1 add column name CHAR(15)
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_10"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;truncate table sing1;commit                             | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_10" in host "dble-1"
    """
    ConnID:2, XID:11
    begin
    [[]dn1[]]TRUNCATE TABLE sing1
    """
    Then check following text exist "N" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_10" in host "dble-1"
    """
    ConnID:2, XID:12
    commit
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_11"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;create index my_index_2 on sing1 (id);rollback          | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_11" in host "dble-1"
    """
    ConnID:2, XID:13
    begin
    [[]dn1[]]CREATE INDEX my_index_2 ON sing1 (id)
    """
    Then check following text exist "N" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_11" in host "dble-1"
    """
    ConnID:2, XID:14
    rollback
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_12"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;drop index my_index_2 on sing1                          | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_12" in host "dble-1"
    """
    ConnID:2, XID:15
    begin
    [[]dn1[]]drop index my_index_2 on sing1
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_13"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;lock tables test read                                   | success | schema1 |
      | conn_3 | false   | begin;unlock tables;commit                                    | success | schema1 |
      | conn_3 | false   | begin;create view test_view1 as select * from test            | success | schema1 |
      | conn_3 | false   | begin;drop view test_view1                                    | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_13" in host "dble-1"
    """
    ConnID:2, XID:16
    begin
    [[]dn1[]] LOCK TABLES test READ;
    [[]dn2[]] LOCK TABLES test READ;
    [[]dn3[]] LOCK TABLES test READ;
    [[]dn4[]] LOCK TABLES test READ;
    ConnID:2, XID:17
    ConnID:2, XID:18
    ConnID:2, XID:19
    """
    Then check following text exist "N" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_13" in host "dble-1"
    """
    unlock tables;
    create view test_view1 as select * from test;
    drop view test_view1;
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_5_14"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_3 | false   | begin;lock tables sing1 read                                  | success | schema1 |
      | conn_3 | false   | begin;unlock tables;commit                                    | success | schema1 |
      | conn_3 | false   | begin;create view test_view2 as select * from sing1           | success | schema1 |
      | conn_3 | true    | begin;drop view test_view2                                    | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_14" in host "dble-1"
    """
    ConnID:2, XID:20
    begin
    [[]dn1[]] LOCK TABLES sing1 READ;
    ConnID:2, XID:21
    ConnID:2, XID:22
    ConnID:2, XID:23
    """
    Then check following text exist "N" in file "/opt/dble/txlogs/server-tx.log" after line "log_5_14" in host "dble-1"
    """
    unlock tables;
    create view test_view2 as select * from sing1;
    drop view test_view2;
    """

    # check dml, dql in transaction
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_6_1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                        | expect  | db      |
      | conn_4 | false   | begin;insert into test values (1,10,11);commit                                             | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_6_1" in host "dble-1"
    """
    ConnID:3, XID:0
    begin
    [[]dn1[]]INSERT INTO test
    VALUES (1, 10, 11);
    [[]dn2[]]INSERT INTO test
    [[]dn3[]]INSERT INTO test
    [[]dn4[]]INSERT INTO test
    commit
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_6_2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                        | expect  | db      |
      | conn_4 | false   | begin;update test set age=20 where id=1;commit;                                            | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_6_2" in host "dble-1"
    """
    ConnID:3, XID:1
    begin
    [[]dn1[]]UPDATE test
    SET age = 20
    WHERE id = 1;
    [[]dn2[]]UPDATE test
    [[]dn3[]]UPDATE test
    [[]dn4[]]UPDATE test
    commit
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_6_3"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                        | expect  | db      |
      | conn_4 | false   | begin;delete from test where id=1;commit;                                                  | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_6_3" in host "dble-1"
    """
    ConnID:3, XID:2
    begin
    [[]dn1[]]DELETE FROM test
    WHERE id = 1;
    [[]dn2[]]DELETE FROM test
    [[]dn3[]]DELETE FROM test
    [[]dn4[]]DELETE FROM test
    commit
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_6_4"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                        | expect  | db      |
      | conn_4 | false   | begin;select * from test where id=3;commit;                                                | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_6_4" in host "dble-1"
    """
    ConnID:3, XID:3
    begin
    commit
    """
    Then check following text exist "N" in file "/opt/dble/txlogs/server-tx.log" after line "log_6_4" in host "dble-1"
    """
    select * from test where id = 3
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_6_5"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                        | expect  | db      |
      | conn_4 | false   | begin;insert into sing1 values (11,10,1),(12,20,2);commit;                                 | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_6_5" in host "dble-1"
    """
    ConnID:3, XID:4
    begin
    [[]dn1[]]INSERT INTO sing1
    VALUES (11, 10, 1),
    (12, 20, 2)
    commit
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_6_6"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                        | expect  | db      |
      | conn_4 | false   | begin;update sing1 set age=20;commit;                                                      | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_6_6" in host "dble-1"
    """
    ConnID:3, XID:5
    begin
    [[]dn1[]]UPDATE sing1
    SET age = 20
    commit
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_6_7"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                        | expect  | db      |
      | conn_4 | false   | begin;delete from sing1 where id=11;commit;                                                | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_6_7" in host "dble-1"
    """
    ConnID:3, XID:6
    begin
    [[]dn1[]]DELETE FROM sing1
    WHERE id = 11
    commit
    """
    Given record current dble log "/opt/dble/txlogs/server-tx.log" line number in "log_6_8"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                        | expect  | db      |
      | conn_4 | false   | begin;select * from sing1 where id=12;commit;                                              | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/txlogs/server-tx.log" after line "log_6_8" in host "dble-1"
    """
    ConnID:3, XID:7
    begin
    commit
    """
    Then check following text exist "N" in file "/opt/dble/txlogs/server-tx.log" after line "log_6_8" in host "dble-1"
    """
    select * from sing1 where id = 12
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_4 | false   | drop table if exists test                                        | success | schema1 |
      | conn_4 | true    | drop table if exists sing1                                       | success | schema1 |