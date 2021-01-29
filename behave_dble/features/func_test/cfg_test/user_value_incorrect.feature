# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by lizizi at 2020/7/3
Feature:  config user config files incorrect and restart dble or reload configs

  Scenario:  config without managerUser, reload failed #1
    Given update file content "/opt/dble/conf/user.xml" in "dble-1" with sed cmds
    """
    /managerUser/d
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """

  Scenario:  config empty password, reload failed #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="sharding_test" password="" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" schemas="schema1" maxCon="0" blacklist="blacklist1"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      password of sharding_test is empty
    """

  Scenario:  config without password property, reload failed #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="sharding_test" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" schemas="schema1" maxCon="0" blacklist="blacklist1"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      Attribute 'password' must appear on element 'shardingUser'
    """

  Scenario:  usingDecrypt="true",config password with plaintext, reload failed #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="sharding_test" password="111111" usingDecrypt="true" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" schemas="schema1" maxCon="0" blacklist="blacklist1"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      user sharding_test password need to decrypt ,but failed
    """

  Scenario:  config empty schemas, reload failed #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="sharding_test" password="111111" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" schemas="" maxCon="0" blacklist="blacklist1"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      User [sharding_test:tenant1]'s schemas is empty
    """

  Scenario:  config shardingUser without schemas property, reload failed #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <shardingUser name="sharding_test" password="111111" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" maxCon="0" blacklist="blacklist1"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      Attribute 'schemas' must appear on element 'shardingUser'
    """
    
  Scenario:  config case sensitive, check privileges #7
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <managerUser name="root_test" password="111111" usingDecrypt="false" whiteIPs="172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" maxCon="0"/>
      <shardingUser name="sharding_test" password="111111" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" schemas="schema1" maxCon="0" blacklist="blacklist1"/>
      <blacklist name="blacklist1">
        <property name="variantCheck">true</property>
      </blacklist>
    """
    Given add xml segment to node with attribute "{'tag':'shardingUser','kv_map':{'name':'sharding_test'}}" in "user.xml"
    """
      <privileges check="true">
        <schema name="SCHEMA1" dml="0110">
            <table name="tb01" dml="0000"/>
            <table name="tb02" dml="1111"/>
        </schema>
      </privileges>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      privileges's schema[SCHEMA1] was not found in the user [name:sharding_test,tenant:tenant1]'s schemas
    """

    Given add xml segment to node with attribute "{'tag':'shardingUser','kv_map':{'name':'sharding_test'}}" in "user.xml"
    """
      <privileges check="true">
        <schema name="schema1" dml="0110">
            <table name="tb01" dml="0000"/>
            <table name="tb02" dml="1111"/>
        </schema>
      </privileges>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user          | passwd | conn   | toClose | sql      | expect                                                       | db      |
      | test          | 11111  | conn_1 | False   | select 1 | Access denied for user 'test', because password is incorrect | schema1 |
      | test          |        | conn_4 | False   | select 1 | Access denied for user 'test', because password is incorrect | schema1 |
      | root          | 111111 | conn_2 | False   | select 1 | Access denied for manager user 'root'                        | schema1 |
      | test          | 111111 | new_1  | False   | select 1 | Unknown database 'SCHEMA1'                                   | SCHEMA1 |

    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql      | expect                        |
      | test | 111111 | conn_3 | False   | select 1 | Access denied for user 'test' |

  Scenario: config db with same url value for different dbInstances in one dbGroup, reload success #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10" primary="true">
          </dbInstance>
          <dbInstance name="hosts1" password="111111" url="172.100.9.2:3306" user="test" maxCon="100" minCon="10" primary="false">
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

  Scenario:  config two managerUsers with the same name, reload failed #9
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml" with duplicate name
    """
      <managerUser name="root_test1" password="111111" usingDecrypt="false" whiteIPs="172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" maxCon="0"/>
      <managerUser name="root_test1" password="222222" usingDecrypt="false" whiteIPs="172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      User [name:root_test1] has already existed
    """

  Scenario:  config two shardingUsers with the same name, reload failed #10
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml" with duplicate name
    """
      <shardingUser name="sharding_test1" password="111111" schemas="schema1" maxCon="0"/>
      <shardingUser name="sharding_test1" password="222222" schemas="schema1" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      User [sharding_test1] has already existed
    """

  Scenario:  config two blacklists with the same name, reload failed #11
    Given add xml segment to node with attribute "{'tag':'root', 'prev':'shardingUser'}" in "user.xml" with duplicate name
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

  Scenario:  config wrong blacklist property, reload failed #12
    Given add xml segment to node with attribute "{'tag':'root', 'prev':'shardingUser'}" in "user.xml" with duplicate name
    """
      <blacklist name="blacklist1">
        <property name="selectHavingAlwayTrueCheck_fake">true</property>
      </blacklist>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      blacklist item(s) is not recognized: selectHavingAlwayTrueCheck_fake
    """

  Scenario:  config schema which not exists in sharding.xml , reload failed #13
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml" with duplicate name
    """
      <shardingUser name="sharding_test1" password="111111" schemas="schema2" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      User[name:sharding_test1]'s schema [schema2] is not exist
    """