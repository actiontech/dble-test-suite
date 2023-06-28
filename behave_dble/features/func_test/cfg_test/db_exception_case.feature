# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by chenhuiming at 2020/7/2

Feature: db basic config test

  Scenario: config balance with illegal value, reload fail #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <dataHost balance="4" name="ha_group1" slaveThreshold="100" maxCon="1000" minCon="10" >
          <heartbeat>select user()</heartbeat>
          <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
          </writeHost>
      </dataHost>
    """

    Then execute admin cmd "reload @@config_all" get the following output
    """
    dbGroup ha_group1 balance should be between 0 and 2
    """