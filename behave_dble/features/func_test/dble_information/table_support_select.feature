# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  show databases/use dble_information/show tables [like]

  Scenario:  show databases/use dble_information/show tables [like] #1

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                    | expect                                  |
#case  begin query not use schema
      | conn_0 | False   | show tables                            | No database selected                    |
      | conn_0 | False   | show tables like 'dble%'               | No database selected                    |
      | conn_0 | False   | desc version                           | No database selected                    |
      | conn_0 | False   | select * from version                  | No database selected                    |
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
      | dble_config                  |
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
      | sql_log                                               |
      | sql_log_by_tx_by_entry_by_user                        |
      | sql_statistic_by_associate_tables_by_entry_by_user    |
      | sql_statistic_by_frontend_by_backend_by_entry_by_user |
      | sql_statistic_by_table_by_user_by_entry               |
      | version                                               |
    Then check resultset "tables_1" has not lines with following column values
      | Tables_in_dble_information-0 |
      | demotest1                    |
      | demotest2                    |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                  | expect       | db               |
      | conn_0 | False   | show tables                          | length{(36)} | dble_information |
 #case The query needs to be printed in the log，when management commands not supported by druid github:issues/1977
    Then execute sql in "dble-1" in "admin" mode
       | conn   | toClose | sql          | expect                |
       | conn_0 | true    | show VARINT  | Unsupported statement |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    Unsupported show:show VARINT
    """


  Scenario:  table select supported #2  todo:add some special case

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

     <schema shardingNode="dn4" name="schema3" sqlMaxLimit="100">
        <globalTable name="global3" shardingNode="dn1,dn2,dn3,dn4" cron="/5 * * * * ? *" checkClass="CHECKSUM" />
        <shardingTable name="sharding_incrementColumn" shardingNode="dn4,dn1" function="hash-two" shardingColumn="two" incrementColumn="id"/>
        <shardingTable name="sharding_sqlRequiredSharding" shardingNode="dn3,dn1,dn2" function="hash-three" shardingColumn="three" sqlRequiredSharding="true"/>
        <shardingTable name="sharding_sqlRequiredSharding1" shardingNode="dn3,dn1,dn2" function="hash-three" shardingColumn="three" sqlRequiredSharding="true"/>
    </schema>

     <schema shardingNode="dn6" name="schema4" >
        <globalTable name="global4" shardingNode="dn1,dn5,dn3" cron="/10 * * * * ?" checkClass="COUNT" />
        <globalTable name="global5" shardingNode="dn6,dn4,dn2" cron="0 /5 * * * ? *" checkClass="CHECKSUM" />
        <shardingTable name="sharding_fixed_uniform" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform" shardingColumn="code" >
            <childTable name="er_child1" joinColumn="code1" parentColumn="code" incrementColumn="id1"/>
            <childTable name="er_child2" joinColumn="code2" parentColumn="code" />
        </shardingTable>
        <shardingTable name="sharding_fixed_nonuniform" shardingNode="dn1,dn4,dn3,dn2" function="fixed_nonuniform" shardingColumn="fix">
            <childTable name="er_child3" joinColumn="code" parentColumn="fix" incrementColumn="id"/>
        </shardingTable>
        <shardingTable name="sharding_fixed_uniform_string_rule" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform_string_rule" shardingColumn="rule"/>
        <shardingTable name="sharding_fixed_nonuniform_string_rule" shardingNode="dn2,dn1,dn4,dn3" function="fixed_nonuniform_string_rule" shardingColumn="fixed"/>
        <shardingTable name="sharding_date_default_rule" shardingNode="dn1,dn2,dn3,dn4" function="date_default_rule" shardingColumn="date"/>
     </schema>

     <schema shardingNode="dn6" name="schema5" >
     </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />

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
    <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3,schema4,schema5"/>
    """
    Then execute admin cmd "reload @@config"
