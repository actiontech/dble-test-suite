# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/6/22

Feature: test user.xml blacklist



  Scenario: test user.xml blacklist  -- DML on DMP SQL firewall #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
        <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
          <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
        </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1"/>
       <rwSplitUser name="rwSp1" password="111111" dbGroup="ha_group3" blacklist="blacklist1"/>
       <blacklist name="blacklist1">
            <property name="insertAllow">false</property>
            <property name="deleteAllow">false</property>
            <property name="replaceAllow">false</property>
            <property name="updateAllow">false</property>
            <property name="selelctAllow">false</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
      | user   | passwd   | conn   | toClose | sql                                         | expect      | db      |
      | test1  | 111111   | conn_0 | False   | drop table if exists test                   | success     | schema1 |
      | test1  | 111111   | conn_0 | False   | create table test(id int)                   | success     | schema1 |
      | test1  | 111111   | conn_0 | False   | insert into test values (1)                 | Intercepted by suspected configuration [insertAllow] in the blacklist of user 'test1', so it is considered unsafe SQL             | schema1 |
      | test1  | 111111   | conn_0 | False   | delete from test                            | Intercepted by suspected configuration [deleteAllow] in the blacklist of user 'test1', so it is considered unsafe SQL             | schema1 |
      | test1  | 111111   | conn_0 | False   | replace into test(id) values (2)            | Intercepted by suspected configuration [replaceAllow] in the blacklist of user 'test1', so it is considered unsafe SQL            | schema1 |
      | test1  | 111111   | conn_0 | False   | update test set id=2 where id=1             | Intercepted by suspected configuration [updateAllow] in the blacklist of user 'test1', so it is considered unsafe SQL             | schema1 |
      | test1  | 111111   | conn_0 | true    | select * from test where id=1               | Intercepted by suspected configuration [selelctAllow,selectAllColumnAllow] in the blacklist of user 'test1', so it is considered unsafe SQL            | schema1 |

