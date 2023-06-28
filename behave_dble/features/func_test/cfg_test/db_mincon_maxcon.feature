# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/7/7


Feature: check minCon and maxCon in schema.xml DBLE0REQ-1246

  Scenario: minCon < maxCon and minCon > numOfShardingNodes #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="100" minCon="20">
        <heartbeat>select user()</heartbeat>
        <writeHost name="hostM2" password="111111" url="172.100.9.6:3306" user="test"/>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql                         |
      | show @@connection_pool      |
    Then check resultset "A" has lines with following column values
      | DB_GROUP-0 | DB_INSTANCE-1 | PROPERTY-2 | VALUE-3 |
      | ha_group1  | hostM1        | minCon     | 10      |
      | ha_group1  | hostM1        | maxCon     | 1000    |
      | ha_group2  | hostM2        | minCon     | 20      |
      | ha_group2  | hostM2        | maxCon     | 100     |

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="10" minCon="10">
        <heartbeat>select user()</heartbeat>
        <writeHost name="hostM2" password="111111" url="172.100.9.6:3306" user="test" />
    </dataHost>
    """
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A1"
      | sql                         |
      | show @@connection_pool      |
    Then check resultset "A1" has lines with following column values
      | DB_GROUP-0 | DB_INSTANCE-1 | PROPERTY-2 | VALUE-3 |
      | ha_group1  | hostM1        | minCon     | 10      |
      | ha_group1  | hostM1        | maxCon     | 1000    |
      | ha_group2  | hostM2        | minCon     | 10      |
      | ha_group2  | hostM2        | maxCon     | 10      |



  Scenario: minCon < maxCon and minCon < numOfShardingNodes #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="1">
        <heartbeat>select user()</heartbeat>
        <writeHost name="hostM2" password="111111" url="172.100.9.6:3306" user="test" />
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql                         |
      | show @@connection_pool      |
    Then check resultset "A" has lines with following column values
      | DB_GROUP-0 | DB_INSTANCE-1 | PROPERTY-2 | VALUE-3 |
      | ha_group1  | hostM1        | minCon     | 10      |
      | ha_group1  | hostM1        | maxCon     | 1000    |
      | ha_group2  | hostM2        | minCon     | 2       |
      | ha_group2  | hostM2        | maxCon     | 1000    |
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A1"
      | sql                         |
      | show @@connection_pool      |
    Then check resultset "A1" has lines with following column values
      | DB_GROUP-0 | DB_INSTANCE-1 | PROPERTY-2 | VALUE-3 |
      | ha_group1  | hostM1        | minCon     | 10      |
      | ha_group1  | hostM1        | maxCon     | 1000    |
      | ha_group2  | hostM2        | minCon     | 2       |
      | ha_group2  | hostM2        | maxCon     | 1000    |



  Scenario: minCon > maxCon and minCon > numOfShardingNodes #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="5" minCon="10">
        <heartbeat>select user()</heartbeat>
        <writeHost name="hostM2" password="111111" url="172.100.9.6:3306" user="test" />
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql                         |
      | show @@connection_pool      |
    Then check resultset "A" has lines with following column values
      | DB_GROUP-0 | DB_INSTANCE-1 | PROPERTY-2 | VALUE-3 |
      | ha_group1  | hostM1        | minCon     | 10      |
      | ha_group1  | hostM1        | maxCon     | 1000    |
      | ha_group2  | hostM2        | minCon     | 10      |
      | ha_group2  | hostM2        | maxCon     | 10      |
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A1"
      | sql                         |
      | show @@connection_pool      |
    Then check resultset "A1" has lines with following column values
      | DB_GROUP-0 | DB_INSTANCE-1 | PROPERTY-2 | VALUE-3 |
      | ha_group1  | hostM1        | minCon     | 10      |
      | ha_group1  | hostM1        | maxCon     | 1000    |
      | ha_group2  | hostM2        | minCon     | 10      |
      | ha_group2  | hostM2        | maxCon     | 10      |


  Scenario: minCon > maxCon and minCon < numOfShardingNodes #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1" minCon="2">
        <heartbeat>select user()</heartbeat>
        <writeHost name="hostM2" password="111111" url="172.100.9.6:3306" user="test" />
    </dataHost>
    """
    Given delete the following xml segment
    | file     | parent             | child                  |
    | schema.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn6" name="schema2" sqlMaxLimit="100"></schema>
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="db1" name="dn2" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    <dataNode dataHost="ha_group2" database="db2" name="dn4" />
    <dataNode dataHost="ha_group1" database="db3" name="dn5" />
    <dataNode dataHost="ha_group2" database="db6" name="dn6" />
    <dataNode dataHost="ha_group2" database="db7" name="dn7" />
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A1"
      | sql                         |
      | show @@connection_pool      |
    Then check resultset "A1" has lines with following column values
      | DB_GROUP-0 | DB_INSTANCE-1 | PROPERTY-2 | VALUE-3 |
      | ha_group1  | hostM1        | minCon     | 10      |
      | ha_group1  | hostM1        | maxCon     | 1000    |
      | ha_group2  | hostM2        | minCon     | 3       |
      | ha_group2  | hostM2        | maxCon     | 3       |
    Given Restart dble in "dble-1" success
    Given sleep "10" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A1"
      | sql                         |
      | show @@connection_pool      |
    Then check resultset "A1" has lines with following column values
      | DB_GROUP-0 | DB_INSTANCE-1 | PROPERTY-2 | VALUE-3 |
      | ha_group1  | hostM1        | minCon     | 10      |
      | ha_group1  | hostM1        | maxCon     | 1000    |
      | ha_group2  | hostM2        | minCon     | 3       |
      | ha_group2  | hostM2        | maxCon     | 3       |