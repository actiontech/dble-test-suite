# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2020/3/9
# update by caiwei at 2022/01/12 because of http://10.186.18.11/jira/browse/DBLE0REQ-1447
Feature: test ddl refactor
  check log when ddl execute successfully
  check log when ddl execute failed
  check warning log when the time of hang>60s
  can‘t support ddl in xa transaction

  Scenario: check log when ddl execute successfully   #1
    Given execute sql in "dble-1" in "user" mode
      | sql                                 | expect   | db      |
      | drop table if exists sharding_4_t1  | success  | schema1 |

    Given record current dble log line number in "log_num"
    Then execute sql in "dble-1" in "user" mode
      | sql                                 | expect   | db      |
      | create table sharding_4_t1(id int)  | success  | schema1 |
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num" in "dble-1"
      | key                                   | occur_times |
      | <init_ddl_trace>                      | 1           |
      | <add_table_lock.start>                | 1           |
      | <add_table_lock.succ>                 | 1           |
      | <test_ddl_conn.start>                 | 5           |
      | <test_ddl_conn.succ>                  | 5           |
      | <exec_ddl_sql.start>                  | 5           |
      | <exec_ddl_sql.get_conn>               | 4           |
      | <exec_ddl_sql.succ>                   | 5           |
      | <update_table_metadata.start>         | 1           |
      | <update_table_metadata>               | 2           |
      | <update_table_metadata.succ>          | 1           |
      | <release_table_lock.succ>             | 1           |
      | <finish_ddl_trace>                    | 1           |
    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect   | db      |
      | drop table if exists sharding_4_t1 | success  | schema1 |

  Scenario: check log when ddl execute failed       #2
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect   | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1 | success  | schema1 |
      | conn_0 | True    | create table sharding_4_t1(id int) | success  | schema1 |
    Then execute sql in "mysql-master1"
      | sql                                | expect    | db     |
      | drop table if exists sharding_4_t1 | success   | db1    |

    Given record current dble log line number in "log_num"
    Then execute sql in "dble-1" in "user" mode
      | sql                      | expect                            | db      |
      | drop table sharding_4_t1 | Unknown table 'db1.sharding_4_t1' | schema1 |

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num" in "dble-1"
      | key                                   | occur_times |
      | <init_ddl_trace>                      | 1           |
      | <add_table_lock.start>                | 1           |
      | <add_table_lock.succ>                 | 1           |
      | <test_ddl_conn.start>                 | 5           |
      | <test_ddl_conn.succ>                  | 5           |
      | <exec_ddl_sql.start>                  | 5           |
      | <exec_ddl_sql.get_conn>               | 4           |
      | <exec_ddl_sql.succ>                   | 3           |
      | <exec_ddl_sql.fail>                   | 2           |
      | <update_table_metadata>               | 1           |
      | <release_table_lock.succ>             | 1           |
      | <finish_ddl_trace>                    | 1           |
    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect   | db      |
      | drop table if exists sharding_4_t1 | success  | schema1 |

  @current
  Scenario: check warning log when the time of hang>60s   #3
    #有个定时任务，每60s检测一次 ddl执行时间是否超过 30*60*60 ms, 如果超过108s, dble日志中就打印一次warn提示信息, 类似：this ddl{drop table sharding_4_t1} execute for too long
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect   | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1  | success  | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int)  | success  | schema1 |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                                | expect                         | db  |timeout |
      | conn_1 | False    |begin                               | success                        | db1 |        |
      | conn_1 | False    |insert into sharding_4_t1 values(1) | success                        | db1 |        |
      | conn_1 | False    |select * from sharding_4_t1         | has{((1,),)}                   | db1 | 3      |
    Given prepare a thread execute sql "drop table sharding_4_t1" with "conn_0"
    #极端情况下需要 108+60秒 才能打印出日志
    Given sleep "170" seconds
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    cat /opt/dble/logs/dble.log |grep WARN|grep "this ddl{drop table sharding_4_t1} execute for too long" |wc -l
    """
    Then check result "rs_A" value as ">=1"
    Then get index:"0" column value of "show @@session" named as "id_A"
    Then kill dble front connection "id_A" in "dble-1" with manager command
    Then get result of oscmd named "rs_B" in "dble-1"
    """
    cat /opt/dble/logs/dble.log |grep WARN|grep "this ddl{drop table sharding_4_t1} execute for too long" |wc -l
    """
    Then check result "rs_B" value as "<=2"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    \[DDL_3\] <exec_ddl_sql.fail>
    \[DDL_3\] <finish_ddl_trace>
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    NullPointerException
    """
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql    | expect  | db  |
      | test | 111111 | conn_1 | True    | commit | success | db1 |
    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect   | db      |
      | drop table if exists sharding_4_t1 | success  | schema1 |


   Scenario:  can‘t support ddl in xa transaction  #4
     #case  https://github.com/actiontech/dble/issues/1760
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect                                                           | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1           | success                                                          | schema1 |
      | conn_0 | False   | set autocommit=0                             | success                                                          | schema1 |
      | conn_0 | False   | set xa=on                                    | success                                                          | schema1 |
      | conn_0 | False   | show full tables                             | success                                                          | schema1 |
      | conn_0 | False   | create table sharding_4_t1 (id int,code int) | Implicit commit statement cannot be executed when xa transaction | schema1 |
      | conn_0 | False   | rollback                                     | success                                                          | schema1 |
      | conn_0 | False   | set autocommit=1                             | success                                                          | schema1 |
      | conn_0 | False   | set xa=off                                   | success                                                          | schema1 |
      | conn_0 | true    | drop table if exists sharding_4_t1           | success                                                          | schema1 |



   Scenario: Multiple ddl is executed concurrently, the id in the dble log is correct #5
     #### dble-9042
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                      | expect                                 | db               |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='frontWorker'                   | success                                | dble_information |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name ='frontWorker'     | has{(('frontWorker', 4, 4),)}          | dble_information |

    Given execute sql "2345" times in "dble-1" together use 1000 connection not close
      | sql                                                                          | db      |
      | drop table if exists sharding_4_t1;create table sharding_4_t1(id int)        | schema1 |

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                           | occur_times |
      | <init_ddl_trace>              | 4690        |
      | <finish_ddl_trace>            | 4690        |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      java.nio.channels.AsynchronousCloseException: null
      caught err:
      """