#    Then execute sql in "dble-1" in "user" mode
#      | user   | passwd   | conn   | toClose | sql                                         | expect      | db  |
#      | rwSp1  | 111111   | conn_2 | False   | drop table if exists test                   | success     | db1 |
#      | rwSp1  | 111111   | conn_2 | False   | create table test(id int)                   | success     | db1 |
#      | rwSp1  | 111111   | conn_2 | False   | insert into test values (1)                 | Intercepted by suspected configuration [insertAllow] in the blacklist of user 'rwSp1', so it is considered unsafe SQL             | db1 |
#      | rwSp1  | 111111   | conn_2 | False   | delete from test                            | Intercepted by suspected configuration [deleteAllow] in the blacklist of user 'rwSp1', so it is considered unsafe SQL             | db1 |
#      | rwSp1  | 111111   | conn_2 | False   | replace into test(id) values (2)            | Intercepted by suspected configuration [replaceAllow] in the blacklist of user 'rwSp1', so it is considered unsafe SQL            | db1 |
#      | rwSp1  | 111111   | conn_2 | False   | update test set id=2 where id=1             | Intercepted by suspected configuration [updateAllow] in the blacklist of user 'rwSp1', so it is considered unsafe SQL             | db1 |
#      | rwSp1  | 111111   | conn_2 | true    | select * from test where id=1               | Intercepted by suspected configuration [selelctAllow,selectAllColumnAllow] in the blacklist of user 'rwSp1', so it is considered unsafe SQL            | db1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist2"/>
       <blacklist name="blacklist2">
            <property name="insertAllow">true</property>
            <property name="deleteAllow">true</property>
            <property name="replaceAllow">true</property>
            <property name="updateAllow">true</property>
            <property name="selelctAllow">true</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                         | expect      | db      |
      | conn_1 | False   | drop table if exists test                   | success     | schema1 |
      | conn_1 | False   | create table test(id int)                   | success     | schema1 |
      | conn_1 | False   | insert into test values (1)                 | success     | schema1 |
      | conn_1 | False   | delete from test                            | success     | schema1 |
      | conn_1 | False   | replace into test(id) values (2)            | success     | schema1 |
      | conn_1 | False   | update test set id=2 where id=1             | success     | schema1 |
      | conn_1 | False   | select * from test where id=1               | success     | schema1 |
      | conn_1 | true    | drop table if exists test                   | success     | schema1 |


  Scenario: test user.xml blacklist  -- DDL on DMP SQL firewall #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1"/>
       <blacklist name="blacklist1">
            <property name="dropTableAllow">false</property>
            <property name="alterTableAllow">false</property>
            <property name="renameTableAllow">false</property>
            <property name="createTableAllow">false</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd   | conn   | toClose | sql                                         | expect                                                                                                                      | db      |
      | test1  | 111111   | conn_0 | False   | drop table if exists test                   | Intercepted by suspected configuration [dropTableAllow] in the blacklist of user 'test1', so it is considered unsafe SQL    | schema1 |
      | test1  | 111111   | conn_0 | False   | create table test(id int)                   | Intercepted by suspected configuration [createTableAllow] in the blacklist of user 'test1', so it is considered unsafe SQL  | schema1 |
      | test1  | 111111   | conn_0 | False   | alter table test add id2 int                | Intercepted by suspected configuration [alterTableAllow] in the blacklist of user 'test1', so it is considered unsafe SQL   | schema1 |
      | test1  | 111111   | conn_0 | true    | rename table test to test1                  | Intercepted by suspected configuration [renameTableAllow] in the blacklist of user 'test1', so it is considered unsafe SQL  | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist2"/>
       <blacklist name="blacklist2">
            <property name="dropTableAllow">true</property>
            <property name="alterTableAllow">true</property>
            <property name="renameTableAllow">true</property>
            <property name="createTableAllow">true</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                         | expect                    | db      |
      | conn_1 | False   | drop table if exists test                   | success                   | schema1 |
      | conn_1 | False   | create table test(id int)                   | success                   | schema1 |
      | conn_1 | False   | alter table test add id2 int                | success                   | schema1 |
      | conn_1 | False   | rename table test to test1                  | Unsupported statement     | schema1 |
      | conn_1 | true    | drop table if exists test1                  | success                   | schema1 |


  Scenario: test user.xml blacklist  -- DAL on DMP SQL firewall #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1"/>
       <blacklist name="blacklist1">
            <property name="setAllow">false</property>
            <property name="showAllow">false</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd   | conn   | toClose | sql                     | expect                                                                                                                | db      |
      | test1  | 111111   | conn_0 | False   | show tables             | Intercepted by suspected configuration [showAllow] in the blacklist of user 'test1', so it is considered unsafe SQL   | schema1 |
      | test1  | 111111   | conn_0 | true    | set @@autocommit = 0    | Intercepted by suspected configuration [setAllow] in the blacklist of user 'test1', so it is considered unsafe SQL    | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist2"/>
       <blacklist name="blacklist2">
            <property name="setAllow">true</property>
            <property name="showAllow">true</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                     | expect     | db      |
      | conn_1 | False   | show tables             | success    | schema1 |
      | conn_1 | true    | set @@autocommit = 0    | success    | schema1 |


  Scenario: test user.xml blacklist  -- Transaction and lock on DMP SQL firewall #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1"/>
       <blacklist name="blacklist1">
            <property name="rollbackAllow">false</property>
            <property name="commitAllow">false</property>
            <property name="startTransactionAllow">false</property>
            <property name="lockTableAllow">false</property>
            <property name="truncateAllow">false</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd   | conn   | toClose | sql                              | expect     | db      |
      | test1  | 111111   | conn_0 | False   | drop table if exists test        | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | create table test(id int)        | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | truncate table test              | Intercepted by suspected configuration [truncateAllow] in the blacklist of user 'test1', so it is considered unsafe SQL          | schema1 |
      | test1  | 111111   | conn_0 | False   | begin                            | Intercepted by suspected configuration [startTransactionAllow] in the blacklist of user 'test1', so it is considered unsafe SQL  | schema1 |
      | test1  | 111111   | conn_0 | False   | start transaction                | Intercepted by suspected configuration [startTransactionAllow] in the blacklist of user 'test1', so it is considered unsafe SQL  | schema1 |
      | test1  | 111111   | conn_0 | False   | commit                           | Intercepted by suspected configuration [commitAllow] in the blacklist of user 'test1', so it is considered unsafe SQL            | schema1 |
      | test1  | 111111   | conn_0 | False   | rollback                         | Intercepted by suspected configuration [rollbackAllow] in the blacklist of user 'test1', so it is considered unsafe SQL          | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist2"/>
       <blacklist name="blacklist2">
            <property name="rollbackAllow">true</property>
            <property name="commitAllow">true</property>
            <property name="startTransactionAllow">true</property>
            <property name="lockTableAllow">true</property>
            <property name="truncateAllow">true</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                       | expect  | db      |
      | conn_1 | False   | drop table if exists test | success | schema1 |
      | conn_1 | False   | create table test(id int) | success | schema1 |
      | conn_1 | False   | truncate table test       | success | schema1 |
      | conn_1 | False   | begin                     | success | schema1 |
      | conn_1 | False   | rollback                  | success | schema1 |
      | conn_1 | False   | start transaction         | success | schema1 |
      | conn_1 | true    | commit                    | success | schema1 |


  Scenario: test user.xml blacklist  -- Functions and operators and SQL injection on DMP SQL firewall #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1"/>
       <blacklist name="blacklist1">
            <property name="blockAllow">false</property>
            <property name="intersectAllow">false</property>
            <property name="callAllow">false</property>
            <property name="minusAllow">false</property>
            <property name="commentAllow">false</property>
            <property name="hintAllow">false</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd   | conn   | toClose | sql                                 | expect     | db      |
      | test1  | 111111   | conn_0 | False   | drop table if exists test2          | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | drop table if exists test           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | create table test(id int)           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | insert into test values (1)         | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | drop table if exists test1          | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | create table test1(id int)          | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | insert into test1 values (1)        | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | (select id from test) intersect (select id from test1)        | Intercepted by suspected configuration [intersectAllow] in the blacklist of user 'test1', so it is considered unsafe SQL  | schema1 |
      | test1  | 111111   | conn_0 | False   | select id from test minus select id from test1                | Intercepted by suspected configuration [intersectAllow] in the blacklist of user 'test1', so it is considered unsafe SQL  | schema1 |
