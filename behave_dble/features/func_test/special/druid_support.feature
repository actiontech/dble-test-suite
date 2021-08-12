# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/8/3

# DBLE0REQ-1040
Feature: druid upgrade from 1.2.3 to 1.2.6

  Scenario: check getEngine #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <singleTable name="single_t1"  shardingNode="dn1" />
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                             | expect  | db      |
      | conn_1 | False   | drop table if exists no_sharding_t1;drop table if exists no_sharding_t2         | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_4_t1;drop table if exists sharding_4_t2           | success | schema1 |
      | conn_1 | False   | drop table if exists single_t1;drop table if exists test                        | success | schema1 |
      | conn_1 | False   | create table no_sharding_t1 (id int, name varchar(20))                          | success | schema1 |
      | conn_1 | False   | create table no_sharding_t2(id int, name varchar(20)) engine=innodb             | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1 (id int, name varchar(20))                           | success | schema1 |
      | conn_1 | False   | create table sharding_4_t2(id int, name varchar(20)) ENGINE=InnoDB              | success | schema1 |
      | conn_1 | False   | create table single_t1(id int, name varchar(20)) ENGINE=InnoDB                  | success | schema1 |
      | conn_1 | False   | create table test(id int, name varchar(20)) engine=innodb                       | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_4_t1;drop table if exists sharding_4_t2           | success | schema1 |
      | conn_1 | False   | drop table if exists no_sharding_t1;drop table if exists no_sharding_t2         | success | schema1 |
      | conn_1 | False   | drop table if exists single_t1;drop table if exists test                        | success | schema1 |
      | conn_1 | False   | drop table if exists test                                                       | success | schema1 |
      | conn_1 | False   | create table single_t1(id int, name varchar(20)) ENGINE=MyISAM                  | success | schema1 |
      | conn_1 | False   | create table no_sharding_t1(id int, name varchar(20)) ENGINE=PERFORMANCE_SCHEMA | Invalid performance_schema usage. | schema1 |
      | conn_1 | True    | drop table if exists no_sharding_t1;drop table if exists single_t1              | success | schema1 |

    Given execute linux command in "dble-1" and contains exception "create table only can use ENGINE InnoDB, others not supported:CREATE TABLE sharding_4_t1"
    """
    mysql -P8066 -utest -h172.100.9.1 -Dschema1 -e "create table sharding_4_t1(id int, name varchar(20)) ENGINE=MyISAM"
    """
    Given execute linux command in "dble-1" and contains exception "create table only can use ENGINE InnoDB, others not supported:CREATE TABLE test"
    """
    mysql -P8066 -utest -h172.100.9.1 -Dschema1 -e "create table test(id int, name varchar(20)) ENGINE=PERFORMANCE_SCHEMA"
    """


  Scenario: check [CONSTRAINT [symbol]] CHECK (expr) [[NOT] ENFORCED] - mysql8.0 #2
    Given delete the following xml segment
      | file          | parent           | child                   |
      | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.9:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
     </dbGroup>
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.10:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
     </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                            | expect                                               | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                             | success                                              | schema1 |
      | conn_1 | False   | drop table if exists no_sharding_t1                            | success                                              | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,first_name varchar(20),last_name varchar(20),age int,sex char(1) check(sex='F' or sex='M'), constraint name_ck check(first_name<>last_name) not enforced,constraint `age_ck` check (age>=16 and age<65) enforced) engine=innodb default charset=utf8 | success | schema1 |
      | conn_1 | False   | show create table sharding_4_t1             | hasStr{CONSTRAINT `age_ck` CHECK (((`age` >= 16) and (`age` < 65)))},hasStr{CONSTRAINT `name_ck` CHECK ((`first_name` <> `last_name`))},hasStr{CONSTRAINT `sharding_4_t1_chk_1` CHECK (((`sex` = _latin1'F') or (`sex` = _latin1'M')))}  | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1, 'first', 'last', 10, 'm')  | Check constraint 'age_ck' is violated.               | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1, 'first', 'last', 20, 'a')  | Check constraint 'sharding_4_t1_chk_1' is violated.  | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1, 'name', 'name', 20, 'm')   | success                                              | schema1 |
      | conn_1 | False   | alter table sharding_4_t1 add constraint id_ck_1 check(id>0)   | success                                              | schema1 |
      | conn_1 | False   | show create table sharding_4_t1                                | hasStr{CONSTRAINT `id_ck_1` CHECK ((`id` > 0))}      | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(0, 'first', 'last', 20, 'm')  | Check constraint 'id_ck_1' is violated.              | schema1 |
      | conn_1 | False   | create table no_sharding_t1(check (first_name!=last_name),id int,first_name varchar(20),last_name varchar(20),salary int,CONSTRAINT id_ck_1 CHECK (id>0) not enforced,constraint salary_ck_1 check (salary<1000000) enforced) | success | schema1 |
      | conn_1 | False   | insert into no_sharding_t1 values(1, 'first', 'first', 100000) | Check constraint 'no_sharding_t1_chk_1' is violated. | schema1 |
      | conn_1 | False   | insert into no_sharding_t1 values(1, 'first', 'last', 1000000) | Check constraint 'salary_ck_1' is violated.          | schema1 |
      | conn_1 | False   | insert into no_sharding_t1 values(0, 'first', 'last', 999999)  | success                                              | schema1 |
      | conn_1 | False   | insert into no_sharding_t1 values(1, 'first', 'last', 999999)  | success                                              | schema1 |
      | conn_1 | False   | drop table if exists sharding_4_t1                             | success                                              | schema1 |
      | conn_1 | True    | drop table if exists no_sharding_t1                            | success                                              | schema1 |


  Scenario: check select FOR SHARE/SKIP LOCKED - mysql8.0 #3
    Given delete the following xml segment
      | file          | parent           | child                   |
      | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.9:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
     </dbGroup>
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.10:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
     </dbGroup>
     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <singleTable name="single_t1"  shardingNode="dn1" />
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    #single table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_1 | False   | drop table if exists single_t1                      | success | schema1 |
      | conn_1 | False   | create table single_t1(id int,name varchar(20))     | success | schema1 |
      | conn_1 | False   | insert into single_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
      | conn_1 | False   | select * from single_t1 where id=1 for share        | has{((1,'1'))} | schema1 |
      | conn_2 | False   | select * from single_t1                             | has{((1,'1'),(2,'2'),(3,'3'),(4,'4'))} | schema1 |
      | conn_2 | False   | update single_t1 set name=22 where id=2             | success | schema1 |
      | conn_1 | False   | begin                                               | success | schema1 |
      | conn_1 | False   | select * from single_t1 where id=1 for share        | has{((1,'1'))} | schema1 |
      | conn_2 | False   | select * from single_t1                             | has{((1,'1'),(2,'22'),(3,'3'),(4,'4'))} | schema1 |
      | conn_2 | False   | update single_t1 set name=11 where id=1             | Lock wait timeout exceeded; try restarting transaction | schema1 |
      | conn_2 | False   | delete from single_t1 where id=1                    | Lock wait timeout exceeded; try restarting transaction | schema1 |
      | conn_1 | False   | commit                                              | success | schema1 |
      | conn_2 | False   | update single_t1 set name=11 where id=1             | success | schema1 |
      | conn_2 | False   | delete from single_t1 where id=1                    | success | schema1 |
      | conn_1 | False   | set autocommit=0                                    | success | schema1 |
      | conn_1 | False   | select * from single_t1 where id=2 for share        | has{((2,'22'))} | schema1 |
      | conn_2 | False   | begin                                               | success | schema1 |
      #DBLE0REQ-1191
      | conn_2 | False   | select * from single_t1 where id in (2,3) for share skip locked | druid not support sql syntax, the reason is sql syntax error, no terminated. IDENTIFIER | schema1 |
      | conn_3 | False   | begin                                               | success | schema1 |
      | conn_3 | False   | select * from single_t1 where id in (2,3) for share | has{((2,'22'),(3,'3'))} | schema1 |
      | conn_3 | False   | commit                                              | success | schema1 |
      | conn_3 | True    | update single_t1 set name=33 where id=3             | Lock wait timeout exceeded; try restarting transaction | schema1 |
      | conn_1 | True    | rollback                                            | success | schema1 |
      | conn_2 | True    | rollback                                            | success | schema1 |
    #sharding table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                 | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                  | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(20))                 | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4),(5,5),(6,6) | success | schema1 |
      | conn_1 | False   | select * from sharding_4_t1 where id in(1,2) for share              | has{((1,'1'),(2,'2'))} | schema1 |
      | conn_1 | False   | select * from sharding_4_t1 where id in(1,2) for share skip locked  | druid not support sql syntax, the reason is sql syntax error, no terminated. IDENTIFIER | schema1 |
      | conn_1 | False   | select * from sharding_4_t1 where id in(1,2) for share nowait       | druid not support sql syntax, the reason is sql syntax error, no terminated. IDENTIFIER | schema1 |
      | conn_1 | False   | begin                                                               | success | schema1 |
      | conn_1 | False   | select * from sharding_4_t1 where id in (1,2) for share             | has{((1,'1'),(2,'2'))} | schema1 |
      | conn_2 | False   | set autocommit=0                                                    | success | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                                         | has{((1,'1'),(2,'2'),(3,'3'),(4,'4'),(5,'5'),(6,'6'))} | schema1 |
      | conn_2 | False   | update sharding_4_t1 set name=33 where id=3                         | success | schema1 |
      | conn_2 | False   | update sharding_4_t1 set name=55 where id=5                         | Lock wait timeout exceeded; try restarting transaction | schema1 |
      | conn_2 | False   | rollback                                                            | success | schema1 |
      | conn_2 | False   | begin                                                               | success | schema1 |
      | conn_2 | False   | delete from sharding_4_t1 where id=2                                | Lock wait timeout exceeded; try restarting transaction | schema1 |
      | conn_3 | False   | set autocommit=0                                                    | success | schema1 |
      | conn_3 | False   | select * from sharding_4_t1 where id=2 or id=3 for share skip locked | druid not support sql syntax, the reason is sql syntax error, no terminated. IDENTIFIER | schema1 |
      | conn_3 | False   | update sharding_4_t1 set name=3 where id=3                          | success | schema1 |
      | conn_3 | True    | rollback                                                            | success | schema1 |
      | conn_2 | True    | rollback                                                            | success | schema1 |
      | conn_1 | True    | rollback                                                            | success | schema1 |
    #global table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect  | db      |
      | conn_1 | False   | drop table if exists test                                  | success | schema1 |
      | conn_1 | False   | create table test(id int,name varchar(20))                 | success | schema1 |
      | conn_1 | False   | insert into test values(1,1),(2,2),(3,3),(4,4),(5,5),(6,6) | success | schema1 |
      | conn_1 | False   | select * from test where id in(1,2) for share              | has{((1,'1'),(2,'2'))} | schema1 |
      | conn_1 | False   | select * from test where id in(1,2) for share skip locked  | druid not support sql syntax, the reason is sql syntax error, no terminated. IDENTIFIER | schema1 |
      | conn_1 | False   | select * from test where id in(1,2) for share nowait       | druid not support sql syntax, the reason is sql syntax error, no terminated. IDENTIFIER | schema1 |
      | conn_1 | False   | begin                                                      | success | schema1 |
      | conn_1 | False   | select * from test where id in (1,2) for share             | has{((1,'1'),(2,'2'))} | schema1 |
      | conn_2 | False   | set autocommit=0                                           | success | schema1 |
      | conn_2 | False   | select * from test                                         | has{((1,'1'),(2,'2'),(3,'3'),(4,'4'),(5,'5'),(6,'6'))} | schema1 |
      | conn_2 | False   | update test set name=33 where id=3                         | Lock wait timeout exceeded; try restarting transaction | schema1 |
      | conn_2 | False   | rollback                                                   | success | schema1 |
      | conn_2 | False   | begin                                                      | success | schema1 |
      | conn_2 | False   | delete from test where id=2                                | Lock wait timeout exceeded; try restarting transaction | schema1 |
      | conn_3 | False   | set autocommit=0                                           | success | schema1 |
      | conn_3 | False   | select * from test where id=2 or id=3 for share skip locked | druid not support sql syntax, the reason is sql syntax error, no terminated. IDENTIFIER | schema1 |
      | conn_3 | False   | update test set name=3 where id=3                         | Lock wait timeout exceeded; try restarting transaction | schema1 |
      | conn_3 | False   | rollback                                                  | success | schema1 |
      | conn_2 | False   | rollback                                                  | success | schema1 |
      | conn_1 | False   | rollback                                                  | success | schema1 |
      | conn_3 | True    | drop table if exists test                                 | success | schema1 |
      | conn_2 | True    | drop table if exists sharding_4_t1                        | success | schema1 |
      | conn_1 | True    | drop table if exists single_t1                            | success | schema1 |


  Scenario: complex query #4
    Given delete the following xml segment
      | file          | parent           | child                   |
      | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.9:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
     </dbGroup>
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.10:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
     </dbGroup>
     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                  | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1;drop table if exists sharding_4_t2                | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(20),age int)                          | success | schema1 |
      | conn_1 | False   | create table sharding_4_t2(id int,age int)                                           | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1,1),(2,2,12),(3,3,35),(4,4,43),(5,5,56),(6,6,69) | success | schema1 |
      | conn_1 | False   | begin                                                                                | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t2 select id,age from sharding_4_t1 where age>18 for share    | success | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                                                          | has{((1,'1',1),(2,'2',12),(3,'3',35),(4,'4',43),(5,'5',56),(6,'6',69))} | schema1 |
      | conn_2 | False   | update sharding_4_t1 set age=20 where age<18                                         | Lock wait timeout exceeded; try restarting transaction | schema1 |
      | conn_2 | False   | update sharding_4_t1 set age=20 where age>50                                         | Lock wait timeout exceeded; try restarting transaction | schema1 |
      | conn_1 | True    | commit                                                                               | success | schema1 |
      | conn_2 | False   | select * from sharding_4_t2                                                          | has{((3,35),(4,43),(5,56),(6,69),)} | schema1 |
      | conn_2 | False   | update sharding_4_t1 set age=35 where age>18                                         | success | schema1 |
      | conn_2 | True    | select * from sharding_4_t2                                                          | has{((3,35),(4,43),(5,56),(6,69),)} | schema1 |
      | conn_3 | False   | set autocommit=0                                                                     | success | schema1 |
      # DBLE0REQ-1207
