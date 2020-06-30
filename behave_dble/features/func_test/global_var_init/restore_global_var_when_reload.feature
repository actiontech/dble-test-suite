# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/13 下午12:14
# @Author  : irene-coming

Feature: if dble rebuild conn pool with reload, then global vars dble concerned will be redetected
#dble cared global vars:
#| dble config name     | dble default value | mysql variable name    | mysql default value   | mysql effect Scope |
#| lowerCaseTableNames  | true              | lower_case_table_names | 0                      | global             |
#| autocommit           | 1                 | autocommit             | ON                     | Global,Session     |
#| txIsolation          | 3                 | tx_isolation           | REPEATABLE-READ(3)     | Global,Session     |
#| readOnly             | false             | read_only              | OFF                    | Global             |

  @restore_global_setting
  Scenario: Backend Global vars are same with dble config,conn pool recreated will trigger to check global vars again and will not reset for values are same.#1
    """
    {'restore_global_setting':{'mysql-master1':{'general_log':0},'mysql-master2':{'general_log':0}}}
    """
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    Given record current dble log line number in "log_linenu"
# if conn pool is not recreated, global var will not be redetected, so reload must has -r option
    When execute admin cmd "reload @@config_all -r" success
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    con query sql:select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation
    """
    Then check general log in host "mysql-master1" has not "set global autocommit=1"
    Then check general log in host "mysql-master2" has not "set global autocommit=1"
    When execute sql in "dble-1" in "user" mode
      | sql                                | expect  | db      |
      | drop table if exists sharding_4_t1 | success | schema1 |
    Then check general log in host "mysql-master1" has not "SET autocommit=1"
    Then check general log in host "mysql-master2" has not "SET autocommit=1"

  @restore_global_setting
  Scenario: Backend Global vars are different with dble config,conn pool recreated will check it, and set the values same as dble config #2
    """
    {'restore_global_setting':{'mysql-master1':{'general_log':0},'mysql-master2':{'general_log':0}}}
    """
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                      |
      | conn_0 | False   | set global autocommit=0                  |
      | conn_0 | True    | set global tx_isolation='READ-COMMITTED' |
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    When execute admin cmd "reload @@config_all -r" success
    Then check general log in host "mysql-master1" has "set global autocommit=1,tx_isolation='REPEATABLE-READ'"
    Then check general log in host "mysql-master2" has not "set global autocommit=1,tx_isolation='REPEATABLE-READ'"
#    create new conns,and check new conn will not set global xxx
    Given turn on general log in "mysql-master1"
    Given kill all backend conns in "mysql-master1"
    When execute sql in "dble-1" in "user" mode
      | sql                                | db      |
      | drop table if exists sharding_4_t1 | schema1 |
    Then check general log in host "mysql-master1" has not "set global autocommit=1"

  @restore_mysql_config
  Scenario:select global vars to a certain writeHost fail at dble start, when heatbeat recover, try select global vars again and set global vars if nessessary #3
    """
    {'restore_mysql_config':{'mysql-master1':{'autocommit':1,'transaction_isolation':'REPEATABLE-READ','general_log':0}}}
    """
    Given stop mysql in host "mysql-master1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
          <property name="heartbeatPeriodMillis">2000</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
           <property name="heartbeatPeriodMillis">2000</property>
        </dbInstance>
    </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Given start mysql in host "mysql-master1"
    """
    /autocommit/d
    /server-id/a autocommit=0
    /transaction_isolation/d
    /server-id/a transaction_isolation='READ-COMMITTED'
    /general_log/d
    /server-id/a general_log=1
    """
#    heartbeat check period is 2s, 3s makes sure waiting more than a heartbeat time
    Given sleep "3" seconds
    Then check general log in host "mysql-master1" has "set global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_global_setting
  Scenario:set global vars failed for user has no priviledges, then set session context if values are not same as config at conn used #4
    """
    {'restore_global_setting':{'mysql-master1':{'general_log':0}}}
    """
    Given stop dble in "dble-1"
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                            | expect  |
      | conn_0 | False   | drop user if exists 'user1'@'%'                | success |
      | conn_0 | False   | create user 'user1'@'%' identified by '111111' | success |
      | conn_0 | False   | grant select on *.* to 'user1'@'%'             | success |
      | conn_0 | False   | set global tx_isolation='READ-COMMITTED'       | success |
      | conn_0 | True    | set global autocommit=0                        | success |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="user1" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Given turn on general log in "mysql-master1"
    Given Start dble in "dble-1"
    #    try to set global but failed for having no priviledges
    Then check general log in host "mysql-master1" has "set global autocommit=1,tx_isolation='REPEATABLE-READ'" occured ">0" times
#    when dble start, it need to check metadata by show create table, during which will set session context if it find autocommit is different with config
    Then check general log in host "mysql-master1" has "SET autocommit=1" occured ">0" times
    Given kill all backend conns in "mysql-master1"
#    force rotate general log
    Given turn on general log in "mysql-master1"
    When execute sql in "dble-1" in "user" mode
      | sql                                | expect                      | db      |
      | drop table if exists sharding_4_t1 | DROP command denied to user | schema1 |
    Then check general log in host "mysql-master1" has "SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ" occured "==2" times
#    ddl for sharding table, use autocommit=0,and so, no need to set autocommit=1
    Then check general log in host "mysql-master1" has not "SET autocommit=1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    When execute admin cmd "reload @@config_all " success
    Then check general log in host "mysql-master1" has "set global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_global_setting
  Scenario:backend mysql global var read_only=true, then every heartbeat will try to select the global vars,and try to set autocommit and tx_isolation if their values different between dble and mysql#5
    """
    {'restore_global_setting':{'mysql-master1':{'read_only':0,'general_log':0}}}
    """
    Given stop dble in "dble-1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
          <property name="heartbeatPeriodMillis">2000</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
           <property name="heartbeatPeriodMillis">2000</property>
        </dbInstance>
    </dbGroup>
    """
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                      |
      | conn_0 | False   | set global read_only=on                  |
      | conn_0 | False   | set global autocommit=0                  |
      | conn_0 | True    | set global tx_isolation='READ-COMMITTED' |
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"
#    a heartbeat period is 2, 5 means wait more than 2 heartbeat period
    Given sleep "5" seconds
    Then check general log in host "mysql-master1" has "select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation" occured ">2" times
