# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2020/3/9
Feature: test ddl refactor
  check log when ddl execute failed
  check log when ddl execute successfully
  check warning log when the time of hang>60s

  Scenario: check log when ddl execute failed       #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect   | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1 | success  | schema1 |
      | conn_0 | True    | create table sharding_4_t1(id int) | success  | schema1 |
    Then execute sql in "mysql-master1"
      | sql                                | expect    | db     |
      | drop table if exists sharding_4_t1 | success   | db1    |
    Then execute sql in "dble-1" in "user" mode
      | sql                      | expect                            | db      |
      | drop table sharding_4_t1 | Unknown table 'db1.sharding_4_t1' | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    CONN_EXECUTE_ERROR
    """
    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect   | db      |
      | drop table if exists sharding_4_t1 | success  | schema1 |

  Scenario: check log when ddl execute successfully   #2
    Then execute sql in "dble-1" in "user" mode
      | sql                                 | expect   | db      |
      | create table sharding_4_t1(id int)  | success  | schema1 |
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                  | occur_times |
      | ROUTE_END            | 1      |
      | LOCK_END             | 1      |
      | CONN_TEST_START      | 5      |
      | CONN_TEST_SUCCESS    | 8      |
      | CONN_EXECUTE_START   | 4      |
      | CONN_EXECUTE_SUCCESS | 8      |
      | META_UPDATE          | 1      |
      | EXECUTE_END          | 1      |
    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect   | db      |
      | drop table if exists sharding_4_t1 | success  | schema1 |


  @current @skip #doing ddl problem
  Scenario: check warning log when the time of hang>60s   #3
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect   | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1  | success  | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int)  | success  | schema1 |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                                | expect    | db  |
      | conn_1 | False    |begin                               | success   | db1 |
      | conn_1 | False    |insert into sharding_4_t1 values(1) | success   | db1 |
    Given prepare a thread execute sql "drop table sharding_4_t1" with "conn_0"
    Given sleep "120" seconds
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    cat /opt/dble/logs/dble.log |grep WARN|grep "THIS DDL EXECUTE FOR TOO LONG" |wc -l
    """
    Then check result "rs_A" value is "1"
    Then get index:"0" column value of "show @@session" named as "id_A"
    Then kill dble front connection "id_A" in "dble-1" with manager command
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Front_id_A"
      | sql            |
      | show @@session |
    Then check resultset "Front_id_A" has not lines with following column values
      | FRONT_ID-1 |
      | 2          |

    Then get result of oscmd named "rs_B" in "dble-1"
    """
    cat /opt/dble/logs/dble.log |grep WARN|grep "THIS DDL EXECUTE FOR TOO LONG" |wc -l
    """
    Then check result "rs_B" value is "1"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    EXECUTE_CONN_CLOSE
    EXECUTE_END
    """
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql    | expect  | db  |
      | test | 111111 | conn_1 | True    | commit | success | db1 |
    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect   | db      |
      | drop table if exists sharding_4_t1 | success  | schema1 |

