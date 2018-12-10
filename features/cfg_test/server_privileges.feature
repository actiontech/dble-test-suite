Feature:test user's privileges under different combination
  dml:xxxx in order "insert,update,select,delete"

  @regression
  Scenario: config privileges, including exist schema, different privileges, not exist schema,reload success #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn5" name="testdb" sqlMaxLimit="100"></schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">test_password</property>
        <property name="schemas">mytest,testdb</property>
        <property name="readOnly">true</property>
        <privileges check="true">
            <schema name="mytest" dml="0000" >
                <table name="tableA" dml="1111"></table>
                <table name="tableB" dml="1111"></table>
            </schema>
            <schema name="testdb" dml="1111" >
                <table name="test1" dml="0000"></table>
                <table name="test2" dml="0110"></table>
            </schema>
        </privileges>
    </user>
    """
    Then execute admin cmd "reload @@config_all"

  @regression
  Scenario: add readonly client user, user can only read #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
     <user name="test_user">
        <property name="password">test_password</property>
        <property name="schemas">mytest</property>
        <property name="readOnly">true</property>
     </user>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd        | conn   | toClose | sql      | expect  | db     |
        | test_user    | test_password | conn_0 | False   | select 1 | success | mytest |
        | test_user    | test_password | conn_0 | True    | drop table if exists test_table | User READ ONLY | mytest |

  @smoke
  Scenario: check user privileges work right under check=true setting, including:
  tables' explict privileges prior to schema's,
  one client users' privileges not affected by others,
  tables have no explict privileges use schema's privilege,
  tables in default schema node will use default privileges or explict privileges configed for them,
  tables have different privileges do join or union
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn5" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="aly_test" rule="hash-four" />
		    <table dataNode="dn1,dn2,dn3,dn4" name="aly_order" rule="hash-four" />
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" type="global" />
    </schema>
    <schema name="testdb" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test1" rule="hash-four" />
		    <table dataNode="dn1,dn2,dn3,dn4" name="test2" rule="hash-four" />
		    <table dataNode="dn1,dn2,dn3,dn4" name="test3" rule="hash-four" />
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">111111</property>
        <property name="schemas">mytest,testdb</property>
        <privileges check="true">
            <schema name="mytest" dml="0000" >
                <table name="aly_test" dml="1111"></table>
                <table name="aly_order" dml="0010"></table>
            </schema>
            <schema name="testdb" dml="1111" >
                <table name="test1" dml="0000"></table>
                <table name="test2" dml="0110"></table>
                <table name="test4" dml="0110"></table>
            </schema>
        </privileges>
    </user>
    """
    Then execute admin cmd "reload @@config_all"
    #table has explict privileges, and all privileges available
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                             | expect  | db   |
      | test_user | 111111 | conn_0 | False   | use mytest                                      | success |      |
      | test_user | 111111 | conn_0 | False   | drop table if exists aly_test                   | success |      |
      | test_user | 111111 | conn_0 | False   | create table aly_test(id int, name varchar(10)) | success |      |
      | test_user | 111111 | conn_0 | False   | insert into aly_test value(1,'a')               | success |      |
      | test_user | 111111 | conn_0 | False   | update aly_test set name='b' where id=1         | success |      |
      | test_user | 111111 | conn_0 | False   | select * from aly_test                          | success |      |
      | test_user | 111111 | conn_0 | False   | delete from aly_test                            | success |      |
      | test_user | 111111 | conn_0 | False   | show create table aly_test                      | success |      |
    #other user's privileges to a certain table does not affected by test_user
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                             | expect  | db   |
      | test | 111111 | conn_1 | False   | use mytest                                      | success |      |
      | test | 111111 | conn_1 | False   | drop table if exists aly_test                   | success |      |
      | test | 111111 | conn_1 | False   | create table aly_test(id int, name varchar(10)) | success |      |
      | test | 111111 | conn_1 | False   | insert into aly_test value(1,'a')               | success |      |
      | test | 111111 | conn_1 | False   | update aly_test set name='b' where id=1         | success |      |
      | test | 111111 | conn_1 | False   | select * from aly_test                          | success |      |
      | test | 111111 | conn_1 | False   | delete from aly_test                            | success |      |
      | test | 111111 | conn_1 | True    | show create table aly_test                      | success |      |
    #table has explict privileges, not all privileges available
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                             | expect  | db   |
      | test_user | 111111 | conn_0 | False   | use mytest                                      | success |      |
      | test_user | 111111 | conn_0 | False   | drop table if exists aly_order                  | success |      |
      | test_user | 111111 | conn_0 | False   | create table aly_order(id int, name varchar(10))| success |      |
      | test_user | 111111 | conn_0 | False   | insert into aly_order value(1,'a')              | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | update aly_order set name='b' where id=1        | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | select * from aly_order                         | success |      |
      | test_user | 111111 | conn_0 | False   | delete from aly_order                           | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | show create table aly_order                     | success |      |
    #table has not explicit privileges assign,using default schema privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                        | expect  | db   |
      | test_user | 111111 | conn_0 | False   | use mytest                                 | success |      |
      | test_user | 111111 | conn_0 | False   | drop table if exists test                  | success |      |
      | test_user | 111111 | conn_0 | False   | create table test(id int, name varchar(10))| success |      |
      | test_user | 111111 | conn_0 | False   | insert into test value(1,'a')              | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | update test set name='b' where id=1        | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | select * from test                         | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | delete from test                           | DML privilege check is not passed |      |
    #table logic schema default node, use schema's default privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                               | expect  | db   |
      | test_user | 111111 | conn_0 | False   | use mytest                                        | success |      |
      | test_user | 111111 | conn_0 | False   | drop table if exists no_config_t                  | success |      |
      | test_user | 111111 | conn_0 | False   | create table no_config_t(id int, name varchar(10))| success |      |
      | test_user | 111111 | conn_0 | False   | insert into no_config_t value(1,'a')              | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | update no_config_t set name='b' where id=1        | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | select * from no_config_t                         | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | delete from no_config_t                           | DML privilege check is not passed |      |
    #table test1 has no dml privileges, schema has all dml privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                         | expect  | db   |
      | test_user | 111111 | conn_0 | False   | use testdb                                  | success |      |
      | test_user | 111111 | conn_0 | False   | drop table if exists test1                  | success |      |
      | test_user | 111111 | conn_0 | False   | create table test1(id int, name varchar(10))| success |      |
      | test_user | 111111 | conn_0 | False   | insert into test1 value(1,'a')              | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | update test1 set name='b' where id=1        | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | select * from test1                         | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | delete from test1                           | DML privilege check is not passed |      |
    #table test2 has part of dml privileges, schema has all dml privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                         | expect  | db   |
      | test_user | 111111 | conn_0 | False   | use testdb                                  | success |      |
      | test_user | 111111 | conn_0 | False   | drop table if exists test2                  | success |      |
      | test_user | 111111 | conn_0 | False   | create table test2(id int, name varchar(10))| success |      |
      | test_user | 111111 | conn_0 | False   | insert into test2 value(1,'a')              | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | update test2 set name='b' where id=1        | success |      |
      | test_user | 111111 | conn_0 | False   | select * from test2                         | success |      |
      | test_user | 111111 | conn_0 | False   | delete from test2                           | DML privilege check is not passed |      |
    #table test4 in schema's default, test4 has explicit dml privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                         | expect  | db   |
      | test_user | 111111 | conn_0 | False   | use testdb                                  | success |      |
      | test_user | 111111 | conn_0 | False   | drop table if exists test4                  | success |      |
      | test_user | 111111 | conn_0 | False   | create table test4(id int, name varchar(10))| success |      |
      | test_user | 111111 | conn_0 | False   | insert into test4 value(1,'a')              | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | update test4 set name='b' where id=1        | success |      |
      | test_user | 111111 | conn_0 | False   | select * from test4                         | success |      |
      | test_user | 111111 | conn_0 | False   | delete from test4                           | DML privilege check is not passed |      |
    #table test3 has no privileges setting, schema has all dml privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                         | expect  | db   |
      | test_user | 111111 | conn_0 | False   | use testdb                                  | success |      |
      | test_user | 111111 | conn_0 | False   | drop table if exists test3                  | success |      |
      | test_user | 111111 | conn_0 | False   | create table test3(id int, name varchar(10))| success |      |
      | test_user | 111111 | conn_0 | False   | insert into test3 value(1,'a')              | success |      |
      | test_user | 111111 | conn_0 | False   | update test3 set name='b' where id=1        | success |      |
      | test_user | 111111 | conn_0 | False   | select * from test3                         | success |      |
      | test_user | 111111 | conn_0 | False   | delete from test3                           | success |      |
    #table has different privileges do join or union
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                             | expect  | db   |
      | test_user | 111111 | conn_0 | False   | select * from mytest.aly_test a join mytest.aly_order b on a.id=b.id | success |      |
      | test_user | 111111 | conn_0 | False   | select * from mytest.aly_test a join mytest.test b on a.id=b.id      | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | select * from mytest.test a join mytest.no_config_t b on a.id=b.id   | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | select * from mytest.aly_test a join testdb.test1 b on a.id=b.id     | DML privilege check is not passed |      |
      | test_user | 111111 | conn_0 | False   | select * from mytest.aly_test a join test2 b on a.id=b.id            | success |      |
      | test_user | 111111 | conn_0 | False   | select * from mytest.aly_test union select * from mytest.aly_order   | success |      |
      | test_user | 111111 | conn_0 | False   | select * from mytest.aly_test union select * from testdb.test1       | DML privilege check is not passed |      |
