# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/12/11


Feature: because 3.20.07 version change, the cluster function changes ,from doc: https://github.com/actiontech/dble-docs-cn/blob/master/2.Function/2.08_cluster.md
  # ddl
  ######case points:
  #  1.shardingtable query ddl,check on dble-1,dble-2.dble-3
  #  2.use btrace add lock on meta
  #  3.case let ddl query error,to check metadata and lock
  #  4.case kill dble-1 on doing DDL,to check lock and check metadata on dble-2,dble-3


  Scenario: basis shardingtable query ddl,check on dble-1,dble-2.dble-3  #1
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
    #case check lock on zookeeper values is 0
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.sharding_4_t1" | wc -l
      """
    Then check result "A" value is "0"
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
      | conn   | toClose | sql                                    | expect                                                   | db      |
      | conn_2 | False   | drop table if exists sharding_4_t1     | success                                                  | schema1 |
      | conn_2 | true    | select * from sharding_4_t1            | Meta data of table 'schema1.sharding_4_t1' doesn't exist | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql            | expect                  | db      |
      | conn_1 | true    | show tables    | hasNoStr{sharding_4_t1} | schema1 |
    Then execute sql in "dble-3" in "admin" mode
      | conn    | toClose | sql                                                                     | expect                                                       | db               |
      | conn_31 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'  | has{(('schema1', 'sharding_4_t1', 'null', 'null', 0, 0),)}   | dble_information |
    #case check lock on zookeeper values is 0
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.sharding_4_t1" | wc -l
      """
    Then check result "A" value is "0"


  @skip_restart @btrace
  Scenario: use btrace add lock on meta  #2
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1     | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1 (id int)    | success | schema1 |
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /sleepWhenClearIfSessionClosed/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                     | db      |
      | conn_1 | true    | alter table sharding_4_t1 add age int   | schema1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
    """
    get into clearIfSessionClosed,start sleep
    """
    #case check lock on zookeeper values is 1
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.sharding_4_t1" | wc -l
      """
    Then check result "A" value is "1"
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                           | expect                                                                                                                                                                 | db      |
      | conn_2 | False    | alter table sharding_4_t1 add age1 int        | java.sql.SQLNonTransientException: java.sql.SQLNonTransientException: SCHEMA[schema1], TABLE[sharding_4_t1] is doing DDL,sql:alter table sharding_4_t1 add age1 int    | schema1 |
      | conn_2 | True     | insert into sharding_4_t1 values (1)          | success                                                                                                                                                                | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                           | expect                                                                                                                                                                 | db      |
      | conn_3 | False    | alter table sharding_4_t1 add age2 int        | java.sql.SQLNonTransientException: java.sql.SQLNonTransientException: SCHEMA[schema1], TABLE[sharding_4_t1] is doing DDL,sql:alter table sharding_4_t1 add age2 int    | schema1 |
      | conn_3 | False    | insert into sharding_4_t1 values (2,2)        | Column count doesn't match value count at row 1                                                                                                                        | schema1 |
      | conn_3 | False    | drop table if exists test1                    | success                                                                                                                                                                | schema1 |
      | conn_3 | true     | create table test1 (id int)                   | success                                                                                                                                                                | schema1 |
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given sleep "15" seconds
    #case check lock on zookeeper values is 0
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.sharding_4_t1" | wc -l
      """
    Then check result "A" value is "0"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect                                          | db      |
      | conn_1 | False   | insert into sharding_4_t1 values (3)   | Column count doesn't match value count at row 1 | schema1 |
      | conn_1 | true    | insert into sharding_4_t1 values (3,3) | success                                         | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                                    | expect    | db      |
      | conn_2 | False    | alter table sharding_4_t1 add age1 int                 | success   | schema1 |
      | conn_2 | True     | insert into sharding_4_t1 values (1,1,1)               | success   | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                                    | expect   | db      |
      | conn_3 | False    | alter table sharding_4_t1 add age2 int                 | success  | schema1 |
      | conn_3 | true     | insert into sharding_4_t1 values (2,2,2,2)             | success  | schema1 |
      #case check full @@metadata on admin mode
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_A"
      | conn    | toClose | sql                                                                              | db               |
      | conn_11 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
    Then check resultset "Res_A" has lines with following column values
      | schema-0 | table-1        | consistent_in_sharding_nodes-4 | consistent_in_memory-5 |
      | schema1  | sharding_4_t1  | 1                              | 1                      |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_B"
      | conn    | toClose | sql                                                                              | db               |
      | conn_21 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_C"
      | conn    | toClose | sql                                                                              | db               |
      | conn_31 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
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
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"


  @skip_restart @btrace
  Scenario: case let ddl query error,to check metadata and lock   #3
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | expect                      | db      |
      | conn_1 | true    | alter table sharding_4_t1 add age int             | Duplicate column name 'age' | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      FAILED;DROP_INDEX;schema1;1;alter table sharding_4_t1 add age int
      CONN_EXECUTE_ERROR
      """
    #case check full @@metadata on admin mode
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_A"
      | conn    | toClose | sql                                                                              | db               |
      | conn_11 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
    Then check resultset "Res_A" has lines with following column values
      | schema-0 | table-1       | consistent_in_sharding_nodes-4 | consistent_in_memory-5 |
      | schema1  | sharding_4_t1 | 1                              | 1                      |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_B"
      | conn    | toClose | sql                                                                              | db               |
      | conn_21 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_C"
      | conn    | toClose | sql                                                                              | db               |
      | conn_31 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
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
    #case check lock on zookeeper values is 0
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.sharding_4_t1" | wc -l
      """
    Then check result "A" value is "0"
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                                    | expect    | db      |
      | conn_2 | True     | insert into sharding_4_t1 values (4,4,4,4)             | success   | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                                    | expect   | db      |
      | conn_3 | true     | insert into sharding_4_t1 values (5,5,5,5)             | success  | schema1 |
    #case query ddl timeout
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /-DidleTimeout/d
      $a -DidleTimeout=20000
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
      """
      /-DidleTimeout/d
      $a -DidleTimeout=20000
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
      """
      /-DidleTimeout/d
      $a -DidleTimeout=20000
      """
    Then Restart dble in "dble-1" success
    Then Restart dble in "dble-2" success
    Then Restart dble in "dble-3" success
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /sleepWhenClearIfSessionClosed/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                     | db      |
      | conn_1 | true    | alter table sharding_4_t1 drop age      | schema1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
    """
    get into clearIfSessionClosed,start sleep
    """
    #case check lock on zookeeper values is 1
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.sharding_4_t1" | wc -l
      """
    Then check result "A" value is "1"
    #case wait idle timeout,check  query ddl on dble-2,dble-3 will has metaLock
    Given sleep "20" seconds
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                           | expect                                                                                                                                                                                            | db      |
      | conn_2 | False    | alter table sharding_4_t1 add age1 int        | java.sql.SQLNonTransientException: java.sql.SQLNonTransientException: SCHEMA[schema1], TABLE[sharding_4_t1] is doing DDL,sql:alter table sharding_4_t1 add age1 int                               | schema1 |
      | conn_2 | true     | alter table sharding_4_t1 drop age1           | java.sql.SQLNonTransientException: java.lang.Exception: The metaLock about `schema1.sharding_4_t1` is exists. It means other instance is doing DDL.,sql:alter table sharding_4_t1 drop age1       | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                           | expect                                                                                                                                                                                            | db      |
      | conn_3 | False    | alter table sharding_4_t1 add age2 int        | java.sql.SQLNonTransientException: java.sql.SQLNonTransientException: SCHEMA[schema1], TABLE[sharding_4_t1] is doing DDL,sql:alter table sharding_4_t1 add age2 int                               | schema1 |
      | conn_3 | true     | alter table sharding_4_t1 drop age2           | java.sql.SQLNonTransientException: java.lang.Exception: The metaLock about `schema1.sharding_4_t1` is exists. It means other instance is doing DDL.,sql:alter table sharding_4_t1 drop age2       | schema1 |
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given sleep "20" seconds
    #case check lock on zookeeper values is 0
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.sharding_4_t1" | wc -l
      """
    Then check result "A" value is "0"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect                                          | db      |
      | conn_1 | False   | insert into sharding_4_t1 values (6,6,6)     | Column count doesn't match value count at row 1 | schema1 |
      | conn_1 | true    | insert into sharding_4_t1 values (7,7,7,7)   | success                                         | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                                    | expect    | db      |
      | conn_2 | False    | alter table sharding_4_t1 drop age1                    | success   | schema1 |
      | conn_2 | True     | insert into sharding_4_t1 values (8,8,8)               | success   | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                                    | expect   | db      |
      | conn_3 | False    | alter table sharding_4_t1 drop age2                    | success  | schema1 |
      | conn_3 | true     | insert into sharding_4_t1 values (9,9)                 | success  | schema1 |
    #case desc table ,check metadata
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Res_A"
      | conn   | toClose | sql                 | db      |
      | conn_1 | true    | desc sharding_4_t1  | schema1 |
    Then check resultset "Res_A" has lines with following column values
      | Field-0 | Type-1  | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id      | int(11) | YES    |       | None      |         |
      | age     | int(11) | YES    |       | None      |         |
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
      | conn    | toClose | sql                                                                              | db               |
      | conn_11 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
    Then check resultset "Res_A" has lines with following column values
      | schema-0 | table-1       | consistent_in_sharding_nodes-4 | consistent_in_memory-5 |
      | schema1  | sharding_4_t1 | 1                              | 1                      |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_B"
      | conn    | toClose | sql                                                                              | db               |
      | conn_21 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_C"
      | conn    | toClose | sql                                                                              | db               |
      | conn_31 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
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
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"


  @btrace
  Scenario: case kill dble-1 on doing DDL,to check lock and check metadata on dble-2,dble-3   #4
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /sleepWhenClearIfSessionClosed/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                     | db      |
      | conn_1 | true    | alter table sharding_4_t1 drop age      | schema1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
    """
    get into clearIfSessionClosed,start sleep
    """
    #case check lock on zookeeper values is 1
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.sharding_4_t1" | wc -l
      """
    Then check result "A" value is "1"
    Given stop dble in "dble-1"
    Given sleep "10" seconds
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                           | expect                                                                                                                                                                                            | db      |
      | conn_2 | False    | alter table sharding_4_t1 add age1 int        | java.sql.SQLNonTransientException: java.sql.SQLNonTransientException: SCHEMA[schema1], TABLE[sharding_4_t1] is doing DDL,sql:alter table sharding_4_t1 add age1 int                               | schema1 |
      | conn_2 | true     | alter table sharding_4_t1 drop age1           | java.sql.SQLNonTransientException: java.lang.Exception: The metaLock about `schema1.sharding_4_t1` is exists. It means other instance is doing DDL.,sql:alter table sharding_4_t1 drop age1       | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                           | expect                                                                                                                                                                                            | db      |
      | conn_3 | False    | alter table sharding_4_t1 add age2 int        | java.sql.SQLNonTransientException: java.sql.SQLNonTransientException: SCHEMA[schema1], TABLE[sharding_4_t1] is doing DDL,sql:alter table sharding_4_t1 add age2 int                               | schema1 |
      | conn_3 | true     | alter table sharding_4_t1 drop age2           | java.sql.SQLNonTransientException: java.lang.Exception: The metaLock about `schema1.sharding_4_t1` is exists. It means other instance is doing DDL.,sql:alter table sharding_4_t1 drop age2       | schema1 |
    #case wait 30s ,to check  metaLock is not
    Given sleep "30" seconds
    #case check lock on zookeeper values is 0
    Then get result of oscmd named "A" in "dble-2"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.sharding_4_t1" | wc -l
      """
    Then check result "A" value is "0"
    #case check full @@metadata on admin mode
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_B"
      | conn    | toClose | sql                                                                              | db               |
      | conn_21 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_C"
      | conn    | toClose | sql                                                                              | db               |
      | conn_31 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
    Then check resultsets "Res_C" and "Res_B" are same in following columns
      | column                       | column_index |
      | schema                       | 0            |
      | table                        | 1            |
      | table_structure              | 3            |
      | consistent_in_sharding_nodes | 4            |
      | consistent_in_memory         | 5            |
    #case desc table ,check metadata
    Given execute single sql in "dble-2" in "user" mode and save resultset in "Res_A"
      | conn   | toClose | sql                 | db      |
      | conn_1 | true    | desc sharding_4_t1  | schema1 |
    Then check resultset "Res_A" has lines with following column values
      | Field-0 | Type-1  | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id      | int(11) | YES    |       | None      |         |
      | age     | int(11) | YES    |       | None      |         |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_C"
      | conn   | toClose | sql                 | db      |
      | conn_3 | true    | desc sharding_4_t1  | schema1 |
    Then check resultsets "Res_A" and "Res_C" are same in following columns
      | column  | column_index |
      | Field   | 0            |
      | Type    | 1            |
      | Null    | 2            |
      | Key     | 3            |
      | Default | 4            |
      | Extra   | 5            |
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    #case dble-2 doing ddl,start dble-1,do query ,dble-1 will waiting for dble-2 ddl finished,dble-1 logs has "waiting for ddl finished"
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /sleepWhenClearIfSessionClosed/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
      """
    Given sleep "2" seconds
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-2"
    Given execute sqls in "dble-2" at background
      | conn   | toClose | sql                                     | db      |
      | conn_2 | true    | alter table sharding_4_t1 drop age      | schema1 |
    #case check lock on zookeeper values is 1
    Then get result of oscmd named "A" in "dble-2"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.sharding_4_t1" | wc -l
      """
    Then check result "A" value is "1"
    Then check btrace "BtraceClusterDelay.java" output in "dble-2"
    """
    get into clearIfSessionClosed,start sleep
    """
    Then Restart dble in "dble-1" success
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    waiting for DDL finished
    """
    Given stop btrace script "BtraceClusterDelay.java" in "dble-2"
    Given destroy btrace threads list
    Given sleep "30" seconds
    #case check lock on zookeeper values is 0
    Then get result of oscmd named "A" in "dble-2"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.sharding_4_t1" | wc -l
      """
    Then check result "A" value is "0"
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Res_A"
      | conn   | toClose | sql                 | db      |
      | conn_1 | true    | desc sharding_4_t1  | schema1 |
    Then check resultset "Res_A" has lines with following column values
      | Field-0 | Type-1  | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id      | int(11) | YES    |       | None      |         |
      | age     | int(11) | YES    |       | None      |         |
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
      | conn    | toClose | sql                                                                              | db               |
      | conn_11 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
    Then check resultset "Res_A" has lines with following column values
      | schema-0 | table-1       | consistent_in_sharding_nodes-4 | consistent_in_memory-5 |
      | schema1  | sharding_4_t1 | 1                              | 1                      |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_B"
      | conn    | toClose | sql                                                                              | db               |
      | conn_21 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_C"
      | conn    | toClose | sql                                                                              | db               |
      | conn_31 | true    | check full @@metadata where schema='schema1' and table='sharding_4_t1'           | dble_information |
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
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-2"
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                                    | expect   | db      |
      | conn_3 | False    | drop table if exists sharding_4_t1                     | success  | schema1 |
      | conn_3 | true     | drop table if exists test1                             | success  | schema1 |