@skip
  @restore_global_setting
  Scenario:config autocommit/txIsolation to not default value, and backend mysql values are different, dble will set backend same as dble configed #6
    """
    {'restore_global_setting':{'mysql-master1':{'general_log':0}}}
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    a/-Dautocommit=0
    a/-DtxIsolation=2
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

  @restore_global_setting
  Scenario: dble default autocommit=1, after executing implicit query(with which dble will add autocommit=0 to the session), the global var will be restored #7
# with long gap heartbeat, when kill all backend conns except the ones you want to keep, then the following query will use the conn you keep, which make sure autocommit=0 conns afterwhile is set autocommit=1
    """
    {'restore_global_setting':{'mysql-master1':{'general_log':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
          <property name="heartbeatPeriodMillis">120000</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
           <property name="heartbeatPeriodMillis">120000</property>
        </dbInstance>
    </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
      | sql                                | expect  |db      |
      | drop table if exists sharding_2_t1 | success |schema1 |
      | create table sharding_2_t1(id int) | success |schema1 |
    Given record current dble log line number in "log_linenu"
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | expect  | db      |
      | conn_0 | False   | insert into sharding_2_t1 values(1),(2) | success | schema1 |
      | conn_0 | True    | commit                                  | success | schema1 |
# find backend conns of query "insert into sharrding_2_t1 values(1),(2)" and heartbeat used in dble.log
    Given execute linux command in "dble-1" and save result in "heartbeat_master1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" |grep "172.100.9.5"| awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given execute linux command in "dble-1" and save result in "heartbeat_master2"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" |grep "172.100.9.6"| awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given execute linux command in "mysql-master1" and save result in "backendIds_master1"
    """
    grep -i "INSERT INTO sharding_2_t1" {node:install_path}/data/mysql-master1.log | awk '{print $2}'
    """
    Given execute linux command in "mysql-master2" and save result in "backendIds_master2"
    """
    grep -i "INSERT INTO sharding_2_t1" {node:install_path}/data/mysql-master2.log | awk '{print $2}'
    """
    Given merge resultset of "heartbeat_master1" and "backendIds_master1" into "ids_to_kill_master1"
    Given merge resultset of "heartbeat_master2" and "backendIds_master2" into "ids_to_kill_master2"
    Then check general log in host "mysql-master1" has "SET autocommit=0"
    Then check general log in host "mysql-master2" has "SET autocommit=0"
# make sure new client session will use conn in backendIds
    Given kill all backend conns in "mysql-master1" except ones in "ids_to_kill_master1"
    Given kill all backend conns in "mysql-master2" except ones in "ids_to_kill_master2"
    Given execute sql in "dble-1" in "user" mode
      | sql                         | expect  | db      |
      | select * from sharding_2_t1 | success | schema1 |
    Then check general log in host "mysql-master1" has "SET autocommit=1"
    Then check general log in host "mysql-master2" has "SET autocommit=1"
  @skip
  @restore_global_setting
  Scenario:config autocommit=0, after executing explicit query(with which dble will add autocommit=0 to the session), the global var will not be restored #8
    """
    {'restore_global_setting':{'mysql-master1':{'general_log':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
          <property name="heartbeatPeriodMillis">120000</property>
          <property name="evictorShutdownTimeoutMillis">120000</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
           <property name="heartbeatPeriodMillis">120000</property>
           <property name="evictorShutdownTimeoutMillis">120000</property>
        </dbInstance>
    </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
      | sql                                | expect  |db      |
      | drop table if exists sharding_2_t1 | success |schema1 |
      | create table sharding_2_t1(id int) | success |schema1 |
    Given record current dble log line number in "log_linenu"
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | expect  | db      |
      | conn_0 | False   | insert into sharding_2_t1 values(1),(2) | success | schema1 |
      | conn_0 | true    | commit                                  | success | schema1 |
    Given execute linux command in "dble-1" and save result in "heartbeat_master1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" |grep "172.100.9.5"| awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given execute linux command in "dble-1" and save result in "heartbeat_master2"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" |grep "172.100.9.6"| awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given execute linux command in "mysql-master1" and save result in "backendIds_master1"
    """
    grep -i "INSERT INTO sharding_2_t1" {node:install_path}/data/mysql-master1.log | awk '{print $2}'
    """
    Given execute linux command in "mysql-master2" and save result in "backendIds_master2"
    """
    grep -i "INSERT INTO sharding_2_t1" {node:install_path}/data/mysql-master2.log | awk '{print $2}'
    """
    Given merge resultset of "heartbeat_master1" and "backendIds_master1" into "ids_to_kill_master1"
    Given merge resultset of "heartbeat_master2" and "backendIds_master2" into "ids_to_kill_master2"
    Then check general log in host "mysql-master1" has not "SET autocommit=0"
    Then check general log in host "mysql-master2" has not "SET autocommit=0"
    Given kill all backend conns in "mysql-master1" except ones in "ids_to_kill_master1"
    Given kill all backend conns in "mysql-master2" except ones in "ids_to_kill_master2"
    Given execute sql in "dble-1" in "user" mode
      | sql                         | expect  | db      |
      | select * from sharding_2_t1 | success | schema1 |
    Then check general log in host "mysql-master1" has not "SET autocommit=1"
    Then check general log in host "mysql-master2" has not "SET autocommit=1"

  @restore_global_setting
  Scenario:dble starts at disabled=true, global vars values are different, then change it to enable by manager command, dble send set global query #9
    """
    {'restore_global_setting':{'mysql-master1':{'general_log':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="true">
        </dbInstance>
    </dbGroup>
    """
    Given stop dble in "dble-1"
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                       | expect  |
      | conn_0 | False   | set global autocommit=0                   | success |
      | conn_0 | True    | set global tx_isolation='READ-COMMITTED'  | success |
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"
    When execute admin cmd "dbGroup @@enable name='ha_group1'" success
    Then check general log in host "mysql-master1" has "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_global_setting
  Scenario:dble starts at disabled=true, global vars values are different, then change it to enable by config and reload, dble send set global query #10
    """
    {'restore_global_setting':{'mysql-master1':{'general_log':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="true">
        </dbInstance>
    </dbGroup>
    """
    Given stop dble in "dble-1"
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                       |
      | conn_0 | False   | set global autocommit=0                   |
      | conn_0 | True    | set global tx_isolation='READ-COMMITTED'  |
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="false">
        </dbInstance>
    </dbGroup>
    """
    When execute admin cmd "reload @@config" success
    Then check general log in host "mysql-master1" has "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_global_setting
  Scenario:dble starts at disabled=true, global vars values are same, then change it to enable by manager command, dble will not send set global query #11
    """
    {'restore_global_setting':{'mysql-master1':{'general_log':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="true">
        </dbInstance>
    </dbGroup>
    """
    Given stop dble in "dble-1"
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"
    When execute admin cmd "dbGroup @@enable name='ha_group1'" success
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_global_setting
  Scenario:dble starts at disabled=true, global vars values are same, then change it to enable by config and reload, dble will not send set global query #12
    """
    {'restore_global_setting':{'mysql-master1':{'general_log':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="true">
        </dbInstance>
    </dbGroup>
    """
    Given stop dble in "dble-1"
    Given turn on general log in "mysql-master1"
    When Start dble in "dble-1"
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='READ-COMMITTED'"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="false">
        </dbInstance>
    </dbGroup>
    """
    When execute admin cmd "reload @@config" success
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"

  @restore_global_setting
  Scenario:dble disabled loop state by false-true-false, global vars values are different at step false-true, dble will not send set global query #13
    """
    {'restore_global_setting':{'mysql-master1':{'general_log':0}}}
    """
    Given turn on general log in "mysql-master1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="true">
        </dbInstance>
    </dbGroup>
    """
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                       |
      | conn_0 | False   | set global autocommit=0                   |
      | conn_0 | True    | set global tx_isolation='READ-COMMITTED'  |
    Given execute admin cmd "dbGroup @@enable name='ha_group1'" success
    Then check general log in host "mysql-master1" has not "SET global autocommit=1,tx_isolation='REPEATABLE-READ'"
@skip
  Scenario: if global var detect query failed at heartbeat restore, the heartbeat restore failed #14
    Given stop mysql in host "mysql-master1"
#    default heartbeatPeriodMillis is 10, 11 makes sure heartbeat failed for mysql-master1
    Given sleep "11" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    heartbeat to \[172.100.9.5:3306\] setError
    """
    Given prepare a thread run btrace script "BtraceSelectGlobalVars1.java" in "dble-1"
#    sleep 2s for wait btrace in working
    Given sleep "2" seconds
    Given prepare a thread run btrace script "BtraceSelectGlobalVars2.java" in "dble-1"
    Given sleep "2" seconds
    Given record current dble log line number in "log_linenu"
    Given start mysql in host "mysql-master1"
#    run into this btrace code means heartbeat of mysql-master1 has recover success then try to send global var detect query and be blocked 3s by btrace
    Then check btrace "BtraceSelectGlobalVars1.java" output in "dble-1"
    """
    get into call
    """
#   dble received feedback of global var detect query, but the connection is still in use state
    Then check btrace "BtraceSelectGlobalVars2.java" output in "dble-1"
    """
    get into fieldEofResponse
    """
    # find backend conns of query "select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation" used in dble.log
    Given execute linux command in "dble-1" and save result in "backendIds"
    """
    tail -n +{context:log_linenu} {node:install_dir}/dble/logs/dble.log | grep -i "select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation" |grep "host=172.100.9.5"| grep -o "mysqlId=[0-9]*"|grep -o "[0-9]*" |sort| uniq
    """
    Given kill mysql conns in "mysql-master1" in "backendIds"
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    heartbeat to \[172.100.9.5:3306\] setError
    """