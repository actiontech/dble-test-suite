# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by mayingle at 2021/09/01

Feature: start @@statistic_queue_monitor [observeTime = ? [and intervalTime = ?]]
         stop @@statistic_queue_monitor;
         drop @@statistic_queue.usage;
         show @@statistic_queue.usage;
         link: http://10.186.18.11/jira/browse/DBLE0REQ-978


  Scenario: test statistic_queue_monitor with sql statistic off #1
    # case 9303 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9303
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                             | expect   | db                 |
      | conn_0 | False    | disable @@statistic;            | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 0;      | success  | dble_information   |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "befenv"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "befenv" has lines with following column values
      | NAME-0                   | VALUE-1      |
      | statistic                | OFF          |
      | samplingRate             | 0            |
      | queueMonitor             | -            |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                       | expect                                              | db               |
      | conn_0 | False    | start @@statistic_queue_monitor;          | Statistic is disabled and samplingRate value is 0   | dble_information |
      | conn_0 | False    | show @@statistic_queue.usage;             | success                                             | dble_information |
      | conn_0 | False    | show @@statistic_queue.usage;             | length{(0)}                                         | dble_information |
      | conn_0 | False    | stop @@statistic_queue_monitor;           | success                                             | dble_information |
      | conn_0 | False    | drop @@statistic_queue.usage;             | success                                             | dble_information |
      | conn_0 | False    | show @@statistic_queue.usage;             | success                                             | dble_information |
      | conn_0 | False    | disable @@statistic;                      | success                                             | dble_information |
      | conn_0 | True     | reload @@samplingRate = 0;                | success                                             | dble_information |


  Scenario: test statistic_queue_monitor with sql statistic on（default observeTime=1min,intervalTime=5s） #2
    # case 9304 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9304
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                     | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 0;               | success  | dble_information   |
      | conn_0 | False    | drop @@statistic_queue.usage;            | success  | dble_information   |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "befenv"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "befenv" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |
    # 开启采样统计
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | reload @@samplingRate = 20;         | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_2"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_2" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 20            |
      | queueMonitor             | -             |
    # 开启队列统计
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect       | db                 |
      | conn_0 | False    | start @@statistic_queue_monitor;       | success      | dble_information   |
    # 因为需要等到第一条统计数据统计进结果中去才可以断言通过
    Given sleep "1" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect       | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(1)}  | dble_information   |
    # 查看queueMonitor状态，因为它的状态变更需要时间
    Given sleep "4" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_3"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_3" has lines with following column values
      | NAME-0                   | VALUE-1        |
      | statistic                | OFF            |
      | samplingRate             | 20             |
      | queueMonitor             | monitoring     |
    # 需要超过默认的observeTime 1min时间长度至少再加一个intervalTime的长度，再去查看show @@statistic_queue.usage;是否停更才有意义
    Given sleep "65" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(13)}  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_4"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_4" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 20            |
      | queueMonitor             | -             |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |
      | conn_0 | False    | disable @@statistic;                   | success       | dble_information   |
      | conn_0 | True     | reload @@samplingRate = 0;             | success       | dble_information   |


  Scenario: test statistic_queue_monitor with sql statistic on（none default observeTime,intervalTime） #3
    # case 9305 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9305
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                     | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 0;               | success  | dble_information   |
      | conn_0 | False    | drop @@statistic_queue.usage;            | success  | dble_information   |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "befenv"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "befenv" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |
    # 开启sql全量统计
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | enable @@statistic;                 | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_5"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_5" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 0             |
      | queueMonitor             | -             |
    # 开启队列统计 observeTime，intervalTime均为非默认合法值
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                           | expect       | db                 |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 1h and intervalTime = 2s;       | success      | dble_information   |
    # 因为需要等到第一条统计数据统计进结果中去才可以断言通过
    Given sleep "1" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect       | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(1)}  | dble_information   |
    # 查看queueMonitor状态，因为它的状态变更需要时间
    Given sleep "4" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_6"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_6" has lines with following column values
      | NAME-0                   | VALUE-1        |
      | statistic                | ON             |
      | samplingRate             | 0              |
      | queueMonitor             | monitoring     |
    # 再sleep 1s 凑足6s 开始中断队列监控
    Given sleep "1" seconds
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect       | db                 |
      | conn_0 | False    | stop @@statistic_queue_monitor;        | success      | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(4)}   | dble_information   |
    # 再sleep 2s，一个intervalTime周期，再次查看sql统计条数没有增加
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(4)}   | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_7"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_7" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 0             |
      | queueMonitor             | -             |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |
      | conn_0 | False    | disable @@statistic;                   | success       | dble_information   |
      | conn_0 | True     | reload @@samplingRate = 0;             | success       | dble_information   |


  Scenario: test statistic_queue_monitor single observeTime or intervalTime; default unit for observeTime & intervalTime is seconds  #4
    # case 9306 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9306
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                     | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 0;               | success  | dble_information   |
      | conn_0 | False    | drop @@statistic_queue.usage;            | success  | dble_information   |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "befenv"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "befenv" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |
    # 开启sql全量统计和采样统计
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | enable @@statistic;                 | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 20;         | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_8"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_8" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | -             |
    # 开启队列统计 observeTime为默认合法值，而intervalTime为指定值，并省略单位，默认单位为s
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                  | expect                                                                                       | db               |
      | conn_0 | False    | start @@statistic_queue_monitor intervalTime = 10;   | The sql does not match: start @@statistic_queue_monitor observeTime = ? and intervalTime = ? | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_9"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_9" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | -             |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |
    # 开启队列统计 intervalTime为默认合法值，而observeTime为指定值，并省略单位，默认单位为s
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                  | expect   | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 10;    | success  | dble_information |
    # sleep 5s，查看监控状态
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_10"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_10" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | monitoring    |
    # 再 sleep 10s，加上之前的5s，是observeTime加上一个intervalTime周期，查看监控状态
    Given sleep "10" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_11"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_11" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | -             |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(3)}   | dble_information   |
    # 清理历史statistic_queue.usage信息
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |
      | conn_0 | False    | disable @@statistic;                   | success       | dble_information   |
      | conn_0 | True     | reload @@samplingRate = 0;             | success       | dble_information   |


  Scenario: test start statistic_queue_monitor with the last statistic_queue_monitor is running  #5
    # case 9307 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9307
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                     | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 0;               | success  | dble_information   |
      | conn_0 | False    | drop @@statistic_queue.usage;            | success  | dble_information   |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "befenv"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "befenv" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |
    # 开启sql全量统计和采样统计
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | enable @@statistic;                 | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 20;         | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_12"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_12" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | -             |

    # 开启队列监控，首次
    #start @@statistic_queue_monitor observeTime =10min and intervalTime = 2;
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect   | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =10min and intervalTime = 2;   | success  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_13"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    # 查看queueMonitor状态，因为它的状态变更需要时间
    Given sleep "3" seconds
    Then check resultset "res_13" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | monitoring    |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(2)}   | dble_information   |
    # 开启队列监控时，再次 开启队列监控会报错
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                       | expect                                                                                  | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =4M and intervalTime = 3;     | In the monitoring..., can use 'stop @@statistic_queue_monitor' to interrupt monitoring  | dble_information |
    # sleep 3s，查看监控状态，如果是旧的规则，则会有4条记录，若新的规则生效则会有2条数据
    Given sleep "3" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(4)}   | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_14"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_14" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | monitoring    |

    # 关全量统计，查看队列监控的状态，由于采样统计仍为开启的状态，所以队列监控的状态仍然在继续
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                     | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_14"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_14" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 20            |
      | queueMonitor             | monitoring    |
    # 查看监控状态，仍然会有4条记录，下次过了一个intervalTime后，会增加一条记录，说明队列监控确实没有停
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(4)}   | dble_information   |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(5)}   | dble_information   |

    # 也关闭采样统计，查看队列监控的状态，由于全量和采样统计都关闭了，所以队列监控也应该是关闭的状态
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | reload @@samplingRate = 0;               | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_15"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_15" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |
    # 查看监控状态，仍然会有4条记录，下次过了一个intervalTime后，并没有增加一条记录，说明队列监控确实被关闭
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(5)}   | dble_information   |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(5)}   | dble_information   |

    # 清理历史statistic_queue.usage信息
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |
      | conn_0 | False    | disable @@statistic;                   | success       | dble_information   |
      | conn_0 | True     | reload @@samplingRate = 0;             | success       | dble_information   |


  Scenario: test statistic_queue_monitor with illegal observeTime or intervalTime #6 & #7
    # case 9308 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9308
    # case 9309 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9309
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                     | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 0;               | success  | dble_information   |
      | conn_0 | False    | drop @@statistic_queue.usage;            | success  | dble_information   |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "befenv"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "befenv" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |
    # 开启sql全量统计和采样统计
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | enable @@statistic;                 | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 20;         | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_16"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_16" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | -             |

    #  intervalTime为默认合法值，而observeTime为指定非法值/observeTime为合法值，但observeTime<intervalTime ，开启队列监控，失败
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                  | expect                                                                           | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = -1h;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 0min;  | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 2s;    | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
    #  intervalTime为指定合法值，而observeTime为指定非法值/observeTime为合法值，但observeTime<intervalTime ，开启队列监控，失败
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                            | expect                                                                           | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = -1h and intervalTime = 3;        | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 0min and intervalTime = 3;       | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 10MIN and intervalTime = 30M;    | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 10s and intervalTime = 1min;     | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_17"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    # 查看queueMonitor状态,未开启 值为空
    Then check resultset "res_17" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | -             |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |

    # observeTime为合法值，但intervalTime为异常值 ，开启队列监控，失败
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect                                                                           | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =10H and intervalTime = -3s;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =3MIN and intervalTime = 0s;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
    # observeTime,intervalTime均为异常值 ，开启队列监控，失败
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect                                                                           | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =0H and intervalTime = -12s;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =3MIN and intervalTime = 0s;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =-1min and intervalTime = -1H; | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_18"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    # 查看queueMonitor状态,未开启 值为空
    Then check resultset "res_18" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | -             |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |

    # 清理历史statistic_queue.usage信息
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |
      | conn_0 | False    | disable @@statistic;                   | success       | dble_information   |
      | conn_0 | True     | reload @@samplingRate = 0;             | success       | dble_information   |


  Scenario: test start statistic_queue_monitor exit when the merely statistic is disabled  #8
    # case 9310 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9310
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                     | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 0;               | success  | dble_information   |
      | conn_0 | False    | drop @@statistic_queue.usage;            | success  | dble_information   |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "befenv"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "befenv" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |
    # 开启sql全量统计
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | enable @@statistic;                 | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_19"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_19" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 0             |
      | queueMonitor             | -             |

    # 开启队列监控
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect   | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 2H and intervalTime = 1S;    | success  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_20"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_20" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 0             |
      | queueMonitor             | monitoring    |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(1)}   | dble_information   |
    # 执行reload @@samplingRate = 0;关闭采样统计(由于采样统计本来就是关闭状态，则这个操作不应该影响正在运行的sql全量统计和队列使用率监控)
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect   | db               |
      | conn_0 | False    | reload @@samplingRate = 0;             | success  | dble_information |
    # sleep 1s，查看监控状态，由于采样统计仍为开启的状态，所以队列监控的状态仍然在继续
    Given sleep "1" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(2)}   | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_21"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_21" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 0             |
      | queueMonitor             | monitoring    |

    # 关全量统计，查看队列监控的状态，由于采样统计已为关闭的状态，所以队列监控的状态应该被停掉
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                     | success  | dble_information   |
    # sleep 1s，即一个 intervalTime周期，查看监控输出，没有新增，查看状态，队列监控停止
    Given sleep "1" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(2)}   | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_22"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_22" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |

    # 清理历史statistic_queue.usage信息
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |
      | conn_0 | False    | disable @@statistic;                   | success       | dble_information   |
      | conn_0 | True     | reload @@samplingRate = 0;             | success       | dble_information   |


  Scenario: test start statistic_queue_monitor exit when the merely samplingRate_statistic is disabled  #9
    # case 9311 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9311
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                     | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 0;               | success  | dble_information   |
      | conn_0 | False    | drop @@statistic_queue.usage;            | success  | dble_information   |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "befenv"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "befenv" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |
    # 开启sql全量统计
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | reload @@samplingRate = 20;         | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_23"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_23" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 20            |
      | queueMonitor             | -             |

    # 开启队列监控
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect   | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 30 and intervalTime = 2;     | success  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_24"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    # 查看queueMonitor状态，因为它的状态变更需要时间
    Given sleep "2" seconds
    Then check resultset "res_24" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 20            |
      | queueMonitor             | monitoring    |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(2)}   | dble_information   |
    # 执行disable @@statistic;关闭sql全量统计(由于全量统计本来就是关闭状态，则这个操作不应该影响正在运行的sql采样统计和队列使用率监控)
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect   | db               |
      | conn_0 | False    | disable @@statistic;                   | success  | dble_information |
    # sleep 2s 一个intervalTime周期，查看监控状态，由于采样统计仍为开启的状态，所以队列监控的状态仍然在继续
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(3)}   | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_25"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_25" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 20            |
      | queueMonitor             | monitoring    |

    # 关采样统计，查看队列监控的状态，由于全量统计已为关闭的状态，所以队列监控的状态应该被停掉
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | reload @@samplingRate = 0;               | success  | dble_information   |
    # sleep 2s，即一个 intervalTime周期，查看监控输出，没有新增，查看状态，队列监控停止
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(3)}   | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_26"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_26" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |

    # 清理历史statistic_queue.usage信息
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |
      | conn_0 | False    | disable @@statistic;                   | success       | dble_information   |
      | conn_0 | True     | reload @@samplingRate = 0;             | success       | dble_information   |


  Scenario: test start statistic_queue_monitor stoped with dble restart  #10
    # case 9312 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9312
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                     | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 0;               | success  | dble_information   |
      | conn_0 | False    | drop @@statistic_queue.usage;            | success  | dble_information   |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "befenv"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "befenv" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |
    # 开启sql全量统计和采样统计
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | enable @@statistic;                 | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 20;         | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_27"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_27" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | -             |

    # 开启队列监控
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect   | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =10MIN and intervalTime = 2;   | success  | dble_information |
    # 查看queueMonitor状态，因为它的状态变更需要时间
    Given sleep "2" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_28"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_28" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | monitoring    |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | True     | show @@statistic_queue.usage;          | length{(2)}   | dble_information   |
    # 重启dble后，检测队列监控的情况，sql统计仍然开启，但队列使用率的状态为停止状态
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_29"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_29" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | -             |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |

    # 清理历史statistic_queue.usage信息
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |
      | conn_0 | False    | disable @@statistic;                   | success       | dble_information   |
      | conn_0 | True     | reload @@samplingRate = 0;             | success       | dble_information   |


