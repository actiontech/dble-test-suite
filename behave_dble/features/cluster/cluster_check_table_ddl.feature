# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/12/11


Feature: because 3.20.07 version change, the cluster function changes ,from doc: https://github.com/actiontech/dble-docs-cn/blob/master/2.Function/2.08_cluster.md
  # ddl
  ######case points:
  #  1.shardingtable query ddl,check on dble-1,dble-2.dble-3
  #  2.

#    Then get result of oscmd named "A" in "dble-1"
#      """
#      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/sharding | grep "schema1" |wc -l
#      """
#    Then check result "A" value is "1"

  Scenario: basis shardingtable query ddl,check on dble-1,dble-2.dble-3  #1
#    Given reset dble registered nodes in zk
    #case desc table on user mode
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                  | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                   | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1 (id int, name char(5))    | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Res_A"
      | conn   | toClose | sql                 | db      |
      | conn_1 | true    | desc sharding_4_t1  | schema1 |
    Then check resultset "Res_A" has lines with following column values
      | Field-0 | Type-1  | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id      | int(11) | YES    |       | None      |         |
      | name    | char(5) | YES    |       | None      |         |
    Given execute single sql in "dble-2" in "user" mode and save resultset in "Res_B"
      | conn   | toClose | sql                 | db      |
      | conn_2 | true    | desc sharding_4_t1  | schema1 |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_C"
      | conn   | toClose | sql                 | db      |
      | conn_3 | true    | desc sharding_4_t1  | schema1 |
    Then check resultsets "Res_A" and "Res_B" are same in following columns
      | column  | column_index |
      | Field   | 0            |
      | Type    | 1            |
      | Null    | 2            |
      | Key     | 3            |
      | Default | 4            |
      | Extra   | 5            |
    Then check resultsets "Res_C" and "Res_B" are same in following columns
      | column  | column_index |
      | Field   | 0            |
      | Type    | 1            |
      | Null    | 2            |
      | Key     | 3            |
      | Default | 4            |
      | Extra   | 5            |
    #case check full @@metadata on admin mode
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_A"
      | conn    | toClose | sql                                                                     | db               |
      | conn_11 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'  | dble_information |
    Then check resultset "Res_A" has lines with following column values
      | schema-0 | table-1       | consistent_in_sharding_nodes-4 | consistent_in_memory-5 |
      | schema1  | sharding_4_t1 | 1                              | 1                      |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_B"
      | conn    | toClose | sql                                                                     | db               |
      | conn_21 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'  | dble_information |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_C"
      | conn    | toClose | sql                                                                     | db               |
      | conn_31 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'  | dble_information |
    Then check resultsets "Res_A" and "Res_B" are same in following columns
      | column                       | column_index |
      | schema                       | 0            |
      | table                        | 1            |
      | table_structure              | 3            |
      | consistent_in_sharding_nodes | 4            |
      | consistent_in_memory         | 5            |
    Then check resultsets "Res_C" and "Res_B" are same in following columns
      | column                       | column_index |
      | schema                       | 0            |
      | table                        | 1            |
      | table_structure              | 3            |
      | consistent_in_sharding_nodes | 4            |
      | consistent_in_memory         | 5            |
    #case alter table on user mode
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                      | expect  | db      |
      | conn_2 | False   | alter table sharding_4_t1 add age int    | success | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose | sql                                            | expect  | db      |
      | conn_3 | False   | alter table sharding_4_t1 add proe char(15)    | success | schema1 |
    #case check table
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Res_A"
      | conn   | toClose | sql                 | db      |
      | conn_1 | true    | desc sharding_4_t1  | schema1 |
    Then check resultset "Res_A" has lines with following column values
      | Field-0 | Type-1   | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id      | int(11)  | YES    |       | None      |         |
      | name    | char(5)  | YES    |       | None      |         |
      | age     | int(11)  | YES    |       | None      |         |
      | proe    | char(15) | YES    |       | None      |         |
    Given execute single sql in "dble-2" in "user" mode and save resultset in "Res_B"
      | conn   | toClose | sql                 | db      |
      | conn_2 | true    | desc sharding_4_t1  | schema1 |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_C"
      | conn   | toClose | sql                 | db      |
      | conn_3 | true    | desc sharding_4_t1  | schema1 |
    Then check resultsets "Res_A" and "Res_B" are same in following columns
      | column  | column_index |
      | Field   | 0            |
      | Type    | 1            |
      | Null    | 2            |
      | Key     | 3            |
      | Default | 4            |
      | Extra   | 5            |
    Then check resultsets "Res_C" and "Res_B" are same in following columns
      | column  | column_index |
      | Field   | 0            |
      | Type    | 1            |
      | Null    | 2            |
      | Key     | 3            |
      | Default | 4            |
      | Extra   | 5            |
    #case check full @@metadata on admin mode
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_A"
      | conn    | toClose | sql                                                                     | db               |
      | conn_11 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'  | dble_information |
    Then check resultset "Res_A" has lines with following column values
      | schema-0 | table-1       | consistent_in_sharding_nodes-4 | consistent_in_memory-5 |
      | schema1  | sharding_4_t1 | 1                              | 1                      |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_B"
      | conn    | toClose | sql                                                                     | db               |
      | conn_21 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'  | dble_information |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_C"
      | conn    | toClose | sql                                                                     | db               |
      | conn_31 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'  | dble_information |
    Then check resultsets "Res_A" and "Res_B" are same in following columns
      | column                       | column_index |
      | schema                       | 0            |
      | table                        | 1            |
      | table_structure              | 3            |
      | consistent_in_sharding_nodes | 4            |
      | consistent_in_memory         | 5            |
    Then check resultsets "Res_C" and "Res_B" are same in following columns
      | column                       | column_index |
      | schema                       | 0            |
      | table                        | 1            |
      | table_structure              | 3            |
      | consistent_in_sharding_nodes | 4            |
      | consistent_in_memory         | 5            |
    #case drop table
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                          | expect                                                   | db      |
      | conn_2 | False   | drop table sharding_4_t1     | success                                                  | schema1 |
      | conn_2 | true    | select * from sharding_4_t1  | Meta data of table 'schema1.sharding_4_t1' doesn't exist | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql            | expect                  | db      |
      | conn_1 | true    | show tables    | hasNoStr{sharding_4_t1} | schema1 |
    Then execute sql in "dble-3" in "admin" mode
      | conn    | toClose | sql                                                                     | expect                                                       | db               |
      | conn_31 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'  | has{(('schema1', 'sharding_4_t1', 'null', 'null', 0, 0),)}   | dble_information |
    #case check lock on zookeeper
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.sharding_4_t1" |wc -l
      """
    Then check result "A" value is "0"


  @skip_restart  @btrace
  Scenario: use btrace add lock on meta  #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                         | expect  | db      |
      | conn_1 | False   | drop table if exists test                   | success | schema1 |
      | conn_1 | False   | create table test (id int, name char(5))    | success | schema1 |
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /sleepWhenClearIfSessionClosed/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(60000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Given sleep "1" seconds
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                      | db      |
      | conn_1 | true    | alter table test add age int             | schema1 |
    Given sleep "5" seconds
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.test" |wc -l
      """
    Then check result "A" value is "1"


    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
