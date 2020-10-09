# Copyright (C) 2016-2020 ActionTech.
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
          <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="global_sequence" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" incrementColumn="id"/>
       </schema>
       <schema name="schema2" sqlMaxLimit="100">
          <shardingTable name="sharding_2_t1" shardingNode="dn3,dn4" function="hash-two" shardingColumn="id" />
          <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn4" />
          <shardingTable name="sharding_4_t3" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
       </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                            |expect   | db      |
      | conn_0 | False    | drop table if exists test                   |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_1_t1         |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1         |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_4_t1         |success  | schema1 |
      | conn_0 | False    | drop table if exists global_sequence       |success  | schema1 |
      | conn_0 | False    | drop table if exists nosharding             |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1          |success  | schema2 |
      | conn_0 | False    | drop table if exists test1                   |success  | schema2 |
      | conn_0 | True     | drop table if exists sharding_4_t3          |success  | schema2 |

  @CRITICAL
  Scenario: dump file have schema and data, but have no create table sql in it #1
    Given upload file "./assets/schema1_with_only_data.sql" to "dble-1" success
    #1.have no table meta in dble, split return error for sharding tables
     Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_only_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                               | expect                                                   |
      | split /opt/schema1_with_only_data.sql /opt   |success                                                   |
#      | split /opt/schema1_with_only_data.sql /opt   | has{('schema1-global_sequence', 'current stmt[INSERT INTO `global_sequence` VALUES (1,'1',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5)] error,because:can't find meta of table and the table has no create statement.'),}                                                   |
#      | split /opt/schema1_with_only_data.sql /opt    | has{('schema1-global_sequence', 'current stmt\[INSERT INTO `global_sequence` VALUES (1,'1',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5)\] error,because:can't find \
#       meta of table and the table has no create statement.'),('schema1-sharding_2_t1','current stmt\[INSERT \
#      INTO `sharding_2_t1` VALUES (1,'1',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5)\] error,because:can't find meta of table and the table has no create statement.'),('schema1-sharding_4_t1'),'current \
#      stmt\[INSERT INTO `sharding_4_t1` VALUES (1,'1',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5)\] error,because:can't find meta of table and the table has no create statement.')}  |
#    #check the split out files exist
    Then check path "/opt/schema1_with_only_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn5-*.dump" in "dble-1" should exist
    #upload data into every nodes and check data is correct in dble
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                             | db      |
      | conn_0 | False    | create table test(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                    | schema1 |
      | conn_0 | False    | create table sharding_1_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))          | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))          | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))          | schema1 |
      | conn_0 | False    | create table nosharding(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))              | schema1 |
      | conn_0 | False    | create table global_sequence(id bigint,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))        | schema1 |
    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_only_data.sql-dn1-*.dump /opt/schema1_with_only_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn1.dump && \
      mv /opt/schema1_with_only_data.sql-dn3-*.dump /opt/schema1_with_only_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn3.dump && \
      mv /opt/schema1_with_only_data.sql-dn5-*.dump /opt/schema1_with_only_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn5.dump && \
      mv /opt/schema1_with_only_data.sql-dn2-*.dump /opt/schema1_with_only_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn2.dump && \
      mv /opt/schema1_with_only_data.sql-dn4-*.dump /opt/schema1_with_only_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn4.dump
     """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect       |db          |
      | conn_0 | False    | select * from test                       | length{(5)} | schema1    |
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
      | conn   | toClose  | sql                                                                                                        |expect   | db      |
      | conn_0 | False    | drop table if exists test                                                                               |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_1_t1                                                                    |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1                                                                    |success  | schema1 |
      | conn_0 | False    | drop table if exists sharding_4_t1                                                                    |success  | schema1 |
      | conn_0 | False    | drop table if exists global_sequence                                                                  |success  | schema1 |
      | conn_0 | False    | drop table if exists nosharding                                                                        |success  | schema1 |
      | conn_0 | False    | create table test(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))               |success  | schema1 |
      | conn_0 | False    | create table sharding_1_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))     |success  | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))     |success  | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))     |success  | schema1 |
      | conn_0 | False    | create table nosharding(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))         |success  | schema1 |
      | conn_0 | True     | create table global_sequence(id bigint,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))    |success  | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                          | expect                                                                                                       |
      | split /opt/schema1_with_only_data.sql /opt             | success                                                                                               |
#      | split /opt/schema1_with_only_data.sql /opt -sschema1  | has{('schema1-global_sequence','For table using global sequence, dble has set increment column values for you',)}   |
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
      | conn   | toClose  | sql                                                                            | expect                                       |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                                 | length{(5)}                                 | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                   | has{(2,'2',2),(4,'4',4)}                   | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                    | has{(1,'1',1),(3,'3',3),(5,'5',5)}       | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                    | has{(4,'4',4)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                    | has{(1,'1',1),(5,'5',5)}                  | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                    | has{(2,'2',2)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                    | has{(3,'3',3)}                              | schema1     |
      | conn_0 | False    | select * from nosharding                                                     | length{(5)}                                 | schema1     |
      | conn_0 | True     | select * from global_sequence                                               | length{(5)}                                 | schema1     |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_only_data.sql*.dump
    """


  @CRITICAL
  Scenario: dump file have no schema in it #2
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
    Then check path "/opt/noschema_only_table_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn5-*.dump" in "dble-1" should not exist

    #2.split with '-s' parameter and the schema3 does not exist in dble config, split return error and will not split out files
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                  | expect                                                   |
      | split /opt/noschema_only_table_data.sql /opt -sschema3        | Default schema[schema3] doesn't exist in config    |
    Then check path "/opt/noschema_only_table_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/noschema_only_table_data.sql-dn5-*.dump" in "dble-1" should not exist

    #3.split with '-s' parameter and the schema exists in dble, split success
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                  | expect                                                   |
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
      mv /opt/noschema_only_table_data.sql-dn1-*.dump /opt/noschema_only_table_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/noschema_only_table_data.sql-dn1.dump && \
      mv /opt/noschema_only_table_data.sql-dn3-*.dump /opt/noschema_only_table_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/noschema_only_table_data.sql-dn3.dump && \
      mv /opt/noschema_only_table_data.sql-dn5-*.dump /opt/noschema_only_table_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/noschema_only_table_data.sql-dn5.dump && \
      mv /opt/noschema_only_table_data.sql-dn2-*.dump /opt/noschema_only_table_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/noschema_only_table_data.sql-dn2.dump && \
      mv /opt/noschema_only_table_data.sql-dn4-*.dump /opt/noschema_only_table_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/noschema_only_table_data.sql-dn4.dump
     """
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                            | expect                                       |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                                 | length{(5)}                                 | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                   | has{(2,'2',2),(4,'4',4)}                   | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                    | has{(1,'1',1),(3,'3',3),(5,'5',5)}       | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                    | has{(4,'4',4)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                    | has{(1,'1',1),(5,'5',5)}                  | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                    | has{(2,'2',2)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                    | has{(3,'3',3)}                              | schema1     |
      | conn_0 | False    | select * from nosharding                                                     | length{(5)}                                 | schema1     |
      | conn_0 | True     | select * from global_sequence                                               | length{(5)}                                 | schema1     |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/noschema_only_table_data.sql*.dump
    """


  @CRITICAL
  Scenario: split file only have one schema and also have create table sql in it #3
    Given upload file "./assets/schema1_with_data.sql" to "dble-1" success
    #1.split with '-s' parameter and the schema does not exist in dble config, split return error
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                  | expect                                                   |
      | split /opt/schema1_with_data.sql /opt -sschema3                | Default schema[schema3] doesn't exist in config    |
    Then check path "/opt/schema1_with_data.sql-dn1-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn2-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn3-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn4-*.dump" in "dble-1" should not exist
    Then check path "/opt/schema1_with_data.sql-dn5-*.dump" in "dble-1" should not exist

    #2.split with no '-s' parameter, split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                  | expect                                                   |
      | split /opt/schema1_with_data.sql /opt                           | success   |
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
      | conn   | toClose  | sql                                                                            | expect                                       |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                                 | length{(5)}                                 | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                   | has{(2,'2',2),(4,'4',4)}                   | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                    | has{(1,'1',1),(3,'3',3),(5,'5',5)}       | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                    | has{(4,'4',4)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                    | has{(1,'1',1),(5,'5',5)}                  | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                    | has{(2,'2',2)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                    | has{(3,'3',3)}                              | schema1     |
      | conn_0 | False    | select * from nosharding                                                     | length{(5)}                                 | schema1     |
      | conn_0 | True     | select * from global_sequence                                               | length{(5)}                                 | schema1     |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql-dn*.dump
    """

    #3.split with '-s' parameter and the schema exists in dble config(consistent with dump file), split success
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                             | expect                                                   |
      | split /opt/schema1_with_data.sql /opt -sschema1                           | success     |
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
      | conn   | toClose  | sql                                                                            | expect                                       |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                                 | length{(5)}                                 | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                   | has{(2,'2',2),(4,'4',4)}                   | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                    | has{(1,'1',1),(3,'3',3),(5,'5',5)}       | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                    | has{(4,'4',4)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                    | has{(1,'1',1),(5,'5',5)}                  | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                    | has{(2,'2',2)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                    | has{(3,'3',3)}                              | schema1     |
      | conn_0 | False    | select * from nosharding                                                     | length{(5)}                                 | schema1     |
      | conn_0 | True     | select * from global_sequence                                               | length{(5)}                                 | schema1     |
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
      | conn   | toClose  | sql                                                                            | expect                                       |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                                 | length{(5)}                                 | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                   | has{(2,'2',2),(4,'4',4)}                   | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                    | has{(1,'1',1),(3,'3',3),(5,'5',5)}       | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                    | has{(4,'4',4)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                    | has{(1,'1',1),(5,'5',5)}                  | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                    | has{(2,'2',2)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                    | has{(3,'3',3)}                              | schema1     |
      | conn_0 | False    | select * from nosharding                                                     | length{(5)}                                 | schema1     |
      | conn_0 | True     | select * from global_sequence                                               | length{(5)}                                 | schema1     |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql*.dump
    """


  @CRITICAL @ww @skip_restart
  Scenario: dump file have two schemas #4
    Given upload file "./assets/all_schemas_with_data.sql" to "dble-1" success
    #1.split with '-s' parameter and the schema does not exist in dble config, split return error
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/all_schemas_with_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                  | expect                                                   |
      | split /opt/all_schemas_with_data.sql /opt -sschema3            | Default schema[schema3] doesn't exist in config    |
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
      | conn   | toClose  | sql                                                                            | expect                                       |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                                 | length{(5)}                                 | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                   | has{(2,'2',2),(4,'4',4)}                   | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                    | has{(1,'1',1),(3,'3',3),(5,'5',5)}       | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                    | has{(4,'4',4)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                    | has{(1,'1',1),(5,'5',5)}                  | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                    | has{(2,'2',2)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                    | has{(3,'3',3)}                              | schema1     |
      | conn_0 | False    | select * from nosharding                                                     | length{(5)}                                 | schema1     |
      | conn_0 | True     | select * from global_sequence                                               | length{(5)}                                 | schema1     |
      | conn_0 | False     | select * from test1                                                          | length{(5)}                                  | schema2     |
      | conn_0 | False     | /*#dble:shardingNode=dn3*/select * from sharding_2_t1                  | has{(2,'2',2),(4,'4',4)}                      | schema2    |
      | conn_0 | False     | /*#dble:shardingNode=dn4*/select * from sharding_2_t1                   | has{(1,'1',1),(3,'3',3),(5,'5',5)}           | schema2    |
      | conn_0 | False     | /*#dble:shardingNode=dn1*/select * from sharding_4_t3                   | has{(4,'4',4)}                                 | schema2     |
      | conn_0 | False     | /*#dble:shardingNode=dn2*/select * from sharding_4_t3                    | has{(1,'1',1),(5,'5',5),(9,'9',9),(13,'13',13)}  | schema2     |
      | conn_0 | False     | /*#dble:shardingNode=dn3*/select * from sharding_4_t3                    | has{(2,'2',2),(6,'6',6)}                                 | schema2     |
      | conn_0 | True      | /*#dble:shardingNode=dn4*/select * from sharding_4_t3                     | has{(3,'3',3)}                                 | schema2     |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/all_schemas_with_data.sql-dn*.dump
    """

    #3.split with '-s' parameter and the schema exists in dble config, split success and the split out files will consistent with the original dump file
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                             | expect                                                   |
      | split /opt/all_schemas_with_data.sql /opt -sschema1                           | success     |
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
      | conn   | toClose  | sql                                                                            | expect                                       |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from test                              | length{(5)}                                 | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                                 | length{(5)}                                 | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                   | has{(2,'2',2),(4,'4',4)}                   | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                    | has{(1,'1',1),(3,'3',3),(5,'5',5)}       | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                    | has{(4,'4',4)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                    | has{(1,'1',1),(5,'5',5)}                  | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                    | has{(2,'2',2)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                    | has{(3,'3',3)}                              | schema1     |
      | conn_0 | False    | select * from nosharding                                                     | length{(5)}                                 | schema1     |
      | conn_0 | True     | select * from global_sequence                                               | length{(5)}                                 | schema1     |
      | conn_0 | False     | select * from test1                                                         | length{(5)}                                  | schema2     |
      | conn_0 | False     | /*#dble:shardingNode=dn3*/select * from sharding_2_t1                  | has{(2,'2',2),(4,'4',4)}                      | schema2    |
      | conn_0 | False     | /*#dble:shardingNode=dn4*/select * from sharding_2_t1                   | has{(1,'1',1),(3,'3',3),(5,'5',5)}           | schema2    |
      | conn_0 | False     | /*#dble:shardingNode=dn1*/select * from sharding_4_t3                   | has{(4,'4',4)}                                 | schema2     |
      | conn_0 | False     | /*#dble:shardingNode=dn2*/select * from sharding_4_t3                    | has{(1,'1',1),(5,'5',5),(9,'9',9),(13,'13',13)}  | schema2     |
      | conn_0 | False     | /*#dble:shardingNode=dn3*/select * from sharding_4_t3                    | has{(2,'2',2),(6,'6',6)}                                 | schema2     |
      | conn_0 | True      | /*#dble:shardingNode=dn4*/select * from sharding_4_t3                     | has{(3,'3',3)}                                 | schema2     |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/all_schemas_with_data.sql*.dump
    """

  @CRITICAL
  Scenario: test with '--ignore' parameter #5
    Given upload file "./assets/schema1_with_only_data.sql" to "dble-1" success
    #1.split with no '--ignore' parameter, split success and the insert statement will not contains the keyword 'ignore'
#    Then execute sql in "dble-1" in "admin" mode
#      | sql                                                                             | expect                                                   |
#      | split /opt/schema1_with_only_data.sql /opt                                  | success     |
#    #check the split out files exist
#    Then check path "/opt/schema1_with_only_data.sql-dn1-*.dump" in "dble-1" should exist
#    Then check path "/opt/schema1_with_only_data.sql-dn2-*.dump" in "dble-1" should exist
#    Then check path "/opt/schema1_with_only_data.sql-dn3-*.dump" in "dble-1" should exist
#    Then check path "/opt/schema1_with_only_data.sql-dn4-*.dump" in "dble-1" should exist
#    Then check path "/opt/schema1_with_only_data.sql-dn5-*.dump" in "dble-1" should exist


#    Then check following text exist "N" in file "/opt/schema1_with_only_data.sql-dn1-*.dump" in host "dble-1"
#     """
#     ignore
#     """
#    Then check following text exist "N" in file "/opt/schema1_with_only_data.sql-dn2-*.dump" in host "dble-1"
#     """
#     ignore
#     """
#    Then check following text exist "N" in file "/opt/schema1_with_only_data.sql-dn3-*.dump" in host "dble-1"
#     """
#     ignore
#     """
#    Then check following text exist "N" in file "/opt/schema1_with_only_data.sql-dn4-*.dump" in host "dble-1"
#     """
#     ignore
#     """
#    Then check following text exist "N" in file "/opt/schema1_with_only_data.sql-dn5-*.dump" in host "dble-1"
#     """
#     ignore
#     """

    #2.split with '--ignore' parameter, split success and the insert statement contains the keyword 'ignore'
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_only_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                      | db      |
      | conn_0 | False    | create table test(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                             | schema1 |
      | conn_0 | False    | insert into test values(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)                          | schema1 |
      | conn_0 | False    | create table sharding_1_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                  | schema1 |
      | conn_0 | False    | insert into sharding_1_t1 values(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)                | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                   | schema1 |
      | conn_0 | False    | insert into sharding_2_t1 values(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)                  | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                   | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)                  | schema1 |
      | conn_0 | False    | create table nosharding(id int,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))                       | schema1 |
      | conn_0 | False    | insert into nosharding values(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)                      | schema1 |
      | conn_0 | True     | create table global_sequence(id bigint,name varchar(30),age int,PRIMARY KEY(id),INDEX id(name))               | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                                                 | expect                                                   |
      | split /opt/schema1_with_only_data.sql /opt --ignore                                            | success     |
    #check the split out files exist
    Then check path "/opt/schema1_with_only_data.sql-dn1-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn2-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn3-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn4-*.dump" in "dble-1" should exist
    Then check path "/opt/schema1_with_only_data.sql-dn5-*.dump" in "dble-1" should exist

#    Then check following text exist "Y" in file "/opt/schema1_with_only_data.sql-dn1.dump" in host "dble-1"
#     """
#     ignore
#     """
#    Then check following text exist "Y" in file "/opt/schema1_with_only_data.sql-dn2.dump" in host "dble-1"
#     """
#     ignore
#     """
#    Then check following text exist "Y" in file "/opt/schema1_with_only_data.sql-dn3.dump" in host "dble-1"
#     """
#     ignore
#     """
#    Then check following text exist "Y" in file "/opt/schema1_with_only_data.sql-dn4.dump" in host "dble-1"
#     """
#     ignore
#     """
#    Then check following text exist "Y" in file "/opt/schema1_with_only_data.sql-dn5.dump" in host "dble-1"
#     """
#     ignore
#     """

    Given execute oscmd in "dble-1"
     """
      mv /opt/schema1_with_only_data.sql-dn1-*.dump /opt/schema1_with_only_data.sql-dn1.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn1.dump && \
      mv /opt/schema1_with_only_data.sql-dn3-*.dump /opt/schema1_with_only_data.sql-dn3.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn3.dump && \
      mv /opt/schema1_with_only_data.sql-dn5-*.dump /opt/schema1_with_only_data.sql-dn5.dump && mysql -h172.100.9.5 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn5.dump && \
      mv /opt/schema1_with_only_data.sql-dn2-*.dump /opt/schema1_with_only_data.sql-dn2.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn2.dump && \
      mv /opt/schema1_with_only_data.sql-dn4-*.dump /opt/schema1_with_only_data.sql-dn4.dump && mysql -h172.100.9.6 -utest -P3306 -p111111 < /opt/schema1_with_only_data.sql-dn4.dump
     """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                            | expect                                                                        |db          |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from test                              | has{(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)}     | schema1    |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from test                              | has{(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)}     | schema1    |
      | conn_0 | False    | select * from sharding_1_t1                                                 | length{(5)}                                 | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_2_t1                   | has{(2,'20',20),(4,'40',40)}                   | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_2_t1                    | has{(1,'10',10),(3,'30',30),(5,'50',50)}       | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn1*/select * from sharding_4_t1                    | has{(4,'40',40)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn2*/select * from sharding_4_t1                    | has{(1,'10',10),(5,'50',50)}                  | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn3*/select * from sharding_4_t1                    | has{(2,'20',20)}                              | schema1     |
      | conn_0 | False    | /*#dble:shardingNode=dn4*/select * from sharding_4_t1                    | has{(3,'30',30)}                              | schema1     |
      | conn_0 | False    | select * from nosharding                                                     | has{(1,'10',10),(2,'20',20),(3,'30',30),(4,'40',40),(5,'50',50)}   | schema1     |
      | conn_0 | True     | select * from global_sequence                                               | length{(5)}                                     | schema1     |
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_only_data.sql*.dump
    """

  @NORMAL
  Scenario: test with '-l' parameter #6
    Given upload file "./assets/schema1_with_data.sql" to "dble-1" success
    #1.set the -l=1,check the insert values length is 1
    Given execute oscmd in "dble-1"
     """
      rm -rf /opt/schema1_with_data.sql-dn*.dump
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                  | expect                                                   |
      | split /opt/schema1_with_data.sql /opt -l1                       | success      |
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
      | sql                                                                  | expect                                                   |
      | split /opt/schema1_with_data.sql /opt -l2                       | success      |
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
      rm -rf /opt/schema1_with_data.sql*.dump
    """

  @NORMAL
  Scenario: split file with large data(10000w) #6