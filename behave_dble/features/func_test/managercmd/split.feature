# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2020/09/22

Feature: test split: split src dest [-sschema] [-r500] [-w500] [-l10000] [-ignore]
  Background: prepare env, need contains all types of tables and cross schema
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
       <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
          <singleTable name="sharding_1_t1" shardingNode="dn1" />
          <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
          <shardingTable name="foreign_table" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
          <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
             <childTable name="tb_child" joinColumn="child_id" parentColumn="id" sqlMaxLimit="201" />
          </shardingTable>
          <shardingTable name="global_sequence" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" incrementColumn="id"/>
       </schema>
       <schema name="schema2" sqlMaxLimit="100">
          <shardingTable name="sharding_2_t1" shardingNode="dn3,dn4" function="hash-two" shardingColumn="id" />
          <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn4" />
          <shardingTable name="sharding_4_t3" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
       </schema>
       <schema shardingNode="dn4" name="schema3" sqlMaxLimit="100">
       </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                            |expect   | db      |
      | conn_0 | False    | drop table if exists test                      |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_1_t1             |success  | schema1 |
      | conn_0 | False    | drop table if exists foreign_table             |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1             |success  | schema1 |
      | conn_0 | False    | drop table if exists tb_child                  |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_4_t1             |success  | schema1 |
      | conn_0 | False    | drop table if exists global_sequence           |success  | schema1 |
      | conn_0 | False    | drop table if exists nosharding                |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1             |success  | schema2 |
      | conn_0 | False    | drop table if exists test1                     |success  | schema2 |
      | conn_0 | True     | drop table if exists sharding_4_t3             |success  | schema2 |

  @CRITICAL @delete_mysql_tables
  Scenario: dump file have schema and data, but have no create table sql in it #1
     """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2']}}
    """
    Given upload file "./assets/schema1_with_only_data.sql" to "dble-1" success
    #1.have no table meta in dble, split return error for sharding tables
     Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_only_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                          | expect                                                   |
      | split /opt/schema1_with_only_data.sql /opt   |success                                                   |
    #check the split out files exist
    Then check path "/opt/schema1_with_only_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                  | db      |
      | conn_0 | False    | create table test(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                    | schema1 |
      | conn_0 | False    | create table sharding_1_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))           | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))           | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))           | schema1 |
      | conn_0 | False    | create table nosharding(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))              | schema1 |
      | conn_0 | False    | create table global_sequence(id bigint,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))      | schema1 |
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_only_data.sql-dn1-*.dump /opt/schema1_with_only_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn1.dump && \
      mv /opt/schema1_with_only_data.sql-dn3-*.dump /opt/schema1_with_only_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn3.dump && \
      mv /opt/schema1_with_only_data.sql-dn5-*.dump /opt/schema1_with_only_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn5.dump && \
      mv /opt/schema1_with_only_data.sql-dn2-*.dump /opt/schema1_with_only_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn2.dump && \
      mv /opt/schema1_with_only_data.sql-dn4-*.dump /opt/schema1_with_only_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn4.dump
     """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                     | expect      |db           |
      | conn_0 | False    | select * from test                      | length{(5)} | schema1     |
      | conn_0 | False    | select * from sharding_1_t1             | length{(5)} | schema1     |
      | conn_0 | False    | select * from sharding_2_t1             | length{(0)} | schema1     |
      | conn_0 | False    | select * from sharding_4_t1             | length{(0)} | schema1     |
      | conn_0 | False    | select * from nosharding                | length{(5)} | schema1     |
      | conn_0 | True     | select * from global_sequence           | length{(0)} | schema1     |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_only_data.sql-dn*.dump
    """
    Then check path "/opt/schema1_with_only_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_only_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_only_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_only_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_only_data.sql-dn5-*.dump" in "dble-1" should not exist
    #2.have table meta in dble, split success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                               |expect   | db      |
      | conn_0 | False    | drop table if exists test                                                                         |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_1_t1                                                                |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1                                                                |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_4_t1                                                                |success  | schema1 |
      | conn_0 | False    | drop table if exists global_sequence                                                              |success  | schema1 |
      | conn_0 | False    | drop table if exists nosharding                                                                   |success  | schema1 |
      | conn_0 | False    | create table test(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                 |success  | schema1 |
      | conn_0 | False    | create table sharding_1_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))        |success  | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))        |success  | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))        |success  | schema1 |
      | conn_0 | False    | create table nosharding(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))           |success  | schema1 |
      | conn_0 | True     | create table global_sequence(id bigint,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))   |success  | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                    | expect               |
      | split /opt/schema1_with_only_data.sql /opt             | success              |
    #check the split out files exist
    Then check path "/opt/schema1_with_only_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_only_data.sql-dn1-*.dump /opt/schema1_with_only_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn1.dump && \
      mv /opt/schema1_with_only_data.sql-dn3-*.dump /opt/schema1_with_only_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn3.dump && \
      mv /opt/schema1_with_only_data.sql-dn5-*.dump /opt/schema1_with_only_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn5.dump && \
      mv /opt/schema1_with_only_data.sql-dn2-*.dump /opt/schema1_with_only_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn2.dump && \
      mv /opt/schema1_with_only_data.sql-dn4-*.dump /opt/schema1_with_only_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn4.dump
     """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                       | expect                                      |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                               | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                     | has{(2,'2',2),(4,'4',4)}                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                     | has{(1,'1',1),(3,'3',3),(5,'5',5)}          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                     | has{(4,'4',4)}                              | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                     | has{(1,'1',1),(5,'5',5)}                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                     | has{(2,'2',2)}                              | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                     | has{(3,'3',3)}                              | schema1    |
      | conn_0 | False    | select * from nosharding                                                  | length{(5)}                                 | schema1    |
      | conn_0 | True     | select * from global_sequence                                             | length{(5)}                                 | schema1    |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_only_data.sql*
    """

  @CRITICAL @delete_mysql_tables
  Scenario: dump file have no schema in it #2
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2']}}
    """
    Given upload file "./assets/noschema_only_table_data.sql" to "dble-1" success
    #1.split with no '-s' parameter, split return error and will not split out files
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/noschema_only_table_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                   | expect                                                   |
      | split /opt/noschema_only_table_data.sql /opt    | success  |
#      | split /opt/noschema_only_table_data.sql /opt    | has{('null-null','dump file executor exit, because:Please set schema by -s option or make sure that there are statement about schema in dump file.',)}  |
      | split /opt/noschema_only_table_data.sql /opt    | has{('ERROR', 'dump file executor exit, because:Please set schema by -s option or make sure that there are statement about schema in dump file.',)}  |
    Then check path "/opt/noschema_only_table_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn5-*.dump" in "dble-1" should not exist

    #2.split with '-s' parameter and the schema4 does not exist in dble config, split return error and will not split out files
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                           | expect                                            |
      | split /opt/noschema_only_table_data.sql /opt -sschema4        | Default schema[schema4] doesn't exist in config   |
    Then check path "/opt/noschema_only_table_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn5-*.dump" in "dble-1" should not exist

    #3.split with '-s' parameter and the schema exists in dble, split success
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                           | expect    |
      | split /opt/noschema_only_table_data.sql /opt -sschema1        | success   |
    #check the split out files exist
    Then check path "/opt/noschema_only_table_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/noschema_only_table_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/noschema_only_table_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/noschema_only_table_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/noschema_only_table_data.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/noschema_only_table_data.sql-dn1-*.dump /opt/noschema_only_table_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 -Ddb1< /opt/noschema_only_table_data.sql-dn1.dump && \
      mv /opt/noschema_only_table_data.sql-dn3-*.dump /opt/noschema_only_table_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 -Ddb2 < /opt/noschema_only_table_data.sql-dn3.dump && \
      mv /opt/noschema_only_table_data.sql-dn5-*.dump /opt/noschema_only_table_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 -Ddb3< /opt/noschema_only_table_data.sql-dn5.dump && \
      mv /opt/noschema_only_table_data.sql-dn2-*.dump /opt/noschema_only_table_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 -Ddb1< /opt/noschema_only_table_data.sql-dn2.dump && \
      mv /opt/noschema_only_table_data.sql-dn4-*.dump /opt/noschema_only_table_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 -Ddb2< /opt/noschema_only_table_data.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                       | expect                                      |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                               | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                     | has{(2,'2',2),(4,'4',4)}                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                     | has{(1,'1',1),(3,'3',3),(5,'5',5)}          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                     | has{(4,'4',4)}                              | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                     | has{(1,'1',1),(5,'5',5)}                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                     | has{(2,'2',2)}                              | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                     | has{(3,'3',3)}                              | schema1    |
      | conn_0 | True     | select * from global_sequence                                             | length{(5)}                                 | schema1    |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/noschema_only_table_data.sql*
    """

  @CRITICAL @delete_mysql_tables
  Scenario: split file only have one schema and also have create table sql in it #3
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2']}}
    """
    Given upload file "./assets/schema1_with_data.sql" to "dble-1" success
    #1.split with '-s' parameter and the schema does not exist in dble config, split return error
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                      | expect                                             |
      | split /opt/schema1_with_data.sql /opt -sschema4          | Default schema[schema4] doesn't exist in config    |
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should not exist

    #2.split with no '-s' parameter, split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                      | expect    |
      | split /opt/schema1_with_data.sql /opt                    | success   |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_data.sql-dn1-*.dump /opt/schema1_with_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn1.dump && \
      mv /opt/schema1_with_data.sql-dn3-*.dump /opt/schema1_with_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn3.dump && \
      mv /opt/schema1_with_data.sql-dn5-*.dump /opt/schema1_with_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn5.dump && \
      mv /opt/schema1_with_data.sql-dn2-*.dump /opt/schema1_with_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn2.dump && \
      mv /opt/schema1_with_data.sql-dn4-*.dump /opt/schema1_with_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                       | expect                                      |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                               | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                     | has{(2,'2',2),(4,'4',4)}                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                     | has{(1,'1',1),(3,'3',3),(5,'5',5)}          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                     | has{(4,'4',4)}                              | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                     | has{(1,'1',1),(5,'5',5)}                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                     | has{(2,'2',2)}                              | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                     | has{(3,'3',3)}                              | schema1    |
      | conn_0 | False    | select * from nosharding                                                  | length{(5)}                                 | schema1    |
      | conn_0 | True     | select * from global_sequence                                             | length{(5)}                                 | schema1    |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql-dn*.dump
    """

    #3.split with '-s' parameter and the schema exists in dble config(consistent with dump file), split success
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                             | expect     |
      | split /opt/schema1_with_data.sql /opt -sschema1                 | success    |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_data.sql-dn1-*.dump /opt/schema1_with_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn1.dump && \
      mv /opt/schema1_with_data.sql-dn3-*.dump /opt/schema1_with_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn3.dump && \
      mv /opt/schema1_with_data.sql-dn5-*.dump /opt/schema1_with_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn5.dump && \
      mv /opt/schema1_with_data.sql-dn2-*.dump /opt/schema1_with_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn2.dump && \
      mv /opt/schema1_with_data.sql-dn4-*.dump /opt/schema1_with_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                       | expect                                      |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                               | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                     | has{(2,'2',2),(4,'4',4)}                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                     | has{(1,'1',1),(3,'3',3),(5,'5',5)}          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                     | has{(4,'4',4)}                              | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                     | has{(1,'1',1),(5,'5',5)}                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                     | has{(2,'2',2)}                              | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                     | has{(3,'3',3)}                              | schema1    |
      | conn_0 | False    | select * from nosharding                                                  | length{(5)}                                 | schema1    |
      | conn_0 | True     | select * from global_sequence                                             | length{(5)}                                 | schema1    |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql-dn*.dump
    """

    #4.split with '-s' parameter and the schema exists in dble config(not consistent with dump file) , split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                     | expect                                                   |
      | split /opt/schema1_with_data.sql /opt -sschema2                   | success                                                  |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_data.sql-dn1-*.dump /opt/schema1_with_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn1.dump && \
      mv /opt/schema1_with_data.sql-dn3-*.dump /opt/schema1_with_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn3.dump && \
      mv /opt/schema1_with_data.sql-dn5-*.dump /opt/schema1_with_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn5.dump && \
      mv /opt/schema1_with_data.sql-dn2-*.dump /opt/schema1_with_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn2.dump && \
      mv /opt/schema1_with_data.sql-dn4-*.dump /opt/schema1_with_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                       | expect                                      |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                               | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                     | has{(2,'2',2),(4,'4',4)}                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                     | has{(1,'1',1),(3,'3',3),(5,'5',5)}          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                     | has{(4,'4',4)}                              | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                     | has{(1,'1',1),(5,'5',5)}                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                     | has{(2,'2',2)}                              | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                     | has{(3,'3',3)}                              | schema1    |
      | conn_0 | False    | select * from nosharding                                                  | length{(5)}                                 | schema1    |
      | conn_0 | True     | select * from global_sequence                                             | length{(5)}                                 | schema1    |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql*
    """

  @CRITICAL @delete_mysql_tables
  Scenario: dump file have two schemas #4
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2']}}
    """
    Given upload file "./assets/all_schemas_with_data.sql" to "dble-1" success
    #1.split with '-s' parameter and the schema does not exist in dble config, split return error
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/all_schemas_with_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                       | expect                                           |
      | split /opt/all_schemas_with_data.sql /opt -sschema4       | Default schema[schema4] doesn't exist in config  |
    Then check path "/opt/all_schemas_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/all_schemas_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/all_schemas_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/all_schemas_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/all_schemas_with_data.sql-dn5-*.dump" in "dble-1" should not exist

    #2.split with no '-s' parameter, split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                  | expect                                                   |
      | split /opt/all_schemas_with_data.sql /opt                           | success   |
    #check the split out files exist
    Then check path "/opt/all_schemas_with_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/all_schemas_with_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/all_schemas_with_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/all_schemas_with_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/all_schemas_with_data.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/all_schemas_with_data.sql-dn1-*.dump /opt/all_schemas_with_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/all_schemas_with_data.sql-dn1.dump && \
      mv /opt/all_schemas_with_data.sql-dn3-*.dump /opt/all_schemas_with_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/all_schemas_with_data.sql-dn3.dump && \
      mv /opt/all_schemas_with_data.sql-dn5-*.dump /opt/all_schemas_with_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/all_schemas_with_data.sql-dn5.dump && \
      mv /opt/all_schemas_with_data.sql-dn2-*.dump /opt/all_schemas_with_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/all_schemas_with_data.sql-dn2.dump && \
      mv /opt/all_schemas_with_data.sql-dn4-*.dump /opt/all_schemas_with_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/all_schemas_with_data.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                         | expect                                           | db        |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                | length{(5)}                                      | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                | length{(5)}                                      | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                | length{(5)}                                      | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                | length{(5)}                                      | schema1   |
      | conn_0 | False    | select * from sharding_1_t1                                 | length{(5)}                                      | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1       | has{(2,'2',2),(4,'4',4)}                         | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1       | has{(1,'1',1),(3,'3',3),(5,'5',5)}               | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1       | has{(4,'4',4)}                                   | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1       | has{(1,'1',1),(5,'5',5)}                         | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1       | has{(2,'2',2)}                                   | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1       | has{(3,'3',3)}                                   | schema1   |
      | conn_0 | False    | select * from nosharding                                    | length{(5)}                                      | schema1   |
      | conn_0 | True     | select * from global_sequence                               | length{(5)}                                      | schema1   |
      | conn_0 | False    | select * from test1                                         | length{(5)}                                      | schema2   |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_2_t1       | has{(2,'2',2),(4,'4',4)}                         | schema2   |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_2_t1       | has{(1,'1',1),(3,'3',3),(5,'5',5)}               | schema2   |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t3       | has{(4,'4',4)}                                   | schema2   |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t3       | has{(1,'1',1),(5,'5',5),(9,'9',9),(13,'13',13)}  | schema2   |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t3       | has{(2,'2',2),(6,'6',6)}                         | schema2   |
      | conn_0 | True     | /*#dble:shardingNode=dn4*/select * from sharding_4_t3       | has{(3,'3',3)}                                   | schema2   |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/all_schemas_with_data.sql-dn*.dump
    """

    #3.split with '-s' parameter and the schema exists in dble config, split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                           | expect    |
      | split /opt/all_schemas_with_data.sql /opt -sschema1           | success   |
    #check the split out files exist
    Then check path "/opt/all_schemas_with_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/all_schemas_with_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/all_schemas_with_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/all_schemas_with_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/all_schemas_with_data.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/all_schemas_with_data.sql-dn1-*.dump /opt/all_schemas_with_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/all_schemas_with_data.sql-dn1.dump && \
      mv /opt/all_schemas_with_data.sql-dn3-*.dump /opt/all_schemas_with_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/all_schemas_with_data.sql-dn3.dump && \
      mv /opt/all_schemas_with_data.sql-dn5-*.dump /opt/all_schemas_with_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/all_schemas_with_data.sql-dn5.dump && \
      mv /opt/all_schemas_with_data.sql-dn2-*.dump /opt/all_schemas_with_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/all_schemas_with_data.sql-dn2.dump && \
      mv /opt/all_schemas_with_data.sql-dn4-*.dump /opt/all_schemas_with_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/all_schemas_with_data.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                         | expect                                           |db         |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                | length{(5)}                                      | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                | length{(5)}                                      | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                | length{(5)}                                      | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                | length{(5)}                                      | schema1   |
      | conn_0 | False    | select * from sharding_1_t1                                 | length{(5)}                                      | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1       | has{(2,'2',2),(4,'4',4)}                         | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1       | has{(1,'1',1),(3,'3',3),(5,'5',5)}               | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1       | has{(4,'4',4)}                                   | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1       | has{(1,'1',1),(5,'5',5)}                         | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1       | has{(2,'2',2)}                                   | schema1   |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1       | has{(3,'3',3)}                                   | schema1   |
      | conn_0 | False    | select * from nosharding                                    | length{(5)}                                      | schema1   |
      | conn_0 | True     | select * from global_sequence                               | length{(5)}                                      | schema1   |
      | conn_0 | False    | select * from test1                                         | length{(5)}                                      | schema2   |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_2_t1       | has{(2,'2',2),(4,'4',4)}                         | schema2   |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_2_t1       | has{(1,'1',1),(3,'3',3),(5,'5',5)}               | schema2   |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t3       | has{(4,'4',4)}                                   | schema2   |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t3       | has{(1,'1',1),(5,'5',5),(9,'9',9),(13,'13',13)}  | schema2   |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t3       | has{(2,'2',2),(6,'6',6)}                         | schema2   |
      | conn_0 | True     | /*#dble:shardingNode=dn4*/select * from sharding_4_t3       | has{(3,'3',3)}                                   | schema2   |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/all_schemas_with_data.sql*.dump
    """

  @CRITICAL
  Scenario: test with '--ignore' parameter #5
    Given upload file "./assets/schema1_with_only_data.sql" to "dble-1" success
    #1.split with no '--ignore' parameter, split success and the insert statement will not contains the keyword 'ignore'
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                               | expect      |
      | split /opt/schema1_with_only_data.sql /opt                        | success     |
    #check the split out files exist
    Then check path "/opt/schema1_with_only_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn5-*.dump" in "dble-1" should exist
    Then check following text exist "N" in file "/opt/schema1_with_only_data.sql-dn1-*.dump" in host "dble-1"
     """
     INSERT IGNORE
     """
    Then check following text exist "N" in file "/opt/schema1_with_only_data.sql-dn2-*.dump" in host "dble-1"
     """
     INSERT IGNORE
     """
    Then check following text exist "N" in file "/opt/schema1_with_only_data.sql-dn3-*.dump" in host "dble-1"
     """
     INSERT IGNORE
     """
    Then check following text exist "N" in file "/opt/schema1_with_only_data.sql-dn4-*.dump" in host "dble-1"
     """
     INSERT IGNORE
     """
    Then check following text exist "N" in file "/opt/schema1_with_only_data.sql-dn5-*.dump" in host "dble-1"
     """
     INSERT IGNORE
     """

    #2.split with '--ignore' parameter, split success and the insert statement contains the keyword 'ignore'
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_only_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                       | db      |
      | conn_0 | False    | create table test(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                         | schema1 |
      | conn_0 | False    | insert into test values(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)                        | schema1 |
      | conn_0 | False    | create table sharding_1_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                | schema1 |
      | conn_0 | False    | insert into sharding_1_t1 values(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)               | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                | schema1 |
      | conn_0 | False    | insert into sharding_2_t1 values(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)               | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)               | schema1 |
      | conn_0 | False    | create table nosharding(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                   | schema1 |
      | conn_0 | False    | insert into nosharding values(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)                  | schema1 |
      | conn_0 | True     | create table global_sequence(id bigint,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))           | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                     | expect     |
      | split /opt/schema1_with_only_data.sql /opt --ignore                     | success    |
    #check the split out files exist
    Then check path "/opt/schema1_with_only_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn5-*.dump" in "dble-1" should exist
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_only_data.sql-dn1-*.dump /opt/schema1_with_only_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn1.dump && \
      mv /opt/schema1_with_only_data.sql-dn3-*.dump /opt/schema1_with_only_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn3.dump && \
      mv /opt/schema1_with_only_data.sql-dn5-*.dump /opt/schema1_with_only_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn5.dump && \
      mv /opt/schema1_with_only_data.sql-dn2-*.dump /opt/schema1_with_only_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn2.dump && \
      mv /opt/schema1_with_only_data.sql-dn4-*.dump /opt/schema1_with_only_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn4.dump
     """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                        | expect                                                               | db       |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test               | has{(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)}     | schema1  |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test               | has{(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)}     | schema1  |
      | conn_0 | False    | select * from sharding_1_t1                                | length{(5)}                                                          | schema1  |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1      | has{(2,'20',20),(4,'40',40)}                                         | schema1  |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1      | has{(1,'10',10),(3,'30',30),(5,'50',50)}                             | schema1  |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1      | has{(4,'40',40)}                                                     | schema1  |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1      | has{(1,'10',10),(5,'50',50)}                                         | schema1  |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1      | has{(2,'20',20)}                                                     | schema1  |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1      | has{(3,'30',30)}                                                     | schema1  |
      | conn_0 | False    | select * from nosharding                                   | has{(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)}     | schema1  |
      | conn_0 | True     | select * from global_sequence                              | length{(5)}                                                          | schema1  |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_only_data.sql*.dump
    """

  @NORMAL @delete_mysql_tables
  Scenario: test with '-l' parameter #6
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2']}}
    """
    Given upload file "./assets/schema1_with_data.sql" to "dble-1" success
    #1.set the -l=1,check the insert values length is 1
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                     | expect      |
      | split /opt/schema1_with_data.sql /opt -l1               | success     |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should exist
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_data.sql-dn2-*.dump /opt/schema1_with_data.sql-dn2.dump
     """
    #check the insert value length is 1
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep "INSERT INTO \`sharding_2_t1\`" /opt/schema1_with_data.sql-dn2.dump |wc -l
    """
    Then check result "rs_A" value is "3"

    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql-dn*.dump
    """

    #2.set the -l=2,check the insert values length is 2
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                    | expect    |
      | split /opt/schema1_with_data.sql /opt -l2              | success   |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should exist
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_data.sql-dn2-*.dump /opt/schema1_with_data.sql-dn2.dump
     """
    #check the insert value length is 2
    Then get result of oscmd named "rs_B" in "dble-1"
    """
    grep "INSERT INTO \`sharding_2_t1\`" /opt/schema1_with_data.sql-dn2.dump |wc -l
    """
    Then check result "rs_B" value is "2"
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql*
    """

  @NORMAL @delete_mysql_tables
  Scenario: insert value contains special character ';'(this case comes from DBLE0REQ-574)  #7
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2']}}
    """
    Given upload file "./assets/schema1_with_data_special.sql" to "dble-1" success
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data_special.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                              | expect       |
      | split /opt/schema1_with_data_special.sql /opt                    | success      |
    #check the split out files exist
    Then check path "/opt/schema1_with_data_special.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data_special.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data_special.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data_special.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data_special.sql-dn5-*.dump" in "dble-1" should exist
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_data_special.sql-dn1-*.dump /opt/schema1_with_data_special.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data_special.sql-dn1.dump && \
      mv /opt/schema1_with_data_special.sql-dn3-*.dump /opt/schema1_with_data_special.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data_special.sql-dn3.dump && \
      mv /opt/schema1_with_data_special.sql-dn5-*.dump /opt/schema1_with_data_special.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data_special.sql-dn5.dump && \
      mv /opt/schema1_with_data_special.sql-dn2-*.dump /opt/schema1_with_data_special.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_data_special.sql-dn2.dump && \
      mv /opt/schema1_with_data_special.sql-dn4-*.dump /opt/schema1_with_data_special.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_data_special.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect                                                         | db      |
      | conn_0 | False   | /*#dble:shardingNode=dn1*/select * from test          | has{(1,'1!',1),(2,'@2',2),(3,'#3*',3),(4,'$4&',4),(5,'%5^',5)} | schema1 |
      | conn_0 | False   | /*#dble:shardingNode=dn2*/select * from test          | has{(1,'1!',1),(2,'@2',2),(3,'#3*',3),(4,'$4&',4),(5,'%5^',5)} | schema1 |
      | conn_0 | False   | /*#dble:shardingNode=dn3*/select * from test          | has{(1,'1!',1),(2,'@2',2),(3,'#3*',3),(4,'$4&',4),(5,'%5^',5)} | schema1 |
      | conn_0 | False   | /*#dble:shardingNode=dn4*/select * from test          | has{(1,'1!',1),(2,'@2',2),(3,'#3*',3),(4,'$4&',4),(5,'%5^',5)} | schema1 |
      | conn_0 | False   | select * from sharding_1_t1                           | has{(1,'1;',1),(2,'2;',2),(3,'3;',3),(4,'4;',4),(5,'5;',5)}    | schema1 |
      | conn_0 | False   | /*#dble:shardingNode=dn1*/select * from sharding_2_t1 | has{(2,',2',2),(4,';4',4)}                                     | schema1 |
      | conn_0 | False   | /*#dble:shardingNode=dn2*/select * from sharding_2_t1 | has{(1,'a,1',1),(3,'a3',3),(5,'5,6',5)}                        | schema1 |
      | conn_0 | False   | /*#dble:shardingNode=dn1*/select * from sharding_4_t1 | has{(4,'$4&',4)}                                               | schema1 |
      | conn_0 | False   | /*#dble:shardingNode=dn2*/select * from sharding_4_t1 | has{(1,'1!',1),(5,'%5^',5)}                                    | schema1 |
      | conn_0 | False   | /*#dble:shardingNode=dn3*/select * from sharding_4_t1 | has{(2,'@2',2)}                                                | schema1 |
      | conn_0 | False   | /*#dble:shardingNode=dn4*/select * from sharding_4_t1 | has{(3,'#3*',3)}                                               | schema1 |
      | conn_0 | False   | select * from nosharding                              | has{(1,';1',1),(2,';2',2),(3,';3',3),(4,';4',4),(5,';5',5)}    | schema1 |
      | conn_0 | True    | select * from global_sequence                         | length{(5)}                                                    | schema1 |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data_special.sql*
    """

  @NORMAL @delete_mysql_tables
  Scenario: dump file have child tables #8
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2']}}
  """
    Given upload file "./assets/schema1_with_childTable.sql" to "dble-1" success
    #1.split with '-s' parameter and the schema does not exist in dble config, split return error
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_childTable.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                  | expect                                             |
      | split /opt/schema1_with_childTable.sql /opt -sschema4                | Default schema[schema4] doesn't exist in config    |
    Then check path "/opt/schema1_with_childTable.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_childTable.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_childTable.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_childTable.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_childTable.sql-dn5-*.dump" in "dble-1" should not exist

    #2.split with no '-s' parameter, split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                            | expect    |
