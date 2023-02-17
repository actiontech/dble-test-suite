# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_thread_pool test


  Scenario:  dble_thread_pool table #1
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
     $a  -DbackendProcessorExecutor=8
     $a  -DcomplexExecutor=8
     $a  -DwriteToBackendExecutor=8
     $a  -DbackendProcessors=8
    """
    Then restart dble in "dble-1" success
  #case desc dble_thread_pool
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_pool_1"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | desc dble_thread_pool    | dble_information |
    Then check resultset "dble_thread_pool_1" has lines with following column values
      | Field-0            | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name               | varchar(32) | NO     | PRI   | None      |         |
      | pool_size          | int(11)     | NO     |       | None      |         |
      | core_pool_size     | int(11)     | NO     |       | None      |         |
      | active_count       | int(11)     | NO     |       | None      |         |
      | waiting_task_count | int(11)     | NO     |       | None      |         |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                               | expect            | db               |
      | conn_0 | False   | desc dble_thread_pool             | length{(5)}       | dble_information |
      | conn_0 | False   | select * from dble_thread_pool    | success           | dble_information |
   #case select * from dble_thread_pool
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_pool_2"
      | conn   | toClose | sql                            | db                |
      | conn_0 | False   | select * from dble_thread_pool | dble_information  |
    Then check resultset "dble_thread_pool_2" has lines with following column values
      | name-0               | core_pool_size-2 | active_count-3 | waiting_task_count-4 |
      | Timer                | 1                | 0              | 0                    |
      | frontWorker          | 1                | 1              | 0                    |
      | backendWorker        | 8                | 0              | 0                    |
      | complexQueryWorker   | 8                | 1              | 0                    |
      | writeToBackendWorker | 8                | 8              | 0                    |
      | NIOFrontRW           | 1                | 1              | 0                    |
      | NIOBackendRW         | 8                | 8              | 0                    |
   #case supported select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                         | expect                                                                               |
      | conn_0 | False   | use dble_information                                        | success                                                                              |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool limit 1                      | has{(('Timer', 1),)}                                                |
      | conn_0 | False   | select * from dble_thread_pool order by name desc limit 2   | length{(2)}                                                                          |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name like '%Worker%' | has{(('frontWorker', 1), ('backendWorker', 8))}     |
      | conn_0 | False   | select core_pool_size from dble_thread_pool                      | has{((1,), (1,), (8,), (8,), (8,), (1,), (8,))}                                      |
  #case supported select max/min from table
      | conn_0 | False   | select max(core_pool_size) from dble_thread_pool                 | has{((8,),)}   |
      | conn_0 | False   | select min(core_pool_size) from dble_thread_pool                 | has{((1,),)}   |
  #case supported where [sub-query]
      | conn_0 | False   | select core_pool_size from dble_thread_pool where name in (select name from dble_thread_pool where active_count>0)  | has{((1,), (8,), (8,), (1,), (8,))}                      |
  #case supported select field from
      | conn_0 | True    | select name from dble_thread_pool where active_count > 0    | has{(('frontWorker',), ('complexQueryWorker',), ('writeToBackendWorker',), ('NIOFrontRW',), ('NIOBackendRW',))} |


  #case unsupported update/delete/insert
#      | conn_0 | False   | delete from dble_thread_pool where pool_size=1                   | Access denied for table 'dble_thread_pool'  |
#      | conn_0 | False   | update dble_thread_pool set pool_size=2 where name='Timer'       | Access denied for table 'dble_thread_pool'  |
#      | conn_0 | True    | insert into dble_thread_pool values ('a',1,2,3)                  | Access denied for table 'dble_thread_pool'  |

  #case change bootstrap.cnf to check result
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
     s/-DprocessorExecutor=1/-DprocessorExecutor=4/
     s/-DbackendProcessorExecutor=8/-DbackendProcessorExecutor=12/
     s/-DcomplexExecutor=8/-DcomplexExecutor=12/
     s/-DwriteToBackendExecutor=8/-DwriteToBackendExecutor=12/
     s/-DbackendProcessors=8/-DbackendProcessors=16/
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_pool_3"
      | conn   | toClose | sql                            | db                |
      | conn_0 | True    | select * from dble_thread_pool | dble_information  |
    Then check resultset "dble_thread_pool_3" has lines with following column values
      | name-0               | core_pool_size-2 |
      | Timer                | 1           |
      | frontWorker          | 4           |
      | backendWorker        | 12          |
      | complexQueryWorker   | 12          |
      | writeToBackendWorker | 12          |
      | NIOFrontRW           | 1           |
      | NIOBackendRW         | 16          |
    Then check resultset "dble_thread_pool_3" has not lines with following column values
      | name-0               | core_pool_size-2 |
      | frontWorker          | 1           |
      | backendWorker        | 8           |
      | complexQueryWorker   | 8           |
      | writeToBackendWorker | 8           |