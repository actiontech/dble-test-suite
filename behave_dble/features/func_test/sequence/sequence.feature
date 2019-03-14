Feature: Functional testing of global sequences
  common test for global sequences column:
  insert or insert...set explicitly to global sequence column get error
  insert without value of global sequence column success

  @BLOCKER
  Scenario: test global sequnceHandlerType: 1(MySQL-offset-step) #1
#    case points:
#  1.sequence column can't be inserted by client, and other limits to query
#  2.sequence column value should be unique
#  3.single thread insert values to sequenceColumn, the values should be continuous
#  4.multiple thread insert values to sequenceColumn, the vlaues should be unique, and insert time should be tolerable(<1s)
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_auto" dataNode="dn1,dn2,dn3,dn4" primaryKey="id" autoIncrement="true" rule="hash-four" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="sequnceHandlerType">1</property>
    """
    When Add some data in "sequence_db_conf.properties"
    """
    `schema1`.`test_auto`=dn1
    """
    Then execute sqlFile to initialize sequence table
    Given Restart dble in "dble-1" success
    #case 1: can not assign value to sequenceColumn, and can assgin value to columns without sequenceColumn
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                            | expect            | db     |
        | test | 111111 | conn_0 | False   | drop table if exists test_auto                                                 | success           | schema1 |
        | test | 111111 | conn_0 | False   | create table test_auto(id bigint primary key auto_increment, name varchar(20)) | success           | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto values('abc')                                            | success           | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto(name) values('abc')            | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto(id,name) values(1, 'abc')      | In insert Syntax, you can't set value for Autoincrement column| schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto set id=1, name='abc'           | In insert Syntax, you can't set value for Autoincrement column| schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto set name='abc'                 | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto values('abc'),('abc'),('abc')  | success | schema1 |
        | test | 111111 | conn_0 | False   | drop table if exists test_auto                       | success | schema1 |
        | test | 111111 | conn_0 | False   | create table test_auto(id bigint , name varchar(20)) | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto values('abc')                  | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto(name) values('abc')            | success | schema1 |
        | test | 111111 | conn_0 | False   | drop table if exists test_auto                       | success | schema1 |
        | test | 111111 | conn_0 | False   | create table test_auto(idd bigint, name varchar(20)) | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto values('abc')                  | please make sure your table structure has primaryKey or incrementColumn | schema1 |
        | test | 111111 | conn_0 | True    | insert into test_auto(name) values('abc')            | please make sure your table structure has primaryKey or incrementColumn | schema1 |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                            | expect            | db     |
        | test | 111111 | conn_0 | False   | drop table if exists test_auto                                                 | success           | schema1 |
        | test | 111111 | conn_0 | Tru e   | create table test_auto(id bigint primary key auto_increment, name varchar(20)) | success           | schema1 |
    Then insert "1000" rows to global sequence table "test_auto" in "1" thread
#    case 2: check global sequence column value is unique
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                            | expect      | db      |
        | test | 111111 | conn_0 | True    | select count(*) from test_auto having count(*) > 1 group by id | length{(0)} | schema1 |
#    case 3: check global sequence column value is continus
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                     | expect        | db      |
        | test | 111111 | conn_0 | True    | select max(id)-min(id)+1 from test_auto | match{(1000)} | schema1 |
    Then insert "1000" rows to global sequence table "test_auto" in "10" thread
#    case 4: check global sequence column value is unique after multiple theads insert, maybe not suiltable test with python language for cpython GIL
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                            | expect      | db      |
        | test | 111111 | conn_0 | True    | select count(*) from test_auto having count(*) > 1 group by id | length{(0)} | schema1 |

  @BLOCKER  @current
  Scenario: test global sequnceHandlerType: 2(snowflake) #2
#    case points:
#  1.sequence column can't be inserted by client
#  2.sequence column value should be unique
#  3.multiple thread insert values to sequenceColumn, the vlaues should be unique
#  4.int type for current type sequence type is err, expect bigint

    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_auto" dataNode="dn1,dn2,dn3,dn4" primaryKey="id" autoIncrement="true" rule="hash-four" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="sequnceHandlerType">2</property>
    """
    Given Restart dble in "dble-1" success
    #case 1: can not assign value to sequenceColumn, and can assgin value to columns without sequenceColumn
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                            | expect            | db     |
        | test | 111111 | conn_0 | False   | drop table if exists test_auto                                                 | success           | schema1 |
        | test | 111111 | conn_0 | False   | create table test_auto(id bigint primary key auto_increment, name varchar(20)) | success           | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto values('abc')                                            | success           | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto(name) values('abc')            | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto(id,name) values(1, 'abc')      | In insert Syntax, you can't set value for Autoincrement column| schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto set id=1, name='abc'           | In insert Syntax, you can't set value for Autoincrement column| schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto set name='abc'                 | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto values('abc'),('abc'),('abc')  | success | schema1 |
        | test | 111111 | conn_0 | False   | drop table if exists test_auto                       | success | schema1 |
        | test | 111111 | conn_0 | False   | create table test_auto(id bigint , name varchar(20)) | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto values('abc')                  | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto(name) values('abc')            | success | schema1 |
        | test | 111111 | conn_0 | False   | drop table if exists test_auto                       | success | schema1 |
        | test | 111111 | conn_0 | False   | create table test_auto(idd bigint, name varchar(20)) | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto values('abc')                  | please make sure your table structure has primaryKey or incrementColumn | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto(name) values('abc')            | please make sure your table structure has primaryKey or incrementColumn | schema1 |
        | test | 111111 | conn_0 | True    | drop table if exists test_auto                       | success | schema1 |
    #case 4: int type for current type sequence type is err, expect bigint
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                    | expect            | db     |
        | test | 111111 | conn_0 | False   | drop table if exists test_auto                                               | success           | schema1 |
        | test | 111111 | conn_0 | False   | create table test_auto(id int primary key auto_increment, name varchar(20))  | success           | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto values('abc')                      | Out of range value for column | schema1 |
        | test | 111111 | conn_0 | True    | insert into test_auto values('abc'),('abc'),('abc')      | Out of range value for column | schema1 |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                            | expect            | db     |
        | test | 111111 | conn_0 | False   | drop table if exists test_auto                                                 | success           | schema1 |
        | test | 111111 | conn_0 | Tru e   | create table test_auto(id bigint primary key auto_increment, name varchar(20)) | success           | schema1 |
    Then insert "1000" rows to global sequence table "test_auto" in "1" thread
#    case 2: check global sequence column value is unique
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                            | expect      | db      |
        | test | 111111 | conn_0 | True    | select count(*) from test_auto having count(*) > 1 group by id | length{(0)} | schema1 |
    Then insert "1000" rows to global sequence table "test_auto" in "10" thread
#    case 4: check global sequence column value is unique after multiple theads insert, maybe not suiltable test with python language for cpython GIL
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                            | expect      | db      |
        | test | 111111 | conn_0 | True    | select count(*) from test_auto having count(*) > 1 group by id | length{(0)} | schema1 |
