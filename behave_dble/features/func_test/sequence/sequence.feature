# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: Functional testing of global sequences
  common test for global sequences column:
  insert or insert...set explicitly to global sequence column get error
  insert without value of global sequence column success

  @BLOCKER
  Scenario: test global sequenceHandlerType: 1(MySQL-offset-step) #1
#    case points:
#  1.sequence column can't be inserted by client, and other limits to query
#  2.sequence column value should be unique
#  3.single thread insert values to sequenceColumn, the values should be continuous
#  4.multiple thread insert values to sequenceColumn, the vlaues should be unique, and insert time should be tolerable(<1s)
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="test_auto" shardingNode="dn1,dn2,dn3,dn4" incrementColumn="id" shardingColumn="id" function="hash-four" />
    """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
        $a sequenceHandlerType=1
    """
    When Add some data in "sequence_db_conf.properties"
    """
    `schema1`.`test_auto`=dn1
    """
    Then initialize mysql-off-step sequence table
    Given Restart dble in "dble-1" success
    #case 1: can not assign value to sequenceColumn, and can assgin value to columns without sequenceColumn
    Then execute sql in "dble-1" in "user" mode
        | conn   | toClose | sql                                                                            | expect            | db     |
        | conn_0 | False   | drop table if exists test_auto                                                 | success           | schema1 |
        | conn_0 | False   | create table test_auto(id bigint primary key auto_increment, name varchar(20)) | success           | schema1 |
        | conn_0 | False   | insert into test_auto values('abc')                                            | success           | schema1 |
        | conn_0 | False   | insert into test_auto(name) values('abc')            | success | schema1 |
        | conn_0 | False   | insert into test_auto(id,name) values(1, 'abc')      | In insert Syntax, you can't set value for Autoincrement column| schema1 |
        | conn_0 | False   | insert into test_auto set id=1, name='abc'           | In insert Syntax, you can't set value for Autoincrement column| schema1 |
        | conn_0 | False   | insert into test_auto set name='abc'                 | success | schema1 |
        | conn_0 | False   | insert into test_auto values('abc'),('abc'),('abc')  | success | schema1 |
        | conn_0 | False   | drop table if exists test_auto                       | success | schema1 |
        | conn_0 | False   | create table test_auto(id bigint , name varchar(20)) | success | schema1 |
        | conn_0 | False   | insert into test_auto values('abc')                  | success | schema1 |
        | conn_0 | False   | insert into test_auto(name) values('abc')            | success | schema1 |
        | conn_0 | False   | drop table if exists test_auto                       | success | schema1 |
        | conn_0 | False   | create table test_auto(idd bigint, name varchar(20)) | success | schema1 |
        | conn_0 | False   | insert into test_auto values('abc')                  | please make sure your table structure has incrementColumn | schema1 |
        | conn_0 | True    | insert into test_auto(name) values('abc')            | please make sure your table structure has incrementColumn | schema1 |
    Then execute sql in "dble-1" in "user" mode
        | conn   | toClose | sql                                                                            | expect  | db      |
        | conn_0 | False   | drop table if exists test_auto                                                 | success | schema1 |
        | conn_0 | True    | create table test_auto(id bigint primary key auto_increment, name varchar(20)) | success | schema1 |
    Then insert "1000" rows to global sequence table "test_auto" in "1" thread
#    case 2: check global sequence column value is unique
    Then execute sql in "dble-1" in "user" mode
      | sql                                                            | expect      | db      |
      | select count(*) from test_auto having count(*) > 1 group by id | length{(0)} | schema1 |
#    case 3: check global sequence column value is continus
    Then execute sql in "dble-1" in "user" mode
      | sql                                     | expect        | db      |
      | select max(id)-min(id)+1 from test_auto | match{(1000)} | schema1 |
    Then insert "1000" rows to global sequence table "test_auto" in "10" thread
#    case 4: check global sequence column value is unique after multiple theads insert, maybe not suiltable test with python language for cpython GIL
    Then execute sql in "dble-1" in "user" mode
      | sql                                                            | expect      | db      |
      | select count(*) from test_auto having count(*) > 1 group by id | length{(0)} | schema1 |

  @BLOCKER  @current
  Scenario: test global sequenceHandlerType: 2(snowflake) #2
