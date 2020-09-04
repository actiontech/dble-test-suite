# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_schema test
@skip_restart
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
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_schema_3"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | select * from dble_schema | dble_information |
    Then check resultset "dble_schema_3" has lines with following column values
      | name-0  | sharding_node-1 | sql_max_limit-2 |
      | schema1 | dn5             | 100             |
      | schema2 | dn6             | 1000            |
      | schema3 | None            | -1              |

  #case select
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                             | expect                                                                                                                                                                | db               |
      | conn_0 | False   | select * from dble_schema order by sql_max_limit                                                                | has{(('schema3', None, -1), ('schema1', 'dn5', 100), ('schema2', 'dn6', 1000))}                                                                                       | dble_information |
      | conn_0 | False   | select * from dble_schema order by sql_max_limit desc                                                           | has{(('schema2', 'dn6', 1000), ('schema1', 'dn5', 100), ('schema3', None, -1))}                                                                                       | dble_information |
      | conn_0 | False   | select max(sql_max_limit) from dble_schema                                                                      | has{((1000,),)}                                                                                                                                                       | dble_information |
      | conn_0 | False   | select min(sql_max_limit) from dble_schema                                                                      | has{((-1,),)}                                                                                                                                                         | dble_information |
      | conn_0 | False   | select abs(sql_max_limit) from dble_schema                                                                      | has{((100,), (1000,), (1,))}                                                                                                                                          | dble_information |
      | conn_0 | False   | select * from dble_schema where name ='schema3'                                                                 | has{('schema3', None, -1)}                                                                                                                                            | dble_information |
      | conn_0 | False   | select * from dble_schema where abs(sql_max_limit)=1                                                            | has{('schema3', None, -1)}                                                                                                                                            | dble_information |
      | conn_0 | False   | select name from dble_schema                                                                                    | has{(('schema1',), ('schema2',), ('schema3',))}                                                                                                                       | dble_information |
      | conn_0 | False   | select * from dble_schema a left join dble_sharding_node b on a.sharding_node =b.name order by a.sql_max_limit  | has{(('schema3', None, -1, None, None, None, None), ('schema1', 'dn5', 100,'dn5','ha_group1','db3','false'),('schema2','dn6', 1000,'dn6','ha_group2','db3','false'))} | dble_information |
      | conn_0 | False   | select * from dble_schema a right join dble_sharding_node b on a.sharding_node =b.name where a.name='schema1'   | has{(('schema1','dn5',100,'dn5','ha_group1','db3','false'))}                                                                                                          | dble_information |
      | conn_0 | False   | select * from dble_schema a inner join dble_sharding_node b on a.sharding_node =b.name order by a.sql_max_limit | has{(('schema1','dn5',100,'dn5','ha_group1','db3','false'),('schema2','dn6',1000,'dn6','ha_group2','db3','false'))}                                                   | dble_information |
      | conn_0 | False   | select * from dble_schema where sharding_node in (select name from dble_sharding_node )                         | has{(('schema1', 'dn5', 100), ('schema2', 'dn6', 1000),)}                                                                                                             | dble_information |
      | conn_0 | False   | select * from dble_schema where sharding_node >all (select name from dble_sharding_node)                        | success                                                                                                                                                               | dble_information |
      | conn_0 | False   | select * from dble_schema where sharding_node < any (select name from dble_sharding_node)                       | has{('schema1', 'dn5', 100), }                                                                                                                                        | dble_information |
      | conn_0 | False   | select * from dble_schema where sharding_node = any (select name from dble_sharding_node )                      | has{(('schema1', 'dn5', 100), ('schema2', 'dn6', 1000),)}                                                                                                             | dble_information |

#      | conn_0 | False   | select * from dble_schema where sharding_node >=(select name from dble_sharding_node where db_group ='ha_group1')      |           | dble_information |
#      | conn_0 | False   | select abs(sql_max_limit) from dble_schema where name ='schema3'       |         | dble_information |
#      | conn_0 | False   | select a.*,b.* from dble_sharding_node a inner join dble_schema b on a.name=b.sharding where a.db_schema ='db3'      |         | dble_information |
#      | conn_0 | False   | select * from dble_sharding_node where name =(select sharding_node from dble_schema where name ='schema1')       |         | dble_information |