#      | split /opt/schema1_with_childTable.sql /opt    | success   |
      | split /opt/schema1_with_childTable.sql /opt    | has{('schema1-tb_child', "current stmt[\nDROP TABLE IF EXISTS `tb_child`] error,because:can't process child table, skip.")}  |
    #check the split out files exist
    Then check path "/opt/schema1_with_childTable.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_childTable.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_childTable.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_childTable.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_childTable.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_childTable.sql-dn1-*.dump /opt/schema1_with_childTable.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_childTable.sql-dn1.dump && \
      mv /opt/schema1_with_childTable.sql-dn3-*.dump /opt/schema1_with_childTable.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_childTable.sql-dn3.dump && \
      mv /opt/schema1_with_childTable.sql-dn5-*.dump /opt/schema1_with_childTable.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_childTable.sql-dn5.dump && \
      mv /opt/schema1_with_childTable.sql-dn2-*.dump /opt/schema1_with_childTable.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_childTable.sql-dn2.dump && \
      mv /opt/schema1_with_childTable.sql-dn4-*.dump /opt/schema1_with_childTable.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_childTable.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                           | expect                                            |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                   | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1         | has{(2,'2',2),(4,'4',4)}                          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1         | has{(1,'1',1),(3,'3',3),(5,'5',5)}                | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1         | has{(4,'4',4)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1         | has{(1,'1',1),(5,'5',5)}                          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1         | has{(2,'2',2)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1         | has{(3,'3',3)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from foreign_table         | has{(2,'Jerry',12,2),(4,'Nibbles',3,4)}           | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from foreign_table         | has{(1,'Tom',30,1),(3,'Spike',5,3)}               | schema1    |
      | conn_0 | True     | select * from nosharding                                      | length{(5)}                                       | schema1    |

    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_childTable.sql-dn*.dump
    """

    #3.split with '-s' parameter and the schema exists in dble config, split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                             | expect      |
      | split /opt/schema1_with_childTable.sql /opt -sschema1                           | success     |
    #check the split out files exist
    Then check path "/opt/schema1_with_childTable.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_childTable.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_childTable.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_childTable.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_childTable.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_childTable.sql-dn1-*.dump /opt/schema1_with_childTable.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_childTable.sql-dn1.dump && \
      mv /opt/schema1_with_childTable.sql-dn3-*.dump /opt/schema1_with_childTable.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_childTable.sql-dn3.dump && \
      mv /opt/schema1_with_childTable.sql-dn5-*.dump /opt/schema1_with_childTable.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_childTable.sql-dn5.dump && \
      mv /opt/schema1_with_childTable.sql-dn2-*.dump /opt/schema1_with_childTable.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_childTable.sql-dn2.dump && \
      mv /opt/schema1_with_childTable.sql-dn4-*.dump /opt/schema1_with_childTable.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_childTable.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                           | expect                                            |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                   | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1         | has{(2,'2',2),(4,'4',4)}                          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1         | has{(1,'1',1),(3,'3',3),(5,'5',5)}                | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1         | has{(4,'4',4)}                                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1         | has{(1,'1',1),(5,'5',5)}                          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1         | has{(2,'2',2)}                                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1         | has{(3,'3',3)}                                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from foreign_table         | has{(2,'Jerry',12,2),(4,'Nibbles',3,4)}           | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from foreign_table         | has{(1,'Tom',30,1),(3,'Spike',5,3)}               | schema1    |
      | conn_0 | True     | select * from nosharding                                      | length{(5)}                                       | schema1    |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_childTable.sql*
    """

  @NORMAL @delete_mysql_tables
  Scenario: dump file have create view sql  #9
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2']}}
   """
    Given upload file "./assets/schema1_with_view.sql" to "dble-1" success
    #1.split with '-s' parameter and the schema does not exist in dble config, split return error
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_view.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                   | expect                                             |
      | split /opt/schema1_with_view.sql /opt -sschema4       | Default schema[schema4] doesn't exist in config    |
    Then check path "/opt/schema1_with_view.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_view.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_view.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_view.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_view.sql-dn5-*.dump" in "dble-1" should not exist

    #2.split with no '-s' parameter, split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                       | expect    |
#      | split /opt/schema1_with_view.sql /opt          | success   |
      | split /opt/schema1_with_view.sql /opt     | has{('schema1-vvview', 'skip view vvview')}   |
    #check the split out files exist
    Then check path "/opt/schema1_with_view.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_view.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_view.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_view.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_view.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_view.sql-dn1-*.dump /opt/schema1_with_view.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_view.sql-dn1.dump && \
      mv /opt/schema1_with_view.sql-dn3-*.dump /opt/schema1_with_view.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_view.sql-dn3.dump && \
      mv /opt/schema1_with_view.sql-dn5-*.dump /opt/schema1_with_view.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_view.sql-dn5.dump && \
      mv /opt/schema1_with_view.sql-dn2-*.dump /opt/schema1_with_view.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_view.sql-dn2.dump && \
      mv /opt/schema1_with_view.sql-dn4-*.dump /opt/schema1_with_view.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_view.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                           | expect                                            |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                   | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1         | has{(2,'2',2),(4,'4',4)}                          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1         | has{(1,'1',1),(3,'3',3),(5,'5',5)}                | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1         | has{(4,'4',4)}                                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1         | has{(1,'1',1),(5,'5',5)}                          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1         | has{(2,'2',2)}                                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1         | has{(3,'3',3)}                                    | schema1    |
      | conn_0 | True     | select * from nosharding                                      | length{(5)}                                       | schema1    |

    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_view.sql-dn*.dump
    """

    #3.split with '-s' parameter and the schema exists in dble config, split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                             | expect      |
      | split /opt/schema1_with_view.sql /opt -sschema1                                 | has{('schema1-vvview', 'skip view vvview')}      |
    #check the split out files exist
    Then check path "/opt/schema1_with_view.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_view.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_view.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_view.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_view.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_view.sql-dn1-*.dump /opt/schema1_with_view.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_view.sql-dn1.dump && \
      mv /opt/schema1_with_view.sql-dn3-*.dump /opt/schema1_with_view.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_view.sql-dn3.dump && \
      mv /opt/schema1_with_view.sql-dn5-*.dump /opt/schema1_with_view.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_view.sql-dn5.dump && \
      mv /opt/schema1_with_view.sql-dn2-*.dump /opt/schema1_with_view.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_view.sql-dn2.dump && \
      mv /opt/schema1_with_view.sql-dn4-*.dump /opt/schema1_with_view.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_view.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                           | expect                                            |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                  | length{(5)}                                       | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                   | length{(5)}                                       | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1         | has{(2,'2',2),(4,'4',4)}                          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1         | has{(1,'1',1),(3,'3',3),(5,'5',5)}                | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1         | has{(4,'4',4)}                                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1         | has{(1,'1',1),(5,'5',5)}                          | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1         | has{(2,'2',2)}                                    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1         | has{(3,'3',3)}                                    | schema1    |
      | conn_0 | True     | select * from nosharding                                      | length{(5)}                                       | schema1    |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_view.sql*
    """

  @NORMAL @delete_mysql_tables
  Scenario: dump file of schema2 with extra table test but which do not have default shardingNode #10
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2']}}
  """
    Given upload file "./assets/schema2_with_no_default_shardingNode.sql" to "dble-1" success
    #1.split with '-s' parameter and the schema does not exist in dble config, split return error
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema2_with_no_default_shardingNode.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                          | expect                                             |
      | split /opt/schema2_with_no_default_shardingNode.sql /opt -sschema4           | Default schema[schema4] doesn't exist in config    |
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn5-*.dump" in "dble-1" should not exist
    #2.split with no '-s' parameter, split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                               | expect    |
