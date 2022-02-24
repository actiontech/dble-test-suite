# Copyright (C) 2016-2022 ActionTech.
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
      /countdown/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
      """

     Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
      /-Dprocessors=1/c -Dprocessors=4
      /-DprocessorExecutor=1/c -DprocessorExecutor=4
     """
     Then Restart dble in "dble-1" success
     Given delete the following xml segment
       |file          | parent           | child                     |
       |sharding.xml  |{'tag':'root'}    | {'tag':'schema'}          |
     Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_3_t1" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="id" />
      </schema>
     """
     Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
     Then execute admin cmd  in "dble-1" at background
       | conn   | toClose   | sql                   |  db              |
       | conn_0 | False     | reload @@config_all   |  dble_information|
     Then check btrace "BtraceClusterDelay.java" output in "dble-1"
     """
      get into countdown
     """
     Given sleep "5" seconds
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
       | conn   | toClose   | sql                    |  db                |
       | conn_1 | False     | show @@reload_status   |  dble_information  |
     Then check resultset "A" has lines with following column values
       | INDEX-0 | CLUSTER-1 | RELOAD_TYPE-2 | RELOAD_STATUS-3 | LAST_RELOAD_END-5 | TRIGGER_TYPE-6  | END_TYPE-7 |
       |   0     | None      | RELOAD_ALL    | META_RELOAD     |                   |  LOCAL_COMMAND  |            |
     Given sleep "5" seconds
     Then execute sql in "dble-1" in "admin" mode
       | conn   | toClose   | sql                        | db               | expect   |
       | conn_1 | False     | release @@reload_metadata  | dble_information | success  |
     Given sleep "20" seconds
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
       | conn_0 | False     |  show @@shardingNodes where schema=schema1 and table=sharding_3_t1  |   dble_information|
     Then check resultset "D" has lines with following column values
       | NAME-0 |SEQUENCE-1 | HOST-2         | PORT-3   | PHYSICAL_SCHEMA-4 |  USER-5 | PASSWORD-6 |
       | dn1    | 0         | 172.100.9.5    | 3306     |   db1             |  test   | 111111     |
       | dn2    | 1         | 172.100.9.6    | 3306     |   db1             |  test   | 111111     |
       | dn3    | 2         | 172.100.9.5    |  3306    |    db2            |  test   | 111111     |
     Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      [RL][0-SELF_RELOAD]
      [RL][1-SELF_RELOAD]
      """
