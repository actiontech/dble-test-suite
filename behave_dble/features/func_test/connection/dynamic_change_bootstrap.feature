# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/05/25

Feature: Dynamically adjust parameters on bootstrap use "update dble_thread_pool"

  processors、backendProcessors、processorExecutor、backendProcessorExecutor、complexExecutor、writeToBackendExecutor


#@skip_restart
  Scenario: basic test about 'update'  #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendProcessorExecutor=1
      $a  -DwriteToBackendExecutor=1
      $a  -DbackendProcessors=1
      $a  -DcomplexExecutor=2
      """
    Then restart dble in "dble-1" success
    # keepAlivetime is 60s, 'complexExecutor' heartbeat and 9066 cmd would use it
    Given sleep "60" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_pool_1"
      | conn   | toClose | sql                            | db                |
      | conn_0 | False   | select * from dble_thread_pool | dble_information  |
    Then check resultset "dble_thread_pool_1" has lines with following column values
      | name-0                  | pool_size-1 | core_pool_size-2 | active_count-3 | waiting_task_count-4 |
      | Timer                   | 1           | 1                | 0              | 0                    |
      | BusinessExecutor        | 1           | 1                | 1              | 0                    |
      | backendBusinessExecutor | 1           | 1                | 0              | 0                    |
      | complexQueryExecutor    | 2           | 2                | 1              | 0                    |
      | writeToBackendExecutor  | 1           | 1                | 1              | 0                    |
      | $_NIO_REACTOR_FRONT-    | 1           | 1                | 1              | 0                    |
      | $_NIO_REACTOR_BACKEND-  | 1           | 1                | 1              | 0                    |
    Then check "/opt/dble/conf/bootstrap.dynamic.cnf" in "dble-1" was empty

    # unsupported insert and delete
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                        | expect             | db               |
      | conn_0 | False   | insert into dble_thread_pool values ('aa',1,1,1,1)         | not support insert | dble_information |
      | conn_0 | False   | delete from dble_thread_pool where name='BusinessExecutor' | not support delete | dble_information |

    # unsupported update "core_pool_size" illegal number  DBLE0REQ-1149
#      | conn_0 | False   | update dble_thread_pool set core_pool_size=0.5 where name ='$_NIO_REACTOR_FRONT-'        | Not Supported of Value EXPR :0.5                | dble_information |
#      | conn_0 | False   | update dble_thread_pool set core_pool_size=0 where name ='writeToBackendExecutor'        | Column 'core_pool_size' can not be empty or '0' | dble_information |
#      | conn_0 | False   | update dble_thread_pool set core_pool_size=' ' where name ='$_NIO_REACTOR_BACKEND-'      | Column 'core_pool_size' can not be empty or '0' | dble_information |
#      | conn_0 | False   | update dble_thread_pool set core_pool_size='-1' where name ='$_NIO_REACTOR_FRONT-'       | unknown error:null                              | dble_information |
#      | conn_0 | False   | update dble_thread_pool set core_pool_size='afr' where name ='$complexQueryExecutor'     | unknown error:For input string: "afr"           | dble_information |
#      | conn_0 | False   | update dble_thread_pool set core_pool_size='null' where name ='$backendBusinessExecutor' | unknown error:For input string: "null"          | dble_information |
#      | conn_0 | False   | update dble_thread_pool set core_pool_size=null where name ='BusinessExecutor'           | Column 'core_pool_size' cannot be null          | dble_information |

    # unsupported update "name/active_count/waiting_task_count/pool_size"
      | conn_0 | False   | update dble_thread_pool set name='a' where name ='$_NIO_REACTOR_FRONT-'             | Primary column 'name' can not be update, please use delete & insert     | dble_information |
      | conn_0 | False   | update dble_thread_pool set active_count=3 where name ='$_NIO_REACTOR_FRONT-'       | Column 'name/active_count/waiting_task_count/pool_size' is not writable | dble_information |
      | conn_0 | False   | update dble_thread_pool set waiting_task_count=3 where name ='$_NIO_REACTOR_FRONT-' | Column 'name/active_count/waiting_task_count/pool_size' is not writable | dble_information |
      | conn_0 | False   | update dble_thread_pool set pool_size=3 where name ='$_NIO_REACTOR_FRONT-'          | Column 'name/active_count/waiting_task_count/pool_size' is not writable | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=8 where name='Timer'                     | the current line does not support modification                          | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=8 where name not in ('BusinessExecutor','backendBusinessExecutor','complexQueryExecutor','writeToBackendExecutor') | the current line does not support modification | dble_information |

    Then check "/opt/dble/conf/bootstrap.dynamic.cnf" in "dble-1" was empty
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      set to file success:/bootstrap.dynamic.cnf
      """
    # supported update syntax
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                           | expect  | db               |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=2 where name ='$_NIO_REACTOR_FRONT-'                                                                               | success | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='$_NIO_REACTOR_FRONT-' or name ='$_NIO_REACTOR_BACKEND-'                                             | success | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=6 where name like '$_NIO_REACTOR %'                                                                                | success | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=8 where name in ('BusinessExecutor','backendBusinessExecutor','complexQueryExecutor','writeToBackendExecutor')     | success | dble_information |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=10 where name not in ('Timer')                                                                                     | success | dble_information |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      set to file success:/bootstrap.dynamic.cnf
      """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      processors=10
      processorExecutor=10
      complexExecutor=10
      backendProcessorExecutor=10
      backendProcessors=10
      writeToBackendExecutor=10
      """

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect                                                | db               |
      | conn_0 | true    | select core_pool_size from dble_thread_pool         | has{((1,), (10,), (10,), (10,), (10,), (10,), (10,))} | dble_information |

    Then Restart dble in "dble-1" success
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      processors=10
      processorExecutor=10
      complexExecutor=10
      backendProcessorExecutor=10
      backendProcessors=10
      writeToBackendExecutor=10
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                              | expect                                                | db               |
      | conn_0 | False   | select core_pool_size from dble_thread_pool      | has{((1,), (10,), (10,), (10,), (10,), (10,), (10,))} | dble_information |



