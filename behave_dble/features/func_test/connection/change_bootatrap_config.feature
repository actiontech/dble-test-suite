# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/05/25
#update by caiwei at 2022/01/27 for http://10.186.18.11/jira/browse/DBLE0REQ-1384

Feature: Dynamically adjust parameters on bootstrap use "update dble_thread_pool"

  NIOFrontRW、NIOBackendRW、frontWorker、backendWorker、complexQueryWorker、writeToBackendWorker、managerFrontWorker


  Scenario: basic test about 'update'  #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendWorker=1
      $a  -DwriteToBackendWorker=1
      $a  -DNIOBackendRW=1
      $a  -DcomplexQueryWorker=2
      $a  -DmanagerFrontWorker=1
      """
    Then restart dble in "dble-1" success
    # keepAlivetime is 60s, 'complexExecutor' heartbeat and 9066 cmd would use it, but when the heartbeat frequently，it will effect recycle complexQueryWorker.so remove the pool_size column. from DBLE0REQ-2007
    # Given sleep "61" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_pool_1"
      | conn   | toClose | sql                            | db                |
      | conn_0 | False   | select * from dble_thread_pool | dble_information  |
    Then check resultset "dble_thread_pool_1" has lines with following column values
      | name-0                  | core_pool_size-2 | waiting_task_count-4 |
      | Timer                   | 1                | 0                    |
      | frontWorker             | 1                | 0                    |
      | backendWorker           | 1                | 0                    |
      | complexQueryWorker      | 2                | 0                    |
      | writeToBackendWorker    | 1                | 0                    |
      | NIOFrontRW              | 1                | 0                    |
      | NIOBackendRW            | 1                | 0                    |
      | managerFrontWorker      | 1                | 0                    |
    Then check "/opt/dble/conf/bootstrap.dynamic.cnf" in "dble-1" was empty

    # unsupported insert and delete
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                        | expect             | db               |
      | conn_0 | False   | insert into dble_thread_pool values ('aa',1,1,1,1)         | not support insert | dble_information |
      | conn_0 | False   | delete from dble_thread_pool where name='frontWorker'      | not support delete | dble_information |

#     unsupported update "core_pool_size" illegal number  DBLE0REQ-1149
      | conn_0 | False   | update dble_thread_pool set core_pool_size=0.5 where name ='NIOFrontRW'             | Not Supported of Value EXPR :0.5                                    | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=0 where name ='writeToBackendWorker'     | Column 'core_pool_size' should be a positive integer greater than 0 | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=' ' where name ='NIOBackendRW'           | Not Supported of Value EXPR :' '                                    | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size='-1' where name ='NIOFrontRW'            | Column 'core_pool_size' should be a positive integer greater than 0 | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size='afr' where name ='complexQueryWorker'   | Update failure.The reason is incorrect integer value: 'afr'         | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size='null' where name ='backendWorker'       | Not Supported of Value EXPR :'null'                                 | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=null where name ='frontWorker'           | Column 'core_pool_size' cannot be null                              | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=-1 where name ='NIOFrontRW'              | Column 'core_pool_size' should be a positive integer greater than 0 | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size='abc' where name ='managerFrontWorker'   | Update failure.The reason is incorrect integer value: 'abc'         | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=0 where name ='managerFrontWorker'       | Column 'core_pool_size' should be a positive integer greater than 0 | dble_information |

    # unsupported update "name/active_count/waiting_task_count/pool_size"
      | conn_0 | False   | update dble_thread_pool set name='a' where name ='NIOFrontRW'             | Primary column 'name' can not be update, please use delete & insert     | dble_information |
      | conn_0 | False   | update dble_thread_pool set active_count=3 where name ='NIOFrontRW'       | Column 'name/active_count/waiting_task_count/pool_size' is not writable | dble_information |
      | conn_0 | False   | update dble_thread_pool set waiting_task_count=3 where name ='NIOFrontRW' | Column 'name/active_count/waiting_task_count/pool_size' is not writable | dble_information |
      | conn_0 | False   | update dble_thread_pool set pool_size=3 where name ='NIOFrontRW'          | Column 'name/active_count/waiting_task_count/pool_size' is not writable | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=8 where name='Timer'           | the current line does not support modification                          | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=8 where name not in ('frontWorker','backendWorker','complexQueryWorker','writeToBackendWorker','managerFrontWorker') | the current line does not support modification | dble_information |

    Then check "/opt/dble/conf/bootstrap.dynamic.cnf" in "dble-1" was empty
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      set to file success:/bootstrap.dynamic.cnf
      """
    # supported update syntax
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                           | expect  | db               |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=2 where name ='NIOFrontRW'                                                                                         | success | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='NIOFront' or name ='NIOBackendRW'                                                                   | success | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=6 where name like 'NIO%'                                                                                           | success | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=8 where name in ('frontWorker','backendWorker','complexQueryWorker','writeToBackendWorker','managerFrontWorker')   | success | dble_information |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=10 where name not in ('Timer','TimerScheduler')                                                                                     | success | dble_information |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      set to file success:/bootstrap.dynamic.cnf
      """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      NIOFrontRW=10
      frontWorker=10
      complexQueryWorker=10
      backendWorker=10
      NIOBackendRW=10
      writeToBackendWorker=10
      managerFrontWorker=10
      """

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect                                                | db               |
      | conn_0 | true    | select name,core_pool_size from dble_thread_pool    | has{(('Timer',1), ('TimerScheduler',2), ('frontWorker',10), ('backendWorker',10), ('complexQueryWorker',10), ('writeToBackendWorker',10), ('NIOFrontRW',10), ('NIOBackendRW',10), ('managerFrontWorker',10))} | dble_information |

    Then Restart dble in "dble-1" success
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      NIOFrontRW=10
      frontWorker=10
      complexQueryWorker=10
      backendWorker=10
      NIOBackendRW=10
      writeToBackendWorker=10
      managerFrontWorker=10
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                              | expect                                                | db               |
      | conn_0 | true    | select name,core_pool_size from dble_thread_pool | has{(('Timer',1), ('TimerScheduler',2), ('frontWorker',10), ('backendWorker',10), ('complexQueryWorker',10), ('writeToBackendWorker',10), ('NIOFrontRW',10), ('NIOBackendRW',10), ('managerFrontWorker',10))} | dble_information |


  @skip_restart
  Scenario: test "NIOFrontRW"  #2
  # on bootstrap.cnf the default value : -DNIOFrontRW=1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DuseThreadUsageStat=1
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-NIOFrontRW'                   | length{(1)}                            | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='NIOFrontRW'                   | success                                | dble_information |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='NIOFrontRW'     | has{(('NIOFrontRW', 4),)}           | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'NIOFrontRW' | wc -l
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
      NIOFrontRW=4
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
      | conn   | toClose | sql                                                                                  | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-NIOFrontRW'                | length{(4)}                            | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=2 where name ='NIOFrontRW'                | success                                | dble_information |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='NIOFrontRW'  | has{(('NIOFrontRW', 2),)}           | dble_information |
    # use jstack check number
    Then get result of oscmd named "B" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'NIOFrontRW' | wc -l
      """
    Then check result "B" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                           | occur_times |
      | will interrupt thread                         | 2           |
      | set to file success:/bootstrap.dynamic.cnf    | 2           |

    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      NIOFrontRW=2
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
      | conn_0 | true    | select * from dble_thread_usage where thread_name like '%-NIOFrontRW'                 | length{(2)}     | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  Scenario: test "NIOBackendRW"  #3
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendWorker=1
      $a  -DwriteToBackendWorker=1
      $a  -DNIOBackendRW=1
      $a  -DcomplexQueryWorker=2
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
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'NIOBackendRW' | wc -l
      """
    Then check result "A" value is "1"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect                                   | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-NIOBackendRW'                 | length{(1)}                              | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='NIOBackendRW'                 | success                                  | dble_information |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='NIOBackendRW'   | has{(('NIOBackendRW', 4),)}           | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'NIOBackendRW' | wc -l
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
      NIOBackendRW=4
      """
    Given execute "admin" sql "20" times in "dble-1" at concurrent
      | sql                       | db                |
      | reload @@config_all -r    | dble_information  |
    Given sleep "5" seconds
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'NIOBackendRW' | wc -l
      """
    Then check result "A" value is "4"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect                                   | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-NIOBackendRW'                 | length{(4)}                              | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=2 where name ='NIOBackendRW'                 | success                                  | dble_information |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                   | db               |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='NIOBackendRW'               | has{(('NIOBackendRW', 2),)}           | dble_information |
    # use jstack check number
    Then get result of oscmd named "A1" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'NIOBackendRW' | wc -l
      """
    Then check result "A1" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                                | occur_times |
      | will interrupt thread                              | 2           |
      | set to file success:/bootstrap.dynamic.cnf         | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      NIOBackendRW=2
      """
    Given execute "admin" sql "10" times in "dble-1" at concurrent
      | sql                       | db                |
      | reload @@config_all -r    | dble_information  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                   | db               |
      | conn_0 | true    | select * from dble_thread_usage where thread_name like '%-NIOBackendRW'                             | length{(2)}                              | dble_information |
    Then get result of oscmd named "A1" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'NIOBackendRW' | wc -l
      """
    Then check result "A1" value is "2"

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """


  Scenario: test "frontWorker"  #4
  # on bootstrap.cnf the default value : -DfrontWorker=1
  # check dble.log has one frontWorker0
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
      \[0-frontWorker\]
      """ 
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[1-frontWorker1\]
      \[2-frontWorker2\]
      \[3-frontWorker3\]
      """

    # change core_pool_size 1-4
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                      | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-frontWorker'                   | length{(1)}                            | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='frontWorker'                   | success                                | dble_information |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='frontWorker'     | has{(('frontWorker', 4),)}          | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'frontWorker' | wc -l
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
      frontWorker=4
      """

    Given execute "user" sql "200" times in "dble-1" together use 100 connection not close
      | sql                | db        |
      | select user()      | schema1   |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[0-frontWorker\]
      \[1-frontWorker\]
      \[2-frontWorker\]
      \[3-frontWorker\]
      """

    # change core_pool_size 4-2
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                      | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-frontWorker'                   | length{(4)}                            | dble_information |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=2 where name ='frontWorker'                   | success                                | dble_information |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                           | expect                                 | db               |
      | conn_0 | true    | select name,core_pool_size from dble_thread_pool where name ='frontWorker'          | has{(('frontWorker', 2),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'frontWorker' | wc -l
      """
    Then check result "A" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                        | occur_times |
      | will interrupt thread                      | 2           |
      | set to file success:/bootstrap.dynamic.cnf | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      frontWorker=2
      """
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql         | db        |
      | select 1    | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                           | expect                                 | db               |
      | conn_0 | true    | select * from dble_thread_usage where thread_name like '%-frontWorker'                        | length{(2)}                            | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  Scenario: test "writeToBackendWorker"  #5
    # writeToBackendWorker donot exists dble.log
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendWorker=1
      $a  -DwriteToBackendWorker=1
      $a  -DNIOBackendRW=1
      $a  -DcomplexQueryWorker=2
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
      | conn   | toClose | sql                                                                                               | expect                                       | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-writeToBackendWorker'                   | length{(1)}                                  | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='writeToBackendWorker'                   | success                                      | dble_information |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='writeToBackendWorker'     | has{(('writeToBackendWorker', 4),)}       | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'writeToBackendWorker' | wc -l
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
      writeToBackendWorker=4
      """
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                           | db       |
      | select * from sharding_4_t1   | schema1  |


    # change core_pool_size 4-2
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                               | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-writeToBackendWorker'                   | length{(4)}                            | dble_information |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=2 where name ='writeToBackendWorker'                   | success                                | dble_information |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                       | db               |
      | conn_0 | true    | select name,core_pool_size from dble_thread_pool where name ='writeToBackendWorker'     | has{(('writeToBackendWorker', 2),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'writeToBackendWorker' | wc -l
      """
    Then check result "A" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                              | occur_times |
      | will interrupt thread                            | 2           |
      | set to file success:/bootstrap.dynamic.cnf       | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      writeToBackendWorker=2
      """
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                           | db       |
      | select * from sharding_4_t1   | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                                 | db               |
      | conn_0 | true    | select * from dble_thread_usage where thread_name like '%-writeToBackendWorker'                     | length{(2)}                            | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  Scenario: test "complexQueryWorker"  #6
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendWorker=1
      $a  -DwriteToBackendWorker=1
      $a  -DNIOBackendRW=1
      $a  -DcomplexQueryWorker=2
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
      | conn   | toClose | sql                                                                                             | expect                                     | db               |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='complexQueryWorker'                   | success                                    | dble_information |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='complexQueryWorker'               | has{(('complexQueryWorker', 4),)}          | dble_information |
    # complexExecutor线程池比较特殊：最大容量为数值型的最大值，可以理解为无限大，可设置的core_pool_size为线程池的最小值
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'complexQueryWorker' | wc -l
      """
    Then check result "A" value as ">=4"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                        | occur_times |
      | will execute thread                        | 0           |
      | set to file success:/bootstrap.dynamic.cnf | 1           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      complexQueryWorker=4
      """
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                                           | db       |
      | select * from sharding_4_t1  where name in (select name from sharding_4_t1)   | schema1  |


    # change core_pool_size 4-2
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                               | expect                                 | db               |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=2 where name ='complexQueryWorker'                     | success                                | dble_information |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                               | expect                                   | db               |
      | conn_0 | true    | select name,core_pool_size from dble_thread_pool where name ='complexQueryWorker'                 | has{(('complexQueryWorker', 2),)}        | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'complexQueryWorker' | wc -l
      """
    Then check result "A" value as ">=2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                              | occur_times |
      | will interrupt thread                            | 0           |
      | set to file success:/bootstrap.dynamic.cnf       | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      complexQueryWorker=2
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



  Scenario: test "backendWorker" and usePerformanceMode=0 #7
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendWorker=1
      $a  -DwriteToBackendWorker=1
      $a  -DNIOBackendRW=1
      $a  -DcomplexQueryWorker=2
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
      \[0-backendWorker\]
      """
   Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[1-backendWorker\]
      \[2-backendWorker\]
      \[3-backendWorker\]
      """

    # change core_pool_size 1-4
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                                     | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-backendWorker'         | length{(1)}                                | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='backendWorker'         | success                                    | dble_information |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='backendWorker'     | has{(('backendWorker', 4),)}               | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'backendWorker' | wc -l
      """
    Then check result "A" value is "1"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                        | occur_times |
      | will execute thread                        | 0           |
      | set to file success:/bootstrap.dynamic.cnf | 1           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      backendWorker=4
      """

    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                        | db        |
      | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)    | schema1   |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                        | expect                              | db               |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='backendWorker'     | has{(('backendWorker', 4),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'backendWorker' | wc -l
      """
    Then check result "A" value is "4"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[0-backendWorker\]
      \[1-backendWorker\]
      \[2-backendWorker\]
      \[3-backendWorker\]
      """

    # change core_pool_size 4-2
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                        | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-backendWorker'                   | length{(4)}                            | dble_information |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=2 where name ='backendWorker'                   | success                                | dble_information |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                        | expect                              | db               |
      | conn_0 | true    | select name,core_pool_size from dble_thread_pool where name ='backendWorker'     | has{(('backendWorker', 2),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'backendWorker' | wc -l
      """
    Then check result "A" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                                 | occur_times |
      | will interrupt thread                               | 0           |
      | set to file success:/bootstrap.dynamic.cnf          | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      backendWorker=2
      """

    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                        | db        |
      | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)    | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                  | expect                                 | db               |
      | conn_0 | true    | select * from dble_thread_usage where thread_name like '%-backendWorker'                             | length{(2)}                            | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  Scenario: test "backendWorker" and usePerformanceMode=1 #8
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendWorker=1
      $a  -DwriteToBackendWorker=1
      $a  -DNIOBackendRW=1
      $a  -DcomplexQueryWorker=2
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
      \[0-backendWorker\]
      """
   Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[1-backendWorker\]
      \[2-backendWorker\]
      \[3-backendWorker\]
      """

    # change core_pool_size 1-4
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                        | expect                                        | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-backendWorker'                   | length{(1)}                                   | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='backendWorker'                   | success                                       | dble_information |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='backendWorker'     | has{(('backendWorker', 4),)}     | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'backendWorker' | wc -l
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
      backendWorker=4
      """
    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                        | db        |
      | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)    | schema1   |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[0-backendWorker\]
      \[1-backendWorker\]
      \[2-backendWorker\]
      \[3-backendWorker\]
      """

    # change core_pool_size 4-2
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                        | expect                                 | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-backendWorker'                   | length{(4)}                            | dble_information |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=2 where name ='backendWorker'                   | success                                | dble_information |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                        | expect                                        | db               |
      | conn_0 | true    | select name,core_pool_size from dble_thread_pool where name ='backendWorker'     | has{(('backendWorker', 2),)}               | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'backendWorker' | wc -l
      """
    Then check result "A" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                                 | occur_times |
      | will interrupt thread                               | 2           |
      | set to file success:/bootstrap.dynamic.cnf          | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      backendWorker=2
      """

    Given execute "user" sql "100" times in "dble-1" together use 100 connection not close
      | sql                                                        | db        |
      | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)    | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                  | expect             | db               |
      | conn_0 | true    | select * from dble_thread_usage where thread_name like '%-backendWorker'                    | length{(2)}        | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  @btrace
  Scenario: use btrace check  #9
  # on bootstrap.cnf the default value : -DNIOFrontRW=1
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                   | expect     | db               |
      | conn_1 | False   | update dble_thread_pool set core_pool_size=4 where name ='NIOFrontRW'                 | success    | dble_information |

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
      | conn_11 | True    | update dble_thread_pool set core_pool_size=1 where name = 'NIOFrontRW'                  | dble_information   |
    Then check btrace "BtraceAboutBootstrap.java" output in "dble-1"
       """
       get into reRegister
       """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                   | expect                                                                                           | db               |
      | conn_1 | True    | update dble_thread_pool set core_pool_size=2 where name = 'NIOFrontRW'                | Other threads are executing management commands(insert/update/delete), please try again later    | dble_information |
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
      | conn_1 | False   | update dble_thread_pool set core_pool_size=5 where name ='NIOFrontRW'                 | success    | dble_information |
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
      | conn_11 | True    | update dble_thread_pool set core_pool_size=1 where name = 'NIOFrontRW'                  | dble_information   |
    Then check btrace "BtraceAboutBootstrap.java" output in "dble-1"
       """
       get into reRegister
       """
    # set idleTimeout
    Given sleep "20" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble_admin_query.log" in host "dble-1"
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
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'NIOFrontRW' | wc -l
      """
    Then check result "A" value is "1"


    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendWorker=1
      $a  -DwriteToBackendWorker=1
      $a  -DNIOBackendRW=8
      $a  -DcomplexQueryWorker=2
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
      | conn    | toClose | sql                                                                         | db                 |
      | conn_4  | True    | update dble_thread_pool set core_pool_size=1 where name = 'NIOBackendRW'    | dble_information   |

    Then check btrace "BtraceAboutBootstrap.java" output in "dble-1"
       """
       get into reRegister
       """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                   | expect                                                                                           | db               |
      | conn_3 | True    | update dble_thread_pool set core_pool_size=2 where name like 'NIOBackendRW'           | Other threads are executing management commands(insert/update/delete), please try again later    | dble_information |
    Given stop btrace script "BtraceAboutBootstrap.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceAboutBootstrap.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutBootstrap.java.log" on "dble-1"

  # DBLE0REQ-2111
  Scenario: test "managerFrontWorker"  #10
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      /-DmanagerFrontWorker=/d
      $a -DmanagerFrontWorker=abc
    """
    Then restart dble in "dble-1" failed for
    """
      property \[ managerFrontWorker \] 'abc' data type should be int
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      s/-DmanagerFrontWorker=abc/-DmanagerFrontWorker=0/
    """
    Then restart dble in "dble-1" failed for
    """
      Property \[ managerFrontWorker \] '0' in bootstrap.cnf is illegal, you may need use the default value.* replaced
    """

  # check dble.log has one managerFrontWorker0
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     s/-DmanagerFrontWorker=0/-DmanagerFrontWorker=1/
     $a  -DuseThreadUsageStat=1
     """
   Then restart dble in "dble-1" success
    Given execute "admin" sql "100" times in "dble-1" together use 100 connection not close
      | sql                   | db               |
      | select * from version | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[0-managerFrontWorker\]
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[1-managerFrontWorker\]
      \[2-managerFrontWorker\]
      \[3-managerFrontWorker\]
      """

    # change core_pool_size 1-4
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                   | expect                                 | db               |
      | conn_0 | False   | select variable_value from dble_variables where variable_name='managerFrontWorker'    | has{(('1',),)}                         | dble_information |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-managerFrontWorker'         | length{(1)}                            | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=4 where name ='managerFrontWorker'         | success                                | dble_information |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name ='managerFrontWorker'     | has{(('managerFrontWorker', 4),)}      | dble_information |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'managerFrontWorker' | wc -l
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
      managerFrontWorker=4
      """

    Given execute "admin" sql "200" times in "dble-1" together use 100 connection not close
      | sql                   | db               |
      | select * from version | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[0-managerFrontWorker\]
      \[1-managerFrontWorker\]
      \[2-managerFrontWorker\]
      \[3-managerFrontWorker\]
      """

    # change core_pool_size 4-2
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                               | expect                            | db               |
      | conn_0 | False   | select * from dble_thread_usage where thread_name like '%-managerFrontWorker'     | length{(4)}                       | dble_information |
      | conn_0 | true    | update dble_thread_pool set core_pool_size=2 where name ='managerFrontWorker'     | success                           | dble_information |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                               | expect                            | db               | timeout |
      | conn_0 | true    | select name,core_pool_size from dble_thread_pool where name ='managerFrontWorker' | has{(('managerFrontWorker', 2),)} | dble_information | 3       |
    # use jstack check number
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'managerFrontWorker' | wc -l
      """
    Then check result "A" value is "2"
    # use dble.log check
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                        | occur_times |
      | will interrupt thread                      | 2           |
      | set to file success:/bootstrap.dynamic.cnf | 2           |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      managerFrontWorker=2
      """
    Given execute "admin" sql "100" times in "dble-1" together use 100 connection not close
      | sql                   | db               |
      | select * from version | dble_information |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                           | expect      | db               |
      | conn_0 | true    | select * from dble_thread_usage where thread_name like '%-managerFrontWorker' | length{(2)} | dble_information |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """

  # DBLE0REQ-2111
  Scenario: test "managerFrontWorker" btrace  #11
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                              | expect     | db               |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=2 where name in ('NIOFrontRW','frontWorker','managerFrontWorker')     | success    | dble_information |
      | conn_0 | False   | select name,core_pool_size from dble_thread_pool where name in ('NIOFrontRW','frontWorker','managerFrontWorker') | has{(('NIOFrontRW', 2),('frontWorker', 2),('managerFrontWorker', 2))} | dble_information |
    
    Given delete file "/opt/dble/BtraceQueryHandler.java" on "dble-1"
    Given delete file "/opt/dble/BtraceQueryHandler.java.log" on "dble-1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group3" delayThreshold="100">
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="100" minCon="20" primary="true" />
      <dbInstance name="hostS3" password="111111" url="172.100.9.4:3307" user="test" maxCon="100" minCon="20" primary="false" />
    </dbGroup>
    """

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                  | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(20)) | success | schema1 |

    Given prepare a thread run btrace script "BtraceQueryHandler.java" in "dble-1"
    Given prepare a thread execute sql "insert into sharding_4_t1 values (1,1),(2,2)" with "conn_1"
    # 分库分表用户执行sql进桩
    Then check btrace "BtraceQueryHandler.java" output in "dble-1"
      """
      get into shardingQuery
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                | expect     | db               | timeout |
      | conn_0 | False   | reload @@config_all                | success    | dble_information |  5      |
      | conn_0 | False   | select * from dble_thread_pool     | success    | dble_information |         |
    #管理端执行sql不进桩，桩仍旧只输出一次  
    Then check btrace "BtraceQueryHandler.java" output in "dble-1"
      """
      get into shardingQuery
      """
    Given stop btrace script "BtraceQueryHandler.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceQueryHandler.java.log" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                              | expect  | db  |
      | rwS1  | 111111 | conn_2 | False   | drop table if exists test_table                  | success | db1 |
      | rwS1  | 111111 | conn_2 | False   | create table test_table(id int,name varchar(20)) | success | db1 |
    Given prepare a thread run btrace script "BtraceQueryHandler.java" in "dble-1"
    Given prepare a thread execute sql "insert into test_db values (1, 'name1')" with "conn_2"
    # 读写分离用户执行sql进桩
    Then check btrace "BtraceQueryHandler.java" output in "dble-1"
      """
      get into rwSplitQuery
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                | expect     | db               |
      | conn_0 | False   | show @@heartbeat                   | success    | dble_information |
      | conn_0 | False   | select * from dble_thread_pool     | success    | dble_information | 
    #管理端执行sql不进桩，桩仍旧只输出一次
    Then check btrace "BtraceQueryHandler.java" output in "dble-1"
      """
      get into rwSplitQuery
      """ 
    Given stop btrace script "BtraceQueryHandler.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceQueryHandler.java.log" on "dble-1"

    Given prepare a thread run btrace script "BtraceQueryHandler.java" in "dble-1"
    Given prepare a thread execute sql "show @@heartbeat" with "conn_0"
    # 管理用户执行sql进桩
    Then check btrace "BtraceQueryHandler.java" output in "dble-1"
      """
      get into managerQuery
      """
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                              | expect  | db      |
      | test  | 111111 | conn_1 | False   | insert into sharding_4_t1 values (1,'x'),(2,'y') | success | schema1 |
      | test  | 111111 | conn_1 | False   | select * from sharding_4_t1                      | success | schema1 |
      | test  | 111111 | conn_1 | True    | drop table if exists sharding_4_t1               | success | schema1 |
      | rwS1  | 111111 | conn_2 | False   | select * from test_table                         | success | db1     |
      | rwS1  | 111111 | conn_2 | True    | drop table if exists test_table                  | success | db1     |
    #分库分表、读写分离用户执行sql不进桩，桩仍旧只输出一次
    Then check btrace "BtraceQueryHandler.java" output in "dble-1"
      """
      get into managerQuery
      """ 
    Given stop btrace script "BtraceQueryHandler.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceQueryHandler.java" on "dble-1"
    Given delete file "/opt/dble/BtraceQueryHandler.java.log" on "dble-1"