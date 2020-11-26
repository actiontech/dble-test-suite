# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  show databases/use dble_information/show tables [like]

 Scenario:  show databases/use dble_information/show tables [like] #1

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                    | expect                                                                 |
#case  begin query not use schema
      | conn_0 | False   | show tables                            | No database selected                                                   |
      | conn_0 | False   | show tables like 'dble%'               | No database selected                                                   |
      | conn_0 | False   | desc version                           | No database selected                                                   |
      | conn_0 | False   | select * from version                  | get error call manager command Schema name or Table name is null!      |
#case  begin query with error shcema or not exists schema
      | conn_0 | False   | desc dble_infor.version                | Unknown database 'dble_infor'                                          |
      | conn_0 | False   | describe schema1.version               | Unknown database 'schema1'                                             |
      | conn_0 | False   | select * from schema1.version          | get error call manager command schema schema1 doesn't exist!           |
#case show databases correct or erroneous spelling
      | conn_0 | False   | show database                          | Unsupported statement                                                  |
      | conn_0 | False   | show databasesl                        | Unsupported statement                                                  |
      | conn_0 | False   | show databases                         | has{('dble_information')}                                              |
#case query with  correct schema
      | conn_0 | False   | desc dble_information.version          | has{('version', 'varchar(64)', 'NO', 'PRI', None, '')}                 |
      | conn_0 | False   | describe dble_information.version      | has{('version', 'varchar(64)', 'NO', 'PRI', None, '')}                 |
      | conn_0 | False   | select * from dble_information.version | has{('version')}                                                       |
#case use dble_information correct or erroneous spelling
      | conn_0 | False   | use dble_informatio                    | Unknown database 'dble_informatio'                                     |
      | conn_0 | False   | use dble_information                   | success                                                                |
#case  show tables [like]  correct or erroneous spelling
      | conn_0 | False   | show table                             | Unsupported statement                                                  |
      | conn_0 | False   | show full tables                       | Unsupported statement                                                  |
      | conn_0 | False   | show columns from version              | Unsupported statement                                                  |
      | conn_0 | False   | show tables                            | has{('Tables_in_dble_information')}                                    |
      | conn_0 | False   | show tables like '%s%'                 | has{('Tables_in_dble_information (%s%)')}                              |
      | conn_0 | False   | show tables like 'version'             | has{('Tables_in_dble_information (version)')}                          |
#case desc/describe
      | conn_0 | False   | desc version                           | has{('version', 'varchar(64)', 'NO', 'PRI', None, '')}                 |
      | conn_0 | False   | describe version                       | has{('version', 'varchar(64)', 'NO', 'PRI', None, '')}                 |
#case correct or erroneous spelling
      | conn_0 | False   | descc version                          | Unsupported statement                                                  |
      | conn_0 | False   | desc versio                            | Table `dble_information`.`versio` doesn't exist                        |
      | conn_0 | False   | select * froom version                 | Unsupported statement                                                  |
      | conn_0 | False   | select * from versio                   | get error call manager command table versio doesn't exist!             |
#case Unsupported create database/table or alter table
      | conn_0 | False   | create database test                                       | The sql did not match create\|drop database @@shardingNode ='dn......' |
      | conn_0 | False   | create table test (id int)                                 | The sql did not match create\|drop database @@shardingNode ='dn......' |
      | conn_0 | False   | drop database dble_information                             | The sql did not match create\|drop database @@shardingNode ='dn......' |
      | conn_0 | False   | drop table dble_status                                     | The sql did not match create\|drop database @@shardingNode ='dn......' |
      | conn_0 | False   | alter table version add id int                             | Unsupported statement                                                  |
      | conn_0 | False   | alter table dble_status drop variable_value                | Unsupported statement                                                  |
      | conn_0 | False   | alter table dble_schema modify sql_max_limit varchar       | Unsupported statement                                                  |
      | conn_0 | False   | alter table dble_schema change name sql_max_limit varchar  | Unsupported statement                                                  |
      | conn_0 | False   | alter table dble_schema modify name NOT NULL DEFAULT 100   | Unsupported statement                                                  |
      | conn_0 | False   | alter table dble_sharding_node rename to test              | Unsupported statement                                                  |
#case supported lower_case_table_names DBLE0REQ-576
       | conn_0 | False   | use dble_information       | success |
       | conn_0 | False   | select * from dble_Schema  | success |
       | conn_0 | False   | select ID from dble_Table  | success |
#case show all tables and delete demo table
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "tables_1"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | show tables               | dble_information |
    Then check resultset "tables_1" has lines with following column values
      | Tables_in_dble_information-0 |
      | backend_connections          |
      | backend_variables            |
      | dble_algorithm               |
      | dble_blacklist               |
      | dble_child_table             |
      | dble_db_group                |
      | dble_db_instance             |
      | dble_ddl_lock                |
      | dble_entry                   |
      | dble_entry_db_group          |
      | dble_entry_schema            |
      | dble_entry_table_privilege   |
      | dble_global_table            |
      | dble_processor               |
      | dble_reload_status           |
      | dble_rw_split_entry          |
      | dble_schema                  |
      | dble_sharding_node           |
      | dble_sharding_table          |
      | dble_status                  |
      | dble_table                   |
      | dble_table_sharding_node     |
      | dble_thread_pool             |
      | dble_thread_usage            |
      | dble_variables               |
      | dble_xa_session              |
      | processlist                  |
      | session_connections          |
      | session_variables            |
    Then check resultset "tables_1" has not lines with following column values
      | Tables_in_dble_information-0 |
      | demotest1                    |
      | demotest2                    |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                  | expect       | db               |
      | conn_0 | False   | show tables                          | length{(30)} | dble_information |
 #case The query needs to be printed in the log，when management commands not supported by druid   https://github.com/actiontech/dble/issues/1977
    Then execute sql in "dble-1" in "admin" mode
       | conn   | toClose | sql          | expect                |
       | conn_0 | true    | show VARINT  | Unsupported statement |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    Unsupported show:show VARINT
    """

  Scenario:  table select supported #2  todo:add some special case
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
      | conn   | toClose | sql                                                                 | db               |
      | conn_0 | False   | select * from dble_table,dble_child_table where dble_table.id ='C4' | dble_information |
    Then check resultset "1" has lines with following column values
      | id-0 | name-1    | schema-2 | max_limit-3 | type-4 | id-5 | parent_id-6 | increment_column-7 | join_column-8 | paren_column-9 |
      | C4   | er_child1 | schema1  | 1000        | CHILD  | C4   | C3          | ID1                | CODE1         | CODE           |
      | C4   | er_child1 | schema1  | 1000        | CHILD  | C5   | C3          | ID2                | CODE2         | CODE           |
      | C4   | er_child1 | schema1  | 1000        | CHILD  | C7   | C6          | ID                 | CODE          | NAME           |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "2"
      | conn   | toClose | sql                                                                                      | db               |
      | conn_0 | False   | select a.* from dble_table a,dble_child_table b where a.id = 'C4' and b.parent_id = 'C3' | dble_information |
    Then check resultset "2" has lines with following column values
      | id-0 | name-1    | schema-2 | max_limit-3 | type-4 |
      | C4   | er_child1 | schema1  | 1000        | CHILD  |
      | C4   | er_child1 | schema1  | 1000        | CHILD  |




