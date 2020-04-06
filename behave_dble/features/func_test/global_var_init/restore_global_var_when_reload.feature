# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/13 下午12:14
# @Author  : irene-coming
#@skip
Feature: if dble rebuild conn pool with reload, then global vars dble concerned will be redetected
#dble cared global vars:
#| dble config name     | dble config value | mysql variable name    | mysql variable value   | mysql effect Scope |
#| lowerCaseTableNames  | true              | lower_case_table_names | 0                      | global             |
#| autocommit           | 1                 | autocommit             | ON                     | Global,Session     |
#| txIsolation          | 3                 | tx_isolation           | REPEATABLE-READ(3)     | Global,Session     |
#| readOnly             | false             | read_only              | OFF                    | Global             |

  @restore_general_log
  Scenario: Backend Global vars are same with dble config,conn pool recreated will trigger to check global vars again and will not reset for values are same.#1
    """
    {'restore_general_log':['mysql-master1','mysql-master2']}
    """
# if conn pool is not recreated, global var will not be redetected
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    Given record current dble log line number in "log_linenu"
    When execute admin cmd "reload @@config_all -r" success
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    con query sql:select @@lower_case_table_names,@@autocommit, @@read_only,@@tx_isolation
    """
    Then check general log in host "mysql-master1" has not "set global autocommit=1"
    Then check general log in host "mysql-master2" has not "set global autocommit=1"
    When execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose | sql                                | expect  | db      |
      | test  | 111111    | conn_0 | True    | drop table if exists sharding_4_t1 | success | schema1 |
    Then check general log in host "mysql-master1" has not "SET autocommit=1"
    Then check general log in host "mysql-master2" has not "SET autocommit=1"

  @restore_general_log @skip
  Scenario: Backend Global vars are different with dble config,conn pool recreated will check it, and set the values same as dble config #2
    """
    {'restore_general_log':['mysql-master1','mysql-master2']}
    """
    Given execute sql in "mysql-master1"
      | user  | passwd    | conn   | toClose | sql                                      | expect  |db |
      | test  | 111111    | conn_0 | False   | set global autocommit=0                  | success |   |
      | test  | 111111    | conn_0 | True    | set global tx_isolation='READ-COMMITTED' | success |   |
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    When execute admin cmd "reload @@config_all -r" success
    Then check general log in host "mysql-master1" has "set global autocommit=1,tx_isolation='REPEATABLE-READ'"
    Then check general log in host "mysql-master2" has not "set global autocommit=1,tx_isolation='REPEATABLE-READ'"
#    create new conns,and check new conn will not set global xxx
    Given turn on general log in "mysql-master1"
    Given create "11" front connections executing "drop table if exists sharding_4_t1"
    Then check general log in host "mysql-master1" has not "set global autocommit=1"

  @restore_general_log
  Scenario:select global vars to a certain writeHost fail at dble start, when heatbeat recover, try select global vars again and set global vars if nessessary #3
    """
    {'restore_general_log':['mysql-master1']}
    """
    Given stop mysql in host "mysql-master1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="dataNodeHeartbeatPeriod">2000</property>
    </system>
    """
    Given Restart dble in "dble-1" success
    Given start mysql in host "mysql-master1"
    Given turn on general log in "mysql-master1"
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                      | expect  |
      | conn_0 | False   | set global autocommit=0                  | success |
      | conn_0 | True    | set global tx_isolation='READ-COMMITTED' | success |
    Given sleep "3" seconds
    Then check general log in host "mysql-master1" has "set global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_general_log @skip
  Scenario:set global vars failed for user has no priviledges, then set session context if values are not same as config at conn used #4
    """
    {'restore_general_log':['mysql-master1']}
    """
    Given stop dble in "dble-1"
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                            | expect  |
      | conn_0 | False   | drop user if exists 'user1'@'%'                | success |
      | conn_0 | False   | create user 'user1'@'%' identified by '111111' | success |
      | conn_0 | False   | grant select on *.* to 'user1'@'%'             | success |
      | conn_0 | False   | set global tx_isolation='READ-COMMITTED'       | success |
      | conn_0 | True    | set global autocommit=0                        | success |
    Given add xml segment to node with attribute "{'tag':'dataHost','kv_map':{'name':'ha_group1'}}" in "schema.xml"
    """
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="user1">
    </writeHost>
    """
    Given turn on general log in "mysql-master1"
    Given Start dble in "dble-1"
    #    try to set global but failed for having no priviledges
    Then check general log in host "mysql-master1" has "set global autocommit=1,tx_isolation='REPEATABLE-READ'"
#    when dble start, it need to check metadata by show create table, during which will set session context if it find autocommit is different with config
    Then check general log in host "mysql-master1" has "SET autocommit=1"
#    create more than minCon conns to used out the conn pool, the next conn will be new created
    Given create "11" front connections executing "drop table if exists sharding_4_t1"
