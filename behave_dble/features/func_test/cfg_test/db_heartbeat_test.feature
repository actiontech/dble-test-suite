# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by chenhuiming at 2020/7/2

Feature: db heartbeat test

  Scenario: config db with isShowSlaveSql and isSelectReadOnlySql heartbeat, reload success #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select @@read_only</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
          </dbInstance>
      </dbGroup>

      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>show slave status</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
          </dbInstance>
          <dbInstance name="hosts1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="false">
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then Restart dble in "dble-1" success

  Scenario: config errorRetryCount with illegal value, reload fail #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat errorRetryCount="-1" timeout="10">select @@read_only</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    dbGroup ha_group1 errorRetryCount should be greater than 0!
    """