#      | test1  | 111111   | conn_0 | False   | create table test2(id int not null default 0 comment 'aa')   | Intercepted by suspected configuration [commentAllow] in the blacklist of user 'test1', so it is considered unsafe SQL    | schema1 |
#      | test1  | 111111   | conn_0 | true    | insert DELAYED INTO test2 set id =2                          | Intercepted by suspected configuration [commentAllow] in the blacklist of user 'test1', so it is considered unsafe SQL    | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist2"/>
       <blacklist name="blacklist2">
            <property name="blockAllow">true</property>
            <property name="intersectAllow">true</property>
            <property name="callAllow">true</property>
            <property name="minusAllow">true</property>
            <property name="commentAllow">true</property>
            <property name="hintAllow">true</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect  | db      |
      | conn_1 | False   | drop table if exists test2       | success | schema1 |
      | conn_1 | False   | drop table if exists test        | success | schema1 |
      | conn_1 | False   | create table test(id int)        | success | schema1 |
      | conn_1 | False   | insert into test values (1)      | success | schema1 |
      | conn_1 | False   | drop table if exists test1       | success | schema1 |
      | conn_1 | False   | create table test1(id int)       | success | schema1 |
      | conn_1 | False   | insert into test1 values (1)     | success | schema1 |
      | conn_1 | False   | (select id from test) intersect (select id from test1)     | You have an error in your SQL syntax;INTERSECT | schema1 |
      | conn_1 | False   | select id from test minus select id from test1             | You have an error in your SQL syntax;MINUS     | schema1 |
      | conn_1 | False   | create table test2(id int not null default 0 comment 'aa') | success     | schema1 |
      | conn_1 | False   | insert DELAYED INTO test2 set id =2                        | success     | schema1 |
      | conn_1 | False   | drop table if exists test        | success | schema1 |
      | conn_1 | False   | drop table if exists test1       | success | schema1 |
      | conn_1 | true    | drop table if exists test2       | success | schema1 |


  Scenario: test user.xml blacklist  -- Misoperation on DMP SQL firewall  #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1"/>
       <blacklist name="blacklist1">
            <property name="conditionAndAlwayTrueAllow">false</property>
            <property name="conditionDoubleConstAllow">false</property>
            <property name="deleteWhereNoneCheck">true</property>
            <property name="updateWhereNoneCheck">true</property>
            <property name="conditionAndAlwayFalseAllow">false</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd   | conn   | toClose | sql                                 | expect     | db      |
      | test1  | 111111   | conn_0 | False   | drop table if exists test           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | create table test(id int)           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | insert into test values (1)         | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | select * from test where id =1 and 1=1      | Intercepted by suspected configuration [selectWhereAlwayTrueCheck,selectHavingAlwayTrueCheck,deleteWhereAlwayTrueCheck,updateWhereAlayTrueCheck,conditionAndAlwayTrueAllow] in the blacklist of user 'test1', so it is considered unsafe SQL | schema1 |
      | test1  | 111111   | conn_0 | False   | select * from test where 2 =1 and 1=1       | Intercepted by suspected configuration [conditionDoubleConstAllow] in the blacklist of user 'test1', so it is considered unsafe SQL                   | schema1 |
      | test1  | 111111   | conn_0 | False   | delete from test                            | Intercepted by suspected configuration [deleteWhereNoneCheck,updateWhereNoneCheck] in the blacklist of user 'test1', so it is considered unsafe SQL   | schema1 |
      | test1  | 111111   | conn_0 | true    | update test set id=2                        | Intercepted by suspected configuration [deleteWhereNoneCheck,updateWhereNoneCheck] in the blacklist of user 'test1', so it is considered unsafe SQL   | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist2"/>
       <blacklist name="blacklist2">
            <property name="conditionAndAlwayTrueAllow">true</property>
            <property name="conditionDoubleConstAllow">true</property>
            <property name="deleteWhereNoneCheck">false</property>
            <property name="updateWhereNoneCheck">false</property>
            <property name="conditionAndAlwayFalseAllow">true</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  | db      |
      | conn_1 | False   | drop table if exists test              | success | schema1 |
      | conn_1 | False   | create table test(id int)              | success | schema1 |
      | conn_1 | False   | insert into test values (1)            | success | schema1 |
      | conn_1 | False   | select * from test where id =1 and 1=1 | success | schema1 |
      | conn_1 | False   | select * from test where 2 =1 and 1=1  | success | schema1 |
      | conn_1 | False   | update test set id=2                   | success | schema1 |
      | conn_1 | False   | delete from test                       | success | schema1 |
      | conn_1 | true    | drop table if exists test              | success | schema1 |


  Scenario: test user.xml blacklist  -- Bad operation on DMP SQL firewall  #7
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1"/>
       <blacklist name="blacklist1">
            <property name="selectUnionCheck">true</property>
            <property name="limitZeroAllow">false</property>
            <property name="conditionLikeTrueAllow">false</property>
            <property name="constArithmeticAllow">false</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd   | conn   | toClose | sql                                 | expect     | db      |
      | test1  | 111111   | conn_0 | False   | drop table if exists test           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | create table test(id int)           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | insert into test values (1)         | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | drop table if exists test1          | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | create table test1(id int)          | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | insert into test1 values (1)        | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | select * from test limit 0          | Intercepted by suspected configuration [limitZeroAllow] in the blacklist of user 'test1', so it is considered unsafe SQL             | schema1 |
      | test1  | 111111   | conn_0 | False   | select * from test where id = 2-1   | Intercepted by suspected configuration [constArithmeticAllow] in the blacklist of user 'test1', so it is considered unsafe SQL          | schema1 |
