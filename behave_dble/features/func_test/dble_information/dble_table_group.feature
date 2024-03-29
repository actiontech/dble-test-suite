# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_table test


  Scenario:  dble_table  table #1
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
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                         | expect       | db               |
      | conn_0 | True    | desc dble_table             | length{(5)}  | dble_information |

    #case change sharding/user.xml add some schema and reload
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
        <globalTable name="global1" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4" shardingNode="dn3,dn1,dn4,dn2" function="hash-four" shardingColumn="id"/>
        <shardingTable name="er_parent" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
            <childTable name="er_child" sqlMaxLimit="90" joinColumn="id" parentColumn="id"/>
        </shardingTable>
    </schema>

     <schema shardingNode="dn2" name="schema2" sqlMaxLimit="1000">
        <singleTable name="sing1"  shardingNode="dn1" />
        <shardingTable name="sharding_3" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="id"/>
        <globalTable name="global2" shardingNode="dn1,dn2,dn3,dn4" />
     </schema>

    <schema shardingNode="dn4" name="schema3">
        <singleTable name="sing2"  shardingNode="dn2" />
    </schema>

    <schema shardingNode="dn6" name="schema4">
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3,schema4"/>
    """
    Then execute admin cmd "reload @@config"
   #clear all table if exists other tables
    Given execute oscmd in "dble-1"
       """
       mysql -uroot -p111111 -P9066 -h172.100.9.1 -Ddble_information -e "select concat('drop table if exists ',name,';') as 'select 1;' from dble_table" >/opt/dble/test.sql && \
       mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "source /opt/dble/test.sql" && \
       mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema2 -e "source /opt/dble/test.sql" && \
       mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema3 -e "source /opt/dble/test.sql" && \
       mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema4 -e "source /opt/dble/test.sql"
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect       | db               |
      | conn_1 | True    | show tables                 | length{(0)}  | schema1          |
      | conn_1 | True    | show tables                 | length{(0)}  | schema2          |
      | conn_1 | True    | show tables                 | length{(0)}  | schema3          |
      | conn_1 | True    | show tables                 | length{(0)}  | schema4          |

   # case check "SHARDING" "GLOBAL" "SINGLE" "CHILD" table
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_table_2"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | select * from dble_table  | dble_information |
    Then check resultset "dble_table_2" has lines with following column values
      | id-0 | name-1     | schema-2 | max_limit-3 | type-4   |
      | C1   | global1    | schema1  | 100         | GLOBAL   |
      | C2   | sharding_2 | schema1  | 100         | SHARDING |
      | C3   | sharding_4 | schema1  | 100         | SHARDING |
      | C4   | er_parent  | schema1  | 100         | SHARDING |
      | C5   | er_child   | schema1  | 90          | CHILD    |
      | C6   | sing1      | schema2  | 1000        | SINGLE   |
      | C7   | sharding_3 | schema2  | 1000        | SHARDING |
      | C8   | global2    | schema2  | 1000        | GLOBAL   |
      | C9   | sing2      | schema3  | -1          | SINGLE   |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                  | expect       | db               |
      | conn_0 | True    | select * from dble_table             | length{(9)}  | dble_information |
  #case create new tables to check "NO_SHARDING" table,the vertical table is special NO_SHARDING table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | expect  | db      | timeout |
      | conn_1 | True    | drop table if exists schema1.no_s1      | success | schema1 | 6,2     |
      | conn_1 | True    | create table schema1.no_s1 (id int)     | success | schema1 |         |
      | conn_1 | True    | drop table if exists schema2.no_s2      | success | schema2 |         |
      | conn_1 | True    | create table schema2.no_s2 (id int)     | success | schema2 |         |
      | conn_1 | True    | drop table if exists schema3.no_s3      | success | schema3 |         |
      | conn_1 | True    | create table schema3.no_s3 (id int)     | success | schema3 |         |
      | conn_1 | True    | drop table if exists schema4.vertical   | success | schema4 |         |
      | conn_1 | True    | create table schema4.vertical (id int)  | success | schema4 |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                  | expect        | db               |
      | conn_0 | false   | select * from dble_table             | length{(13)}  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_table_3"
      | conn   | toClose | sql                                                 | db               |
      | conn_0 | True    | select * from dble_table where type ='NO_SHARDING'  | dble_information |
    Then check resultset "dble_table_3" has lines with following column values
      | name-1     | schema-2 | max_limit-3 | type-4      |
      | no_s1      | schema1  | 100         | NO_SHARDING |
      | no_s2      | schema2  | 1000        | NO_SHARDING |
      | no_s3      | schema3  | -1          | NO_SHARDING |
      | vertical   | schema4  | -1          | NO_SHARDING |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4         | success | schema1 |
      | conn_1 | False   | drop table if exists er_parent          | success | schema1 |
      | conn_1 | True    | drop table if exists schema1.no_s1      | success | schema1 |
      | conn_1 | True    | drop table if exists schema2.no_s2      | success | schema2 |
      | conn_1 | True    | drop table if exists schema3.no_s3      | success | schema3 |
      | conn_1 | True    | drop table if exists schema4.vertical   | success | schema4 |

   Scenario:  dble_global_table table #2
  #case desc dble_global_table check metadata
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_global_table_1"
      | conn   | toClose | sql                    | db               |
      | conn_0 | False   | desc dble_global_table | dble_information |
    Then check resultset "dble_global_table_1" has lines with following column values
      | Field-0     | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id          | varchar(64) | NO     | PRI   | None      |         |
      | check       | varchar(5)  | NO     |       | None      |         |
      | check_class | varchar(64) | YES    |       | None      |         |
      | cron        | varchar(32) | YES    |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                         | expect       | db               |
      | conn_0 | True    | desc dble_global_table      | length{(4)}  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_global_table_2"
      | conn   | toClose | sql                             | db               |
      | conn_0 | False   | select * from dble_global_table | dble_information |
    Then check resultset "dble_global_table_2" has lines with following column values
      | check-1 | check_class-2 | cron-3      |
      | false   | CHECKSUM      | 0 0 0 * * ? |
      | false   | CHECKSUM      | 0 0 0 * * ? |
    #case change sharding.xml add checkClass and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn4" name="schema2" sqlMaxLimit="100">
        <globalTable name="global3" shardingNode="dn1,dn2,dn3,dn4" cron="/5 * * * * ? *" checkClass="CHECKSUM" />
    </schema>
     <schema shardingNode="dn1" name="schema3" >
        <globalTable name="global4" shardingNode="dn1,dn3,dn5" cron="/10 * * * * ?" checkClass="COUNT" />
     </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_global_table_3"
      | conn   | toClose | sql                             | db               |
      | conn_0 | True    | select * from dble_global_table | dble_information |
    Then check resultset "dble_global_table_3" has lines with following column values
      | check-1 | check_class-2 | cron-3         |
      | false   | CHECKSUM      | 0 0 0 * * ?    |
      | false   | CHECKSUM      | 0 0 0 * * ?    |
      | true    | CHECKSUM      | /5 * * * * ? * |
      | true    | COUNT         | /10 * * * * ?  |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "6,2" times
    """
    Global check start .........global3
    Global check start .........global4
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
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                         | expect       | db               |
      | conn_0 | True    | desc dble_sharding_table    | length{(5)}  | dble_information |
  #case change sharding.xml add some schema/function  and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
     <schema shardingNode="dn4" name="schema2" sqlMaxLimit="100">
        <shardingTable name="sharding_incrementColumn" shardingNode="dn4,dn2" function="hash-two" shardingColumn="two" incrementColumn="id"/>
        <shardingTable name="sharding_sqlRequiredSharding" shardingNode="dn3,dn1,dn2" function="hash-three" shardingColumn="three" sqlRequiredSharding="true"/>
    </schema>

     <schema shardingNode="dn1" name="schema3" >
        <shardingTable name="sharding_fixed_uniform" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform" shardingColumn="code"/>
        <shardingTable name="sharding_fixed_nonuniform" shardingNode="dn1,dn4,dn3,dn2" function="fixed_nonuniform" shardingColumn="fix"/>
        <shardingTable name="sharding_fixed_uniform_string_rule" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform_string_rule" shardingColumn="rule"/>
        <shardingTable name="sharding_fixed_nonuniform_string_rule" shardingNode="dn2,dn1,dn4,dn3" function="fixed_nonuniform_string_rule" shardingColumn="fixed"/>
        <shardingTable name="sharding_date_default_rule" shardingNode="dn1,dn2,dn3,dn4" function="date_default_rule" shardingColumn="date"/>
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
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_table_2"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from dble_sharding_table | dble_information |
    Then check resultset "dble_sharding_table_2" has lines with following column values
      | increment_column-1 | sharding_column-2 | sql_required_sharding-3 | algorithm_name-4             |
      | None               | ID                | false                   | hash-two                     |
      | None               | ID                | false                   | hash-four                    |
      | ID                 | TWO               | false                   | hash-two                     |
      | None               | THREE             | true                    | hash-three                   |
      | None               | CODE              | false                   | fixed_uniform                |
      | None               | FIX               | false                   | fixed_nonuniform             |
      | None               | RULE              | false                   | fixed_uniform_string_rule    |
      | None               | FIXED             | false                   | fixed_nonuniform_string_rule |
      | None               | DATE              | false                   | date_default_rule            |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                  | expect        | db               |
      | conn_0 | True    | select * from dble_sharding_table    | length{(9)}  | dble_information |


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
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                                           | expect         | db               |
      | conn_0 | true     | desc dble_table_sharding_node                                                                 | length{(3)}    | dble_information |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
     <schema shardingNode="dn4" name="schema2" sqlMaxLimit="100">
        <shardingTable name="sharding_incrementColumn" shardingNode="dn4,dn2" function="hash-two" shardingColumn="two" incrementColumn="id"/>
        <shardingTable name="sharding_sqlRequiredSharding" shardingNode="dn3,dn1,dn2" function="hash-three" shardingColumn="three" sqlRequiredSharding="true"/>
    </schema>

     <schema shardingNode="dn1" name="schema3" >
        <shardingTable name="sharding_fixed_uniform" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform" shardingColumn="code"/>
        <shardingTable name="sharding_fixed_nonuniform" shardingNode="dn1,dn4,dn3,dn2" function="fixed_nonuniform" shardingColumn="fix"/>
        <shardingTable name="sharding_fixed_uniform_string_rule" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform_string_rule" shardingColumn="rule"/>
        <shardingTable name="sharding_fixed_nonuniform_string_rule" shardingNode="dn2,dn1,dn4,dn3" function="fixed_nonuniform_string_rule" shardingColumn="fixed"/>
        <shardingTable name="sharding_date_default_rule" shardingNode="dn1,dn2,dn3,dn4" function="date_default_rule" shardingColumn="date"/>
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
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                                           | expect         | db               |
      | conn_0 | False    | select * from dble_table_sharding_node                                                        | length{(35)}   | dble_information |
      | conn_0 | False    | select * from dble_table_sharding_node where order in (3)                                     | length{(7)}    | dble_information |
      | conn_0 | True     | select * from dble_table_sharding_node where sharding_node = 'dn3' or sharding_node = 'dn4'   | length{(16)}   | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                           | expect  | db      | charset | timeout |
      | conn_1 | False   | drop table if exists sharding_4_t1                                            | success | schema1 | utf8mb4 | 6,2     |
      | conn_1 | False   | create table sharding_4_t1 (id int(10),name char(10)) DEFAULT CHARSET=utf8mb4 | success | schema1 | utf8mb4 |         |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "dble_table_sharding_node_4"
      | conn   | toClose | sql                                                                                  | db      |
      | conn_1 | true    | explain insert into sharding_4_t1 values (1,'顺序3'),(2,'顺序1'),(3,'顺序4'),(4,'顺序2') | schema1 |
    Then check resultset "dble_table_sharding_node_4" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                    |
      | dn1             | BASE SQL | INSERT INTO sharding_4_t1 VALUES (4, '顺序2') |
      | dn2             | BASE SQL | INSERT INTO sharding_4_t1 VALUES (1, '顺序3') |
      | dn3             | BASE SQL | INSERT INTO sharding_4_t1 VALUES (2, '顺序1') |
      | dn4             | BASE SQL | INSERT INTO sharding_4_t1 VALUES (3, '顺序4') |



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
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect         | db               |
      | conn_0 | False    | desc dble_child_table               | length{(5)}    | dble_information |
      | conn_0 | False    | select * from dble_child_table      | length{(0)}    | dble_information |
  #case change sharding.xml and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
     <schema shardingNode="dn2" name="schema1" >
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-two" shardingColumn="code" >
            <childTable name="er_child1" joinColumn="code1" parentColumn="code" incrementColumn="id1"/>
            <childTable name="er_child2" joinColumn="code2" parentColumn="code" />
        </shardingTable>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn4,dn3,dn2" function="hash-four" shardingColumn="fix">
            <childTable name="er_child3" joinColumn="code" parentColumn="fix" incrementColumn="id"/>
        </shardingTable>
     </schema>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_child_table_2"
      | conn   | toClose | sql                            | db               |
      | conn_0 | True    | select * from dble_child_table | dble_information |
     Then check resultset "dble_child_table_2" has lines with following column values
      | increment_column-2 | join_column-3 | paren_column-4 |
      | ID1                | CODE1         | CODE           |
      | None               | CODE2         | CODE           |
      | ID                 | CODE          | FIX            |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect         | db               |
      | conn_0 | False    | select * from dble_child_table      | length{(3)}    | dble_information |


   Scenario:  supported select and unsupported dml
#case count filed values
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                         | expect          |
      | conn_0 | False    | use dble_information                        | success         |
#case unsupported update/delete/insert
      | conn_0 | False   | delete from dble_table where schema='schema1'              | Access denied for table 'dble_table'                     |
      | conn_0 | False   | update dble_table set schema = 'a' where schema='schema1'  | Access denied for table 'dble_table'                     |
      | conn_0 | False   | insert into dble_table values ('a','1',2,'3')              | Access denied for table 'dble_table'                     |
      | conn_0 | False   | delete from dble_global_table where id='c1'                | Access denied for table 'dble_global_table'              |
      | conn_0 | False   | update dble_global_table set id = 'a' where id='c1'        | Access denied for table 'dble_global_table'              |
      | conn_0 | False   | insert into dble_global_table values ('a','1','2','3')     | Access denied for table 'dble_global_table'              |
      | conn_0 | False   | delete from dble_sharding_table where id='c1'              | Access denied for table 'dble_sharding_table'            |
      | conn_0 | False   | update dble_sharding_table set id = 'a' where id='c1'      | Access denied for table 'dble_sharding_table'            |
      | conn_0 | False   | insert into dble_sharding_table values ('a','1','2','3')   | Access denied for table 'dble_sharding_table'            |
      | conn_0 | False   | delete from dble_table_sharding_node where id='c1'         | Access denied for table 'dble_table_sharding_node'       |
      | conn_0 | False   | update dble_table_sharding_node set id = 'a' where id='c1' | Access denied for table 'dble_table_sharding_node'       |
      | conn_0 | False   | insert into dble_table_sharding_node values ('a','1')      | Access denied for table 'dble_table_sharding_node'       |
      | conn_0 | False   | delete from dble_child_table where id='c1'                 | Access denied for table 'dble_child_table'               |
      | conn_0 | False   | update dble_child_table set id = 'a' where id='c1'         | Access denied for table 'dble_child_table'               |
      | conn_0 | False   | insert into dble_child_table values ('a','1','a','1')      | Access denied for table 'dble_child_table'               |
#case supported select limit /order by/where like
      | conn_0 | False   | select * from dble_table limit 1                           | success    |
      | conn_0 | False   | select * from dble_table order by id desc limit 1          | success    |
      | conn_0 | False   | select * from dble_table where name like "ver%"            | success    |
#case supported select max/min
      | conn_0 | False   | select max(algorithm_name) from dble_sharding_table        | success             |
      | conn_0 | False   | select min(algorithm_name) from dble_sharding_table        | success             |
      | conn_0 | False   | select max(order) from dble_table_sharding_node            | success             |
      | conn_0 | False   | select min(order) from dble_table_sharding_node            | success             |
      | conn_0 | False   | select max(paren_column) from dble_child_table             | success             |
      | conn_0 | False   | select min(paren_column) from dble_child_table             | success             |
      | conn_0 | False   | select max(check_class) from dble_global_table             | success             |
      | conn_0 | False   | select min(check_class) from dble_global_table             | success             |
#case supported select field and where [sub-query]
      | conn_0 | False   | select id,parent_id from dble_child_table where paren_column in (select paren_column from dble_child_table where increment_column ='ID')    | success    |
      | conn_0 | False   | select id,parent_id from dble_child_table where paren_column >all (select paren_column from dble_child_table where increment_column ='ID')  | success    |
      | conn_0 | False   | select id,parent_id from dble_child_table where paren_column <any (select paren_column from dble_child_table where increment_column ='ID')  | success    |
      | conn_0 | False   | select id,parent_id from dble_child_table where paren_column = (select paren_column from dble_child_table where increment_column ='ID')     | success    |
      | conn_0 | False   | select id,parent_id from dble_child_table where paren_column = any (select paren_column from dble_child_table where increment_column ='ID') | success    |
#case supported select join
      | conn_0 | False   | select * from dble_table where abs(id)="11111"     | length{(0)}    |
      | conn_0 | true    | select * from dble_table a left join dble_schema b on a.name =b.name order by a.name | success    |