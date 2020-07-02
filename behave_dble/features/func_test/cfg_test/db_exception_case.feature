# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

Feature: db basic config test

  Scenario: config rwSplitMode with illegal value, reload fail #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="3" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
          </dbInstance>
      </dbGroup>
    """

    Then execute admin cmd "reload @@config_all" get the following output
    """
    dbGroup ha_group1 rwSplitMode should be between 0 and 2!
    """


