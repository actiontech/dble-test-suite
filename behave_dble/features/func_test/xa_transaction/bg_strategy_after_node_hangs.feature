# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/26

#2.20.04.0#dble-8174
Feature: retry policy after xa transaction commit failed for mysql service stopped

  @btrace @restore_mysql_service @auto_retry #DBLE0REQ-2305
  Scenario: mysql node hangs causing xa transaction fail to commit,restart mysql node before the front end attempts to commit 5 times #1
    """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | schema1 |
      | conn_0 | False   | set autocommit=0                                        | schema1 |
      | conn_0 | False   | set xa=on                                               | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    /beforeInnerRetry/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with ">0" times
    """
    before xa commit
    """
    Given stop mysql in host "mysql-master1"
    # delayBeforeXaCommit桩可能还没结束，桩结束后才会进beforeInnerRetry桩
    Given sleep "20" seconds
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "1" times
    """
    before inner retry
    """
    Given start mysql in host "mysql-master1"
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    #### 确定dble心跳恢复

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect      | db      | timeout |
      | conn_1 | False   | select * from sharding_4_t1         | length{(4)} | schema1 | 15,3    |
      | conn_1 | False   | delete from sharding_4_t1           | success     | schema1 |         |
      | conn_1 | True    | drop table if exists sharding_4_t1  | success     | schema1 |         |

    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"


  @btrace @restore_mysql_service @auto_retry
  Scenario: mysql node hangs causing xa transaction fail to commit, automatic recovery in background attempts #2
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | success | schema1 |
      | conn_0 | False   | set autocommit=0                                        | success | schema1 |
      | conn_0 | False   | set xa=on                                               | success | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    /beforeAddXaToQueue/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa commit
    """
    Given stop mysql in host "mysql-master1"
    # delayBeforeXaCommit桩可能还没结束，桩结束后才会进beforeAddXaToQueue桩
    Given sleep "20" seconds
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before add xa
    """
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given execute oscmd in "dble-1" and "4" less than result
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Given start mysql in host "mysql-master1"
    Then execute oscmd many times in "dble-1" and result is same
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    #### 确定dble心跳恢复

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect      | db      | timeout |
      | conn_1 | False   | select * from sharding_4_t1         | length{(4)} | schema1 | 15,3    |
      | conn_1 | False   | delete from sharding_4_t1           | success     | schema1 |         |
      | conn_1 | True    | drop table if exists sharding_4_t1  | success     | schema1 |         |

    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace @restore_mysql_service @skip #DBLE0REQ-2297
  Scenario:mysql node hangs causing xa transaction fail to commit, close background attempts, execute 'kill @@session.xa' #3
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | schema1 |
      | conn_0 | False   | set autocommit=0                                        | schema1 |
      | conn_0 | False   | set xa=on                                               | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa prepare
    """
    Given stop mysql in host "mysql-master1"
    Given destroy sql threads list

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_A"
      | sql               |
      | show @@session.xa |
    Then execute admin cmd "kill @@xa_session" with "rs_A" result

    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then execute oscmd many times in "dble-1" and result is same
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Given sleep "10" seconds
    #wait background attempt failed
    Given start mysql in host "mysql-master1"
    #warit Heartbeat successed

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect                     | db      | timeout |
      | conn_1 | false   | select * from sharding_4_t1            | length{(2)}                | schema1 | 15,3    |
      | conn_1 | false   | delete from sharding_4_t1 where id = 1 | success                    | schema1 |         |
      | conn_1 | false   | delete from sharding_4_t1 where id = 2 | Lock wait timeout exceeded | schema1 |         |
      | conn_1 | false   | delete from sharding_4_t1 where id = 3 | success                    | schema1 |         |
      | conn_1 | True    | delete from sharding_4_t1 where id = 4 | Lock wait timeout exceeded | schema1 |         |

    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect      | db      |
      | conn_1 | false   | select * from sharding_4_t1         | length{(2)} | schema1 |
      | conn_1 | false   | delete from sharding_4_t1           | success     | schema1 |
      | conn_1 | True    | drop table if exists sharding_4_t1  | success     | schema1 |

    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace @restore_mysql_service
  Scenario: mysql node hangs causing xa transaction fail to commit, restart dble causing xa commit again #4
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | schema1 |
      | conn_0 | False   | set autocommit=0                                        | schema1 |
      | conn_0 | False   | set xa=on                                               | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa prepare
    """
    Given stop mysql in host "mysql-master1"
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then restart dble in "dble-1" failed for
    """
     Fail to recover xa when dble start, please check backend mysql
    """
    Given start mysql in host "mysql-master1"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect      | db      |
      | conn_1 | False   | select * from sharding_4_t1            | length{(4)} | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id = 1 | success     | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id = 2 | success     | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id = 3 | success     | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id = 4 | success     | schema1 |
      | conn_1 | True    | drop table if exists sharding_4_t1     | success     | schema1 |

    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace @restore_mysql_service
  Scenario: mysql node hangs causing xa transaction perpare to fail and keep rolling back,but recovered during background attempts #5
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | schema1 |
      | conn_0 | False   | set autocommit=0                                        | schema1 |
      | conn_0 | False   | set xa=on                                               | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /delayBeforeXaPrepare/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    /beforeAddXaToQueue/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa end
    """
    Given stop mysql in host "mysql-master1"
    Given destroy sql threads list
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "5" times
    """
    before add xa
    """
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given execute oscmd in "dble-1" and "5" less than result
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Given start mysql in host "mysql-master1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect      | db      | timeout |
      | conn_1 | False   | select * from sharding_4_t1            | length{(0)} | schema1 | 15,3    |
      | conn_1 | False   | delete from sharding_4_t1 where id = 1 | success     | schema1 |         |
      | conn_1 | False   | delete from sharding_4_t1 where id = 2 | success     | schema1 |         |
      | conn_1 | False   | delete from sharding_4_t1 where id = 3 | success     | schema1 |         |
      | conn_1 | False   | delete from sharding_4_t1 where id = 4 | success     | schema1 |         |
      | conn_1 | True    | drop table if exists sharding_4_t1     | success     | schema1 |         |

    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace @restore_mysql_service
  Scenario: mysql node hangs causing xa transaction fail to commit, automatic recovery in background attempts and check xaSessionCheckPeriod #6
    """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="xaSessionCheckPeriod">20000</property>
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | success | schema1 |
      | conn_0 | False   | set autocommit=0                                        | success | schema1 |
      | conn_0 | False   | set xa=on                                               | success | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa commit
    """
    Given stop mysql in host "mysql-master1"
    Given sleep "10" seconds
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given record current dble log "/opt/dble/logs/dble.log" line number in "log_num_1"
    Given sleep "60" seconds
    ### 日志中 "at the 0th time in background "的关键字是定时任务完成返回的，和定时任务开始是两个异步的线程，靠这个关键词检测xaSessionCheckPeriod字段存在一定的时间误差
    ### 目前因为issue：DBLE0REQ-2056 ，暂时更改成检验时间内发生的次数作为校验，后续有更好的方案再修改 time：2023.1.31
    ### 增加偏移量确保时间差  time：2023.2.1
    Then check the time interval of following key after line "log_num_1" in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                        | interval_times | percent |
      | at the 0th time in background              | 20             |  0.5   |
    Given start mysql in host "mysql-master1"
    #warit Heartbeat successed
    Given sleep "15" seconds
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="xaSessionCheckPeriod">10000</property>
    """
    Then Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_2 | False   | set autocommit=0                                        | success | schema1 |
      | conn_2 | False   | set xa=on                                               | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values(5,5),(6,6),(7,7),(8,8) | success | schema1 |
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given prepare a thread execute sql "commit" with "conn_2"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "4" times
    """
    before xa commit
    """
    Given stop mysql in host "mysql-master1"
    Given sleep "10" seconds
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given record current dble log "/opt/dble/logs/dble.log" line number in "log_num_2"
    Given sleep "30" seconds
    Then check the time interval of following key after line "log_num_2" in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                        | interval_times | percent |
      | at the 0th time in background              | 10             |  0.5   |
    Given start mysql in host "mysql-master1"
    #warit Heartbeat successed
    ###心跳恢复和xa的定时任务有时间差，还是要加上至少1秒的retry
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect      | db      | timeout |
      | conn_1 | False   | select * from sharding_4_t1         | length{(8)} | schema1 | 15,3    |
      | conn_1 | False   | delete from sharding_4_t1           | success     | schema1 |         |
      | conn_1 | True    | drop table if exists sharding_4_t1  | success     | schema1 |         |

    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"