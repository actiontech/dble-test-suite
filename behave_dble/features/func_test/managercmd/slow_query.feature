# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: test slow query log related manager command

  @NORMAL
  Scenario:test "enable @@slow_query_log"，"disable @@slow_query_log"，"show @@slow_query_log" #1
      Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose | sql                     | expect       |
        | conn_0 | False   | enable @@slow_query_log | success      |
        | conn_0 | False   | show @@slow_query_log   | has{('1',)}  |
        | conn_0 | False   | disable @@slow_query_log| success      |
        | conn_0 | True    | show @@slow_query_log   | has{('0',)}  |
  @NORMAL
  Scenario: test "show @@slow_query.time", "reload @@slow_query.time", "show @@slow_query.flushperid", "reload @@slow_query.flushperid", "show @@slow_query.flushsize", "reload @@slow_query.flushsize" #2
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DsqlSlowTime=30
    $a -DflushSlowLogPeriod=1000
    $a -DflushSlowLogSize=5
    """
       Given Restart dble in "dble-1" success
       Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose | sql                                   | expect        |
        | conn_0 | False   | show @@slow_query.time                | has{('30',)}  |
        | conn_0 | False   | reload @@slow_query.time = 200        | success       |
        | conn_0 | False   | show @@slow_query.time                | has{('200',)} |

        | conn_0 | False   | show @@slow_query.flushperiod         | has{('1000',)} |
        | conn_0 | False   | reload @@slow_query.flushperiod = 200 | success        |
        | conn_0 | False   | show @@slow_query.flushperiod         | has{('200',)}  |

        | conn_0 | False   | show @@slow_query.flushsize           | has{('5',)}    |
        | conn_0 | False   | reload @@slow_query.flushsize = 50    | success        |
        | conn_0 | True    | show @@slow_query.flushsize           | has{('50',)}   |

  @NORMAL 
  Scenario: check slow query log written in assigned file #3
      Given delete file "/opt/dble/slowQuery" on "dble-1"
      Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableSlowLog=1
    $a -DslowLogBaseName=query
    $a -DslowLogBaseDir=./slowQuery
    $a -DsqlSlowTime=1
    """
     Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
        <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
            <shardingTable shardingNode="dn1,dn2,dn3,dn4" name="a_test" function="hash-four" shardingColumn="id" />
        </schema>
     """
      Given Restart dble in "dble-1" success
      Then check following " " exist in dir "/opt/dble/" in "dble-1"
      """
      slowQuery
      query.log
      """
      Then execute sql in "dble-1" in "admin" mode
        | sql                            |
        | disable @@slow_query_log       |
      Then execute sql in "dble-1" in "user" mode
        | conn   | toClose  | sql                             | db      |
        | conn_0 | False    | drop table if exists a_test     | schema1 |
        | conn_0 | False    | create table a_test(id int)     | schema1 |
        | conn_0 | False    | alter table a_test add age int  | schema1 |
        | conn_0 | False    | insert into a_test values(1,20) | schema1 |
        | conn_0 | False    | select id from a_test           | schema1 |
        | conn_0 | False    | select count(id) from a_test    | schema1 |
        | conn_0 | True     | delete from a_test              | schema1 |

      Then check following text exist "N" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
      """
      drop table if exists a_test
      create table a_test(id int)
      alter table a_test add name char(20)
      insert into a_test values(1,20)
      select id from a_test
      select count(id) from a_test
      delete from a_test
      """
      Then execute sql in "dble-1" in "admin" mode
        | sql                     |
        | enable @@slow_query_log |
      Then execute sql in "dble-1" in "user" mode
        | conn   | toClose  | sql                             | db      |
        | conn_0 | False    | drop table if exists a_test     | schema1 |
        | conn_0 | False    | create table a_test(id int)     | schema1 |
        | conn_0 | False    | alter table a_test add age int  | schema1 |
        | conn_0 | False    | insert into a_test values(1,20) | schema1 |
        | conn_0 | False    | select id from a_test           | schema1 |
        | conn_0 | False    | select count(id) from a_test    | schema1 |
        | conn_0 | True     | delete from a_test              | schema1 |
      Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
      """
      drop table if exists a_test
      create table a_test(id int)
      alter table a_test add age int
      insert into a_test values(1,20)
      select id from a_test
      select count(id) from a_test
      delete from a_test
      """
     Then execute sql in "dble-1" in "admin" mode
       | sql                     |
       | enable @@slow_query_log |
     Then execute sql in "dble-1" in "user" mode
       | conn   | toClose  | sql                                                             | expect                          | db      |
       | conn_0 | False    | drop table if exists a_test                                     | success                         | schema1 |
       | conn_0 | False    | create table a_test(id int(10) unsigned NOT NULL,name char(1))  | success                         | schema1 |
       | conn_0 | False    | insert into a_test values(1,1),(2,1111)                         | Data too long for column 'name' | schema1 |
       | conn_0 | True     | insert into a_test values(3,3)                                  | success                         | schema1 |
     Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     drop table if exists a_test
     create table a_test(id int(10) unsigned NOT NULL,name char(1))
     insert into a_test values(3,3)
     """
     Then check following text exist "N" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     insert into a_test values(1,1),(2,1111)
     """

# case from  testlink /3.20.10.0/8811
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect  | db      |
      | conn_0 | False   | drop table if exists test                  | success | schema1 |
      | conn_0 | False   | create table test(id int(10),name int(20)) | success | schema1 |
      | conn_0 | False   | insert into test values(1,1)               | success | schema1 |
      | conn_0 | False   | begin                                      | success | schema1 |
      | conn_0 | False   | update test set name = 2                   | success | schema1 |
      | conn_1 | False   | begin                                      | success | schema1 |
     Given prepare a thread execute sql "update test set name = 3" with "conn_1"
#case 1:wiat 10 secends in conn0 query commit ,to check slowlogs has update sql
     Given sleep "11" seconds
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql    | expect  | db      |
      | conn_0 | true    | commit | success | schema1 |
     Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     update test set name = 2
     update test set name = 3
     """
    Given destroy sql threads list
