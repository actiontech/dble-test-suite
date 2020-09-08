# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_thread_pool test
#@skip_restart
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





   #case select * from dble_status where xxx
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_pool_4"
#      | conn   | toClose | sql                       | db                |
#      | conn_0 | False   |                           | dble_information  |



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
  #case set useThreadUsageStat
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DuseThreadUsageStat=1
    $a -DuseCostTimeStat=1
    """
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_usage_2"
      | conn   | toClose | sql                              | db               |
      | conn_1 | False   | select * from  dble_thread_usage | dble_information |
 #   Then check resultset "dble_thread_usage_2" has lines with following column values