#clear all table if exists table and restart dble to reset id values
    Given execute oscmd in "dble-1"
       """
       mysql -uroot -p111111 -P9066 -h172.100.9.1 -Ddble_information -e "select concat('drop table if exists ',name,';') as 'select 1;' from dble_table" >/opt/dble/test.sql && \
       mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "source /opt/dble/test.sql" && \
       mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema2 -e "source /opt/dble/test.sql" && \
       mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema3 -e "source /opt/dble/test.sql" && \
       mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema4 -e "source /opt/dble/test.sql" && \
       mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema5 -e "source /opt/dble/test.sql"
      """
    Given Restart dble in "dble-1" success
#prepare
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                        | expect  | db      | charset |
      | conn_1 | False   | create table no_s1 (id int) DEFAULT CHARSET=utf8mb4                        | success | schema1 | utf8mb4 |
      | conn_1 | False   | create table schema2.no_s2 (id int) DEFAULT CHARSET=utf8mb4                | success | schema1 | utf8mb4 |
      | conn_1 | False   | create table schema3.no_s3 (id int) DEFAULT CHARSET=utf8mb4                | success | schema1 | utf8mb4 |
      | conn_1 | False   | create table schema5.vertical (id int) DEFAULT CHARSET=utf8mb4             | success | schema1 | utf8mb4 |
      | conn_1 | False   | create table sharding_4 (id int(10),name char(10)) DEFAULT CHARSET=utf8mb4 | success | schema1 | utf8mb4 |
      | conn_1 | False   | create table er_parent (id int(10),name char(10)) DEFAULT CHARSET=utf8mb4  | success | schema1 | utf8mb4 |
#case supported subquery position between select and from
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "1"
      | conn   | toClose | sql                                                                                                | db               |
      | conn_0 | True    | select *, (select id from dble_child_table where id='C5') from dble_table order by name desc limit 5 | dble_information |
    Then check resultset "1" has lines with following column values
      | name-1                        | schema-2 | max_limit-3 | type-4      | ( SELECT id FROM dble_child_table WHERE id = 'C5')-5 |
      | vertical                      | schema5  |          -1 | NO_SHARDING | C5                                                   |
      | sing1                         | schema2  |        1000 | SINGLE      | C5                                                   |
      | sharding_sqlRequiredSharding1 | schema3  |         100 | SHARDING    | C5                                                   |
      | sharding_sqlRequiredSharding  | schema3  |         100 | SHARDING    | C5                                                   |
      | sharding_incrementColumn      | schema3  |         100 | SHARDING    | C5                                                   |
#case supported  subquery with [not] in
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "2"
      | conn   | toClose | sql                                                                                                        | db               |
      | conn_0 | True    | select a.* from dble_table a ,dble_sharding_table b where a.id = b.id and b.id in ('C1','C6','C10','C19')  | dble_information |
    Then check resultset "2" has lines with following column values
      | id-0 | name-1                            | schema-2 | max_limit-3 | type-4   |
      | C10  | sharding_incrementColumn          | schema3  | 100         | SHARDING |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "3"
      | conn   | toClose | sql                                                                                       | db               |
      | conn_0 | True    | select * from dble_table where id not IN (select id from dble_sharding_table) order by id | dble_information |
    Then check resultset "3" has lines with following column values
      | id-0 | name-1    | schema-2 | max_limit-3 | type-4      |
      | C1   | global1   | schema1 |          100 | GLOBAL      |
      | C13  | global4   | schema4 |           -1 | GLOBAL      |
      | C14  | global5   | schema4 |           -1 | GLOBAL      |
      | C16  | er_child1 | schema4 |           -1 | CHILD       |
      | C17  | er_child2 | schema4 |           -1 | CHILD       |
      | C19  | er_child3 | schema4 |           -1 | CHILD       |
      | C5   | er_child  | schema1 |           90 | CHILD       |
      | C6   | sing1     | schema2 |         1000 | SINGLE      |
      | C8   | global2   | schema2 |         1000 | GLOBAL      |
      | C9   | global3   | schema3 |          100 | GLOBAL      |
      | M1   | no_s1     | schema1 |          100 | NO_SHARDING |
      | M2   | no_s2     | schema2 |         1000 | NO_SHARDING |
      | M3   | no_s3     | schema3 |          100 | NO_SHARDING |
      | M4   | vertical  | schema5 |           -1 | NO_SHARDING |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "4"
      | conn   | toClose | sql                                                                                                                                  | db               |
      | conn_0 | True    | SELECT * FROM dble_table a LEFT JOIN dble_schema b ON a.schema = b.NAME where a.id NOT IN (SELECT id FROM dble_table_sharding_node)  | dble_information |
    Then check resultset "4" has lines with following column values
      | id-0 | name-1   | schema-2 | max_limit-3 | type-4      | name-5  | sharding_node-6 | sql_max_limit-7 |
      | M1   | no_s1    | schema1  | 100         | NO_SHARDING | schema1 | dn1             | 100             |
      | M2   | no_s2    | schema2  | 1000        | NO_SHARDING | schema2 | dn2             | 1000            |
      | M3   | no_s3    | schema3  | 100         | NO_SHARDING | schema3 | dn4             | 100             |
      | M4   | vertical | schema5  | -1          | NO_SHARDING | schema5 | dn6             | -1              |
