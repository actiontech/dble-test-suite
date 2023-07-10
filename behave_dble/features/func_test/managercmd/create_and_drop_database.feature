# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/12/7
# Created by quexiuping at 2020/9/23

Feature: test "create database @@dataNode='dn1,dn2,...' and drop database @@dataNode='dn1,dn2,...'"

  @NORMAL
  Scenario: "create/drop database @@..." for all used datanode #1
     Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
     """
        <dataNode dataHost="ha_group1" database="da1" name="dn1" />
        <dataNode dataHost="ha_group2" database="da1" name="dn2" />
        <dataNode dataHost="ha_group1" database="da2" name="dn3" />
        <dataNode dataHost="ha_group2" database="da2" name="dn4" />
        <dataNode dataHost="ha_group1" database="da3" name="dn5" />
    """
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                         | expect   |
      | conn_0 | False    | drop database if exists da1 | success  |
      | conn_0 | False    | drop database if exists da2 | success  |
      | conn_0 | True     | drop database if exists da3 | success  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         | expect   |
      | conn_0 | False    | drop database if exists da1 | success  |
      | conn_0 | True     | drop database if exists da2 | success  |
    Then execute admin cmd "reload @@config_all -r"
    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4,dn5'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql             |
      | show @@dataNode |
    #TODO EXECUTE的值待确认
    Then check resultset "A" has lines with following column values
      | NAME-0 | DB_GROUP-1    | SCHEMA_EXISTS-2 | ACTIVE-3 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn1    | ha_group1/da1 | true            | 0        | 1000   | 0         | -1              |
      | dn2    | ha_group2/da1 | true            | 0        | 1000   | 1         | -1              |
      | dn3    | ha_group1/da2 | true            | 0        | 1000   | 0         | -1              |
      | dn4    | ha_group2/da2 | true            | 0        | 1000   | 0         | -1              |
      | dn5    | ha_group1/da3 | true            | 0        | 1000   | 1         | -1              |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                       | expect          |
      | conn_0 | False    | show databases like 'da1' | has{(('da1',),)}  |
      | conn_0 | False    | show databases like 'da2' | has{(('da2',),)}  |
      | conn_0 | True     | show databases like 'da3' | has{(('da3',),)}  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'da1'  | has{(('da1',),)}  |
      | conn_0 | True     | show databases like 'da2'  | has{(('da2',),)}  |
    Then execute admin cmd "drop database @@dataNode ='dn1,dn2,dn3,dn4,dn5'"
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                       | expect       |
      | conn_0 | False    | show databases like 'da1' | length{(0)}  |
      | conn_0 | False    | show databases like 'da2' | length{(0)}  |
      | conn_0 | True     | show databases like 'da3' | length{(0)}  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                        | expect      |
      | conn_0 | False    | show databases like 'da1'  | length{(0)} |
      | conn_0 | True     | show databases like 'da2'  | length{(0)} |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A1"
      | sql             |
      | show @@dataNode |
    #TODO EXECUTE的值待确认
    Then check resultset "A1" has lines with following column values
      | NAME-0 | DB_GROUP-1    | SCHEMA_EXISTS-2  | ACTIVE-3 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn1    | ha_group1/da1 | false            | 0        | 1000   | 0         | -1              |
      | dn2    | ha_group2/da1 | false            | 0        | 1000   | 1         | -1              |
      | dn3    | ha_group1/da2 | false            | 0        | 1000   | 0         | -1              |
      | dn4    | ha_group2/da2 | false            | 0        | 1000   | 0         | -1              |
      | dn5    | ha_group1/da3 | false            | 0        | 1000   | 1         | -1              |
    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4,dn5'"
    Then execute admin cmd "drop database @@dataNode ='dn1,dn2,dn3,dn4,dn5'"



  @NORMAL
  Scenario: "create database @@..." for part of used datanode #2
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
    """
        <dataNode dataHost="ha_group1" database="da11" name="dn1" />
        <dataNode dataHost="ha_group2" database="da11" name="dn2" />
        <dataNode dataHost="ha_group1" database="da21" name="dn3" />
        <dataNode dataHost="ha_group2" database="da21" name="dn4" />
        <dataNode dataHost="ha_group1" database="da31" name="dn5" />
    """
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                          | expect   |
      | conn_0 | False    | drop database if exists da11 | success  |
      | conn_0 | False    | drop database if exists da21 | success  |
      | conn_0 | True     | drop database if exists da31 | success  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                          | expect   |
      | conn_0 | False    | drop database if exists da11 | success  |
      | conn_0 | True     | drop database if exists da21 | success  |
    Then execute admin cmd "reload @@config_all -r"
    Then execute admin cmd "create database @@dataNode ='dn1,dn2'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
      | sql             |
      | show @@dataNode |
    Then check resultset "B" has lines with following column values
      | NAME-0 | DB_GROUP-1     | SCHEMA_EXISTS-2 | ACTIVE-3 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn1    | ha_group1/da11 | true            | 0        | 1000   | 0         | -1              |
      | dn2    | ha_group2/da11 | true            | 0        | 1000   | 1         | -1              |
      | dn3    | ha_group1/da21 | false           | 0        | 1000   | 0         | -1              |
      | dn4    | ha_group2/da21 | false           | 0        | 1000   | 0         | -1              |
      | dn5    | ha_group1/da31 | false           | 0        | 1000   | 1         | -1              |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'da11' | has{('da11',),} |
      | conn_0 | False    | show databases like 'da21' | length{(0)}     |
      | conn_0 | True     | show databases like 'da31' | length{(0)}     |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         | expect          |
      | conn_0 | False    | show databases like 'da11'  | has{('da11',),} |
      | conn_0 | True     | show databases like 'da21'  | length{(0)}     |
    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4,dn5'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B1"
      | sql                 |
      | show @@dataNode |
    Then check resultset "B1" has lines with following column values
      | NAME-0 | DB_GROUP-1     | SCHEMA_EXISTS-2 | ACTIVE-3 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn1    | ha_group1/da11 | true            | 0        | 1000   | 0         | -1              |
      | dn2    | ha_group2/da11 | true            | 0        | 1000   | 1         | -1              |
      | dn3    | ha_group1/da21 | true            | 0        | 1000   | 0         | -1              |
      | dn4    | ha_group2/da21 | true            | 0        | 1000   | 0         | -1              |
      | dn5    | ha_group1/da31 | true            | 0        | 1000   | 1         | -1              |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect           |
      | conn_0 | False    | show databases like 'da11' | has{('da11',),}  |
      | conn_0 | False    | show databases like 'da21' | has{('da21',),}  |
      | conn_0 | True     | show databases like 'da31' | has{('da31',),}  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         | expect           |
      | conn_0 | False    | show databases like 'da11'  | has{('da11',),}  |
      | conn_0 | True     | show databases like 'da21'  | has{('da21',),}  |
    Then execute admin cmd "drop database @@dataNode ='dn1,dn2'"
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect           |
      | conn_0 | False    | show databases like 'da11' | length{(0)}      |
      | conn_0 | False    | show databases like 'da21' | has{('da21',),}  |
      | conn_0 | True     | show databases like 'da31' | has{('da31',),}  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         | expect           |
      | conn_0 | False    | show databases like 'da11'  | length{(0)}      |
      | conn_0 | True     | show databases like 'da21'  | has{('da21',),}  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B2"
      | sql                 |
      | show @@dataNode |
    Then check resultset "B2" has lines with following column values
      | NAME-0 | DB_GROUP-1     | SCHEMA_EXISTS-2 | ACTIVE-3 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn1    | ha_group1/da11 | false           | 0        | 1000   | 0         | -1              |
      | dn2    | ha_group2/da11 | false           | 0        | 1000   | 1         | -1              |
      | dn3    | ha_group1/da21 | true            | 0        | 1000   | 0         | -1              |
      | dn4    | ha_group2/da21 | true            | 0        | 1000   | 0         | -1              |
      | dn5    | ha_group1/da31 | true            | 0        | 1000   | 1         | -1              |

    Then execute admin cmd "drop database @@dataNode ='dn1,dn2,dn3,dn4,dn5'"
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'da11' | length{(0)}     |
      | conn_0 | False    | show databases like 'da21' | length{(0)}     |
      | conn_0 | True     | show databases like 'da31' | length{(0)}     |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         | expect         |
      | conn_0 | False    | show databases like 'da11'  | length{(0)}    |
      | conn_0 | True     | show databases like 'da21'  | length{(0)}    |



  @NORMAL
  Scenario: "create database @@..." for datanode of style 'dn$x-y' #3
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
        <schema dataNode="dn5" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn10,dn11,dn20,dn21" name="test" rule="hash-four" />
        </schema>

        <dataNode dataHost="ha_group1" database="da0$0-1" name="dn1$0-1" />
        <dataNode dataHost="ha_group2" database="da0$0-1" name="dn2$0-1" />
        <dataNode dataHost="ha_group1" database="da31" name="dn5" />
     """
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                          | expect   |
      | conn_0 | False    | drop database if exists da00 | success  |
      | conn_0 | False    | drop database if exists da01 | success  |
      | conn_0 | True     | drop database if exists da31 | success  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                          | expect   |
      | conn_0 | False    | drop database if exists da00 | success  |
      | conn_0 | True     | drop database if exists da01 | success  |
    Then execute admin cmd "reload @@config_all -r" get the following output
    Then execute admin cmd "create database @@dataNode ='dn10,dn11,dn20,dn21'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
      | sql             |
      | show @@dataNode |
    #TODO EXECUTE的值待确认
    Then check resultset "C" has lines with following column values
      | NAME-0 | DB_GROUP-1     | SCHEMA_EXISTS-2 | ACTIVE-3 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn10   | ha_group1/da00 | true            | 0        | 1000   | 0         | -1              |
      | dn11   | ha_group1/da01 | true            | 0        | 1000   | 0         | -1              |
      | dn20   | ha_group2/da00 | true            | 0        | 1000   | 0         | -1              |
      | dn21   | ha_group2/da01 | true            | 0        | 1000   | 1         | -1              |
      | dn5    | ha_group1/da31 | false           | 0        | 1000   | 1         | -1              |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'da00' | has{('da00',),} |
      | conn_0 | False    | show databases like 'da01' | has{('da01',),} |
      | conn_0 | True     | show databases like 'da31' | length{(0)}     |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                           | expect          |
      | conn_0 | False    | show databases like 'da00'    | has{('da00',),} |
      | conn_0 | True     | show databases like 'da01'    | has{('da01',),} |
    Then execute admin cmd "drop database @@dataNode ='dn10,dn11,dn20,dn21'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
      | sql                 |
      | show @@dataNode |
    Then check resultset "C" has lines with following column values
      | NAME-0 | DB_GROUP-1     | SCHEMA_EXISTS-2  | ACTIVE-3 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn10   | ha_group1/da00 | false            | 0        | 1000   | 0         | -1              |
      | dn11   | ha_group1/da01 | false            | 0        | 1000   | 0         | -1              |
      | dn20   | ha_group2/da00 | false            | 0        | 1000   | 0         | -1              |
      | dn21   | ha_group2/da01 | false            | 0        | 1000   | 1         | -1              |
      | dn5    | ha_group1/da31 | false            | 0        | 1000   | 1         | -1              |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'da00' | length{(0)}     |
      | conn_0 | False    | show databases like 'da01' | length{(0)}     |
      | conn_0 | True     | show databases like 'da31' | length{(0)}     |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                           | expect        |
      | conn_0 | False    | show databases like 'da00'    | length{(0)}   |
      | conn_0 | True     | show databases like 'da01'    | length{(0)}   |
      
      
  @NORMAL  @restore_database
  Scenario: add new dataHost & "create database @@..." & "show @@datanode" when sharding  #4
    """
    {'restore_database':'dble-1'}
    """
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
    """
    <schema dataNode="dn6" name="schema2" sqlMaxLimit="100"/>

    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="db1" name="dn2" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    <dataNode dataHost="ha_group2" database="db2" name="dn4" />
    <dataNode dataHost="ha_group1" database="db3" name="dn5" />
    <dataNode dataHost="ha_group3" database="db4" name="dn6" />

    <dataHost balance="0" name="ha_group3" slaveThreshold="100" maxCon="1000" minCon="10">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM1" password="111111" url="172.100.9.4:3306" user="test">
      </writeHost>
    </dataHost>
    """
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                         | expect   |
      | conn_0 | False    | drop database if exists db1 | success  |
      | conn_0 | False    | drop database if exists db2 | success  |
      | conn_0 | True     | drop database if exists db3 | success  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         | expect   |
      | conn_0 | False    | drop database if exists db1 | success  |
      | conn_0 | True     | drop database if exists db2 | success  |
    Then execute sql in "mysql"
      | conn   | toClose  | sql                         | expect   |
      | conn_0 | False    | drop database if exists db4 | success  |
     Then execute admin cmd "reload @@config_all -r"
     Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4,dn5,dn6'"
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql                    |
      | show @@dataNode        |
     Then check resultset "A" has lines with following column values
       | NAME-0 | DB_GROUP-1        | SCHEMA_EXISTS-2 | ACTIVE-3 | SIZE-5 | RECOVERY_TIME-7 |
       | dn1    | ha_group1/db1     | true            | 0        | 1000   | -1              |
       | dn2    | ha_group2/db1     | true            | 0        | 1000   | -1              |
       | dn3    | ha_group1/db2     | true            | 0        | 1000   | -1              |
       | dn4    | ha_group2/db2     | true            | 0        | 1000   | -1              |
       | dn5    | ha_group1/db3     | true            | 0        | 1000   | -1              |
       | dn6    | ha_group3/db4     | true            | 0        | 1000   | -1              |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                       | expect          |
      | conn_0 | False    | show databases like 'db1' | has{('db1',),}  |
      | conn_0 | False    | show databases like 'db2' | has{('db2',),}  |
      | conn_0 | True     | show databases like 'db3' | has{('db3',),}  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'db1'  | has{('db1',),}  |
      | conn_0 | True     | show databases like 'db2'  | has{('db2',),}  |
    Then execute sql in "mysql"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | True     | show databases like 'db4'  | has{('db4',),}  |
    Given delete the following xml segment
       |file          | parent          | child                   |
       |schema.xml  |{'tag':'root'}   | {'tag':'schema'}        |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn5" name="schema1" sqlMaxLimit="100">
      <table name="test" dataNode="dn1,dn2,dn3,dn4" type="global" />
      <table name="sharding_2_t1" dataNode="dn1,dn2" rule="hash-two" />
      <table name="sharding_4_t1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
    </schema>
    """
    Then execute admin cmd "reload @@config_all -r"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
      | sql                    |
      | show @@dataNode        |
     Then check resultset "B" has lines with following column values
       | NAME-0 | DB_GROUP-1        | SCHEMA_EXISTS-2 | ACTIVE-3 |SIZE-5 | RECOVERY_TIME-7 |
       | dn1    | ha_group1/db1     | true            | 0        |1000   | -1              |
       | dn2    | ha_group2/db1     | true            | 0        |1000   | -1              |
       | dn3    | ha_group1/db2     | true            | 0        |1000   | -1              |
       | dn4    | ha_group2/db2     | true            | 0        |1000   | -1              |
       | dn5    | ha_group1/db3     | true            | 0        |1000   | -1              |
     #CASE show @@shardingNodes where schema=? and table=?;
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
      | sql                                                             |
      | show @@dataNodes where schema = schema1 and table = test        |
     Then check resultset "C" has lines with following column values
       | NAME-0 | SEQUENCE-1 | HOST-2        | PORT-3 | PHYSICAL_SCHEMA-4 | USER-5 | PASSWORD-6 |
       | dn1    | 0          | 172.100.9.5   | 3306   | db1               | test   | 111111     |
       | dn2    | 1          | 172.100.9.6   | 3306   | db1               | test   | 111111     |
       | dn3    | 2          | 172.100.9.5   | 3306   | db2               | test   | 111111     |
       | dn4    | 3          | 172.100.9.6   | 3306   | db2               | test   | 111111     |
     #CASE show @@dataNode where schema=?
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "D"
       | conn   | toClose  | sql                                           |
       | conn_0 | False    | show @@dataNode  where schema = schema1       |
     Then check resultset "D" has lines with following column values
       | NAME-0 | DB_GROUP-1      | SCHEMA_EXISTS-2 |ACTIVE-3 | SIZE-5 | RECOVERY_TIME-7 |
       | dn1  | ha_group1/db1     | true            |      0  | 1000   |            -1   |
       | dn2  | ha_group2/db1     | true            |      0  | 1000   |            -1   |
       | dn3  | ha_group1/db2     | true            |      0  | 1000   |            -1   |
       | dn4  | ha_group2/db2     | true            |      0  | 1000   |            -1   |
       | dn5  | ha_group1/db3     | true            |      0  | 1000   |            -1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                      | expect                        | timeout |
      | conn_0 | False    | drop database @@dataNode ='dn1,dn2,dn3,dn4,dn5,dn6'      | DataNode dn6 does not exists  |         |
      | conn_0 | true     | drop database @@dataNode ='dn1,dn2,dn3,dn4,dn5'          | success                       | 5       |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "E"
      | sql             |
      | show @@dataNode |
    Then check resultset "E" has lines with following column values
      | NAME-0 | DB_GROUP-1     | SCHEMA_EXISTS-2  | ACTIVE-3 | SIZE-5 | RECOVERY_TIME-7 |
      | dn1    | ha_group1/db1  | false            | 0        | 1000   | -1              |
      | dn2    | ha_group2/db1  | false            | 0        | 1000   | -1              |
      | dn3    | ha_group1/db2  | false            | 0        | 1000   | -1              |
      | dn4    | ha_group2/db2  | false            | 0        | 1000   | -1              |
      | dn5    | ha_group1/db3  | false            | 0        | 1000   | -1              |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'db1'  | length{(0)}     |
      | conn_0 | False    | show databases like 'db2'  | length{(0)}     |
      | conn_0 | True     | show databases like 'db3'  | length{(0)}     |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                           | expect        |
      | conn_0 | False    | show databases like 'db1'     | length{(0)}   |
      | conn_0 | True     | show databases like 'db2'     | length{(0)}   |
    Then execute sql in "mysql"
      | conn   | toClose  | sql                           | expect           |
      | conn_0 | true     | show databases like 'db4'     | has{('db4',),}   |
    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4,dn5'"
