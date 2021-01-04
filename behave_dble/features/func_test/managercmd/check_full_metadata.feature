# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2018/12/21
Feature: test "check full @@metadata...'"

  @CRITICAL
  Scenario: config same table name in different schema #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn1">
    <shardingTable name="test_shard" shardingNode="dn2,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    <schema name="testdb" sqlMaxLimit="100" shardingNode="dn1">
    <shardingTable name="test_shard" shardingNode="dn4,dn5" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,testdb"/>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                | expect  | db      |
      | conn_0 | False   | drop table if exists test_shard                    | success | testdb  |
      | conn_0 | True    | create table test_shard(id int,name char,age int)  | success | testdb  |
      | conn_1 | False   | drop table if exists test_shard                    | success | schema1 |
      | conn_1 | True    | create table test_shard(id int,name char)          | success | schema1 |
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect                                          | db      |
      | conn_1 | False   | insert into test_shard values(1,1,1) | Column count doesn't match value count at row 1 | schema1 |
      | conn_1 | True    | insert into test_shard values(1,1)   | success                                         | schema1 |
      | conn_0 | False   | insert into test_shard values(1,1)   | Column count doesn't match value count at row 1 | testdb  |
      | conn_0 | True    | insert into test_shard values(1,1,1) | success                                         | testdb  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect                               |
      | conn_2 | False   | check full @@metadata where schema='schema1' and table='test_shard' | hasNoStr{`age` int(11) DEFAULT NULL} |
      | conn_2 | False   | check full @@metadata where schema='schema1' and table='test_shard' | hasStr{`id` int(11) DEFAULT NULL}    |
      | conn_2 | True    | check full @@metadata where schema='testdb' and table='test_shard'  | hasStr{`age` int(11) DEFAULT NULL}   |

  @CRITICAL
  Scenario: config no-sharding table's name is same as sharding table's name, their metadatas are not affected by each other #2
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      | expect  | db       |
      | conn_0 | False   | drop table if exists test1                               | success | schema1  |
      | conn_0 | False   | create table test1(id int,name1 char,age int,name2 char) | success | schema1  |
      | conn_0 | True    | insert into test1 values(1,1,1,1)                        | success | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | check full @@metadata where schema='schema1' and table='test1' | hasStr{`name2` char(1) DEFAULT NULL} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test" password="111111" schemas="schema1,testdb"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn1">
    <shardingTable name="test1" shardingNode="dn2,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    <schema name="testdb" sqlMaxLimit="100" shardingNode="dn1">
    <globalTable name="test1" shardingNode="dn4,dn5"/>
    </schema>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect  | db      |
      | conn_0 | False   | drop table if exists test1                     | success | schema1 |
      | conn_0 | True    | create table test1(id int,name char,age int)   | success | schema1 |
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                               | expect                                          | db        |
      | conn_0 | False   | insert into test1 values(1,1,1,1) | Column count doesn't match value count at row 1 | schema1   |
      | conn_0 | False   | insert into test1 values(2,2,2)   | success                                         | schema1   |
      | conn_0 | True    | alter table test1 drop name       | success                                         | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                            | expect                             |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test1' | hasStr{`age` int(11) DEFAULT NULL} |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test1' | hasNoStr{`name`}                   |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test1' | hasNoStr{`name2`}                  |
      | conn_0 | True    | check @@metadata                                               | success                            |

  @CRITICAL
  Scenario: config no-sharding table's name is same as global table's name, their metadatas are not affected by each other #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test" password="111111" schemas="schema1,testdb"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn1">
    <shardingTable name="test1" shardingNode="dn2,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    <schema name="testdb" sqlMaxLimit="100" shardingNode="dn1">
    <globalTable name="test1" shardingNode="dn4,dn5"/>
    </schema>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                         | expect   | db       |
      | conn_0 | False    | drop table if exists test1  | success  | testdb   |
      | conn_0 | True     | create table test1(id int)  | success  | testdb   |
    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect   | db      |
      | insert into test1 values(3)        | success  | testdb  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                               |
      | conn_0 | False   | check full @@metadata where schema='testdb' and table='test1' | hasNoStr{`age` int(11) DEFAULT NULL} |
      | conn_0 | True    | check full @@metadata where schema='testdb' and table='test1' | hasStr{`id`}                         |
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_0 | False   | insert into test1 values(3)        | success | testdb  |
      | conn_0 | True    | alter table test1 add name char    | success | testdb  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                               |
      | conn_0 | False   | check full @@metadata where schema='testdb' and table='test1' | hasNoStr{`age` int(11) DEFAULT NULL} |
      | conn_0 | True    | check full @@metadata where schema='testdb' and table='test1' | hasStr{`name`}                       |

  @CRITICAL
  Scenario: config no tables in node schema, then create 1 table in default node and do ddl,reload @@metadata, check table's metadata during the procedure #4
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                         |
      | conn_0 | False    | drop database if exists db3 |
      | conn_0 | True     | create database db3         |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                          |
      | check full @@metadata where schema='schema1' |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                         | expect      | db       |
      | conn_0 | False   | drop table if exists test                   | success     | schema1  |
      | conn_0 | False   | create table test(id int,name char,age int) | success     | schema1  |
      | conn_0 | False   | insert into test values(1,1,1)              | success     | schema1  |
      | conn_0 | False   | alter table test drop name                  | success     | schema1  |
      | conn_0 | True    | insert into test values(2,2)                | success     | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect                             |
      | conn_0 | False   | check full @@metadata where schema='schema1' |hasStr{`age` int(11) DEFAULT NULL}  |
      | conn_0 | False   | check full @@metadata where schema='schema1' |hasNoStr{`name`}                    |
      | conn_0 | True    | reload @@metadata                            | success                            |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                          | expect  | db        |
      | conn_0 | False   | insert into test values(3,3) | success | schema1   |
      | conn_0 | False   | alter table test drop age    | success | schema1   |
      | conn_0 | True    | insert into test values(4)   | success | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                            | expect                               |
      | conn_0 | False   | check full @@metadata where schema='schema1'   |hasNoStr{`age` int(11) DEFAULT NULL}  |
      | conn_0 | True    | check full @@metadata where schema='schema1'   |hasStr{`id` int(11) DEFAULT NULL}     |
    Then execute sql in "dble-1" in "user" mode
      | sql                       | expect  | db      |
      | drop table if exists test | success | schema1 |

  @CRITICAL @current
  Scenario: backend tables in shardingnode are inconsistent or lack in some shardingnode for a config sharding/global table, check metadata and query #5
    """
    5.1 the table structure of the sharding table in the shardingnode is different
    5.2 Part of the shardingnode sharding table does not exist
    5.3 the table structure of the global table in the shardingnode is different'
    5.4 Part of the shardingnode global table does not exist
    ps:the order of show create table is stable: show create table test4;show create table test5;show create table test2;show create table test3;show create table test6;show create table test1;
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
      <shardingTable name="test1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      <shardingTable name="test2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      <shardingTable name="test3" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      <shardingTable name="test4" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      <globalTable name="test5" shardingNode="dn1,dn2,dn3,dn4"/>
      <shardingTable name="test6" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect  | db       |
      | conn_0 | False   | drop table if exists test1                     | success | schema1  |
      | conn_0 | False   | create table test1(id int,name char,age int)   | success | schema1  |
      | conn_0 | False   | drop table if exists test2                     | success | schema1  |
      | conn_0 | False   | create table test2(id int,name char,age int)   | success | schema1  |
      | conn_0 | False   | drop table if exists test3                     | success | schema1  |
      | conn_0 | False   | create table test3(id int,name char,age int)   | success | schema1  |
      | conn_0 | False   | drop table if exists test4                     | success | schema1  |
      | conn_0 | False   | create table test4(id int,name char,age int)   | success | schema1  |
      | conn_0 | False   | drop table if exists test5                     | success | schema1  |
      | conn_0 | False   | create table test5(id int,name char,age int)   | success | schema1  |
      | conn_0 | True    | drop table if exists test6                     | success | schema1  |
    #5.1
    Then execute sql in "mysql-master1"
       | sql                        | expect   | db      |
       |alter table test4 drop age  | success  | db1     |
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                             | expect   | db        |
      | conn_0 | False   | select * from test2             | success  | schema1   |
      | conn_0 | False   | insert into test2 values(1,1,1) | success  | schema1   |
      | conn_0 | True    | alter table test2 drop name     | success  | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect            |
      | conn_1 | False   | check full @@metadata where consistent_in_sharding_nodes =0       | hasStr{`test4`}   |
      | conn_1 | False   | check full @@metadata where consistent_in_sharding_nodes =0       | hasNoStr{`test2`} |
      | conn_1 | False   | check full @@metadata where consistent_in_sharding_nodes =1       | hasStr{`test2`}   |
      | conn_1 | False   | check full @@metadata where consistent_in_sharding_nodes =1       | hasNoStr{`test4`} |
      | conn_1 | False   | check full @@metadata where schema='schema1' and table='test2'| hasNoStr{`name`}  |
      | conn_1 | False   | check full @@metadata where schema='schema1' and table='test2'| hasStr{`age`}     |
      | conn_1 | True    | check full @@metadata where schema='schema1' and table='test6'| hasNoStr{`id`}    |
    Then execute sql in "dble-1" in "user" mode
      | sql                        | expect                       | db      |
      | alter table test4 drop age | check that column/key exists | schema1 |
    #5.2
    Then execute sql in "mysql-master1"
      | sql                        | expect   | db      |
      |drop table if exists test4  | success  | db1     |
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect   | db        |
      | conn_0 | False   | select * from test2              | success  | schema1   |
      | conn_0 | False   | insert into test2 values(1,1)    | success  | schema1   |
      | conn_0 | True    | alter table test2 add name char  | success  | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect            |
      | conn_1 | False   | check full @@metadata where consistent_in_sharding_nodes =0       | hasStr{`test4`}   |
      | conn_1 | True    | check full @@metadata where schema='schema1' and table='test2'| hasStr{`name`}    |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect                           | db        |
      | conn_0 | False   | alter table test4 drop name                    | Table 'db1.test4' doesn't exist  | schema1   |
      | conn_0 | False   | drop table if exists test4                     | success                          | schema1   |
      | conn_0 | False   | drop table if exists test2                     | success                          | schema1   |
      | conn_0 | True    | create table test2(id int,name char,age int)   | success                          | schema1   |
    #5.3
    Then execute sql in "mysql-master1"
      | sql                              | expect   | db      |
      |alter table test5 drop age        | success  | db1     |
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                             | expect   | db        |
      | conn_0 | False   | select * from test2             | success  | schema1   |
      | conn_0 | False   | insert into test2 values(1,1,1) | success  | schema1   |
      | conn_0 | True    | alter table test2 drop name     | success  | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect            |
      | conn_1 | False   | check full @@metadata where consistent_in_sharding_nodes =0       | hasStr{`test5`}   |
      | conn_1 | False   | check full @@metadata where consistent_in_sharding_nodes =0       | hasNoStr{`test2`} |
      | conn_1 | False   | check full @@metadata where consistent_in_sharding_nodes =1       | hasStr{`test2`}   |
      | conn_1 | False   | check full @@metadata where consistent_in_sharding_nodes =1       | hasNoStr{`test5`} |
      | conn_1 | False   | check full @@metadata where schema='schema1' and table='test2'| hasNoStr{`name`}  |
      | conn_1 | False   | check full @@metadata where schema='schema1' and table='test2'| hasStr{`age`}     |
      | conn_1 | True    | check full @@metadata where schema='schema1' and table='test6'| hasNoStr{`id`}    |
    Then execute sql in "dble-1" in "user" mode
      | sql                          | expect                        | db        |
      | alter table test5 drop age   | check that column/key exists  | schema1   |
    #5.4
    Then execute sql in "mysql-master1"
      | sql                               | expect   | db      |
      |drop table if exists test5         | success  | db1     |
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect   | db        |
      | conn_0 | False   | select * from test2              | success  | schema1   |
      | conn_0 | False   | insert into test2 values(1,1)    | success  | schema1   |
      | conn_0 | True    | alter table test2 add name char  | success  | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect          |
      | conn_1 | False   | check full @@metadata where consistent_in_sharding_nodes =0       | hasStr{`test5`} |
      | conn_1 | True    | check full @@metadata where schema='schema1' and table='test2'| hasStr{`name`}  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                           | db        |
      | conn_0 | False   | alter table test5 drop name | Table 'db1.test5' doesn't exist  | schema1   |
      | conn_0 | False   | drop table if exists test5  | success                          | schema1   |
      | conn_0 | True    | drop table if exists test2  | success                          | schema1   |

  @NORMAL @restore_mysql_service
  Scenario: Some of dbGroup's dbInstance(with or dbInstance ) cannot be connectted, check metadata and query #6
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1},'mysql-master2':{'start_mysql':1}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
      <shardingTable name="test_shard" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      <shardingTable name="test_two" shardingNode="dn2,dn4" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup name="ha_group2" rwSplitMode="0">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" url="172.100.9.6:3306" user="test" password="111111" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
       <dbInstance name="hostS2" url="172.100.9.2:3306" user="test" password="111111" maxCon="1000" minCon="10">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect   | db      |
      | conn_0 | False   | drop table if exists test_shard                       | success  | schema1 |
      | conn_0 | False   | drop table if exists test_two                         | success  | schema1 |
      | conn_0 | False   | drop table if exists test_no_shard                    | success  | schema1 |
      | conn_0 | False   | create table test_shard(id int,name char,age int)     | success  | schema1 |
      | conn_0 | False   | create table test_two(id int,name char,age int)       | success  | schema1 |
      | conn_0 | True    | create table test_no_shard(id int,name1 char,age int) | success  | schema1 |
    #6.1 Unable to connect to dbGroup does not exist dbInstance
    Given stop mysql in host "mysql-master1"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect              | db      |
      | conn_0 | False   | insert into test_shard values(1,1,1)  | success             | schema1 |
      | conn_0 | False   | alter table test_two drop age         | success             | schema1 |
      | conn_0 | True    | alter table test_shard drop name      | error totally whack | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                | expect                             |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test_shard'| hasStr{`name` }                    |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test_two'  | hasStr{`id` int(11) DEFAULT NULL}  |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test_two'  | hasNoStr{`age`}                    |
      | conn_0 | False   | show @@version                                                     | success                            |
      | conn_0 | True    | reload @@metadata                                                  | success                            |
    Given start mysql in host "mysql-master1"
    Given sleep "10" seconds
    #6.2 Unable to connect to dbGroup has dbInstance
    Given stop mysql in host "mysql-master2"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect              | db      |
      | conn_0 | False   | insert into test_shard values(2,2,2)   | success             | schema1 |
      | conn_0 | False   | alter table test_no_shard drop age     | success             | schema1 |
      | conn_0 | True    | alter table test_shard drop name       | error totally whack | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                   | expect                             |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test_shard'   | hasStr{`name` }                    |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test_no_shard'| hasStr{`id` int(11) DEFAULT NULL}  |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test_no_shard'| hasNoStr{`age`}                    |
      | conn_0 | False   | show @@version                                                        | success                            |
      | conn_0 | True    | reload @@metadata                                                     | success                            |
    Given start mysql in host "mysql-master2"
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_0 | False   | drop table if exists test_shard    | success | schema1 |
      | conn_0 | False   | drop table if exists test_two      | success | schema1 |
      | conn_0 | True    | drop table if exists test_no_shard | success | schema1 |

  @regression @restore_view
  Scenario: default schema table or sharding table contains view in part of backend database,  check metadata and query #7
     """
    {'restore_view':{'mysql-master1':{'db1':'view_test,view_test1'}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
      <shardingTable name="test_shard" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | expect   | db      |
      | conn_0 | False   | drop table if exists test_shard                   | success  | schema1 |
      | conn_0 | False   | drop table if exists test_no_shard                | success  | schema1 |
      | conn_0 | False   | create table test_shard(id int,name char,age int) | success  | schema1 |
      | conn_0 | True    | create table test_no_shard(id int,name1 char)     | success  | schema1 |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                                                  | expect   | db  |
      | conn_0 | False    |drop view if exists view_test                         | success  | db1 |
      | conn_0 | True     |create view view_test as select * from test_shard     | success  | db1 |
      | conn_1 | False    |drop view if exists view_test1                        | success  | db3 |
      | conn_1 | True     |create view view_test1 as select * from test_no_shard | success  | db3 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | expect   | db      |
      | conn_0 | False   | insert into test_shard values(1,1,1)    | success  | schema1 |
      | conn_0 | False   | insert into test_no_shard values(1,1)   | success  | schema1 |
      | conn_0 | False   | alter table test_shard drop age         | success  | schema1 |
      | conn_0 | True    | alter table test_no_shard add age int   | success  | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                   | expect                |
      | conn_0 | False   | check full @@metadata where schema='schema1'                          | hasNoStr{view_test}   |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test_shard'   | hasNoStr{age}         |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test_shard'   | hasStr{name}          |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test_no_shard'| hasStr{name1}         |
      | conn_0 | False   | check full @@metadata where schema='schema1' and table='test_no_shard'| hasStr{age}           |
      | conn_0 | False   | show @@version                                                        | success               |
      | conn_0 | True    | reload @@metadata                                                     | success               |
    Then execute sql in "mysql-master1"
      | sql                 | expect   | db  |
      |drop view view_test  | success  | db1 |
      |drop view view_test1 | success  | db3 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect   | db      |
      | conn_0 | False   | drop table if exists test_shard    | success  | schema1 |
      | conn_0 | True    | drop table if exists test_no_shard | success  | schema1 |

  @regression
  Scenario: meta data check should ignore AUTO_INCREMENT difference, check matadate、rload and dble.log #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn1">
      <shardingTable name="test_shard" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      <shardingTable name="mytest_auto_test1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" incrementColumn="R_REGIONKEY" />
      </schema>
      <shardingNode name="dn1" dbGroup="host1" database="db1"/>
      <shardingNode name="dn2" dbGroup="host1" database="db2"/>
      <shardingNode name="dn3" dbGroup="host1" database="db3"/>
      <shardingNode name="dn4" dbGroup="host1" database="db4"/>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup name="host1" rwSplitMode="0" delayThreshold="100">
         <heartbeat>show slave status</heartbeat>
         <dbInstance name="hostM2" url="172.100.9.5:3306" user="test" password="111111" maxCon="1000" minCon="5" primary="true">
         </dbInstance>
      </dbGroup>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | expect   | db     |
      | conn_0 | False   | drop table if exists test_shard                   | success  | schema1 |
      | conn_0 | False   | CREATE TABLE test_shard (id BIGINT PRIMARY KEY AUTO_INCREMENT,clientNum CHAR(20) NOT NULL ) | success  | schema1 |
      | conn_0 | True    | insert into test_shard values(1,1),(2,2),(3,3),(4,4),(5,5)  | success  | schema1 |
    Then execute admin cmd "reload @@config_all"
    Then check following text exist "N" in file "dble.log" in host "dble-1"
      """
      CREATE TABLE `test_shard`
      """
    Then execute admin cmd "reload @@metadata"
    Then check following text exist "N" in file "dble.log" in host "dble-1"
      """
      CREATE TABLE `test_shard`
      """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
       """
       a/-DcheckTableConsistency=1
       a/-DcheckTableConsistencyPeriod=1000
       """
    Given Restart dble in "dble-1" success
    Then check following text exist "N" in file "dble.log" in host "dble-1"
      """
      CREATE TABLE `test_shard`
      """
    Given sleep "1" seconds
    Then check following text exist "N" in file "dble.log" in host "dble-1"
      """
      CREATE TABLE `test_shard`
      """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                      | expect                  |
      | check full @@metadata where consistent_in_sharding_nodes =0  | hasNoStr{`test_shard`}  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      | expect   | db     |
      | conn_0 | False   | drop table if exists mytest_auto_test1                   | success  | schema1 |
      | conn_0 | False   | create table mytest_auto_test1 (id int(11),R_REGIONKEY bigint primary key AUTO_INCREMENT,R_NAME varchar(50),R_COMMENT varchar(50)) | success  | schema1 |
      | conn_0 | True    | insert into mytest_auto_test1(id,R_NAME,R_COMMENT) values(1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5)  | success  | schema1 |
    Then execute admin cmd "reload @@config_all"
    Then check following text exist "N" in file "dble.log" in host "dble-1"
      """
      CREATE TABLE `mytest_auto_test1`
      """
    Then execute admin cmd "reload @@metadata"
    Then check following text exist "N" in file "dble.log" in host "dble-1"
      """
      CREATE TABLE `mytest_auto_test1`
      """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                         | expect                          |
      | check full @@metadata where consistent_in_sharding_nodes =0 | hasNoStr{`mytest_auto_test1`}   |

  Scenario: add filter for reload @@metadata #9
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
    <shardingTable name="test1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    <shardingTable name="test11" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100" shardingNode="dn5">
    <globalTable name="test2" shardingNode="dn2,dn4"/>
    </schema>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | db      |
      | conn_0 | False   | drop table if exists test1                                | schema1 |
      | conn_0 | False   | drop table if exists test11                               | schema1 |
      | conn_0 | False   | CREATE TABLE test1 (id int,clientNum CHAR(20) NOT NULL )  | schema1 |
      | conn_0 | True    | CREATE TABLE test11 (id int,clientNum CHAR(20) NOT NULL ) | schema1 |
      | conn_1 | False   | drop table if exists test2                                | schema2 |
      | conn_1 | True    | CREATE TABLE test2 (id int,clientNum CHAR(20) NOT NULL )  | schema2 |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                                | db      |
      | conn_0 | False    |alter table test1 add name char(20) | db1     |
      | conn_0 | True     |alter table test11 add age int      | db1     |
      | conn_1 | False    |alter table test1 add name char(20) | db2     |
      | conn_1 | True     |alter table test11 add age int      | db2     |
    Then execute sql in "mysql-master2"
      | sql                                    | db      |
      |alter table test2 add student char(20)  | db1     |
      |alter table test2 add student char(20)  | db2     |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                        | expect            |
      | conn_0 | False   | reload @@metadata where schema='schema1' and table='test1' | success           |
      | conn_0 | False   | check full @@metadata where schema='schema1'               | hasStr{name}      |
      | conn_0 | False   | check full @@metadata where schema='schema1'               | hasNoStr{age}     |
      | conn_0 | False   | check full @@metadata where schema='schema2'               | hasNoStr{student} |
      | conn_0 | False   | reload @@metadata where schema='schema2'                   | success           |
      | conn_0 | False   | check full @@metadata where schema='schema1'               | hasNoStr{age}     |
      | conn_0 | True    | check full @@metadata where schema='schema2'               | hasStr{student}   |
    Then execute sql in "mysql-master1"
      | sql                         | db      |
      |alter table test1 drop name  | db1     |
      |alter table test1 drop name  | db2     |
    Then execute sql in "mysql-master2"
      | sql                           | db      |
      |alter table test2 drop student | db1     |
      |alter table test2 drop student | db2     |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                | expect            |
      | conn_0 | False   | reload @@metadata where table in('schema1.test11','schema2.test2') | success           |
      | conn_0 | False   | check full @@metadata where schema='schema1'                       | hasStr{name}      |
      | conn_0 | False   | check full @@metadata where schema='schema1'                       | hasStr{age}       |
      | conn_0 | False   | check full @@metadata where schema='schema2'                       | hasNoStr{student} |
      | conn_0 | False   | reload @@metadata where table in('schema1.test1')                  | success           |
      | conn_0 | False   | check full @@metadata where schema='schema1'                       | hasNoStr{name}    |
      | conn_0 | True    | reload @@metadata where schema=schema2                             | success           |