#case supported subquery with some
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "5"
      | conn   | toClose | sql                                                                                                          | db               |
      | conn_0 | True    | select * from dble_table where id <>some(select max(id) from dble_table_sharding_node) and id not like "M%"  | dble_information |
    Then check resultset "5" has lines with following column values
      | id-0 | name-1                                | schema-2 | max_limit-3 | type-4   |
      | C1   | global1                               | schema1 |          100 | GLOBAL   |
      | C2   | sharding_2                            | schema1 |          100 | SHARDING |
      | C3   | sharding_4                            | schema1 |          100 | SHARDING |
      | C4   | er_parent                             | schema1 |          100 | SHARDING |
      | C5   | er_child                              | schema1 |           90 | CHILD    |
      | C6   | sing1                                 | schema2 |         1000 | SINGLE   |
      | C7   | sharding_3                            | schema2 |         1000 | SHARDING |
      | C8   | global2                               | schema2 |         1000 | GLOBAL   |
      | C10  | sharding_incrementColumn              | schema3 |          100 | SHARDING |
      | C11  | sharding_sqlRequiredSharding          | schema3 |          100 | SHARDING |
      | C12  | sharding_sqlRequiredSharding1         | schema3 |          100 | SHARDING |
      | C13  | global4                               | schema4 |           -1 | GLOBAL   |
      | C14  | global5                               | schema4 |           -1 | GLOBAL   |
      | C15  | sharding_fixed_uniform                | schema4 |           -1 | SHARDING |
      | C16  | er_child1                             | schema4 |           -1 | CHILD    |
      | C17  | er_child2                             | schema4 |           -1 | CHILD    |
      | C18  | sharding_fixed_nonuniform             | schema4 |           -1 | SHARDING |
      | C19  | er_child3                             | schema4 |           -1 | CHILD    |
      | C20  | sharding_fixed_uniform_string_rule    | schema4 |           -1 | SHARDING |
      | C21  | sharding_fixed_nonuniform_string_rule | schema4 |           -1 | SHARDING |
      | C22  | sharding_date_default_rule            | schema4 |           -1 | SHARDING |
    Then check resultset "5" has not lines with following column values
      | id-0 | name-1                   | schema-2 | max_limit-3 | type-4      |
      | M1   | no_s1                    | schema1  | 100         | NO_SHARDING |
      | M2   | no_s2                    | schema2  | 1000        | NO_SHARDING |
      | M3   | no_s3                    | schema3  | 100         | NO_SHARDING |
      | M4   | vertical                 | schema5  | -1          | NO_SHARDING |
