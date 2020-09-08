# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/9/2

Feature:  dble_thread_usage test
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











