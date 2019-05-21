# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
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
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | new | False    | drop table if exists test_table                                                             | success | schema1 |
        | test | 111111 | new | False    | drop table if exists test_index                                                             | success | schema1 |
        | test | 111111 | conn_0 | False    | /*!dble:datanode=dn1*/ create table test_table(id int,name varchar(20))              | success | schema1 |
        | test | 111111 | conn_0 | False    | /*!dble:datanode=dn1*/ create table test_index(id int,name varchar(20),index ddd (name) KEY_BLOCK_SIZE = 1)              | success | schema1 |
        | test | 111111 | conn_0 | True     | /*!dble:datanode=dn1*/ insert into test_table values(2,'test2')                       | success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | new     | False    | show tables                                                                                    | has{('test_table'),} | db1   |
        | test | 111111 | new     | False    | show tables                                                                                    | has{('test_index'),} | db1   |
        | test | 111111 | conn_0 | True     | select * from test_table                                                                     | has{(2L, 'test2'),} | db1   |
        | test | 111111 | new     | False    | show tables                                                                                    | hasnot{('test_table'),} | db2   |
        | test | 111111 | new     | False    | show tables                                                                                    | hasnot{('test_index'),} | db2   |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                                               | expect  | db     |
        | test | 111111 | new     | False    | /*!dble:datanod=dn1*/ drop table test_table                                                               | Not supported hint sql type : datanod | schema1 |
        | test | 111111 | conn_0 | False    | /*#dble:datanode=dn1*/ drop table test_table                                                               | success | schema1 |
        | test | 111111 | conn_0 | False    |  drop table if exists test_shard                                                                             | success | schema1 |
        | test | 111111 | conn_0 | False    |  create table test_table (id int ,name varchar(20))                                                        | success | schema1 |
        | test | 111111 | conn_0 | False    |  create table test_shard(id int,name varchar(20))                                                           | success | schema1 |
        | test | 111111 | conn_0 | False    |  insert into test_table values(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4')      | success | schema1 |
        | test | 111111 | conn_0 | False    |  insert into test_shard values(4,'test_shard4'),(5,'test_shard5'),(6,'test_shard6'),(7,'test_shard7')     | success | schema1 |
        | test | 111111 | conn_0 | False    | /*!dble:datanode=dn1*/ select * from test_table                                                            | has{(2,'test_table2'),(4,'test_table4')} | schema1 |
        | test | 111111 | conn_0 | False    | /*!dble:datanode=dn1,dn3*/ select * from test_table                                                       | can't find hint datanode:dn1,dn3 | schema1 |
        | test | 111111 | conn_0 | True     | /*!dble:datanode=dn1*/ update test_table set name = 'dn1'                                                | success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | new    | True    | select * from test_table                                                                     | has{(2,'dn1'),(4,'dn1')} | db1   |
        | test | 111111 | new    | True     | select * from test_table                                                                    | has{(1,'test_table1'),(3,'test_table3')} | db2   |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | new     | True    | /*!dble:datanode=dn1*/ delete from test_table                                      | success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | new    | True    | select * from test_table                                                                     | length{(0)} | db1   |
        | test | 111111 | new    | True    | select * from test_table                                                                    | has{(1,'test_table1'),(3,'test_table3')} | db2   |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | new     | True    | /*!dble:datanode=dn1*/ insert into test_table select id,name from test_shard where id>4          | success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | new    | True    | select * from test_table                                                                     | has{(6, 'test_shard6')} | db1   |
        | test | 111111 | new    | True    | select * from test_table                                                                     | hasnot{(6, 'test_shard6')} | db2   |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | new     | True    |  /*!dble:datanode=dn3*/ replace test_table select id,name from test_shard where id < 7        | success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | new    | True    | select * from test_table                                                                     | hasnot{(5, 'test_shard5')} | db1   |
        | test | 111111 | new    | True    | select * from test_table                                                                     | has{(5, 'test_shard5')} | db2   |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | new     | True    |   /*!dble:datanode=dn3*/ select count(*) from test_shard        | has{(2),} | schema1 |
        | test | 111111 | new     | True    |   /*!dble:datanode=dn1*/ alter table test_table add c varchar(20)        | success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | new    | True    | desc test_table                                                                     | length{(3)}} | db1   |
        | test | 111111 | new    | True    | desc test_table                                                                    | length{(2)}} | db2   |

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
        | user | passwd | conn   | toClose  | sql                                                                                     | expect  | db      |
        | test | 111111 | new    | False    | drop table if exists test_table                                                         | success | schema1 |
        | test | 111111 | conn_0 | False    | drop table if exists test_index                                                         | success | schema1 |
        | test | 111111 | conn_0 | False    | drop table if exists test_shard                                                         | success | schema1 |
        | test | 111111 | conn_0 | False    |  create table test_shard(id int,name varchar(20))                                       | success | schema1 |
        | test | 111111 | conn_0 | False    |  insert into test_shard values(4,'test_shard4'),(5,'test_shard5'),(6,'test_shard6'),(7,'test_shard7')     | success | schema1 |
        | test | 111111 | conn_0 | False    | /*!dble:sql=select id from test_shard where id =4*/ create table test_table(id int,name varchar(20))      | success | schema1 |
        | test | 111111 | conn_0 | False    | /*!dble:sql=select id from test_shard where id =4*/ create table test_index(id int,name varchar(20),index ddd (name) KEY_BLOCK_SIZE = 1)              | success | schema1 |
        | test | 111111 | conn_0 | True     | /*!dble:sql=select id from test_shard where id =4*/ insert into test_table values(2,'test2')              | success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose | sql                       | expect                  | db    |
        | test | 111111 | new    | False   | show tables               | has{('test_table'),}    | db1   |
        | test | 111111 | conn_0 | False   | show tables               | has{('test_index'),}    | db1   |
        | test | 111111 | conn_0 | True    | select * from test_table  | has{(2L, 'test2'),}     | db1   |
        | test | 111111 | new    | False   | show tables               | hasnot{('test_table'),} | db2   |
        | test | 111111 | conn_0 | True    | show tables               | hasnot{('test_index'),} | db2   |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                                                 | expect  | db     |
        | test | 111111 | conn_0 | False    | /*!dble:sql=select id from test_shard where id =4*/ drop table test_table                                           | success | schema1 |
        | test | 111111 | conn_0 | False    |  create table test_table (id int ,name varchar(20))                                                                 | success | schema1 |
        | test | 111111 | conn_0 | False    |  insert into test_table values(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4')               | success | schema1 |
        | test | 111111 | conn_0 | False    | /*!dble:sql=select id from test_shard where id =4*/ select * from test_table                                        | has{(2,'test_table2'),(4,'test_table4')} | schema1 |
        | test | 111111 | conn_0 | False    | /*!dble:sql=select id from test_not_exist where id =4*/ select * from test_table                                    |Table 'db3.test_table' doesn't exist | schema1 |
        | test | 111111 | conn_0 | False    | /*!dble:sql=select id from test_shard where id in(4,5)*/ select * from test_table                                   | has{(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4')} | schema1 |
        | test | 111111 | conn_0 | False    | /*!dble:sql=select * from test_shard */ select * from test_table                                                    | has{(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4')} | schema1 |
        | test | 111111 | conn_0 | False    | /*!dble:sql=select id from test_shard where id =4,select id from test_shard where id =5*/ select * from test_table  |sql syntax error, no terminated. COMMA | schema1 |
        | test | 111111 | conn_0 | True     | /*!dble:sql=select id from test_shard where id =4*/ update test_table set name = 'dn1'                              | success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose | sql                       | expect                                   | db    |
        | test | 111111 | conn_0 | True    | select * from test_table  | has{(2,'dn1'),(4,'dn1')}                 | db1   |
        | test | 111111 | conn_0 | True    | select * from test_table  | has{(1,'test_table1'),(3,'test_table3')} | db2   |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                        | expect  | db      |
        | test | 111111 | conn_0 | True    | /*!dble:sql=select id from test_shard where id =4*/ delete from test_table | success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose | sql                      | expect                                   | db    |
        | test | 111111 | conn_0 | True    | select * from test_table | length{(0)}                              | db1   |
        | test | 111111 | conn_0 | True    | select * from test_table | has{(1,'test_table1'),(3,'test_table3')} | db2   |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                      | expect  | db     |
        | test | 111111 | conn_0 | True    | /*!dble:sql=select id from test_shard where id =4*/ insert into test_table select id,name from test_shard where id>4 | success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose | sql                      | expect                     | db    |
        | test | 111111 | conn_0 | True    | select * from test_table | has{(6, 'test_shard6')}    | db1   |
        | test | 111111 | conn_0 | True    | select * from test_table | hasnot{(6, 'test_shard6')} | db2   |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0 | True    |  /*!dble:sql=select id from test_shard where id =5*/ replace test_table select id,name from test_shard where id < 7 | success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose | sql                      | expect                     | db    |
        | test | 111111 | conn_0 | True    | select * from test_table | hasnot{(5, 'test_shard5')} | db1   |
        | test | 111111 | conn_0 | True    | select * from test_table | has{(5, 'test_shard5')}    | db2   |
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                                          | expect  | db     |
        | test | 111111 | conn_0 | True    |   /*!dble:sql=select id from test_shard where id =5*/ select count(*) from test_shard        | has{(2),} | schema1 |
        | test | 111111 | conn_0 | True    |   /*!dble:sql=select id from test_shard where id =4*/ alter table test_table add c varchar(20)| success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose | sql             | expect       | db    |
        | test | 111111 | conn_0 | True    | desc test_table | length{(3)}} | db1   |
        | test | 111111 | conn_0 | True    | desc test_table | length{(2)}} | db2   |

  @TRIVIAL @current
  Scenario: test hint format: /*!dble:db_type=xxx*/ while load balance type 1 #3
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema name="schema1" >
         <table name="test_table" dataNode="dn2,dn4" rule="hash-two" />
      </schema>
      <schema name="schema2" dataNode="dn2">
      </schema>
       <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
       <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
      <dataHost balance="1" maxCon="1000" minCon="10" name="172.100.9.6" slaveThreshold="100" switchType="1">
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
        | user | passwd | conn   | toClose | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0 | False   | drop table if exists test_table                                                             | success | schema1 |
        | test | 111111 | conn_0 | False   |  create table test_table (id int ,name varchar(20))                                     | success | schema1 |
        | test | 111111 | conn_0 | True    |  insert into test_table values(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4')      | success | schema1 |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | False    | set global general_log=on                                                                |success |    |
        | test | 111111 | conn_0     | False    | set global log_output='table'                                                           | success |    |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
      Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | False    | set global general_log=on                                                                |success |    |
        | test | 111111 | conn_0     | False    | set global log_output='table'                                                           | success |    |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | True    | /*!dble:db_type=master*/select * from test_table                                       | success | schema1 |
    Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | True     | select * from mysql.general_log where argument  = 'select * from test_table'     | length{(0)} |   |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | False     | select * from mysql.general_log where argument  = 'select * from test_table'      | length{(2)} |   |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | True    | /*!dble:db_type=slave*/select * from test_table                                       | success | schema1 |
    Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | True     |  select * from mysql.general_log where argument  = 'select * from test_table'    | length{(2)} |   |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | False     | select * from mysql.general_log where argument  = 'select * from test_table'      | length{(0)} |   |
        | test | 111111 | conn_0     | True    | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | True    | /*!dble:db_type=master*/select count(*) from test_table                                       | success | schema1 |
    Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | True     | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%'     | length{(0)} |   |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | False     | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%'      | length{(2)} |   |
        | test | 111111 | conn_0     | True    | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | True    | /*!dble:db_type=slave*/select count(*) from test_table                                       | success | schema1 |
    Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | True     | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%'     | length{(2)} |   |
        | test | 111111 | conn_0     | True    | set global log_output='file'                                                           | success |    |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | False     | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%'      | length{(0)} |   |
        | test | 111111 | conn_0     | False    | set global log_output='file'                                                           | success |    |
        | test | 111111 | conn_0     | True     | set global general_log=off                                                                |success |    |

  @NORMAL
  Scenario: test hint format: /*!dble:db_type=xxx*/ while load balance type 2 #4
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema name="schema1" >
         <table name="test_table" dataNode="dn2,dn4" rule="hash-two" />
      </schema>
      <schema name="schema2" dataNode="dn2">
      </schema>
       <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
       <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
      <dataHost balance="2" maxCon="1000" minCon="10" name="172.100.9.6" slaveThreshold="100" switchType="1">
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
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_table                                                             | success | schema1 |
        | test | 111111 | conn_0 | False    |  create table test_table (id int ,name varchar(20))                                     | success | schema1 |
        | test | 111111 | conn_0 | True    |  insert into test_table values(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4')      | success | schema1 |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | False    | set global general_log=on                                                                |success |    |
        | test | 111111 | conn_0     | False    | set global log_output='table'                                                           | success |    |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
      Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | False    | set global general_log=on                                                                |success |    |
        | test | 111111 | conn_0     | False    | set global log_output='table'                                                           | success |    |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | True    | /*!dble:db_type=master*/select * from test_table                                       | success | schema1 |
    Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | True     | select * from mysql.general_log where argument  = 'select * from test_table'     | length{(0)} |   |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | False     | select * from mysql.general_log where argument  = 'select * from test_table'      | length{(2)} |   |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | True    | /*!dble:db_type=slave*/select * from test_table                                       | success | schema1 |
    Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | True     |  select * from mysql.general_log where argument  = 'select * from test_table'    | length{(2)} |   |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | False     | select * from mysql.general_log where argument  = 'select * from test_table'      | length{(0)} |   |
        | test | 111111 | conn_0     | True    | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | True    | /*!dble:db_type=master*/select count(*) from test_table                                       | success | schema1 |
    Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | True     | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%'     | length{(0)} |   |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | False     | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%'      | length{(2)} |   |
        | test | 111111 | conn_0     | True    | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | True    | /*!dble:db_type=slave*/select count(*) from test_table                                       | success | schema1 |
    Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | True     | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%'     | length{(2)} |   |
        | test | 111111 | conn_0     | True    | set global log_output='file'                                                           | success |    |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | False     | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%'      | length{(0)} |   |
        | test | 111111 | conn_0     | False    | set global log_output='file'                                                           | success |    |
        | test | 111111 | conn_0     | True     | set global general_log=off                                                                |success |    |

  @NORMAL
  Scenario: test hint format: /*!dble:db_type=xxx*/ while load balance type 3 #5
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema name="schema1" >
         <table name="test_table" dataNode="dn2,dn4" rule="hash-two" />
      </schema>
      <schema name="schema2" dataNode="dn2">
      </schema>
       <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
       <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
      <dataHost balance="3" maxCon="1000" minCon="10" name="172.100.9.6" slaveThreshold="100" switchType="1">
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
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_table                                                             | success | schema1 |
        | test | 111111 | conn_0 | False    |  create table test_table (id int ,name varchar(20))                                     | success | schema1 |
        | test | 111111 | conn_0 | True    |  insert into test_table values(1,'test_table1'),(2,'test_table2'),(3,'test_table3'),(4,'test_table4')      | success | schema1 |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | False    | set global general_log=on                                                                |success |    |
        | test | 111111 | conn_0     | False    | set global log_output='table'                                                           | success |    |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
      Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | False    | set global general_log=on                                                                |success |    |
        | test | 111111 | conn_0     | False    | set global log_output='table'                                                           | success |    |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | True    | /*!dble:db_type=master*/select * from test_table                                       | success | schema1 |
    Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | True     | select * from mysql.general_log where argument  = 'select * from test_table'     | length{(0)} |   |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | False     | select * from mysql.general_log where argument  = 'select * from test_table'      | length{(2)} |   |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | True    | /*!dble:db_type=slave*/select * from test_table                                       | success | schema1 |
    Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | True     |  select * from mysql.general_log where argument  = 'select * from test_table'    | length{(2)} |   |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | False     | select * from mysql.general_log where argument  = 'select * from test_table'      | length{(0)} |   |
        | test | 111111 | conn_0     | True    | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | True    | /*!dble:db_type=master*/select count(*) from test_table                                       | success | schema1 |
    Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | True     | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%'     | length{(0)} |   |
        | test | 111111 | conn_0     | True     | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | False     | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%'      | length{(2)} |   |
        | test | 111111 | conn_0     | True    | truncate table mysql.general_log                                                        | success|    |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | True    | /*!dble:db_type=slave*/select count(*) from test_table                                       | success | schema1 |
    Then execute sql in "mysql-slave1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | True     | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%'     | length{(2)} |   |
        | test | 111111 | conn_0     | True    | set global log_output='file'                                                           | success |    |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0    | False     | select * from mysql.general_log where argument  like 'select COUNT(*)%from%test_table%'      | length{(0)} |   |
        | test | 111111 | conn_0     | False    | set global log_output='file'                                                           | success |    |
        | test | 111111 | conn_0     | True     | set global general_log=off                                                                |success |    |

  @TRIVIAL
  Scenario: hint for specail sql syntax: call procedure #6
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
      """
        <table name="test_sp" dataNode="dn1,dn3" rule="hash-two" />
        <table name="test_shard" dataNode="dn1,dn3" rule="hash-two" />
     """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_sp                                                             | success | schema1 |
        | test | 111111 | conn_0 | False    | drop table if exists test_shard                                                             | success | schema1 |
        | test | 111111 | conn_0 | False    |  create table test_sp (id int ,name varchar(20))                                     | success | schema1 |
        | test | 111111 | conn_0 | False    |  create table test_shard (id int ,name varchar(20))                                     | success | schema1 |
        | test | 111111 | conn_0 | False    |  insert into test_sp values(1,'test_sp1'),(2,'test_sp2')                             | success | schema1 |
        | test | 111111 | conn_0 | True     |  insert into test_shard values(1,'test_shard1'),(2,'test_shard2')                    | success | schema1 |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | False    | drop procedure if exists select_name                                                     |success |  db1  |
        | test | 111111 | conn_0     | True    | create procedure select_name() begin select id,name from test_sp where id =2;end | success |  db1  |
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn       | toClose  | sql                                                                                             | expect  | db     |
        | test | 111111 | conn_0     | False    | /*!dble:datanode=dn1*/call select_name                                            | has{[((2L, 'test_sp2'),)]} | schema1 |
        | test | 111111 | conn_0     | True     | /*!dble:sql=select id from test_shard where id =2*/call select_name          | has{[((2L, 'test_sp2'),)]} | schema1 |

  @regression
  Scenario: routed node when index with hint    from issue: 892    author:maofei #7
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                             | expect  | db     |
        | test | 111111 | conn_0 | True     | drop table if exists test_global            | success | schema1 |
        | test | 111111 | conn_0 | True     | create table test_global(id int)            | success | schema1 |
        | test | 111111 | conn_0 | True     | create index index_test on test_global(id) | success | schema1 |
    Then connect "dble-1" to execute "100" of select
    """
    show index from test_global /*test*/
    """
    Then check following "not" exist in file "/opt/dble/logs/dble.log" in "dble-1"
    """
    dn5{show index from test_global/*test*/}
    """

  Scenario: sql from GUI CLient test    author:maofei #8
    #from issue: 1032
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                                                    | expect  | db       |
        | test | 111111 | conn_0 | True     | drop table if exists test1                                                                                          | success | schema1 |
        | test | 111111 | conn_0 | True     | create table test1(id int not null, name varchar(40), depart varchar(40),role varchar(30),code int(4))    | success | schema1 |
        | test | 111111 | conn_0 | True     | create view view_tt as select name,depart,role from test1                                                       | success | schema1 |
        | test | 111111 | conn_0 | True     | /* ApplicationName=DBeaver 5.2.4 - Main */drop view view_tt                                                     | success | schema1 |
    #from issue: 842
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                      | expect                                    | db       |
        | test | 111111 | conn_0 | True     | drop table if exists sharding_4_t1   | success                                   | schema1 |
        | test | 111111 | conn_0 | True     | drop table if exists test1            | success                                   | schema1 |
        | test | 111111 | conn_0 | True     | drop table if exists test2            | success                                    | schema1 |
        | test | 111111 | conn_0 | True     | drop table if exists test3            | success                                    | schema1 |
        | test | 111111 | conn_0 | True     | create table sharding_4_t1(id int)   | success                                    | schema1 |
        | test | 111111 | conn_0 | True     | create table test1(id int)            | success                                    | schema1 |
        | test | 111111 | conn_0 | True     | create table test2(id int)            | success                                    | schema1 |
        | test | 111111 | conn_0 | True     | create table test3(id int)            | success                                    | schema1 |
        | test | 111111 | conn_0 | True     | SHOW FULL TABLES FROM `schema1`      | hasStr{sharding_4_t1}  | schema1 |
        | test | 111111 | conn_0 | True     | SHOW FULL TABLES FROM schema1        | hasStr{sharding_4_t1}   | schema1 |
    #from issue:829
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                                      | expect   | db      |
        | test | 111111 | conn_0 | True     | /* ApplicationName=DBeaver 5.2.4 - Metadata */ SHOW FULL TABLES FROM schema1  | success  | schema1 |
    #from issue:824
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                            | expect       | db       |
        | test | 111111 | conn_0 | True     | drop table if exists sharding_4_t1                        | success      | schema1 |
        | test | 111111 | conn_0 | True     | create table sharding_4_t1(id int,name varchar(30))    | success       | schema1 |
        | test | 111111 | conn_0 | True     | show table status like 'sharding_4_t1'                   | length{(1)}  | schema1 |
