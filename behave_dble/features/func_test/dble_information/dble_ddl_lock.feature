# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/9/2

Feature:  dble_ddl_lock test
   Scenario:  dble_ddl_lock  table #1
  #case desc dble_ddl_lock
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_ddl_lock_1"
      | conn   | toClose | sql                | db               |
      | conn_0 | False   | desc dble_ddl_lock | dble_information |
    Then check resultset "dble_ddl_lock_1" has lines with following column values
      | Field-0 | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |
      | schema  | varchar(64)  | NO     | PRI   | None      |         |
      | table   | varchar(64)  | NO     | PRI   | None      |         |
      | sql     | varchar(500) | NO     |       | None      |         |
  #case show ddl
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | use schema1                                      | success |
      | conn_1 | False   | drop table if exists sharding_2_t1               | success |
      | conn_1 | False   | create table sharding_2_t1 (id int)              | success |
      | conn_1 | False   | set autocommit=0                                 | success |
      | conn_1 | False   | set xa=on                                        | success |
      | conn_1 | False   | insert into sharding_2_t1 values (1),(2),(3),(4) | success |
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                       |
      | conn_2 | False   | use schema1               |
    Given prepare a thread execute sql "drop table if exists sharding_2_t1" with "conn_2"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_ddl_lock_2"
      | conn   | toClose | sql                         | db               |
      | conn_0 | False   | select * from dble_ddl_lock | dble_information |
    Then check resultset "dble_ddl_lock_2" has lines with following column values
      | schema-0 | table-1       | sql-2                              |
      | schema1  | sharding_2_t1 | drop table if exists sharding_2_t1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_ddl_lock_3"
      | conn   | toClose | sql           | db               |
      | conn_0 | False   | show @@ddl    | dble_information |
    Then check resultsets "dble_ddl_lock_2" and "dble_ddl_lock_3" are same in following columns
      | column     | column_index |
      | schema     | 0            |
      | table      | 1            |
      | sql        | 2            |

  #case update/delete
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                   | expect                                      |
      | conn_0 | False   | delete from dble_ddl_lock where sql='drop table if exists sharding_2_t1'              | Access denied for table 'dble_ddl_lock'     |
      | conn_0 | False   | update dble_ddl_lock set sql = 'a' where sql='drop table if exists sharding_2_t1'     | Access denied for table 'dble_ddl_lock'     |
      | conn_0 | False   | insert into dble_ddl_lock values (1,'1',1,1,1)                                        | Access denied for table 'dble_ddl_lock'     |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_1 | False   | rollback                                                | schema1 |
      | conn_1 | False   | set autocommit=1                                        | schema1 |
      | conn_1 | False   | set xa=off                                              | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                      | schema1 |