#    force rotate general log
    Given turn on general log in "mysql-master1"
    When execute sql in "dble-1" in "user" mode
      | sql                                | expect                      | db      |
      | drop table if exists sharding_4_t1 | DROP command denied to user | schema1 |
    Then check general log in host "mysql-master1" has "SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ"
    Then check general log in host "mysql-master1" has "SET autocommit=1"
    Given add xml segment to node with attribute "{'tag':'dataHost','kv_map':{'name':'ha_group1'}}" in "schema.xml"
    """
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
    </writeHost>
    """
    When execute admin cmd "reload @@config_all " success
    Then check general log in host "mysql-master1" has "set global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_general_log @restore_global_setting
  Scenario:backend mysql global var read_only=true, then every heartbeat will try to select the global vars,and try to set autocommit and tx_isolation if their values different between dble and mysql#5
    """
    {'restore_general_log':['mysql-master1']}
    {'restore_global_setting':{'mysql-master1':{'read_only':0}}}
    """
    Given stop dble in "dble-1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="dataNodeHeartbeatPeriod">2000</property>
    </system>
    """
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                      |
      | conn_0 | False   | set global read_only=on                  |
      | conn_0 | False   | set global autocommit=0                  |
      | conn_0 | True    | set global tx_isolation='READ-COMMITTED' |
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"
    Given sleep "5" seconds
    Then check general log in host "mysql-master1" has "select @@lower_case_table_names,@@autocommit, @@read_only,@@tx_isolation" occured ">2" times

  @restore_general_log @skip
  Scenario:config autocommit/txIsolation to not default value, and backend mysql values are different, dble will set backend same as dble configed #6
    """
    {'restore_general_log':['mysql-master1']}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="autocommit">0</property>
        <property name="txIsolation">2</property>
    </system>
    """
    Given stop dble in "dble-1"
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                       |
      | conn_0 | False   | set global autocommit=1                   |
      | conn_0 | True    | set global tx_isolation='REPEATABLE-READ' |
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has "SET global autocommit=0,tx_isolation='READ-COMMITTED'"
    When execute sql in "dble-1" in "user" mode
      | sql                                | expect  | db      |
      | drop table if exists sharding_4_t1 | success | schema1 |
    Then check general log in host "mysql-master1" has not "SET autocommit=0"
    Then check general log in host "mysql-master2" has not "SET autocommit=0"

  @restore_general_log @skip
  Scenario: dble default autocommit=1, after executing implicit query(with which dble will add autocommit=0 to the session), the global var will be restored #7
# with long gap heartbeat, when kill all backend conns except the ones you want to keep, then the following query will use the conn you keep, which make sure autocommit=0 conns afterwhile is set autocommit=1
    """
    {'restore_general_log':['mysql-master1']}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="dataNodeHeartbeatPeriod">120000</property>
    </system>
    """
    Given Restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
      | sql                                | expect  |db      |
      | create table sharding_2_t1(id int) | success |schema1 |
    Given record current dble log line number in "log_linenu"
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    Given execute sql in "dble-1" in "user" mode
      | sql                                     | expect  | db      |
      | insert into sharding_2_t1 values(1),(2) | success | schema1 |
    Given find backend conns of query "insert into sharrding_2_t1 values(1),(2)" used stored in "backendIds"
    Then check general log in host "mysql-master1" has "SET autocommit=0"
    Then check general log in host "mysql-master2" has "SET autocommit=0"
    Given kill all backend conns of "mysql-master1" except ones in "backendIds"
    Given kill all backend conns of "mysql-master2" except ones in "backendIds"
    Given execute sql in "dble-1" in "user" mode
      | sql                         | expect  | db      |
      | select * from sharding_2_t1 | success | schema1 |
    Then check general log in host "mysql-master1" has "SET autocommit=1"
    Then check general log in host "mysql-master2" has "SET autocommit=1"

  @restore_general_log @skip
  Scenario:config autocommit=0, after executing explicit query(with which dble will add autocommit=0 to the session), the global var will not be restored #8
    """
    {'restore_general_log':['mysql-master1']}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="dataNodeHeartbeatPeriod">120000</property>
        <property name="autocommit">0</property>
    </system>
    """
    Given Restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
      | sql                                | expect  |db      |
      | create table sharding_2_t1(id int) | success |schema1 |
    Given record current dble log line number in "log_linenu"
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    Given execute sql in "dble-1" in "user" mode
      | sql                                     | expect  | db      |
      | insert into sharding_2_t1 values(1),(2) | success | schema1 |
    Given find backend conns of query "insert into sharrding_2_t1 values(1),(2)" used stored in "backendIds"
    Then check general log in host "mysql-master1" has not "SET autocommit=0"
    Then check general log in host "mysql-master2" has not "SET autocommit=0"
    Given kill all backend conns of "mysql-master1" except ones in "backendIds"
    Given kill all backend conns of "mysql-master2" except ones in "backendIds"
    Given execute sql in "dble-1" in "user" mode
      | sql                         | expect  | db      |
      | select * from sharding_2_t1 | success | schema1 |
    Then check general log in host "mysql-master1" has not "SET autocommit=1"
    Then check general log in host "mysql-master2" has not "SET autocommit=1"

  @restore_general_log
  Scenario:dble starts at disabled=true, global vars values are different, then change it to enable by manager command, dble send set global query #9
    """
    {'restore_general_log':['mysql-master1']}
    """
    Given add xml segment to node with attribute "{'tag':'dataHost','kv_map':{'name':'ha_group1'}}" in "schema.xml"
    """
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test" disabled="true">
    </writeHost>
    """
    Given stop dble in "dble-1"
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                       | expect  |
      | conn_0 | False   | set global autocommit=0                   | success |
      | conn_0 | True    | set global tx_isolation='READ-COMMITTED'  | success |
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"
    When execute admin cmd "dataHost @@enable name='ha_group1'" success
    Then check general log in host "mysql-master1" has "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_general_log
  Scenario:dble starts at disabled=true, global vars values are different, then change it to enable by config and reload, dble send set global query #10
    """
    {'restore_general_log':['mysql-master1']}
    """
    Given add xml segment to node with attribute "{'tag':'dataHost','kv_map':{'name':'ha_group1'}}" in "schema.xml"
    """
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test" disabled="true">
    </writeHost>
    """
    Given stop dble in "dble-1"
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                       |
      | conn_0 | False   | set global autocommit=0                   |
      | conn_0 | True    | set global tx_isolation='READ-COMMITTED'  |
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"
    Given add xml segment to node with attribute "{'tag':'dataHost','kv_map':{'name':'ha_group1'}}" in "schema.xml"
    """
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test" disabled="false">
    </writeHost>
    """
    When execute admin cmd "reload @@config" success
    Then check general log in host "mysql-master1" has "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_general_log
  Scenario:dble starts at disabled=true, global vars values are same, then change it to enable by manager command, dble will not send set global query #11
    """
    {'restore_general_log':['mysql-master1']}
    """
    Given add xml segment to node with attribute "{'tag':'dataHost','kv_map':{'name':'ha_group1'}}" in "schema.xml"
    """
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test" disabled="true">
    </writeHost>
    """
    Given stop dble in "dble-1"
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"
    When execute admin cmd "dataHost @@enable name='ha_group1'" success
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_general_log
  Scenario:dble starts at disabled=true, global vars values are same, then change it to enable by config and reload, dble will not send set global query #12
    """
    {'restore_general_log':['mysql-master1']}
    """
    Given add xml segment to node with attribute "{'tag':'dataHost','kv_map':{'name':'ha_group1'}}" in "schema.xml"
    """
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test" disabled="true">
    </writeHost>
    """
    Given stop dble in "dble-1"
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='READ-COMMITTED'"
    Given add xml segment to node with attribute "{'tag':'dataHost','kv_map':{'name':'ha_group1'}}" in "schema.xml"
    """
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test" disabled="false">
    </writeHost>
    """
    When execute admin cmd "reload @@config" success
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_general_log
  Scenario:dble disabled loop state by false-true-false, global vars values are different at step false-true, dble will not send set global query #13
    """
    {'restore_general_log':['mysql-master1']}
    """
    Given turn on general log in "mysql-master1"
    Given add xml segment to node with attribute "{'tag':'dataHost','kv_map':{'name':'ha_group1'}}" in "schema.xml"
    """
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test" disabled="true">
    </writeHost>
    """
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                       |
      | conn_0 | False   | set global autocommit=0                   |
      | conn_0 | True    | set global tx_isolation='READ-COMMITTED'  |
    Given execute admin cmd "dataHost @@enable name='ha_group1'" success
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @current
  Scenario: if global var detect query failed at heartbeat restore, the heartbeat restore failed #14
    Given stop mysql in host "mysql-master1"
#    default dataNodeHeartbeatPeriod is 10, 11 makes sure heartbeat failed for mysql-master1
    Given sleep "11" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    heartbeat to [172.100.9.5:3306] setError
    """
    Given start mysql in host "mysql-master1"
    Given prepare a thread run btrace script "BtraceSelectGlobalVars1.java" in "dble-1"
    Then check btrace "BtraceAddMetaLock1.java" output in "dble-1" with "2" times'
    """
    get into call
    """
    Given prepare a thread run btrace script "BtraceSelectGlobalVars2.java" in "dble-1"
    """
    get into fieldEofResponse
    """
    Given kill connection with query "select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only" in host "mysql-master1"
    Given record current dble log line number in "log_linenu"
    Given sleep "11" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    heartbeat to [172.100.9.5:3306] setError
    """

