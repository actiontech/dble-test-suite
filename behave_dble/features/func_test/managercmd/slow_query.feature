# Copyright (C) 2016-2021 ActionTech.
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
  #CASE slow_query.time values can set  0 or other positive int
        | conn_0 | False   | reload @@slow_query.time = 0          | success                    |
        | conn_0 | False   | show @@slow_query.time                | has{('0',)}                |
        | conn_0 | False   | reload @@slow_query.time = -1         | the commend is not correct |
        | conn_0 | False   | reload @@slow_query.time = 1          | success                    |
        | conn_0 | False   | show @@slow_query.time                | has{('1',)}                |

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
       | conn   | toClose  | sql                                                             | expect                           | db      |
       | conn_0 | False    | drop table if exists a_test                                     |  success                         | schema1 |
       | conn_0 | False    | create table a_test(id int(10) unsigned NOT NULL,name char(1))  |  success                         | schema1 |
       | conn_0 | False    | insert into a_test values(1,1),(2,1111)                         |  Data too long for column 'name' | schema1 |
       | conn_0 | True     | insert into a_test values(3,3)                                  |  success                         | schema1 |
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
  # case to check xa query log written in assigned file
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                           | expect  | db      |
      | conn_0 | False   | begin                                         | success | schema1 |
      | conn_0 | False   | update a_test set name = "2"                  | success | schema1 |
      | conn_1 | False   | begin                                         | success | schema1 |
     Given prepare a thread execute sql "update a_test set name = "3"" with "conn_1"
     Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     update a_test set name = "2"
     """
     Then check following text exist "N" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     update a_test set name = "3"
     """
