# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by lizizi at 2020/7/3
Feature:  config user config files incorrect and restart dble or reload configs

  Scenario:  config user property, restart config #1
    Given update file content "/opt/dble/conf/user.xml" in "dble-1" with sed cmds
    """
    /managerUser/d
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """

  Scenario:  config user property, restart config #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="sharding_test" password="" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" schemas="schema1" maxCon="0" blacklist="blacklist1"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      password of sharding_test is empty
    """

  Scenario:  config user property, restart config #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="sharding_test" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" schemas="schema1" maxCon="0" blacklist="blacklist1"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      Attribute "password" is required and must be specified for element type "shardingUser"
    """

  Scenario:  config user property, restart config #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="sharding_test" password="111111" usingDecrypt="true" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" schemas="schema1" maxCon="0" blacklist="blacklist1"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      user sharding_test password need to decrypt ,but failed
    """

  Scenario:  config user property, restart config #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="sharding_test" password="111111" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" schemas="" maxCon="0" blacklist="blacklist1"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      User [sharding_test:tenant1]'s schemas is empty
    """

  Scenario:  config user property, restart config #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="sharding_test" password="111111" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" maxCon="0" blacklist="blacklist1"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      Attribute "schemas" is required and must be specified for element type "shardingUser"
    """

  Scenario:  config user property, login the system #7
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <managerUser name="root_test" password="111111" usingDecrypt="false" whiteIPs="172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" maxCon="0"/>
      <shardingUser name="sharding_test" password="111111" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" schemas="schema1" maxCon="0" blacklist="blacklist1"/>
      <rwSplitUser name="rwSplit" password="111111" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" dbGroup="ha_group1" tenant="tenant1" maxCon="20" blacklist="blacklist1"/>
      <blacklist name="blacklist1">
        <property name="variantCheck">true</property>
      </blacklist>
    """
    Given add xml segment to node with attribute "{'tag':'shardingUser','kv_map':{'name':'sharding_test'}}" in "user.xml"
    """
      <privileges check="true">
        <schema name="TESTDB" dml="0110">
            <table name="tb01" dml="0000"/>
            <table name="tb02" dml="1111"/>
        </schema>
      </privileges>
    """
    Then execute admin cmd "reload @@config_all"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user          | passwd | conn   | toClose | sql      | expect                                                       | db      |
      | test          | 11111  | conn_1 | False   | select 1 | Access denied for user 'test', because password is incorrect | schema1 |
      | root          | 111111 | conn_2 | False   | select 1 | Access denied for manager user 'root'                        | schema1 |
      | test          | 111111 | new_1  | False   | select 1 | Unknown database 'SCHEMA1'                                   | SCHEMA1 |

    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql      | expect                        |
      | test | 111111 | conn_3 | False   | select 1 | Access denied for user 'test' |
#    Then execute sql in "dble-2" in "user" mode
#      | user          | passwd | conn   | toClose | sql      | expect                        |
#      | sharding_test | 111111 | conn_4 | False   | select 1 | Access denied for user 'test' |

  Scenario: config db property, login the system #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10" primary="true">
          </dbInstance>
          <dbInstance name="hosts1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10" primary="false">
          </dbInstance>
      </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="sharding_test" password="111111" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" schemas="schema1" maxCon="0" blacklist="blacklist1"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql      | expect                    | db     |
      | test | 111111 | conn_5 | False   | select 1 | Unknown database 'hosts1' | hosts1 |

  Scenario:  config user property, login the system #9
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml" with duplicate name
    """
      <managerUser name="root_test1" password="111111" usingDecrypt="false" whiteIPs="172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" maxCon="0"/>
      <managerUser name="root_test1" password="222222" usingDecrypt="false" whiteIPs="172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      User [name:root_test1] has already existed
    """

  Scenario:  config user property, login the system #10
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml" with duplicate name
    """
      <shardingUser name="sharding_test1" password="111111" schemas="schema1" maxCon="0"/>
      <shardingUser name="sharding_test1" password="222222" schemas="schema1" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      User [sharding_test1] has already existed
    """

  Scenario:  config user property, login the system #11
    Given add xml segment to node with attribute "{'tag':'root', 'prev':'rwSplitUser'}" in "user.xml" with duplicate name
    """
      <blacklist name="blacklist1">
        <property name="selectHavingAlwayTrueCheck">true</property>
      </blacklist>
      <blacklist name="blacklist1">
        <property name="selectWhereAlwayTrueCheck">true</property>
      </blacklist>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      blacklist[blacklist1]  has already existed
    """

  Scenario:  config user property, login the system #12
    Given add xml segment to node with attribute "{'tag':'root', 'prev':'rwSplitUser'}" in "user.xml" with duplicate name
    """
      <blacklist name="blacklist1">
        <property name="selectHavingAlwayTrueCheck_fake">true</property>
      </blacklist>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      blacklist item(s) is not recognized: selectHavingAlwayTrueCheck_fake
    """