#@skip_restart
  Scenario: test "processors"  #2
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendProcessorExecutor=1
      $a  -DwriteToBackendExecutor=1
      $a  -DbackendProcessors=1
      $a  -DcomplexExecutor=2
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                               | expect                                 | db               |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='$_NIO_REACTOR_FRONT-'                   | success                                | dble_information |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name ='$_NIO_REACTOR_FRONT-'     | has{(('$_NIO_REACTOR_FRONT-', 4, 4),)} | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '$_NIO_REACTOR_FRONT' | wc -l
      """
    Then check result "A" value is "4"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                        | occur_times |
      | will execute thread                        | 3           |
      | Running, pool size = 1                     | 1           |
      | Running, pool size = 2                     | 1           |
      | Running, pool size = 3                     | 1           |
      | set to file success:/bootstrap.dynamic.cnf | 1           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      processors=4
      """
     # create session check
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                     | expect  | db      |
      | conn_1  | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_1  | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_1  | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
      | conn_1  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_2  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_3  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_4  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_5  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_6  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_7  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_8  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_9  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_10 | False   | select * from sharding_4_t1                             | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                               | expect                                 | db               |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=2 where name ='$_NIO_REACTOR_FRONT-'                   | success                                | dble_information |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name ='$_NIO_REACTOR_FRONT-'     | has{(('$_NIO_REACTOR_FRONT-', 2, 2),)} | dble_information |
    # use jstack check number
    Then get result of oscmd named "B" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '$_NIO_REACTOR_FRONT' | wc -l
      """
    Then check result "B" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                           | occur_times |
      | interrupt thread:Thread\[$_NIO_REACTOR_FRONT  | 4           |
      | set to file success:/bootstrap.dynamic.cnf    | 2           |

    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      processors=2
      """
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                     | expect  | db      |
      | conn_1  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_2  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_3  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_4  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_5  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_6  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_7  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_8  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_9  | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_10 | False   | select * from sharding_4_t1                             | success | schema1 |

# 设置前端超时时间小一点，update超时
# 加桩，缩容期间前端加业务


@skip_restart
  Scenario: test "backendProcessors"  #3
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendProcessorExecutor=1
      $a  -DwriteToBackendExecutor=1
      $a  -DbackendProcessors=1
      $a  -DcomplexExecutor=2
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                   | db               |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='$_NIO_REACTOR_BACKEND-'                   | success                                  | dble_information |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name ='$_NIO_REACTOR_BACKEND-'     | has{(('$_NIO_REACTOR_BACKEND-', 4, 4),)} | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '$_NIO_REACTOR_BACKEND' | wc -l
      """
    Then check result "A" value is "4"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                        | occur_times |
      | will execute thread                        | 3           |
      | Running, pool size = 1                     | 1           |
      | Running, pool size = 2                     | 1           |
      | Running, pool size = 3                     | 1           |
      | set to file success:/bootstrap.dynamic.cnf | 1           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      backendProcessors=4
      """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "reload @@config_all"
