# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by chenhuiming at 2020/7/2

Feature: db basic config test

  Scenario: config rwSplitMode with illegal value, reload fail #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="4" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
          </dbInstance>
      </dbGroup>
    """

    Then execute admin cmd "reload @@config_all" get the following output
    """
    dbGroup ha_group1 rwSplitMode should be between 0 and 3!
    """



  Scenario: config dbInstance-property with illegal value, reload and restart fail # DBLE0REQ-920  #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="11" minCon="5" primary="true" readWeight="1"  id="xx1">
             <property name="testOnCreate">-1</property>
             <property name="testOnBorrow">4</property>
             <property name="testOnReturn">string</property>
             <property name="testWhileIdle"></property>
             <property name="connectionTimeout">abc</property>
             <property name="connectionHeartbeatTimeout"> </property>
             <property name="timeBetweenEvictionRunsMillis">30000ms</property>
             <property name="evictorShutdownTimeoutMillis">20000min</property>
             <property name="idleTimeout">1h</property>
             <property name="heartbeatPeriodMillis">2.88</property>
        </dbInstance>
       </dbGroup>
      """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      Reload config failure
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ connectionHeartbeatTimeout \] '' data type should be long
      property \[ connectionTimeout \] 'abc' data type should be long
      property \[ evictorShutdownTimeoutMillis \] '20000min' data type should be long
      property \[ heartbeatPeriodMillis \] '2.88' data type should be long
      property \[ idleTimeout \] '1h' data type should be long
      property \[ testOnBorrow \] '4' data type should be boolean
      property \[ testOnCreate \] '-1' data type should be boolean
      property \[ testOnReturn \] 'string' data type should be boolean
      property \[ testWhileIdle \] '' data type should be boolean
      property \[ timeBetweenEvictionRunsMillis \] '30000ms' data type should be long
      """
