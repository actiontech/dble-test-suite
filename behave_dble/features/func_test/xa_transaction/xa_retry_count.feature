# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/3

#2.20.04.0#dble-8176
  @skip
Feature: change xaRetryCount value and check result
  @skip
  Scenario: Setting xaRetryCount to an illegal value, dble report warning #1
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DxaRetryCount=-1
    """
    Given Restart dble in "dble-1" success
    Then check "dble.log" in "dble-1" has the warnings
      | TYPE-0 | LEVEL-1 | DETAIL-2                                                                |
      | Xml    | WARNING | Property [ xaRetryCount ] '-1' in bootstrap.cnf is illegal, use 0 replaced |

  @btrace
  Scenario: Setting xaRetryCount to 3 , dble report 3 warnings, recovery node by manual, check data not lost #2
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DxaRetryCount=3
    """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                      | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char)            | schema1 |
      | conn_0 | False   | set autocommit=0                                        | schema1 |
      | conn_0 | False   | set xa=on                                               | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | schema1 |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "1" times
    """
    before xa commit
    """
    Given stop mysql in host "mysql-master1"
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given sleep "10" seconds
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Then check result "rs_A" value is "3"
    Given start mysql in host "mysql-master1"
    Given sleep "15" seconds
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect      | db      |
      | conn_1 | False   | select * from sharding_4_t1          | length{(4)} | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id=1 | success     | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id=2 | success     | schema1 |
      | conn_1 | False   | delete from sharding_4_t1 where id=3 | success     | schema1 |
      | conn_1 | True    | delete from sharding_4_t1 where id=4 | success     | schema1 |
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

  @btrace @current
  Scenario: mysql node failover during xa transaction retry commit stage and check data not lost #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
          <property name="heartbeatPeriodMillis">2000</property>
          </dbInstance>
      </dbGroup>

      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
          <property name="heartbeatPeriodMillis">2000</property>
          </dbInstance>
      </dbGroup>
    """
    Given Restart dble in "dble-1" success
#   delayBeforeXaCommit sleep time must long enough for stopping dble
    Given update file content "./assets/BtraceXaDelay_backgroundRetry2.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    /beforeAddXaToQueue/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceXaDelay_backgroundRetry2.java" in "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1                      | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1(id int,name char)            | success | schema1 |
      | conn_1 | False   | set autocommit=0                                        | success | schema1 |
      | conn_1 | False   | set xa=on                                               | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values(1,1),(2,2)             | success | schema1 |
    Given prepare a thread execute sql "commit" with "conn_1"
    Then check btrace "BtraceXaDelay_backgroundRetry2.java" output in "dble-1" with ">0" times
    """
    before xa commit
    """
    Given stop mysql in host "mysql-master1"
    Given destroy sql threads list
    Then check btrace "BtraceXaDelay_backgroundRetry2.java" output in "dble-1"
    """
    before add xa
    """
    Given start mysql in host "mysql-master1"
    #sleep 5s for waiting background retry succeed,2s make sure heartbeat recover, and 3s wait xa commit, loop to try commit at per 1s
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect      | db      |
      | conn_2 | False   | select * from sharding_2_t1          | length{(2)} | schema1 |
      | conn_2 | False   | delete from sharding_2_t1 where id=1 | success     | schema1 |
      | conn_2 | True    | delete from sharding_2_t1 where id=2 | success     | schema1 |
    Given stop btrace script "BtraceXaDelay_backgroundRetry2.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceXaDelay_backgroundRetry2.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay_backgroundRetry2.java.log" on "dble-1"