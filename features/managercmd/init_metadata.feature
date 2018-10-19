Feature:
  Scenario: #1 same table name
    # 1.1 same table name in different database
    # 1.2 no-sharding table's name is same as sharding table's name
    # 1.3 no-sharding table's name is same as global table's name
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
    <user name="test_user">
        <property name="password">test_password</property>
        <property name="schemas">mytest,testdb</property>
    </user>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user       | passwd         | conn   | toClose | sql                                                      | expect          | db     |
      | test_user | test_password | conn_0 | True    | drop table if exists test_shard                      | success         | mytest |
      | test_user | test_password | conn_0 | True    | drop table if exists test_shard                      | success         | testdb   |
      | test_user | test_password | conn_0 | True    | create table test_shard(id int,name char)           | success         | mytest |
      | test_user | test_password | conn_0 | True    | create table test_shard(id int,name char,age int)  | success         | testdb   |
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user       | passwd         | conn   | toClose | sql                                                | expect                                                   | db     |
      | test_user | test_password | conn_0 | True    | insert into test_shard values(1,1,1)           | Column count doesn't match value count at row 1    | mytest |
      | test_user | test_password | conn_0 | True    | insert into test_shard values(1,1)             | success                                                  | mytest |
      | test_user | test_password | conn_0 | True    | insert into test_shard values(1,1)             | Column count doesn't match value count at row 1     | testdb   |
      | test_user | test_password | conn_0 | True    | insert into test_shard values(1,1,1)           | success                                                  | testdb   |
    Then execute sql in "dble-1" in "admin" mode
      | user         | passwd    | conn   | toClose | sql      | expect  | db     |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_shard' | hasNoStr{`age` int(11) DEFAULT NULL} |  |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_shard' | hasStr{`id` int(11) DEFAULT NULL} |  |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='testdb' and table='test_shard' | hasStr{`age` int(11) DEFAULT NULL} |  |

    Then execute sql in "dble-1" in "user" mode
      | user       | passwd         | conn   | toClose | sql                                                      | expect          | db     |
      | test_user | test_password | conn_0 | True    | drop table if exists test1                      | success         | mytest   |
      | test_user | test_password | conn_0 | True    | create table test1(id int,name1 char,age int,name2 char)  | success         | mytest   |
      | test_user | test_password | conn_0 | True    | insert into test1 values(1,1,1,1)  |  success         | mytest   |
    Then execute sql in "dble-1" in "admin" mode
      | user         | passwd    | conn   | toClose | sql      | expect  | db     |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='mytest' and table='test1' | hasStr{`name2` char(1) DEFAULT NULL} |  |
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
      | user       | passwd         | conn   | toClose | sql                                                  | expect          | db     |
      | test_user | test_password | conn_0 | True    | drop table if exists test1                        | success         | mytest   |
      | test_user | test_password | conn_0 | True    | create table test1(id int,name char,age int)    | success         | mytest   |
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user       | passwd         | conn   | toClose | sql                                                  | expect          | db     |
      | test_user | test_password | conn_0 | True    | insert into test1 values(1,1,1,1)                 |  Column count doesn't match value count at row 1         | mytest   |
      | test_user | test_password | conn_0 | True    | insert into test1 values(2,2,2)                   | success       | mytest   |
      | test_user | test_password | conn_0 | True    | alter table test1 drop name                        | success       | mytest   |
    Then execute sql in "dble-1" in "admin" mode
      | user         | passwd    | conn   | toClose | sql      | expect  | db     |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='mytest' and table='test1' | hasStr{`age` int(11) DEFAULT NULL} |  |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='mytest' and table='test1' | hasNoStr{`name`} |  |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='mytest' and table='test1' | hasNoStr{`name2`} |  |
      | root         | 111111    | conn_0 | True    | check @@metadata | success |  |

    Then execute sql in "dble-1" in "user" mode
      | user       | passwd         | conn   | toClose | sql                                                  | expect          | db     |
      | test_user | test_password | conn_0 | True    | drop table if exists test1                        | success         | testdb   |
      | test_user | test_password | conn_0 | True    | create table test1(id int)    | success         | testdb   |
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user       | passwd         | conn   | toClose | sql                                                  | expect          | db     |
      | test_user | test_password | conn_0 | True    | insert into test1 values(1,1,1,1)                 |  In insert Syntax, you can't set value for Global check column!         | testdb   |
      | test_user | test_password | conn_0 | True    | insert into test1 values(2,2)                   | In insert Syntax, you can't set value for Global check column!       | testdb   |
      | test_user | test_password | conn_0 | True    | insert into test1 values(3)                   | success       | testdb   |
      | test_user | test_password | conn_0 | True    | alter table test1 add name char                       | success       | testdb   |
    Then execute sql in "dble-1" in "admin" mode
      | user         | passwd    | conn   | toClose | sql      | expect  | db     |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='testdb' and table='test1' | hasNoStr{`age` int(11) DEFAULT NULL} |  |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='testdb' and table='test1' | hasStr{`name`} |  |
    Then execute sql in "dble-1" in "user" mode
      | user       | passwd         | conn   | toClose | sql                                                  | expect          | db     |
      | test_user | test_password | conn_0 | True    | drop table if exists test1                        | success         | testdb   |
      | test_user | test_password | conn_0 | True    | drop table if exists test1                        | success         | mytest   |
      | test_user | test_password | conn_0 | True    | drop table if exists test_shard                        | success         | testdb   |
      | test_user | test_password | conn_0 | True    | drop table if exists test_shard                        | success         | mytest   |

  Scenario: #2 Number of tables
    #2.1 no tables in the schema
    #2.2 one table in teh schema
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose  | sql                            | expect   | db     |
      | test | 111111 | conn_0 | True     | drop database if exists db3 | success  |        |
      | test | 111111 | conn_0 | True     | create database db3          | success  |        |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="mytest" sqlMaxLimit="100" dataNode="dn5">
    </schema>
	"""
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user         | passwd    | conn   | toClose | sql                                               | expect   | db     |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='mytest'  | success  |        |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                          | expect      | db        |
      | test | 111111 | conn_0 | True    | drop table if exists test                                 | success     | mytest   |
      | test | 111111 | conn_0 | True    | create table test(id int,name char,age int)            | success     | mytest    |
      | test | 111111 | conn_0 | True    | insert into test values(1,1,1)                           | success     | mytest   |
      | test | 111111 | conn_0 | True    | alter table test drop name                                | success     | mytest   |
      | test | 111111 | conn_0 | True    | insert into test values(2,2)                              | success     | mytest   |
    Then execute sql in "dble-1" in "admin" mode
      | user         | passwd    | conn   | toClose | sql                                                | expect                                  | db   |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='mytest'   |hasStr{`age` int(11) DEFAULT NULL}  |       |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='mytest'   |hasNoStr{`name`}                       |       |
      | root         | 111111    | conn_0 | True    | reload @@metadata                                 | success                                |       |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                            | expect          | db       |
      | test | 111111 | conn_0 | True    | insert into test values(3,3)                                | success         | mytest   |
      | test | 111111 | conn_0 | True    | alter table test drop age                                   | success         | mytest   |
      | test | 111111 | conn_0 | True    | insert into test values(4)                                  | success         | mytest   |
    Then execute sql in "dble-1" in "admin" mode
      | user         | passwd    | conn   | toClose | sql      | expect  | db     |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='mytest' |hasNoStr{`age` int(11) DEFAULT NULL}  |  |
      | root         | 111111    | conn_0 | True    | check full @@metadata where schema='mytest' |hasStr{`id` int(11) DEFAULT NULL}     |  |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                  | expect          | db       |
      | test | 111111 | conn_0 | True    | drop table if exists test                         | success         | mytest   |












