# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature:test user's privileges under different combination
  dml:xxxx in order "insert,update,select,delete"

  @TRIVIAL
  Scenario: config privileges, including exist schema, different privileges, not exist schema,reload success #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="testdb" sqlMaxLimit="100"></schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test_user" password="test_password" schemas="schema1,testdb" readOnly="true">
        <privileges check="true">
            <schema name="schema1" dml="0000" >
                <table name="tableA" dml="1111"></table>
                <table name="tableB" dml="1111"></table>
            </schema>
            <schema name="testdb" dml="1111" >
                <table name="test1" dml="0000"></table>
                <table name="test2" dml="0110"></table>
            </schema>
        </privileges>
    </shardingUser>

    """
    Then execute admin cmd "reload @@config_all"

  @CRITICAL
  Scenario: add readonly client user, user can only read to table in schema's default node and to global table #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
     """
     <shardingUser name="test_user" password="test_password" schemas="schema1" readOnly="true"/>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd        | conn   | toClose | sql      | expect  | db     |
        | test_user    | test_password | conn_0 | False   | select 1 | success | schema1 |
        | test_user    | test_password | conn_0 | True    | drop table if exists test_table | User READ ONLY | schema1 |
    Then execute sql in "dble-1" in "user" mode
        | user      | passwd        | conn   | toClose | sql                                                | expect         | db     |
        | test      | 111111        | conn_0 | False   | drop table if exists test_table                    | success        | schema1 |
        | test_user | test_password | conn_1 | False   | create table test_table(id int, data varchar(10))  | User READ ONLY |schema1 |
        | test      | 111111        | conn_0 | False   | create table test_table(id int, data varchar(10))  | success        |schema1 |
        | test_user | test_password | conn_1 | False   | drop table test_table                              | User READ ONLY | schema1 |
        | test_user | test_password | conn_1 | False   | alter table test_table add column data1 varchar(10)| User READ ONLY | schema1 |
        | test_user | test_password | conn_1 | False   | insert into test_table values (1, 'aaa')           | User READ ONLY | schema1 |
        | test_user | test_password | conn_1 | False   | update test_table set data = 'bbb' where id = 1    | User READ ONLY | schema1 |
        | test_user | test_password | conn_1 | False   | delete from test_table                             | User READ ONLY | schema1 |
        | test_user | test_password | conn_1 | False   | select * from test_table                           | success        | schema1 |
        | test      | 111111        | conn_0 | True    | drop table if exists test_table                    | success        | schema1|

  @BLOCKER
  Scenario: check user privileges work right under check=true setting, including: #3
  tables' explict privileges prior to schema's,
  one client users' privileges not affected by others,
  tables have no explict privileges use schema's privilege,
  tables in default schema node will use default privileges or explict privileges configed for them,
  tables have different privileges do join or union
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn5" sqlMaxLimit="100">
          <shardingTable name="aly_test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="aly_order" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
      </schema>

      <schema name="testdb" shardingNode="dn1" sqlMaxLimit="100">
          <shardingTable name="test1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="test2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="test3" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test_user" password="111111" schemas="schema1,testdb">
        <privileges check="true">
            <schema name="schema1" dml="0000" >
                <table name="aly_test" dml="1111"></table>
                <table name="aly_order" dml="0010"></table>
            </schema>
            <schema name="testdb" dml="1111" >
                <table name="test1" dml="0000"></table>
                <table name="test2" dml="0110"></table>
                <table name="test4" dml="0110"></table>
            </schema>
        </privileges>
    </shardingUser>
    """
    Then execute admin cmd "reload @@config_all"
    #table has explict privileges, and all privileges available
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                             | expect  | db   |
      | test_user | 111111 | conn_0 | False   | use schema1                                      | success |      |
      | test_user | 111111 | conn_0 | False   | drop table if exists aly_test                   | success |      |
      | test_user | 111111 | conn_0 | False   | create table aly_test(id int, name varchar(10)) | success |      |
      | test_user | 111111 | conn_0 | False   | insert into aly_test value(1,'a')               | success |      |
      | test_user | 111111 | conn_0 | False   | update aly_test set name='b' where id=1         | success |      |
      | test_user | 111111 | conn_0 | False   | select * from aly_test                          | success |      |
      | test_user | 111111 | conn_0 | False   | delete from aly_test                            | success |      |
      | test_user | 111111 | conn_0 | False   | show create table aly_test                      | success |      |
    #other user's privileges to a certain table does not affected by test_user
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect  |
      | conn_1 | False   | use schema1                                     | success |
      | conn_1 | False   | drop table if exists aly_test                   | success |
      | conn_1 | False   | create table aly_test(id int, name varchar(10)) | success |
      | conn_1 | False   | insert into aly_test value(1,'a')               | success |
      | conn_1 | False   | update aly_test set name='b' where id=1         | success |
      | conn_1 | False   | select * from aly_test                          | success |
      | conn_1 | False   | delete from aly_test                            | success |
      | conn_1 | True    | show create table aly_test                      | success |
    #table has explict privileges, not all privileges available
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                             | expect                            |
      | test_user | 111111 | conn_0 | False   | use schema1                                     | success                           |
      | test_user | 111111 | conn_0 | False   | drop table if exists aly_order                  | success                           |
      | test_user | 111111 | conn_0 | False   | create table aly_order(id int, name varchar(10))| success                           |
      | test_user | 111111 | conn_0 | False   | insert into aly_order value(1,'a')              | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | update aly_order set name='b' where id=1        | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | select * from aly_order                         | success                           |
      | test_user | 111111 | conn_0 | False   | delete from aly_order                           | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | show create table aly_order                     | success                           |
    #table has not explicit privileges assign,using default schema privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                        | expect                            |
      | test_user | 111111 | conn_0 | False   | use schema1                                | success                           |
      | test_user | 111111 | conn_0 | False   | drop table if exists test                  | success                           |
      | test_user | 111111 | conn_0 | False   | create table test(id int, name varchar(10))| success                           |
      | test_user | 111111 | conn_0 | False   | insert into test value(1,'a')              | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | update test set name='b' where id=1        | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | select * from test                         | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | delete from test                           | DML privilege check is not passed |
    #table logic schema default node, use schema's default privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                               | expect                            |
      | test_user | 111111 | conn_0 | False   | use schema1                                       | success                           |
      | test_user | 111111 | conn_0 | False   | drop table if exists no_config_t                  | success                           |
      | test_user | 111111 | conn_0 | False   | create table no_config_t(id int, name varchar(10))| success                           |
      | test_user | 111111 | conn_0 | False   | insert into no_config_t value(1,'a')              | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | update no_config_t set name='b' where id=1        | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | select * from no_config_t                         | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | delete from no_config_t                           | DML privilege check is not passed |
    #table test1 has no dml privileges, schema has all dml privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                         | expect                            |
      | test_user | 111111 | conn_0 | False   | use testdb                                  | success                           |
      | test_user | 111111 | conn_0 | False   | drop table if exists test1                  | success                           |
      | test_user | 111111 | conn_0 | False   | create table test1(id int, name varchar(10))| success                           |
      | test_user | 111111 | conn_0 | False   | insert into test1 value(1,'a')              | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | update test1 set name='b' where id=1        | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | select * from test1                         | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | delete from test1                           | DML privilege check is not passed |
    #table test2 has part of dml privileges, schema has all dml privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                         | expect                            |
      | test_user | 111111 | conn_0 | False   | use testdb                                  | success                           |
      | test_user | 111111 | conn_0 | False   | drop table if exists test2                  | success                           |
      | test_user | 111111 | conn_0 | False   | create table test2(id int, name varchar(10))| success                           |
      | test_user | 111111 | conn_0 | False   | insert into test2 value(1,'a')              | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | update test2 set name='b' where id=1        | success                           |
      | test_user | 111111 | conn_0 | False   | select * from test2                         | success                           |
      | test_user | 111111 | conn_0 | False   | delete from test2                           | DML privilege check is not passed |
    #table test4 in schema's default, test4 has explicit dml privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                         | expect                            |
      | test_user | 111111 | conn_0 | False   | use testdb                                  | success                           |
      | test_user | 111111 | conn_0 | False   | drop table if exists test4                  | success                           |
      | test_user | 111111 | conn_0 | False   | create table test4(id int, name varchar(10))| success                           |
      | test_user | 111111 | conn_0 | False   | insert into test4 value(1,'a')              | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | update test4 set name='b' where id=1        | success                           |
      | test_user | 111111 | conn_0 | False   | select * from test4                         | success                           |
      | test_user | 111111 | conn_0 | False   | delete from test4                           | DML privilege check is not passed |
    #table test3 has no privileges setting, schema has all dml privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                         | expect  |
      | test_user | 111111 | conn_0 | False   | use testdb                                  | success |
      | test_user | 111111 | conn_0 | False   | drop table if exists test3                  | success |
      | test_user | 111111 | conn_0 | False   | create table test3(id int, name varchar(10))| success |
      | test_user | 111111 | conn_0 | False   | insert into test3 value(1,'a')              | success |
      | test_user | 111111 | conn_0 | False   | update test3 set name='b' where id=1        | success |
      | test_user | 111111 | conn_0 | False   | select * from test3                         | success |
      | test_user | 111111 | conn_0 | False   | delete from test3                           | success |
    #table has different privileges do join or union
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                                                    | expect                            |
      | test_user | 111111 | conn_0 | False   | select * from schema1.aly_test a join schema1.aly_order b on a.id=b.id | success                           |
      | test_user | 111111 | conn_0 | False   | select * from schema1.aly_test a join schema1.test b on a.id=b.id      | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | select * from schema1.test a join schema1.no_config_t b on a.id=b.id   | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | select * from schema1.aly_test a join testdb.test1 b on a.id=b.id      | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | select * from schema1.aly_test a join test2 b on a.id=b.id             | success                           |
      | test_user | 111111 | conn_0 | False   | select * from schema1.aly_test union select * from schema1.aly_order   | success                           |
      | test_user | 111111 | conn_0 | False   | select * from schema1.aly_test union select * from testdb.test1        | DML privilege check is not passed |
      | test_user | 111111 | conn_0 | False   | select * from schema1.aly_test union select * from schema1.test       | DML privilege check is not passed  |
    #clear tables and close conn
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                          | expect  |
      | test_user | 111111 | conn_0 | False   | use schema1                  | success |
      | test_user | 111111 | conn_0 | False   | truncate table aly_test      | success |
      | test_user | 111111 | conn_0 | False   | truncate table aly_order     | success |
      | test_user | 111111 | conn_0 | False   | truncate table test          | success |
      | test_user | 111111 | conn_0 | False   | drop table aly_test          | success |
      | test_user | 111111 | conn_0 | False   | drop table aly_order         | success |
      | test_user | 111111 | conn_0 | False   | drop table test              | success |
      | test_user | 111111 | conn_0 | False   | drop table no_config_t       | success |
      | test_user | 111111 | conn_0 | False   | drop table testdb.test1      | success |
      | test_user | 111111 | conn_0 | False   | drop table testdb.test2      | success |
      | test_user | 111111 | conn_0 | False   | drop table testdb.test3      | success |
      | test_user | 111111 | conn_0 | True    | drop table testdb.test4      | success |

  @NORMAL
  Scenario: check user privileges work right under check=false setting #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn5" sqlMaxLimit="100">
          <shardingTable name="aly_test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="aly_order" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
      </schema>

      <schema name="testdb" sqlMaxLimit="100">
          <shardingTable name="test1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="test2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="test3" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test_user" password="111111" schemas="schema1,testdb">
        <privileges check="false">
            <schema name="schema1" dml="0000" >
                <table name="aly_test" dml="1111"></table>
                <table name="aly_order" dml="0010"></table>
            </schema>
            <schema name="testdb" dml="1111" >
                <table name="test1" dml="0000"></table>
                <table name="test2" dml="0110"></table>
            </schema>
        </privileges>
    </shardingUser>
    """
    Then execute admin cmd "reload @@config_all"
    #table has explict privileges, not all privileges available, with no check to privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                             | expect  |
      | test_user | 111111 | conn_0 | False   | use schema1                                     | success |
      | test_user | 111111 | conn_0 | False   | drop table if exists aly_order                  | success |
      | test_user | 111111 | conn_0 | False   | create table aly_order(id int, name varchar(10))| success |
      | test_user | 111111 | conn_0 | False   | insert into aly_order value(1,'a')              | success |
      | test_user | 111111 | conn_0 | False   | update aly_order set name='b' where id=1        | success |
      | test_user | 111111 | conn_0 | False   | select * from aly_order                         | success |
      | test_user | 111111 | conn_0 | False   | delete from aly_order                           | success |
      | test_user | 111111 | conn_0 | False   | show create table aly_order                     | success |
      | test_user | 111111 | conn_0 | True    | drop table aly_order                            | success |

  @CRITICAL @current
  Scenario: config only schema level privileges, tables in the schema privileges will inherit it #5
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="schema_permission" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="testA" password="testA" schemas="schema1">
        <privileges check="true">
            <schema name="schema1" dml="0000" />
        </privileges>
    </shardingUser>
    <shardingUser name="testB" password="testB" schemas="schema1">
        <privileges check="true">
            <schema name="schema1" dml="1111" />
        </privileges>
    </shardingUser>
    <shardingUser name="testC" password="testC" schemas="schema1">
        <privileges check="true">
            <schema name="schema1" dml="0001" />
        </privileges>
    </shardingUser>
    <shardingUser name="testD" password="testD" schemas="schema1">
        <privileges check="true">
            <schema name="schema1" dml="0010" />
        </privileges>
    </shardingUser>
    <shardingUser name="testE" password="testE" schemas="schema1">
      <privileges check="true">
            <schema name="schema1" dml="0100" />
        </privileges>
    </shardingUser>
    <shardingUser name="testF" password="testF" schemas="schema1">
      <privileges check="true">
            <schema name="schema1" dml="1000" />
        </privileges>
    </shardingUser>
    """
    Then execute admin cmd "reload @@config_all"
    Then test only schema level privilege configed
      | user  | password | schema  | dml   | table             |
      | testA | testA    | schema1 | 0000  | schema_permission |
      | testB | testB    | schema1 | 1111  | schema_permission |
      | testC | testC    | schema1 | 0001  | schema_permission |
      | testD | testD    | schema1 | 0010  | schema_permission |
      | testE | testE    | schema1 | 0100  | schema_permission |
      | testF | testF    | schema1 | 1000  | schema_permission |

  @BLOCKER
  Scenario: mix privilege config: readonly + schema #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="readonly_schema1" password="readonly_schema1" schemas="schema1" readOnly="true">
      <privileges check="true">
            <schema name="schema1" dml="1111" />
        </privileges>
    </shardingUser>
    <shardingUser name="readonly_schema2" password="readonly_schema2" schemas="schema1" readOnly="true">
      <privileges check="true">
            <schema name="schema1" dml="0000" />
        </privileges>
    </shardingUser>
    <shardingUser name="readonly_schema3" password="readonly_schema3" schemas="schema1" readOnly="true">
      <privileges check="true">
            <schema name="schema1" dml="1101" />
        </privileges>
    </shardingUser>
    """
    Then execute admin cmd "reload @@config_all"
    Then Test config readonly and schema permission feature
      | user  | password | schema  | dml   | table             |
      | testA | testA    | schema1 | 0000  | schema_permission |
      | testB | testB    | schema1 | 1111  | schema_permission |
      | testC | testC    | schema1 | 0001  | schema_permission |
      | testD | testD    | schema1 | 0010  | schema_permission |
      | testE | testE    | schema1 | 0100  | schema_permission |
      | testF | testF    | schema1 | 1000  | schema_permission |
    """
    [{"user":"readonly_schema1","password":"readonly_schema1","schema":"schema1","dml":"1111","table":"schema_permission"},
    {"user":"readonly_schema2","password":"readonly_schema2","schema":"schema1","dml":"0000","table":"schema_permission"},
    {"user":"readonly_schema3","password":"readonly_schema3","schema":"schema1","dml":"1101","table":"schema_permission"}
    ]
    """
    Given delete the following xml segment
      |file        | parent                 | child                                               |
      |user.xml  | {'tag':'root'}         | {'tag':'shardingUser','kv_map':{'name':'readonly_schema1'}} |
      |user.xml  | {'tag':'root'}         | {'tag':'shardingUser','kv_map':{'name':'readonly_schema2'}} |
      |user.xml  | {'tag':'root'}         | {'tag':'shardingUser','kv_map':{'name':'readonly_schema3'}} |
    Then execute admin cmd "reload @@config_all"

  @NORMAL
  Scenario: config both table and schema privileges, table's privilege prior to schema's #7
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="schema_table1" password="schema_table1" schemas="schema1">
     <privileges check="true">
            <schema name="schema1" dml="1111">
                <table name="table1" dml="1111"></table>
                <table name="table2" dml="0000"></table>
                <table name="table3" dml="0001"></table>
                <table name="table4" dml="0010"></table>
                <table name="table5" dml="0100"></table>
                <table name="table6" dml="1000"></table>
            </schema>
        </privileges>
    </shardingUser>
    <shardingUser name="schema_table2" password="schema_table2" schemas="schema1">
        <privileges check="true">
            <schema name="schema1" dml="0000">
                <table name="table1" dml="1111"></table>
                <table name="table2" dml="0000"></table>
                <table name="table3" dml="0001"></table>
                <table name="table4" dml="0010"></table>
                <table name="table5" dml="0100"></table>
                <table name="table6" dml="1000"></table>
            </schema>
        </privileges>
    </shardingUser>
    """
    Then execute admin cmd "reload @@config_all"
    Then Test config schema and table permission feature
    """
    [{"user":"schema_table1","password":"schema_table1","schema":"schema1","schema_dml":"1111","single_table":"schema_permission","tables_config":
        {"tables":[{"dml":"1111","table":"table1"},
                   {"dml":"0000","table":"table2"},
                   {"dml":"0001","table":"table3"},
                   {"dml":"0010","table":"table4"},
                   {"dml":"0100","table":"table5"},
                   {"dml":"1000","table":"table6"}]
        }
     },
     {"user":"schema_table2","password":"schema_table2","schema":"schema1","schema_dml":"0000","single_table":"schema_permission","tables_config":
        {"tables":[{"dml":"1111","table":"table1"},
                   {"dml":"0000","table":"table2"},
                   {"dml":"0001","table":"table3"},
                   {"dml":"0010","table":"table4"},
                   {"dml":"0100","table":"table5"},
                   {"dml":"1000","table":"table6"}]
        }
     }
    ]
    """
    Given delete the following xml segment
      |file        | parent                 | child                                            |
      |user.xml  | {'tag':'root'}         | {'tag':'shardingUser','kv_map':{'name':'schema_table1'}} |
      |user.xml  | {'tag':'root'}         | {'tag':'shardingUser','kv_map':{'name':'schema_table2'}} |
      |sharding.xml  | {'tag':'schema','kv_map':{'name':'schema1'}} | {'tag':'shardingTable','kv_map':{'name':'schema_permission'}} |
    Then execute admin cmd "reload @@config_all"