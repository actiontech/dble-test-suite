# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: sharding basic config test

  @TRIVIAL
  Scenario: config with er table and extra no use shardingNode, reload success #1
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
      <shardingTable name="test_table" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" >
          <childTable name="child_table" joinColumn="id" parentColumn="id" />
      </shardingTable>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <shardingNode dbGroup="ha_group2" database="db3" name="testdn" />
    """
    Then execute admin cmd "reload @@config_all"

  @TRIVIAL
  Scenario: config with no shardingUser in user.xml, expect reload success #2
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
      |user.xml      |{'tag':'root'}   | {'tag':'shardingUser'}  |
    Then Restart dble in "dble-1" success
    #user.xml no shardingUser,  dble starts success
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10" primary="true">
          </dbInstance>
      </dbGroup>
    """
    Then Restart dble in "dble-1" success

  @TRIVIAL
  Scenario: when config file contains illegal label<test/>, reload fail #3
    Given add xml segment to node with attribute "{'tag':'root','prev': 'dbGroup'}" in "db.xml"
    """
        <test>
        </test>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """
  @NORMAL
  Scenario: config <shardingNode> with "$" preseting range, reload success #4
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
     <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2"/>
     </schema>
     <shardingNode dbGroup="ha_group1" database="db$1-2" name="dn$1-2"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
            <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10" primary="true">
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "Reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                       | db      |
      | conn_0 | False    | drop table if exists test | schema1 |
      | conn_0 | True     | create table test(id int) | schema1 |

  @TRIVIAL
  Scenario: config dbGroup xml node closed with none abbr mode, expect reload success, but fail at present #5
    Given add xml segment to node with attribute "{'tag':'root','kv_map':{'name':'ha_group2'}}" in "db.xml"
     """
        <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10"/>
    """
    #todo: reload should success
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """
  @TRIVIAL
  Scenario:.when <read dbInstance > put outside <wirte dbInstance>, reload fail #6
    Given add xml segment to node with attribute "{'tag':'root','kv_map':{'name':'ha_group2'}}" in "db.xml"
     """
        <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """
  @NORMAL
  Scenario: config table sharding rule not defined in sharding.xml, reload fail #7
    Given add xml segment to node with attribute "{'tag':'schema'}" in "sharding.xml"
    """
    <shardingTable name="test" shardingNode="dn1,dn2" function="sharding-test" shardingColumn="id" />
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """

  @TRIVIAL
  Scenario:github issue 598-636,dbGroup configed for shardingNode is not created and the shardingNode is not used by any table #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn5" sqlMaxLimit="100">
          <shardingTable name="test" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
      </schema>
      <shardingNode dbGroup="ha_group1" database="da1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="da1" name="dn2" />
      <shardingNode dbGroup="ha_group1" database="da2" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="da2" name="dn4" />
      <shardingNode dbGroup="ha_group1" database="da3" name="dn5" />
    """
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                         |
      | conn_0 | False    | drop database if exists da1 |
      | conn_0 | False    | drop database if exists da2 |
      | conn_0 | True     | drop database if exists da3 |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         |
      | conn_0 | False    | drop database if exists da1 |
      | conn_0 | True     | drop database if exists da2 |
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql            | expect  |
      | show @@version | success |
    Then execute sql in "dble-1" in "user" mode
      | sql                                                      | expect            | db      |
      | create table if not exists test(id int,name varchar(20)) | Unknown database  | schema1 |

  @NORMAL
  Scenario: database configed for shardingNode is not created and the shardingNode is used by table #9
     Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
     Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
        <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
            <globalTable name="test" shardingNode="dn1,dn3" />
        </schema>
        <shardingNode dbGroup="ha_group1" database="da1" name="dn1" />
        <shardingNode dbGroup="ha_group1" database="da2" name="dn3" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="10" primary="true">
          </dbInstance>
      </dbGroup>
      """
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                         |
      | conn_0 | False   | drop database if exists da1 |
      | conn_0 | True    | drop database if exists da2 |
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | sql            | expect  | db     |
      | show @@version | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | sql                                                      | expect            | db      |
      | create table if not exists test(id int,name varchar(20)) | Unknown database  | schema1 |

  Scenario: Multiple shardingNodes use the same database of the same dbGroup #10
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db1" name="dn5" />
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                 | expect                                                          |
      | conn_0 | False   | dryrun              | shardingNode dn5 use the same dbGroup&database with other shardingNode |
      | conn_0 | True    | reload @@config_all | shardingNode dn5 use the same dbGroup&database with other shardingNode |
    Then restart dble in "dble-1" failed for
    """
    shardingNode dn5 use the same dbGroup&database with other shardingNode
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
	Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                 | expect  |
      | conn_0 | False   | dryrun              | success |
      | conn_0 | True    | reload @@config_all | success |
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <schema name="schema1" shardingNode="dn-5" sqlMaxLimit="100">
            <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
            <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        </schema>

        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
        <shardingNode dbGroup="ha_group1" database="db1" name="dn-5" />
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                 | expect                                                           |
      | conn_0 | False   | dryrun              | shardingNode dn-5 use the same dbGroup&database with other shardingNode |
      | conn_0 | True    | reload @@config_all | shardingNode dn-5 use the same dbGroup&database with other shardingNode |
    Then restart dble in "dble-1" failed for
    """
    shardingNode dn-5 use the same dbGroup&database with other shardingNode
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db3" name="dn-5" />
    """
    Given Restart dble in "dble-1" success
    Given delete the following xml segment
      |file        | parent           | child              |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn_5" sqlMaxLimit="100">
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
          <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>

      <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
      <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
      <shardingNode dbGroup="ha_group1" database="db1" name="dn_5" />
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                 | expect                                                           |
      | conn_0 | False   | dryrun              | shardingNode dn_5 use the same dbGroup&database with other shardingNode |
      | conn_0 | True    | reload @@config_all | shardingNode dn_5 use the same dbGroup&database with other shardingNode |
    Then restart dble in "dble-1" failed for
    """
    shardingNode dn_5 use the same dbGroup&database with other shardingNode
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db3" name="dn_5" />
    """
    Given Restart dble in "dble-1" success
    Given delete the following xml segment
      |file        | parent           | child              |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn_5" sqlMaxLimit="100">
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
          <shardingTable name="sharding_4_t1" shardingNode="dn$1-4" function="hash-four" shardingColumn="id"/>
      </schema>

      <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db$1-1" name="dn2" />
      <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db$1-1" name="dn4" />
      <shardingNode dbGroup="ha_group1" database="db3" name="dn_5" />
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                 | expect                                                          |
      | conn_0 | False   | dryrun              | shardingNode dn4 use the same dbGroup&database with other shardingNode |
      | conn_0 | True    | reload @@config_all | shardingNode dn4 use the same dbGroup&database with other shardingNode |
    Then restart dble in "dble-1" failed for
    """
    shardingNode dn4 use the same dbGroup&database with other shardingNode
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    """
    Given Restart dble in "dble-1" success

  Scenario: Special characters:'-' in the name of schema and special characters:'.' in the name of database #11
    Given delete the following xml segment
      |file        | parent          | child              |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}   |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
      <schema name="schema-1" shardingNode="dn5" sqlMaxLimit="100">
          <globalTable name="test-1" shardingNode="dn1,dn2,dn3,dn4" />
          <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>

      <shardingNode dbGroup="ha_group1" database="db_1.1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db$1-1" name="dn2" />
      <shardingNode dbGroup="ha_group1" database="db.2" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db.2" name="dn4" />
      <shardingNode dbGroup="ha_group1" database="db.3_3" name="dn5" />
     """
     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
     """
     <shardingUser name="test" password="111111" schemas="schema-1" readOnly="false"/>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | sql                                 | expect  |
      | create database @@shardingNode='dn$1-5' | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect      | db       |
      | conn_0 | False   | drop table if exists `test-1`                         | success     | schema-1 |
      | conn_0 | False   | create table `test-1`(id int)                         | success     | schema-1 |
      | conn_0 | False   | insert into `test-1`(id) values(1),(2),(3),(4)        | success     | schema-1 |
      | conn_0 | False   | select * from `test-1`                                | length{(4)} | schema-1 |
      | conn_0 | False   | drop table if exists `sharding_4_t1`                  | success     | schema-1 |
      | conn_0 | False   | create table `sharding_4_t1`(id int)                  | success     | schema-1 |
      | conn_0 | False   | insert into `sharding_4_t1`(id) values(1),(2),(3),(4) | success     | schema-1 |
      | conn_0 | False   | select * from `sharding_4_t1`                         | length{(4)} | schema-1 |
      | conn_0 | False   | show columns from `schema-1`.`test-1`                 | success     | schema-1 |
      | conn_0 | False   | show index from `schema-1`.`test-1`                   | success     | schema-1 |
      | conn_0 | False   | show full tables from `schema-1`                      | success     | schema-1 |
      | conn_0 | True    | show table status from `schema-1`                     | success     | schema-1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                              |
      | conn_0 | False   | kill @@ddl_lock where schema='schema-1' and table='test-1'       |
      | conn_0 | False   | check full @@metadata where schema='schema-1' and table='test-1' |
      | conn_0 | False   | reload @@metadata where schema='schema-1' and table='test-1'     |
      | conn_0 | False   | reload @@metadata where table in ('schema-1.test-1')             |
      | conn_0 | False   | show @@Algorithm where schema='schema-1' and table='test-1'      |
      | conn_0 | True    | show @@shardingNode where schema='schema-1' and table='test-1'      |


