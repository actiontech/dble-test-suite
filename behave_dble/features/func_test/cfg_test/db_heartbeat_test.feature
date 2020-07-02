# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

Feature: db heartbeat test

  @skip_restart @test999
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
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"

