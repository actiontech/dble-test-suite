# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/11/30

Feature: test manager command :show @@data_distribution where table ='schema.table'
  1.sing /nosharding /vertical table not supported
  2.global /sharding table supported

  Scenario: check manager cmd: "show @@data_distribution where table ='schema.table'" #1
    Then execute sql in "dble-1" in "admin" mode
#case 1 :the schema doesn't exists or table doesn't exists, the result will be reported "doesn't exist"
      | conn   | toClose | sql                                                       | expect                                         |
      | conn_0 | false   | show @@data_distribution where table ='testdb.test'       | The schema testdb doesn't exist                |
      | conn_0 | True    | show @@data_distribution where table ='schema1.testtable' | The table 'schema1.testtable' doesn't exist    |

     Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
      <schema shardingNode="dn1" name="schema2" sqlMaxLimit="100">
         <singleTable name="sing" shardingNode="dn4" />
         <shardingTable name="sharding_4_t3" shardingNode="dn1,dn3,dn5" function="fixed_uniform_string_rule" shardingColumn="id"/>
      </schema>

      <schema shardingNode="dn5" name="schema3" sqlMaxLimit="100" />

      <function name="fixed_uniform_string_rule" class="StringHash">
        <property name="partitionCount">2,1</property>
        <property name="partitionLength">256,512</property>
        <property name="hashSlice">0:2</property>
      </function>
     """
     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
     """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
     """
      Then execute admin cmd "reload @@config"
#case 2 :the schema or table exists, cmd on admin mode ro check values
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_1 | false   | drop table if exists test                       | success | schema1 |
      | conn_1 | false   | drop table if exists sharding_2_t1              | success | schema1 |
      | conn_1 | false   | drop table if exists nosharding                 | success | schema1 |
      | conn_2 | false   | drop table if exists sing                       | success | schema2 |
      | conn_2 | false   | drop table if exists sharding_4_t3              | success | schema2 |
      | conn_3 | false   | drop table if exists vertical                   | success | schema3 |
      | conn_1 | false   | create table test (id int,id2 int)              | success | schema1 |
      | conn_1 | false   | create table sharding_2_t1 (id int,id2 int)     | success | schema1 |
      | conn_1 | false   | create table nosharding (id int,id2 int)        | success | schema1 |
      | conn_2 | false   | create table sing (id int,id2 int)              | success | schema2 |
      | conn_2 | false   | create table sharding_4_t3 (id char(5),id2 int) | success | schema2 |
      | conn_3 | false   | create table vertical (id int,id2 int)          | success | schema3 |
#case 2.1 :no insert values
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                                                |
      | conn_0 | false   | show @@data_distribution where table ='schema1.test'          | has{(('dn1', 0), ('dn2', 0), ('dn3', 0), ('dn4', 0))} |
      | conn_0 | false   | show @@data_distribution where table ='schema1.sharding_2_t1' | has{(('dn1', 0), ('dn2', 0))}                         |
      | conn_0 | false   | show @@data_distribution where table ='schema1.nosharding'    | The table 'schema1.nosharding' doesn't exist          |
      | conn_0 | false   | show @@data_distribution where table ='schema2.sing'          | The table 'schema2.sing' is Single table              |
      | conn_0 | false   | show @@data_distribution where table ='schema2.sharding_4_t3' | has{(('dn1', 0), ('dn3', 0), ('dn5', 0))}             |
      | conn_0 | false   | show @@data_distribution where table ='schema3.vertical'      | The schema schema3 is no sharding schema              |
#case 2.2 :insert some values,the result will be correct
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                           | expect  | db      |
      | conn_1 | false   | insert into test values (1,1)                 | success | schema1 |
      | conn_1 | false   | insert into sharding_2_t1 values (1,1)        | success | schema1 |
      | conn_1 | false   | insert into nosharding values (1,1)           | success | schema1 |
      | conn_2 | false   | insert into sing values (1,1)                 | success | schema2 |
      | conn_2 | false   | insert into sharding_4_t3 values ("test",1)   | success | schema2 |
      | conn_3 | false   | insert into vertical values (1,1)             | success | schema3 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                                                |
      | conn_0 | false   | show @@data_distribution where table ='schema1.test'          | has{(('dn1', 1), ('dn2', 1), ('dn3', 1), ('dn4', 1))} |
      | conn_0 | false   | show @@data_distribution where table ='schema1.sharding_2_t1' | has{(('dn1', 0), ('dn2', 1))}                         |
      | conn_0 | false   | show @@data_distribution where table ='schema1.nosharding'    | The table 'schema1.nosharding' doesn't exist          |
      | conn_0 | false   | show @@data_distribution where table ='schema2.sing'          | The table 'schema2.sing' is Single table              |
      | conn_0 | false   | show @@data_distribution where table ='schema2.sharding_4_t3' | has{(('dn1', 0), ('dn3', 0), ('dn5', 1))}             |
      | conn_0 | false   | show @@data_distribution where table ='schema3.vertical'      | The schema schema3 is no sharding schema              |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | false   | insert into test values (2,2),(3,3)          | success | schema1 |
      | conn_1 | false   | insert into sharding_2_t1 values (2,2),(4,4) | success | schema1 |
      | conn_2 | false   | insert into sharding_4_t3 values ("a",1)     | success | schema2 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                                                |
      | conn_0 | false   | show @@data_distribution where table ='schema1.test'          | has{(('dn1', 3), ('dn2', 3), ('dn3', 3), ('dn4', 3))} |
      | conn_0 | false   | show @@data_distribution where table ='schema1.sharding_2_t1' | has{(('dn1', 2), ('dn2', 1))}                         |
      | conn_0 | false   | show @@data_distribution where table ='schema2.sharding_4_t3' | has{(('dn1', 1), ('dn3', 0), ('dn5', 1))}             |
#case 2.3 :insert more values on global table,the result will be correct and values equal "select * from table"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect         | db      |
      | conn_1 | false   | insert into test (id) select id from test | success        | schema1 |
      | conn_1 | false   | insert into test (id) select id from test | success        | schema1 |
      | conn_1 | false   | insert into test (id) select id from test | success        | schema1 |
      | conn_1 | false   | insert into test (id) select id from test | success        | schema1 |
      | conn_1 | false   | select count(*) from test                 | has{((48,),)}  | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                                                    |
      | conn_0 | false   | show @@data_distribution where table ='schema1.test'          | has{(('dn1', 48), ('dn2', 48), ('dn3', 48), ('dn4', 48))} |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect         | db      |
      | conn_1 | false   | insert into test (id) select id from test | success        | schema1 |
      | conn_1 | false   | insert into test (id) select id from test | success        | schema1 |
      | conn_1 | false   | insert into test (id) select id from test | success        | schema1 |
      | conn_1 | false   | insert into test (id) select id from test | success        | schema1 |
      | conn_1 | false   | select * from test limit 1000             | length{(768)}  | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                                                        |
      | conn_0 | false   | show @@data_distribution where table ='schema1.test'          | has{(('dn1', 768), ('dn2', 768), ('dn3', 768), ('dn4', 768))} |
#case 2.3.1 insert values on backend mysql to check in admin mode,the result will be correct
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                          | expect       | db  |
      | conn_4 | True    | insert into test values (4,4),(5,5)          | success      | db1 |
      | conn_4 | True    | insert into test values (6,6)                | success      | db2 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                                                        |
      | conn_0 | false   | show @@data_distribution where table ='schema1.test'          | has{(('dn1', 770), ('dn2', 768), ('dn3', 769), ('dn4', 768))} |
#case 2.3.2  backend mysql drop table,the result will be reture "occur Exception"
    Given record current dble log line number in "log_linenu"
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                          | expect       | db  |
      | conn_4 | True    | drop table if exists test                    | success      | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                                                        |
      | conn_0 | false   | show @@data_distribution where table ='schema1.test'          | occur Exception, so see dble.log to check reason              |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    error response errNo:1146, Table
    exist from of sql :SELECT COUNT
    AS COUNT FROM test
    """
