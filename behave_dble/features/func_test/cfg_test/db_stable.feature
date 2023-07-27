# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/12/7
Feature: db config stable test

#  Background delete default configs not must，reload @@config_all success
#    Given delete the following xml segment
#      | file          | parent           | child                                             |
#      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}                                  |
#      | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}                            |
#      | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}                                 |
#      | user.xml      | {'tag':'root'}   | {'tag':'shardingUser', 'kv_map':{'name':'test'}}  |
#    Then execute admin cmd "reload @@config_all"
#    Given Restart dble in "dble-1" success

  @NORMAL @restore_mysql_service
  Scenario: config contains only 1 stopped mysqld, reload @@config_all fail, start the mysqld, reload @@config_all success #1
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
     Given delete the following xml segment
      | file          | parent           | child                                             |
      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}                                  |
      | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}                            |
      | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}                                 |
      | user.xml      | {'tag':'root'}   | {'tag':'shardingUser', 'kv_map':{'name':'test'}}  |
    Then execute admin cmd "reload @@config_all"
    Given Restart dble in "dble-1" success

    Given stop mysql in host "mysql-master1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
          <globalTable name="test" shardingNode="dn1,dn3" />
      </schema>

      <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select 1</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10" primary="true">
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload Failure.The reason is Can't get variables from any dbInstance, because all of dbGroup can't connect to MySQL correctly
    """
    Given start mysql in host "mysql-master1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test" password="111111" schemas="schema1" readOnly="false"/>
    """
    Then execute admin cmd "reload @@config_all"
    # add sleeptime because Waiting for the recovery of the backend mysql heartbeat
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "user" mode
      | sql      |
      | select 2 |

  @BLOCKER
  Scenario: add mysqld with disabled="true", no dbInstance with primary="false", reload success #2
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn2" sqlMaxLimit="100">
          <globalTable name="test" shardingNode="dn2,dn4" />
      </schema>

      <shardingNode dbGroup="ha_group1" database="db1" name="dn2" />
      <shardingNode dbGroup="ha_group1" database="db2" name="dn4" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10" disabled="true" primary="true">
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"

  @NORMAL
  Scenario: add dbinstance in disabled state, execute select success with rwSplitMode not 0 #3
   Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="10" primary="true">
          </dbInstance>
          <dbInstance name="hosts1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="10">
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | sql      |
      | select 2 |

  @NORMAL
  Scenario: set dbGroup rwSplitMode=0 in case which dbInstance which  primary="false" will not be used, dble should still check whether dbInstance connectable #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn2" sqlMaxLimit="100">
          <globalTable name="test" shardingNode="dn2,dn4" />
      </schema>

      <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="10" primary="true">
          </dbInstance>
          <dbInstance name="hosts1" password="222" url="172.100.9.6:3307" user="test" maxCon="100" minCon="10">
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload Failure.The reason is com.actiontech.dble.config.util.ConfigException: SelfCheck### there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group2.hosts1]}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="10" primary="true">
          </dbInstance>
          <dbInstance name="hosts1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="10" primary="false">
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"


  # DBLE0REQ-2301
  Scenario: all mysql dbGroup disabled=true, add a clickhouse disabled=false, then execute reload/dryrun and restart dble success #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="true">
      </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="true">
      </dbInstance>
    </dbGroup>
    """
    Then restart dble in "dble-1" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <analysisUser name="ana1" password="111111" dbGroup="ha_group4"  />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group4" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM4" password="111111" url="172.100.9.10:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse" disabled="false"/>
    </dbGroup>
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dryrun_rs"
      | sql    |
      | dryrun |
    Then check resultset "dryrun_rs" has lines with following column values
      | TYPE-0  | LEVEL-1 | DETAIL-2                                          |
      | Backend | WARNING | dbGroup[ha_group1,hostM1] is disabled             |
      | Backend | WARNING | dbGroup[ha_group2,hostM2] is disabled             |
      | Meta    | WARNING | Database db2 doesn't exists in dbGroup[ha_group1] |
      | Meta    | WARNING | Database db1 doesn't exists in dbGroup[ha_group2] |
      | Meta    | WARNING | Database db3 doesn't exists in dbGroup[ha_group1] |
      | Meta    | WARNING | Database db2 doesn't exists in dbGroup[ha_group2] |
      | Meta    | WARNING | Database db1 doesn't exists in dbGroup[ha_group1] |
      | Cluster | NOTICE  | Dble is in single mod                             |
    Then check resultset "dryrun_rs" has not lines with following column values
      | TYPE-0  | LEVEL-1 | DETAIL-2                                                              |
      | Backend | ERROR   | Get Vars from backend failed, Maybe all backend MySQL can't connected |
    Then execute admin cmd "reload @@config_all"
    Then restart dble in "dble-1" success


  # DBLE0REQ-2302
  Scenario: mysql dbGroup from disabled=true to disabled=false, then execute reload/dryrun, should test database connection #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="true">
      </dbInstance>
    </dbGroup>
    """
    Then restart dble in "dble-1" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="false">
      </dbInstance>
    </dbGroup>
    """
    Given record current dble log line number in "log_line_num1"
    Then execute admin cmd "dryrun"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num1" in host "dble-1"
    """
    SelfCheck### test dbGroup\[ha_group1.hostM1\],shardingNode\[dn1\],schema\[db1\] database connection success
    SelfCheck### test dbGroup\[ha_group1.hostM1\],shardingNode\[dn3\],schema\[db2\] database connection success
    SelfCheck### test dbGroup\[ha_group1.hostM1\],shardingNode\[dn5\],schema\[db3\] database connection success
    """
    Given record current dble log line number in "log_line_num2"
    Then execute admin cmd "reload @@config_all"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num2" in host "dble-1"
    """
    SelfCheck### test dbGroup\[ha_group1.hostM1\],shardingNode\[dn1\],schema\[db1\] database connection success
    SelfCheck### test dbGroup\[ha_group1.hostM1\],shardingNode\[dn3\],schema\[db2\] database connection success
    SelfCheck### test dbGroup\[ha_group1.hostM1\],shardingNode\[dn5\],schema\[db3\] database connection success
    """