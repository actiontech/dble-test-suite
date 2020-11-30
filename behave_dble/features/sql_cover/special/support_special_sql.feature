# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/9/24
  Feature: support special sql

   Scenario: can support special sql like when when two sharding_table inner join select DATEDIFF()   #1
#case https://github.com/actiontech/dble/issues/1913
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_2_t2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                              | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1                                                                               | success | schema1 |
      | conn_0 | False   | drop table if exists sharding_2_t2                                                                               | success | schema1 |
      | conn_0 | False   | CREATE TABLE sharding_2_t1 (id int(11),APPLY_TIME DATE,CREAT_TIME DATETIME)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 | success | schema1 |
      | conn_0 | False   | CREATE TABLE sharding_2_t2 (id int(11),APPLY_TIME DATE)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4                     | success | schema1 |
      | conn_0 | False   | INSERT INTO sharding_2_t1  (id,APPLY_TIME,CREAT_TIME) VALUES (1,'2020-07-08','2020-07-01 21:34:50')              | success | schema1 |
      | conn_0 | False   | INSERT INTO sharding_2_t2  (id,APPLY_TIME) VALUES (1,'2020-07-08')                                               | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "7A"
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_0 | False   | SELECT tb.id,tb.APPLY_TIME,tb.CREAT_TIME,CURDATE(),DATEDIFF(tb.APPLY_TIME, CURDATE()) T1,DATEDIFF(tb.APPLY_TIME, NOW()) T2,DATEDIFF('2020-07-08', '2020-07-02') T3,DATEDIFF(tb.CREAT_TIME, CURDATE()) T4 FROM sharding_2_t1 tb INNER JOIN sharding_2_t2 tb1 ON tb.APPLY_TIME=tb1.APPLY_TIME WHERE tb1.APPLY_TIME='2020-07-08'           | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "7B"
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_0 | False   | SELECT tb.id,tb.APPLY_TIME,tb.CREAT_TIME,CURDATE(),DATEDIFF(tb.APPLY_TIME, CURDATE()) T1,DATEDIFF(tb.APPLY_TIME, NOW()) T2,DATEDIFF('2020-07-08', '2020-07-02') T3,DATEDIFF(tb.CREAT_TIME, CURDATE()) T4 FROM sharding_2_t1 tb WHERE tb.id=1           | success | schema1 |
    Then check resultsets "7A" and "7B" are same in following columns
      | column     | column_index |
      | id         | 0            |
      | APPLY_TIME | 1            |
      | CREAT_TIME | 2            |
      | CURDATE()  | 3            |
      | T1         | 4            |
      | T2         | 5            |
      | T3         | 6            |
      | T4         | 7            |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1        | success | schema1 |
      | conn_0 | true    | drop table if exists sharding_2_t2        | success | schema1 |


   Scenario: Query result is incorrect when the regexp is used in where condition  #2
#case from github:1385
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn1" />
    <schema name="schema3" sqlMaxLimit="100" shardingNode="dn2" />
    <schema name="schema2" sqlMaxLimit="100" shardingNode="dn3" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                | expect  | db      |
      | conn_0 | False   | drop table if exists table_a                                       | success | schema1 |
      | conn_0 | False   | create table table_a(id int,goods_id varchar(40),city varchar(40)) | success | schema1 |
      | conn_0 | False   | insert into table_a values(1,"goods","city")                       | success | schema1 |
      | conn_1 | False   | drop table if exists table_b                                       | success | schema2 |
      | conn_1 | False   | create table table_b(id int,goods_id varchar(40))                  | success | schema2 |
      | conn_1 | False   | insert into table_b values(2,"goods")                              | success | schema2 |
      | conn_1 | False   | drop table if exists table_c                                       | success | schema2 |
      | conn_1 | False   | create table table_c(id int,city varchar(50),wid int)              | success | schema2 |
      | conn_1 | False   | insert into table_c values(3,"city",4)                             | success | schema2 |
      | conn_2 | False   | drop table if exists table_d                                       | success | schema3 |
      | conn_2 | False   | create table table_d(id int,name varchar(100))                     | success | schema3 |
      | conn_2 | False   | insert into table_d values(4,"12345AAA")                           | success | schema3 |
  Given execute single sql in "dble-1" in "user" mode and save resultset in "A"
      | conn   | toClose | sql   | db |
      | conn_0 | False   | select dg.id aaaa, dgw.id bbbb, ew.id cccc from schema1.table_a dgw inner join schema2.table_b dg on dgw.goods_id = dg.goods_id left join schema2.table_c dwp on dgw.city = dwp.city left join schema3.table_d ew on ew.id = dwp.wid where dgw.id = 1 and ew.name regexp 'AAA'     | schema1 |
    Then check resultset "A" has lines with following column values
      | aaaa-0 | bbbb-1 | cccc-2 |
      | 2      | 1      | 4      |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | expect  | db      |
      | conn_0 | true    | drop table if exists table_a            | success | schema1 |
      | conn_1 | False   | drop table if exists table_b            | success | schema2 |
      | conn_1 | true    | drop table if exists table_c            | success | schema2 |
      | conn_2 | true    | drop table if exists table_d            | success | schema3 |

# join query with ambiguous columns success but expect not case from github:1330
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                         | expect                                 | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1                                          | success                                | schema1 |
      | conn_0 | False   | drop table if exists sharding_3_t1                                          | success                                | schema1 |
      | conn_0 | False   | create table sharding_2_t1(id int, name char(20), age int)                  | success                                | schema1 |
      | conn_0 | False   | create table sharding_3_t1(id int)                                          | success                                | schema1 |
      | conn_0 | False   | insert into sharding_2_t1 values(1,null,1),(2,'',2),(3,'a',3)               | success                                | schema1 |
      | conn_0 | False   | insert into sharding_3_t1 values(1),(5),(3)                                 | success                                | schema1 |
      | conn_0 | False   | select id, name from sharding_2_t1 a, sharding_3_t1 b where a.id > b.id     | Column 'id' in field list is ambiguous | schema1 |
      | conn_0 | False   | select b.id, a.name from sharding_2_t1 a, sharding_3_t1 b where a.id > b.id | success                                | schema1 |
      | conn_0 | False   | drop table if exists sharding_2_t1                                          | success                                | schema1 |
      | conn_0 | true    | drop table if exists sharding_3_t1                                          | success                                | schema1 |