#case 1:wiat "update test set name = 4" return error ,to check slowlogs hasnot error update 5
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect  | db      |
      | conn_1 | true    | commit                                     | success | schema1 |
      | conn_2 | False   | begin                                      | success | schema1 |
      | conn_2 | False   | update test set name = 4                   | success | schema1 |
      | conn_3 | False   | begin                                      | success | schema1 |
     Given prepare a thread execute sql "update test set name = 5" with "conn_3"
     Given sleep "30" seconds
     Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     update test set name = 4
     """
     Then check following text exist "N" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     update test set name = 5
     """
    Given destroy sql threads list
#case drop table
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect  | db      |
      | conn_2 | true    | commit                                     | success | schema1 |
      | conn_3 | False   | rollback                                   | success | schema1 |
      | conn_3 | true    | drop table if exists test                  | success | schema1 |


  Scenario: enable slow log function and execute sql, failed sql will not be logged to slow log; successful SQL will be logged to slow log #4
    Given delete file "/opt/dble/slowQuery" on "dble-1"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableSlowLog=1
    $a -DslowLogBaseName=query
    $a -DslowLogBaseDir=./slowQuery
    $a -DsqlSlowTime=1
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                       | expect                                   | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                                                                                                                        | success                                  | schema1 |
      | conn_0 | False   | CREATE TABLE sharding_4_t1(id int(10) unsigned NOT NULL,t_id int(10) unsigned NOT NULL DEFAULT "0",name char(1) NOT NULL DEFAULT "",pad int(11) NOT NULL,PRIMARY KEY (id),KEY k_1 (t_id)) | success                                  | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1,"test_1",1),(2,2,"test_2",2),(3,3,"test_3",4),(4,4,"test_4",3),(5,5,5,1),(6,6,"test6",6)                                                             | Data too long for column 'name' at row 1 | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(1,1,1,1)                                                                                                                                                 | success                                  | schema1 |
    Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
    """
    CREATE TABLE sharding_4_t1(id int(10) unsigned NOT NULL,t_id int(10) unsigned NOT NULL DEFAULT "0",name char(1) NOT NULL DEFAULT "",pad int(11) NOT NULL,PRIMARY KEY (id),KEY k_1 (t_id))
    insert into sharding_4_t1 values(1,1,1,1)
    """
    Then check following text exist "N" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
    """
    insert into sharding_4_t1 values(1,1,1,1),(2,2,"test_2",2),(3,3,"test_3",4),(4,4,4,3),(5,5,"test...5",1),(6,6,"test6",6)
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    NPE
    """
    Then check following text exist "N" in file "/opt/dble/logs/wrapper.log" in host "dble-1"
    """
    NPE
    """