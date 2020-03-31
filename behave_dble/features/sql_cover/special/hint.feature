# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: verify hint sql

  @NORMAL
  Scenario: test hint format: /*!dble:datanode=xxx*/ #1
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn3" rule="hash-two" />
        <table name="test_shard" dataNode="dn1,dn3" rule="hash-two" />
        <table name="test_index" dataNode="dn1,dn3" rule="hash-two" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                         | expect  | db      |
      | test | 111111 | new    | False   | drop table if exists test_table                                                                             | success | schema1 |
      | test | 111111 | new    | False   | drop table if exists test_index                                                                             | success | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:datanode=dn1*/ create table test_table(id int,name varchar(20))                                     | success | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:datanode=dn1*/ create table test_index(id int,name varchar(20),index ddd (name) KEY_BLOCK_SIZE = 1) | success | schema1 |
      | test | 111111 | conn_0 | True    | /*!dble:datanode=dn1*/ insert into test_table values(2,'test2')                                             | success | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                      | expect                  | db  |
      | test | 111111 | new    | False   | show tables              | has{('test_table'),}    | db1 |
      | test | 111111 | new    | False   | show tables              | has{('test_index'),}    | db1 |
      | test | 111111 | conn_0 | True    | select * from test_table | has{(2L, 'test2'),}     | db1 |
      | test | 111111 | new    | False   | show tables              | hasnot{('test_table'),} | db2 |
      | test | 111111 | new    | False   | show tables              | hasnot{('test_index'),} | db2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                  | expect                                   | db      |
      | test | 111111 | new    | False   | /*!dble:datanod=dn1*/ drop table test_table                                                          | Not supported hint sql type : datanod    | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/ drop table test_table                                                         | success                                  | schema1 |
      | test | 111111 | conn_0 | False   | drop table if exists test_shard                                                                      | success                                  | schema1 |
      | test | 111111 | conn_0 | False   | create table test_table (id int ,name varchar(20))                                                   | success                                  | schema1 |
      | test | 111111 | conn_0 | False   | create table test_shard(id int,name varchar(20))                                                     | success                                  | schema1 |
      | test | 111111 | conn_0 | False   | insert into test_table values(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4') | success                                  | schema1 |
      | test | 111111 | conn_0 | False   | insert into test_shard values(4,'test_shard4'),(5,'test_shard5'),(6,'test_shard6'),(7,'test_shard7') | success                                  | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:datanode=dn1*/ select * from test_table                                                      | has{(2,'test_table2'),(4,'test_table4')} | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:datanode=dn1,dn3*/ select * from test_table                                                  | can't find hint datanode:dn1,dn3         | schema1 |
      | test | 111111 | conn_0 | True    | /*!dble:datanode=dn1*/ update test_table set name = 'dn1'                                            | success                                  | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn | toClose | sql                      | expect                                   | db  |
      | test | 111111 | new  | True    | select * from test_table | has{(2,'dn1'),(4,'dn1')}                 | db1 |
      | test | 111111 | new  | True    | select * from test_table | has{(1,'test_table1'),(3,'test_table3')} | db2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                                           | expect  | db      |
      | test | 111111 | new  | True    | /*!dble:datanode=dn1*/ delete from test_table | success | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn | toClose | sql                      | expect                                   | db  |
      | test | 111111 | new  | True    | select * from test_table | length{(0)}                              | db1 |
      | test | 111111 | new  | True    | select * from test_table | has{(1,'test_table1'),(3,'test_table3')} | db2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                                                                                     | expect  | db      |
      | test | 111111 | new  | True    | /*!dble:datanode=dn1*/ insert into test_table select id,name from test_shard where id>4 | success | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn | toClose | sql                      | expect                     | db  |
      | test | 111111 | new  | True    | select * from test_table | has{(6, 'test_shard6')}    | db1 |
      | test | 111111 | new  | True    | select * from test_table | hasnot{(6, 'test_shard6')} | db2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                                                                                   | expect  | db      |
      | test | 111111 | new  | True    | /*!dble:datanode=dn3*/ replace test_table select id,name from test_shard where id < 7 | success | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn | toClose | sql                      | expect                     | db  |
      | test | 111111 | new  | True    | select * from test_table | hasnot{(5, 'test_shard5')} | db1 |
      | test | 111111 | new  | True    | select * from test_table | has{(5, 'test_shard5')}    | db2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                                                             | expect    | db      |
      | test | 111111 | new  | True    | /*!dble:datanode=dn3*/ select count(*) from test_shard          | has{(2),} | schema1 |
      | test | 111111 | new  | True    | /*!dble:datanode=dn1*/ alter table test_table add c varchar(20) | success   | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn | toClose | sql             | expect       | db  |
      | test | 111111 | new  | True    | desc test_table | length{(3)}} | db1 |
      | test | 111111 | new  | True    | desc test_table | length{(2)}} | db2 |

  @NORMAL
  Scenario: test hint format: /*!dble:sql=xxx*/ #2
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn3" rule="hash-two" />
        <table name="test_shard" dataNode="dn1,dn3" rule="hash-two" />
        <table name="test_index" dataNode="dn1,dn3" rule="hash-two" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                                      | expect  | db      |
      | test | 111111 | new    | False   | drop table if exists test_table                                                                                                          | success | schema1 |
      | test | 111111 | conn_0 | False   | drop table if exists test_index                                                                                                          | success | schema1 |
      | test | 111111 | conn_0 | False   | drop table if exists test_shard                                                                                                          | success | schema1 |
      | test | 111111 | conn_0 | False   | create table test_shard(id int,name varchar(20))                                                                                         | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into test_shard values(4,'test_shard4'),(5,'test_shard5'),(6,'test_shard6'),(7,'test_shard7')                                     | success | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:sql=select id from test_shard where id =4*/ create table test_table(id int,name varchar(20))                                     | success | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:sql=select id from test_shard where id =4*/ create table test_index(id int,name varchar(20),index ddd (name) KEY_BLOCK_SIZE = 1) | success | schema1 |
      | test | 111111 | conn_0 | True    | /*!dble:sql=select id from test_shard where id =4*/ insert into test_table values(2,'test2')                                             | success | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                      | expect                  | db  |
      | test | 111111 | new    | False   | show tables              | has{('test_table'),}    | db1 |
      | test | 111111 | conn_0 | False   | show tables              | has{('test_index'),}    | db1 |
      | test | 111111 | conn_0 | True    | select * from test_table | has{(2L, 'test2'),}     | db1 |
      | test | 111111 | new    | False   | show tables              | hasnot{('test_table'),} | db2 |
      | test | 111111 | conn_0 | True    | show tables              | hasnot{('test_index'),} | db2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                | expect                                                                       | db      |
      | test | 111111 | conn_0 | False   | /*!dble:sql=select id from test_shard where id =4*/ drop table test_table                                          | success                                                                      | schema1 |
      | test | 111111 | conn_0 | False   | create table test_table (id int ,name varchar(20))                                                                 | success                                                                      | schema1 |
      | test | 111111 | conn_0 | False   | insert into test_table values(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4')               | success                                                                      | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:sql=select id from test_shard where id =4*/ select * from test_table                                       | has{(2,'test_table2'),(4,'test_table4')}                                     | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:sql=select id from test_not_exist where id =4*/ select * from test_table                                   | Table 'db3.test_table' doesn't exist                                         | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:sql=select id from test_shard where id in(4,5)*/ select * from test_table                                  | has{(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4')} | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:sql=select * from test_shard */ select * from test_table                                                   | has{(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4')} | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:sql=select id from test_shard where id =4,select id from test_shard where id =5*/ select * from test_table | sql syntax error, no terminated. COMMA                                       | schema1 |
      | test | 111111 | conn_0 | True    | /*!dble:sql=select id from test_shard where id =4*/ update test_table set name = 'dn1'                             | success                                                                      | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                      | expect                                   | db  |
      | test | 111111 | conn_0 | True    | select * from test_table | has{(2,'dn1'),(4,'dn1')}                 | db1 |
      | test | 111111 | conn_0 | True    | select * from test_table | has{(1,'test_table1'),(3,'test_table3')} | db2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                        | expect  | db      |
      | test | 111111 | conn_0 | True    | /*!dble:sql=select id from test_shard where id =4*/ delete from test_table | success | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                      | expect                                   | db  |
      | test | 111111 | conn_0 | True    | select * from test_table | length{(0)}                              | db1 |
      | test | 111111 | conn_0 | True    | select * from test_table | has{(1,'test_table1'),(3,'test_table3')} | db2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                  | expect  | db      |
      | test | 111111 | conn_0 | True    | /*!dble:sql=select id from test_shard where id =4*/ insert into test_table select id,name from test_shard where id>4 | success | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                      | expect                     | db  |
      | test | 111111 | conn_0 | True    | select * from test_table | has{(6, 'test_shard6')}    | db1 |
      | test | 111111 | conn_0 | True    | select * from test_table | hasnot{(6, 'test_shard6')} | db2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                | expect  | db      |
      | test | 111111 | conn_0 | True    | /*!dble:sql=select id from test_shard where id =5*/ replace test_table select id,name from test_shard where id < 7 | success | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                      | expect                     | db  |
      | test | 111111 | conn_0 | True    | select * from test_table | hasnot{(5, 'test_shard5')} | db1 |
      | test | 111111 | conn_0 | True    | select * from test_table | has{(5, 'test_shard5')}    | db2 |
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                          | expect    | db      |
      | test | 111111 | conn_0 | True    | /*!dble:sql=select id from test_shard where id =5*/ select count(*) from test_shard          | has{(2),} | schema1 |
      | test | 111111 | conn_0 | True    | /*!dble:sql=select id from test_shard where id =4*/ alter table test_table add c varchar(20) | success   | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql             | expect       | db  |
      | test | 111111 | conn_0 | True    | desc test_table | length{(3)}} | db1 |
      | test | 111111 | conn_0 | True    | desc test_table | length{(2)}} | db2 |

  @TRIVIAL @current
  Scenario: test hint format: /*!dble:db_type=xxx*/ while load balance type 1 #3
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}   |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
      | schema.xml | {'tag':'root'} | {'tag':'dataHost'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema name="schema1" >
         <table name="test_table" dataNode="dn2,dn4" rule="hash-two" />
      </schema>
      <schema name="schema2" dataNode="dn2">
      </schema>
       <dataNode dataHost="ha_group2" database="db1" name="dn2" />
       <dataNode dataHost="ha_group2" database="db2" name="dn4" />
      <dataHost balance="1" maxCon="1000" minCon="10" name="ha_group2" slaveThreshold="100" >
               <heartbeat>select user()</heartbeat>
               <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
                  <readHost host="hostS1" password="111111" url="172.100.9.2:3306" user="test"/>
               </writeHost>
       </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test">
        <property name="password">111111</property>
        <property name="schemas">schema1,schema2</property>
    </user>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                  | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists test_table                                                                      | success | schema1 |
      | test | 111111 | conn_0 | False   | create table test_table (id int ,name varchar(20))                                                   | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into test_table values(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4') | success | schema1 |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                              | expect  | db |
      | test | 111111 | conn_0 | False   | set global general_log=on        | success |    |
      | test | 111111 | conn_0 | False   | set global log_output='table'    | success |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log | success |    |
    Then execute sql in "mysql-slave1"
      | user | passwd | conn   | toClose | sql                              | expect  | db |
      | test | 111111 | conn_0 | False   | set global general_log=on        | success |    |
      | test | 111111 | conn_0 | False   | set global log_output='table'    | success |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log | success |    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                              | expect  | db      |
      | test | 111111 | conn_0 | True    | /*!dble:db_type=master*/select * from test_table | success | schema1 |
    Then execute sql in "mysql-slave1"
      | user | passwd | conn   | toClose | sql                                                                          | expect      | db |
      | test | 111111 | conn_0 | True    | select * from mysql.general_log where argument  = 'select * from test_table' | length{(0)} |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log                                             | success     |    |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                                                                          | expect      | db |
      | test | 111111 | conn_0 | False   | select * from mysql.general_log where argument  = 'select * from test_table' | length{(2)} |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log                                             | success     |    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                             | expect  | db      |
      | test | 111111 | conn_0 | True    | /*!dble:db_type=slave*/select * from test_table | success | schema1 |
    Then execute sql in "mysql-slave1"
      | user | passwd | conn   | toClose | sql                                                                          | expect      | db |
      | test | 111111 | conn_0 | True    | select * from mysql.general_log where argument  = 'select * from test_table' | length{(2)} |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log                                             | success     |    |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                                                                          | expect      | db |
      | test | 111111 | conn_0 | False   | select * from mysql.general_log where argument  = 'select * from test_table' | length{(0)} |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log                                             | success     |    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | True    | /*!dble:db_type=master*/select count(*) from test_table | success | schema1 |
    Then execute sql in "mysql-slave1"
      | user | passwd | conn   | toClose | sql                                                                                     | expect      | db |
      | test | 111111 | conn_0 | True    | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%' | length{(0)} |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log                                                        | success     |    |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                                                                                     | expect      | db |
      | test | 111111 | conn_0 | False   | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%' | length{(2)} |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log                                                        | success     |    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                    | expect  | db      |
      | test | 111111 | conn_0 | True    | /*!dble:db_type=slave*/select count(*) from test_table | success | schema1 |
    Then execute sql in "mysql-slave1"
      | user | passwd | conn   | toClose | sql                                                                                     | expect      | db |
      | test | 111111 | conn_0 | True    | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%' | length{(2)} |    |
      | test | 111111 | conn_0 | True    | set global log_output='file'                                                            | success     |    |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                                                                                     | expect      | db |
      | test | 111111 | conn_0 | False   | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%' | length{(0)} |    |
      | test | 111111 | conn_0 | False   | set global log_output='file'                                                            | success     |    |
      | test | 111111 | conn_0 | True    | set global general_log=off                                                              | success     |    |

  @NORMAL
  Scenario: test hint format: /*!dble:db_type=xxx*/ while load balance type 2 #4
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}   |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
      | schema.xml | {'tag':'root'} | {'tag':'dataHost'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema name="schema1" >
         <table name="test_table" dataNode="dn2,dn4" rule="hash-two" />
      </schema>
      <schema name="schema2" dataNode="dn2">
      </schema>
       <dataNode dataHost="ha_group2" database="db1" name="dn2" />
       <dataNode dataHost="ha_group2" database="db2" name="dn4" />
      <dataHost balance="2" maxCon="1000" minCon="10" name="ha_group2" slaveThreshold="100" >
               <heartbeat>select user()</heartbeat>
               <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
                  <readHost host="hostS1" password="111111" url="172.100.9.2:3306" user="test"/>
               </writeHost>
       </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test">
        <property name="password">111111</property>
        <property name="schemas">schema1,schema2</property>
    </user>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                  | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists test_table                                                                      | success | schema1 |
      | test | 111111 | conn_0 | False   | create table test_table (id int ,name varchar(20))                                                   | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into test_table values(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4') | success | schema1 |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                              | expect  | db |
      | test | 111111 | conn_0 | False   | set global general_log=on        | success |    |
      | test | 111111 | conn_0 | False   | set global log_output='table'    | success |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log | success |    |
    Then execute sql in "mysql-slave1"
      | user | passwd | conn   | toClose | sql                              | expect  | db |
      | test | 111111 | conn_0 | False   | set global general_log=on        | success |    |
      | test | 111111 | conn_0 | False   | set global log_output='table'    | success |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log | success |    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                              | expect  | db      |
      | test | 111111 | conn_0 | True    | /*!dble:db_type=master*/select * from test_table | success | schema1 |
    Then execute sql in "mysql-slave1"
      | user | passwd | conn   | toClose | sql                                                                          | expect      | db |
      | test | 111111 | conn_0 | True    | select * from mysql.general_log where argument  = 'select * from test_table' | length{(0)} |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log                                             | success     |    |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                                                                          | expect      | db |
      | test | 111111 | conn_0 | False   | select * from mysql.general_log where argument  = 'select * from test_table' | length{(2)} |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log                                             | success     |    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                             | expect  | db      |
      | test | 111111 | conn_0 | True    | /*!dble:db_type=slave*/select * from test_table | success | schema1 |
    Then execute sql in "mysql-slave1"
      | user | passwd | conn   | toClose | sql                                                                          | expect      | db |
      | test | 111111 | conn_0 | True    | select * from mysql.general_log where argument  = 'select * from test_table' | length{(2)} |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log                                             | success     |    |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                                                                          | expect      | db |
      | test | 111111 | conn_0 | False   | select * from mysql.general_log where argument  = 'select * from test_table' | length{(0)} |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log                                             | success     |    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | True    | /*!dble:db_type=master*/select count(*) from test_table | success | schema1 |
    Then execute sql in "mysql-slave1"
      | user | passwd | conn   | toClose | sql                                                                                     | expect      | db |
      | test | 111111 | conn_0 | True    | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%' | length{(0)} |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log                                                        | success     |    |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                                                                                     | expect      | db |
      | test | 111111 | conn_0 | False   | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%' | length{(2)} |    |
      | test | 111111 | conn_0 | True    | truncate table mysql.general_log                                                        | success     |    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                    | expect  | db      |
      | test | 111111 | conn_0 | True    | /*!dble:db_type=slave*/select count(*) from test_table | success | schema1 |
    Then execute sql in "mysql-slave1"
      | user | passwd | conn   | toClose | sql                                                                                     | expect      | db |
      | test | 111111 | conn_0 | True    | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%' | length{(2)} |    |
      | test | 111111 | conn_0 | True    | set global log_output='file'                                                            | success     |    |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                                                                                     | expect      | db |
      | test | 111111 | conn_0 | False   | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%' | length{(0)} |    |
      | test | 111111 | conn_0 | False   | set global log_output='file'                                                            | success     |    |
      | test | 111111 | conn_0 | True    | set global general_log=off                                                              | success     |    |

  @TRIVIAL
  Scenario: hint for specail sql syntax: call procedure #6
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
      """
        <table name="test_sp" dataNode="dn1,dn3" rule="hash-two" />
        <table name="test_shard" dataNode="dn1,dn3" rule="hash-two" />
     """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                              | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists test_sp                                     | success | schema1 |
      | test | 111111 | conn_0 | False   | drop table if exists test_shard                                  | success | schema1 |
      | test | 111111 | conn_0 | False   | create table test_sp (id int ,name varchar(20))                  | success | schema1 |
      | test | 111111 | conn_0 | False   | create table test_shard (id int ,name varchar(20))               | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into test_sp values(1,'test_sp1'),(2,'test_sp2')          | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into test_shard values(1,'test_shard1'),(2,'test_shard2') | success | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                                                              | expect  | db  |
      | test | 111111 | conn_0 | False   | drop procedure if exists select_name                                             | success | db1 |
      | test | 111111 | conn_0 | True    | create procedure select_name() begin select id,name from test_sp where id =2;end | success | db1 |
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                 | expect                     | db      |
      | test | 111111 | conn_0 | False   | /*!dble:datanode=dn1*/call select_name                              | has{[((2L, 'test_sp2'),)]} | schema1 |
      | test | 111111 | conn_0 | True    | /*!dble:sql=select id from test_shard where id =2*/call select_name | has{[((2L, 'test_sp2'),)]} | schema1 |

  @regression
  Scenario: routed node when index with hint    from issue: 892    author:maofei #7
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                        | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test_global           | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test_global(id int)           | success | schema1 |
      | test | 111111 | conn_0 | True    | create index index_test on test_global(id) | success | schema1 |
    Then connect "dble-1" to execute "100" of select
    """
    show index from test_global /*test*/
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    dn5{show index from test_global/*test*/}
    """

  Scenario: sql from GUI CLient test    author:maofei #8
    #from issue: 1032
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                    | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test1                                                                             | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test1(id int not null, name varchar(40), depart varchar(40),role varchar(30),code int(4)) | success | schema1 |
      | test | 111111 | conn_0 | True    | create view view_tt as select name,depart,role from test1                                              | success | schema1 |
      | test | 111111 | conn_0 | True    | /* ApplicationName=DBeaver 5.2.4 - Main */drop view view_tt                                            | success | schema1 |
    #from issue: 842
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | expect                | db      |
      | test | 111111 | conn_0 | True    | drop table if exists sharding_4_t1 | success               | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test1         | success               | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test2         | success               | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test3         | success               | schema1 |
      | test | 111111 | conn_0 | True    | create table sharding_4_t1(id int) | success               | schema1 |
      | test | 111111 | conn_0 | True    | create table test1(id int)         | success               | schema1 |
      | test | 111111 | conn_0 | True    | create table test2(id int)         | success               | schema1 |
      | test | 111111 | conn_0 | True    | create table test3(id int)         | success               | schema1 |
      | test | 111111 | conn_0 | True    | SHOW FULL TABLES FROM `schema1`    | hasStr{sharding_4_t1} | schema1 |
      | test | 111111 | conn_0 | True    | SHOW FULL TABLES FROM schema1      | hasStr{sharding_4_t1} | schema1 |
    #from issue:829
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                          | expect  | db      |
      | test | 111111 | conn_0 | True    | /* ApplicationName=DBeaver 5.2.4 - Metadata */ SHOW FULL TABLES FROM schema1 | success | schema1 |
    #from issue:824
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                 | expect      | db      |
      | test | 111111 | conn_0 | True    | drop table if exists sharding_4_t1                  | success     | schema1 |
      | test | 111111 | conn_0 | True    | create table sharding_4_t1(id int,name varchar(30)) | success     | schema1 |
      | test | 111111 | conn_0 | True    | show table status like 'sharding_4_t1'              | length{(1)} | schema1 |

  Scenario: support multi-statement in procedure   author:wujinling #9
    #from issue:1228
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
      """
        <table name="test_shard" dataNode="dn1,dn3" rule="hash-two" />
     """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                                                                  | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists test_shard                                                                                                                                      | success | schema1 |
      | test | 111111 | conn_0 | False   | create table test_shard (id int ,name varchar(20))                                                                                                                   | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into test_shard values(1,'test_shard1'),(2,'test_shard2'),(3,'test_shard3')                                                                                   | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into test_shard values(4,'test_shard4'),(5,'test_shard5'),(6,'test_shard6')                                                                                   | success | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:sql=select * from test_shard where id =1*/drop procedure if exists delete_matches                                                                            | success | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:sql=select * from test_shard where id =1*/CREATE PROCEDURE delete_matches(IN p_playerno INTEGER) BEGIN select * from test_shard; delete from test_shard; END | success | schema1 |
      | test | 111111 | conn_0 | False   | /*!dble:sql=select * from test_shard where id =1*/call delete_matches(1)                                                                                             | success | schema1 |
      | test | 111111 | conn_0 | True    | /*!dble:sql=select * from test_shard where id =1*/drop procedure if exists delete_matches                                                                            | success | schema1 |

  Scenario: support create function   author:maofei #10
    Then execute sql in "dble-1" in "test" mode
      | user | passwd | conn   | toClose | sql                                                                                                                                                                                                                                                                                                                                  | expect                               | db      |
      | test | 111111 | conn_0 | True    | drop table if exists sharding_4_t1                                                                                                                                                                                                                                                                                                   | success                              | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test1                                                                                                                                                                                                                                                                                                           | success                              | schema1 |
      | test | 111111 | conn_0 | True    | create table sharding_4_t1 (id int ,name varchar(20))                                                                                                                                                                                                                                                                                | success                              | schema1 |
      | test | 111111 | conn_0 | True    | create table test1 (id int ,name varchar(20))                                                                                                                                                                                                                                                                                        | success                              | schema1 |
      | test | 111111 | conn_0 | True    | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4),(5,5)                                                                                                                                                                                                                                                                        | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/drop function if exists test1                                                                                                                                                                                                                                                                                  | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/drop function if exists test_get                                                                                                                                                                                                                                                                               | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/CREATE FUNCTION test1(v_id int) RETURNS VARCHAR(255) BEGIN DECLARE x VARCHAR(255) DEFAULT ''; select name into x from sharding_4_t1 where id =v_id; RETURN x; END                                                                                                                                              | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/CREATE FUNCTION test_get(v_id int) RETURNS VARCHAR(255) BEGIN DECLARE x VARCHAR(255) DEFAULT ''; select test1(v_id) into x ; RETURN x; END                                                                                                                                                                     | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/select test1(4)                                                                                                                                                                                                                                                                                                | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/select test_get(4)                                                                                                                                                                                                                                                                                             | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/drop function test1                                                                                                                                                                                                                                                                                            | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/select test_get(4)                                                                                                                                                                                                                                                                                             | FUNCTION db1.test1 does not exist    | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/drop function test_get                                                                                                                                                                                                                                                                                         | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/drop function test_get                                                                                                                                                                                                                                                                                         | FUNCTION db1.test_get does not exist | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/drop function if exists `test-1`                                                                                                                                                                                                                                                                               | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/drop function if exists `test-get`                                                                                                                                                                                                                                                                             | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/CREATE FUNCTION `test-1`(v_id int) RETURNS VARCHAR(255) BEGIN DECLARE x VARCHAR(255) DEFAULT ''; select name into x from sharding_4_t1 where id =v_id; RETURN x; END                                                                                                                                           | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/CREATE FUNCTION `test-get`(v_id int) RETURNS VARCHAR(255) BEGIN DECLARE x VARCHAR(255) DEFAULT ''; select `test-1`(v_id) into x ; RETURN x; END                                                                                                                                                                | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/select `test-get`(4)                                                                                                                                                                                                                                                                                           | success                              | schema1 |
      | test | 111111 | conn_0 | False   | select `test-get`(4),id from sharding_4_t1                                                                                                                                                                                                                                                                                           | Unknown function `TEST-GET`          | schema1 |
      | test | 111111 | conn_0 | False   | select `test-get`(4),id from sharding_4_t1,test1                                                                                                                                                                                                                                                                                     | error totally whack                  | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/drop function if exists myTime                                                                                                                                                                                                                                                                                 | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/CREATE FUNCTION myTime() RETURNS VARCHAR(30) RETURN DATE_FORMAT(NOW(),'%Y%m%d %H%i%s');                                                                                                                                                                                                                        | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/select myTime()                                                                                                                                                                                                                                                                                                | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/drop function if exists caseTest                                                                                                                                                                                                                                                                               | success                              | schema1 |
      | test | 111111 | conn_0 | False   | /*#dble:datanode=dn1*/create function caseTest(str varchar(5),num int) returns int begin case str when 'power' then set @result=power(num,2); when 'ceil' then set @result=ceil(num); when 'floor' then set @result=floor(num); when 'round' then set @result=round(num); else set @result=0; end case; return (select @result); end | success                              | schema1 |
      | test | 111111 | conn_0 | True    | /*#dble:datanode=dn1*/select caseTest('power',2)                                                                                                                                                                                                                                                                                     | success                              | schema1 |

  @run
  Scenario: support dble import/export by using GUI  author:wujinling,2019.09.19 #11
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
      """
        <table name="test_shard" dataNode="dn1,dn3" rule="hash-two" />
     """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                         | expect     | db      |
      | test | 111111 | conn_0 | False   | drop table if exists test_shard                                                             | success    | schema1 |
      | test | 111111 | conn_0 | False   | create table test_shard (id int ,name varchar(20))                                          | success    | schema1 |
      | test | 111111 | conn_0 | False   | insert into test_shard values(1,'test_shard1'),(2,'test_shard2'),(3,'test_shard3')          | success    | schema1 |
      | test | 111111 | conn_0 | False   | insert into test_shard values(4,'test_shard4'),(5,'test_shard5'),(6,'test_shard6')          | success    | schema1 |
      | test | 111111 | conn_0 | False   | SHOW CREATE DATABASE IF NOT EXISTS `schema1`                                                | success    | schema1 |
      | test | 111111 | conn_0 | False   | CREATE DATABASE /*!32312 IF NOT EXISTS*/ `schema1` /*!40100 DEFAULT CHARACTER SET latin1 */ | success    | schema1 |
      | test | 111111 | conn_0 | False   | FLUSH /*!40101 LOCAL */ TABLES                                                              | success    | schema1 |
      | test | 111111 | conn_0 | False   | FLUSH TABLES WITH READ LOCK                                                                 | success    | schema1 |
      | test | 111111 | conn_0 | False   | --;                                                                                         | success    | schema1 |
      | test | 111111 | conn_0 | False   | -- ;                                                                                        | success    | schema1 |
      | test | 111111 | conn_0 | False   | select * from test_shard                                                                    | length{(6)} | schema1 |
      | test | 111111 | conn_0 | True    | -- select * from test_shard                                                                 | success    | schema1 |
    Given create local and server file "hint_test.sql" and fill with text
     """
     /*
     Navicat Premium Data Transfer

     Source Server         : mysql
     Source Server Type    : MySQL
     Source Server Version : 50713
     Source Host           : 10.186.60.30:7144
     Source Schema         : schema1

     Target Server Type    : MySQL
     Target Server Version : 50713
     File Encoding         : 65001

     Date: 08/07/2019 16:01:38
     */

     SET NAMES utf8mb4;
     SET FOREIGN_KEY_CHECKS = 0;

     -- ----------------------------
     -- Records of test_shard
     -- ----------------------------
     INSERT INTO `test_shard` VALUES (7,'test_shard7');
     INSERT INTO `test_shard` VALUES (8,'test_shard8');
     INSERT INTO `test_shard` VALUES (9,'test_shard9');
     SET FOREIGN_KEY_CHECKS = 1;
     """
    Given execute oscmd in "dble-1"
     """
      mysql -h127.0.0.1 -utest -P8066 -p111111 schema1 < /opt/dble/hint_test.sql
     """

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                      | expect     | db      |
      | test | 111111 | conn_0 | True    | select * from test_shard | length{(9)} | schema1 |
    Given remove local and server file "hint_test.sql"