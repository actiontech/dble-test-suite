# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_schema   dble_ap_node    test


   Scenario:  dble_schema table #1
  #case desc dble_schema
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_schema_1"
      | conn   | toClose | sql              | db               |
      | conn_0 | False   | desc dble_schema | dble_information |
    Then check resultset "dble_schema_1" has lines with following column values
      | Field-0                 | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name                    | varchar(64) | NO     | PRI   | None      |         |
      | sharding_node           | varchar(64) | YES    |       | None      |         |
      | function                | varchar(64) | YES    |       | None      |         |
      | ap_node                 | varchar(64) | YES    |       | None      |         |
      | sql_max_limit           | int(11)     | YES    |       | None      |         |
      | logical_create_and_drop | varchar(5)  | YES    |       | None      |         |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                          | expect        | db               |
      | conn_0 | False   | desc dble_schema             | length{(6)}   | dble_information |
      | conn_0 | False   | select * from dble_schema    | success       | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_schema_2"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | select * from dble_schema | dble_information |
    Then check resultset "dble_schema_2" has lines with following column values
      | name-0  | sharding_node-1 | function-2 | ap_node-3 | sql_max_limit-4 | logical_create_and_drop-5 |
      | schema1 | dn5             | -          | None      | 100             | true                      |

  #case change sharding.xml add some schema and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
     <schema shardingNode="dn6" name="schema2" sqlMaxLimit="1000">
     </schema>
    <schema name="schema3">
        <singleTable name="test1"  shardingNode="dn5" />
    </schema>
        <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_schema_3"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | select * from dble_schema | dble_information |
    Then check resultset "dble_schema_3" has lines with following column values
      | name-0  | sharding_node-1 | function-2 | sql_max_limit-4 | logical_create_and_drop-5 |
      | schema1 | dn5             |  -         |   100           | true                      |
      | schema2 | dn6             |  -         |   1000          | true                      |
      | schema3 | None            |  -         |   -1            | true                      |

  #case supported select limit/order by
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                             | expect                                                                                                                                                                | db               |
      | conn_0 | False   | select * from dble_schema limit 1                                                                               | has{(('schema1', 'dn5', '-', None, 100,'true'),)}                                                                                                                                       | dble_information |
      | conn_0 | False   | select * from dble_schema order by sql_max_limit                                                                | has{(('schema3', None, '-', None, -1,'true'), ('schema1', 'dn5', '-', None, 100,'true'), ('schema2', 'dn6', '-', None, 1000,'true'))}                                                                                       | dble_information |
      | conn_0 | False   | select * from dble_schema order by sql_max_limit desc                                                           | has{(('schema2', 'dn6', '-', None, 1000,'true'), ('schema1', 'dn5', '-', None, 100,'true'), ('schema3', None, '-', None, -1,'true'))}                                                                                       | dble_information |
  #case supported select max/min
      | conn_0 | False   | select max(sql_max_limit) from dble_schema                                                                      | has{((1000,),)}                                                                                                                                                       | dble_information |
      | conn_0 | False   | select min(sql_max_limit) from dble_schema                                                                      | has{((-1,),)}                                                                                                                                                         | dble_information |
      | conn_0 | False   | select abs(sql_max_limit) from dble_schema                                                                      | has{((100,), (1000,), (1,))}                                                                                                                                          | dble_information |
  #case supported select where like
      | conn_0 | False   | select * from dble_schema where name ='schema3'                                                                 | has{(('schema3', None, '-', None, -1,'true'),)}                                                                                                                                            | dble_information |
      | conn_0 | False   | select * from dble_schema where abs(sql_max_limit)=1                                                            | has{(('schema3', None, '-', None, -1,'true'),)}                                                                                                                                            | dble_information |
      | conn_0 | False   | select name from dble_schema                                                                                    | has{(('schema1',), ('schema2',), ('schema3',))}                                                                                                                       | dble_information |
  #case supported select join
      | conn_0 | False   | select * from dble_schema a left join dble_sharding_node b on a.sharding_node =b.name order by a.sql_max_limit  | has{(('schema3', None, '-', None, -1,'true', None, None, None, None), ('schema1', 'dn5', '-', None, 100,'true','dn5','ha_group1','db3','false'),('schema2','dn6', '-', None, 1000,'true','dn6','ha_group2','db3','false'))} | dble_information |
      | conn_0 | False   | select * from dble_schema a right join dble_sharding_node b on a.sharding_node =b.name where a.name='schema1'   | has{(('schema1','dn5', '-', None, 100,'true','dn5','ha_group1','db3','false'),)}                                                                                                          | dble_information |
      | conn_0 | False   | select * from dble_schema a inner join dble_sharding_node b on a.sharding_node =b.name order by a.sql_max_limit | has{(('schema1','dn5', '-', None, 100,'true','dn5','ha_group1','db3','false'),('schema2','dn6', '-', None, 1000,'true','dn6','ha_group2','db3','false'))}                                                   | dble_information |
  #case supported select where [sub-query]
      | conn_0 | False   | select * from dble_schema where sharding_node in (select name from dble_sharding_node )                         | has{(('schema1', 'dn5', '-', None, 100,'true'), ('schema2', 'dn6', '-', None, 1000,'true'),)}                                                                                                             | dble_information |
      | conn_0 | False   | select * from dble_schema where sharding_node >all (select name from dble_sharding_node)                        | success                                                                                                                                                               | dble_information |
      | conn_0 | False   | select * from dble_schema where sharding_node < any (select name from dble_sharding_node)                       | has{(('schema1', 'dn5', '-', None, 100,'true'),) }                                                                                                                                        | dble_information |
      | conn_0 | False   | select * from dble_schema where sharding_node = any (select name from dble_sharding_node )                      | has{(('schema1', 'dn5', '-', None, 100,'true'), ('schema2', 'dn6', '-', None, 1000,'true'),)}                                                                                                             | dble_information |
      | conn_0 | False   | select * from dble_schema where sharding_node in (select name from dble_sharding_node where db_group ='ha_group1')      | has{(('schema1', 'dn5', '-', None, 100,'true'),)}           | dble_information |
      | conn_0 | False   | select abs(sql_max_limit) from dble_schema where name ='schema3'       | has{((1,),)}         | dble_information |
  #case unsupported update/delete/insert
      | conn_0 | False   | delete from dble_schema where name = 'schema1'               | Access denied for table 'dble_schema'   | dble_information |
      | conn_0 | False   | update dble_schema set name = '2' where name = 'schema1'     | Access denied for table 'dble_schema'   | dble_information |
      | conn_0 | True    | insert into dble_schema values ('1','2', 3, 4)               | Access denied for table 'dble_schema'   | dble_information |

  #case delete some schema to check result
    Given delete the following xml segment
      | file         | parent         | child            |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_schema_4"
      | conn   | toClose | sql                       | db               |
      | conn_0 | True    | select * from dble_schema | dble_information |
    Then check resultset "dble_schema_4" has lines with following column values
      | name-0  | sharding_node-1 | function-2 | sql_max_limit-4 | logical_create_and_drop-5 |
      | schema1 | dn1             |  -         | -1              | true                      |
    Then check resultset "dble_schema_4" has not lines with following column values
      | name-0  | sharding_node-1 | function-2 | sql_max_limit-4  | logical_create_and_drop-5 |
      | schema1 | dn5             | -           | 100             | true                      |
      | schema2 | dn6             | -           | 1000            | true                      |
      | schema3 | None            | -           | -1              | true                      |

     ### DBLE0REQ-2220  引入HTAPUser的配置 增加 apNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="hytest1" shardingNode="dn6" apNode="apNode1">
        <shardingTable name="hytest" shardingNode="dn1,dn2" sqlMaxLimit="200" function="hash-two" shardingColumn="id"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
    <apNode name="apNode1" dbGroup="ha_group3" database="ckdb"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup name="ha_group3" rwSplitMode="0" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="ckdb" url="172.100.9.10:9004" user="test" password="111111" maxCon="1000" minCon="10" databaseType="clickhouse" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <hybridTAUser name="hyu1" password="111111" schemas="hytest1" maxCon="20"/>
    """
     Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_schema_5"
      | conn   | toClose | sql                       | db               |
      | conn_0 | True    | select * from dble_schema | dble_information |
    Then check resultset "dble_schema_5" has lines with following column values
      | name-0  | sharding_node-1 | function-2 | ap_node-3 | sql_max_limit-4 | logical_create_and_drop-5 |
      | schema1 | dn1             |  -         | None      | -1              | true                      |
      | hytest1 | dn6             | -          | apNode1   | -1              | true                      |

     ##check dble_ap_node table
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_ap_node_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | desc dble_ap_node       | dble_information |
    Then check resultset "dble_ap_node_1" has lines with following column values
      | Field-0   | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name      | varchar(64) | NO     | PRI   | None      |         |
      | db_group  | varchar(64) | NO     |       | None      |         |
      | db_schema | varchar(64) | NO     |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                           | expect            | db               |
      | conn_0 | False   | desc dble_ap_node             | length{(3)}       | dble_information |
      | conn_0 | False   | select * from dble_ap_node    | length{(1)}       | dble_information |
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_ap_node_3"
      | conn   | toClose | sql                              | db               |
      | conn_0 | False   | select * from dble_ap_node | dble_information |
    Then check resultset "dble_ap_node_3" has lines with following column values
      | name-0     | db_group-1 | db_schema-2 |
      | apNode1    | ha_group3  | ckdb         |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                       | expect                                    | db               |
     #case unsupported update/delete/insert
      | conn_0 | False   | delete from dble_ap_node where name = 'apNode1'            | Access denied for table 'dble_ap_node'   | dble_information |
      | conn_0 | False   | update dble_ap_node set name = '2' where name = 'dn1'      | Access denied for table 'dble_ap_node'   | dble_information |
      | conn_0 | True    | insert into dble_ap_node values ('1','2','3')              | Access denied for table 'dble_ap_node'   | dble_information |