#case supported subquery with all
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "6"
      | conn   | toClose | sql                                                                                                           | db               |
      | conn_0 | True    | select * from dble_table where schema = ALL(select name from dble_schema where sql_max_limit is null) limit 5 | dble_information |
    Then check resultset "6" has lines with following column values
      | name-1     | schema-2 | max_limit-3 | type-4   |
      | sharding_2 | schema1  | 100         | SHARDING |
      | sharding_4 | schema1  | 100         | SHARDING |
      | er_parent  | schema1  | 100         | SHARDING |
      | er_child   | schema1  | 90          | CHILD    |
      | global1    | schema1  | 100         | GLOBAL   |
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "7"
      | conn   | toClose | sql                                                                                               | db               |
      | conn_0 | True    | select * from dble_table where id <> all(select id from dble_child_table where id not like "%C")  | dble_information |
    Then check resultset "7" has lines with following column values
      | name-1                                | schema-2 | max_limit-3 | type-4      |
      | sharding_2                            | schema1  | 100         | SHARDING    |
      | sharding_4                            | schema1  | 100         | SHARDING    |
      | er_parent                             | schema1  | 100         | SHARDING    |
      | global1                               | schema1  | 100         | GLOBAL      |
      | sharding_3                            | schema2  | 1000        | SHARDING    |
      | global2                               | schema2  | 1000        | GLOBAL      |
      | sing1                                 | schema2  | 1000        | SINGLE      |
      | sharding_incrementColumn              | schema3  | 100         | SHARDING    |
      | sharding_sqlRequiredSharding          | schema3  | 100         | SHARDING    |
      | sharding_sqlRequiredSharding1         | schema3  | 100         | SHARDING    |
      | global3                               | schema3  | 100         | GLOBAL      |
      | sharding_fixed_uniform                | schema4  | -1          | SHARDING    |
      | sharding_fixed_nonuniform             | schema4  | -1          | SHARDING    |
      | sharding_fixed_uniform_string_rule    | schema4  | -1          | SHARDING    |
      | sharding_fixed_nonuniform_string_rule | schema4  | -1          | SHARDING    |
      | sharding_date_default_rule            | schema4  | -1          | SHARDING    |
      | global4                               | schema4  | -1          | GLOBAL      |
      | global5                               | schema4  | -1          | GLOBAL      |
      | no_s1                                 | schema1  | 100         | NO_SHARDING |
      | no_s2                                 | schema2  | 1000        | NO_SHARDING |
      | no_s3                                 | schema3  | 100         | NO_SHARDING |
      | vertical                              | schema5  | -1          | NO_SHARDING |
    Then check resultset "7" has not lines with following column values
      | name-1    | schema-2 | max_limit-3 | type-4 |
      | er_child  | schema1  | 90          | CHILD  |
      | er_child1 | schema4  | -1          | CHILD  |
      | er_child2 | schema4  | -1          | CHILD  |
      | er_child3 | schema4  | -1          | CHILD  |

#case supported subquery with [not] exists
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                               | expect          | db               |
      | conn_0 | False   | select * from dble_table where exists(select id from dble_global_table where `check`='false')     | length{(26)}    | dble_information |
      | conn_0 | False   | select * from dble_table where exists(select id from dble_global_table where id='C88')            | length{(0)}     | dble_information |
      | conn_0 | False   | select * from dble_table where not exists(select id from dble_global_table where `check`='false') | length{(0)}     | dble_information |
      | conn_0 | False   | select * from dble_table where not  exists(select id from dble_global_table where id='C88')       | length{(26)}    | dble_information |

#case some unsupported query
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                             | expect                                                            |
#case unsupported explain
      | conn_0 | False   | explain select name from dble_schema where name is null                                         | Unsupported statement                                             |
#case unsupported select 3
      | conn_0 | False   | select *, select 3 from dble_table order by id                                                  | Unsupported statement                                             |
      | conn_0 | False   | select * from dble_table where exists(select null) order by id                                  | not supported tree node type:NONAME                               |
      | conn_0 | False   | select *, (select 3) from dble_table order by id                                                | not supported tree node type:NONAME                               |
      | conn_0 | False   | select *, (select id,parent_id from dble_child_table where id='C4') from dble_table order by id | Operand should contain 1 column(s) |
#case unsupported Correlated Sub Queries
      | conn_0 | True    | select * from dble_table where schema = ALL(select schema from dble_schema where sql_max_limit is null)  | Correlated Sub Queries is not supported    |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | expect  | db      |
      | conn_1 | False   | drop table if exists schema1.no_s1                | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.no_s2                | success | schema1 |
      | conn_1 | False   | drop table if exists schema3.no_s3                | success | schema1 |
      | conn_1 | False   | drop table if exists schema5.vertical             | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_4                   | success | schema1 |
      | conn_1 | True    | drop table if exists er_parent                    | success | schema1 |
