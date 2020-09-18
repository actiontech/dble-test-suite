# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_table test
#@skip_restart
   Scenario:  dble_table  table #1
  #case desc dble_table
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_table_1"
      | conn   | toClose | sql             | db               |
      | conn_0 | False   | desc dble_table | dble_information |
    Then check resultset "dble_table_1" has lines with following column values
      | Field-0   | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id        | varchar(64) | NO     | PRI   | None      |         |
      | name      | varchar(64) | NO     |       | None      |         |
      | schema    | varchar(64) | NO     |       | None      |         |
      | max_limit | int(11)     | YES    |       | None      |         |
      | type      | varchar(10) | NO     |       | None      |         |

  #case change sharding/user.xml add some schema and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="er_parent" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
            <childTable name="er_child" sqlMaxLimit="90" joinColumn="id" parentColumn="id"/>
        </shardingTable>
    </schema>
     <schema shardingNode="dn6" name="schema2" sqlMaxLimit="1000">
        <singleTable name="test1"  shardingNode="dn1" />
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <globalTable name="global_4_t1" shardingNode="dn1,dn2,dn3,dn4" />
     </schema>
    <schema shardingNode="dn4" name="schema3">
        <singleTable name="test2"  shardingNode="dn2" />
    </schema>

        <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    	<shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_table_2"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | select * from dble_table  | dble_information |
    Then check resultset "dble_table_2" has lines with following column values
      | name-1        | schema-2 | max_limit-3 | type-4   |
      | sharding_2_t1 | schema1  | 100         | SHARDING |
      | sharding_4_t1 | schema1  | 100         | SHARDING |
      | er_parent     | schema1  | 100         | SHARDING |
      | er_child      | schema1  | 90          | CHILD    |
      | test          | schema1  | 100         | GLOBAL   |
      | sharding_4_t2 | schema2  | 1000        | SHARDING |
      | global_4_t1   | schema2  | 1000        | GLOBAL   |
      | test1         | schema2  | 1000        | SINGLE   |
      | test2         | schema3  | -1          | SINGLE   |
  #case create new tables
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  |
      | conn_1 | False   | use schema1                 | success |
      | conn_1 | False   | drop table if exists no_s1  | success |
      | conn_1 | False   | create table no_s1 (id int) | success |
      | conn_1 | False   | use schema2                 | success |
      | conn_1 | False   | drop table if exists no_s2  | success |
      | conn_1 | False   | create table no_s2 (id int) | success |
      | conn_1 | False   | use schema3                 | success |
      | conn_1 | False   | drop table if exists no_s3  | success |
      | conn_1 | False   | create table no_s3 (id int) | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_table_3"
      | conn   | toClose | sql                                                                                                      | db               |
      | conn_0 | False   | select * from dble_table where type ='NO_SHARDING' and name ='no_s1' or name = 'no_s2' or name = 'no_s3' | dble_information |
    Then check resultset "dble_table_3" has lines with following column values
      | name-1  | schema-2 | max_limit-3 | type-4      |
      | no_s1   | schema1  | 100         | NO_SHARDING |
      | no_s2   | schema2  | 1000        | NO_SHARDING |
      | no_s3   | schema3  | -1          | NO_SHARDING |
   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                         | expect                                                                                       |
      | conn_0 | False   | select * from dble_table limit 1                            | has{(('C1', 'sharding_2_t1', 'schema1', 100,'SHARDING'),)}                                   |
      | conn_0 | False   | select * from dble_table order by type desc limit 2         | has{(('C8', 'test1', 'schema2', 1000, 'SINGLE'), ('C9', 'test2', 'schema3', -1, 'SINGLE'))}  |
      | conn_0 | False   | select * from dble_table where name like '%no%'             | length{(3)}                                                                                  |
  #case select max/min
      | conn_0 | False   | select max(max_limit) from dble_table                      | has{((1000,),)}  |
      | conn_0 | False   | select min(max_limit) from dble_table                      | has{((-1,),)}    |
  #case select field and where [sub-query]
      | conn_0 | False   | select type from dble_table where schema in (select schema from dble_table where max_limit=90)       | success  |