#case 2.4 :insert more values on sharding table function :Hash,the result will be correct
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                          | expect       | db  |
      | conn_4 | True    | insert into sharding_2_t1 values (3,3)       | success      | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                             |
      | conn_0 | false   | show @@data_distribution where table ='schema1.sharding_2_t1' | has{(('dn1', 3), ('dn2', 1))}      |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                          | expect       | db  |
      | conn_4 | True    | insert into sharding_2_t1 values (3,3)       | success      | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                             |
      | conn_0 | false   | show @@data_distribution where table ='schema1.sharding_2_t1' | has{(('dn1', 3), ('dn2', 2))}      |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                                               | expect       | db  |
      | conn_4 | false   | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
      | conn_4 | false   | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
      | conn_4 | false   | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
      | conn_4 | false   | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
      | conn_4 | false   | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
      | conn_4 | false   | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
      | conn_4 | True    | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                                               | expect       | db  |
      | conn_4 | false   | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
      | conn_4 | false   | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
      | conn_4 | false   | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
      | conn_4 | false   | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
      | conn_4 | false   | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
      | conn_4 | True    | insert into sharding_2_t1 (id) select id from sharding_2_t1       | success      | db1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect         | db      |
      | conn_1 | false   | select * from sharding_2_t1 limit 1000              | length{(512)}  | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                                 |
      | conn_0 | false   | show @@data_distribution where table ='schema1.sharding_2_t1' | has{(('dn1', 384), ('dn2', 128))}      |
