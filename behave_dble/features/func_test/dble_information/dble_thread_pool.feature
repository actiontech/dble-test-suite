# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_thread_pool test
   Scenario:  dble_thread_pool table #1
  #case desc dble_thread_pool
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_pool_1"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | desc dble_thread_pool    | dble_information |
    Then check resultset "dble_thread_pool_1" has lines with following column values
      | Field-0            | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name               | varchar(32) | NO     | PRI   | None      |         |
      | size               | int(11)     | NO     |       | None      |         |
      | active_count       | int(11)     | NO     |       | None      |         |
      | waiting_task_count | int(11)     | NO     |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                               | expect            | db               |
      | conn_0 | False   | desc dble_thread_pool             | length{(4)}       | dble_information |
      | conn_0 | False   | select * from dble_thread_pool    | length{(5)}       | dble_information |
   #case select * from dble_thread_pool
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_pool_2"
      | conn   | toClose | sql                            | db                |
      | conn_0 | False   | select * from dble_thread_pool | dble_information  |
    Then check resultset "dble_thread_pool_2" has lines with following column values
      | name-0                  | size-1 | active_count-2 | waiting_task_count-3 |
      | Timer                   | 1      | 0              | 0                    |
      | BusinessExecutor        | 1      | 1              | 0                    |
      | backendBusinessExecutor | 8      | 0              | 0                    |
      | complexQueryExecutor    | 8      | 1              | 0                    |
      | writeToBackendExecutor  | 8      | 8              | 0                    |
   #case supported select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                         | expect                                                                         |
      | conn_0 | False   | use dble_information                                        | success                                                                        |
      | conn_0 | False   | select * from dble_thread_pool limit 1                      | has{(('Timer', 1, 0, 0),)}                                                     |
      | conn_0 | False   | select * from dble_thread_pool order by name desc limit 2   | has{(('writeToBackendExecutor', 8, 8, 0), ('Timer', 1, 0, 0))}                 |
      | conn_0 | False   | select * from dble_thread_pool where name like '%Business%' | has{(('BusinessExecutor', 1, 1, 0), ('backendBusinessExecutor', 8, 0, 0))}     |
      | conn_0 | False   | select size from dble_thread_pool                           | has{((1,), (1,), (8,), (8,), (8,))}                                            |
  #case supported select max/min from table
      | conn_0 | False   | select max(size) from dble_thread_pool                      | has{((8,),)}  |
      | conn_0 | False   | select min(size) from dble_thread_pool                      | has{((1,),)}  |
  #case supported where [sub-query]
      | conn_0 | False   | select size from dble_thread_pool where name in (select name from dble_thread_pool where active_count>0)  | has{((1,), (8,), (8,))}                      |
  #case supported select field from
      | conn_0 | False   | select name from dble_thread_pool where active_count > 0    | has{(('BusinessExecutor',), ('complexQueryExecutor',), ('writeToBackendExecutor',))} |
  #case unsupported update/delete/insert
      | conn_0 | False   | delete from dble_thread_pool where size=1                   | Access denied for table 'dble_thread_pool'  |
      | conn_0 | False   | update dble_thread_pool set size=2 where name='Timer'       | Access denied for table 'dble_thread_pool'  |
      | conn_0 | True    | insert into dble_thread_pool values ('a',1,2,3)             | Access denied for table 'dble_thread_pool'  |

  #case change bootstrap.cnf to check result
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
     s/-DprocessorExecutor=1/-DprocessorExecutor=4/
     $a  -DbackendProcessorExecutor=12
     $a  -DcomplexExecutor=12
     $a  -DwriteToBackendExecutor=12
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_pool_3"
      | conn   | toClose | sql                            | db                |
      | conn_0 | True    | select * from dble_thread_pool | dble_information  |
    Then check resultset "dble_thread_pool_3" has lines with following column values
      | name-0                  | size-1 |
      | Timer                   | 1      |
      | BusinessExecutor        | 4      |
      | backendBusinessExecutor | 12     |
      | complexQueryExecutor    | 12     |
      | writeToBackendExecutor  | 12     |
    Then check resultset "dble_thread_pool_3" has not lines with following column values
      | name-0                  | size-1 |
      | BusinessExecutor        | 1      |
      | backendBusinessExecutor | 8      |
      | complexQueryExecutor    | 8      |
      | writeToBackendExecutor  | 8      |


