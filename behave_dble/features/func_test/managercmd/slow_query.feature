# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: test slow query log related manager command

  @NORMAL
  Scenario:test "enable @@slow_query_log"，"disable @@slow_query_log"，"show @@slow_query_log" #1
      Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose | sql                     | expect       |
        | conn_0 | False   | enable @@slow_query_log | success      |
        | conn_0 | False   | show @@slow_query_log   | has{(('1',),)}  |
        | conn_0 | False   | disable @@slow_query_log| success      |
        | conn_0 | True    | show @@slow_query_log   | has{(('0',),)}  |


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
        | conn_0 | False   | show @@slow_query.time                | has{(('30',),)}  |
        | conn_0 | False   | reload @@slow_query.time = 200        | success       |
        | conn_0 | False   | show @@slow_query.time                | has{(('200',),)} |
  #CASE slow_query.time values can set  0 or other positive int
        | conn_0 | False   | reload @@slow_query.time = 0          | success                    |
        | conn_0 | False   | show @@slow_query.time                | has{(('0',),)}                |
        | conn_0 | False   | reload @@slow_query.time = -1         | the commend is not correct |
        | conn_0 | False   | reload @@slow_query.time = 1          | success                    |
        | conn_0 | False   | show @@slow_query.time                | has{(('1',),)}                |

        | conn_0 | False   | show @@slow_query.flushperiod         | has{(('1000',),)} |
        | conn_0 | False   | reload @@slow_query.flushperiod = 200 | success        |
        | conn_0 | False   | show @@slow_query.flushperiod         | has{(('200',),)}  |

        | conn_0 | False   | show @@slow_query.flushsize           | has{(('5',),)}    |
        | conn_0 | False   | reload @@slow_query.flushsize = 50    | success        |
        | conn_0 | True    | show @@slow_query.flushsize           | has{(('50',),)}   |


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
  # case to check transaction query log written in assigned file
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                           | expect  | db      |
      | conn_0 | False   | begin                                         | success | schema1 |
      | conn_0 | False   | update a_test set name = "2"                  | success | schema1 |
      | conn_1 | False   | begin                                         | success | schema1 |
     Given prepare a thread execute sql "update a_test set name = "3"" with "conn_1"
     Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     update a_test set name = \"2\"
     """
     Then check following text exist "N" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     update a_test set name = \"3\"
     """
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql    | expect  | db      |
      | conn_0 | true    | commit | success | schema1 |
  # case wait 3 seconds to check slowlogs has below update sql
     Given sleep "3" seconds
     Then check following text exist "Y" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
     """
     update a_test set name = \"3\"
     """
    Given destroy sql threads list
  # case drop table
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
    Given sleep "1" seconds
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
    Given sleep "1" seconds
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
    CREATE TABLE sharding_4_t1(id int(10) unsigned NOT NULL,t_id int(10) unsigned NOT NULL DEFAULT \"0\",name char(1) NOT NULL DEFAULT \"\",pad int(11) NOT NULL,PRIMARY KEY (id),KEY k_1 (t_id))
    insert into sharding_4_t1 values(1,1,1,1)
    """
    Then check following text exist "N" in file "/opt/dble/slowQuery/query.log" in host "dble-1"
    """
    insert into sharding_4_t1 values(1,1,1,1),(2,2,\"test_2\",2),(3,3,\"test_3\",4),(4,4,4,3),(5,5,\"test...5\",1),(6,6,\"test6\",6)
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      caught err:
      exception occurred when the statistics were recorded
      Exception processing
      """
    Then check following text exist "N" in file "/opt/dble/logs/wrapper.log" in host "dble-1"
      """
      NullPointerException
      caught err:
      exception occurred when the statistics were recorded
      Exception processing
      """


  Scenario: just shardinguser executed sql enable logged to slow log #6
      Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
       <rwSplitUser name="rwSp" password="111111" dbGroup="ha_group3" />
       """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="100" minCon="10" primary="true" />
      <dbInstance name="hostS3" password="111111" url="172.100.9.4:3307" user="test" maxCon="100" minCon="10" primary="false" />
      </dbGroup>
      """
     Then execute admin cmd "reload @@config_all"

     Then execute sql in "dble-1" in "admin" mode
       | conn   | toClose | sql                                   | expect         |
       | conn_0 | False   | enable @@slow_query_log               | success        |
       | conn_0 | False   | reload @@slow_query.time = 0          | success        |
       | conn_0 | true    | show @@slow_query.time                | has{(('0',),)} |
     Then execute sql in "dble-1" in "user" mode
      | user | password | conn   | toClose | sql                                         | expect      | db      |
      | rwSp | 111111   | conn_3 | False   | drop table if exists test                   | success     | db1     |
      | rwSp | 111111   | conn_3 | False   | create table test(id int)                   | success     | db1     |
      | rwSp | 111111   | conn_3 | False   | insert into test values (1)                 | success     | db1     |
      | rwSp | 111111   | conn_3 | true    | delete from test                            | success     | db1     |
     Then check following text exist "N" in file "/opt/dble/slowlogs/slow-query.log" in host "dble-1"
      """
      drop table if exists test
      create table test(id int)
      insert into test values (1)
      delete from test
      """
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                         | expect      | db        |
      | conn_1 | False   | drop table if exists test                   | success     | schema1   |
      | conn_1 | False   | create table test(id int)                   | success     | schema1   |
      | conn_1 | False   | insert into test values (1)                 | success     | schema1   |
      | conn_1 | true    | delete from test                            | success     | schema1   |
     Then check following text exist "Y" in file "/opt/dble/slowlogs/slow-query.log" in host "dble-1"
      """
      drop table if exists test
      create table test(id int)
      insert into test values (1)
      delete from test
      """


  Scenario: Added Inner_Execute, SIMPLE_QUERY properties #7
      Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
       <shardingUser name="test1" password="111111" schemas="schema1" tenant="tenant1"/>
       """
     Then execute admin cmd "reload @@config_all"
     Then execute sql in "dble-1" in "admin" mode
       | conn   | toClose | sql                                   | expect         |
       | conn_0 | False   | enable @@slow_query_log               | success        |
       | conn_0 | False   | reload @@slow_query.time = 0          | success        |

###################case:use schema1
    Then execute sql in "dble-1" in "user" mode
      | user          | passwd | conn   | toClose | sql         | expect   |
      | test1:tenant1 | 111111 | conn_2 | False   | use schema1 | success  |
    Then check following text exist "Y" in file "/opt/dble/slowlogs/slow-query.log" in host "dble-1"
      """
      User@Host: test1:tenant1\[test1:tenant1\]
      Query_time
      Lock_time
      Rows_sent
      Rows_examined
      Read_SQL
      Inner_Execute
      Write_Client
      SIMPLE_QUERY
      """
    Then check following text exist "N" in file "/opt/dble/slowlogs/slow-query.log" in host "dble-1"
      """
      Result_Fetch
      """

# check user front_id
    Then get index:"0" column value of "select session_conn_id from dble_information.session_connections where user = 'test1' and tenant = 'tenant1'" named as "user_front_id"

    Then execute the sql in "dble-1" in "admin" mode by parameter from resultset "user_front_id" and save resultset in "connection_sql_1"
      | conn   | toClose | sql                                               | expect       |
      | conn_0 | False   | show @@connection.sql.status where front_id={0}   | length{(3)} |

    Then check resultset "connection_sql_1" has lines with following column values
      | OPERATION-0     | SHARDING_NODE-4 | SQL/REF-5 |
      | Read_SQL        | -               | -         |
      | Parse_SQL       | -               | -         |
      | Write_to_Client | -               | -         |

###################case:show tables ,due sharding.xml has "<schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">"    DBLE0REQ-1872
    Then execute sql in "dble-1" in "user" mode
      | user          | passwd | conn   | toClose | sql         | expect   |
      | test1:tenant1 | 111111 | conn_2 | False   | show tables | success  |

    Then check the occur times of following key in file "/opt/dble/slowlogs/slow-query.log" in "dble-1"
      | key                    | occur_times |
      | Query_time             | 2        |
      | Lock_time              | 2        |
      | Rows_sent              | 2        |
      | Rows_examined          | 2        |
      | Read_SQL               | 2        |
      | Inner_Execute          | 2        |
#      | Write_Client           | 2        |
    Then check following text exist "N" in file "/opt/dble/slowlogs/slow-query.log" in host "dble-1"
      """
      Result_Fetch
      """
    Then execute the sql in "dble-1" in "admin" mode by parameter from resultset "user_front_id" and save resultset in "connection_sql_2"
      | conn   | toClose | sql                                               | expect       |
      | conn_0 | False   | show @@connection.sql.status where front_id={0}   | length{(3)} |

    Then check resultset "connection_sql_2" has lines with following column values
      | OPERATION-0     | SHARDING_NODE-4 | SQL/REF-5 |
      | Read_SQL        | -               | -         |
      | Parse_SQL       | -               | -         |
      | Write_to_Client | -               | -         |

###################case:set trace and show trace
    Then execute sql in "dble-1" in "user" mode
      | user          | passwd | conn   | toClose | sql         | expect       |
      | test1:tenant1 | 111111 | conn_2 | False   | set trace=1 | success      |
      | test1:tenant1 | 111111 | conn_2 | False   | show trace  | length{(4)}  |
      | test1:tenant1 | 111111 | conn_2 | False   | show tables | success      |
      | test1:tenant1 | 111111 | conn_2 | False   | show trace  | length{(4)}  |

    Then check the occur times of following key in file "/opt/dble/slowlogs/slow-query.log" in "dble-1"
      | key                    | occur_times |
      | Query_time             | 6        |
      | Lock_time              | 6        |
      | Rows_sent              | 6        |
      | Rows_examined          | 6        |
      | Read_SQL               | 6        |
      | Inner_Execute          | 6        |
      | Write_Client           | 6        |

    Then check following text exist "N" in file "/opt/dble/slowlogs/slow-query.log" in host "dble-1"
      """
      Result_Fetch
      """
    Then check following text exist "N" in file "/opt/dble/logs/wrapper.log" in host "dble-1"
      """
      NullPointerException
      caught err:
      exception occurred when the statistics were recorded
      Exception processing
      """


  Scenario: commit rollback #8
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  | db      |
      | conn_1 | False   | drop table if exists test   | success | schema1 |
      | conn_1 | False   | create table test (id int)  | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                   | expect         |
      | conn_0 | False   | enable @@slow_query_log               | success        |
      | conn_0 | False   | reload @@slow_query.time = 0          | success        |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  | db      |
      | conn_1 | False   | begin                       | success | schema1 |
      | conn_1 | False   | insert into test values (1) | success | schema1 |
      | conn_1 | False   | rollback                    | success | schema1 |

    Then check the occur times of following key in file "/opt/dble/slowlogs/slow-query.log" in "dble-1"
      | key                    | occur_times |
      | Query_time             | 3        |
      | Lock_time              | 3        |
      | Rows_sent              | 3        |
      | Rows_examined          | 3        |
      | Read_SQL               | 3        |
      | Inner_Execute          | 2        |
      | Write_Client           | 3        |
      | SIMPLE_QUERY           | 2        |
    Given record current dble log "/opt/dble/slowlogs/slow-query.log" line number in "log_1"
#####sleep just create time to check "commit"  Write_Client time
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  | db      |
      | conn_1 | False   | commit                      | success | schema1 |
###### check   Write_Client <  5s
    Then check following text exist "Y" in file "/opt/dble/slowlogs/slow-query.log" after line "log_1" in host "dble-1"
    """
    Write_Client: 0.00
    commit
    """
    Then check the occur times of following key in file "/opt/dble/slowlogs/slow-query.log" in "dble-1"
      | key                    | occur_times |
      | Query_time             | 4        |
      | Lock_time              | 4        |
      | Rows_sent              | 4        |
      | Rows_examined          | 4        |
      | Read_SQL               | 4        |
      | Inner_Execute          | 3        |
      | Write_Client           | 4        |
      | SIMPLE_QUERY           | 3        |
    Then check following text exist "N" in file "/opt/dble/logs/wrapper.log" in host "dble-1"
      """
      NullPointerException
      caught err:
      exception occurred when the statistics were recorded
      Exception processing
      """