#      | split /opt/schema2_with_no_default_shardingNode.sql /opt          | success   |
      | split /opt/schema2_with_no_default_shardingNode.sql /opt          | has{('schema2-test', 'dump file executor exit, because:null')}  |
    #check the split out files exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn5-*.dump" in "dble-1" should not exist
    #3.split with '-s' parameter and the schema exists in dble config, split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                             | expect      |
      | split /opt/schema2_with_no_default_shardingNode.sql /opt -sschema1              | has{('schema2-test', 'dump file executor exit, because:null')}  |
    #check the split out files exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema2_with_no_default_shardingNode.sql-dn5-*.dump" in "dble-1" should not exist

    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema2_with_no_default_shardingNode.sql*
    """

  @NORMAL @delete_mysql_tables
  Scenario: split file only have create table sql in it #11
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2']}}
  """
    Given upload file "./assets/schema1_with_only_table_structure.sql" to "dble-1" success
    #1.split with '-s' parameter and the schema does not exist in dble config, split return error
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_only_table_structure.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                 | expect                                             |
      | split /opt/schema1_with_only_table_structure.sql /opt -sschema4     | Default schema[schema4] doesn't exist in config    |
    Then check path "/opt/schema1_with_only_table_structure.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn5-*.dump" in "dble-1" should not exist

    #2.split with no '-s' parameter, split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                        | expect    |
      | split /opt/schema1_with_only_table_structure.sql /opt      | has{('ERROR', 'dump file executor exit, because:Please set schema by -s option or make sure that there are statement about schema in dump file.')}   |
    #check the split out files exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn5-*.dump" in "dble-1" should not exist

    #3.split with '-s' parameter and the schema exists in dble config(consistent with dump file), split success
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                      | expect      |
      | split /opt/schema1_with_only_table_structure.sql /opt -sschema1          | success     |
    #check the split out files exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_only_table_structure.sql-dn1-*.dump /opt/schema1_with_only_table_structure.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 -Ddb1 < /opt/schema1_with_only_table_structure.sql-dn1.dump && \
      mv /opt/schema1_with_only_table_structure.sql-dn3-*.dump /opt/schema1_with_only_table_structure.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 -Ddb2 < /opt/schema1_with_only_table_structure.sql-dn3.dump && \
      mv /opt/schema1_with_only_table_structure.sql-dn5-*.dump /opt/schema1_with_only_table_structure.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 -Ddb3 < /opt/schema1_with_only_table_structure.sql-dn5.dump && \
      mv /opt/schema1_with_only_table_structure.sql-dn2-*.dump /opt/schema1_with_only_table_structure.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 -Ddb1 < /opt/schema1_with_only_table_structure.sql-dn2.dump && \
      mv /opt/schema1_with_only_table_structure.sql-dn4-*.dump /opt/schema1_with_only_table_structure.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 -Ddb2 < /opt/schema1_with_only_table_structure.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                   | expect               | db       |
      | conn_0 | False    | show tables                                           | length{(6)}          | schema1  |
      | conn_0 | False    | select * from global_sequence                         | length{(0)}          | schema1  |
      | conn_0 | False    | select * from sharding_1_t1                           | length{(0)}          | schema1  |
      | conn_0 | False    | select * from sharding_2_t1                           | length{(0)}          | schema1  |
      | conn_0 | False    | select * from sharding_4_t1                           | length{(0)}          | schema1  |
      | conn_0 | False    | select * from test                                    | length{(0)}          | schema1  |
      | conn_0 | False    | select * from nosharding                              | length{(0)}          | schema1  |
      | conn_0 | False    | drop table if exists global_sequence                  | success              | schema1  |
      | conn_0 | False    | drop table if exists sharding_1_t1                    | success              | schema1  |
      | conn_0 | False    | drop table if exists sharding_2_t1                    | success              | schema1  |
      | conn_0 | False    | drop table if exists sharding_4_t1                    | success              | schema1  |
      | conn_0 | False    | drop table if exists test                             | success              | schema1  |
      | conn_0 | True     | drop table if exists nosharding                       | success              | schema1  |

    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_only_table_structure.sql-dn*.dump
    """
   #4.split with '-s' parameter and the schema exists in dble config(not consistent with dump file) , split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                               | expect                                                   |
      | split /opt/schema1_with_only_table_structure.sql /opt -sschema2   | has{('schema2-test', 'current stmt[\n--\n-- Table structure for table `test`\n--\n\nDROP TABLE IF EXISTS `test`] error,because:schema schema2 has no default node.')}    |
    #check the split out files exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_table_structure.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_only_table_structure.sql-dn1-*.dump /opt/schema1_with_only_table_structure.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 -Ddb1 < /opt/schema1_with_only_table_structure.sql-dn1.dump && \
      mv /opt/schema1_with_only_table_structure.sql-dn3-*.dump /opt/schema1_with_only_table_structure.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 -Ddb2 < /opt/schema1_with_only_table_structure.sql-dn3.dump && \
      mv /opt/schema1_with_only_table_structure.sql-dn5-*.dump /opt/schema1_with_only_table_structure.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 -Ddb3 < /opt/schema1_with_only_table_structure.sql-dn5.dump && \
      mv /opt/schema1_with_only_table_structure.sql-dn2-*.dump /opt/schema1_with_only_table_structure.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 -Ddb1 < /opt/schema1_with_only_table_structure.sql-dn2.dump && \
      mv /opt/schema1_with_only_table_structure.sql-dn4-*.dump /opt/schema1_with_only_table_structure.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 -Ddb2 < /opt/schema1_with_only_table_structure.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                           | expect                                        |db          |
      | conn_0 | True     | show tables                   | length{(0)}                                   | schema1    |
      | conn_0 | False    | show tables                   | length{(1)}                                   | schema2    |
      | conn_0 | True     | show tables                   | has{('sharding_2_t1',)}                       | schema2    |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_only_table_structure.sql*
    """

  @CRITICAL @delete_mysql_tables
  Scenario: test with '-w' parameter  #12
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2']}}
  """
    Given upload file "./assets/schema1_with_data.sql" to "dble-1" success
    #1.split -w with blank
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                 | expect                                       |
      | split /opt/schema1_with_data.sql  /opt -w 500       | You have an error in your SQL syntax         |
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should not exist

    #2.1.split -w with number not power of 2
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                 | expect              |
      | split /opt/schema1_with_data.sql  /opt -w500;       | error totally whack |
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should exist
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql-dn*.dump
    """

    #3.split -w with proper number, split success
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                       | expect      |
      | split /opt/schema1_with_data.sql /opt -sschema1 -w512                     | success     |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_data.sql-dn1-*.dump /opt/schema1_with_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn1.dump && \
      mv /opt/schema1_with_data.sql-dn3-*.dump /opt/schema1_with_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn3.dump && \
      mv /opt/schema1_with_data.sql-dn5-*.dump /opt/schema1_with_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn5.dump && \
      mv /opt/schema1_with_data.sql-dn2-*.dump /opt/schema1_with_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn2.dump && \
      mv /opt/schema1_with_data.sql-dn4-*.dump /opt/schema1_with_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_data.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                        | expect                                |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test               | length{(5)}                           | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test               | length{(5)}                           | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test               | length{(5)}                           | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test               | length{(5)}                           | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                | length{(5)}                           | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1      | has{(2,'2',2),(4,'4',4)}              | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1      | has{(1,'1',1),(3,'3',3),(5,'5',5)}    | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1      | has{(4,'4',4)}                        | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1      | has{(1,'1',1),(5,'5',5)}              | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1      | has{(2,'2',2)}                        | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1      | has{(3,'3',3)}                        | schema1    |
      | conn_0 | False    | select * from nosharding                                   | length{(5)}                           | schema1    |
      | conn_0 | True     | select * from global_sequence                              | length{(5)}                           | schema1    |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql*
    """

  @NORMAL
  Scenario: split file without required parameters / with wrong parameters  #13
    Given upload file "./assets/schema1_with_data.sql" to "dble-1" success
    #1.split without -dest, split return error
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                              | expect                                       |
      | split /opt/schema1_with_data.sql                 | You have an error in your SQL syntax         |
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should not exist

    #2.split with a none exists dumpfile path, split return error
    Then execute sql in "dble-1" in "admin" mode
      | sql                                              | expect                                       |
      | split /opt/test.sql /opt                         | /opt/test.sql (No such file or directory)    |
    Then check path "/opt/test.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/test.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/test.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/test.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/test.sql-dn5-*.dump" in "dble-1" should not exist

    #3.split with a wrong dumpfile path, split return error
    Then execute sql in "dble-1" in "admin" mode
      | sql                                              | expect      |
      | split opt/schema1_with_data.sql /opt -sschema1   | opt/schema1_with_data.sql (No such file or directory)  |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should not exist

    #4.split with a wrong dest path, split return error
    Then execute sql in "dble-1" in "admin" mode
      | sql                                              | expect               |
      | split /opt/schema1_with_data.sql /oom            | error totally whack  |
    #check the split out files exist
    Then check path "/oom/schema1_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/oom/schema1_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/oom/schema1_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/oom/schema1_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/oom/schema1_with_data.sql-dn5-*.dump" in "dble-1" should not exist

    #5.split with with wrong -w
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                               | expect                                |
      | split /opt/schema1_with_data.sql  /opt -wert;                     | You have an error in your SQL syntax  |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should not exist
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                               | expect                                |
      | split /opt/schema1_with_data.sql  /opt -w-256;                    | You have an error in your SQL syntax  |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should not exist

    #6.split with with wrong -t
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                               | expect                                |
      | split /opt/schema1_with_data.sql  /opt -w -t&UGF;                 | You have an error in your SQL syntax  |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should not exist
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                              | expect                                |
      | split /opt/schema1_with_data.sql  /opt -w -t-20;                 | You have an error in your SQL syntax  |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should not exist

    #7.split with with wrong -l
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                               | expect                                |
      | split /opt/schema1_with_data.sql  /opt -w512 -t2 -lxsd;           | You have an error in your SQL syntax  |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should not exist
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                               | expect                                |
      | split /opt/schema1_with_data.sql  /opt -w512 -t2 -l-1;            | You have an error in your SQL syntax  |
    #check the split out files exist
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should not exist

    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql*
    """