#    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
#    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"






  @skip
#  _restart
  Scenario: case let ddl query error #3
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                      | expect                      | db      |
      | conn_1 | true    | alter table sharding_4_t1 add age int    | Duplicate column name 'age' | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      FAILED;DROP_INDEX;schema1;1;alter table sharding_4_t1 add age int
      CONN_EXECUTE_ERROR
      """
    #case check full @@metadata on admin mode
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_A"
      | conn    | toClose | sql                                                                     | db               |
      | conn_11 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'  | dble_information |
    Then check resultset "Res_A" has lines with following column values
      | schema-0 | table-1       | consistent_in_sharding_nodes-4 | consistent_in_memory-5 |
      | schema1  | sharding_4_t1 | 1                              | 1                      |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_B"
      | conn    | toClose | sql                                                                     | db               |
      | conn_21 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'  | dble_information |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_C"
      | conn    | toClose | sql                                                                     | db               |
      | conn_31 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'  | dble_information |
    Then check resultsets "Res_A" and "Res_B" are same in following columns
      | column                       | column_index |
      | schema                       | 0            |
      | table                        | 1            |
      | table_structure              | 3            |
      | consistent_in_sharding_nodes | 4            |
      | consistent_in_memory         | 5            |
    Then check resultsets "Res_C" and "Res_B" are same in following columns
      | column                       | column_index |
      | schema                       | 0            |
      | table                        | 1            |
      | table_structure              | 3            |
      | consistent_in_sharding_nodes | 4            |
      | consistent_in_memory         | 5            |
    #case let ddl query error,