#@skip for https://github.com/actiontech/dble/issues/860      | test_user | 111111 | conn_0 | False   | select * from mytest.aly_test union select * from mytest.test       | DML privilege check is not passed |      |
    #clear tables and close conn
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                          | expect  | db   |
      | test_user | 111111 | conn_0 | False   | use mytest                   | success |      |
      | test_user | 111111 | conn_0 | False   | truncate table aly_test      | success |      |
      | test_user | 111111 | conn_0 | False   | truncate table aly_order     | success |      |
      | test_user | 111111 | conn_0 | False   | truncate table test          | success |      |
      | test_user | 111111 | conn_0 | False   | drop table aly_test          | success |      |
      | test_user | 111111 | conn_0 | False   | drop table aly_order         | success |      |
      | test_user | 111111 | conn_0 | False   | drop table test              | success |      |
      | test_user | 111111 | conn_0 | False   | drop table no_config_t       | success |      |
      | test_user | 111111 | conn_0 | False   | drop table testdb.test1      | success |      |
      | test_user | 111111 | conn_0 | False   | drop table testdb.test2      | success |      |
      | test_user | 111111 | conn_0 | False   | drop table testdb.test3      | success |      |
      | test_user | 111111 | conn_0 | True    | drop table testdb.test4      | success |      |

  @regression
  Scenario: check user privileges work right under check=false setting
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn5" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="aly_test" rule="hash-four" />
		    <table dataNode="dn1,dn2,dn3,dn4" name="aly_order" rule="hash-four" />
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" type="global" />
    </schema>
    <schema name="testdb" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test1" rule="hash-four" />
		    <table dataNode="dn1,dn2,dn3,dn4" name="test2" rule="hash-four" />
		    <table dataNode="dn1,dn2,dn3,dn4" name="test3" rule="hash-four" />
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">111111</property>
        <property name="schemas">mytest,testdb</property>
        <privileges check="false">
            <schema name="mytest" dml="0000" >
                <table name="aly_test" dml="1111"></table>
                <table name="aly_order" dml="0010"></table>
            </schema>
            <schema name="testdb" dml="1111" >
                <table name="test1" dml="0000"></table>
                <table name="test2" dml="0110"></table>
            </schema>
        </privileges>
    </user>
    """
    Then execute admin cmd "reload @@config_all"
    #table has explict privileges, not all privileges available, with no check to privileges
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                             | expect  | db   |
      | test_user | 111111 | conn_0 | False   | use mytest                                      | success |      |
      | test_user | 111111 | conn_0 | False   | drop table if exists aly_order                  | success |      |
      | test_user | 111111 | conn_0 | False   | create table aly_order(id int, name varchar(10))| success |      |
      | test_user | 111111 | conn_0 | False   | insert into aly_order value(1,'a')              | success |      |
      | test_user | 111111 | conn_0 | False   | update aly_order set name='b' where id=1        | success |      |
      | test_user | 111111 | conn_0 | False   | select * from aly_order                         | success |      |
      | test_user | 111111 | conn_0 | False   | delete from aly_order                           | success |      |
      | test_user | 111111 | conn_0 | False   | show create table aly_order                     | success |      |
      | test_user | 111111 | conn_0 | True    | drop table aly_order                            | success |      |