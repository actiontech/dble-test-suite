# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/05/25

Feature: Dynamically adjust parameters on bootstrap use "update dble_thread_pool"

  processors、backendProcessors、processorExecutor、backendProcessorExecutor、complexExecutor、writeToBackendExecutor



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
    Given sleep "61" seconds
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

#     unsupported update "core_pool_size" illegal number  DBLE0REQ-1149
      | conn_0 | False   | update dble_thread_pool set core_pool_size=0.5 where name ='$_NIO_REACTOR_FRONT-'        | Not Supported of Value EXPR :0.5                                    | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=0 where name ='writeToBackendExecutor'        | Column 'core_pool_size' should be a positive integer greater than 0 | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=' ' where name ='$_NIO_REACTOR_BACKEND-'      | Not Supported of Value EXPR :' '                                    | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size='-1' where name ='$_NIO_REACTOR_FRONT-'       | Column 'core_pool_size' should be a positive integer greater than 0 | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size='afr' where name ='complexQueryExecutor'      | Update failure.The reason is incorrect integer value: 'afr'         | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size='null' where name ='backendBusinessExecutor'  | Not Supported of Value EXPR :'null'                                 | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=null where name ='BusinessExecutor'           | Column 'core_pool_size' cannot be null                              | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=-1 where name ='$_NIO_REACTOR_FRONT-'         | Column 'core_pool_size' should be a positive integer greater than 0 | dble_information |

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



  Scenario: test "processors"  #2
  # on bootstrap.cnf the default value : -Dprocessors=1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DuseThreadUsageStat=1
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                               | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '$_NIO_REACTOR_FRONT%'                     | length{(1)}                            | dble_information |
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
    Given execute "user" sql "100" times in "dble-1" at concurrent
      | sql                           | db       |
      | select * from sharding_4_t1   | schema1  |
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                           | db       |
      | select * from sharding_4_t1   | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                               | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '$_NIO_REACTOR_FRONT%'                     | length{(4)}                            | dble_information |
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
      | conn_1  | true    | select * from sharding_4_t1                             | success | schema1 |
      | conn_2  | true    | select * from sharding_4_t1                             | success | schema1 |
      | conn_3  | true    | select * from sharding_4_t1                             | success | schema1 |
      | conn_4  | true    | select * from sharding_4_t1                             | success | schema1 |
      | conn_5  | true    | select * from sharding_4_t1                             | success | schema1 |
      | conn_6  | true    | select * from sharding_4_t1                             | success | schema1 |
      | conn_7  | true    | select * from sharding_4_t1                             | success | schema1 |
      | conn_8  | true    | select * from sharding_4_t1                             | success | schema1 |
      | conn_9  | true    | select * from sharding_4_t1                             | success | schema1 |
      | conn_10 | true    | select * from sharding_4_t1                             | success | schema1 |
    Given execute "user" sql "100" times in "dble-1" at concurrent
      | sql                           | db       |
      | select * from sharding_4_t1   | schema1  |
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                           | db       |
      | select * from sharding_4_t1   | schema1  |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                   | expect          | db               |
      | conn_0 | true    | select * from dble_thread_usage where thread_name like '$_NIO_REACTOR_FRONT%'         | length{(2)}     | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  Scenario: test "backendProcessors"  #3
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendProcessorExecutor=1
      $a  -DwriteToBackendExecutor=1
      $a  -DbackendProcessors=1
      $a  -DcomplexExecutor=2
      $a  -DuseThreadUsageStat=1
      """
    Then restart dble in "dble-1" success
    Given execute "admin" sql "20" times in "dble-1" at concurrent
      | sql                       | db                |
      | reload @@config_all -r    | dble_information  |
    Given sleep "5" seconds
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '$_NIO_REACTOR_BACKEND' | wc -l
      """
    Then check result "A" value is "1"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                   | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '$_NIO_REACTOR_BACKEND%'                     | length{(1)}                              | dble_information |
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
    Given execute "admin" sql "20" times in "dble-1" at concurrent
      | sql                       | db                |
      | reload @@config_all -r    | dble_information  |
    Given sleep "5" seconds
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '$_NIO_REACTOR_BACKEND' | wc -l
      """
    Then check result "A" value is "4"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                   | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '$_NIO_REACTOR_BACKEND%'                     | length{(4)}                              | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=2 where name ='$_NIO_REACTOR_BACKEND-'                   | success                                  | dble_information |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                   | db               |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name ='$_NIO_REACTOR_BACKEND-'     | has{(('$_NIO_REACTOR_BACKEND-', 2, 2),)} | dble_information |
    # use jstack check number
    Then get result of oscmd named "A1" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '$_NIO_REACTOR_BACKEND' | wc -l
      """
    Then check result "A1" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                                | occur_times |
      | interrupt thread:Thread\[$_NIO_REACTOR_BACKEND     | 4           |
      | set to file success:/bootstrap.dynamic.cnf         | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      backendProcessors=2
      """
    Given execute "admin" sql "10" times in "dble-1" at concurrent
      | sql                       | db                |
      | reload @@config_all -r    | dble_information  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                   | db               |
      | conn_0 | true    | select * from dble_thread_usage where thread_name like '$_NIO_REACTOR_BACKEND%'                     | length{(2)}                              | dble_information |
    Then get result of oscmd named "A1" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '$_NIO_REACTOR_BACKEND' | wc -l
      """
    Then check result "A1" value is "2"

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  Scenario: test "processorExecutor"  #4
  # on bootstrap.cnf the default value : -DprocessorExecutor=1
  # check dble.log has one BusinessExecutor0
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DuseThreadUsageStat=1
      """
   Then restart dble in "dble-1" success
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql         | db        |
      | select 1    | schema1   |
   Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[BusinessExecutor0\]
      """
   Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[BusinessExecutor1\]
      \[BusinessExecutor2\]
      \[BusinessExecutor3\]
      """

    # change core_pool_size 1-4
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                           | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like 'BusinessExecutor%'                    | length{(1)}                            | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='BusinessExecutor'                   | success                                | dble_information |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name ='BusinessExecutor'     | has{(('BusinessExecutor', 4, 4),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '"BusinessExecutor' | wc -l
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
      processorExecutor=4
      """

    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql         | db        |
      | select 1    | schema1   |
   Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[BusinessExecutor0\]
      \[BusinessExecutor1\]
      \[BusinessExecutor2\]
      \[BusinessExecutor3\]
      """

    # change core_pool_size 4-2
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                           | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like 'BusinessExecutor%'                    | length{(4)}                            | dble_information |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=2 where name ='BusinessExecutor'                   | success                                | dble_information |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                           | expect                                 | db               |
      | conn_0 | true    | select name,pool_size,core_pool_size from dble_thread_pool where name ='BusinessExecutor'     | has{(('BusinessExecutor', 2, 2),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '"BusinessExecutor' | wc -l
      """
    Then check result "A" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                        | occur_times |
      | interrupt thread:Thread\[BusinessExecutor  | 4           |
      | set to file success:/bootstrap.dynamic.cnf | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      processorExecutor=2
      """
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql         | db        |
      | select 1    | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                           | expect                                 | db               |
      | conn_0 | true    | select * from dble_thread_usage where thread_name like 'BusinessExecutor%'                    | length{(2)}                            | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  Scenario: test "writeToBackendExecutor"  #5
    # writeToBackendExecutor donot exists dble.log
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendProcessorExecutor=1
      $a  -DwriteToBackendExecutor=1
      $a  -DbackendProcessors=1
      $a  -DcomplexExecutor=2
      $a  -DuseThreadUsageStat=1
      """
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                     | expect  | db      |
      | conn_1  | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_1  | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_1  | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                           | db       |
      | select * from sharding_4_t1   | schema1  |

    # change core_pool_size 1-4
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                       | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like 'writeToBackendExecutor%'                    | length{(1)}                                  | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='writeToBackendExecutor'                   | success                                      | dble_information |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name ='writeToBackendExecutor'     | has{(('writeToBackendExecutor', 4, 4),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '"writeToBackendExecutor' | wc -l
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
      writeToBackendExecutor=4
      """
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                           | db       |
      | select * from sharding_4_t1   | schema1  |


    # change core_pool_size 4-2
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like 'writeToBackendExecutor%'                    | length{(4)}                            | dble_information |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=2 where name ='writeToBackendExecutor'                   | success                                | dble_information |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                       | db               |
      | conn_0 | true    | select name,pool_size,core_pool_size from dble_thread_pool where name ='writeToBackendExecutor'     | has{(('writeToBackendExecutor', 2, 2),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '"writeToBackendExecutor' | wc -l
      """
    Then check result "A" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                              | occur_times |
      | interrupt thread:Thread\[writeToBackendExecutor  | 4           |
      | set to file success:/bootstrap.dynamic.cnf       | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      writeToBackendExecutor=2
      """
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                           | db       |
      | select * from sharding_4_t1   | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                 | db               |
      | conn_0 | true    | select * from dble_thread_usage where thread_name like 'writeToBackendExecutor%'                    | length{(2)}                            | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  Scenario: test "complexExecutor"  #6
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendProcessorExecutor=1
      $a  -DwriteToBackendExecutor=1
      $a  -DbackendProcessors=1
      $a  -DcomplexExecutor=2
      """
    Then restart dble in "dble-1" success

    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                     | expect  | db      |
      | conn_1  | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_1  | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_1  | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                                       | db       |
      | select * from sharding_4_t1  where id in (select id from sharding_4_t1)   | schema1  |


    # change core_pool_size 1-4
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                               | expect                                     | db               |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='complexQueryExecutor'                   | success                                    | dble_information |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='complexQueryExecutor'               | has{(('complexQueryExecutor', 4),)}        | dble_information |
    # keepAlivetime is 60s, 'complexExecutor' heartbeat and 9066 cmd would use it
    Given sleep "60" seconds
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '"complexQueryExecutor' | wc -l
      """
    Then check result "A" value is "4"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                        | occur_times |
      | will execute thread                        | 0           |
      | set to file success:/bootstrap.dynamic.cnf | 1           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      complexExecutor=4
      """
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                                           | db       |
      | select * from sharding_4_t1  where name in (select name from sharding_4_t1)   | schema1  |


    # change core_pool_size 4-2
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                               | expect                                 | db               |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=2 where name ='complexQueryExecutor'                   | success                                | dble_information |
    Given sleep "60" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                               | expect                                     | db               |
      | conn_0 | true    | select name,pool_size,core_pool_size from dble_thread_pool where name ='complexQueryExecutor'     | has{(('complexQueryExecutor', 2, 2),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '"complexQueryExecutor' | wc -l
      """
    Then check result "A" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                              | occur_times |
      | interrupt thread:Thread\[complexQueryExecutor    | 0           |
      | set to file success:/bootstrap.dynamic.cnf       | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      complexExecutor=2
      """
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                                       | db       |
      | select * from sharding_4_t1  where id in (select id from sharding_4_t1)   | schema1  |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  Scenario: test "backendProcessorExecutor" and usePerformanceMode=0 #7
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendProcessorExecutor=1
      $a  -DwriteToBackendExecutor=1
      $a  -DbackendProcessors=1
      $a  -DcomplexExecutor=2
      $a  -DuseThreadUsageStat=1
      """
    Then restart dble in "dble-1" success

    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                     | expect  | db      |
      | conn_1  | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_1  | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_1  | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                        | db        |
      | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)    | schema1   |
   Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[backendBusinessExecutor0\]
      """
   Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[backendBusinessExecutor1\]
      \[backendBusinessExecutor2\]
      \[backendBusinessExecutor3\]
      """

    # change core_pool_size 1-4
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                        | expect                                     | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like 'backendBusinessExecutor%'          | length{(1)}                                | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='backendBusinessExecutor'         | success                                    | dble_information |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='backendBusinessExecutor'     | has{(('backendBusinessExecutor', 4),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '"backendBusinessExecutor' | wc -l
      """
    Then check result "A" value is "1"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                        | occur_times |
      | will execute thread                        | 0           |
      | set to file success:/bootstrap.dynamic.cnf | 1           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      backendProcessorExecutor=4
      """

    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                        | db        |
      | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)    | schema1   |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                  | expect                                        | db               |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name ='backendBusinessExecutor'     | has{(('backendBusinessExecutor', 4, 4),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '"backendBusinessExecutor' | wc -l
      """
    Then check result "A" value is "4"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[backendBusinessExecutor0\]
      \[backendBusinessExecutor1\]
      \[backendBusinessExecutor2\]
      \[backendBusinessExecutor3\]
      """

    # change core_pool_size 4-2
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                  | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like 'backendBusinessExecutor%'                    | length{(4)}                            | dble_information |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=2 where name ='backendBusinessExecutor'                   | success                                | dble_information |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                  | expect                                        | db               |
      | conn_0 | true    | select name,pool_size,core_pool_size from dble_thread_pool where name ='backendBusinessExecutor'     | has{(('backendBusinessExecutor', 2, 2),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '"backendBusinessExecutor' | wc -l
      """
    Then check result "A" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                                 | occur_times |
      | interrupt thread:Thread\[backendBusinessExecutor    | 0           |
      | set to file success:/bootstrap.dynamic.cnf          | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      backendProcessorExecutor=2
      """

    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                        | db        |
      | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)    | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                  | expect                                 | db               |
      | conn_0 | true    | select * from dble_thread_usage where thread_name like 'backendBusinessExecutor%'                    | length{(2)}                            | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  Scenario: test "backendProcessorExecutor" and usePerformanceMode=1 #8
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendProcessorExecutor=1
      $a  -DwriteToBackendExecutor=1
      $a  -DbackendProcessors=1
      $a  -DcomplexExecutor=2
      $a  -DusePerformanceMode=1
      $a  -DuseThreadUsageStat=1
      """
    Then restart dble in "dble-1" success


    Given execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                     | expect  | db      |
      | conn_1  | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_1  | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_1  | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                        | db        |
      | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)    | schema1   |
   Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[backendBusinessExecutor0\]
      """
   Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[backendBusinessExecutor1\]
      \[backendBusinessExecutor2\]
      \[backendBusinessExecutor3\]
      """

    # change core_pool_size 1-4
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                  | expect                                        | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like 'backendBusinessExecutor%'                    | length{(1)}                                   | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='backendBusinessExecutor'                   | success                                       | dble_information |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name ='backendBusinessExecutor'     | has{(('backendBusinessExecutor', 4, 4),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '"backendBusinessExecutor' | wc -l
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
      backendProcessorExecutor=4
      """
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                        | db        |
      | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)    | schema1   |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[backendBusinessExecutor0\]
      \[backendBusinessExecutor1\]
      \[backendBusinessExecutor2\]
      \[backendBusinessExecutor3\]
      """

    # change core_pool_size 4-2
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                  | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like 'backendBusinessExecutor%'                    | length{(4)}                            | dble_information |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=2 where name ='backendBusinessExecutor'                   | success                                | dble_information |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                  | expect                                        | db               |
      | conn_0 | true    | select name,pool_size,core_pool_size from dble_thread_pool where name ='backendBusinessExecutor'     | has{(('backendBusinessExecutor', 2, 2),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '"backendBusinessExecutor' | wc -l
      """
    Then check result "A" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                                 | occur_times |
      | interrupt thread:Thread\[backendBusinessExecutor    | 4           |
      | set to file success:/bootstrap.dynamic.cnf          | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      backendProcessorExecutor=2
      """

    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                        | db        |
      | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)    | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                  | expect             | db               |
      | conn_0 | true    | select * from dble_thread_usage where thread_name like 'backendBusinessExecutor%'                    | length{(2)}        | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  @btrace
  Scenario: use btrace check  #9
  # on bootstrap.cnf the default value : -Dprocessors=1
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                   | expect     | db               |
      | conn_1 | False   | update dble_thread_pool set core_pool_size=4 where name ='$_NIO_REACTOR_FRONT-'       | success    | dble_information |

    Given execute "user" sql "25" times in "dble-1" together use 25 connection not close
      | sql                                 | db       |
      | drop table if exists sharding_4_t1  | schema1  |
    Given update file content "./assets/BtraceAboutBootstrap.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /reRegisterSelector/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceAboutBootstrap.java" in "dble-1"

    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                                                                                     | db                 |
      | conn_11 | True    | update dble_thread_pool set core_pool_size=1 where name like '%_NIO_REACTOR_FRONT-'     | dble_information   |
    Then check btrace "BtraceAboutBootstrap.java" output in "dble-1"
       """
       get into reRegister
       """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                   | expect                                                                                            | db               |
      | conn_1 | True    | update dble_thread_pool set core_pool_size=2 where name like '%_NIO_REACTOR_FRONT-'   | Other threads are executing management commands(insert/update/delete), please try again later.    | dble_information |
    Given stop btrace script "BtraceAboutBootstrap.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceAboutBootstrap.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutBootstrap.java.log" on "dble-1"

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DidleTimeout=20000
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                   | expect     | db               |
      | conn_1 | False   | update dble_thread_pool set core_pool_size=5 where name ='$_NIO_REACTOR_FRONT-'       | success    | dble_information |
    Given execute "user" sql "25" times in "dble-1" together use 25 connection not close
      | sql                                 | db       |
      | drop table if exists sharding_4_t1  | schema1  |
    Given update file content "./assets/BtraceAboutBootstrap.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /reRegisterSelector/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(25000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceAboutBootstrap.java" in "dble-1"
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                                                                                     | db                 |
      | conn_11 | True    | update dble_thread_pool set core_pool_size=1 where name like '%_NIO_REACTOR_FRONT-'     | dble_information   |
    Then check btrace "BtraceAboutBootstrap.java" output in "dble-1"
       """
       get into reRegister
       """
    # set idleTimeout
    Given sleep "20" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      Lost connection to MySQL server during query
      """
    Given stop btrace script "BtraceAboutBootstrap.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceAboutBootstrap.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutBootstrap.java.log" on "dble-1"
    Given sleep "60" seconds
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '$_NIO_REACTOR_FRONT' | wc -l
      """
    Then check result "A" value is "1"


    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendProcessorExecutor=1
      $a  -DwriteToBackendExecutor=1
      $a  -DbackendProcessors=8
      $a  -DcomplexExecutor=2
      $a  -DuseThreadUsageStat=1
      """
    Then restart dble in "dble-1" success
    Given update file content "./assets/BtraceAboutBootstrap.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /reRegisterSelector/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(25000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceAboutBootstrap.java" in "dble-1"

    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                                                                                      | db                 |
      | conn_4  | True    | update dble_thread_pool set core_pool_size=1 where name like '%_NIO_REACTOR_BACKEND-'    | dble_information   |

    Then check btrace "BtraceAboutBootstrap.java" output in "dble-1"
       """
       get into reRegister
       """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                   | expect                                                                                            | db               |
      | conn_3 | True    | update dble_thread_pool set core_pool_size=2 where name like '%_NIO_REACTOR_FRONT-'   | Other threads are executing management commands(insert/update/delete), please try again later.    | dble_information |
    Given stop btrace script "BtraceAboutBootstrap.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceAboutBootstrap.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutBootstrap.java.log" on "dble-1"