#case wiat 10 secends in conn0 query commit ,to check slowlogs has update sql
     Given sleep "10" seconds
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql    | expect  | db      |
      | conn_0 | true    | commit | success | schema1 |
     Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     update a_test set name = "3"
     """
    Given destroy sql threads list
#case drop table
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect  | db      |
      | conn_1 | true    | commit                                     | success | schema1 |
      | conn_0 | true    | drop table if exists a_test                | success | schema1 |


  @NORMAL
  Scenario: add one line in logfile what's NODE_QUERY  #4  DBLE0REQ-503
    Given delete file "/opt/dble/slowQuery" on "dble-1"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableSlowLog=1
    $a -DslowLogBaseName=query
    $a -DslowLogBaseDir=./slowQuery
    $a -DsqlSlowTime=0
    """
    Given delete the following xml segment
      | file            | parent         | child              |
      | sharding.xml    | {'tag':'root'} | {'tag':'schema'}   |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="s1" shardingNode="dn1" />
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
      </schema>
     <schema name="schema2" shardingNode="dn3" >
     </schema>
     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
     """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
     """
      Given Restart dble in "dble-1" success
      Then check following " " exist in dir "/opt/dble/" in "dble-1"
      """
      slowQuery
      query.log
      """
      Then execute sql in "dble-1" in "admin" mode
        | sql                            |
        | enable @@slow_query_log        |
     Then execute sql in "dble-1" in "user" mode
       | conn   | toClose  | sql                        | expect             | db      |
       | conn_0 | False    | select sleep(1)            | success            | schema1 |
     Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     select sleep(1)
     SINGLE_NODE_QUERY
     """
   # case singletable
    Given execute oscmd in "dble-1"
    """
     >/opt/dble/slowQuery/query.log
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                           | expect  | db      |
      | conn_0 | False   | drop table if exists s1       | success | schema1 |
      | conn_0 | False   | create table s1 (id int)      | success | schema1 |
      | conn_0 | False   | insert into s1 values (1),(2) | success | schema1 |
      | conn_0 | False   | select id from s1             | success | schema1 |
      | conn_0 | False   | update s1 set id=3            | success | schema1 |
      | conn_0 | true    | delete from s1                | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     drop table if exists s1
     create table s1 (id int)
     insert into s1 values (1),(2)
     select id from s1
     update s1 set id=3
     delete from s1
     SINGLE_NODE_QUERY
     dn1_First_Result_Fetch
     dn1_Last_Result_Fetch
     """
    Then check following text exist "N" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     MULTI_NODE_QUERY
     dn2
     dn3
     dn4
     dn5
     """
   # case global table
    Given execute oscmd in "dble-1"
    """
     >/opt/dble/slowQuery/query.log
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | expect  | db      |
      | conn_0 | False   | drop table if exists test               | success | schema1 |
      | conn_0 | False   | create table test (id int)              | success | schema1 |
      | conn_0 | False   | insert into test values (1),(2),(3),(4) | success | schema1 |
      | conn_0 | False   | select id from test                     | success | schema1 |
      | conn_0 | False   | update test set id=3                    | success | schema1 |
      | conn_0 | true    | delete from test                        | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     drop table if exists test
     create table test (id int)
     insert into test values (1),(2),(3),(4)
     select id from test
     update test set id=3
     delete from test
     MULTI_NODE_QUERY
     dn1_First_Result_Fetch
     dn1_Last_Result_Fetch
     dn2_First_Result_Fetch
     dn2_Last_Result_Fetch
     dn3_First_Result_Fetch
     dn3_Last_Result_Fetch
     dn4_First_Result_Fetch
     dn4_Last_Result_Fetch
     """
    Then check following text exist "N" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     dn5
     """
  # case sharding table
    Given execute oscmd in "dble-1"
    """
     >/opt/dble/slowQuery/query.log
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1               | success | schema1 |
      | conn_0 | False   | create table sharding_2_t1 (id int,code int)     | success | schema1 |
      | conn_0 | False   | insert into sharding_2_t1 values (1,1),(2,2)     | success | schema1 |
      | conn_0 | False   | select id,code from sharding_2_t1                | success | schema1 |
      | conn_0 | False   | update sharding_2_t1 set code=3                  | success | schema1 |
      | conn_0 | true    | delete from sharding_2_t1                        | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     drop table if exists sharding_2_t1
     create table sharding_2_t1 (id int,code int)
     insert into sharding_2_t1 values (1,1),(2,2)
     select id,code from sharding_2_t1
     update sharding_2_t1 set code=3
     delete from sharding_2_t1
     MULTI_NODE_QUERY
     dn1_First_Result_Fetch
     dn1_Last_Result_Fetch
     dn2_First_Result_Fetch
     dn2_Last_Result_Fetch
     """
    Then check following text exist "N" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     SINGLE_NODE_QUERY
     dn3
     dn4
     dn5
     """
  # case no-sharding table
    Given execute oscmd in "dble-1"
    """
     >/opt/dble/slowQuery/query.log
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect  | db      |
      | conn_0 | False   | drop table if exists n1               | success | schema1 |
      | conn_0 | False   | create table n1 (id int)              | success | schema1 |
      | conn_0 | False   | insert into n1 values (1),(2),(3),(4) | success | schema1 |
      | conn_0 | False   | select id from n1                     | success | schema1 |
      | conn_0 | False   | update n1 set id=3                    | success | schema1 |
      | conn_0 | true    | delete from n1                        | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     drop table if exists n1
     create table n1 (id int)
     insert into n1 values (1),(2),(3),(4)
     select id from n1
     update n1 set id=3
     delete from n1
     SINGLE_NODE_QUERY
     dn5_First_Result_Fetch
     dn5_Last_Result_Fetch
     """
    Then check following text exist "N" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     MULTI_NODE_QUERY
     dn1
     dn2
     dn3
     dn4
     """
  # case vertical table
    Given execute oscmd in "dble-1"
    """
     >/opt/dble/slowQuery/query.log
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect  | db      |
      | conn_0 | False   | drop table if exists v1               | success | schema2 |
      | conn_0 | False   | create table v1 (id int)              | success | schema2 |
      | conn_0 | False   | insert into v1 values (1),(2),(3),(4) | success | schema2 |
      | conn_0 | False   | select id from v1                     | success | schema2 |
      | conn_0 | False   | update v1 set id=3                    | success | schema2 |
      | conn_0 | true    | delete from v1                        | success | schema2 |
    Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     drop table if exists v1
     create table v1 (id int)
     insert into v1 values (1),(2),(3),(4)
     select id from v1
     update v1 set id=3
     delete from v1
     SINGLE_NODE_QUERY
     dn3_First_Result_Fetch
     dn3_Last_Result_Fetch
     """
    Then check following text exist "N" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     MULTI_NODE_QUERY
     dn1
     dn2
     dn4
     dn5
     """
 #case Complex query
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                | expect  | db      |
      | conn_0 | False   | insert into s1 values (1),(2),(3),(4)              | success | schema1 |
      | conn_0 | False   | insert into test values (1),(2),(3),(4)            | success | schema1 |
      | conn_0 | False   | insert into sharding_2_t1 values (1,1),(2,2)       | success | schema1 |
      | conn_0 | False   | insert into n1 values (1),(2),(3),(4)              | success | schema1 |
      | conn_0 | False   | insert into schema2.v1 values (1),(2),(3),(4)      | success | schema1 |
    Given execute oscmd in "dble-1"
    """
     >/opt/dble/slowQuery/query.log
    """
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                 | expect  | db      |
      | conn_0 | False   | select * from test where id in (select id from n1 where id =(select * from s1 where id=1))          | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     COMPLEX_QUERY
     Generate_New_Query
     """
    Given execute oscmd in "dble-1"
    """
     >/opt/dble/slowQuery/query.log
    """
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                            | expect  | db      |
      | conn_0 | False   | select * from sharding_2_t1 where id >(select t.id from test t inner join s1 s on t.id=s.id where s.id =1)     | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     COMPLEX_QUERY
     Generate_New_Query
     """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_0 | False   | drop table if exists s1                         | success | schema1 |
      | conn_0 | False   | drop table if exists test                       | success | schema1 |
      | conn_0 | False   | drop table if exists sharding_2_t1              | success | schema1 |
      | conn_0 | False   | drop table if exists n1                         | success | schema1 |
      | conn_0 | true    | drop table if exists schema2.v1                 | success | schema1 |




  Scenario: enable slow log function and execute sql, failed sql will not be logged to slow log; successful SQL will be logged to slow log #5
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