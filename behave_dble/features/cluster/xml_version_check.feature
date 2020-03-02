# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by WuJinling at 2019/3/6
Feature: test "check xml version warning message in dble.log and dryrun"
  # details please refer to github issue #986
  Scenario: check xml version warning  message in dryrun and dble.log when the new dble version uses the old xml version #1
    #Given add xml segment to node with attribute "{'tag':'dble',{"version":"9.9.9.0"}}" in "server.xml"
    Given add attribute "{"version":"9.9.9.0"}" to rootnode in "server.xml"
    Given add attribute "{"version":"9.9.9.9"}" to rootnode in "rule.xml"
    Then execute admin cmd "reload @@config_all"
    Given sleep "2" seconds
    Then get resultset of admin cmd "dryrun" named "dryrun_rs"
    Then check resultset "dryrun_rs" has lines with following column values
      | TYPE-0 | LEVEL-1 | DETAIL-2                                                                                                                                                    |
      | Xml    | NOTICE | The dble-config-version is [0-9].[0-9],but the rule.xml version is 9.9.9.9.There must be some incompatible config between two versions, please check it             |
      | Xml    | NOTICE | The dble-config-version is [0-9].[0-9],but the server.xml version is 9.9.9.0.There must be some incompatible config between two versions, please check it |
    Then check following " " exist in file "/opt/dble/logs/dble.log" in "dble-1"
      """
      The dble-config-version is [0-9].[0-9],but the server.xml version is 9.9.9.0.There must be some incompatible config between two versions, please check it
      The dble-config-version is [0-9].[0-9],but the rule.xml version is 9.9.9.9.There must be some incompatible config between two versions, please check it
      """
    Then check following "not" exist in file "/opt/dble/logs/dble.log" in "dble-1"
      """
      The dble-config-version is [0-9].[0-9],but the schema.xml version
      """
    Then check following " " exist in file "/opt/dble/conf/rule.xml" in "dble-2"
      """
      version="9.9.9.9"
     """
    Then check following " " exist in file "/opt/dble/conf/server.xml" in "dble-2"
      """
      version="9.9.9.0"
     """
    Then check following " " exist in file "/opt/dble/conf/rule.xml" in "dble-3"
      """
      version="9.9.9.9"
     """
    Then check following " " exist in file "/opt/dble/conf/server.xml" in "dble-3"
      """
      version="9.9.9.0"
     """
  @current
  Scenario: check xml version warning  message in dryrun and dble.log when the version number：x.y is incorrect #2
    Given add attribute "{"version":"1.0"}" to rootnode in "server.xml"
    Given add attribute "{"version":"1.1"}" to rootnode in "rule.xml"
    Then execute admin cmd "reload @@config_all"
    Given sleep "2" seconds
    Then check following " " exist in file "/opt/dble/logs/dble.log" in "dble-1"
      """
      The dble-config-version is [0-9].[0-9],but the server.xml version is 1.0.There must be some incompatible config between two versions, please check it
      The dble-config-version is [0-9].[0-9],but the rule.xml version is 1.1.There must be some incompatible config between two versions, please check it
      """
    Then check following "not" exist in file "/opt/dble/logs/dble.log" in "dble-1"
      """
      The dble-config-version is [0-9].[0-9],but the schema.xml version
      """
    Then get resultset of admin cmd "dryrun" named "dryrun_rs"
    Then check resultset "dryrun_rs" has lines with following column values
      | TYPE-0 | LEVEL-1 | DETAIL-2                                                                                                                                                    |
      | Xml    | NOTICE | The dble-config-version is [0-9].[0-9],but the rule.xml version is 1.1.There must be some incompatible config between two versions, please check it             |
      | Xml    | NOTICE | The dble-config-version is [0-9].[0-9],but the server.xml version is 1.0.There must be some incompatible config between two versions, please check it |
    Then stop dble in "dble-1"
    Given sleep "60" seconds
    Then Start dble in "dble-1"
    Then check following " " exist in file "/opt/dble/logs/dble.log" in "dble-1"
      """
      The dble-config-version is [0-9].[0-9],but the server.xml version is 1.0.There must be some incompatible config between two versions, please check it
      The dble-config-version is [0-9].[0-9],but the rule.xml version is 1.1.There must be some incompatible config between two versions, please check it
      """
    Then check following "not" exist in file "/opt/dble/logs/dble.log" in "dble-1"
      """
      The dble-config-version is [0-9].[0-9],but the schema.xml version
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="2" minCon="1" name="ha_group1" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
    </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then check resultset "dryrun_rs" has lines with following column values
      | TYPE-0 | LEVEL-1 | DETAIL-2                                                                                                                                                    |
      | Xml    | NOTICE | The dble-config-version is [0-9].[0-9],but the rule.xml version is 1.1.There must be some incompatible config between two versions, please check it             |
      | Xml    | NOTICE | The dble-config-version is [0-9].[0-9],but the server.xml version is 1.0.There must be some incompatible config between two versions, please check it |
    Given get config xml version from template config and named as "current_version"
    Given add current version from var "current_version" to rootnode in "server.xml"
    Given add current version from var "current_version" to rootnode in "rule.xml"
    Then execute admin cmd "reload @@config_all"
    Given Restart dble in "dble-1" success
    Then check following "not" exist in file "/opt/dble/logs/dble.log" in "dble-1"
      """
      The dble-config-version is [0-9]*\.[0-9]*,but the server.xml version is [0-9]*\.[0-9]*.There must be some incompatible config between two versions, please check it
      The dble-config-version is [0-9]*\.[0-9],but the rule.xml version is [0-9]*\.[0-9]*.There must be some incompatible config between two versions, please check it
      """
