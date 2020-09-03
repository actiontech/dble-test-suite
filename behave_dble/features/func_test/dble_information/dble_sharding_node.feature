# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_sharding_node test

   Scenario:  dble_sharding_node table #1
  #case desc dble_sharding_node
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_node_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | desc dble_sharding_node | dble_information |
    Then check resultset "dble_sharding_node_1" has lines with following column values
      | Field-0   | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name      | varchar(64) | NO     | PRI   | None      |         |
      | db_group  | varchar(64) | NO     |       | None      |         |
      | db_schema | varchar(64) | NO     |       | None      |         |
      | pause     | varchar(5)  | YES    |       | None      |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_node_2"
      | conn   | toClose | sql                              | db               |
      | conn_0 | False   | select * from dble_sharding_node | dble_information |
    Then check resultset "dble_sharding_node_2" has lines with following column values
      | name-0 | db_group-1 | db_schema-2 | pause-3 |
      | dn1    | ha_group1  | db1         | false   |
      | dn2    | ha_group2  | db1         | false   |
      | dn3    | ha_group1  | db2         | false   |
      | dn4    | ha_group2  | db2         | false   |
      | dn5    | ha_group1  | db3         | false   |
  #case change sharding.xml and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
     <schema shardingNode="dn6" name="schema2" sqlMaxLimit="100">
    </schema>
        <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_node_3"
      | conn   | toClose | sql                              | db               |
      | conn_0 | False   | select * from dble_sharding_node | dble_information |
    Then check resultset "dble_sharding_node_3" has lines with following column values
      | name-0 | db_group-1 | db_schema-2 | pause-3 |
      | dn1    | ha_group1  | db1         | false   |
      | dn2    | ha_group2  | db1         | false   |
      | dn3    | ha_group1  | db2         | false   |
      | dn4    | ha_group2  | db2         | false   |
      | dn5    | ha_group1  | db3         | false   |
      | dn6    | ha_group2  | db3         | false   |
    Then execute admin cmd "pause @@shardingNode='dn1' and timeout=10"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_node_4"
      | conn   | toClose | sql                              | db               |
      | conn_0 | False   | select * from dble_sharding_node | dble_information |
    Then check resultset "dble_sharding_node_4" has lines with following column values
      | name-0 | db_group-1 | db_schema-2 | pause-3 |
      | dn1    | ha_group1  | db1         | true   |
      | dn2    | ha_group2  | db1         | false   |
      | dn3    | ha_group1  | db2         | false   |
      | dn4    | ha_group2  | db2         | false   |
      | dn5    | ha_group1  | db3         | false   |
      | dn6    | ha_group2  | db3         | false   |
    Then execute admin cmd "resume"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_node_5"
      | conn   | toClose | sql                              | db               |
      | conn_0 | False   | select * from dble_sharding_node | dble_information |
    Then check resultset "dble_sharding_node_5" has lines with following column values
      | name-0 | db_group-1 | db_schema-2 | pause-3 |
      | dn1    | ha_group1  | db1         | true   |
      | dn2    | ha_group2  | db1         | false   |
      | dn3    | ha_group1  | db2         | false   |
      | dn4    | ha_group2  | db2         | false   |
      | dn5    | ha_group1  | db3         | false   |
      | dn6    | ha_group2  | db3         | false   |