# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by lizizi at 2020/7/7
Feature: config db config files incorrect and restart dble or reload configs

  Scenario: config db property, reload the configs #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml" with duplicate name
    """
     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="hostM4" password="111111" url="172.100.9.2:3307" user="test" maxCon="1000" minCon="10" primary="true"/>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      dbGroup[ha_group3] has multi primary instance
    """

  Scenario: config db property, reload the configs #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml" with duplicate name
    """
     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" primary="false"/>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      dbGroup[ha_group3] has no primary instance
    """

  Scenario: config db property, reload the configs #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml" with duplicate name
    """
     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="h~ost@M3" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" primary="true"/>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      'h~ost@M3' is not a valid value for 'NMTOKEN'
    """

  Scenario: config db property, reload the configs #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml" with duplicate name
    """
     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="" user="test" maxCon="1000" minCon="10" primary="true"/>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      dbGroup ha_group3 define error,some attributes of this element is empty: hostM3
    """

  Scenario: config db property, reload the configs #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml" with duplicate name
    """
     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      Attribute 'url' must appear on element 'dbInstance'
    """

  Scenario: config db property, reload the configs #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="0">select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3307" user="test" usingDecrypt="false" maxCon="1000" minCon="10" readWeight="0" primary="true" disabled="false">
          <property name="evictorShutdownTimeoutMillis_fake">10L * 1000L</property>
        </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      These properties of system are not recognized: evictorShutdownTimeoutMillis_fake
    """

  Scenario: config db property, reload the configs #7
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml" with duplicate name
    """
     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      The content of element 'dbGroup' is not complete. One of '{dbInstance}' is expected
    """


  @test-no-dbgroup
  Scenario: config db property, reload the configs #8
    ####  dmp initialization config
    Given update file content "/opt/dble/conf/db.xml" in "dble-1" with sed cmds
      """
      4,14d
      """
    Given update file content "/opt/dble/conf/sharding.xml" in "dble-1" with sed cmds
      """
      4,14d
      """
    Then execute admin cmd "reload @@config_all"
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test', because there are some empty dbGroup/fake dbInstance"
    """
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "select version()"
    """
    Then restart dble in "dble-1" failed for
      """
      User\[name:test\]'s schema \[schema1\] is not exist
      """
    Given update file content "/opt/dble/conf/user.xml" in "dble-1" with sed cmds
      """
      5d
      """
    Given Restart dble in "dble-1" success



  Scenario: dbInstance's url duplicate in one dbGroup, reload the configs #9
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" primary="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      dbGroup[ha_group2]'s child url [172.100.9.6:3307]  duplicated!
      """


  Scenario: dbInstance's has non-exist parameters, reload the configs #10
     #dble-9114
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" switchType="1" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" primary="true" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      Attribute 'switchType' is not allowed to appear in element 'dbGroup'
      """

  @TRIVIAL @skip
  Scenario: dbInstance's  add databasetype  #11
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.5:3307" user="test" maxCon="1000" minCon="10" primary="true" databaseType="mysql"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "show @@version"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                    | expect                 | db      |
      | conn_0  | False    | drop table if exists test_table        | success                | schema1 |
      | conn_0  | False    | select 1                               | success                | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databasetype="clickhouse"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      Attribute 'databasetype' is not allowed to appear in element 'dbInstance'
      """

  @TRIVIAL
  Scenario: shardingNodeDbGroup with dbInstance database type must be MYSQL #12
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3007" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse"/>
      </dbGroup>
      """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      shardingNodeDbGroup [ha_group2] define error ,all dbInstance database type must be MYSQL
      """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3007" user="test" maxCon="1000" minCon="10" primary="true"/>
          <dbInstance name="hostS1" password="111111" url="172.100.9.2:3007" user="test" maxCon="1000" minCon="10" primary="false" databaseType="clickhouse"/>
      </dbGroup>
      """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      The reason is dbGroup[ha_group2]'s child database type must be consistent
      """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3007" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse"/>
          <dbInstance name="hostS1" password="111111" url="172.100.9.2:3007" user="test" maxCon="1000" minCon="10" primary="false" />
      </dbGroup>
      """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      The reason is dbGroup[ha_group2]'s child database type must be consistent
      """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3007" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse"/>
          <dbInstance name="hostS1" password="111111" url="172.100.9.2:3007" user="test" maxCon="1000" minCon="10" primary="false" databaseType="clickhouse"/>
      </dbGroup>
      """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      shardingNodeDbGroup [ha_group2] define error ,all dbInstance database type must be MYSQL
      """

  @TRIVIAL
  Scenario: rwSplitUser with dbInstance database type must be MYSQL #13
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3307" user="test" maxCon="100" minCon="10" primary="true" databaseType="mysql"/>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config"

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3307" user="test" maxCon="100" minCon="10" primary="true" databaseType="clickhouse"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      The reason is The group[rwS1.ha_group3] all dbInstance database type must be MYSQL
      """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3307" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3307" user="test" maxCon="100" minCon="10" primary="false" databaseType="clickhouse"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      The reason is dbGroup[ha_group3]'s child database type must be consistent
      """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3307" user="test" maxCon="100" minCon="10" primary="true" databaseType="clickhouse"/>
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3307" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      The reason is dbGroup[ha_group3]'s child database type must be consistent
      """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3307" user="test" maxCon="100" minCon="10" primary="true" databaseType="clickhouse"/>
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3307" user="test" maxCon="100" minCon="10" primary="false" databaseType="clickhouse"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      The reason is The group[rwS1.ha_group3] all dbInstance database type must be MYSQL
      """

  @TRIVIAL @skip
  Scenario: analysisUser with dbInstance database type must be CLICKHOUSE #14
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group3" delayThreshold="100" >
        <heartbeat>select 1</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.13:9004" user="test" maxCon="100" minCon="10" primary="true" databaseType="clickhouse"/>
        <dbInstance name="hostS1" password="111111" url="172.100.9.14:9004" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <analysisUser name="ana1" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"
    """
    Reload config failure.The reason is dbGroup[ha_group3]'s child database type must be consistent
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group3" delayThreshold="100" >
        <heartbeat>select 1</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.13:9004" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.14:9004" user="test" maxCon="100" minCon="10" primary="false" databaseType="clickhouse"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    Reload config failure.The reason is dbGroup[ha_group3]'s child database type must be consistent
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group3" delayThreshold="100" >
        <heartbeat>select 1</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.13:9004" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.14:9004" user="test" maxCon="100" minCon="10" primary="false" databaseType="mysql"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    Reload config failure.The reason is The group[ana1.ha_group3] all dbInstance database type must be CLICKHOUSE
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group3" delayThreshold="100" >
        <heartbeat>select 1</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.13:9004" user="test" maxCon="100" minCon="10" primary="true" databaseType="clickhouse"/>
        <dbInstance name="hostS1" password="111111" url="172.100.9.14:9004" user="test" maxCon="100" minCon="10" primary="false" databaseType="clickhouse"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"


