# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_sharding_node table test

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
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                 | expect            | db               |
      | conn_0 | False   | desc dble_sharding_node             | length{(4)}       | dble_information |
      | conn_0 | False   | select * from dble_sharding_node    | length{(5)}       | dble_information |
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
  #case change sharding.xml and reload to check result
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
     <schema shardingNode="dn6" name="schema2" sqlMaxLimit="100"/>
        <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
    """
    Then execute admin cmd "reload @@config"
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
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_node_4"
      | conn   | toClose | sql                      |
      | conn_0 | False   | show @@shardingnode      |
    Then check resultset "dble_sharding_node_4" has lines with following column values
      | NAME-0 | DB_GROUP-1    | SCHEMA_EXISTS-2 |
      | dn1    | ha_group1/db1 | true            |
      | dn2    | ha_group2/db1 | true            |
      | dn3    | ha_group1/db2 | true            |
      | dn4    | ha_group2/db2 | true            |
      | dn5    | ha_group1/db3 | true            |
      | dn6    | ha_group2/db3 | true            |
    Then execute admin cmd "pause @@shardingNode='dn1' and timeout=10"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql          | expect       |
      | conn_0 | False   | show @@pause | has{('dn1')} |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_node_5"
      | conn   | toClose | sql                              | db               |
      | conn_0 | False   | select * from dble_sharding_node | dble_information |
    Then check resultset "dble_sharding_node_5" has lines with following column values
      | name-0 | db_group-1 | db_schema-2 | pause-3 |
      | dn1    | ha_group1  | db1         | true    |
      | dn2    | ha_group2  | db1         | false   |
      | dn3    | ha_group1  | db2         | false   |
      | dn4    | ha_group2  | db2         | false   |
      | dn5    | ha_group1  | db3         | false   |
      | dn6    | ha_group2  | db3         | false   |
    Then check resultset "dble_sharding_node_5" has not lines with following column values
      | name-0 | db_group-1 | db_schema-2 | pause-3 |
      | dn1    | ha_group1  | db1         | false   |
    Then execute admin cmd "resume"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_node_6"
      | conn   | toClose | sql                              | db               |
      | conn_0 | False   | select * from dble_sharding_node | dble_information |
    Then check resultset "dble_sharding_node_6" has lines with following column values
      | name-0 | db_group-1 | db_schema-2 | pause-3 |
      | dn1    | ha_group1  | db1         | false   |
      | dn2    | ha_group2  | db1         | false   |
      | dn3    | ha_group1  | db2         | false   |
      | dn4    | ha_group2  | db2         | false   |
      | dn5    | ha_group1  | db3         | false   |
      | dn6    | ha_group2  | db3         | false   |
    Then check resultset "dble_sharding_node_6" has not lines with following column values
      | name-0 | db_group-1 | db_schema-2 | pause-3 |
      | dn1    | ha_group1  | db1         | true    |

  #case supported select limit/order by
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                               | expect                                                                                   | db               |
      | conn_0 | False   | select * from dble_sharding_node limit 1                          | has{(('dn1', 'ha_group1', 'db1','false'),)}                                              | dble_information |
      | conn_0 | False   | select * from dble_sharding_node order by name desc limit 2       | has{(('dn6', 'ha_group2', 'db3', 'false'), ('dn5', 'ha_group1', 'db3', 'false'))}        | dble_information |
  #case supported select max/min
      | conn_0 | False   | select max(name) from dble_sharding_node         | has{(('dn6',),)}      | dble_information |
      | conn_0 | False   | select min(name) from dble_sharding_node         | has{(('dn1',),)}      | dble_information |
  #case supported select where like
      | conn_0 | False   | select * from dble_sharding_node where db_schema ='db1'      | has{(('dn1', 'ha_group1', 'db1','false'),('dn2', 'ha_group2', 'db1','false'))}      | dble_information |
      | conn_0 | False   | select * from dble_sharding_node where name like '%dn%'      | length{(6)}                                                                         | dble_information |
  #case supported select where [sub-query]
      | conn_0 | False   | select * from dble_sharding_node where name in (select sharding_node from dble_schema )          | has{(('dn5', 'ha_group1', 'db3','false'), ('dn6', 'ha_group2', 'db3','false'),)}        | dble_information |
      | conn_0 | False   | select * from dble_sharding_node where name >all (select sharding_node from dble_schema)         | success                                                                                 | dble_information |
      | conn_0 | False   | select * from dble_sharding_node where name < any (select sharding_node from dble_schema)        | length{(5)}                                                                             | dble_information |
      | conn_0 | False   | select * from dble_sharding_node where name = any (select sharding_node from dble_schema)        | has{(('dn5', 'ha_group1', 'db3','false'), ('dn6', 'ha_group2', 'db3','false'),)}        | dble_information |
  #case supported select field
      | conn_0 | False   | select a.*,b.* from dble_sharding_node a inner join dble_schema b on a.name=b.sharding_node where a.db_schema ='db3'      | has{(('dn5', 'ha_group1', 'db3', 'false', 'schema1', 'dn5', 100), ('dn6', 'ha_group2', 'db3', 'false', 'schema2', 'dn6', 100))}    | dble_information |
      | conn_0 | False   | select * from dble_sharding_node where name in (select sharding_node from dble_schema where name ='schema1')              | has{(('dn5', 'ha_group1', 'db3','false'), )}                                                                                       | dble_information |

  #case unsupported update/delete/insert
      | conn_0 | False   | delete from dble_sharding_node where name = 'dn1'            | Access denied for table 'dble_sharding_node'   | dble_information |
      | conn_0 | False   | update dble_sharding_node set name = '2' where name = 'dn1'  | Access denied for table 'dble_sharding_node'   | dble_information |
      | conn_0 | True    | insert into dble_sharding_node values ('1','2','3','4')      | Access denied for table 'dble_sharding_node'   | dble_information |

  #case delete some schema to check result
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1">
        <globalTable name="test" shardingNode="dn1,dn2" />
    </schema>
        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_node_7"
      | conn   | toClose | sql                              | db               |
      | conn_0 | True    | select * from dble_sharding_node | dble_information |
    Then check resultset "dble_sharding_node_7" has lines with following column values
      | name-0 | db_group-1 | db_schema-2 | pause-3 |
      | dn1    | ha_group1  | db1         | false   |
      | dn2    | ha_group2  | db2         | false   |
    Then check resultset "dble_sharding_node_7" has not lines with following column values
      | name-0 | db_group-1 | db_schema-2 | pause-3 |
      | dn3    | ha_group1  | db2         | false   |
      | dn4    | ha_group2  | db2         | false   |
      | dn5    | ha_group1  | db3         | false   |
      | dn6    | ha_group2  | db3         | false   |


