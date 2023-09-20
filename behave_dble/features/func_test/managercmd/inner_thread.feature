# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2023/9/11
# 3.23.08 - DBLE0REQ-2112 & DBLE0REQ-1918 & DBLE0REQ-2351
# kill timer线程池触发告警原因：TimerScheduler中13个定时任务中有一部分是转交给timer执行的，timer hang了或者kill了，就会有告警（触发告警的其实是TimerScheduler线程 ）；
# kill TimerScheduler线程池未触发告警原因： TimerScheduler是定时任务调度器所用到的线程池，当这个线程池kill后，定时调度器也不工作了，
## 就没有谁能发现TimerScheduler不工作了（包括ThreadChecker线程，这个线程是针对正在执行任务的线程，发现任务执行过久才被视为疑似hang的）

Feature: check inner thread command
  thread @@kill [name\|poolname] ='?'
  thread @@recover [name\|poolname] ='?'
  thread @@print [name ='?']

  Scenario: check thread @@print [name ='?'] #1
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                     | expect                                                        |
      | conn_0 | False   | thread @@print poolname='Timer'         | Syntax Error, Please check the help to use the thread command |
      | conn_0 | False   | thread @@print name='Timer'             | Thread[Timer] does not exist                                  |
      | conn_0 | False   | thread @@print name='2-Timer'           | Thread[2-Timer] does not exist                                |
      | conn_0 | False   | thread @@print name='0-abc'             | Thread[0-abc] does not exist                                  |

    Then execute admin cmd "thread @@print name='0-Timer'"
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    select thread\[{0-Timer}\]
    \"0-Timer\" #.*, state:.*, stackTrace:
    """
    Then execute admin cmd "thread @@print name='1-TimerScheduler'"
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    select thread\[{1-TimerScheduler}\]
    \"1-TimerScheduler\" #.*, state:.*, stackTrace:
    """
    Then execute admin cmd "thread @@print name='0-frontWorker'"
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    select thread\[{0-frontWorker}\]
    \"0-frontWorker\" #.*, state:.*, stackTrace:
    """
    Then execute admin cmd "thread @@print name='0-managerFrontWorker'"
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    select thread\[{0-managerFrontWorker}\]
    \"0-managerFrontWorker\" #.*, state:.*, stackTrace:
    """
    Then execute admin cmd "thread @@print name='QuartzScheduler_QuartzSchedulerThread'"
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    select thread\[{QuartzScheduler_QuartzSchedulerThread}\]
    \"QuartzScheduler_QuartzSchedulerThread\" #.*, state:.*, stackTrace:
    """
    Then execute admin cmd "thread @@print name='0-ThreadChecker'"
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    select thread\[{0-ThreadChecker}\]
    \"0-ThreadChecker\" #.*, state:.*, stackTrace:
    """
    Then execute admin cmd "thread @@print name='connection-pool-evictor-thread'"
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    select thread\[{connection-pool-evictor-thread}\]
    \"connection-pool-evictor-thread\" #.*, state:.*, stackTrace:
    """
    Then execute admin cmd "thread @@print name='1-NIOBackendRW'"
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    select thread\[{1-NIOBackendRW}\]
    \"1-NIOBackendRW\" #.*, state:.*, stackTrace:
    """
    Then execute admin cmd "thread @@print"
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    select all thread
    _Dble_Server\" #.*, state:.*, stackTrace:
    _Dble_Manager\" #.*, state:.*, stackTrace:
    """


  Scenario: check thread @@kill poolname ='Timer' and thread @@recover poolname ='Timer' #2
    # check jstack
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '\-Timer"' | wc -l
      """
    Then check result "A" value is "1"

    # case 1: check thread @@kill poolname='Timer'
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                           | expect                                                            | db               |
      | conn_0 | False   | thread @@kill poolname='0-Timer'                                              | The threadPool[0-Timer] does not exist                            | dble_information |
      | conn_0 | False   | thread @@kill poolname='123abc'                                               | The threadPool[123abc] does not exist                             | dble_information |
      | conn_0 | False   | thread @@kill pool_name='Timer'                                               | Syntax Error, Please check the help to use the thread command     | dble_information |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name='Timer' | has{(('Timer', 1, 1),)}                                           | dble_information |
      | conn_0 | False   | thread @@kill poolname='Timer'                                                | success                                                           | dble_information |
      # after thread @@kill pool_size=0, active_task_count=0, task_queue_size=0
      | conn_0 | False   | select pl.name,pl.pool_size,pl.core_pool_size,tk.active_task_count,tk.task_queue_size from dble_thread_pool pl join dble_thread_pool_task tk on pl.name=tk.name where pl.name='Timer' | has{(('Timer', 0, 1, 0, 0),)} | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs1"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select pl.name,pl.pool_size,pl.core_pool_size,tk.task_queue_size,tk.completed_task,tk.total_task from dble_thread_pool pl join dble_thread_pool_task tk on pl.name=tk.name where pl.name='Timer' | dble_information |

    # check jstack
    Then get result of oscmd named "B" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '\-Timer"' | wc -l
      """
    Then check result "B" value is "0"

    # check log
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    manual shutdown threadPool\[Timer\] ... start ...
    manual shutdown threadPool\[Timer\] ... end ...
    ThreadPool\[Timer\] execute fail, isShutDown\[true\], task_queue_size\[0\]
    Trigger ThreadPool\[Timer\]'s alarm
    """

    Given sleep "2" seconds
    # after thread @@kill completed_task and total_task don't change
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs2"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select pl.name,pl.pool_size,pl.core_pool_size,tk.task_queue_size,tk.completed_task,tk.total_task from dble_thread_pool pl join dble_thread_pool_task tk on pl.name=tk.name where pl.name='Timer' | dble_information |
    Then check resultsets "rs1" and "rs2" are same in following columns
      | column          | column_index |
      | name            | 0            |
      | pool_size       | 1            |
      | core_pool_size  | 2            |
      | task_queue_size | 3            |
      | completed_task  | 4            |
      | total_task      | 5            |
    Then  execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_1 | False   | begin                                                   | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
      | conn_1 | False   | commit                                                  | success | schema1 |
      | conn_1 | True    | select * from sharding_4_t1                             | success | schema1 |

    # case 2: check thread @@recover poolname='Timer'
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                           | expect                                                         | db               | timeout |
      | conn_0 | False   | thread @@recover poolname='0-Timer'                                           | The threadPool[0-Timer] does not exist                         | dble_information |         |
      | conn_0 | False   | thread @@recover poolname='123abc'                                            | The threadPool[123abc] does not exist                          | dble_information |         |
      | conn_0 | False   | thread @@recover poolname='TimerScheduler'                                    | threadPool[TimerScheduler] is not shutdown, no need to recover | dble_information |         |
      | conn_0 | False   | thread @@recover pool_name='Timer'                                            | Syntax Error, Please check the help to use the thread command  | dble_information |         |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name='Timer' | has{(('Timer', 0, 1),)}                                        | dble_information |         |
      | conn_0 | False   | thread @@recover poolname='Timer'                                             | success                                                        | dble_information |         |
      # after thread @@recover pool_size=1
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name='Timer' | has{(('Timer', 1, 1),)}                                        | dble_information | 3       |

    # check completed_task and total_task recalculate
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs3"
      | conn   | toClose | sql                                                                                                                                                                                              | db               |
      | conn_0 | true    | select pl.name,pl.pool_size,pl.core_pool_size,tk.task_queue_size,tk.completed_task,tk.total_task from dble_thread_pool pl join dble_thread_pool_task tk on pl.name=tk.name where pl.name='Timer' | dble_information |
    Then check resultsets "rs1" and "rs3" the columns have the following relationship
      | column          | column_index | relation_type |
      | name            | 0            |               |
      | pool_size       | 1            | <             |
      | core_pool_size  | 2            |               |
      | completed_task  | 4            | >             |
      | total_task      | 5            | >             |

    # check jstack
    Then get result of oscmd named "C" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '\-Timer"' | wc -l
      """
    Then check result "C" value is "1"

    # check log
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    manual recover threadPool\[Timer\] ... start ...
    manual recover threadPool\[Timer\] ... end ...
    """
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "10,13" times
    """
    Resolve ThreadPool\[Timer\]'s alarm
    """

    Then  execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_1 | False   | begin                                                   | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
      | conn_1 | False   | commit                                                  | success | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_1 | True    | drop table if exists sharding_4_t1                      | success | schema1 |

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                | expect                                                | db               |
      | conn_0 | False   | thread @@recover poolname='Timer'  | threadPool[Timer] is not shutdown, no need to recover | dble_information |
      | conn_0 | False   | thread @@recover poolname='Timer'  | threadPool[Timer] is not shutdown, no need to recover | dble_information |
      | conn_0 | False   | thread @@kill poolname='Timer'     | success                                               | dble_information |
      | conn_0 | False   | thread @@kill poolname='Timer'     | threadPool[Timer] already shutdown                    | dble_information |
      | conn_0 | True    | thread @@recover poolname='Timer'  | success                                               | dble_information |


  Scenario: check thread @@kill poolname ='TimerScheduler' and thread @@recover poolname ='TimerScheduler' #3
    # check jstack
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '\-TimerScheduler"' | wc -l
      """
    Then check result "A" value is "2"

    # case 1: check thread @@kill poolname='TimerScheduler'
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect                                                            | db               |
      | conn_0 | False   | thread @@kill poolname='0-TimerScheduler'                                              | The threadPool[0-TimerScheduler] does not exist                   | dble_information |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name='TimerScheduler' | has{(('TimerScheduler', 2, 2),)}                                  | dble_information |
      | conn_0 | False   | thread @@kill poolname='TimerScheduler'                                                | success                                                           | dble_information |
      # after thread @@kill pool_size=0, active_task_count=0, task_queue_size=0
      | conn_0 | False   | select pl.name,pl.pool_size,pl.core_pool_size,tk.active_task_count,tk.task_queue_size from dble_thread_pool pl join dble_thread_pool_task tk on pl.name=tk.name where pl.name='TimerScheduler' | has{(('TimerScheduler', 0, 2, 0, 0),)} | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs1"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select pl.name,pl.pool_size,pl.core_pool_size,tk.task_queue_size,tk.completed_task,tk.total_task from dble_thread_pool pl join dble_thread_pool_task tk on pl.name=tk.name where pl.name='TimerScheduler' | dble_information |

    # check jstack
    Then get result of oscmd named "B" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '\-TimerScheduler"' | wc -l
      """
    Then check result "B" value is "0"

    # check log
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    manual shutdown threadPool\[TimerScheduler\] ... start ...
    dbGroup\[ha_group1\] stopHeartbeat...
    dbGroup\[ha_group2\] stopHeartbeat...
    dbGroup\[ha_group1\] stopDelayDetection...
    dbGroup\[ha_group2\] stopDelayDetection...
    stopXaIdCheckPeriod...
    manual shutdown threadPool\[TimerScheduler\] ... end ...
    """

    Given sleep "2" seconds
    # after thread @@kill completed_task and total_task don't change
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs2"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select pl.name,pl.pool_size,pl.core_pool_size,tk.task_queue_size,tk.completed_task,tk.total_task from dble_thread_pool pl join dble_thread_pool_task tk on pl.name=tk.name where pl.name='TimerScheduler' | dble_information |
    Then check resultsets "rs1" and "rs2" are same in following columns
      | column          | column_index |
      | name            | 0            |
      | pool_size       | 1            |
      | core_pool_size  | 2            |
      | task_queue_size | 3            |
      | completed_task  | 4            |
      | total_task      | 5            |
    Then  execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect                                                                                  | db      |
      | conn_1 | True   | drop table if exists sharding_4_t1  | the dbInstance[172.100.9.5:3306] can't reach. Please check the dbInstance is accessible | schema1 |
      # check heartbeat
      Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql               | expect                                                                                       |
      | conn_0 | true    | show @@heartbeat  | hasStr{'hostM1', '172.100.9.5', 3306, 'stop'}, hasStr{'hostM2', '172.100.9.6', 3306, 'stop'} |

    # case 2: check thread @@recover poolname='TimerScheduler'
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect                                                        | db               | timeout |
      | conn_0 | False   | thread @@recover poolname='0-TimerScheduler'                                           | The threadPool[0-TimerScheduler] does not exist               | dble_information |         |
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name='TimerScheduler' | has{(('TimerScheduler', 0, 2),)}                              | dble_information |         |
      | conn_0 | False   | thread @@recover poolname='TimerScheduler'                                             | success                                                       | dble_information |         |
      # after thread @@recover pool_size=1
      | conn_0 | False   | select name,pool_size,core_pool_size from dble_thread_pool where name='TimerScheduler' | has{(('TimerScheduler', 2, 2),)}                              | dble_information | 3       |

    # check completed_task and total_task recalculate
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs3"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select pl.name,pl.pool_size,pl.core_pool_size,tk.task_queue_size,tk.completed_task,tk.total_task from dble_thread_pool pl join dble_thread_pool_task tk on pl.name=tk.name where pl.name='TimerScheduler' | dble_information |
    Then check resultsets "rs1" and "rs3" the columns have the following relationship
      | column          | column_index | relation_type |
      | name            | 0            |               |
      | pool_size       | 1            | <             |
      | core_pool_size  | 2            |               |
      | completed_task  | 4            | >             |
      | total_task      | 5            | >             |

    # check jstack
    Then get result of oscmd named "C" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep '\-TimerScheduler"' | wc -l
      """
    Then check result "C" value is "2"

    # check log
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    manual recover threadPool\[TimerScheduler\] ... start ...
    manual recover threadPool\[TimerScheduler\] ... end ...
    dbGroup\[ha_group1\] startHeartbeat...
    dbGroup\[ha_group2\] startHeartbeat...
    dbGroup\[ha_group1\] startDelayDetection...
    dbGroup\[ha_group2\] startDelayDetection...
    stopXaIdCheckPeriod...
    """

    Then  execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_1 | False   | begin                                                   | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
      | conn_1 | False   | commit                                                  | success | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_1 | True    | drop table if exists sharding_4_t1                      | success | schema1 |

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                         | expect                                                                                   | db               |
    # check heartbeat
      | conn_0 | False   | show @@heartbeat                            | hasStr{'hostM1', '172.100.9.5', 3306, 'ok'}, hasStr{'hostM2', '172.100.9.6', 3306, 'ok'} | dble_information |
      | conn_0 | False   | thread @@kill poolname='TimerScheduler'     | success                                                                                  | dble_information |
      | conn_0 | False   | thread @@kill poolname='TimerScheduler'     | threadPool[TimerScheduler] already shutdown                                              | dble_information |
      | conn_0 | True    | thread @@recover poolname='TimerScheduler'  | success                                                                                  | dble_information |


  Scenario: check thread @@kill name ='?' and thread @@recover name ='?' #4
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a  -DbackendWorker=6
      $a  -DwriteToBackendWorker=5
      $a  -DNIOBackendRW=4
      $a  -DcomplexQueryWorker=3
      """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs1"
      | conn   | toClose | sql                                                             | db                |
      | conn_0 | False   | select name, core_pool_size, active_count from dble_thread_pool | dble_information  |
    Then check resultset "rs1" has lines with following column values
      | name-0                  | core_pool_size-1 | active_count-2 |
      | frontWorker             | 1                | 1              |
      | backendWorker           | 6                | 0              |
      | NIOBackendRW            | 4                | 4              |
      | writeToBackendWorker    | 5                | 5              |
      | complexQueryWorker      | 3                | 1              |

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                      | expect                                                        | db               | timeout |
      | conn_0 | False   | thread @@kill name='TimerScheduler'                                      | Thread[TimerScheduler] does not exist                         | dble_information |         |
      | conn_0 | False   | thread @@kill name='Timer'                                               | Thread[Timer] does not exist                                  | dble_information |         |
      | conn_0 | False   | thread @@kill name='0-abc'                                               | Thread[0-abc] does not exist                                  | dble_information |         |
      | conn_0 | False   | thread @@kill name='10-complexQueryWorker'                               | Thread[10-complexQueryWorker] does not exist                  | dble_information |         |
      | conn_0 | False   | thread @@kill thread_name='0-abc'                                        | Syntax Error, Please check the help to use the thread command | dble_information |         |
      | conn_0 | False   | thread @@kill name='0-backendWorker,0-frontWorker'                       | Syntax Error, Please check the help to use the thread command | dble_information |         |
      | conn_0 | False   | thread @@recover name='TimerScheduler'                                   | The recover operation of thread[TimerScheduler] is not supported | dble_information |  |
      | conn_0 | False   | thread @@recover name='Timer'                                            | The recover operation of thread[Timer] is not supported       | dble_information |         |
      | conn_0 | False   | thread @@recover name='0-abc'                                            | The recover operation of threadPool[0-abc] is not supported   | dble_information |         |
      | conn_0 | False   | thread @@recover name='10-complexQueryWorker'                            | The recover operation of threadPool[10-complexQueryWorker] is not supported | dble_information |  |
      | conn_0 | False   | thread @@recover thread_name='0-abc'                                     | Syntax Error, Please check the help to use the thread command | dble_information |         |
      | conn_0 | False   | thread @@recover name='0-backendWorker,0-frontworker'                    | Syntax Error, Please check the help to use the thread command | dble_information |         |
      # if active_count == pool_size, recover fail
      | conn_0 | False   | thread @@recover name='0-managerFrontWorker'                             | threadPool[{managerFrontWorker}] does not need to be recover  | dble_information |         |
      | conn_0 | False   | thread @@recover name='0-NIOBackendRW'                                   | threadPool[{NIOBackendRW}] does not need to be recover        | dble_information |         |
      | conn_0 | False   | thread @@recover name='0-writeToBackendWorker'                           | threadPool[{writeToBackendWorker}] does not need to be recover| dble_information |         |
      | conn_0 | False   | thread @@recover name='0-backendWorker'                                  | success                                                       | dble_information |         |

      | conn_0 | False   | thread @@kill name='3-NIOBackendRW'                                                             | success                                | dble_information |         |
      # thread @@kill active_count-1
      | conn_0 | False   | select name,core_pool_size,active_count from dble_thread_pool where name='NIOBackendRW'         | has{(('NIOBackendRW', 4, 3),)}         | dble_information | 5       |
      | conn_0 | False   | thread @@recover name='3-NIOBackendRW'                                                          | success                                | dble_information |         |
      # thread @@recover active_count+1
      | conn_0 | False   | select name,core_pool_size,active_count from dble_thread_pool where name='NIOBackendRW'         | has{(('NIOBackendRW', 4, 4),)}         | dble_information | 5       |

      | conn_0 | False   | thread @@kill name='5-backendWorker'                                                            | success                                | dble_information |         |
      | conn_0 | False   | thread @@kill name='4-backendWorker'                                                            | success                                | dble_information |         |
      | conn_0 | False   | thread @@kill name='3-backendWorker'                                                            | success                                | dble_information |         |
      | conn_0 | False   | select name,core_pool_size,active_count from dble_thread_pool where name='backendWorker'        | has{(('backendWorker', 6, 0),)}        | dble_information | 5       |
      | conn_0 | False   | thread @@recover name='5-backendWorker'                                                         | success                                | dble_information |         |
      | conn_0 | False   | thread @@recover name='4-backendWorker'                                                         | success                                | dble_information |         |
      | conn_0 | False   | thread @@recover name='3-backendWorker'                                                         | success                                | dble_information |         |
      | conn_0 | False   | select name,core_pool_size,active_count from dble_thread_pool where name='backendWorker'        | has{(('backendWorker', 6, 0),)}        | dble_information | 5       |

      | conn_0 | False   | thread @@kill name='0-frontWorker'                                                              | success                                | dble_information |         |
      | conn_0 | False   | select name,core_pool_size,active_count from dble_thread_pool where name='frontWorker'          | has{(('frontWorker', 1, 0),)}          | dble_information | 5       |
      | conn_0 | False   | thread @@recover name='0-frontWorker'                                                           | success                                | dble_information |         |
      | conn_0 | False   | select name,core_pool_size,active_count from dble_thread_pool where name='frontWorker'          | has{(('frontWorker', 1, 1),)}          | dble_information | 5       |

      | conn_0 | False   | thread @@kill name='4-writeToBackendWorker'                                                     | success                                | dble_information |         |
      | conn_0 | False   | thread @@kill name='3-writeToBackendWorker'                                                     | success                                | dble_information |         |
      | conn_0 | False   | thread @@kill name='2-writeToBackendWorker'                                                     | success                                | dble_information |         |
      | conn_0 | False   | select name,core_pool_size,active_count from dble_thread_pool where name='writeToBackendWorker' | has{(('writeToBackendWorker', 5, 2),)} | dble_information | 5       |
      | conn_0 | False   | thread @@recover name='4-writeToBackendWorker'                                                  | success                                | dble_information |         |
      | conn_0 | False   | thread @@recover name='3-writeToBackendWorker'                                                  | success                                | dble_information |         |
      | conn_0 | False   | thread @@recover name='2-writeToBackendWorker'                                                  | success                                | dble_information |         |
      | conn_0 | False   | select name,core_pool_size,active_count from dble_thread_pool where name='writeToBackendWorker' | has{(('writeToBackendWorker', 5, 5),)} | dble_information | 5       |

      | conn_0 | False   | thread @@kill name='2-complexQueryWorker'                                                       | success                                | dble_information |         |
      | conn_0 | False   | select name,core_pool_size,active_count from dble_thread_pool where name='complexQueryWorker'   | has{(('complexQueryWorker', 3, 1),)}   | dble_information | 5       |

      # only support thread @@kill, do not support thread @@recover
      # 以TimerScheduler这种为例：一般只有发现此线程hang了，才可能执行此kill命令，这种情况下，kill是解决这个线程hang的问题，kill掉后此线程意味着恢复工作，就无需recover操作了
      | conn_0 | False   | thread @@recover name='2-complexQueryWorker'                | The recover operation of threadPool[2-complexQueryWorker] is not supported | dble_information |         |
      | conn_0 | False   | thread @@kill name='0-Timer'                                | success                                                                    | dble_information |         |
      | conn_0 | False   | thread @@recover name='0-Timer'                             | The recover operation of threadPool[0-Timer] is not supported              | dble_information |         |
      | conn_0 | False   | thread @@kill name='1-TimerScheduler'                       | success                                                                    | dble_information |         |
      | conn_0 | False   | thread @@recover name='1-TimerScheduler'                    | The recover operation of threadPool[1-TimerScheduler] is not supported     | dble_information |         |
      | conn_0 | False   | thread @@kill name='0-ThreadChecker'                        | success                                                                    | dble_information |         |
      | conn_0 | False   | thread @@recover name='0-ThreadChecker'                     | The recover operation of threadPool[0-ThreadChecker] is not supported      | dble_information |         |
      | conn_0 | False   | thread @@kill name='connection-pool-evictor-thread'         | success                                                                    | dble_information |         |
      | conn_0 | False   | thread @@kill name='connection-pool-evictor-thread'         | success                                                                    | dble_information |         |
      | conn_0 | False   | thread @@kill name='connection-pool-evictor-thread'         | success                                                                    | dble_information |         |
      | conn_0 | False   | thread @@recover name='connection-pool-evictor-thread'      | The recover operation of thread[connection-pool-evictor-thread] is not supported | dble_information |         |
      | conn_0 | False   | thread @@recover name='connection-pool-evictor-thread'      | The recover operation of thread[connection-pool-evictor-thread] is not supported | dble_information |         |
      | conn_0 | False   | thread @@recover name='connection-pool-evictor-thread'      | The recover operation of thread[connection-pool-evictor-thread] is not supported | dble_information |         |
      | conn_0 | False   | thread @@kill name='0-alertSenderExecutor'                  | success                                                                    | dble_information |         |
      | conn_0 | True    | thread @@recover name='0-alertSenderExecutor'               | The recover operation of threadPool[0-alertSenderExecutor] is not supported| dble_information |         |

    # check log
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "5" times
    """
    exec interrupt Thread\[3-NIOBackendRW\]
    exec interrupt Thread\[5-backendWorker\]
    exec interrupt Thread\[4-backendWorker\]
    exec interrupt Thread\[3-backendWorker\]
    exec interrupt Thread\[0-frontWorker\]
    exec interrupt Thread\[4-writeToBackendWorker\]
    exec interrupt Thread\[3-writeToBackendWorker\]
    exec interrupt Thread\[2-writeToBackendWorker\]
    exec interrupt Thread\[2-complexQueryWorker\]
    exec interrupt Thread\[0-Timer\]
    exec interrupt Thread\[1-TimerScheduler\]
    exec interrupt Thread\[0-ThreadChecker\]
    exec interrupt Thread\[connection-pool-evictor-thread\]
    exec interrupt Thread\[0-alertSenderExecutor\]
    """

    # kill all frontWorker 8066 login fail
    Given execute admin cmd "thread @@kill name='0-frontWorker'" success
    Then  execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect                                                                             | db      |
      | conn_1 | True   | drop table if exists sharding_4_t1  | Lost connection to MySQL server at 'reading authorization packet', system error: 0 | schema1 |

    Given execute admin cmd "thread @@recover name='0-frontWorker'" success
    Then  execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_1 | False   | begin                                                   | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
      | conn_1 | False   | commit                                                  | success | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                             | success | schema1 |
      | conn_1 | True    | drop table if exists sharding_4_t1                      | success | schema1 |

  @skip # case运行时间久，不适合ci上运行
  Scenario: check TimerScheduler hang #5
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs1"
      | conn   | toClose | sql                    |
      | conn_0 | False   | show @@threadpool.task |
    Then check resultset "rs1" has lines with following column values
      | NAME-0         | POOL_SIZE-1 | ACTIVE_TASK_COUNT-2 | TASK_QUEUE_SIZE-3 |
      | TimerScheduler | 2           | 0                   | 13                |

    Given delete file "/opt/dble/TimerScheduler1.java" on "dble-1"
    Given delete file "/opt/dble/TimerScheduler2.java" on "dble-1"
    Given delete file "/opt/dble/BtraceTimerScheduler1.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceTimerScheduler2.java.log" on "dble-1"

    Given update file content "./assets/BtraceTimerScheduler1.java" in "behave" with sed cmds
    """
    /printDDLOutOfLimit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(600000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceTimerScheduler1.java" in "dble-1"
    Then check btrace "BtraceTimerScheduler1.java" output in "dble-1"
    """
    get into printDDLOutOfLimit
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                     | expect                                  | timeout |
      | conn_0 | True    | show @@threadpool.task  | hasStr{'TimerScheduler', 2, 1, 12}      | 10,30   |

    # check log: 只有一个线程hang时不触发告警
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "10,30" times
    """
    Thread\[.*-TimerScheduler\] suspected hang, execute time:\[{.*ms}\] more than 10s, currentState:\[TIMED_WAITING\]
    """
    Then check following text exist "N" in file "/opt/dble/logs/thread.log" in host "dble-1"
    """
    The thread pool where the thread\[.*-TimerScheduler\] is located is in the hang state and cannot work. Trigger alarm
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DenableSessionActiveRatioStat=1
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                     | expect                                  |
      | conn_0 | True    | show @@threadpool.task  | hasStr{'TimerScheduler', 2, 0, 13}      |
    Given update file content "./assets/BtraceTimerScheduler2.java" in "behave" with sed cmds
    """
    /compress/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(600000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceTimerScheduler2.java" in "dble-1"
    Given prepare a thread run btrace script "BtraceTimerScheduler1.java" in "dble-1"
    Then check btrace "BtraceTimerScheduler1.java" output in "dble-1"
    """
    get into printDDLOutOfLimit
    """
    Then check btrace "BtraceTimerScheduler2.java" output in "dble-1"
    """
    get into compress
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                     | expect                                  | timeout |
      | conn_0 | False   | show @@threadpool.task  | hasStr{'TimerScheduler', 2, 2, 11}      | 10,30   |

    # check log: 2个线程都hang时触发告警
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "10,30" times
    """
    Thread\[0-TimerScheduler\] suspected hang, execute time:\[{.*ms}\] more than 10s, currentState:\[TIMED_WAITING\]
    Thread\[1-TimerScheduler\] suspected hang, execute time:\[{.*ms}\] more than 10s, currentState:\[TIMED_WAITING\]
    The thread pool where the thread\[0-TimerScheduler\] is located is in the hang state and cannot work. Trigger alarm
    The thread pool where the thread\[1-TimerScheduler\] is located is in the hang state and cannot work. Trigger alarm
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                    | expect                                  |
      | conn_0 | False   | thread @@kill name='0-TimerScheduler'  | success                                 |
      | conn_0 | False   | thread @@kill name='1-TimerScheduler'  | success                                 |
      | conn_0 | True    | show @@threadpool.task                 | hasStr{'TimerScheduler', 2, 2, 11}      |
    Then check following text exist "Y" in file "/opt/dble/BtraceTimerScheduler1.java.log" in host "dble-1"
    """
     sleep interrupted
     """
    Then check following text exist "Y" in file "/opt/dble/BtraceTimerScheduler2.java.log" in host "dble-1"
    """
    sleep interrupted
    """

    #执行kill日志打印，kill之后告警解决
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "10,30" times
    """
    exec interrupt Thread\[0-TimerScheduler\]
    exec interrupt Thread\[1-TimerScheduler\]
    Resolve Thread\[0-TimerScheduler\]'s alarm
    Resolve Thread\[1-TimerScheduler\]'s alarm
    """

    #桩一直在，TimerScheduler还会继续hang
    Given record current dble log "/opt/dble/logs/thread.log" line number in "log_num"
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" after line "log_num" in host "dble-1" retry "10,15" times
    """
    Thread\[0-TimerScheduler\] suspected hang, execute time:\[{.*ms}\] more than 10s, currentState:\[TIMED_WAITING\]
    Thread\[1-TimerScheduler\] suspected hang, execute time:\[{.*ms}\] more than 10s, currentState:\[TIMED_WAITING\]
    The thread pool where the thread\[0-TimerScheduler\] is located is in the hang state and cannot work. Trigger alarm
    The thread pool where the thread\[1-TimerScheduler\] is located is in the hang state and cannot work. Trigger alarm
    """
#    Given destroy btrace threads list
    Given execute linux command in "dble-1"
    """
      ps -ef | grep BtraceTimerScheduler |grep -v grep | awk '{print $2}' | xargs -r kill -9
     """
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "10,30" times
    """
    Resolve Thread\[0-TimerScheduler\]'s alarm
    Resolve Thread\[1-TimerScheduler\]'s alarm
    """
    Then restart dble in "dble-1" success

  @skip # case运行时间久，不适合ci上运行
  Scenario: check Timer hang #6
    # timer线程的队列大小为65535，要使队列满，开启桩后大约需要4个小时
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DxaSessionCheckPeriod=10000
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                     | expect                  |
      | conn_0 | False   | show @@threadpool.task  | hasStr{'Timer', 1}      |

    Given delete file "/opt/dble/BtraceThreadTimer.java" on "dble-1"
    Given delete file "/opt/dble/BtraceThreadTimer.java.log" on "dble-1"

    Given update file content "./assets/BtraceThreadTimer.java" in "behave" with sed cmds
    """
    /checkXaSessions/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(300000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceThreadTimer.java" in "dble-1"
    Then check btrace "BtraceThreadTimer.java" output in "dble-1"
    """
    get into checkXaSessions
    """

    # check log 定时任务2分钟一次
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "10,30" times
    """
    Thread\[0-Timer\] suspected hang, execute time:\[{.*ms}\] more than 10s, currentState:\[TIMED_WAITING\]
    The thread pool where the thread\[0-Timer\] is located is in the hang state and cannot work. Trigger alarm
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                     | expect                  |
      | conn_0 | True    | show @@threadpool.task  | hasStr{'Timer', 1, 1}   |
    Given execute linux command in "dble-1"
      """
      ps -ef | grep BtraceThreadTimer |grep -v grep | awk '{print $2}' | xargs -r kill -9
      """
    Then check following text exist "Y" in file "/opt/dble/logs/thread.log" in host "dble-1" retry "10,30" times
    """
    Resolve Thread\[0-Timer\]'s alarm
    """
    Then restart dble in "dble-1" success