#    case points:
#  1.sequence column can't be inserted by client
#  2.sequence column value should be unique
#  3.multiple thread insert values to sequenceColumn, the vlaues should be unique
#  4.int type for current type sequence type is err, expect bigint

    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="test_auto" shardingNode="dn1,dn2,dn3,dn4" incrementColumn="id" shardingColumn="id" function="hash-four" />
    """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
        $a sequenceHandlerType=2
    """
    Given Restart dble in "dble-1" success
    #case 1: can not assign value to sequenceColumn, and can assgin value to columns without sequenceColumn
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                            | expect            | db     |
      | conn_0 | False   | drop table if exists test_auto                                                 | success           | schema1 |
      | conn_0 | False   | create table test_auto(id bigint primary key auto_increment, name varchar(20)) | success           | schema1 |
      | conn_0 | False   | insert into test_auto values('abc')                                            | success           | schema1 |
      | conn_0 | False   | insert into test_auto(name) values('abc')            | success | schema1 |
      | conn_0 | False   | insert into test_auto(id,name) values(1, 'abc')      | In insert Syntax, you can't set value for Autoincrement column| schema1 |
      | conn_0 | False   | insert into test_auto set id=1, name='abc'           | In insert Syntax, you can't set value for Autoincrement column| schema1 |
      | conn_0 | False   | insert into test_auto set name='abc'                 | success | schema1 |
      | conn_0 | False   | insert into test_auto values('abc'),('abc'),('abc')  | success | schema1 |
      | conn_0 | False   | drop table if exists test_auto                       | success | schema1 |
      | conn_0 | False   | create table test_auto(id bigint , name varchar(20)) | success | schema1 |
      | conn_0 | False   | insert into test_auto values('abc')                  | success | schema1 |
      | conn_0 | False   | insert into test_auto(name) values('abc')            | success | schema1 |
      | conn_0 | False   | drop table if exists test_auto                       | success | schema1 |
      | conn_0 | False   | create table test_auto(idd bigint, name varchar(20)) | success | schema1 |
      | conn_0 | False   | insert into test_auto values('abc')                  | please make sure your table structure has incrementColumn | schema1 |
      | conn_0 | False   | insert into test_auto(name) values('abc')            | please make sure your table structure has incrementColumn | schema1 |
      | conn_0 | True    | drop table if exists test_auto                       | success | schema1 |
    #case 4: int type for current sequence type is err, sequence type expect bigint
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                          | expect            | db     |
      | conn_0 | False   | drop table if exists test_auto                                               | success           | schema1 |
      | conn_0 | False   | create table test_auto(id int primary key auto_increment, name varchar(20))  | success           | schema1 |
      | conn_0 | False   | insert into test_auto values('abc')                      | Out of range value for column | schema1 |
      | conn_0 | True    | insert into test_auto values('abc'),('abc'),('abc')      | Out of range value for column | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                            | expect   | db     |
      | conn_0 | False   | drop table if exists test_auto                                                 | success  | schema1 |
      | conn_0 | True    | create table test_auto(id bigint primary key auto_increment, name varchar(20)) | success  | schema1 |
    Then insert "1000" rows to global sequence table "test_auto" in "1" thread
#    case 2: check global sequence column value is unique
    Then execute sql in "dble-1" in "user" mode
      | sql                                                            | expect      | db      |
      | select count(*) from test_auto having count(*) > 1 group by id | length{(0)} | schema1 |
    Then insert "1000" rows to global sequence table "test_auto" in "10" thread
#    case 4: check global sequence column value is unique after multiple theads insert, maybe not suiltable test with python language for cpython GIL
    Then execute sql in "dble-1" in "user" mode
      | sql                                                            | expect      | db      |
      | select count(*) from test_auto having count(*) > 1 group by id | length{(0)} | schema1 |

 Scenario: Verify the illegal value of the parameter in the sequence_time_conf.properties  #3
  #    case points:
  #  1.Verify the illegal value of the instanceId
  #  2.Verify the illegal value of the sequenceStartTime
  #  3.sequenceStartTime>the time of dble start
  #  4.sequenceStartTime+69 years<the time of dble start
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="test_auto" shardingNode="dn1,dn2,dn3,dn4" incrementColumn="id" shardingColumn="id" function="hash-four" />
    """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
        $a sequenceHandlerType=2
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
        s/instanceId=.*/instanceId=-1/
    """
    Then restart dble in "dble-1" failed for
    """
        instanceId can't be greater than 1023 or less than 0
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
        s/instanceId=.*/instanceId=33/
    """
    Given Restart dble in "dble-1" success
    #case 2: Verify the illegal value of the instanceId
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
        s/instanceId=.*/instanceId=1025/
    """
    Then restart dble in "dble-1" failed for
    """
        instanceId can't be greater than 1023 or less than 0
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
        s/instanceId=.*/instanceId=-31/
    """
    Then restart dble in "dble-1" failed for
    """
        instanceId can't be greater than 1023 or less than 0
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
        s/instanceId=.*/instanceId=33/
    """
    Given Restart dble in "dble-1" success
    #case 3: Verify the illegal value of the sequenceStartTime, restart failed
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
     """
     $a sequenceStartTime=2010\/11\/04 09:42:54
     """
    Then restart dble in "dble-1" failed for
    """
        Invalid format: "2010/11/04 09:42:54" is malformed at "/11/04 09:42:54"
    """
#    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
#    """
#    sequenceStartTime in cluster.cnf parse exception, starting from 2010-11-04 09:42:54
#    """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
     """
      s/[#]*sequenceStartTime=.* /sequenceStartTime=2010-11-04 /
     """
    Given Restart dble in "dble-1" success
    #case 4: sequenceStartTime>the time of dble start, restart failed
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
      s/[#]*sequenceStartTime=.* /sequenceStartTime=2190-10-01 /
    """
    Then restart dble in "dble-1" failed for
    """
      sequenceStartTime in cluster.cnf mustn't be over than dble start time
    """
#    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
#    """
#    sequenceStartTime in cluster.cnf mustn'\''t be over than dble start time, starting from 2010-11-04 09:42:54
#    """
    #case 5: sequenceStartTime+69 years<the time of dble start
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
      s/[#]*sequenceStartTime=.* /sequenceStartTime=1910-10-01 /
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                             | expect         | db      |
      | conn_0 | False    |drop table if exists test_auto                   | success        | schema1 |
      | conn_0 | False    |create table test_auto(id bigint,time char(120)) | success        | schema1 |
      | conn_0 | True     |insert into test_auto values(1)                  | Global sequence has reach to max limit and can generate duplicate sequences | schema1 |
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
      s/[#]*sequenceStartTime=.* /sequenceStartTime=2010-11-04 /
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | sql                            | expect  | db      |
      |insert into test_auto values(1) | success | schema1 |