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
  Scenario: Backend Global vars are same with dble config,conn pool recreated will check again, and not set for values are same.#1
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

  @restore_general_log
  Scenario: Backend Global vars are different with dble config,conn pool recreated will check it, and set the values same as dble config #2
    """
    {'restore_general_log':['mysql-master1','mysql-master2']}
    """
    Given execute sql in "mysql-master1"
      | user  | passwd    | conn   | toClose | sql                     | expect  |db |
      | test  | 111111    | conn_0 | True    | set global autocommit=0 | success |   |
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    When execute admin cmd "reload @@config_all -r" success
    Then check general log in host "mysql-master1" has "set global autocommit=1"
    Then check general log in host "mysql-master2" has not "set global autocommit=1"
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
      | user  | passwd    | conn   | toClose | sql                                      | expect  |db |
      | test  | 111111    | conn_0 | False   | set global autocommit=0                  | success |   |
      | test  | 111111    | conn_0 | True    | set global tx_isolation='READ-COMMITTED' | success |   |
    Given sleep "3" seconds
    Then check general log in host "mysql-master1" has "set global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_general_log
  Scenario:set global vars failed for user has no priviledges, then set session context if values are not same as config at conn used #4
    """
    {'restore_general_log':['mysql-master1']}
    """
    Given stop dble in "dble-1"
    Given execute sql in "mysql-master1"
      | user  | passwd    | conn   | toClose | sql                                            | expect  | db|
      | test  | 111111    | conn_0 | False   | drop user if exists 'user1'@'%'                | success |   |
      | test  | 111111    | conn_0 | False   | create user 'user1'@'%' identified by '111111' | success |   |
      | test  | 111111    | conn_0 | False   | grant select on *.* to 'user1'@'%'             | success |   |
      | test  | 111111    | conn_0 | False   | set global tx_isolation='READ-COMMITTED'       | success |   |
      | test  | 111111    | conn_0 | True    | set global autocommit=0                        | success |   |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <dataHost balance="0" maxCon="100" minCon="10" name="dh1" slaveThreshold="100" >
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="user1">
            </writeHost>
        </dataHost>
    """
    Given turn on general log in "mysql-master1"
    Given Start dble in "dble-1"
    When execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose | sql                                | expect  | db      |
      | test  | 111111    | conn_0 | True    | drop table if exists sharding_4_t1 | success | schema1 |
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
      | user  | passwd    | conn   | toClose | sql                                      | expect  |db |
      | test  | 111111    | conn_0 | False   | set global read_only=on                  | success |   |
      | test  | 111111    | conn_0 | True    | set global autocommit=0                  | success |   |
      | test  | 111111    | conn_0 | True    | set global tx_isolation='READ-COMMITTED' | success |   |
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has "set global autocommit=1,tx_isolation='REPEATABLE-READ'"
    Given sleep "5" seconds
    Then check general log in host "mysql-master1" has "select @@lower_case_table_names,@@autocommit, @@read_only,@@tx_isolation" occured ">2" times

  @restore_general_log @skip
  Scenario:config autocommit/txIsolation to not default value, and backend mysql values are different, dble will set backend same as dble configed #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="autocommit">0</property>
        <property name="txIsolation">2</property>
    </system>
    """
    Given stop dble in "dble-1"
    Given execute sql in "mysql-master1"
      | user  | passwd    | conn   | toClose | sql                                       | expect  |db |
      | test  | 111111    | conn_0 | False   | set global autocommit=1                   | success |   |
      | test  | 111111    | conn_0 | True    | set global tx_isolation='REPEATABLE-READ' | success |   |
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has "set global autocommit=0,tx_isolation='READ-COMMITTED'"
