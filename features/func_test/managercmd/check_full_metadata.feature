# Created by maofei at 2018/12/21
Feature: test "check full @@metadata...'"

  @CRITICAL
  Scenario: config same table name in different schema #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="mytest" sqlMaxLimit="100" dataNode="dn1">
    <table name="test_shard" dataNode="dn2,dn3" rule="hash-two"/>
    </schema>
    <schema name="testdb" sqlMaxLimit="100" dataNode="dn1">
    <table name="test_shard" dataNode="dn4,dn5" rule="hash-two"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test">
        <property name="password">111111</property>
        <property name="schemas">mytest,testdb</property>
    </user>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                | expect          | db     |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                    | success         | mytest |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                    | success         | testdb |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,name char)          | success         | mytest |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,name char,age int)  | success         | testdb |
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                  | expect                                          | db     |
      | test | 111111 | conn_0 | True    | insert into test_shard values(1,1,1) | Column count doesn't match value count at row 1 | mytest |
      | test | 111111 | conn_0 | True    | insert into test_shard values(1,1)   | success                                         | mytest |
      | test | 111111 | conn_0 | True    | insert into test_shard values(1,1)   | Column count doesn't match value count at row 1 | testdb |
      | test | 111111 | conn_0 | True    | insert into test_shard values(1,1,1) | success                                         | testdb |
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                                                | expect                               | db |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_shard' | hasNoStr{`age` int(11) DEFAULT NULL} |    |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_shard' | hasStr{`id` int(11) DEFAULT NULL}    |    |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='testdb' and table='test_shard' | hasStr{`age` int(11) DEFAULT NULL}   |    |

  @CRITICAL
  Scenario: config no-sharding table's name is same as sharding table's name, their metadatas are not affected by each other #2
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                      | expect  | db       |
      | test | 111111 | conn_0 | True    | drop table if exists test1                               | success | mytest   |
      | test | 111111 | conn_0 | True    | create table test1(id int,name1 char,age int,name2 char) | success | mytest   |
      | test | 111111 | conn_0 | True    | insert into test1 values(1,1,1,1)                        | success | mytest   |
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                                           | expect                                   | db    |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test1' | hasStr{`name2` char(1) DEFAULT NULL} |       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test">
        <property name="password">111111</property>
        <property name="schemas">mytest,testdb</property>
    </user>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="mytest" sqlMaxLimit="100" dataNode="dn1">
    <table name="test1" dataNode="dn2,dn3" rule="hash-two"/>
    </schema>
    <schema name="testdb" sqlMaxLimit="100" dataNode="dn1">
    <table name="test1" dataNode="dn4,dn5" type="global"/>
    </schema>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                            | expect  | db     |
      | test | 111111 | conn_0 | True    | drop table if exists test1                     | success | mytest |
      | test | 111111 | conn_0 | True    | create table test1(id int,name char,age int)   | success | mytest |
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                               | expect                                          | db       |
      | test | 111111 | conn_0 | True    | insert into test1 values(1,1,1,1) | Column count doesn't match value count at row 1 | mytest   |
      | test | 111111 | conn_0 | True    | insert into test1 values(2,2,2)   | success                                         | mytest   |
      | test | 111111 | conn_0 | True    | alter table test1 drop name       | success                                         | mytest   |
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                                           | expect                             | db   |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test1' | hasStr{`age` int(11) DEFAULT NULL} |      |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test1' | hasNoStr{`name`}                   |      |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test1' | hasNoStr{`name2`}                  |      |
      | root | 111111 | conn_0 | True    | check @@metadata                                              | success                            |      |

  @CRITICAL
  Scenario: config no-sharding table's name is same as global table's name, their metadatas are not affected by each other #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test">
        <property name="password">111111</property>
        <property name="schemas">mytest,testdb</property>
    </user>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="mytest" sqlMaxLimit="100" dataNode="dn1">
    <table name="test1" dataNode="dn2,dn3" rule="hash-two"/>
    </schema>
    <schema name="testdb" sqlMaxLimit="100" dataNode="dn1">
    <table name="test1" dataNode="dn4,dn5" type="global"/>
    </schema>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose  | sql                         | expect   | db       |
      | test | 111111 | conn_0 | True     | drop table if exists test1  | success  | testdb   |
      | test | 111111 | conn_0 | True     | create table test1(id int)  | success  | testdb   |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect                                                         | db      |
      | test | 111111 | conn_0 | True    | insert into test1 values(1,1,1,1)  | In insert Syntax, you can't set value for Global check column! | testdb  |
      | test | 111111 | conn_0 | True    | insert into test1 values(2,2)      | In insert Syntax, you can't set value for Global check column! | testdb  |
      | test | 111111 | conn_0 | True    | insert into test1 values(3)        | success                                                        | testdb  |
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                                           | expect                               | db |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='testdb' and table='test1' | hasNoStr{`age` int(11) DEFAULT NULL} |    |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='testdb' and table='test1' | hasStr{`id`}                         |    |
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect                                                          | db      |
      | test | 111111 | conn_0 | True    | insert into test1 values(1,1,1,1)  |  In insert Syntax, you can't set value for Global check column! | testdb  |
      | test | 111111 | conn_0 | True    | insert into test1 values(2,2)      | In insert Syntax, you can't set value for Global check column!  | testdb  |
      | test | 111111 | conn_0 | True    | insert into test1 values(3)        | success                                                         | testdb  |
      | test | 111111 | conn_0 | True    | alter table test1 add name char    | success                                                         | testdb  |
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                                           | expect                               | db |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='testdb' and table='test1' | hasNoStr{`age` int(11) DEFAULT NULL} |    |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='testdb' and table='test1' | hasStr{`name`}                       |    |

  @CRITICAL
  Scenario: config no tables in node schema, then create 1 table in default node and do ddl,reload @@metadata, check table's metadata during the procedure #4
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose  | sql                         | expect   | db     |
      | test | 111111 | conn_0 | True     | drop database if exists db3 | success  |        |
      | test | 111111 | conn_0 | True     | create database db3         | success  |        |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="mytest" sqlMaxLimit="100" dataNode="dn5">
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                         | expect     | db      |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' | success    |         |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                         | expect      | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test                   | success     | mytest  |
      | test | 111111 | conn_0 | True    | create table test(id int,name char,age int) | success     | mytest  |
      | test | 111111 | conn_0 | True    | insert into test values(1,1,1)              | success     | mytest  |
      | test | 111111 | conn_0 | True    | alter table test drop name                  | success     | mytest  |
      | test | 111111 | conn_0 | True    | insert into test values(2,2)                | success     | mytest  |
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                          | expect                             | db   |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest'  |hasStr{`age` int(11) DEFAULT NULL}  |      |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest'  |hasNoStr{`name`}                    |      |
      | root | 111111 | conn_0 | True    | reload @@metadata                            | success                            |      |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                          | expect  | db       |
      | test | 111111 | conn_0 | True    | insert into test values(3,3) | success | mytest   |
      | test | 111111 | conn_0 | True    | alter table test drop age    | success | mytest   |
      | test | 111111 | conn_0 | True    | insert into test values(4)   | success | mytest   |
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                            | expect                               | db  |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest'    |hasNoStr{`age` int(11) DEFAULT NULL}  |     |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest'    |hasStr{`id` int(11) DEFAULT NULL}     |     |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                       | expect  | db     |
      | test | 111111 | conn_0 | True    | drop table if exists test | success | mytest |

  @CRITICAL
  Scenario: backend tables in datanode are inconsistent or lack in some datanode for a config sharding/global table, check metadata and query #5
    """
    5.1 the table structure of the sharding table in the datanode is different
    5.2 Part of the datanode sharding table does not exist
    5.3 the table structure of the global table in the datanode is different'
    5.4 Part of the datanode global table does not exist
    ps:the order of show create table is stable: show create table test4;show create table test5;show create table test2;show create table test3;show create table test6;show create table test1;
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="mytest" sqlMaxLimit="100" dataNode="dn5">
      <table name="test1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="id"/>
      <table name="test2" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="id"/>
      <table name="test3" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="id"/>
      <table name="test4" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="id"/>
      <table name="test5" dataNode="dn1,dn2,dn3,dn4" type="global"/>
      <table name="test6" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd         | conn   | toClose | sql                                            | expect  | db       |
      | test | 111111         | conn_0 | True    | drop table if exists test1                     | success | mytest   |
      | test | 111111         | conn_0 | True    | create table test1(id int,name char,age int)   | success | mytest   |
      | test | 111111         | conn_0 | True    | drop table if exists test2                     | success | mytest   |
      | test | 111111         | conn_0 | True    | create table test2(id int,name char,age int)   | success | mytest   |
      | test | 111111         | conn_0 | True    | drop table if exists test3                     | success | mytest   |
      | test | 111111         | conn_0 | True    | create table test3(id int,name char,age int)   | success | mytest   |
      | test | 111111         | conn_0 | True    | drop table if exists test4                     | success | mytest   |
      | test | 111111         | conn_0 | True    | create table test4(id int,name char,age int)   | success | mytest   |
      | test | 111111         | conn_0 | True    | drop table if exists test5                     | success | mytest   |
      | test | 111111         | conn_0 | True    | create table test5(id int,name char,age int)   | success | mytest   |
      | test | 111111         | conn_0 | True    | drop table if exists test6                     | success | mytest   |
    #5.1
     Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose  | sql                        | expect   | db      |
      | test | 111111 | conn_0 | True     |alter table test4 drop age  | success  | db1     |
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                             | expect   | db        |
      | test  | 111111 | conn_0 | True    | select * from test2             | success  | mytest   |
      | test  | 111111 | conn_0 | True    | insert into test2 values(1,1,1) | success  | mytest   |
      | test  | 111111 | conn_0 | True    | alter table test2 drop name     | success  | mytest   |
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                                  | expect              | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where consistent_in_data_nodes =0       | hasStr{`test4`}   | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where consistent_in_data_nodes =0       | hasNoStr{`test2`} | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where consistent_in_data_nodes =1       | hasStr{`test2`}   | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where consistent_in_data_nodes =1       | hasNoStr{`test4`} | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test2'| hasNoStr{`name`}   | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test2'| hasStr{`age`}      | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test6'| hasNoStr{`id`}      | mytest |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                        | expect                       | db     |
      | test  | 111111 | conn_0 | True    | alter table test4 drop age | check that column/key exists | mytest |
    #5.2
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose  | sql                               | expect   | db      |
      | test | 111111 | conn_0 | True     |drop table if exists test4         | success  | db1     |
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                              | expect   | db       |
      | test  | 111111 | conn_0 | True    | select * from test2              | success  | mytest   |
      | test  | 111111 | conn_0 | True    | insert into test2 values(1,1)    | success  | mytest   |
      | test  | 111111 | conn_0 | True    | alter table test2 add name char  | success  | mytest   |
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                          | expect             | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where consistent_in_data_nodes =0      | hasStr{`test4`}    | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test2'| hasStr{`name`}     | mytest |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                            | expect                           | db        |
      | test  | 111111 | conn_0 | True    | alter table test4 drop name                    | Table 'db1.test4' doesn't exist  | mytest   |
      | test  | 111111 | conn_0 | True    | drop table if exists test4                     | success                          | mytest   |
      | test  | 111111 | conn_0 | True    | drop table if exists test2                     | success                          | mytest   |
      | test  | 111111 | conn_0 | True    | create table test2(id int,name char,age int)   | success                            | mytest   |
    #5.3
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose  | sql                                 | expect   | db      |
      | test | 111111 | conn_0 | True     |alter table test5 drop age        | success  | db1     |
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                 | expect   | db        |
      | test  | 111111 | conn_0 | True    | select * from test2               | success  | mytest   |
      | test  | 111111 | conn_0 | True    | insert into test2 values(1,1,1) | success  | mytest   |
      | test  | 111111 | conn_0 | True    | alter table test2 drop name      | success  | mytest   |
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                                  | expect              | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where consistent_in_data_nodes =0       | hasStr{`test5`}   | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where consistent_in_data_nodes =0       | hasNoStr{`test2`} | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where consistent_in_data_nodes =1       | hasStr{`test2`}   | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where consistent_in_data_nodes =1       | hasNoStr{`test5`} | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test2'| hasNoStr{`name`}   | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test2'| hasStr{`age`}      | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test6'| hasNoStr{`id`}      | mytest |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                 | expect                              | db        |
      | test  | 111111 | conn_0 | True    | alter table test5 drop age       | check that column/key exists     | mytest   |
    #5.4
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose  | sql                                  | expect   | db      |
      | test | 111111 | conn_0 | True     |drop table if exists test5         | success  | db1     |
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                  | expect   | db        |
      | test  | 111111 | conn_0 | True    | select * from test2                | success  | mytest   |
      | test  | 111111 | conn_0 | True    | insert into test2 values(1,1)    | success  | mytest   |
      | test  | 111111 | conn_0 | True    | alter table test2 add name char  | success  | mytest   |
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                                  | expect               | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where consistent_in_data_nodes =0       | hasStr{`test5`}    | mytest |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test2'| hasStr{`name`}      | mytest |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                         | expect                              | db        |
      | test  | 111111 | conn_0 | True    | alter table test5 drop name | Table 'db1.test5' doesn't exist  | mytest   |
      | test  | 111111 | conn_0 | True    | drop table if exists test5  | success                             | mytest   |
      | test  | 111111 | conn_0 | True    | drop table if exists test2  | success                             | mytest   |

  @NORMAL
  Scenario: Some of datahost's writehost(with or without readhost) cannot be connectted, check metadata and query #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="mytest" sqlMaxLimit="100" dataNode="dn5">
      <table name="test_shard" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="id"/>
      <table name="test_two" dataNode="dn2,dn4" rule="hash-two" primaryKey="id"/>
    </schema>

    <dataHost balance="3" maxCon="1000" minCon="10" name="172.100.9.6" slaveThreshold="-1" switchType="1">
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
        <readHost host="hostS2" url="172.100.9.2:3306" password="111111" user="test"/>
        </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                   | expect   | db     |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                       | success  | mytest |
      | test | 111111 | conn_0 | True    | drop table if exists test_two                         | success  | mytest |
      | test | 111111 | conn_0 | True    | drop table if exists test_no_shard                    | success  | mytest |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,name char,age int)     | success  | mytest |
      | test | 111111 | conn_0 | True    | create table test_two(id int,name char,age int)       | success  | mytest |
      | test | 111111 | conn_0 | True    | create table test_no_shard(id int,name1 char,age int) | success  | mytest |
    #6.1 Unable to connect to datahost does not exist readhost
    Given stop mysql in host "mysql-master1"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                   | expect              | db     |
      | test | 111111 | conn_0 | True    | insert into test_shard values(1,1,1)  | success             | mytest |
      | test | 111111 | conn_0 | True    | alter table test_two drop age         | success             | mytest |
      | test | 111111 | conn_0 | True    | alter table test_shard drop name      | error totally whack | mytest |
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                                                | expect                             | db  |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_shard' | hasStr{`name` }                    |     |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_two'   | hasStr{`id` int(11) DEFAULT NULL}  |     |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_two'   | hasNoStr{`age`}                    |     |
      | root | 111111 | conn_0 | True    | show @@version                                                     | success                            |     |
      | root | 111111 | conn_0 | True    | reload @@metadata                                                  | success                            |     |
    Given start mysql in host "mysql-master1"
    #6.2 Unable to connect to datahost has readhost
    Given stop mysql in host "mysql-master2"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                    | expect              | db     |
      | test | 111111 | conn_0 | True    | insert into test_shard values(2,2,2)   | success             | mytest |
      | test | 111111 | conn_0 | True    | alter table test_no_shard drop age     | success             | mytest |
      | test | 111111 | conn_0 | True    | alter table test_shard drop name       | error totally whack | mytest |
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                                                   | expect                             | db  |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_shard'    | hasStr{`name` }                    |     |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_no_shard' | hasStr{`id` int(11) DEFAULT NULL}  |     |
      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_no_shard' | hasNoStr{`age`}                    |     |
      | root | 111111 | conn_0 | True    | show @@version                                                        | success                            |     |
      | root | 111111 | conn_0 | True    | reload @@metadata                                                     | success                            |     |
    Given start mysql in host "mysql-master2"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect  | db     |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard    | success | mytest |
      | test | 111111 | conn_0 | True    | drop table if exists test_two      | success | mytest |
      | test | 111111 | conn_0 | True    | drop table if exists test_no_shard | success | mytest |

  @regression
  Scenario: default schema table or sharding table contains view in part of backend database,  check metadata and query #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="mytest" sqlMaxLimit="100" dataNode="dn5">
      <table name="test_shard" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                               | expect   | db     |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                   | success  | mytest |
      | test | 111111 | conn_0 | True    | drop table if exists test_no_shard                | success  | mytest |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,name char,age int) | success  | mytest |
      | test | 111111 | conn_0 | True    | create table test_no_shard(id int,name1 char)     | success  | mytest |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose  | sql                                                  | expect   | db      |
      | test | 111111 | conn_0 | True     |drop view if exists view_test                         | success  | db1     |
      | test | 111111 | conn_0 | True     |create view view_test as select * from test_shard     | success  | db1     |
      | test | 111111 | conn_0 | True     |drop view if exists view_test1                        | success  | db3     |
      | test | 111111 | conn_0 | True     |create view view_test1 as select * from test_no_shard | success  | db3     |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                     | expect   | db     |
      | test | 111111 | conn_0 | True    | insert into test_shard values(1,1,1)    | success  | mytest |
      | test | 111111 | conn_0 | True    | insert into test_no_shard values(1,1)   | success  | mytest |
      | test | 111111 | conn_0 | True    | alter table test_shard drop age         | success  | mytest |
      | test | 111111 | conn_0 | True    | alter table test_no_shard add age int   | success  | mytest |
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                                   | expect                | db |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest'                           | hasNoStr{view_test}   |    |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_shard'    | hasNoStr{age}         |    |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_shard'    | hasStr{name}          |    |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_no_shard' | hasStr{name1}         |    |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_no_shard' | hasStr{age}           |    |
      | root  | 111111 | conn_0 | True    | show @@version                                                        | success               |    |
      | root  | 111111 | conn_0 | True    | reload @@metadata                                                     | success               |    |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose  | sql                               | expect   | db      |
      | test | 111111 | conn_0 | True     |drop view view_test                | success  | db1     |
      | test | 111111 | conn_0 | True     |drop view view_test1               | success  | db3     |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                    | expect   | db     |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard        | success  | mytest |
      | test | 111111 | conn_0 | True    | drop table if exists test_no_shard     | success  | mytest |

  @regression
  Scenario: meta data check should ignore AUTO_INCREMENT difference, check matadate、rload and dble.log #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
      """
      <schema name="mytest" sqlMaxLimit="100" dataNode="dn1">
      <table name="test_shard" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
      <table name="mytest_auto_test1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="R_REGIONKEY" autoIncrement="true"/>
      </schema>
      <dataNode name="dn1" dataHost="host1" database="db1"/>
      <dataNode name="dn2" dataHost="host1" database="db2"/>
      <dataNode name="dn3" dataHost="host1" database="db3"/>
      <dataNode name="dn4" dataHost="host1" database="db4"/>
      <dataHost balance="0" maxCon="1000" minCon="5" name="host1" switchType="2" slaveThreshold="100">
      <heartbeat>show slave status</heartbeat>
      <writeHost host="hostM1" url="172.100.9.5:3306" password="111111" user="test">
      </writeHost>
      </dataHost>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                               | expect   | db     |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                   | success  | mytest |
      | test | 111111 | conn_0 | True    | CREATE TABLE test_shard (id BIGINT PRIMARY KEY AUTO_INCREMENT,clientNum CHAR(20) NOT NULL ) | success  | mytest |
      | test | 111111 | conn_0 | True    | insert into test_shard values(1,1),(2,2),(3,3),(4,4),(5,5)  | success  | mytest |
    Then execute admin cmd "reload @@config_all"
    Then check following "not" exist in file "dble.log" in "dble-1"
      """
      CREATE TABLE `test_shard`
      """
    Then execute admin cmd "reload @@metadata"
    Then check following "not" exist in file "dble.log" in "dble-1"
      """
      CREATE TABLE `test_shard`
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
       """
       <system>
       <property name="checkTableConsistency">1</property>
       <property name="checkTableConsistencyPeriod">1000</property>
       </system>
       """
    Given Restart dble in "dble-1" success
    Then check following "not" exist in file "dble.log" in "dble-1"
      """
      CREATE TABLE `test_shard`
      """
    Given sleep "1" seconds
    Then check following "not" exist in file "dble.log" in "dble-1"
      """
      CREATE TABLE `test_shard`
      """
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                                  | expect              | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where consistent_in_data_nodes =0       | hasNoStr{`test_shard`}   | mytest |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                               | expect   | db     |
      | test | 111111 | conn_0 | True    | drop table if exists mytest_auto_test1                   | success  | mytest |
      | test | 111111 | conn_0 | True    | create table mytest_auto_test1 (id int(11),R_REGIONKEY bigint primary key AUTO_INCREMENT,R_NAME varchar(50),R_COMMENT varchar(50)) | success  | mytest |
      | test | 111111 | conn_0 | True    | insert into mytest_auto_test1(id,R_NAME,R_COMMENT) values(1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5)  | success  | mytest |
    Then execute admin cmd "reload @@config_all"
    Then check following "not" exist in file "dble.log" in "dble-1"
      """
      CREATE TABLE `mytest_auto_test1`
      """
    Then execute admin cmd "reload @@metadata"
    Then check following "not" exist in file "dble.log" in "dble-1"
      """
      CREATE TABLE `mytest_auto_test1`
      """
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                                  | expect              | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where consistent_in_data_nodes =0       | hasNoStr{`mytest_auto_test1`}   | mytest |