#case 2.4.1  backend mysql drop table,the result will be reture "occur Exception"
    Given record current dble log line number in "log_linenu"
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                          | expect       | db  |
      | conn_4 | True    | drop table if exists sharding_2_t1           | success      | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                    | expect                                                        |
      | conn_0 | false   | show @@data_distribution where table ='schema1.sharding_2_t1'          | occur Exception, so see dble.log to check reason              |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    error response errNo:1146, Table
    exist from of sql :SELECT COUNT
    AS COUNT FROM sharding_2_t1
    """
#case 2.5 :insert more values on sharding table function :fixed_uniform_string_rule ,the result will be correct
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect  | db      |
      | conn_2 | false   | insert into sharding_4_t3 values ("kai",1)     | success | schema2 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                                                |
      | conn_0 | false   | show @@data_distribution where table ='schema2.sharding_4_t3' | has{(('dn1', 1), ('dn3', 1), ('dn5', 1))}             |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                                               | expect       | db  |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db1 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db1 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db1 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db1 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db1 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db1 |
      | conn_4 | True    | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db1 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db2 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db2 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db2 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db2 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db2 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db2 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db2 |
      | conn_4 | True    | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db2 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db3 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db3 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db3 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db3 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db3 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db3 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db3 |
      | conn_4 | false   | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db3 |
      | conn_4 | True    | insert into sharding_4_t3 (id) select id from sharding_4_t3       | success      | db3 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect        | db      |
      | conn_2 | false   | select * from sharding_4_t3 limit 10000        | length{(896)} | schema2 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect                                                |
      | conn_0 | false   | show @@data_distribution where table ='schema2.sharding_4_t3' | has{(('dn1', 128), ('dn3', 256), ('dn5', 512))}       |
#case 2.5.1  backend mysql drop table,the result will be reture "occur Exception"
    Given record current dble log line number in "log_linenu"
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                          | expect       | db  |
      | conn_4 | True    | drop table if exists sharding_4_t3           | success      | db2 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                    | expect                                                        |
      | conn_0 | True    | show @@data_distribution where table ='schema2.sharding_4_t3'          | occur Exception, so see dble.log to check reason              |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    error response errNo:1146, Table
    exist from of sql :SELECT COUNT
    AS COUNT FROM sharding_4_t3
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_1 | false   | drop table if exists test                       | success | schema1 |
      | conn_1 | false   | drop table if exists sharding_2_t1              | success | schema1 |
      | conn_1 | True    | drop table if exists nosharding                 | success | schema1 |
      | conn_2 | false   | drop table if exists sing                       | success | schema2 |
      | conn_2 | True    | drop table if exists sharding_4_t3              | success | schema2 |
      | conn_3 | True    | drop table if exists vertical                   | success | schema3 |