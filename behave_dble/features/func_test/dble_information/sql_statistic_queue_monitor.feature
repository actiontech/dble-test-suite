# Copyright (C) 2016-2022 ActionTech.
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
    # reload @@samplingRate = 20;
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
    # start @@statistic_queue_monitor;
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect       | db                 |
      | conn_0 | False    | start @@statistic_queue_monitor;       | success      | dble_information   |
    # Because you need to wait until the first statistic data is counted in the result before you can assert that it passes
    Given sleep "1" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect       | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(1)}  | dble_information   |
    # Check the status of queueMonitor, because its status change takes time
    Given sleep "4" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_3"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_3" has lines with following column values
      | NAME-0                   | VALUE-1        |
      | statistic                | OFF            |
      | samplingRate             | 20             |
      | queueMonitor             | monitoring     |
    # we need at least [observeTime (1min)+ 1* intervalTime] ，Then the result of "show @@statistic_queue.usage;" will tell us that statistic finished
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
    # enable @@statistic;
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
    # start queue statistics with both observeTime and intervalTime are non-default legal values
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                           | expect       | db                 |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 1h and intervalTime = 2s;       | success      | dble_information   |
    # Because you need to wait until the first statistical data is counted in the result before you can assert that it passes
    Given sleep "1" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect       | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(1)}  | dble_information   |
    # Check the status of queueMonitor, because its status change takes time
    Given sleep "4" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_6"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_6" has lines with following column values
      | NAME-0                   | VALUE-1        |
      | statistic                | ON             |
      | samplingRate             | 0              |
      | queueMonitor             | monitoring     |
    # one more seconds is needed, in addition to the previous sleep duration, the actual total is 6s,then "stop @@statistic_queue_monitor;"
    Given sleep "1" seconds
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect       | db                 |
      | conn_0 | False    | stop @@statistic_queue_monitor;        | success      | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(4)}   | dble_information   |
    # we need a intervalTime，checking "show @@statistic_queue.usage;"
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
    # enable @@statistic; & reload @@samplingRate = 20;
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
    #  test default observeTime & given normal intervalTime (default unit for observeTime & intervalTime is seconds)
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
    # test default intervalTime & given normal observeTime (default unit for observeTime & intervalTime is seconds)
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                  | expect   | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 10;    | success  | dble_information |
    # sleep 5s，a default intervalTime cycle
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_10"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_10" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | monitoring    |
    # more 10s，equal [observeTime + a intervalTime cycle]，checking queueMonitor
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
    # clean env
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
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
    # enable @@statistic; & reload @@samplingRate = 20;
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

    # start @@statistic_queue_monitor，the first time
    #start @@statistic_queue_monitor observeTime =10min and intervalTime = 2;
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect   | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =10min and intervalTime = 2;   | success  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_13"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    # Check the status of queueMonitor, because its status change takes time
    Given sleep "3" seconds
    Then check resultset "res_13" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | monitoring    |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(2)}   | dble_information   |
    # start @@statistic_queue_monitor，the second time,error occurred with the first statistic_queue_monitor is running
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                       | expect                                                                                  | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =4M and intervalTime = 3;     | In the monitoring..., can use 'stop @@statistic_queue_monitor' to interrupt monitoring  | dble_information |
    # sleep 3s，checking statistic_queue_monitor，the second statistic_queue_monitor didn't work
    Given sleep "3" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(4)}   | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_14"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_14" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | monitoring    |

    #disable statistics and check the status of queue monitoring. Since sampling statistics are still open, the status of queue monitoring is still continuing
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
    # Check the monitoring status, there will still be 4 records.
    # Next time after a intervalTime cycle, a new record will be added, indicating that the queue monitoring does not stop.
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(4)}   | dble_information   |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(5)}   | dble_information   |

    # Also close the sampling statistics and check the status of the queue monitoring.
    # Since the full volume and sampling statistics are closed, the queue monitoring should also be closed.
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
    # Check the monitoring status, there will still be 4 records.
    # After an intervalTime cycle , no new record is added again, indicating that the queue monitoring is indeed closed.
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(5)}   | dble_information   |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(5)}   | dble_information   |

    # clean env
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
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
    # enable @@statistic; & reload @@samplingRate = 20;
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

    # Error occurred when intervalTime defalut value,but observeTime illegal/(observeTime legal value & observeTime < intervalTime)
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                  | expect                                                                           | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = -1h;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 0min;  | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 2s;    | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
    # Error occurred when intervalTime given value,but observeTime illegal/(observeTime legal value & observeTime < intervalTime)
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                            | expect                                                                           | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = -1h and intervalTime = 3;        | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 0min and intervalTime = 3;       | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 10MIN and intervalTime = 30M;    | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 10s and intervalTime = 1min;     | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_17"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    # check queueMonitor status is "-"
    Then check resultset "res_17" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | -             |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |

    # Error occurred when intervalTime using illegal value
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect                                                                           | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =10H and intervalTime = -3s;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =3MIN and intervalTime = 0s;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
    # Error occurred when both intervalTime and observeTime using illegal value
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect                                                                           | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =0H and intervalTime = -12s;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =3MIN and intervalTime = 0s;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =-1min and intervalTime = -1H; | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_18"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    # check queueMonitor status is "-"
    Then check resultset "res_18" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 20            |
      | queueMonitor             | -             |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |

    # clean env
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
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
    # enable @@statistic;
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

    # start @@statistic_queue_monitor
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
    # reload @@samplingRate = 0;Since the sampling statistics are closed before, this operation should not affect the running statistics and queue usage monitoring
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect   | db               |
      | conn_0 | False    | reload @@samplingRate = 0;             | success  | dble_information |
    # sleep 1s，check the monitoring status.
      # Since the sampling statistics are still runningn, the queue monitoring status is still continuing
    Given sleep "1" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(2)}   | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_21"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_21" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | ON            |
      | samplingRate             | 0             |
      | queueMonitor             | monitoring    |

    # Turn off the full statistics and check the status of the queue monitoring.
      # Since the sampling statistics has been turned off, the status of the queue monitoring should be stopped
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                     | success  | dble_information   |
    # sleep 1s，an intervalTime cycle,Check the monitoring output, there is no new addition, the queue monitoring stops
    Given sleep "1" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(2)}   | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_22"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_22" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |

    # clean env
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
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
    # reload @@samplingRate = 20;
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

    # start @@statistic_queue_monitor
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect   | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 30 and intervalTime = 2;     | success  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_24"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    # Check the status of queueMonitor, because its status change takes time
    Given sleep "2" seconds
    Then check resultset "res_24" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 20            |
      | queueMonitor             | monitoring    |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(2)}   | dble_information   |
    # disable @@statistic;Since the full statistics was closed before, this operation should not affect the running sampling statistics and queue usage monitoring
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect   | db               |
      | conn_0 | False    | disable @@statistic;                   | success  | dble_information |
    # sleep 2s an intervalTime cycle,Check the monitoring status.
      # Since the sampling statistics are still running, the queue monitoring status is still continuing
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(3)}   | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_25"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_25" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 20            |
      | queueMonitor             | monitoring    |

    # Turn off the sampling statistics and check the status of the queue monitoring.
      # Since the full statistics has been turned off, the status of the queue monitoring should be stopped
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | reload @@samplingRate = 0;               | success  | dble_information   |
    # sleep 2s，an intervalTime cycle,Check the monitoring output, there is no new addition, check the status, the queue monitoring stops
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(3)}   | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_26"
      | conn   | toClose  | sql                             | db               |
      | conn_0 | False    | show @@statistic;               | dble_information |
    Then check resultset "res_26" has lines with following column values
      | NAME-0                   | VALUE-1       |
      | statistic                | OFF           |
      | samplingRate             | 0             |
      | queueMonitor             | -             |

    # clean env
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
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
    # enable @@statistic; & reload @@samplingRate = 20;
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

    # start @@statistic_queue_monitor
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect   | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =10MIN and intervalTime = 2;   | success  | dble_information |
    # Check the status of queueMonitor, because its status change takes time
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
    # after restart dble, checking statistic & samplingRate still working while check queueMonitor status is "-"
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
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |

    # clean env
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |
      | conn_0 | False    | disable @@statistic;                   | success       | dble_information   |
      | conn_0 | True     | reload @@samplingRate = 0;             | success       | dble_information   |