#      | conn_3 | False   | select sharding_4_t1.id,sharding_4_t1.age from sharding_4_t1 join sharding_4_t2 on sharding_4_t1.id=sharding_4_t2.id where sharding_4_t1.age>20 for share of sharding_4_t1 for share of sharding_4_t2 | success | schema1 |
      | conn_3 | False   | select sharding_4_t1.id,sharding_4_t1.age from sharding_4_t1 join sharding_4_t2 on sharding_4_t1.id=sharding_4_t2.id where sharding_4_t1.age>20 for share | has{((3,35),(4,35),(5,35),(6,35),)} | schema1 |
      | conn_4 | False   | select * from sharding_4_t1                                                          | has{((1,'1',1),(2,'2',12),(3,'3',35),(4,'4',35),(5,'5',35),(6,'6',35),)} | schema1 |
      | conn_4 | False   | select * from sharding_4_t2                                                          | has{((3,35),(4,43),(5,56),(6,69),)} | schema1 |
#      | conn_4 | False   | update sharding_4_t1 set age=30 where age<15                                         | Lock wait timeout exceeded; try restarting transaction | schema1 |
#      | conn_4 | False   | delete from sharding_4_t2 where id=4                                                 | Lock wait timeout exceeded; try restarting transaction | schema1 |
      | conn_4 | False   | update sharding_4_t1 set age=30 where age<15                                         | success | schema1 |
      | conn_4 | False   | delete from sharding_4_t2 where id=4                                                 | success | schema1 |
      | conn_4 | False   | begin                                                                                | success | schema1 |
      | conn_4 | False   | select * from sharding_4_t1 where id in (1,3) for share skip locked                  | druid not support sql syntax, the reason is sql syntax error, no terminated. IDENTIFIER | schema1 |
      | conn_4 | False   | select * from sharding_4_t2 where id=3 for share skip locked                         | druid not support sql syntax, the reason is sql syntax error, no terminated. IDENTIFIER | schema1 |
      | conn_3 | False   | commit                                                                               | success | schema1 |
      | conn_3 | False   | select * from sharding_4_t1                                                          | has{((1,'1',30),(2,'2',30),(3,'3',35),(4,'4',35),(5,'5',35),(6,'6',35),)} | schema1 |
      | conn_3 | False   | select * from sharding_4_t2                                                          | has{((3,35),(5,56),(6,69),)} | schema1 |
      | conn_3 | False   | update sharding_4_t1 set name='Jeo' where id=1                                       | success | schema1 |
      | conn_3 | False   | update sharding_4_t1 set name='Jeo' where id=3                                       | success | schema1 |
      | conn_3 | False   | delete from sharding_4_t2 where id=3                                                 | success | schema1 |
      | conn_4 | False   | commit                                                                               | success | schema1 |
      | conn_4 | False   | update sharding_4_t1 set name='Jeo' where id=3                                       | Lock wait timeout exceeded; try restarting transaction | schema1 |
      | conn_3 | True    | drop table if exists sharding_4_t1                                                   | success | schema1 |
      | conn_4 | True    | drop table if exists sharding_4_t2                                                   | success | schema1 |


  Scenario: check limit #5
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                              | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1;drop table if exists test                                     | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(20),age int)                                      | success | schema1 |
      | conn_1 | False   | create table test(id int,age int)                                                                | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1,1),(2,2,12),(3,3,35),(4,4,43),(5,5,56),(6,6,69)             | success | schema1 |
      | conn_1 | False   | insert into test values(1,11),(2,22),(3,33),(4,44),(5,55),(6,66)                                 | success | schema1 |
      | conn_1 | False   | select * from sharding_4_t1 order by id limit 2                                                  | has{((1,'1',1),(2,'2',12))} | schema1 |
      | conn_1 | False   | select * from sharding_4_t1 order by id limit 2                                                  | has{((1,'1',1),(2,'2',12))} | schema1 |
      | conn_1 | False   | select * from sharding_4_t1 order by name limit 3,5                                              | has{((4,'4',43),(5,'5',56),(6,'6',69))} | schema1 |
      | conn_1 | False   | select t1.* from sharding_4_t1 t1 join test t2 on t1.id=t2.id order by t1.name limit 1,2         | has{((2,'2',12),(3,'3',35))} | schema1 |
      | conn_1 | False   | select t2.* from sharding_4_t1 t1,test t2 where t1.id=t2.id and t2.age>40 order by t1.id limit 1 | has{((4,44),)} | schema1 |
      | conn_1 | True    | select * from sharding_4_t1 limit 0                                                              | success | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test" password="111111" schemas="schema1" blacklist="blacklist1"/>
      <blacklist name="blacklist1">
        <property name="limitZeroAllow">false</property>
      </blacklist>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                              | expect  | db      |
      | conn_2 | False   | select t1.* from sharding_4_t1 t1 join test t2 on t1.id=t2.id order by t1.name limit 0           | Intercepted by suspected configuration [limitZeroAllow] in the blacklist of user 'test', so it is considered unsafe SQL | schema1 |
      | conn_2 | False   | select t2.* from sharding_4_t1 t1,test t2 where t1.id=t2.id and t2.age>40 order by t1.id limit 0 | Intercepted by suspected configuration [limitZeroAllow] in the blacklist of user 'test', so it is considered unsafe SQL | schema1 |
      | conn_2 | True    | select * from sharding_4_t1 limit 0                                                              | Intercepted by suspected configuration [limitZeroAllow] in the blacklist of user 'test', so it is considered unsafe SQL | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test" password="111111" schemas="schema1" blacklist="blacklist1"/>
      <blacklist name="blacklist1">
        <property name="limitZeroAllow">true</property>
      </blacklist>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_blacklist_1"
      | conn   | toClose | sql                                                       | db               |
      | conn_0 | True    | select * from dble_blacklist where user_configured='true' | dble_information |
    Then check resultset "dble_blacklist_1" has lines with following column values
      | name-0     | property_key-1              | property_value-2 | user_configured-3 |
      | blacklist1 | limitZeroAllow              | true             | true              |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                              | expect  | db      |
      | conn_3 | False   | select t1.* from sharding_4_t1 t1 join test t2 on t1.id=t2.id order by t1.name limit 0           | success | schema1 |
      | conn_3 | False   | select t2.* from sharding_4_t1 t1,test t2 where t1.id=t2.id and t2.age>40 order by t1.id limit 0 | success | schema1 |
      | conn_3 | False   | select * from sharding_4_t1 limit 0                                                              | success | schema1 |
      | conn_3 | False   | drop table if exists sharding_4_t1                                                               | success | schema1 |
      | conn_3 | True    | drop table if exists test                                                                        | success | schema1 |


  Scenario: check selectAllow #6
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                 | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(20),age int)        | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1,1),(2,2,12),(3,3,35),(4,4,43) | success | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                                        | has{((1,'1',1),(2,'2',12),(3,'3',35),(4,'4',43))} | schema1 |
      | conn_1 | True    | select id,name from sharding_4_t1 where age > 30                   | has{((3,'3'),(4,'4'))} | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test" password="111111" schemas="schema1" blacklist="blacklist1"/>
      <blacklist name="blacklist1">
        <property name="selelctAllow">false</property>
      </blacklist>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_blacklist_2"
      | conn   | toClose | sql                                                       | db               |
      | conn_0 | True    | select * from dble_blacklist where user_configured='true' | dble_information |
    Then check resultset "dble_blacklist_2" has lines with following column values
      | name-0     | property_key-1              | property_value-2 | user_configured-3 |
      | blacklist1 | selelctAllow                | false            | true              |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                               | expect  | db      |
      | conn_2 | False   | select * from sharding_4_t1                                       | Intercepted by suspected configuration [selelctAllow,selectAllColumnAllow] in the blacklist of user 'test', so it is considered unsafe SQL | schema1 |
      | conn_2 | True    | select id,name from sharding_4_t1 where age > 30                  | Intercepted by suspected configuration [selelctAllow,selectAllColumnAllow] in the blacklist of user 'test', so it is considered unsafe SQL | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test" password="111111" schemas="schema1" blacklist="blacklist1"/>
      <blacklist name="blacklist1">
        <property name="selectAllow">false</property>
      </blacklist>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_blacklist_3"
      | conn   | toClose | sql                                                       | db               |
      | conn_0 | True    | select * from dble_blacklist where user_configured='true' | dble_information |
    Then check resultset "dble_blacklist_3" has lines with following column values
      | name-0     | property_key-1              | property_value-2 | user_configured-3 |
      | blacklist1 | selectAllow                 | false            | true              |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                               | expect  | db      |
      | conn_3 | False   | select * from sharding_4_t1                                       | Intercepted by suspected configuration [selelctAllow,selectAllColumnAllow] in the blacklist of user 'test', so it is considered unsafe SQL | schema1 |
      | conn_3 | True    | select id,name from sharding_4_t1 where age > 30                  | Intercepted by suspected configuration [selelctAllow,selectAllColumnAllow] in the blacklist of user 'test', so it is considered unsafe SQL | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test" password="111111" schemas="schema1" blacklist="blacklist1"/>
      <blacklist name="blacklist1">
        <property name="selelctAllow">true</property>
      </blacklist>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_blacklist_4"
      | conn   | toClose | sql                                                       | db               |
      | conn_0 | True    | select * from dble_blacklist where user_configured='true' | dble_information |
    Then check resultset "dble_blacklist_4" has lines with following column values
      | name-0     | property_key-1              | property_value-2 | user_configured-3 |
      | blacklist1 | selelctAllow                | true             | true              |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                               | expect  | db      |
      | conn_4 | False   | select * from sharding_4_t1                                       | has{((1,'1',1),(2,'2',12),(3,'3',35),(4,'4',43))} | schema1 |
      | conn_4 | True    | select id,name from sharding_4_t1 where age > 30                  | has{((3,'3'),(4,'4'))} | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test" password="111111" schemas="schema1" blacklist="blacklist1"/>
      <blacklist name="blacklist1">
        <property name="selectAllow">true</property>
      </blacklist>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_blacklist_5"
      | conn   | toClose | sql                                                       | db               |
      | conn_0 | True    | select * from dble_blacklist where user_configured='true' | dble_information |
    Then check resultset "dble_blacklist_5" has lines with following column values
      | name-0     | property_key-1              | property_value-2 | user_configured-3 |
      | blacklist1 | selectAllow                 | true             | true              |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                               | expect  | db      |
      | conn_5 | False   | select * from sharding_4_t1                                       | has{((1,'1',1),(2,'2',12),(3,'3',35),(4,'4',43))} | schema1 |
      | conn_5 | True    | select id,name from sharding_4_t1 where age > 30                  | has{((3,'3'),(4,'4'))} | schema1 |
      | conn_6 | True    | drop table if exists sharding_4_t1                                | success | schema1 |
