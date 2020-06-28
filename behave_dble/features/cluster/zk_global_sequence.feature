# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/11/6
# 2.19.11.0#dble-7890


Feature: when global sequence with zookeeper mode, if system time exceeds 17 years after startup time ,it will report an error

  @skip_restart
  Scenario: when "insert time" greater than "start time" and less than "start time + 17years", check the correctness of the self-increment sequence #1
    Given reset dble registered nodes in zk
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="mytest_auto_test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" incrementColumn="id" shardingColumn="id"/>
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    $a sequenceHandlerType=3
    $a sequenceStartTime=2010-11-04 09:42:54
    $a sequenceInstanceByZk=true
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-2" with sed cmds
    """
    $a sequenceHandlerType=3
    $a sequenceStartTime=2010-11-04 09:42:54
    $a sequenceInstanceByZk=true
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-3" with sed cmds
    """
    $a sequenceHandlerType=3
    $a sequenceStartTime=2010-11-04 09:42:54
    $a sequenceInstanceByZk=true
    """
    Given execute single sql in "dble-1" in "user" mode and save resultset in "sysTime"
      | sql               |
      | select sysdate()  |
    Then change sequenceStartTime to current time "sysTime" in "cluster.cnf" in dble "dble-1"
    Then change sequenceStartTime to current time "sysTime" in "cluster.cnf" in dble "dble-2"
    Then change sequenceStartTime to current time "sysTime" in "cluster.cnf" in dble "dble-3"
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_0 | True    | drop table if exists mytest_auto_test                   | success | schema1 |
      | conn_0 | True    | create table mytest_auto_test(id bigint,time char(120)) | success | schema1 |
      | conn_0 | True    | insert into mytest_auto_test values(curdate())          | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "ts_time"
      | sql                               | db      |
      | select time from mytest_auto_test | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_id"
      | sql                                         | db      |
      | select conv(id,10,2) from mytest_auto_test  | schema1 |
    Then get id binary named "a" from "rs_id" and add 0 if binary length less than 64 bits
    Then get binary range start "10" end "18" from "a" named "result1"
    Then convert binary "result1"  to decimal "dec_rs1" and check value is "0"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "sysTime" to get "t3"
    Then check time "ts_time" equal to "t3"

    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                            | expect  | db      |
      | conn_0 | False   | delete from mytest_auto_test                   | success | schema1 |
      | conn_0 | True    | insert into mytest_auto_test values(curdate()) | success | schema1 |
    Given execute single sql in "dble-2" in "user" mode and save resultset in "ts_time"
      | sql                               | db      |
      | select time from mytest_auto_test | schema1 |
    Given execute single sql in "dble-2" in "user" mode and save resultset in "rs_id"
      | sql                                        | db      |
      | select conv(id,10,2) from mytest_auto_test | schema1 |
    Then get id binary named "a" from "rs_id" and add 0 if binary length less than 64 bits
    Then get binary range start "10" end "18" from "a" named "result1"
    Then convert binary "result1"  to decimal "dec_result1" and check value is "1"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "sysTime" to get "t3"
    Then check time "ts_time" equal to "t3"

  @restore_sys_time
  Scenario: when "system time" less than "start time + 17years", execute insert sql will error #2
    Given execute single sql in "dble-1" in "user" mode and save resultset in "curTime"
      | sql              |
      | select sysdate() |
    When connect ssh execute cmd "date -s 2009/01/01"
    Then execute sql in "dble-1" in "user" mode
      | sql                                    | expect                                          | db      |
      | insert into mytest_auto_test values(1) | Clock moved backwards.  Refusing to generate id | schema1 |

  @skip_restart
  Scenario: when values of key "INSTANCEID" are different and "sequenceInstanceByZk" is false, check the correctness of the self-increment sequence #3
    Given reset dble registered nodes in zk
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="mytest_auto_test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" incrementColumn="id" shardingColumn="id"/>
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    $a sequenceHandlerType=3
    $a sequenceStartTime=2010-11-04 09:42:54
    $a sequenceInstanceByZk=false
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-2" with sed cmds
    """
    $a sequenceHandlerType=3
    $a sequenceStartTime=2010-11-04 09:42:54
    $a sequenceInstanceByZk=false
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-3" with sed cmds
    """
    $a sequenceHandlerType=3
    $a sequenceStartTime=2010-11-04 09:42:54
    $a sequenceInstanceByZk=false
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DinstanceId/c -DinstanceId=0
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    /DinstanceId/c -DinstanceId=511
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    /DinstanceId/c -DinstanceId=128
    """
    Given execute single sql in "dble-3" in "user" mode and save resultset in "sysTime"
      | sql               |
      | select sysdate()  |
    Then change sequenceStartTime to current time "sysTime" in "cluster.cnf" in dble "dble-1"
    Then change sequenceStartTime to current time "sysTime" in "cluster.cnf" in dble "dble-2"
    Then change sequenceStartTime to current time "sysTime" in "cluster.cnf" in dble "dble-3"
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose | sql                                            | expect  | db      |
      | conn_0 | False   | delete from mytest_auto_test                   | success | schema1 |
      | conn_0 | True    | insert into mytest_auto_test values(curdate()) | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "ts_time"
      | sql                               | db      |
      | select time from mytest_auto_test | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_id"
      | sql                                        | db      |
      | select conv(id,10,2) from mytest_auto_test | schema1 |
    Then get id binary named "a" from "rs_id" and add 0 if binary length less than 64 bits
    Then get binary range start "10" end "18" from "a" named "result1"
    Then convert binary "result1"  to decimal "dec_rs1" and check value is "128"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "sysTime" to get "t3"
    Then check time "ts_time" equal to "t3"

  @skip_restart
  Scenario: when values of key "INSTANCEID" is 0, check the correctness of the self-increment sequence #4
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect  | db      |
      | conn_0 | False   | delete from mytest_auto_test                   | success | schema1 |
      | conn_0 | True    | insert into mytest_auto_test values(curdate()) | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "ts_time"
      | sql                               | db      |
      | select time from mytest_auto_test | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_id"
      | sql                                        | db      |
      | select conv(id,10,2) from mytest_auto_test | schema1 |
    Then get id binary named "a" from "rs_id" and add 0 if binary length less than 64 bits
    Then get binary range start "10" end "18" from "a" named "result1"
    Then convert binary "result1"  to decimal "dec_rs1" and check value is "0"

  @skip_restart
  Scenario: when values of key "INSTANCEID" is 511, check the correctness of the self-increment sequence #5
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                            | expect  | db      |
      | conn_0 | False   | delete from mytest_auto_test                   | success | schema1 |
      | conn_0 | True    | insert into mytest_auto_test values(curdate()) | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "ts_time"
      | sql                               | db      |
      | select time from mytest_auto_test | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_id"
      | sql                                        | db      |
      | select conv(id,10,2) from mytest_auto_test | schema1 |
    Then get id binary named "a" from "rs_id" and add 0 if binary length less than 64 bits
    Then get binary range start "10" end "18" from "a" named "result1"
    Then convert binary "result1"  to decimal "dec_rs1" and check value is "511"
