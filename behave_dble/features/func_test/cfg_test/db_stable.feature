# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.# Created by zhaohongjie at 2018/12/7
Feature: db config stable test

  Background delete default configs not must，reload @@config_all success
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
      |user.xml  |{'tag':'root'}   | {'tag':'shardingUser', 'kv_map':{'name':'test'}}  |
    Then execute admin cmd "reload @@config_all"
    Given Restart dble in "dble-1" success

  @NORMAL @restore_mysql_service
  Scenario: config contains only 1 stopped mysqld, reload @@config_all fail, start the mysqld, reload @@config_all success #1
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
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
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10" primary="true">
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """
    Given start mysql in host "mysql-master1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <shardingUser name="test" password="111111" schemas="schema1" readOnly="false"/>
    """
    Then execute admin cmd "reload @@config_all"
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
  Scenario: add instance in disabled state, execute select success with rwSplitMode not 0 #3
   Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10" primary="true">
          </dbInstance>
          <dbInstance name="hosts1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10">
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
          <dbInstance name="hosts1" password="222" url="172.100.9.2:3306" user="test" maxCon="100" minCon="10">
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="10" primary="true">
          </dbInstance>
          <dbInstance name="hosts1" password="111111" url="172.100.9.2:3306" user="test" maxCon="100" minCon="10" primary="false">
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"