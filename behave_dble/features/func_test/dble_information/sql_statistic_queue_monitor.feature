# Copyright (C) 2016-2023 ActionTech.
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
      | conn   | toClose  | sql                                       | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                      | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 0;                | success  | dble_information   |
      | conn_0 | False    | show @@statistic;                         | has{(('statistic', 'OFF'), ('associateTablesByEntryByUserTableSize', '1024'), ('frontendByBackendByEntryByUserTableSize', '1024'), ('tableByUserByEntryTableSize', '1024'), ('sqlLogTableSize', '1024'), ('samplingRate', '0'), ('queueMonitor', '-'),)}  | dble_information   |
      | conn_0 | False    | start @@statistic_queue_monitor;          | Statistic is disabled and samplingRate value is 0   | dble_information |
      | conn_0 | False    | show @@statistic_queue.usage;             | length{(0)}                                         | dble_information |
      | conn_0 | False    | stop @@statistic_queue_monitor;           | success                                             | dble_information |
      | conn_0 | False    | drop @@statistic_queue.usage;             | success                                             | dble_information |
      | conn_0 | False    | show @@statistic_queue.usage;             | success                                             | dble_information |
      | conn_0 | False    | disable @@statistic;                      | success                                             | dble_information |
      | conn_0 | True     | reload @@samplingRate = 0;                | success                                             | dble_information |

  Scenario: test statistic_queue_monitor with sql statistic off（default observeTime=1min,intervalTime=5s） #2
    # case 9304 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9304
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                       | expect   | db                 |
      | conn_0 | False    | reload @@samplingRate = 20;               | success  | dble_information   |
      | conn_0 | False    | show @@statistic;                         | has{(('statistic', 'OFF'), ('associateTablesByEntryByUserTableSize', '1024'), ('frontendByBackendByEntryByUserTableSize', '1024'), ('tableByUserByEntryTableSize', '1024'), ('sqlLogTableSize', '1024'), ('samplingRate', '20'), ('queueMonitor', '-'),)}  | dble_information   |
      | conn_0 | False    | start @@statistic_queue_monitor;          | success      | dble_information   |
    # Because you need to wait until the first statistic data is counted in the result before you can assert that it passes
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect       | db                 | timeout  |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(1)}  | dble_information   | 5,1      |
    # Check the status of queueMonitor, because its status change takes time
    Given sleep "5" seconds
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | show @@statistic;                        | has{(('statistic', 'OFF'), ('associateTablesByEntryByUserTableSize', '1024'), ('frontendByBackendByEntryByUserTableSize', '1024'), ('tableByUserByEntryTableSize', '1024'), ('sqlLogTableSize', '1024'), ('samplingRate', '20'), ('queueMonitor', 'monitoring'),)}  | dble_information   |
    # we need at least [observeTime (1min)+ 1* intervalTime] ，Then the result of "show @@statistic_queue.usage;" will tell us that statistic finished
    Given sleep "65" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect                    | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length_balance{13,0.1}    | dble_information   |
      | conn_0 | True     | show @@statistic;                      | has{(('statistic', 'OFF'), ('associateTablesByEntryByUserTableSize', '1024'), ('frontendByBackendByEntryByUserTableSize', '1024'), ('tableByUserByEntryTableSize', '1024'), ('sqlLogTableSize', '1024'), ('samplingRate', '20'), ('queueMonitor', '-'),)}  | dble_information   |

    #show 和 stop 可能有时间差
  Scenario: test statistic_queue_monitor with sql statistic on（none default observeTime,intervalTime） #3
    # case 9305 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9305
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                           | expect   | db                 |
      | conn_0 | False    | enable @@statistic;                                                           | success  | dble_information   |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 1h and intervalTime = 2s;       | success  | dble_information   |
    Given sleep "10" seconds
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect                    | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length_balance{5,0.2}    | dble_information   |
      | conn_0 | False    | stop @@statistic_queue_monitor;        | success                   | dble_information   |
    # we need a intervalTime，checking "show @@statistic_queue.usage;"
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect                  | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length_balance{5,0.2}  | dble_information   |
      | conn_0 | True     | show @@statistic;                      | has{(('statistic', 'ON'), ('associateTablesByEntryByUserTableSize', '1024'), ('frontendByBackendByEntryByUserTableSize', '1024'), ('tableByUserByEntryTableSize', '1024'), ('sqlLogTableSize', '1024'), ('samplingRate', '0'), ('queueMonitor', '-'),)}  | dble_information   |

  Scenario: test statistic_queue_monitor single observeTime or intervalTime; default unit for observeTime & intervalTime is seconds  #4
    # case 9306 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9306
    # enable @@statistic; & reload @@samplingRate = 20;
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | enable @@statistic;                 | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 20;         | success  | dble_information   |
      | conn_0 | False    | start @@statistic_queue_monitor intervalTime = 10;   | The sql does not match: start @@statistic_queue_monitor observeTime = ? and intervalTime = ? | dble_information |
      | conn_0 | False    | show @@statistic;                   | has{(('statistic', 'ON'), ('associateTablesByEntryByUserTableSize', '1024'), ('frontendByBackendByEntryByUserTableSize', '1024'), ('tableByUserByEntryTableSize', '1024'), ('sqlLogTableSize', '1024'), ('samplingRate', '20'), ('queueMonitor', '-'),)}  | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;       | length{(0)}   | dble_information   |
    # test default intervalTime & given normal observeTime (default unit for observeTime & intervalTime is seconds)
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 10;    | success  | dble_information |
    # more 10s，equal [observeTime + a intervalTime(5s) cycle]，checking queueMonitor <3.22.11
    Given sleep "12" seconds
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect                                                                                       | db               |timeout|
      | conn_0 | False    | show @@statistic;                   | has{(('statistic', 'ON'), ('associateTablesByEntryByUserTableSize', '1024'), ('frontendByBackendByEntryByUserTableSize', '1024'), ('tableByUserByEntryTableSize', '1024'), ('sqlLogTableSize', '1024'), ('samplingRate', '20'), ('queueMonitor', '-'),)}  | dble_information   |10,1|
      | conn_0 | True     | show @@statistic_queue.usage;       | length{(3)}   | dble_information   |                                                                                                                                                                                                                                                |

   #show 和 stop 可能有时间差
  Scenario: test start statistic_queue_monitor with the last statistic_queue_monitor is running  #5
    # case 9307 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9307
    # enable @@statistic; & reload @@samplingRate = 20;
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | enable @@statistic;                 | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 20;         | success  | dble_information   |
    # start @@statistic_queue_monitor，the first time
    #start @@statistic_queue_monitor observeTime =10min and intervalTime = 2;
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect   | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =10min and intervalTime = 10   | success  | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                       | expect                                                                                  | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =4M and intervalTime = 1      | In the monitoring..., can use 'stop @@statistic_queue_monitor' to interrupt monitoring  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =4M and intervalTime = 2      | In the monitoring..., can use 'stop @@statistic_queue_monitor' to interrupt monitoring  | dble_information |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect                   | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length_balance{2,0.5}    | dble_information   |
      | conn_0 | True     | show @@statistic;                      | has{(('statistic', 'ON'), ('associateTablesByEntryByUserTableSize', '1024'), ('frontendByBackendByEntryByUserTableSize', '1024'), ('tableByUserByEntryTableSize', '1024'), ('sqlLogTableSize', '1024'), ('samplingRate', '20'), ('queueMonitor', 'monitoring'),)}  | dble_information   |


  Scenario: test statistic_queue_monitor with illegal observeTime or intervalTime #6 & #7
    # case 9308 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9308
    # case 9309 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9309

    # enable @@statistic; & reload @@samplingRate = 20;
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | enable @@statistic;                 | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 20;         | success  | dble_information   |
    # Error occurred when intervalTime defalut value,but observeTime illegal/(observeTime legal value & observeTime < intervalTime)
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = -1h;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 0min;  | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 2s;    | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
    # Error occurred when intervalTime given value,but observeTime illegal/(observeTime legal value & observeTime < intervalTime)
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = -1h and intervalTime = 3;        | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 0min and intervalTime = 3;       | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 10MIN and intervalTime = 30M;    | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 10s and intervalTime = 1min;     | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
    # check queueMonitor status is "-"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                             | expect        | db                 |
      | conn_0 | False    | show @@statistic;               | has{(('statistic', 'ON'), ('associateTablesByEntryByUserTableSize', '1024'), ('frontendByBackendByEntryByUserTableSize', '1024'), ('tableByUserByEntryTableSize', '1024'), ('sqlLogTableSize', '1024'), ('samplingRate', '20'), ('queueMonitor', '-'),)}  | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;   | length{(0)}   | dble_information   |

    # Error occurred when intervalTime using illegal value
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect                                                                           | db               |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =10H and intervalTime = -3s;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =3MIN and intervalTime = 0s;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
    # Error occurred when both intervalTime and observeTime using illegal value
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =0H and intervalTime = -12s;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =3MIN and intervalTime = 0s;   | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =-1min and intervalTime = -1H; | Rule: must be a positive integer, observeTime > intervalTime, Unit: (s,m/min,h)  | dble_information |
      | conn_0 | False    | show @@statistic;               | has{(('statistic', 'ON'), ('associateTablesByEntryByUserTableSize', '1024'), ('frontendByBackendByEntryByUserTableSize', '1024'), ('tableByUserByEntryTableSize', '1024'), ('sqlLogTableSize', '1024'), ('samplingRate', '20'), ('queueMonitor', '-'),)}  | dble_information   |
      | conn_0 | True     | show @@statistic_queue.usage;   | length{(0)}   | dble_information   |

  Scenario: test start statistic_queue_monitor exit when the merely samplingRate_statistic is disabled  #8
    # case 9311 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9311
    # reload @@samplingRate = 20; & start @@statistic_queue_monitor
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | reload @@samplingRate = 20;         | success  | dble_information   |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime = 30 and intervalTime = 4;     | success  | dble_information |
    Given sleep "4" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |timeout|
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(2)}   | dble_information   |4,1    |
    # Turn off the sampling statistics and check the status of the queue monitoring.
      # Since the full statistics has been turned off, the status of the queue monitoring should be stopped
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                      | expect   | db                 |
      | conn_0 | False    | disable @@statistic;                     | success       | dble_information |
      | conn_0 | False    | reload @@samplingRate = 0;               | success  | dble_information   |
    # sleep an intervalTime cycle,Check the monitoring output, there is no new addition, check the status, the queue monitoring stops
    Given sleep "4" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(2)}   | dble_information   |
      | conn_0 | True     | show @@statistic;                      | has{(('statistic', 'OFF'), ('associateTablesByEntryByUserTableSize', '1024'), ('frontendByBackendByEntryByUserTableSize', '1024'), ('tableByUserByEntryTableSize', '1024'), ('sqlLogTableSize', '1024'), ('samplingRate', '0'), ('queueMonitor', '-'),)}  | dble_information   |

  Scenario: test start statistic_queue_monitor stoped with dble restart  #9
    # case 9312 http://10.186.18.20:888/testlink/linkto.php?tprojectPrefix=dble&item=testcase&id=dble-9312
    # enable @@statistic; & reload @@samplingRate = 20; & start @@statistic_queue_monitor;
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                 | expect   | db                 |
      | conn_0 | False    | enable @@statistic;                 | success  | dble_information   |
      | conn_0 | False    | reload @@samplingRate = 20;         | success  | dble_information   |
      | conn_0 | False    | start @@statistic_queue_monitor observeTime =10MIN and intervalTime = 4;   | success  | dble_information |

    # Check the status of queueMonitor, because its status change takes time, sleep稍微大于intervalTime防止时间差问题
    Given sleep "4" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |timeout|
      | conn_0 | True     | show @@statistic_queue.usage;          | length{(2)}   | dble_information   |4,1    |
    # after restart dble, checking statistic & samplingRate still working while check queueMonitor status is "-"
    Given Restart dble in "dble-1" success
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                        | expect   | db               |
      | conn_0 | False    | show @@statistic;                      | has{(('statistic', 'ON'), ('associateTablesByEntryByUserTableSize', '1024'), ('frontendByBackendByEntryByUserTableSize', '1024'), ('tableByUserByEntryTableSize', '1024'), ('sqlLogTableSize', '1024'), ('samplingRate', '20'), ('queueMonitor', '-'),)}  | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |

    # clean env
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                    | expect        | db                 |
      | conn_0 | False    | drop @@statistic_queue.usage;          | success       | dble_information   |
      | conn_0 | False    | show @@statistic_queue.usage;          | length{(0)}   | dble_information   |
      | conn_0 | False    | disable @@statistic;                   | success       | dble_information   |
      | conn_0 | True     | reload @@samplingRate = 0;             | success       | dble_information   |


