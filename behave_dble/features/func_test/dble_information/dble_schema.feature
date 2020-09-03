# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_schema test

   Scenario:  dble_schema table #1
  #case desc dble_schema
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_schema_1"
      | conn   | toClose | sql              | db               |
      | conn_0 | False   | desc dble_schema | dble_information |
    Then check resultset "dble_schema_1" has lines with following column values
      | Field-0       | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name          | varchar(64) | NO     | PRI   | None      |         |
      | sharding_node | varchar(64) | YES    |       | None      |         |
      | sql_max_limit | int(11)     | YES    |       | None      |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_schema_2"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | select * from dble_schema | dble_information |
    Then check resultset "dble_schema_2" has lines with following column values
      | name-0  | sharding_node-1 | sql_max_limit-2 |
      | schema1 | dn5             | 100             |

  #case change sharding.xml and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
     <schema shardingNode="dn6" name="schema2" sqlMaxLimit="1000">
     </schema>
    <schema name="schema3">
        <singleTable name="test1"  shardingNode="dn5" />
    </schema>
        <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_schema_3"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | select * from dble_schema | dble_information |
    Then check resultset "dble_schema_3" has lines with following column values
      | name-0  | sharding_node-1 | sql_max_limit-2 |
      | schema1 | dn5             | 100             |
      | schema2 | dn6             | 1000            |
      | schema3 | None            | -1              |
  #case select * from dble_schema where xxx
