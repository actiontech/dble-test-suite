# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
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
        <table name="test_auto" dataNode="dn1,dn2,dn3,dn4" incrementColumn="id" rule="hash-four" />
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
        | test | 111111 | conn_0 | False   | insert into test_auto values('abc')                  | please make sure your table structure has incrementColumn | schema1 |
        | test | 111111 | conn_0 | True    | insert into test_auto(name) values('abc')            | please make sure your table structure has incrementColumn | schema1 |
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
        <table name="test_auto" dataNode="dn1,dn2,dn3,dn4" incrementColumn="id" rule="hash-four" />
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
        | test | 111111 | conn_0 | False   | insert into test_auto values('abc')                  | please make sure your table structure has incrementColumn | schema1 |
        | test | 111111 | conn_0 | False   | insert into test_auto(name) values('abc')            | please make sure your table structure has incrementColumn | schema1 |
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

  Scenario: Verify the illegal value of the parameter in the sequence_time_conf.properties  #3
  #    case points:
  #  1.Verify the illegal value of the WORKID
  #  2.Verify the illegal value of the DATAACENTERID
  #  3.Verify the illegal value of the START_TIME
  #  4.START_TIME>the time of dble start
  #  5.START_TIME+69 years<the time of dble start
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_auto" dataNode="dn1,dn2,dn3,dn4" incrementColumn="id" rule="hash-four" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="sequnceHandlerType">2</property>
    """
    #case 1: Verify the illegal value of the WORKID
     Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1" with sed cmds
     """
      s/WORKID=.*/WORKID=32/
    """
    Then restart dble in "dble-1" failed for
    """
     worker Id can't be greater than 31 or less than 0
    """
    Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1" with sed cmds
     """
      s/WORKID=.*/WORKID=-1/
    """
    Then restart dble in "dble-1" failed for
    """
     worker Id can't be greater than 31 or less than 0
    """
    Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1" with sed cmds
     """
      s/WORKID=.*/WORKID=01/
    """
    Given Restart dble in "dble-1" success
    #case 2: Verify the illegal value of the DATAACENTERID
    Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1" with sed cmds
     """
      s/DATAACENTERID=.*/DATAACENTERID=32/
    """
    Then restart dble in "dble-1" failed for
    """
     datacenter Id can't be greater than 31 or less than 0
    """
    Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1" with sed cmds
     """
      s/DATAACENTERID=.*/DATAACENTERID=-1/
    """
    Then restart dble in "dble-1" failed for
    """
     datacenter Id can't be greater than 31 or less than 0
    """
     Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1" with sed cmds
     """
      s/DATAACENTERID=.*/DATAACENTERID=01/
    """
    Given Restart dble in "dble-1" success
    #case 3: Verify the illegal value of the START_TIME
    Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1" with sed cmds
     """
      s/[#]*START_TIME=.* /START_TIME=2010\/11\/04 /
    """
    Given Restart dble in "dble-1" success
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    START_TIME in sequence_time_conf.properties parse exception, starting from 2010-11-04 09:42:54
    """
    Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1" with sed cmds
     """
      s/[#]*START_TIME=.* /START_TIME=2010-11-04 /
    """
    Given Restart dble in "dble-1" success
    #case 4: START_TIME>the time of dble start
    Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1" with sed cmds
    """
    s/[#]*START_TIME=.* /START_TIME=2190-10-01 /
    """
    Given Restart dble in "dble-1" success
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    START_TIME in sequence_time_conf.properties mustn'\''t be over than dble start time, starting from 2010-11-04 09:42:54
    """
    #case 5: START_TIME+69 years<the time of dble start
    Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1" with sed cmds
    """
    s/[#]*START_TIME=.* /START_TIME=1910-10-01 /
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose  | sql                                                      | expect         | db     |
      | test | 111111 | conn_0 | True     |drop table if exists test_auto                        | success        | schema1 |
      | test | 111111 | conn_0 | True     |create table test_auto(id bigint,time char(120))    | success        | schema1 |
      | test | 111111 | conn_0 | True     |insert into test_auto values(1)                       | Global sequence has reach to max limit and can generate duplicate sequences        | schema1 |
    Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1" with sed cmds
    """
    s/[#]*START_TIME=.* /START_TIME=2010-11-04 /
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose  | sql                                                      | expect         | db     |
      | test | 111111 | conn_0 | True     |insert into test_auto values(1)                       | success        | schema1 |