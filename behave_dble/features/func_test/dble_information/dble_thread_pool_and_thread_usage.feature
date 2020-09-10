# Copyright (C) 2016-2020 ActionTech.
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
   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                         | expect                                                                         |
      | conn_0 | False   | use dble_information                                        | success                                                                        |
      | conn_0 | False   | select * from dble_thread_pool limit 1                      | has{(('Timer', 1, 0, 0),)}                                                     |
      | conn_0 | False   | select * from dble_thread_pool order by name desc limit 2   | has{(('writeToBackendExecutor', 8, 8, 0), ('Timer', 1, 0, 0))}                 |
      | conn_0 | False   | select * from dble_thread_pool where name like '%Business%' | has{(('BusinessExecutor', 1, 1, 0), ('backendBusinessExecutor', 8, 0, 0))}     |
      | conn_0 | False   | select size from dble_thread_pool                           | has{((1,), (1,), (8,), (8,), (8,))}                                            |
  #case select max/min from
      | conn_0 | False   | select max(size) from dble_thread_pool                      | has{((8,),)}  |
      | conn_0 | False   | select min(size) from dble_thread_pool                      | has{((1,),)}  |
  #case where [sub-query]
#      | conn_0 | False   | select size from dble_thread_pool where name in (select name from dble_thread_pool where active_count>1) | has{(('BusinessExecutor', 1, 1, 0), ('backendBusinessExecutor', 8, 0, 0))}     |
  #case select field from
