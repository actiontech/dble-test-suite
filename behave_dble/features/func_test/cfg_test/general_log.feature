# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/3/18

Feature: general log test

  Scenario: check invalid general log parameters in bootstrap.cnf #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableGeneralLog/d
    /-DgeneralLogFileSize/d
    /-DgeneralLogQueueSize/d
    $a\-DenableGeneralLog=abc
    $a\-DgeneralLogFileSize=abc
    $a\-DgeneralLogQueueSize=abc
    """
    Then restart dble in "dble-1" failed for
    """
    property [[] enableGeneralLog []] 'abc' data type should be int
    property [[] generalLogFileSize []] 'abc' data type should be int
    property [[] generalLogQueueSize []] 'abc' data type should be int
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableGeneralLog/d
    /-DgeneralLogFileSize/d
    $a\-DenableGeneralLog=-1
    $a\-DgeneralLogFileSize=-1
    """
    Then restart dble in "dble-1" failed for
    """
    Property [[] enableGeneralLog []] '-1' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
    Property [[] generalLogFileSize []] '-1' in bootstrap.cnf is illegal, you may need use the default value 16 replaced
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DgeneralLogQueueSize/d
    $a\-DgeneralLogQueueSize=-1
    """
    Then restart dble in "dble-1" failed for
    """
    Property [[] generalLogQueueSize []] '-1' in bootstrap.cnf is illegal, size must not be less than 1 and must be a power of 2, you may need use the default value 4096 replaced
    """

  Scenario: check general log parameters in bootstrap.cnf #2
    # check default value
    Then check following text exist "N" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
      """
      -DenableGeneralLog=0
      -DgeneralLogFile=general/general.log
      -DgeneralLogFileSize=16
      -DgeneralLogQueueSize=4096
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect                                                                                | db               |
      | conn_0 | false   | show @@general_log | has{(('general_log', 'OFF'), ('general_log_file', '/opt/dble/general/general.log'),)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "general_log_rs1"
      | conn   | toClose | sql                                                                                              | db               |
      | conn_0 | true    | select variable_name, variable_value from dble_variables where variable_name like '%generalLog%' | dble_information |
    Then check resultset "general_log_rs1" has lines with following column values
      | variable_name-0     | variable_value-1              |
      | enableGeneralLog    | false                         |
      | generalLogFile      | /opt/dble/general/general.log |
      | generalLogFileSize  | 16M                           |
      | generalLogQueueSize | 4096                          |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "general_log_rs2"
      | sql             |
      | show @@sysparam |
    Then check resultset "general_log_rs2" has lines with following column values
      | PARAM_NAME-0        | PARAM_VALUE-1                 |
      | enableGeneralLog    | false                         |
      | generalLogFile      | /opt/dble/general/general.log |
      | generalLogFileSize  | 16M                           |
      | generalLogQueueSize | 4096                          |

    #check valid value : relative path, no suffix
    Given delete file "/opt/dble/general/general" on "dble-1"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableGeneralLog/d
    /-DgeneralLogFile/d
    /-DgeneralLogFileSize/d
    /-DgeneralLogQueueSize/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DenableGeneralLog=1
    $a\-DgeneralLogFile=general/general
    $a\-DgeneralLogFileSize=1
    $a\-DgeneralLogQueueSize=1024
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect                                                                           | db               |
      | conn_1 | false   | show @@general_log | has{(('general_log', 'ON'), ('general_log_file', '/opt/dble/general/general'),)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "general_log_rs3"
      | conn   | toClose | sql                                                                                              | db               |
      | conn_1 | true    | select variable_name, variable_value from dble_variables where variable_name like '%generalLog%' | dble_information |
    Then check resultset "general_log_rs3" has lines with following column values
      | variable_name-0     | variable_value-1          |
      | enableGeneralLog    | true                      |
      | generalLogFile      | /opt/dble/general/general |
      | generalLogFileSize  | 1M                        |
      | generalLogQueueSize | 1024                      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "general_log_rs4"
      | sql             |
      | show @@sysparam |
    Then check resultset "general_log_rs4" has lines with following column values
      | PARAM_NAME-0        | PARAM_VALUE-1             |
      | enableGeneralLog    | true                      |
      | generalLogFile      | /opt/dble/general/general |
      | generalLogFileSize  | 1M                        |
      | generalLogQueueSize | 1024                      |
    Then check following text exist "Y" in file "/opt/dble/general/general" in host "dble-1"
    """
    \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
    Tcp port: 3320  Unix socket: FAKE_SOCK
    Time                 Id Command    Argument
    """
    Given delete file "/opt/dble/general/general" on "dble-1"

    #check valid value : relative path, suffix
    Given delete file "/opt/dble/test/general.log" on "dble-1"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableGeneralLog/d
    /-DgeneralLogFile=/d
    $a\-DenableGeneralLog=1
    $a\-DgeneralLogFile=test/general.log
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect                                                                            | db               |
      | conn_2 | False   | show @@general_log | has{(('general_log', 'ON'), ('general_log_file', '/opt/dble/test/general.log'),)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "general_log_rs5"
      | conn   | toClose | sql                                                                                              | db               |
      | conn_2 | true    | select variable_name, variable_value from dble_variables where variable_name like '%generalLog%' | dble_information |
    Then check resultset "general_log_rs5" has lines with following column values
      | variable_name-0     | variable_value-1           |
      | enableGeneralLog    | true                       |
      | generalLogFile      | /opt/dble/test/general.log |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "general_log_rs6"
      | sql             |
      | show @@sysparam |
    Then check resultset "general_log_rs6" has lines with following column values
      | PARAM_NAME-0        | PARAM_VALUE-1              |
      | enableGeneralLog    | true                       |
      | generalLogFile      | /opt/dble/test/general.log |
    Then check following text exist "Y" in file "/opt/dble/test/general.log" in host "dble-1"
      """
      \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
      Tcp port: 3320  Unix socket: FAKE_SOCK
      Time                 Id Command    Argument
      """
    Given delete file "/opt/dble/test/general.log" on "dble-1"

    #check valid value : absolute path, suffix
    Given delete file "/opt/dble/general.log" on "dble-1"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DgeneralLogFile=test\/general.log/c -DgeneralLogFile=/opt/dble/general.log
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect                                                                          | db               |
      | conn_3 | false   | show @@general_log | has{(('general_log', 'ON'), ('general_log_file', '/opt/dble/general.log'),)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "general_log_rs7"
      | conn   | toClose | sql                                                                                              | db               |
      | conn_3 | true    | select variable_name, variable_value from dble_variables where variable_name like '%generalLog%' | dble_information |
    Then check resultset "general_log_rs7" has lines with following column values
      | variable_name-0     | variable_value-1              |
      | enableGeneralLog    | true                          |
      | generalLogFile      | /opt/dble/general.log         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "general_log_rs8"
      | sql             |
      | show @@sysparam |
    Then check resultset "general_log_rs8" has lines with following column values
      | PARAM_NAME-0        | PARAM_VALUE-1                 |
      | enableGeneralLog    | true                          |
      | generalLogFile      | /opt/dble/general.log         |
    Then check following text exist "Y" in file "/opt/dble/general.log" in host "dble-1"
    """
    \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
    Tcp port: 3320  Unix socket: FAKE_SOCK
    Time                 Id Command    Argument
    """
    Given delete file "/opt/dble/general.log" on "dble-1"

    #check valid value : home path, suffix
    Given delete file "/opt/dble/test/general/general.log" on "dble-1"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DhomePath=./c -DhomePath=/opt/dble/test
    /-DgeneralLogFile=/d
    $a\-DgeneralLogFile=general/general.log
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect                                                                                    | db               |
      | conn_4 | false   | show @@general_log | has{(('general_log', 'ON'), ('general_log_file', '/opt/dble/test/general/general.log'),)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "general_log_rs9"
      | conn   | toClose | sql                                                                                              | db               |
      | conn_4 | true    | select variable_name, variable_value from dble_variables where variable_name like '%generalLog%' | dble_information |
    Then check resultset "general_log_rs9" has lines with following column values
      | variable_name-0     | variable_value-1                   |
      | enableGeneralLog    | true                               |
      | generalLogFile      | /opt/dble/test/general/general.log |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "general_log_rs10"
      | sql             |
      | show @@sysparam |
    Then check resultset "general_log_rs10" has lines with following column values
      | PARAM_NAME-0        | PARAM_VALUE-1                      |
      | enableGeneralLog    | true                               |
      | generalLogFile      | /opt/dble/test/general/general.log |
    Then check following text exist "Y" in file "/opt/dble/test/general/general.log" in host "dble-1"
    """
    \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
    Tcp port: 3320  Unix socket: FAKE_SOCK
    Time                 Id Command    Argument
    """
    Given delete file "/opt/dble/test/general/general.log" on "dble-1"

    #check valid value : default home path, no suffix
    Given delete file "/opt/dble/test/general/general" on "dble-1"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DgeneralLogFile=/d
    $a -DgeneralLogFile=general/general_log
    /-DenableGeneralLog=1/c -DenableGeneralLog=0
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect                                                                                     | db               |
      | conn_5 | false   | show @@general_log | has{(('general_log', 'OFF'), ('general_log_file', '/opt/dble/test/general/general_log'),)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "general_log_rs11"
      | conn   | toClose | sql                                                                                              | db               |
      | conn_5 | true    | select variable_name, variable_value from dble_variables where variable_name like '%generalLog%' | dble_information |
    Then check resultset "general_log_rs11" has lines with following column values
      | variable_name-0     | variable_value-1                   |
      | enableGeneralLog    | false                              |
      | generalLogFile      | /opt/dble/test/general/general_log |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "general_log_rs12"
      | sql             |
      | show @@sysparam |
    Then check resultset "general_log_rs12" has lines with following column values
      | PARAM_NAME-0        | PARAM_VALUE-1                      |
      | enableGeneralLog    | false                              |
      | generalLogFile      | /opt/dble/test/general/general_log |
    Then get result of oscmd named "general_log_rs13" in "dble-1"
    """
    find /opt/dble/test/general -name general_log | wc -l
    """
    Then check result "general_log_rs13" value is "0"

  Scenario: check manager command: enable @@general_log, disable @@general_log, reload @@general_log_file #3
    #check enable @@general_log
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                               | db               |
      | conn_0 | false   | enable @@general_log | success                                                                              | dble_information |
      | conn_0 | true    | show @@general_log   | has{(('general_log', 'ON'), ('general_log_file', '/opt/dble/general/general.log'),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/general/general.log" in host "dble-1"
    """
    \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
    Tcp port: 3320  Unix socket: FAKE_SOCK
    Time                 Id Command    Argument
    """
    Given delete file "/opt/dble/general/general.log" on "dble-1"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableGeneralLog/d
    $a\-DenableGeneralLog=0
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
    | conn   | toClose | sql                  | expect                                                                               | db               |
    | conn_0 | false   | show @@general_log   | has{(('general_log', 'ON'), ('general_log_file', '/opt/dble/general/general.log'),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/general/general.log" in host "dble-1"
    """
    \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
    Tcp port: 3320  Unix socket: FAKE_SOCK
    Time                 Id Command    Argument
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
    """
    enableGeneralLog=1
    """
    Given delete file "/opt/dble/general/general.log" on "dble-1"

    #check disable @@general_log
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                   | expect                                                                                | db               |
      | conn_0 | false   | disable @@general_log | success                                                                               | dble_information |
      | conn_0 | true    | show @@general_log    | has{(('general_log', 'OFF'), ('general_log_file', '/opt/dble/general/general.log'),)} | dble_information |
    Then check following text exist "N" in file "/opt/dble/general/general.log" in host "dble-1"
    """
    \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
    Tcp port: 3320  Unix socket: FAKE_SOCK
    Time                 Id Command    Argument
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableGeneralLog/d
    $a\-DenableGeneralLog=1
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
    | conn   | toClose | sql                  | expect                                                                                | db               |
    | conn_0 | false   | show @@general_log   | has{(('general_log', 'OFF'), ('general_log_file', '/opt/dble/general/general.log'),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
    """
    enableGeneralLog=0
    """
    Given delete file "/opt/dble/general/general.log" on "dble-1"

    #check reload @@general_log_file, absolute path
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                    | expect                                                                             | db               |
      | conn_0 | false   | reload @@general_log_file='/opt/dble/test/general.log' | success                                                                            | dble_information |
      | conn_0 | true    | show @@general_log                                     | has{(('general_log', 'OFF'), ('general_log_file', '/opt/dble/test/general.log'),)} | dble_information |
    Then check following text exist "N" in file "/opt/dble/test/general.log" in host "dble-1"
    """
    \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
    Tcp port: 3320  Unix socket: FAKE_SOCK
    Time                 Id Command    Argument
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DgeneralLogFile/d
    $a\-DgeneralLogFile=/test/general/general.log
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
    | conn   | toClose | sql                  | expect                                                                             | db               |
    | conn_0 | false   | show @@general_log   | has{(('general_log', 'OFF'), ('general_log_file', '/opt/dble/test/general.log'),)} | dble_information |
    | conn_0 | false   | enable @@general_log | success                                                                            | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
    """
    generalLogFile=/opt/dble/test/general.log
    """
    Then check following text exist "Y" in file "/opt/dble/test/general.log" in host "dble-1"
    """
    \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
    Tcp port: 3320  Unix socket: FAKE_SOCK
    Time                 Id Command    Argument
    """
    Then check following text exist "N" in file "/test/general/general.log" in host "dble-1"
    """
    \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
    Tcp port: 3320  Unix socket: FAKE_SOCK
    Time                 Id Command    Argument
    """
    Given delete file "/opt/dble/test/general.log" on "dble-1"

    #check reload @@general_log_file, relative path
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect                                                                            | db               |
      | conn_0 | false   | reload @@general_log_file='general/test.log' | success                                                                           | dble_information |
      | conn_0 | true    | show @@general_log                           | has{(('general_log', 'ON'), ('general_log_file', '/opt/dble/general/test.log'),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/general/test.log" in host "dble-1"
    """
    \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
    Tcp port: 3320  Unix socket: FAKE_SOCK
    Time                 Id Command    Argument
    """
    Given delete file "/opt/dble/general/test.log" on "dble-1"

    #check reload @@general_log_file, home path
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DhomePath=./c -DhomePath=/opt/dble/test
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect                                                                                 | db               |
      | conn_0 | false   | reload @@general_log_file='general/test.log' | success                                                                                | dble_information |
      | conn_0 | true    | show @@general_log                           | has{(('general_log', 'ON'), ('general_log_file', '/opt/dble/test/general/test.log'),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/test/general/test.log" in host "dble-1"
    """
    \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
    Tcp port: 3320  Unix socket: FAKE_SOCK
    Time                 Id Command    Argument
    """
    Given delete file "/opt/dble/test/general/test.log" on "dble-1"

  @btrace
  Scenario: check generalLogQueueSize value #4
    Given delete file "/opt/dble/BtraceGeneralLog.java" on "dble-1"
    Given delete file "/opt/dble/BtraceGeneralLog.java.log" on "dble-1"

    #check generalLogQueueSize default value
    Given prepare a thread run btrace script "BtraceGeneralLog.java" in "dble-1"
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                  | db                 |
      | conn_1 | true    | enable @@general_log | dble_information   |
    Then check btrace "BtraceGeneralLog.java" output in "dble-1"
    """
    generalLogQueueSize is : 4096
    """
    Given stop btrace script "BtraceGeneralLog.java" in "dble-1"
    Given destroy btrace threads list

    #check generalLogQueueSize value
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DgeneralLogQueueSize/d
    $a\-DgeneralLogQueueSize=1024
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                   | expect  | db               |
      | conn_0 | true    | disable @@general_log | success | dble_information |
    Given prepare a thread run btrace script "BtraceGeneralLog.java" in "dble-1"
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                  | db                 |
      | conn_1 | true    | enable @@general_log | dble_information   |
    Then check btrace "BtraceGeneralLog.java" output in "dble-1"
    """
    generalLogQueueSize is : 1024
    """
    Given stop btrace script "BtraceGeneralLog.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceGeneralLog.java" on "dble-1"
    Given delete file "/opt/dble/BtraceGeneralLog.java.log" on "dble-1"

  @btrace
  Scenario: check concurrent operation of manager commands #5
    Given delete file "/opt/dble/BtraceGeneralLog.java" on "dble-1"
    Given delete file "/opt/dble/BtraceGeneralLog.java.log" on "dble-1"

    #check read/write lock
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect                                                                                |
      | conn_0 | false   | show @@general_log | has{(('general_log', 'OFF'), ('general_log_file', '/opt/dble/general/general.log'),)} |
    Given update file content "./assets/BtraceGeneralLog.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /showGeneralLog/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceGeneralLog.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "show @@general_log" with "conn_0"
    Then check btrace "BtraceGeneralLog.java" output in "dble-1"
    """
    start get into showGeneralLog
    """
    Then execute sql in "dble-1" in "admin" mode
    | conn   | toClose | sql                                          | db               |
    | conn_1 | true    | reload @@general_log_file='general/test.log' | dble_information |
    Then check sql thread output in "res"
    """
    ('general_log', 'OFF'), ('general_log_file', '/opt/dble/general/general.log')
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect                                                                             | db               |
      | conn_0 | false   | show @@general_log | has{(('general_log', 'OFF'), ('general_log_file', '/opt/dble/general/test.log'),)} | dble_information |
    Given stop btrace script "BtraceGeneralLog.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceGeneralLog.java" on "dble-1"
    Given delete file "/opt/dble/BtraceGeneralLog.java.log" on "dble-1"
    Given delete file "/opt/dble/general/test.log" on "dble-1"

    #check write/write lock
    Given update file content "./assets/BtraceGeneralLog.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /updateGeneralLogFile/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceGeneralLog.java" in "dble-1"
    Given prepare a thread execute sql "reload @@general_log_file='general/general.log'" with "conn_0"
    Then check btrace "BtraceGeneralLog.java" output in "dble-1"
    """
    start get into updateGeneralLogFile
    """
    Then execute sql in "dble-1" in "admin" mode
    | conn   | toClose | sql                  | db               |
    | conn_2 | true    | enable @@general_log | dble_information |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect                                                                               | db               |
      | conn_0 | false   | show @@general_log | has{(('general_log', 'ON'), ('general_log_file', '/opt/dble/general/general.log'),)} | dble_information |
    Given stop btrace script "BtraceGeneralLog.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceGeneralLog.java" on "dble-1"
    Given delete file "/opt/dble/BtraceGeneralLog.java.log" on "dble-1"
    Given delete file "/opt/dble/general/general.log" on "dble-1"

  Scenario: check general log records - manager user #6
    Given delete file "/opt/dble/general/general.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                          | expect                           | db               |
      | conn_0 | false   | enable @@general_log                                                         | success                          | dble_information |
      | conn_0 | false   | select @@SESSION.TX_READ_ONLY                                                | success                          | dble_information |
      | conn_0 | false   | show @@heartbeat                                                             | success                          | dble_information |
      | conn_0 | false   | show @@connection                                                            | success                          | dble_information |
      | conn_0 | false   | show @@backend                                                               | success                          | dble_information |
      | conn_0 | false   | show @@pause                                                                 | success                          | dble_information |
      | conn_0 | false   | RESUME                                                                       | No shardingNode paused           | dble_information |
      | conn_0 | false   | reload @@config_all                                                          | success                          | dble_information |
      | conn_0 | false   | dryrun                                                                       | success                          | dble_information |
      | conn_0 | false   | check full @@metadata where schema="schema1" and table="sharding_4_t1"       | success                          | dble_information |
      | conn_0 | false   | reload @@metadata                                                            | success                          | dble_information |
      | conn_0 | false   | release @@reload_metadata                                                    | Dble not in reloading or reload status not interruptible | dble_information |
      | conn_0 | false   | enable @@slow_query_log                                                      | success                          | dble_information |
      | conn_0 | false   | disable @@slow_query_log                                                     | success                          | dble_information |
      | conn_0 | false   | show @@slow_query.time                                                       | success                          | dble_information |
      | conn_0 | false   | reload @@slow_query.time=200                                                 | success                          | dble_information |
      | conn_0 | false   | flow_control @@show                                                          | success                          | dble_information |
      | conn_0 | false   | explain show @@slow_query.time                                               | Unsupported statement            | dble_information |
      | conn_0 | false   | show databases                                                               | success                          | dble_information |
      | conn_0 | false   | show databases_aaa                                                           | Unsupported statement            | dble_information |
      | conn_0 | false   | use dble_information                                                         | success                          | dble_information |
      | conn_0 | false   | use dble_information_111                                                     | Unknown database 'dble_information_111' | dble_information |
      | conn_0 | false   | show tables                                                                  | success                          | dble_information |
      | conn_0 | false   | show tables_222                                                              | java.lang.IllegalStateException: No match found | dble_information |
      | conn_0 | false   | desc backend_connections                                                     | success                          | dble_information |
      | conn_0 | false   | select * from backend_connections                                            | success                          | dble_information |
      | conn_0 | false   | select count(*) from backend_connections where db_instance_name="hostM1"     | success                          | dble_information |
      | conn_0 | false   | select db_group_name, max(remote_processlist_id) as max_processlist_id from backend_connections where db_instance_name like "%M1%" group by db_group_name order by max_processlist_id desc | success | dble_information |
      | conn_0 | false   | select * from backend_connections where db_instance_name like "%M1%" limit 1 | success                          | dble_information |
      | conn_0 | false   | select user,sql,db_group_name,schema,xa_status,in_transaction from backend_connections | success                | dble_information |
      | conn_0 | false   | update backend_connections set db_instance_name="testHost" where db_instance_name="hostM1"| Access denied for table 'backend_connections' | dble_information |
      | conn_0 | false   | delete from backend_connections where user="test"                            | Access denied for table 'backend_connections' | dble_information |
      | conn_0 | false   | insert into backend_connections values (1,"1",1,1,1)                         | Access denied for table 'backend_connections' | dble_information |
      | conn_0 | false   | select name,key from dble_algorithm where is_file in (select is_file from dble_algorithm where value = "enum-integer.txt")   | success | dble_information |
      | conn_0 | false   | select name,key from dble_algorithm where is_file > all (select is_file from dble_algorithm where value ="enum-integer.txt") | success | dble_information |
      | conn_0 | false   | select name,key from dble_algorithm where is_file < any (select is_file from dble_algorithm where value ="enum-integer.txt") | success | dble_information |
      | conn_0 | false   | select name,key from dble_algorithm where is_file = any (select is_file from dble_algorithm where value ="enum-integer.txt") | success | dble_information |
      | conn_0 | false   | select name,key from dble_algorithm where is_file = (select is_file from dble_algorithm where value ="enum-integer.txt")     | success | dble_information |
      | conn_0 | false   | select id,sharding_column,algorithm_name from dble_sharding_table where algorithm_name in (select name from dble_algorithm where is_file ='true') | success | dble_information |
      | conn_0 | true    | explain select * from backend_connections limit 10                           | Unsupported statement            | dble_information |

    Then check following text exist "Y" in file "/opt/dble/general/general.log" in host "dble-1"
      """
      \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
      Tcp port: 3320  Unix socket: FAKE_SOCK
      Time                 Id Command    Argument
      select @@SESSION.TX_READ_ONLY
      show @@heartbeat
      show @@connection
      show @@backend
      show @@pause
      RESUME
      reload @@config_all
      dryrun
      check full @@metadata where schema="schema1" and table="sharding_4_t1"
      reload @@metadata
      release @@reload_metadata
      enable @@slow_query_log
      disable @@slow_query_log
      show @@slow_query.time
      reload @@slow_query.time=200
      flow_control @@show
      explain show @@slow_query.time
      show databases
      show databases_aaa
      use dble_information
      use dble_information_111
      show tables
      show tables_222
      desc backend_connections
      select \* from backend_connections
      select count(\*) from backend_connections where db_instance_name="hostM1"
      select db_group_name, max(remote_processlist_id) as max_processlist_id from backend_connections where db_instance_name like "%M1%" group by db_group_name order by max_processlist_id desc
      select \* from backend_connections where db_instance_name like "%M1%" limit 1
      select user,sql,db_group_name,schema,xa_status,in_transaction from backend_connections
      update backend_connections set db_instance_name="testHost" where db_instance_name="hostM1"
      delete from backend_connections where user="test"
      insert into backend_connections values (1,"1",1,1,1)
      select name,key from dble_algorithm where is_file in (select is_file from dble_algorithm where value = "enum-integer.txt")
      select name,key from dble_algorithm where is_file > all (select is_file from dble_algorithm where value ="enum-integer.txt")
      select name,key from dble_algorithm where is_file < any (select is_file from dble_algorithm where value ="enum-integer.txt")
      select name,key from dble_algorithm where is_file = any (select is_file from dble_algorithm where value ="enum-integer.txt")
      select name,key from dble_algorithm where is_file = (select is_file from dble_algorithm where value ="enum-integer.txt")
      explain select \* from backend_connections limit 10
      Quit
      """
    Given delete file "/opt/dble/general/general.log" on "dble-1"

  Scenario: check general log records - sharding user #7
    Given delete file "/opt/dble/general/general.log" on "dble-1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema2">
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "enable @@general_log"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                          | expect                           | db      |
      | conn_1 | False   | select version()                                                             | success                          | schema1 |
      | conn_1 | False   | show databases                                                               | success                          | schema1 |
      | conn_1 | False   | use schema1                                                                  | success                          | schema1 |
      | conn_1 | False   | show tables                                                                  | success                          | schema1 |
      | conn_1 | False   | use schema1_111                                                              | Unknown database 'schema1_111'   | schema1 |
      # no sharding table
      | conn_2 | False   | drop table if exists no_sharding_t1                                          | success                          | schema1 |
      | conn_2 | False   | create table no_sharding_t1(id int, name varchar(20),age int)                | success                          | schema1 |
      | conn_2 | False   | desc no_sharding_t1                                                          | success                          | schema1 |
      | conn_2 | False   | explain select * from no_sharding_t1 limit 10                                | success                          | schema1 |
      | conn_2 | False   | insert into no_sharding_t1 values (1,"name1",1),(2,"name2",2),(3,"name3",3)  | success                          | schema1 |
      | conn_2 | False   | select * from no_sharding_t1                                                 | success                          | schema1 |
      | conn_2 | False   | select id, name from no_sharding_t1 where name like "%name%" order by age    | success                          | schema1 |
      | conn_2 | False   | select count(*) from no_sharding_t1 where age > 1 group by age               | success                          | schema1 |
      | conn_2 | False   | update no_sharding_t1 set age=age-1 where age=3                              | success                          | schema1 |
      | conn_2 | False   | delete from no_sharding_t1 where name="name3"                                | success                          | schema1 |
      # view
      | conn_3 | False   | drop view if exists view_test                                                | success                          | schema1 |
      | conn_3 | False   | create view view_test as select * from no_sharding_t1                        | success                          | schema1 |
      | conn_3 | False   | select * from view_test                                                      | success                          | schema1 |
      | conn_3 | False   | drop view view_test                                                          | success                          | schema1 |
      # sharding table
      | conn_4 | False   | drop table if exists sharding_4_t1                                           | success                          | schema1 |
      | conn_4 | False   | create table sharding_4_t1(id int, name varchar(20), age int)                | success                          | schema1 |
      | conn_4 | False   | explain select * from sharding_4_t1 limit 10                                 | success                          | schema1 |
      | conn_4 | False   | insert into sharding_4_t1(id,name,age) select id,name,age from no_sharding_t1| This `INSERT ... SELECT Syntax` is not supported! | schema1 |
      | conn_4 | False   | insert into sharding_4_t1 values (1,"name1",1),(2,"name2",2),(3,"name3",3),(4,"name4",4) | success              | schema1 |
      | conn_4 | False   | select count(*) from sharding_4_t1 where name like "%name%" group by name    | success                          | schema1 |
      | conn_4 | False   | select id, name from sharding_4_t1 where age > 1 order by name desc limit 10 | success                          | schema1 |
      | conn_4 | False   | update sharding_4_t1 set age=age-1 where age=3                               | success                          | schema1 |
      | conn_4 | False   | delete from sharding_4_t1 where name="name7"                                 | success                          | schema1 |
      # complex sql
      | conn_1 | False   | select * from no_sharding_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1 | success              | schema1 |
      | conn_1 | False   | select * from sharding_4_t1 where name in (select name from no_sharding_t1 where id !=1) | success              | schema1 |
      | conn_1 | False   | select * from no_sharding_t1 where age <> (select age from sharding_4_t1 where id !=1)   | Subquery returns more than 1 row | schema1 |
      | conn_1 | False   | update sharding_4_t1 set name="3" where name=(select name from no_sharding_t1 order by id desc limit 1) | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_1 | False   | update sharding_4_t1 set name="4" where name in (select name from no_sharding_t1)                       | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_1 | False   | update sharding_4_t1 a, no_sharding_t1 b set a.name=b.name where a.id=2 and b.id=2                      | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_1 | False   | update no_sharding_t1 set age=age-1 where name != (select name from sharding_4_t1 where name ="name1")  | This `Complex Update Syntax` is not supported! | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where name in ((select age from (select name,age from no_sharding_t1 order by id desc) as tmp)) | This `Complex Delete Syntax` is not supported! | schema1 |
      | conn_1 | False   | delete sharding_4_t1 from sharding_4_t1,no_sharding_t1 where sharding_4_t1.id=1                         | This `Complex Delete Syntax` is not supported! | schema1 |
      #hint sql
      | conn_1 | False    | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1                      | success                          | schema1 |
      | conn_1 | False    | /*!dble:shardingNode=dn1*/ insert into sharding_4_t1 values(66,"name66",66) | success                          | schema1 |
      | conn_1 | False    | /*!dble:shardingNode=dn1*/ update sharding_4_t1 set name="dn1" where id=66  | success                          | schema1 |
      | conn_1 | True     | /*!dble:shardingNode=dn1*/ delete from sharding_4_t1 where id=66            | success                          | schema1 |
      #vertical table
      #global table
      #single table

    Then check following text exist "Y" in file "/opt/dble/general/general.log" in host "dble-1"
      """
      \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
      Tcp port: 3320  Unix socket: FAKE_SOCK
      Time                 Id Command    Argument
      select version()
      show databases
      use schema1
      show tables
      use schema1_111
      drop table if exists no_sharding_t1
      create table no_sharding_t1(id int, name varchar(20),age int)
      desc no_sharding_t1
      explain select \* from no_sharding_t1 limit 10
      insert into no_sharding_t1 values (1,"name1",1),(2,"name2",2),(3,"name3",3)
      select \* from no_sharding_t1
      select id, name from no_sharding_t1 where name like "%name%" order by age
      select count(\*) from no_sharding_t1 where age > 1 group by age
      update no_sharding_t1 set age=age-1 where age=3
      delete from no_sharding_t1 where name="name3"
      drop view if exists view_test
      create view view_test as select \* from no_sharding_t1
      select \* from view_test
      drop view view_test
      drop table if exists sharding_4_t1
      create table sharding_4_t1(id int, name varchar(20), age int)
      explain select \* from sharding_4_t1 limit 10
      insert into sharding_4_t1(id,name,age) select id,name,age from no_sharding_t1
      insert into sharding_4_t1 values (1,"name1",1),(2,"name2",2),(3,"name3",3),(4,"name4",4)
      select count(\*) from sharding_4_t1 where name like "%name%" group by name
      select id, name from sharding_4_t1 where age > 1 order by name desc limit 10
      update sharding_4_t1 set age=age-1 where age=3
      delete from sharding_4_t1 where name="name7"
      select \* from no_sharding_t1 a inner join sharding_4_t1 b on a.name=b.name where a.id =1
      select \* from sharding_4_t1 where name in (select name from no_sharding_t1 where id !=1)
      select \* from no_sharding_t1 where age <> (select age from sharding_4_t1 where id !=1)
      update sharding_4_t1 set name="3" where name=(select name from no_sharding_t1 order by id desc limit 1)
      update sharding_4_t1 set name="4" where name in (select name from no_sharding_t1)
      update sharding_4_t1 a, no_sharding_t1 b set a.name=b.name where a.id=2 and b.id=2
      update no_sharding_t1 set age=age-1 where name != (select name from sharding_4_t1 where name ="name1")
      delete from sharding_4_t1 where name in ((select age from (select name,age from no_sharding_t1 order by id desc) as tmp))
      delete sharding_4_t1 from sharding_4_t1,no_sharding_t1 where sharding_4_t1.id=1
      /\*!dble:shardingNode=dn1\*/ select \* from sharding_4_t1
      /\*!dble:shardingNode=dn1\*/ insert into sharding_4_t1 values(66,"name66",66)
      /\*!dble:shardingNode=dn1\*/ update sharding_4_t1 set name="dn1" where id=66
      /\*!dble:shardingNode=dn1\*/ delete from sharding_4_t1 where id=66
      Quit
      """
    Given delete file "/opt/dble/general/general.log" on "dble-1"

  Scenario: check general log records - rwSplitUser #8
    Given delete file "/opt/dble/general/general.log" on "dble-1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "enable @@general_log"
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                                                                                                      | expect  | db  |
      | split1 | 111111 | conn_1 | False   | select version()                                                                                                         | success | db1 |
      | split1 | 111111 | conn_1 | False   | show databases                                                                                                           | success | db1 |
      | split1 | 111111 | conn_1 | False   | use db1                                                                                                                  | success | db1 |
      | split1 | 111111 | conn_1 | False   | show tables                                                                                                              | success | db1 |
      | split1 | 111111 | conn_1 | False   | drop table if exists test_table1                                                                                         | success | db1 |
      | split1 | 111111 | conn_1 | False   | create table test_table1(id int, name varchar(20),age int)                                                               | success | db1 |
      | split1 | 111111 | conn_1 | False   | desc test_table1                                                                                                         | success | db1 |
      | split1 | 111111 | conn_1 | False   | explain select * from test_table1 limit 10                                                                               | success | db1 |
      | split1 | 111111 | conn_1 | False   | insert into test_table1 values (1,"name1",1),(2,"name2",2),(3,"name3",3),(4,"name4",4)                                   | success | db1 |
      | split1 | 111111 | conn_1 | False   | drop table if exists test_table2                                                                                         | success | db2 |
      | split1 | 111111 | conn_1 | False   | create table test_table2(id int, name varchar(20),age int)                                                               | success | db2 |
      | split1 | 111111 | conn_1 | False   | insert into test_table2(id,name,age) select id,name,age from db1.test_table1                                             | success | db2 |
      | split1 | 111111 | conn_1 | False   | update test_table2 set name="test_name" where id in (select id from db1.test_table1)                                     | success | db2 |
      | split1 | 111111 | conn_1 | False   | update test_table2 a,db1.test_table1 b set a.age=b.age-1 where a.id=2 and b.id=2                                         | success | db2 |
      | split1 | 111111 | conn_1 | False   | select n.id,s.name from test_table2 n join db1.test_table1 s on n.id=s.id                                                | success | db2 |
      | split1 | 111111 | conn_1 | False   | select * from test_table2 where age <> (select age from db1.test_table1 where id !=1)                                    | Subquery returns more than 1 row | db2 |
      | split1 | 111111 | conn_1 | False   | select * from test_table2 where age in (select age from db1.test_table1 where id !=1)                                    | success | db2 |
      | split1 | 111111 | conn_1 | False   | delete test_table2 from test_table2,db1.test_table1 where test_table2.id=1 and test_table1.id =1                         | success | db2 |
      | split1 | 111111 | conn_1 | False   | delete from db1.test_table1 where name in ((select age from (select name,age from test_table2 order by id desc) as tmp)) | success | db2 |
      | split1 | 111111 | conn_1 | False   | drop view if exists test_view                                                                                            | success | db1 |
      | split1 | 111111 | conn_1 | False   | create view test_view(id,name,age) AS select * from test_table1                                                          | success | db1 |
      | split1 | 111111 | conn_1 | False   | select * from test_view union select * from test_table1                                                                  | success | db1 |
      | split1 | 111111 | conn_1 | False   | drop view test_view                                                                                                      | success | db1 |
      | split1 | 111111 | conn_1 | False   | select * from (select s.sno from test_table1 s where s.id=1)                                                             | Every derived table must have its own alias | db1 |
      | split1 | 111111 | conn_1 | False   | abc | You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'abc' at line 1 | db1 |

    Then check following text exist "Y" in file "/opt/dble/general/general.log" in host "dble-1"
      """
      \/FAKE_PATH\/mysqld, Version: FAKE_VERSION. started with:
      Tcp port: 3320  Unix socket: FAKE_SOCK
      Time                 Id Command    Argument
      select version()
      show databases
      use db1
      show tables
      drop table if exists test_table1
      create table test_table1(id int, name varchar(20),age int)
      desc test_table1
      explain select \* from test_table1 limit 10
      insert into test_table1 values (1,"name1",1),(2,"name2",2),(3,"name3",3),(4,"name4",4)
      drop table if exists test_table2
      create table test_table2(id int, name varchar(20),age int)
      insert into test_table2(id,name,age) select id,name,age from db1.test_table1
      update test_table2 set name="test_name" where id in (select id from db1.test_table1)
      update test_table2 a,db1.test_table1 b set a.age=b.age-1 where a.id=2 and b.id=2
      select n.id,s.name from test_table2 n join db1.test_table1 s on n.id=s.id
      select \* from test_table2 where age <> (select age from db1.test_table1 where id !=1)
      select \* from test_table2 where age in (select age from db1.test_table1 where id !=1)
      delete test_table2 from test_table2,db1.test_table1 where test_table2.id=1 and test_table1.id =1
      delete from db1.test_table1 where name in ((select age from (select name,age from test_table2 order by id desc) as tmp))
      drop view if exists test_view
      create view test_view(id,name,age) AS select \* from test_table1
      select \* from test_view union select \* from test_table1
      drop view test_view
      select \* from (select s.sno from test_table1 s where s.id=1)
      abc
      Quit
      """
    Given delete file "/opt/dble/general/general.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                                          | expect  | db  |
      | split1 | 111111 | conn_1 | False   | drop table if exists test_table2                             | success | db2 |
      | split1 | 111111 | conn_1 | true    | drop table if exists test_table1                             | success | db1 |