#      | conn_0 | False   | select type from dble_table where schema >all (select schema from dble_table where id like '%c%')    | success  |
#      | conn_0 | False   | select type from dble_table where schema < any (select schema from dble_table where id like '%c%')   | success  |
#      | conn_0 | False   | select type from dble_table where schema = (select schema from dble_table where id like '%c%')       | success  |
      | conn_0 | False   | select type from dble_table where schema = any (select schema from dble_table where id like '%c%')   | success  |
  #case update/delete
      | conn_0 | False   | delete from dble_table where schema='schema1'                   | Access denied for table 'dble_table'  |
      | conn_0 | False   | update dble_table set schema = 'a' where schema='schema1'       | Access denied for table 'dble_table'  |
      | conn_0 | False   | insert into dble_table values ('a','1',2,'3')                   | Access denied for table 'dble_table'  |

#  #case delete some schema
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
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    	<shardingUser name="test" password="111111" schemas="schema1"/>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_table_4"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | select * from dble_table  | dble_information |
    Then check resultset "dble_table_4" has lines with following column values
      | name-1        | schema-2 | max_limit-3 | type-4   |
      | test          | schema1  | -1          | GLOBAL   |
    Then check resultset "dble_table_4" has not lines with following column values
      | name-1        | schema-2 | max_limit-3 | type-4      |
      | sharding_2_t1 | schema1  | 100         | SHARDING    |
      | sharding_4_t1 | schema1  | 100         | SHARDING    |
      | er_parent     | schema1  | 100         | SHARDING    |
      | er_child      | schema1  | 100         | CHILD       |
      | test          | schema1  | 100         | GLOBAL      |
      | sharding_4_t2 | schema2  | 1000        | SHARDING    |
      | global_4_t1   | schema2  | 1000        | GLOBAL      |
      | test1         | schema2  | 1000        | SINGLE      |
      | test2         | schema3  | -1          | SINGLE      |
      | no_s1         | schema1  | 100         | NO_SHARDING |
      | no_s2         | schema2  | 1000        | NO_SHARDING |
      | no_s3         | schema3  | -1          | NO_SHARDING |

   Scenario:  dble_global_table table #2
  #case desc dble_global_table
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_global_table_1"
      | conn   | toClose | sql                    | db               |
      | conn_0 | False   | desc dble_global_table | dble_information |
    Then check resultset "dble_global_table_1" has lines with following column values
      | Field-0     | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id          | varchar(64) | NO     | PRI   | None      |         |
      | check       | varchar(5)  | NO     |       | None      |         |
      | check_class | varchar(64) | YES    |       | None      |         |
      | cron        | varchar(32) | YES    |       | None      |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_global_table_2"
      | conn   | toClose | sql                             | db               |
      | conn_0 | False   | select * from dble_global_table | dble_information |
    Then check resultset "dble_global_table_2" has lines with following column values
      |id-0 | check-1 | check_class-2 | cron-3      |
      |C3   | false   | CHECKSUM      | 0 0 0 * * ? |
  #case change sharding.xml add checkClass and reload
    Given delete the following xml segment
      | file         | parent         | child            |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
        <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn4" cron="/5 * * * * ? *" checkClass="CHECKSUM" />
    </schema>
     <schema shardingNode="dn1" name="schema2" sqlMaxLimit="1000">
        <globalTable name="test2" shardingNode="dn1,dn2" cron="/10 * * * * ?" checkClass="COUNT" />
        <globalTable name="test3" shardingNode="dn1,dn2,dn3" cron="0 /5 * * * ? *" checkClass="CHECKSUM" />
        <globalTable name="test4" shardingNode="dn1,dn3" />
     </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    	<shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_global_table_3"
      | conn   | toClose | sql                             | db               |
      | conn_0 | False   | select * from dble_global_table | dble_information |
    Then check resultset "dble_global_table_3" has lines with following column values
      |id-0 | check-1 | check_class-2 | cron-3            |
      |C1   | true    | CHECKSUM      | /5 * * * * ? *    |
      |C2   | true    | COUNT         | /10 * * * * ?     |
      |C3   | true    | CHECKSUM      | 0 /5 * * * ? *    |
      |C4   | false   | CHECKSUM      | 0 0 0 * * ?       |
    Then check resultset "dble_global_table_3" has not lines with following column values
      |id-0 | check-1 | check_class-2 | cron-3      |
      |C3   | false   | CHECKSUM      | 0 0 0 * * ? |
    Given sleep "11" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    Global check start .........test1
    Global check start .........test2
    """
   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                | expect                                                      |
      | conn_0 | False   | use dble_information                                               | success                                                     |
      | conn_0 | False   | select * from dble_global_table limit 1                            | has{(('C1', 'true', 'CHECKSUM', '/5 * * * * ? *'),)}        |
      | conn_0 | False   | select * from dble_global_table order by id desc limit 1           | has{(('C4', 'false', 'CHECKSUM', '0 0 0 * * ?'),)}          |
      | conn_0 | False   | select * from dble_global_table where id like '%c%'                | length{(4)}                                                 |
  #case select max/min
      | conn_0 | False   | select max(check_class) from dble_global_table                     | has{(('COUNT',),)}       |
      | conn_0 | False   | select min(check_class) from dble_global_table                     | has{(('CHECKSUM',),)}    |
  #case update/delete
      | conn_0 | False   | delete from dble_global_table where id='c1'                   | Access denied for table 'dble_global_table' |
      | conn_0 | False   | update dble_global_table set id = 'a' where id='c1'           | Access denied for table 'dble_global_table' |
      | conn_0 | False   | insert into dble_global_table values ('a','1','2','3')        | Access denied for table 'dble_global_table' |

   Scenario:  dble_sharding_table table #3
  #case desc dble_sharding_table
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_table_1"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | desc dble_sharding_table | dble_information |
    Then check resultset "dble_sharding_table_1" has lines with following column values
      | Field-0               | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id                    | varchar(64) | NO     | PRI   | None      |         |
      | increment_column      | varchar(64) | YES    |       | None      |         |
      | sharding_column       | varchar(64) | NO     |       | None      |         |
      | sql_required_sharding | varchar(5)  | NO     |       | None      |         |
      | algorithm_name        | varchar(32) | NO     |       | None      |         |

  #case change sharding.xml add some schema/function  and reload
    Given delete the following xml segment
      | file         | parent         | child            |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_2_t2" shardingNode="dn3,dn4" function="hash-two" shardingColumn="two" incrementColumn="id"/>
        <shardingTable name="sharding_3_t1" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="three" sqlRequiredSharding="true"/>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="four"/>
        <shardingTable name="sharding_date_t1" shardingNode="dn1,dn2,dn3,dn4" function="date_default_rule" shardingColumn="date"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100">
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform" shardingColumn="code"/>
        <shardingTable name="sharding_4_t3" shardingNode="dn1,dn2,dn3,dn4" function="fixed_nonuniform" shardingColumn="fix"/>
        <shardingTable name="sharding_4_t4" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform_string_rule" shardingColumn="rule"/>
        <shardingTable name="sharding_4_t5" shardingNode="dn1,dn2,dn3,dn4" function="fixed_nonuniform_string_rule" shardingColumn="fixed"/>
    </schema>
     <function name="fixed_uniform" class="Hash">
        <property name="partitionCount">4</property>
        <property name="partitionLength">256</property>
     </function>
     <function name="fixed_nonuniform" class="Hash">
        <property name="partitionCount">2,1</property>
        <property name="partitionLength">256,512</property>
     </function>
     <function name="fixed_uniform_string_rule" class="StringHash">
        <property name="partitionCount">4</property>
        <property name="partitionLength">256</property>
        <property name="hashSlice">0:2</property>
     </function>
     <function name="fixed_nonuniform_string_rule" class="StringHash">
        <property name="partitionCount">2,1</property>
        <property name="partitionLength">256,512</property>
        <property name="hashSlice">0:2</property>
     </function>
     <function name="date_default_rule" class="Date">
        <property name="dateFormat">yyyy-MM-dd</property>
        <property name="sBeginDate">2016-12-01</property>
        <property name="sEndDate">2017-01-9</property>
        <property name="sPartionDay">10</property>
        <property name="defaultNode">0</property>
     </function>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    	<shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_table_2"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from dble_sharding_table | dble_information |
    Then check resultset "dble_sharding_table_2" has lines with following column values
      |id-0 | increment_column-1 | sharding_column-2 | sql_required_sharding-3 | algorithm_name-4             |
      |C1   | None               | ID                | false                   | hash-two                     |
      |C2   | ID                 | TWO               | false                   | hash-two                     |
      |C3   | None               | THREE             | true                    | hash-three                   |
      |C4   | None               | FOUR              | false                   | hash-four                    |
      |C5   | None               | DATE              | false                   | date_default_rule            |
      |C6   | None               | CODE              | false                   | fixed_uniform                |
      |C7   | None               | FIX               | false                   | fixed_nonuniform             |
      |C8   | None               | RULE              | false                   | fixed_uniform_string_rule    |
      |C9   | None               | FIXED             | false                   | fixed_nonuniform_string_rule |
   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                            | expect                                                                        |
      | conn_0 | False   | use dble_information                                                           | success                                                                       |
      | conn_0 | False   | select * from dble_sharding_table limit 1                                      | has{(('C1', None, 'ID', 'false', 'hash-two'),)}                               |
      | conn_0 | False   | select * from dble_sharding_table order by id desc limit 1                     | has{(('C9', None, 'FIXED', 'false', 'fixed_nonuniform_string_rule'),)}        |
      | conn_0 | False   | select * from dble_sharding_table where algorithm_name like '%fixed%'          | length{(4)}                                                                   |
  #case select max/min
      | conn_0 | False   | select max(algorithm_name) from dble_sharding_table                | has{(('hash-two',),)}             |
      | conn_0 | False   | select min(algorithm_name) from dble_sharding_table                | has{(('date_default_rule',),)}    |
  #case update/delete
      | conn_0 | False   | delete from dble_sharding_table where id='c1'                   | Access denied for table 'dble_sharding_table'   |
      | conn_0 | False   | update dble_sharding_table set id = 'a' where id='c1'           | Access denied for table 'dble_sharding_table'   |
      | conn_0 | False   | insert into dble_sharding_table values ('a','1','2','3')        | Access denied for table 'dble_sharding_table'   |

  #case change sharding.xml delete some schema/function and reload
    Given delete the following xml segment
      | file         | parent         | child              |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}   |
      | sharding.xml | {'tag':'root'} | {'tag':'function'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    	<shardingUser name="test" password="111111" schemas="schema1"/>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_table_3"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from dble_sharding_table | dble_information |
    Then check resultset "dble_sharding_table_3" has not lines with following column values
      |id-0 | increment_column-1 | sharding_column-2 | sql_required_sharding-3 | algorithm_name-4             |
      |C1   | None               | ID                | false                   | hash-two                     |
      |C2   | ID                 | TWO               | false                   | hash-two                     |
      |C3   | None               | THREE             | true                    | hash-three                   |
      |C4   | None               | FOUR              | false                   | hash-four                    |
      |C5   | None               | DATE              | false                   | date_default_rule            |
      |C6   | None               | CODE              | false                   | fixed_uniform                |
      |C7   | None               | FIX               | false                   | fixed_nonuniform             |
      |C8   | None               | RULE              | false                   | fixed_uniform_string_rule    |
      |C9   | None               | FIXED             | false                   | fixed_nonuniform_string_rule |

   Scenario:  dble_table_sharding_node table #4
  #case desc dble_table_sharding_node
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_table_sharding_node_1"
      | conn   | toClose | sql                           | db               |
      | conn_0 | False   | desc dble_table_sharding_node | dble_information |
    Then check resultset "dble_table_sharding_node_1" has lines with following column values
      | Field-0       | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id            | varchar(64) | NO     | PRI   | None      |         |
      | sharding_node | varchar(32) | NO     | PRI   | None      |         |
      | order         | int(11)     | NO     |       | None      |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_table_sharding_node_2"
      | conn   | toClose | sql                                    | db               |
      | conn_0 | False   | select * from dble_table_sharding_node | dble_information |
    Then check resultset "dble_table_sharding_node_2" has lines with following column values
      | id-0 | sharding_node-1 | order-2 |
      | C1   | dn1             | 0       |
      | C1   | dn2             | 1       |
      | C2   | dn1             | 0       |
      | C2   | dn2             | 1       |
      | C2   | dn3             | 2       |
      | C2   | dn4             | 3       |
  #case change sharding.xml add some schema  and reload
    Given delete the following xml segment
      | file         | parent         | child            |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_2_t2" shardingNode="dn3,dn4" function="hash-two" shardingColumn="two" incrementColumn="id"/>
        <shardingTable name="sharding_3_t1" shardingNode="dn1,dn3,dn5" function="hash-three" shardingColumn="three" sqlRequiredSharding="true"/>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn3,dn2,dn4" function="hash-four" shardingColumn="four"/>
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="date"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_table_sharding_node_3"
      | conn   | toClose | sql                                    | db               |
      | conn_0 | False   | select * from dble_table_sharding_node | dble_information |
    Then check resultset "dble_table_sharding_node_3" has lines with following column values
      | id-0 | sharding_node-1 | order-2 |
      | C1   | dn1             | 0       |
      | C1   | dn2             | 1       |
      | C2   | dn3             | 0       |
      | C2   | dn4             | 1       |
      | C3   | dn1             | 0       |
      | C3   | dn3             | 1       |
      | C3   | dn5             | 2       |
      | C4   | dn1             | 0       |
      | C4   | dn3             | 1       |
      | C4   | dn2             | 2       |
      | C4   | dn4             | 3       |
      | C5   | dn1             | 0       |
      | C5   | dn2             | 1       |
      | C5   | dn3             | 2       |
      | C5   | dn4             | 3       |
   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                            | expect                                                                        |
      | conn_0 | False   | use dble_information                                                           | success                                          |
      | conn_0 | False   | select * from dble_table_sharding_node limit 1                                 | has{(('C1', 'dn1', 0),)}                         |
      | conn_0 | False   | select * from dble_table_sharding_node order by id desc limit 2                | has{(('C5', 'dn1', 0), ('C5', 'dn2', 1),)}       |
      | conn_0 | False   | select * from dble_table_sharding_node where sharding_node like '%n4%'         | length{(3)}                                      |
  #case select max/min
      | conn_0 | False   | select max(order) from dble_table_sharding_node                | has{((3,),)}    |
      | conn_0 | False   | select min(order) from dble_table_sharding_node                | has{((0,),)}    |
  #case select field and where [sub-query]
      | conn_0 | False   | select id from dble_table_sharding_node where sharding_node in (select sharding_node from dble_table_sharding_node where order > 2) | has{(('C2',), ('C4',), ('C5',))}     |
  #case update/delete
      | conn_0 | False   | delete from dble_table_sharding_node where id='c1'             | Access denied for table 'dble_table_sharding_node'   |
      | conn_0 | False   | update dble_table_sharding_node set id = 'a' where id='c1'     | Access denied for table 'dble_table_sharding_node'   |
      | conn_0 | False   | insert into dble_table_sharding_node values ('a','1')          | Access denied for table 'dble_table_sharding_node'   |

  #case change sharding.xml delete some schema and reload
    Given delete the following xml segment
      | file         | parent         | child              |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}   |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" />
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_table_sharding_node_4"
      | conn   | toClose | sql                                    | db               |
      | conn_0 | False   | select * from dble_table_sharding_node | dble_information |
    Then check resultset "dble_table_sharding_node_4" has not lines with following column values
      | id-0 | sharding_node-1 | order-2 |
      | C1   | dn1             | 0       |
      | C1   | dn2             | 1       |
      | C2   | dn3             | 0       |
      | C2   | dn4             | 1       |
      | C3   | dn1             | 0       |
      | C3   | dn3             | 1       |
      | C3   | dn5             | 2       |
      | C4   | dn1             | 0       |
      | C4   | dn3             | 1       |
      | C4   | dn2             | 2       |
      | C4   | dn4             | 3       |
      | C5   | dn1             | 0       |
      | C5   | dn2             | 1       |
      | C5   | dn3             | 2       |
      | C5   | dn4             | 3       |


  @skip_restart
   Scenario:  dble_child_table table #5
  #case desc dble_child_table
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_child_table_1"
      | conn   | toClose | sql                   | db               |
      | conn_0 | False   | desc dble_child_table | dble_information |
    Then check resultset "dble_child_table_1" has lines with following column values
      | Field-0          | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id               | varchar(64) | NO     | PRI   | None      |         |
      | parent_id        | varchar(64) | NO     |       | None      |         |
      | increment_column | varchar(64) | YES    |       | None      |         |
      | join_column      | varchar(64) | NO     |       | None      |         |
      | paren_column     | varchar(64) | NO     |       | None      |         |

  #case change sharding.xml and reload
    Given delete the following xml segment
      | file         | parent         | child            |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="er_parent" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="code" incrementColumn="id">
            <childTable name="er_child1" joinColumn="code1" parentColumn="code" incrementColumn="id1"/>
            <childTable name="er_child2" joinColumn="code2" parentColumn="code" incrementColumn="id2"/>
        </shardingTable>
        <shardingTable name="parent" shardingNode="dn1,dn2" function="hash-two" shardingColumn="name" incrementColumn="code">
            <childTable name="child" joinColumn="code" parentColumn="name" incrementColumn="id"/>
        </shardingTable>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_child_table_2"
      | conn   | toClose | sql                            | db               |
      | conn_0 | False   | select * from dble_child_table | dble_information |
     Then check resultset "dble_child_table_2" has lines with following column values
      | id-0 | parent_id-1 | increment_column-2 | join_column-3 | paren_column-4 |
      | C2   | C1          | ID1                | CODE1         | CODE           |
      | C3   | C1          | ID2                | CODE2         | CODE           |
      | C5   | C4          | ID                 | CODE          | NAME           |

   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                    | expect                                           |
      | conn_0 | False   | use dble_information                                                   | success                                          |
      | conn_0 | False   | select * from dble_child_table limit 1                                 | has{(('C2', 'C1', 'ID1', 'CODE1', 'CODE'),)}     |
      | conn_0 | False   | select * from dble_child_table order by paren_column desc limit 1      | has{(('C5', 'C4', 'ID', 'CODE', 'NAME'),)}       |
      | conn_0 | False   | select * from dble_child_table where paren_column like '%o%'           | length{(2)}                                      |
  #case select max/min
      | conn_0 | False   | select max(paren_column) from dble_child_table                | has{(('NAME',),)}    |
      | conn_0 | False   | select min(paren_column) from dble_child_table                | has{(('CODE',),)}    |
  #case select field and where [sub-query]
      | conn_0 | False   | select id,parent_id from dble_child_table where paren_column in (select paren_column from dble_child_table where increment_column ='ID')   | has{(('C5','C4',))}     |
#      | conn_0 | False   | select id,parent_id from dble_child_table where paren_column >all (select paren_column from dble_child_table where increment_column ='ID') | has{(('C5',), ('C4',))}     |
#      | conn_0 | False   | select id,parent_id from dble_child_table where paren_column <any (select paren_column from dble_child_table where increment_column ='ID') | has{(('C5',), ('C4',))}     |
#      | conn_0 | False   | select id,parent_id from dble_child_table where paren_column = (select paren_column from dble_child_table where increment_column ='ID') | has{(('C5',), ('C4',))}     |
      | conn_0 | False   | select id,parent_id from dble_child_table where paren_column = any (select paren_column from dble_child_table where increment_column ='ID') | has{(('C5','C4',))}     |

  #case update/delete
      | conn_0 | False   | delete from dble_child_table where id='c1'                 | Access denied for table 'dble_child_table'   |
      | conn_0 | False   | update dble_child_table set id = 'a' where id='c1'         | Access denied for table 'dble_child_table'   |
      | conn_0 | False   | insert into dble_child_table values ('a','1','a','1')      | Access denied for table 'dble_child_table'   |

  #case change sharding.xml delete some schema and reload
    Given delete the following xml segment
      | file         | parent         | child              |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}   |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" />
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_child_table_3"
      | conn   | toClose | sql                            | db               |
      | conn_0 | False   | select * from dble_child_table | dble_information |
     Then check resultset "dble_child_table_3" has not lines with following column values
      | id-0 | parent_id-1 | increment_column-2 | join_column-3 | paren_column-4 |
      | C2   | C1          | ID1                | CODE1         | CODE           |
      | C3   | C1          | ID2                | CODE2         | CODE           |
      | C5   | C4          | ID                 | CODE          | NAME           |

#@skip_restart
   Scenario:  table select join #6
    Given delete the following xml segment
      | file         | parent         | child                    |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}         |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn4" cron="/5 * * * * ? *" checkClass="CHECKSUM" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn3,dn2,dn4" function="date_default_rule" shardingColumn="id"/>
        <shardingTable name="er_parent" shardingNode="dn1,dn2,dn3,dn4" function="date_default_rule" shardingColumn="code" incrementColumn="id">
            <childTable name="er_child1" sqlMaxLimit="1000" joinColumn="code1" parentColumn="code" incrementColumn="id1"/>
            <childTable name="er_child2" joinColumn="code2" parentColumn="code" incrementColumn="id2"/>
        </shardingTable>
        <shardingTable name="parent" shardingNode="dn1,dn2" function="hash-two" shardingColumn="name" incrementColumn="code">
            <childTable name="child" joinColumn="code" parentColumn="name" incrementColumn="id"/>
        </shardingTable>
    </schema>
     <schema shardingNode="dn2" name="schema2" sqlMaxLimit="1000">
        <singleTable name="s1"  shardingNode="dn1" />
        <globalTable name="test2" shardingNode="dn1,dn2,dn3,dn4" cron="/5 * * * * ? *" checkClass="CHECKSUM" />
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform" shardingColumn="code"/>
        <shardingTable name="sharding_4_t3" shardingNode="dn1,dn2,dn3,dn4" function="fixed_nonuniform" shardingColumn="fix"/>
        <shardingTable name="sharding_4_t4" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform_string_rule" shardingColumn="rule"/>
        <shardingTable name="sharding_4_t5" shardingNode="dn1,dn2,dn3,dn4" function="fixed_nonuniform_string_rule" shardingColumn="fixed"/>
     </schema>
    <schema shardingNode="dn3" name="schema3">
        <singleTable name="s2"  shardingNode="dn2" />
        <globalTable name="test3" shardingNode="dn1,dn2" cron="/10 * * * * ?" checkClass="COUNT" />
        <globalTable name="test4" shardingNode="dn1,dn2,dn3" cron="0 /5 * * * ? *" checkClass="CHECKSUM" />
        <globalTable name="test5" shardingNode="dn1,dn3" />
    </schema>

     <function name="fixed_uniform" class="Hash">
        <property name="partitionCount">4</property>
        <property name="partitionLength">256</property>
     </function>
     <function name="fixed_nonuniform" class="Hash">
        <property name="partitionCount">2,1</property>
        <property name="partitionLength">256,512</property>
     </function>
     <function name="fixed_uniform_string_rule" class="StringHash">
        <property name="partitionCount">4</property>
        <property name="partitionLength">256</property>
        <property name="hashSlice">0:2</property>
     </function>
     <function name="fixed_nonuniform_string_rule" class="StringHash">
        <property name="partitionCount">2,1</property>
        <property name="partitionLength">256,512</property>
        <property name="hashSlice">0:2</property>
     </function>
     <function name="date_default_rule" class="Date">
        <property name="dateFormat">yyyy-MM-dd</property>
        <property name="sBeginDate">2016-12-01</property>
        <property name="sEndDate">2017-01-9</property>
        <property name="sPartionDay">10</property>
        <property name="defaultNode">0</property>
     </function>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    	<shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "1"
      | conn   | toClose | sql                            | db               |
      | conn_0 | False   | select * from dble_table,dble_child_table where dble_table.id ='C4' | dble_information |
    Then check resultset "1" has lines with following column values
| id-0   | name-1      | schema-2  | max_limit-3 | type-4  | id-5   | parent_id-6 | increment_column-7 | join_column-8 | paren_column-9 |
| C4   | er_child1 | schema1 |      1000 | CHILD | C4   | C3        | ID1              | CODE1       | CODE         |
| C4   | er_child1 | schema1 |      1000 | CHILD | C5   | C3        | ID2              | CODE2       | CODE         |
| C4   | er_child1 | schema1 |      1000 | CHILD | C7   | C6        | ID               | CODE        | NAME         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "2"
       | conn   | toClose | sql                            | db               |
       | conn_0 | False   | select a.* from dble_table a,dble_child_table b where a.id = 'C4' and b.parent_id = 'C3'; | dble_information |
    Then check resultset "2" has lines with following column values
| id-0   | name-1      | schema-2  | max_limit-3 | type-4  |
| C4   | er_child1 | schema1 |      1000 | CHILD |
| C4   | er_child1 | schema1 |      1000 | CHILD |

