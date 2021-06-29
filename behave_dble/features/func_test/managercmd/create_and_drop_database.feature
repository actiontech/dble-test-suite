# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/12/7
# Created by quexiuping at 2020/9/23

Feature: test "create databsae @@shardingnode='dn1,dn2,...' and drop databsae @@shardingnode='dn1,dn2,...'"

  @NORMAL
  Scenario: "create/drop database @@..." for all used shardingnode #1
     Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
     """
        <shardingNode dbGroup="ha_group1" database="da1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="da1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="da2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="da2" name="dn4" />
        <shardingNode dbGroup="ha_group1" database="da3" name="dn5" />
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
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "create database @@shardingNode ='dn1,dn2,dn3,dn4,dn5'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql                 |
      | show @@shardingnode |
    Then check resultset "A" has lines with following column values
      | NAME-0 | DB_GROUP-1    | SCHEMA_EXISTS-2 | ACTIVE-3 | IDLE-4 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn1    | ha_group1/da1 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn2    | ha_group2/da1 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn3    | ha_group1/da2 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn4    | ha_group2/da2 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn5    | ha_group1/da3 | true            | 0        | 0      | 1000   | 0         | -1              |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                       | expect          |
      | conn_0 | False    | show databases like 'da1' | has{('da1',),}  |
      | conn_0 | False    | show databases like 'da2' | has{('da2',),}  |
      | conn_0 | True     | show databases like 'da3' | has{('da3',),}  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'da1'  | has{('da1',),}  |
      | conn_0 | True     | show databases like 'da2'  | has{('da2',),}  |
    Then execute admin cmd "drop database @@shardingNode ='dn1,dn2,dn3,dn4,dn5'"
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
      | sql                 |
      | show @@shardingnode |
    Then check resultset "A1" has lines with following column values
      | NAME-0 | DB_GROUP-1    | SCHEMA_EXISTS-2  | ACTIVE-3 | IDLE-4 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn1    | ha_group1/da1 | false            | 0        | 0      | 1000   | 0         | -1              |
      | dn2    | ha_group2/da1 | false            | 0        | 0      | 1000   | 0         | -1              |
      | dn3    | ha_group1/da2 | false            | 0        | 0      | 1000   | 0         | -1              |
      | dn4    | ha_group2/da2 | false            | 0        | 0      | 1000   | 0         | -1              |
      | dn5    | ha_group1/da3 | false            | 0        | 0      | 1000   | 0         | -1              |
    Then execute admin cmd "create database @@shardingNode ='dn1,dn2,dn3,dn4,dn5'"
    Then execute admin cmd "drop database @@shardingNode ='dn1,dn2,dn3,dn4,dn5'"



  @NORMAL
  Scenario: "create database @@..." for part of used shardingNode #2
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
    """
        <shardingNode dbGroup="ha_group1" database="da11" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="da11" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="da21" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="da21" name="dn4" />
        <shardingNode dbGroup="ha_group1" database="da31" name="dn5" />
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
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "create database @@shardingNode ='dn1,dn2'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
      | sql                 |
      | show @@shardingnode |
    Then check resultset "B" has lines with following column values
      | NAME-0 | DB_GROUP-1     | SCHEMA_EXISTS-2 | ACTIVE-3 | IDLE-4 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn1    | ha_group1/da11 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn2    | ha_group2/da11 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn3    | ha_group1/da21 | false           | 0        | 0      | 1000   | 0         | -1              |
      | dn4    | ha_group2/da21 | false           | 0        | 0      | 1000   | 0         | -1              |
      | dn5    | ha_group1/da31 | false           | 0        | 0      | 1000   | 0         | -1              |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'da11' | has{('da11',),} |
      | conn_0 | False    | show databases like 'da21' | length{(0)}     |
      | conn_0 | True     | show databases like 'da31' | length{(0)}     |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         | expect          |
      | conn_0 | False    | show databases like 'da11'  | has{('da11',),} |
      | conn_0 | True     | show databases like 'da21'  | length{(0)}     |
    Then execute admin cmd "create database @@shardingNode ='dn1,dn2,dn3,dn4,dn5'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B1"
      | sql                 |
      | show @@shardingnode |
    Then check resultset "B1" has lines with following column values
      | NAME-0 | DB_GROUP-1     | SCHEMA_EXISTS-2 | ACTIVE-3 | IDLE-4 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn1    | ha_group1/da11 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn2    | ha_group2/da11 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn3    | ha_group1/da21 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn4    | ha_group2/da21 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn5    | ha_group1/da31 | true            | 0        | 0      | 1000   | 0         | -1              |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect           |
      | conn_0 | False    | show databases like 'da11' | has{('da11',),}  |
      | conn_0 | False    | show databases like 'da21' | has{('da21',),}  |
      | conn_0 | True     | show databases like 'da31' | has{('da31',),}  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         | expect           |
      | conn_0 | False    | show databases like 'da11'  | has{('da11',),}  |
      | conn_0 | True     | show databases like 'da21'  | has{('da21',),}  |
    Then execute admin cmd "drop database @@shardingNode ='dn1,dn2'"
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
      | show @@shardingnode |
    Then check resultset "B2" has lines with following column values
      | NAME-0 | DB_GROUP-1     | SCHEMA_EXISTS-2 | ACTIVE-3 | IDLE-4 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn1    | ha_group1/da11 | false           | 0        | 0      | 1000   | 0         | -1              |
      | dn2    | ha_group2/da11 | false           | 0        | 0      | 1000   | 0         | -1              |
      | dn3    | ha_group1/da21 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn4    | ha_group2/da21 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn5    | ha_group1/da31 | true            | 0        | 0      | 1000   | 0         | -1              |

    Then execute admin cmd "drop database @@shardingNode ='dn1,dn2,dn3,dn4,dn5'"
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
  Scenario: "create database @@..." for shardingNode of style 'dn$x-y' #3
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
            <shardingTable shardingNode="dn10,dn11,dn20,dn21" name="test" function="hash-four" shardingColumn="id"/>
        </schema>

         <shardingNode dbGroup="ha_group1" database="da0$0-1" name="dn1$0-1" />
        <shardingNode dbGroup="ha_group2" database="da0$0-1" name="dn2$0-1" />
        <shardingNode dbGroup="ha_group1" database="da31" name="dn5" />
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
    Then execute admin cmd "reload @@config_all" get the following output
    Then execute admin cmd "create database @@shardingNode ='dn10,dn11,dn20,dn21'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
      | sql                 |
      | show @@shardingnode |
    Then check resultset "C" has lines with following column values
      | NAME-0 | DB_GROUP-1     | SCHEMA_EXISTS-2 | ACTIVE-3 | IDLE-4 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn10   | ha_group1/da00 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn11   | ha_group1/da01 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn20   | ha_group2/da00 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn21   | ha_group2/da01 | true            | 0        | 0      | 1000   | 0         | -1              |
      | dn5    | ha_group1/da31 | false           | 0        | 0      | 1000   | 0         | -1              |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'da00' | has{('da00',),} |
      | conn_0 | False    | show databases like 'da01' | has{('da01',),} |
      | conn_0 | True     | show databases like 'da31' | length{(0)}     |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                           | expect          |
      | conn_0 | False    | show databases like 'da00'    | has{('da00',),} |
      | conn_0 | True     | show databases like 'da01'    | has{('da01',),} |
    Then execute admin cmd "drop database @@shardingNode ='dn10,dn11,dn20,dn21'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
      | sql                 |
      | show @@shardingnode |
    Then check resultset "C" has lines with following column values
      | NAME-0 | DB_GROUP-1     | SCHEMA_EXISTS-2  | ACTIVE-3 | IDLE-4 | SIZE-5 | EXECUTE-6 | RECOVERY_TIME-7 |
      | dn10   | ha_group1/da00 | false            | 0        | 0      | 1000   | 0         | -1              |
      | dn11   | ha_group1/da01 | false            | 0        | 0      | 1000   | 0         | -1              |
      | dn20   | ha_group2/da00 | false            | 0        | 0      | 1000   | 0         | -1              |
      | dn21   | ha_group2/da01 | false            | 0        | 0      | 1000   | 0         | -1              |
      | dn5    | ha_group1/da31 | false            | 0        | 0      | 1000   | 0         | -1              |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'da00' | length{(0)}     |
      | conn_0 | False    | show databases like 'da01' | length{(0)}     |
      | conn_0 | True     | show databases like 'da31' | length{(0)}     |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                           | expect        |
      | conn_0 | False    | show databases like 'da00'    | length{(0)}   |
      | conn_0 | True     | show databases like 'da01'    | length{(0)}   |