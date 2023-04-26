# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2022/01/26

Feature:check DDL log in cluster
  #about http://10.186.18.11/jira/browse/DBLE0REQ-1447

  Scenario: check log when ddl execute successfully in cluster      #1
    Given execute sql in "dble-1" in "user" mode
      | sql                                 | expect   | db      |
      | drop table if exists sharding_4_t1  | success  | schema1 |
    ####为了drop 这个ddl的日志完全输出，避开被下一步的记录dble日志行数记录到
    Given sleep "2" seconds
    Given record current dble log line number in "log_num_1" in "dble-1"
    Given record current dble log line number in "log_num_2" in "dble-2"
    Given record current dble log line number in "log_num_3" in "dble-3"
    Then execute sql in "dble-1" in "user" mode
      | sql                                 | expect   | db      |
      | create table sharding_4_t1(id int)  | success  | schema1 |
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_1" in "dble-1"
      | key                                   | occur_times |
      | <init_ddl_trace>                      | 1           |
      | <notice_cluster_ddl_prepare.start>    | 1           |
      | <notice_cluster_ddl_prepare.succ>     | 1           |
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
      | <notice_cluster_ddl_complete.start>   | 1           |
      | <notice_cluster_ddl_complete.succ>    | 1           |
      | <release_table_lock.succ>             | 1           |
      | <finish_ddl_trace>                    | 1           |
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_2" in "dble-2"
      | key                                   | occur_times |
      | <receive_ddl_prepare>                 | 1           |
      | <add_table_lock.start>                | 1           |
      | <add_table_lock.succ>                 | 1           |
      | <receive_ddl_complete>                | 1           |
      | <update_table_metadata.start>         | 1           |
      | <update_table_metadata>               | 5           |
      | <update_table_metadata.succ>          | 1           |
      | <release_table_lock.succ>             | 1           |
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_3" in "dble-3"
      | key                                   | occur_times |
      | <receive_ddl_prepare>                 | 1           |
      | <add_table_lock.start>                | 1           |
      | <add_table_lock.succ>                 | 1           |
      | <receive_ddl_complete>                | 1           |
      | <update_table_metadata.start>         | 1           |
      | <update_table_metadata>               | 5           |
      | <update_table_metadata.succ>          | 1           |
      | <release_table_lock.succ>             | 1           |
    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect   | db      |
      | drop table if exists sharding_4_t1 | success  | schema1 |

  Scenario: check log when ddl execute failed                                    #2
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect   | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1 | success  | schema1 |
      | conn_0 | True    | create table sharding_4_t1(id int) | success  | schema1 |
    ####为了避免drop 这个ddl的日志完全输出，避开被下一步的记录dble日志行数记录到
    Given sleep "2" seconds
    Then execute sql in "mysql-master1"
      | sql                                | expect    | db     |
      | drop table if exists sharding_4_t1 | success   | db1    |

    Given record current dble log line number in "log_num_1" in "dble-1"
    Given record current dble log line number in "log_num_2" in "dble-2"
    Given record current dble log line number in "log_num_3" in "dble-3"
    Then execute sql in "dble-1" in "user" mode
      | sql                      | expect                            | db      |
      | drop table sharding_4_t1 | Unknown table 'db1.sharding_4_t1' | schema1 |
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_1" in "dble-1"
      | key                                   | occur_times |
      | <init_ddl_trace>                      | 1           |
      | <notice_cluster_ddl_prepare.start>    | 1           |
      | <notice_cluster_ddl_prepare.succ>     | 1           |
      | <add_table_lock.start>                | 1           |
      | <add_table_lock.succ>                 | 1           |
      | <test_ddl_conn.start>                 | 5           |
      | <test_ddl_conn.succ>                  | 5           |
      | <exec_ddl_sql.start>                  | 5           |
      | <exec_ddl_sql.get_conn>               | 4           |
      | <exec_ddl_sql.fail>                   | 2           |
      | <exec_ddl_sql.succ>                   | 3           |
      | <update_table_metadata>               | 1           |
      | <notice_cluster_ddl_complete.start>   | 1           |
      | <notice_cluster_ddl_complete.succ>    | 1           |
      | <release_table_lock.succ>             | 1           |
      | <finish_ddl_trace>                    | 1           |
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_2" in "dble-2"
      | key                                   | occur_times |
      | <receive_ddl_prepare>                 | 1           |
      | <add_table_lock.start>                | 1           |
      | <add_table_lock.succ>                 | 1           |
      | <receive_ddl_complete>                | 1           |
      | <update_table_metadata>               | 1           |
      | <release_table_lock.succ>             | 1           |
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_3" in "dble-3"
      | key                                   | occur_times |
      | <receive_ddl_prepare>                 | 1           |
      | <add_table_lock.start>                | 1           |
      | <add_table_lock.succ>                 | 1           |
      | <receive_ddl_complete>                | 1           |
      | <update_table_metadata>               | 1           |
      | <release_table_lock.succ>             | 1           |

    Then execute sql in "dble-1" in "user" mode
      | sql                                | expect   | db      |
      | drop table if exists sharding_4_t1 | success  | schema1 |

  Scenario: Multiple ddl is executed concurrently, the id in the cluster dble log is correct        #3

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                      | expect                                 | db               |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='frontWorker'                   | success                                | dble_information |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name ='frontWorker'     | has{(('frontWorker', 4, 4),)}          | dble_information |

    Given execute sql "200" times in "dble-1" together use 100 connection not close
      | sql                                                                          | db      |
      | drop table if exists sharding_4_t1;create table sharding_4_t1(id int)        | schema1 |

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                           | occur_times |
      | <init_ddl_trace>              | 400         |
      | <finish_ddl_trace>            | 400         |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      java.nio.channels.AsynchronousCloseException: null
      caught err:
      """
