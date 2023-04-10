# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2021/04/15


Feature: when reload hang,emergency means to deal with it

   @btrace
   Scenario:reload hang with single dble
     Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
     Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
     Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /countdown/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
      """
     Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
      /-Dprocessors=1/c -Dprocessors=4
      /-DprocessorExecutor=1/c -DprocessorExecutor=4
     """
     Then Restart dble in "dble-1" success
     Then execute sql in "dble-1" in "admin" mode
        | conn    | toClose   | sql                        | db               | expect       |
        | conn_0  | False     | show @@reload_status       | dble_information | length{(1)}  |
     Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
        """
        <shardingTable name="sharding" shardingNode="dn3,dn4" shardingColumn="id" function="hash-two"/>
        """
     Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
     Given prepare a thread execute sql "reload @@config_all" with "conn_0"
     Then check btrace "BtraceClusterDelay.java" output in "dble-1"
     """
      get into countdown
     """
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
       | conn   | toClose   | sql                    |  db                |
       | conn_1 | False     | show @@reload_status   |  dble_information  |
     Then check resultset "A" has lines with following column values
       | INDEX-0 | CLUSTER-1 | RELOAD_TYPE-2 | RELOAD_STATUS-3 | LAST_RELOAD_END-5 | TRIGGER_TYPE-6  | END_TYPE-7 |
       |   0     | None      | RELOAD_ALL    | META_RELOAD     |                   |  LOCAL_COMMAND  |            |
     Then execute sql in "dble-1" in "admin" mode
       | conn   | toClose   | sql                        | db               | expect   |
       | conn_1 | False     | release @@reload_metadata  | dble_information | success  |

     ## failed for: (5999, 'Reload Failure.The reason is reload interruputed by others,metadata should be reload')
     Then check sql thread output in "err" by retry "15" times
        """
        Reload config failure.The reason is Reload interruputed by others,metadata should be reload
        """
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
       | conn   | toClose   | sql                      |   db              |
       | conn_1 | False     | show @@reload_status     |   dble_information|
     Then check resultset "B" has lines with following column values
       | INDEX-0 | CLUSTER-1 | RELOAD_TYPE-2 | RELOAD_STATUS-3 | TRIGGER_TYPE-6  | END_TYPE-7     |
       |   0     |    None   |   RELOAD_ALL  | NOT_RELOADING   | LOCAL_COMMAND   | INTERRUPUTED   |
     Then check resultsets "A" and "B" are same in following columns
       | column                    | column_index |
       | LAST_RELOAD_START         |   4          |

     Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
     Given destroy btrace threads list
     Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
     Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"

     Then execute admin cmd "reload @@metadata"
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
       | conn   | toClose   | sql                      |  db          |
       | conn_1 | False     | show @@reload_status     |  dble_information |
     Then check resultset "C" has lines with following column values
       | INDEX-0 | CLUSTER-1 | RELOAD_TYPE-2  | RELOAD_STATUS-3 | TRIGGER_TYPE-6  | END_TYPE-7     |
       |   1     |    None   |   RELOAD_META  | NOT_RELOADING   | LOCAL_COMMAND   | RELOAD_END     |
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "D"
       | conn   | toClose   |  sql                                                                |   db              |
       | conn_0 | False     |  show @@shardingNodes where schema=schema1 and table=sharding       |   dble_information|
     Then check resultset "D" has lines with following column values
       | NAME-0 |SEQUENCE-1 | HOST-2         | PORT-3   | PHYSICAL_SCHEMA-4 |  USER-5 | PASSWORD-6 |
       | dn3    | 0         | 172.100.9.5    | 3306     |   db2             |  test   | 111111     |
       | dn4    | 1         | 172.100.9.6    | 3306     |   db2             |  test   | 111111     |
     Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      [RL][0-SELF_RELOAD]
      [RL][1-SELF_RELOAD]
      """
