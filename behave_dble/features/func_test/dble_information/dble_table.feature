# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_table test

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

  #case change sharding.xml and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="er_parent" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
            <childTable name="er_child" joinColumn="id" parentColumn="id"/>
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
      | er_child      | schema1  | 100         | CHILD    |
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
      | name-1 s| schema-2 | max_limit-3 | type-4      |
      | no_s1   | schema1  | None        | NO_SHARDING |
      | no_s2   | schema2  | None        | NO_SHARDING |
      | no_s3   | schema3  | None        | NO_SHARDING |


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
      | check-1 | check_class-2 | cron-3      |
      | false   | CHECKSUM      | 0 0 0 * * ? |
      | false   | CHECKSUM      | 0 0 0 * * ? |
  #case change sharding.xml and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn4" cron="0 /1 * * * ? *" checkClass="CHECKSUM" />
    </schema>
     <schema shardingNode="dn1" name="schema2" sqlMaxLimit="1000">
        <globalTable name="test2" shardingNode="dn1,dn2" cron="0 0 5 * * ?" checkClass="COUNT" />
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
      | check-1 | check_class-2 | cron-3         |
      | true    | CHECKSUM      | 0 /1 * * * ? * |
      | true    | COUNT         | 0 0 5 * * ?    |
    Given sleep "61" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    Global check start .........test1
    """

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

  #case change sharding.xml and reload
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
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_table_2"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from dble_sharding_table | dble_information |
    Then check resultset "dble_sharding_table_2" has lines with following column values
      | increment_column-1 | sharding_column-2 | sql_required_sharding-3 | algorithm_name-4             |
      | None               | ID                | false                   | hash-two                     |
      | ID                 | TWO               | false                   | hash-two                     |
      | None               | THREE             | true                    | hash-three                   |
      | None               | FOUR              | false                   | hash-four                    |
      | None               | DATE              | false                   | date_default_rule            |
      | None               | CODE              | false                   | fixed_uniform                |
      | None               | FIX               | false                   | fixed_nonuniform             |
      | None               | RULE              | false                   | fixed_uniform_string_rule    |
      | None               | FIXED             | false                   | fixed_nonuniform_string_rule |
  #case select with dble_algorithm

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
      | C3   | dn1             | 0       |
      | C3   | dn2             | 1       |
      | C3   | dn3             | 2       |
      | C3   | dn4             | 3       |
  #case select join sharding_node



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
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="er_parent" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="code" incrementColumn="id1">
            <childTable name="er_child" joinColumn="code1" parentColumn="code" incrementColumn="id2"/>
        </shardingTable>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_child_table_2"
      | conn   | toClose | sql                            | db               |
      | conn_0 | False   | select * from dble_child_table | dble_information |
     Then check resultset "dble_child_table_2" has lines with following column values
      | id-0 | parent_id-1 | increment_column-2 | join_column-3 | paren_column-4 |
      | C2   | C1          | ID2                | CODE1         | CODE           |















