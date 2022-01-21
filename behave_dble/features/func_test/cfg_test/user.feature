# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: test config in user.xml

  @TRIVIAL
  Scenario: add client user with illegal label, reload fail #1
     #1.1  client user with illegal label got error
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test_user" password="test_password" schemas="schema1" test="0"/>
    """

    Then execute admin cmd "reload @@config_all"
    """
    Attribute 'test' is not allowed to appear in element 'shardingUser'
    """

  @TRIVIAL
  Scenario: add client user with schema which does not exist, start dble fail #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test_user3" password="test_password" schemas="testdb" readOnly="false"/>
    """

    Then Restart dble in "dble-1" failed for
     """
     User\[name:test_user3\]'s schema \[testdb\] is not exist!
     """

  @BLOCKER
  Scenario: add client user with usingDecrypt=1, start/reload success, query success #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test_user" password="test_password" schemas="schema1" readOnly="false" usingDecrypt="1"/>
    """

    Given Restart dble in "dble-1" success
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | sql      |
      | select 1 |

  @TRIVIAL
  Scenario: both single & multiple manager user reload and do management cmd success #4
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "show @@version"
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser  name="test_user" password="test_password" readOnly="false"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "show @@version" with user "test_user" passwd "test_password"

  @CRITICAL
  Scenario:config ip white dbInstance to both management and client user, client user not in white dbInstance access denied #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test_user" password="111111" schemas="schema1" readOnly="false" whiteIPs="172.100.9.253"/>
    <shardingUser  name="mng_user" password="111111" schemas="schema1" readOnly="false" whiteIPs="172.100.9.8"/>
    <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" whiteIPs="172.100.9.253,172.100.9.8"/>
    <managerUser  name="root" password="111111" readOnly="false" whiteIPs="172.100.9.253,172.100.9.8"/>
    """

    Given Restart dble in "dble-1" success
    Then execute admin cmd "show @@version" with user "root" passwd "111111"
    Then execute sql in "dble-1" in "admin" mode
        | user       | passwd | sql            | expect                            |
        | mng_user   | 111111 | show @@version |Access denied for user 'mng_user'  |
    Then execute sql in "dble-1" in "user" mode
        | user        | passwd | conn   | toClose | sql      | expect  | db      |
        | test        | 111111 | conn_0 | True    | select 1 |success  | schema1 |
        | test_user   | 111111 | conn_0 | True    | select 1 |Access denied for user 'test_user' | schema1 |


  @CRITICAL
  Scenario: config sql blacklist #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
       <managerUser name="root" password="111111"/>
       <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1"/>
       <blacklist name="blacklist1">
            <property name="conditionDoubleConstAllow">false</property>
            <property name="conditionAndAlwayFalseAllow">false</property>
             <property name="conditionAndAlwayTrueAllow">false</property>
             <property name="constArithmeticAllow">false</property>
             <property name="alterTableAllow">false</property>
             <property name="commitAllow">false</property>
             <property name="deleteAllow">false</property>
             <property name="dropTableAllow">false</property>
             <property name="insertAllow">false</property>
             <property name="intersectAllow">false</property>
             <property name="lockTableAllow">false</property>
             <property name="minusAllow">false</property>
             <property name="callAllow">false</property>
             <property name="replaceAllow">false</property>
             <property name="setAllow">false</property>
             <property name="describeAllow">false</property>
             <property name="limitZeroAllow">false</property>
             <property name="conditionOpXorAllow">false</property>
             <property name="conditionOpBitwseAllow">false</property>
             <property name="startTransactionAllow">false</property>
             <property name="truncateAllow">false</property>
             <property name="updateAllow">false</property>
             <property name="useAllow">false</property>
             <property name="blockAllow">false</property>
             <property name="deleteWhereNoneCheck">false</property>
             <property name="updateWhereNoneCheck">false</property>
       </blacklist>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect             | db      |
      | conn_0 | False   | create table if not exists test_table_1(id int)     |success             | schema1 |
      | conn_0 | False   | create table if not exists test_table_12(id int)    |success             | schema1 |
      | conn_0 | False   | select * from test_table_1 where 1 = 1 and 2 = 1;   |error totally whack | schema1 |
      | conn_0 | False   | select * from test_table_1 where id = 567 and 1!= 1 |error totally whack | schema1 |
      | conn_0 | False   | select * from test_table_1 where id = 567 and 1 = 1 |error totally whack | schema1 |
      | conn_0 | False   | select * from test_table_1 where id = 2-1           |error totally whack | schema1 |
      | conn_0 | False   | alter table test_table_1 add name varchar(20)       |error totally whack | schema1 |
      | conn_0 | False   | commit                                              |error totally whack | schema1 |
      | conn_0 | False   | delete from test_table_1 where id =1                |error totally whack | schema1 |
      | conn_0 | False   | drop table test_table_1                             |error totally whack | schema1 |
      | conn_0 | False   | insert test_table_1 values(1)                       |error totally whack | schema1 |
      | conn_0 | False   | intersect                                           |error totally whack | schema1 |
      | conn_0 | False   | lock tables test_table_1 read                       |error totally whack | schema1 |
      | conn_0 | False   | minus                                               |error totally whack | schema1 |
      | conn_0 | False   | call test_table_1                                   |error totally whack | schema1 |
      | conn_0 | False   | replace into test_table_1(id)values (2)             |error totally whack | schema1 |
      | conn_0 | False   | set xa =1                                           |error totally whack | schema1 |
      | conn_0 | False   | describe test_table_1                               |error totally whack | schema1 |
      | conn_0 | False   | select * from test_table_1 limit 0                  |error totally whack | schema1 |
      | conn_0 | False   | select * from test_table_1 where id = 1^1           |error totally whack | schema1 |
      | conn_0 | False   | select * from test_table_1 where id = 1&1           |error totally whack | schema1 |
      | conn_0 | False   | start transation                                    |error totally whack | schema1 |
      | conn_0 | False   | truncate table test_table_1                         |error totally whack | schema1 |
      | conn_0 | False   | update test_table_1 set id =10 where id =1          |error totally whack | schema1 |
      | conn_0 | False   | use schema1                                         |error totally whack | schema1 |
      | conn_0 | False   | BEGIN select * from suntest;END;                    |error totally whack | schema1 |
      | conn_0 | False   | delete from test_table_1                            |error totally whack | schema1 |
      | conn_0 | False   | update test_table_1 set id =10                      |error totally whack | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
        <blacklist name="blacklist1">
                <property name="selelctAllow">false</property>
                <property name="createTableAllow">false</property>
                <property name="showAllow">false</property>
        </blacklist>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | expect  | db     |
      | conn_0 | False   | create table if not exists test_table_1(id int);   |success | schema1 |
      | conn_0 | False   | select * from test_table_1 where 1 = 1 and 2 = 1; |error totally whack | schema1 |
      | conn_0 | False   | show tables                                       |success | schema1 |
      | new | False   | create table if not exists test_table_1(id int);   |error totally whack | schema1 |
      | new| False   | show tables                                       |error totally whack | schema1 |

  @CRITICAL
  Scenario: config "user" attr "maxCon" (front-end maxCon) greater than 0 #7
   Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111" maxCon="2"/>
    <shardingUser name="test" password="111111" schemas="schema1" maxCon="1"/>
    <shardingUser name="action" password="action" schemas="schema1" readOnly="true" maxCon="1"/>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose  | sql      | expect  | db     |
        | test         | 111111    | conn_0 | False    | select 1 | success | schema1 |
        | test         | 111111    | new    | True     | select 1 | too many connections for this user | schema1 |
        | test         | 111111    | new    | True     | select 1 | test | schema1 |
        | action       | action    | conn_1 | False    | select 1 | success | schema1 |
        | action       | action    | new    | True     | select 1 | too many connections for this user | schema1 |
        | action       | action    | new    | True     | select 1 | action | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql            | expect  |
      | conn_2 | False   | show @@version | success |
      | conn_3 | False   | show @@version | success |
      | new    | False   | show @@version | too many connections for this user |
      | new    | False   | show @@version | root |

  @NORMAL
  Scenario: config "user" attr "maxCon" (front-end maxCon) 0 means using no checking, without "system" property "maxCon" configed #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"  readOnly="false"/>
    <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" maxCon="0"/>
    <shardingUser name="action" password="action" schemas="schema1" readOnly="true" maxCon="0"/>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user   | passwd    | conn   | toClose | sql      | expect  | db      |
        | test   | 111111    | conn_4 | False   | select 1 | success | schema1 |
        | test   | 111111    | conn_5 | False   | select 1 | success | schema1 |
        | action | action    | conn_6 | False   | select 1 | success | schema1 |
        | action | action    | conn_7 | False   | select 1 | success | schema1 |

  @CRITICAL
  Scenario: config sum(all "user" attr "maxCon") > "system" property "maxCon", exceeding connection will fail #9
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      $a\-DmaxCon=1
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"  readOnly="false"/>
    <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" maxCon="1"/>
    <shardingUser name="action" password="action" schemas="schema1" readOnly="true" maxCon="1"/>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user   | passwd    | conn   | toClose | sql      | expect  | db     |
        | test   | 111111    | conn_0 | False   | select 1 | success | schema1 |
        | test   | 111111    | new    | False   | select 1 | too many connections for this user | schema1 |
        | action | action    | conn_1 | False   | select 1 | too many connections for dble server | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | sql            |
      | show @@version |

  Scenario: test tableStructureCheckTask from issue:1098 #10
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      $a\-DcheckTableConsistency=1
      $a\-DcheckTableConsistencyPeriod=1000
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="test_table" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                           | expect  |db       |
      | conn_0  | False   | drop table if exists test_table               | success | schema1 |
      | conn_0  | True    | create table test_table(id int,name char(20)) | success | schema1 |
    Then execute sql in "mysql-master1"
      | sql                              | expect  |db   |
      | alter table test_table drop name | success | db1 |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    structure are not consistent in different shardingNode
    are modified by other,Please Check IT
    """
    Then execute sql in "dble-1" in "user" mode
      | sql                             | expect          |db       |
      | drop table if exists test_table | success         | schema1 |

  Scenario: test 'sqlExecuteTimeout' from issue:1286 #11
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DfakeMySQLVersion=5.7.13
    $a -DprocessorCheckPeriod=10
    $a -DsqlExecuteTimeout=60
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
            <property name="timeBetweenEvictionRunsMillis">10</property>
    </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
            <property name="timeBetweenEvictionRunsMillis">10</property>
        </dbInstance>
    </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                           | expect                 |db       |
      | conn_0  | False    | drop table if exists test_table               | success                | schema1 |
      | conn_0  | False    | create table test_table(id int,name char(20)) | success                | schema1 |
      | conn_0  | False    | insert into test_table values(1,11),(2,22)    | success                | schema1 |
      | conn_0  | False    | select sleep(3)                               | success                | schema1 |
      | conn_0  | False    | select sleep(30)                              | success                | schema1 |
      | conn_0  | False    | select sleep(50)                              | success                | schema1 |
      | conn_0  | False    | select sleep(60),id from test_table           | reason is [sql timeout]| schema1 |
      | conn_0  | False    | select sleep(61)                              | reason is [sql timeout]| schema1 |
      | conn_0  | True     | select sleep(70),id from test_table           | reason is [sql timeout]| schema1 |

  @NORMAL
  Scenario: test rwSplitUsers in user.xml #12
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    #1 more than one rwSplitUsers can use the same dbGroup
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" maxCon="0"/>
    <rwSplitUser name="rwS2" password="111111" dbGroup="ha_group3" maxCon="0"/>
    <rwSplitUser name="rwS3" password="111111" dbGroup="ha_group3" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
    |user |passwd | conn    | toClose  | sql                                               | expect                 |db  |
    | rwS1|111111| conn_0  | False    | drop table if exists test_table                 | success                | db1|
    | rwS1|111111| conn_0  | False    | create table test_table(id int,name char(20)) | success                | db1 |
    | rwS1|111111| conn_0  | False    | insert into test_table values(1,11),(2,22)    | success                | db1 |
    | rwS1|111111| conn_0  | True     | select * from test_table                         | length{2}                | db1 |
    | rwS2|111111| conn_1  | False    | delete from test_table where id=1               | success                | db1 |
    | rwS2|111111| conn_1  | True     | select * from test_table                         | length{1}                | db1 |
    | rwS3|111111| conn_2  | False    | select * from test_table                         | length{1}               | db1 |
    | rwS3|111111| conn_2  | False    | insert into test_table values(1,11),(3,33)     | success                | db1 |
    | rwS3|111111| conn_2  | False    | select * from test_table                         | length{3}                | db1 |
    | rwS3|111111| conn_2  | True     | drop table if exists test_table                 | success                 | db1 |
    #2 rwSplitUser and shardingUser not allow use the same dbGroup
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group1" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config" get the following output
    """
    The group[rwS1.ha_group1] has been used by sharding node, can't be used by rwSplit
    """