#      | conn_0 | False   | select name from dble_thread_pool where active_count > 0                         | has{('BusinessExecutor'),('complexQueryExecutor'),('writeToBackendExecutor')}                                    |
  #case update/delete
      | conn_0 | False   | delete from dble_thread_pool where size=1                   | Access denied for table 'dble_thread_pool'                                                                                                        |
      | conn_0 | False   | update dble_thread_pool set size=2 where name='Timer'       | Access denied for table 'dble_thread_pool'                                                                                                        |
      | conn_0 | False   | insert into dble_thread_pool values ('a',1,2,3)             | update syntax error, not support insert with syntax :[LOW_PRIORITY \| DELAYED \| HIGH_PRIORITY] [IGNORE][ON DUPLICATE KEY UPDATE assignment_list] |

  #case change bootstrap.cnf
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
      | conn_1 | False   | select * from dble_thread_pool | dble_information  |
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



  @skip_restart
   Scenario:  dble_thread_usage  table #1
  #case desc dble_thread_usage
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_usage_1"
      | conn   | toClose | sql                    | db               |
      | conn_0 | False   | desc dble_thread_usage | dble_information |
    Then check resultset "dble_thread_usage_1" has lines with following column values
      | Field-0          | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | thread_name      | varchar(64) | NO     | PRI   | None      |         |
      | last_quarter_min | varchar(5)  | NO     |       | None      |         |
      | last_minute      | varchar(5)  | NO     |       | None      |         |
      | last_five_minute | varchar(5)  | NO     |       | None      |         |
  #case not set useThreadUsageStat and useCostTimeStat
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                    | expect             |
      | conn_0 | False   | select * from dble_thread_usage        | length{(0)}        |
  #case set useThreadUsageStat and useCostTimeStat
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DuseThreadUsageStat=1
    $a -DuseCostTimeStat=1
    """
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_usage_2"
      | conn   | toClose | sql                             | db               |
      | conn_1 | False   | select * from dble_thread_usage | dble_information |
    Then check resultset "dble_thread_usage_2" has lines with following column values
      | thread_name-0            |
      | $_NIO_REACTOR_BACKEND-0  |
      | $_NIO_REACTOR_BACKEND-1  |
      | $_NIO_REACTOR_BACKEND-2  |
      | $_NIO_REACTOR_BACKEND-3  |
      | $_NIO_REACTOR_BACKEND-4  |
      | $_NIO_REACTOR_BACKEND-5  |
      | $_NIO_REACTOR_BACKEND-6  |
      | $_NIO_REACTOR_BACKEND-7  |
      | $_NIO_REACTOR_FRONT-0    |
      | BusinessExecutor0        |
      | backendBusinessExecutor0 |
      | backendBusinessExecutor1 |
      | backendBusinessExecutor2 |
      | backendBusinessExecutor3 |
      | backendBusinessExecutor4 |
      | backendBusinessExecutor5 |
      | backendBusinessExecutor6 |
      | backendBusinessExecutor7 |
      | writeToBackendExecutor0  |
      | writeToBackendExecutor1  |
      | writeToBackendExecutor2  |
      | writeToBackendExecutor3  |
      | writeToBackendExecutor4  |
      | writeToBackendExecutor5  |
      | writeToBackendExecutor6  |
      | writeToBackendExecutor7  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_usage_3"
      | conn   | toClose | sql                       | db               |
      | conn_1 | False   |show @@thread_used         | dble_information |
    Then check resultsets "dble_thread_usage_2" and "dble_thread_usage_3" are same in following columns
      |column            | column_index |
      |thread_name       | 0            |
      |last_quarter_min  | 1            |
      |last_minute       | 2            |
      |last_five_minute  | 3            |
  #case change bootstrap.cnf
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
     s/-DprocessorExecutor=1/-DprocessorExecutor=2/
     $a  -DbackendProcessors=4
     $a  -DbackendProcessorExecutor=4
     $a  -DwriteToBackendExecutor=4
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_usage_4"
      | conn   | toClose | sql                              | db               |
      | conn_2 | true    | select * from dble_thread_usage  | dble_information |
    Then check resultset "dble_thread_usage_4" has lines with following column values
      | thread_name-0            |
      | $_NIO_REACTOR_BACKEND-0  |
      | $_NIO_REACTOR_BACKEND-1  |
      | $_NIO_REACTOR_BACKEND-2  |
      | $_NIO_REACTOR_BACKEND-3  |
      | $_NIO_REACTOR_FRONT-0    |
      | BusinessExecutor0        |
      | BusinessExecutor1        |
      | backendBusinessExecutor0 |
      | backendBusinessExecutor1 |
      | backendBusinessExecutor2 |
      | backendBusinessExecutor3 |
      | writeToBackendExecutor0  |
      | writeToBackendExecutor1  |
      | writeToBackendExecutor2  |
      | writeToBackendExecutor3  |
    Then check resultset "dble_thread_usage_4" has not lines with following column values
      | thread_name-0            |
      | $_NIO_REACTOR_BACKEND-4  |
      | $_NIO_REACTOR_BACKEND-5  |
      | $_NIO_REACTOR_BACKEND-6  |
      | $_NIO_REACTOR_BACKEND-7  |
      | backendBusinessExecutor4 |
      | backendBusinessExecutor5 |
      | backendBusinessExecutor6 |
      | backendBusinessExecutor7 |
      | writeToBackendExecutor4  |
      | writeToBackendExecutor5  |
      | writeToBackendExecutor6  |
      | writeToBackendExecutor7  |

   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect                                                                                                            |
      | conn_2 | False   | use dble_information                                                | success                                                                                                           |
      | conn_2 | False   | select * from dble_thread_usage limit 1                             | has{(('$_NIO_REACTOR_BACKEND-0', '0%', '0%', '0%'),)}                                                             |
      | conn_2 | False   | select * from dble_thread_usage order by thread_name desc limit 2   | has{(('writeToBackendExecutor3','0%', '0%', '0%'), ('writeToBackendExecutor2','0%', '0%', '0%'))}                 |
      | conn_2 | False   | select * from dble_thread_usage where thread_name like '%FRONT%'    | has{(('$_NIO_REACTOR_FRONT-0','0%', '0%', '0%'),)}                                                                |
  #case select max/min from
      | conn_2 | False   | select max(thread_name) from dble_thread_usage                      | has{(('writeToBackendExecutor3',),)}           |
      | conn_2 | False   | select min(thread_name) from dble_thread_usage                      | has{(('$_NIO_REACTOR_BACKEND-0',),)}           |
  #case where [sub-query]
#      | conn_0 | False   | select thread_name from dble_thread_usage where last_minute in (select last_minute from dble_thread_usage where last_five_minute<10%) | has{(('BusinessExecutor', 1, 1, 0), ('backendBusinessExecutor', 8, 0, 0))}     |
   #case select field from
#      | conn_2 | False   | select last_quarter_min from dble_thread_usage where thread_name = 'BusinessExecutor0'          | has{('BusinessExecutor'),('complexQueryExecutor'),('writeToBackendExecutor')}                                    |
  #case update/delete
      | conn_2 | False   | delete from dble_thread_usage where thread_name = 'BusinessExecutor0'                        | Access denied for table 'dble_thread_usage'                                                                                                        |
      | conn_2 | False   | update dble_thread_usage set thread_name = '2' where thread_name = 'BusinessExecutor0'       | Access denied for table 'dble_thread_usage'                                                                                                        |
      | conn_2 | False   | insert into dble_thread_usage values ('_NIO_REACTOR_FRONT-0','1%', '1%', '1%')               | update syntax error, not support insert with syntax :[LOW_PRIORITY \| DELAYED \| HIGH_PRIORITY] [IGNORE][ON DUPLICATE KEY UPDATE assignment_list]  |





