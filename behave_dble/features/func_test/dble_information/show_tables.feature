# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  show databases/use dble_information/show tables [like]

 Scenario:  show databases/use dble_information/show tables [like] #1
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                    | expect                                                                 |
      #case  http://10.186.18.11/jira/browse/DBLE0REQ-489
      | conn_0 | False   | show tables                            | No database selected                                                   |
      | conn_0 | False   | desc version                           | No database selected                                                   |
#      | conn_0 | False   | select * from version                  | No database selected                                                   |
      #case show databases  https://github.com/actiontech/dble/issues/1961
      | conn_0 | False   | show database                          | Unsupported statement                                                  |
      | conn_0 | False   | show databasesl                        | Unsupported statement                                                  |
      | conn_0 | False   | show databases                         | has{('dble_information')}                                              |
      #case http://10.186.18.11/jira/browse/DBLE0REQ-480
      | conn_0 | False   | desc dble_information.version          | has{('version', 'varchar(64)', 'NO', 'PRI', None, '')}                 |
      | conn_0 | False   | describe dble_information.version      | has{('version', 'varchar(64)', 'NO', 'PRI', None, '')}                 |
      | conn_0 | False   | select * from dble_information.version | has{('version')}                                                       |
      #case use dble_information  http://10.186.18.11/jira/browse/DBLE0REQ-450
      | conn_0 | False   | use dble_informatio                    | Unknown database 'dble_informatio'                                     |
      | conn_0 | False   | use dble_information                   | success                                                                |
      #case show tables [like]
      | conn_0 | False   | show table                             | Unsupported statement                                                  |
      | conn_0 | False   | show tables                            | has{('Tables_in_dble_information')}                                    |
      | conn_0 | False   | show tables like '%s%'                 | has{('Tables_in_dble_information (%s%)')}                              |
      | conn_0 | False   | show tables like 'version'             | has{('Tables_in_dble_information (version)')}                          |
      #case desc/describe
      | conn_0 | False   | desc version                           | has{('version', 'varchar(64)', 'NO', 'PRI', None, '')}                 |
      | conn_0 | False   | describe version                       | has{('version', 'varchar(64)', 'NO', 'PRI', None, '')}                 |
      #case some spelling mistakes
      | conn_0 | False   | descc version                          | Unsupported statement                                                  |
      | conn_0 | False   | desc versio                            | Table `dble_information`.`versio` doesn't exist                        |
      | conn_0 | False   | select * froom version                 | Unsupported statement                                                  |
      | conn_0 | False   | select * from versio                   | get error call manager command table versio doesn't exist!             |
      #case create database/table or alter table
      | conn_0 | False   | create database test                                       | The sql did not match create\|drop database @@shardingNode ='dn......' |
      | conn_0 | False   | create table test (id int)                                 | The sql did not match create\|drop database @@shardingNode ='dn......' |
      | conn_0 | False   | drop database dble_information                             | The sql did not match create\|drop database @@shardingNode ='dn......' |
      | conn_0 | False   | drop table dble_status                                     | The sql did not match create\|drop database @@shardingNode ='dn......' |
      | conn_0 | False   | alter table version add id int                             | Unsupported statement                                                  |
      | conn_0 | False   | alter table dble_status drop variable_value                | Unsupported statement                                                  |
      | conn_0 | False   | alter table dble_schema modify sql_max_limit varchar       | Unsupported statement                                                  |
      | conn_0 | False   | alter table dble_schema change name sql_max_limit varchar; | Unsupported statement                                                  |
      | conn_0 | False   | alter table dble_schema modify name NOT NULL DEFAULT 100;  | Unsupported statement                                                  |
      | conn_0 | False   | alter table dble_sharding_node rename to test;             | Unsupported statement                                                  |
   #case show tables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "tables_1"
      | conn   | toClose | sql                       | db               |
      | conn_0 | False   | show tables               | dble_information |
    Then check resultset "tables_1" has lines with following column values
      | Tables_in_dble_information-0 |
      | backend_connections          |
      | dble_algorithm               |
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
#    Then check resultset "tables_1" has not lines with following column values
#      | Tables_in_dble_information-0 |
#      | demotest1                    |
#      | demotest2                    |

   #case  http://10.186.18.11/jira/browse/DBLE0REQ-475

