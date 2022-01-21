# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by WuJinling at 2019/3/6
Feature: test "check xml version warning message in dble.log and dryrun"
  # details please refer to github issue #986
  Scenario: check xml version warning  message in dryrun and dble.log when the new dble version uses the old xml version #1
    #Given add xml segment to node with attribute "{'tag':'dble',{"version":"9.9.9.0"}}" in "sharding.xml"
    Given add attribute "{"version":"9.9.9.0"}" to rootnode in "user.xml"
    Given add attribute "{"version":"9.9.9.9"}" to rootnode in "db.xml"
    Then execute admin cmd "reload @@config_all"
    Given sleep "2" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dryrun_rs"
      | sql    |
      | dryrun |
    Then check resultset "dryrun_rs" has lines with following column values
      | TYPE-0 | LEVEL-1 | DETAIL-2                                                                                                                                                    |
      | Xml    | WARNING | The dble-config-version is [0-9].[0-9],but the db.xml version is 9.9.9.9.There must be some incompatible config between two versions, please check it             |
      | Xml    | WARNING | The dble-config-version is [0-9].[0-9],but the user.xml version is 9.9.9.0.There must be some incompatible config between two versions, please check it |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      The dble-config-version is [0-9].[0-9],but the user.xml version is 9.9.9.0.There must be some incompatible config between two versions, please check it
      The dble-config-version is [0-9].[0-9],but the db.xml version is 9.9.9.9.There must be some incompatible config between two versions, please check it
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      The dble-config-version is [0-9].[0-9],but the sharding.xml version
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      version="9.9.9.9"
     """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-2"
      """
      version="9.9.9.0"
     """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      version="9.9.9.9"
     """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-3"
      """
      version="9.9.9.0"
     """
  @current
  Scenario: check xml version warning  message in dryrun and dble.log when the version number：x.y is incorrect #2
    Given add attribute "{"version":"1.0"}" to rootnode in "user.xml"
    Given add attribute "{"version":"1.1"}" to rootnode in "db.xml"
    Then execute admin cmd "reload @@config_all"
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      The dble-config-version is [0-9].[0-9],but the user.xml version is 1.0.There must be some incompatible config between two versions, please check it
      The dble-config-version is [0-9].[0-9],but the db.xml version is 1.1.There must be some incompatible config between two versions, please check it
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      The dble-config-version is [0-9].[0-9],but the sharding.xml version
      """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dryrun_rs"
      | sql    |
      | dryrun |
    Then check resultset "dryrun_rs" has lines with following column values
      | TYPE-0 | LEVEL-1 | DETAIL-2                                                                                                                                                    |
      | Xml    | WARNING | The dble-config-version is [0-9].[0-9],but the db.xml version is 1.1.There must be some incompatible config between two versions, please check it             |
      | Xml    | WARNING | The dble-config-version is [0-9].[0-9],but the user.xml version is 1.0.There must be some incompatible config between two versions, please check it |
    Then stop dble in "dble-1"
    Given sleep "60" seconds
    Then Start dble in "dble-1"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      The dble-config-version is [0-9].[0-9],but the user.xml version is 1.0.There must be some incompatible config between two versions, please check it
      The dble-config-version is [0-9].[0-9],but the db.xml version is 1.1.There must be some incompatible config between two versions, please check it
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      The dble-config-version is [0-9].[0-9],but the sharding.xml version
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
    <heartbeat>select user()</heartbeat>
    <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="2" minCon="1" primary="true">
    </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then check resultset "dryrun_rs" has lines with following column values
      | TYPE-0 | LEVEL-1 | DETAIL-2                                                                                                                                                    |
      | Xml    | WARNING | The dble-config-version is [0-9].[0-9],but the db.xml version is 1.1.There must be some incompatible config between two versions, please check it             |
      | Xml    | WARNING | The dble-config-version is [0-9].[0-9],but the user.xml version is 1.0.There must be some incompatible config between two versions, please check it |
    Given get config xml version from template config and named as "current_version"
    Given add current version from var "current_version" to rootnode in "user.xml"
    Given add current version from var "current_version" to rootnode in "db.xml"
#    in zk cluster, reload @@config_all to sync config to other nodes
    Then execute admin cmd "reload @@config_all"
    Given Restart dble in "dble-1" success
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      The dble-config-version is [0-9]*\.[0-9]*,but the user.xml version is [0-9]*\.[0-9]*.There must be some incompatible config between two versions, please check it
      The dble-config-version is [0-9]*\.[0-9],but the db.xml version is [0-9]*\.[0-9]*.There must be some incompatible config between two versions, please check it
      """