#      | test1  | 111111   | conn_0 | true    | select * from test union select * from test1                     |    | schema1 |
#      | test1  | 111111   | conn_0 | true    | select * from test where id like '%'                             |    | schema1 |


     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test2" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist3"/>
       <blacklist name="blacklist3">
            <property name="conditionOpBitwseAllow">false</property>
            <property name="conditionOpXorAllow">false</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
      | user   | passwd   | conn   | toClose | sql                                 | expect     | db      |
      | test2  | 111111   | conn_2 | False   | drop table if exists test           | success    | schema1 |
      | test2  | 111111   | conn_2 | False   | create table test(id int)           | success    | schema1 |
      | test2  | 111111   | conn_2 | False   | insert into test values (1)         | success    | schema1 |
      | test2  | 111111   | conn_2 | False   | select * from test where  1 & 2     | Intercepted by suspected configuration [conditionOpBitwseAllow] in the blacklist of user 'test2', so it is considered unsafe SQL   | schema1 |
      | test2  | 111111   | conn_2 | true    | select * from test where  0 xor 1   | Intercepted by suspected configuration [conditionOpXorAllow] in the blacklist of user 'test2', so it is considered unsafe SQL      | schema1 |

     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test3" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist4"/>
       <blacklist name="blacklist4">
            <property name="mustParameterized">true</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
      | user   | passwd   | conn   | toClose | sql                                 | expect     | db      |
      | test3  | 111111   | conn_3 | False   | drop table if exists test           | success    | schema1 |
      | test3  | 111111   | conn_3 | False   | create table test(id int)           | success    | schema1 |
      | test3  | 111111   | conn_3 | False   | insert into test values (1)         | success    | schema1 |
      | test3  | 111111   | conn_3 | true    | select * from test where id=1       | Intercepted by suspected configuration [mustParameterized] in the blacklist of user 'test3', so it is considered unsafe SQL   | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist2"/>
       <blacklist name="blacklist2">
            <property name="conditionOpBitwseAllow">true</property>
            <property name="selectUnionCheck">false</property>
            <property name="limitZeroAllow">true</property>
            <property name="conditionLikeTrueAllow">true</property>
            <property name="conditionOpXorAllow">true</property>
            <property name="constArithmeticAllow">true</property>
            <property name="mustParameterized">false</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | False   | drop table if exists test                    | success | schema1 |
      | conn_1 | False   | create table test(id int)                    | success | schema1 |
      | conn_1 | False   | insert into test values (1)                  | success | schema1 |
      | conn_1 | False   | drop table if exists test1                   | success | schema1 |
      | conn_1 | False   | create table test1(id int)                   | success | schema1 |
      | conn_1 | False   | insert into test1 values (1)                 | success | schema1 |
      | conn_1 | False   | select * from test limit 0                   | success | schema1 |
      | conn_1 | False   | select * from test where id = 2-1            | success | schema1 |
      | conn_1 | False   | select * from test union select * from test1 | success | schema1 |
      | conn_1 | False   | select * from test where id like '%'         | success | schema1 |
      | conn_1 | False   | select * from test where  1 & 2              | success | schema1 |
      | conn_1 | False   | select * from test where  0 xor 1            | success | schema1 |
      | conn_1 | False   | update test set id=2                         | success | schema1 |
      | conn_1 | False   | drop table if exists test                    | success | schema1 |
      | conn_1 | true    | drop table if exists test1                   | success | schema1 |


  Scenario: test user.xml blacklist  -- other operation on DMP SQL firewall #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1"/>
       <blacklist name="blacklist1">
            <property name="describeAllow">false</property>
            <property name="useAllow">false</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd   | conn   | toClose | sql                                 | expect     | db      |
      | test1  | 111111   | conn_0 | False   | drop table if exists test           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | create table test(id int)           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | desc test                           | Intercepted by suspected configuration [describeAllow] in the blacklist of user 'test1', so it is considered unsafe SQL    | schema1 |
      | test1  | 111111   | conn_0 | False   | describe test                       | Intercepted by suspected configuration [describeAllow] in the blacklist of user 'test1', so it is considered unsafe SQL    | schema1 |
      | test1  | 111111   | conn_0 | False   | use schema1                         | Intercepted by suspected configuration [useAllow] in the blacklist of user 'test1', so it is considered unsafe SQL         | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist2"/>
       <blacklist name="blacklist2">
            <property name="describeAllow">true</property>
            <property name="useAllow">true</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | False   | drop table if exists test                    | success | schema1 |
      | conn_1 | False   | create table test(id int)                    | success | schema1 |
      | conn_1 | False   | desc test                                    | success | schema1 |
      | conn_1 | False   | describe test                                | success | schema1 |
      | conn_1 | False   | use schema1                                  | success | schema1 |
      | conn_1 | False   | drop table if exists test                    | success | schema1 |


  Scenario: test user.xml blacklist  -- some operation on dble's documentation  #9
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1"/>
       <blacklist name="blacklist1">
            <property name="selectAllColumnAllow">false</property>
            <property name="selectIntoOutfileAllow">false</property>
            <property name="selectIntoAllow">false</property>
            <property name="mergeAllow">false</property>
            <property name="selectWhereAlwayTrueCheck">false</property>
            <property name="selectHavingAlwayTrueCheck">false</property>
            <property name="deleteWhereAlwayTrueCheck">false</property>
            <property name="updateWhereAlayTrueCheck">false</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd   | conn   | toClose | sql                                 | expect     | db      |
      | test1  | 111111   | conn_0 | False   | drop table if exists test           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | create table test(id int)           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | insert into test set id=1           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | select * from test                  | Intercepted by suspected configuration [selelctAllow,selectAllColumnAllow] in the blacklist of user 'test1', so it is considered unsafe SQL   | schema1 |
      | test1  | 111111   | conn_0 | False   | select id into @1 from test         | Intercepted by suspected configuration [selectIntoAllow] in the blacklist of user 'test1', so it is considered unsafe SQL                     | schema1 |
      | test1  | 111111   | conn_0 | False   | select id into outfile '/test.txt' from test        | Intercepted by suspected configuration [selectIntoAllow] in the blacklist of user 'test1', so it is considered unsafe SQL     | schema1 |
      | test1  | 111111   | conn_0 | False   | select * from test where id = 2-1 and hujh = hujh/*lxxt*/        | Intercepted by suspected configuration [selectWhereAlwayTrueCheck,selectHavingAlwayTrueCheck,deleteWhereAlwayTrueCheck,updateWhereAlayTrueCheck,conditionAndAlwayTrueAllow] in the blacklist of user 'test1', so it is considered unsafe SQL                     | schema1 |
      | test1  | 111111   | conn_0 | False   | select id from test having id = 2-1 and hujh = hujh/*lxxt*/      | Intercepted by suspected configuration [selectWhereAlwayTrueCheck,selectHavingAlwayTrueCheck,deleteWhereAlwayTrueCheck,updateWhereAlayTrueCheck,conditionAndAlwayTrueAllow] in the blacklist of user 'test1', so it is considered unsafe SQL                     | schema1 |
      | test1  | 111111   | conn_0 | False   | delete from test where id = 2-1 and hujh = hujh/*lxxt*/          | Intercepted by suspected configuration [selectWhereAlwayTrueCheck,selectHavingAlwayTrueCheck,deleteWhereAlwayTrueCheck,updateWhereAlayTrueCheck,conditionAndAlwayTrueAllow] in the blacklist of user 'test1', so it is considered unsafe SQL                     | schema1 |
      | test1  | 111111   | conn_0 | true    | update test set id=2 where id = 1 and hujh = hujh/*lxxt*/        | Intercepted by suspected configuration [selectWhereAlwayTrueCheck,selectHavingAlwayTrueCheck,deleteWhereAlwayTrueCheck,updateWhereAlayTrueCheck,conditionAndAlwayTrueAllow] in the blacklist of user 'test1', so it is considered unsafe SQL                     | schema1 |


    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist2"/>
       <blacklist name="blacklist2">
            <property name="selectAllColumnAllow">true</property>
            <property name="selectIntoOutfileAllow">true</property>
            <property name="selectIntoAllow">true</property>
            <property name="mergeAllow">true</property>
            <property name="selectWhereAlwayTrueCheck">true</property>
            <property name="selectHavingAlwayTrueCheck">true</property>
            <property name="deleteWhereAlwayTrueCheck">true</property>
            <property name="updateWhereAlayTrueCheck">true</property>
       </blacklist>
     """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | False   | drop table if exists test                    | success | schema1 |
      | conn_1 | False   | create table test(id int)                    | success | schema1 |
      | conn_1 | False   | insert into test set id=1                    | success | schema1 |
      | conn_1 | False   | select * from test                           | success | schema1 |
      | conn_1 | False   | select id into @1 from test                       | select ... into is not supported | schema1 |
      | conn_1 | False   | select id into outfile '/test.txt' from test      | select ... into is not supported | schema1 |
      | conn_1 | False   | select * from test where id = 2-1 and hujh = hujh/*lxxt*/     | Intercepted by suspected configuration [selectWhereAlwayTrueCheck,selectHavingAlwayTrueCheck,deleteWhereAlwayTrueCheck,updateWhereAlayTrueCheck,conditionAndAlwayTrueAllow] in the blacklist of user 'test', so it is considered unsafe SQL                     | schema1 |
      | conn_1 | False   | select id from test having id = 2-1 and hujh = hujh/*lxxt*/   | Intercepted by suspected configuration [selectWhereAlwayTrueCheck,selectHavingAlwayTrueCheck,deleteWhereAlwayTrueCheck,updateWhereAlayTrueCheck,conditionAndAlwayTrueAllow] in the blacklist of user 'test', so it is considered unsafe SQL                     | schema1 |
      | conn_1 | False   | delete from test where id = 2-1 and hujh = hujh/*lxxt*/       | Intercepted by suspected configuration [selectWhereAlwayTrueCheck,selectHavingAlwayTrueCheck,deleteWhereAlwayTrueCheck,updateWhereAlayTrueCheck,conditionAndAlwayTrueAllow] in the blacklist of user 'test', so it is considered unsafe SQL                     | schema1 |
      | conn_1 | False   | update test set id=2 where id = 1 and hujh = hujh/*lxxt*/     | Intercepted by suspected configuration [selectWhereAlwayTrueCheck,selectHavingAlwayTrueCheck,deleteWhereAlwayTrueCheck,updateWhereAlayTrueCheck,conditionAndAlwayTrueAllow] in the blacklist of user 'test', so it is considered unsafe SQL                     | schema1 |
      | conn_1 | true    | drop table if exists test                    | success | schema1 |


  Scenario: test user.xml blacklist  -- some operation on dble's documentation  #10
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1"/>
       <blacklist name="blacklist1">
            <property name="selectMinusCheck">true</property>
            <property name="selectExceptCheck">true</property>
            <property name="selectIntersectCheck">true</property>
       </blacklist>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd   | conn   | toClose | sql                                 | expect     | db      |
      | test1  | 111111   | conn_0 | False   | drop table if exists test           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | create table test(id int)           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | insert into test set id=1           | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | drop table if exists test1          | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | create table test1(id int)          | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | insert into test1 set id=1          | success    | schema1 |
      | test1  | 111111   | conn_0 | False   | select * from test where id=1 minus select * from test1          | You have an error in your SQL syntax;MINUS                   | schema1 |
      | test1  | 111111   | conn_0 | False   | select * from test where id=1 except select * from test1         | You have an error in your SQL syntax;EXCEPT                  | schema1 |
      | test1  | 111111   | conn_0 | true    | select * from test where id=1 INTERSECT select * from test1      | You have an error in your SQL syntax;INTERSECT               | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist2"/>
       <blacklist name="blacklist2">
            <property name="selectMinusCheck">false</property>
            <property name="selectExceptCheck">false</property>
            <property name="selectIntersectCheck">false</property>
       </blacklist>
     """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | False   | drop table if exists test                    | success | schema1 |
      | conn_1 | False   | create table test(id int)                    | success | schema1 |
      | conn_1 | False   | insert into test set id=1                    | success | schema1 |
      | conn_1 | False   | drop table if exists test1                   | success | schema1 |
      | conn_1 | False   | create table test1(id int)                   | success | schema1 |
      | conn_1 | False   | insert into test1 set id=1                   | success | schema1 |
      | conn_1 | False   | select * from test where id=1 minus select * from test1          | You have an error in your SQL syntax;MINUS                   | schema1 |
      | conn_1 | False   | select * from test where id=1 except select * from test1         | You have an error in your SQL syntax;EXCEPT                  | schema1 |
      | conn_1 | False   | select * from test where id=1 INTERSECT select * from test1      | You have an error in your SQL syntax;INTERSECT               | schema1 |
      | conn_1 | False   | drop table if exists test                    | success | schema1 |
      | conn_1 | true    | drop table if exists test1                   | success | schema1 |



