# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/11/6
# 2.19.11.0#dble-7890
Feature: when global sequence with zookeeper mode, if system time exceeds 17 years after startup time ,it will report an error

  @skip_restart
  Scenario: when "insert time" greater than "start time" and less than "start time + 17years", check the correctness of the self-increment sequence #1
    Given reset dble registered nodes in zk
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="mytest_auto_test" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" incrementColumn="id"/>
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="sequenceHandlerType">3</property>
    """
    Given execute single sql in "dble-1" in "user" mode and save resultset in "sysTime"
      | sql               |
      | select sysdate()  |
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /INSTANCEID/c INSTANCEID=zk
    /CLUSTERID/c CLUSTERID=01
    /START_TIME/c START_TIME=2010-11-04 09:42:54
    """
     Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-2" with sed cmds
    """
    /INSTANCEID/c INSTANCEID=zk
    /CLUSTERID/c CLUSTERID=02
    /START_TIME/c START_TIME=2010-11-04 09:42:54
    """
     Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-3" with sed cmds
    """
    /INSTANCEID/c INSTANCEID=zk
    /CLUSTERID/c CLUSTERID=03
    /START_TIME/c START_TIME=2010-11-04 09:42:54
    """
    Then change start_time to current time "sysTime" in "sequence_distributed_conf.properties" in dble "dble-1"
    Then change start_time to current time "sysTime" in "sequence_distributed_conf.properties" in dble "dble-2"
    Then change start_time to current time "sysTime" in "sequence_distributed_conf.properties" in dble "dble-3"
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
    Then get binary range start "15" end "18" from "a" named "result1"
    Then get binary range start "10" end "14" from "a" named "result2"
    Then convert binary "result1"  to decimal "dec_rs1" and check value is "1"
    Then convert binary "result2"  to decimal "A"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "sysTime" to get "t3"
    Then check time "ts_time" equal to "t3"

    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_0 | False   | drop table if exists mytest_auto_test                   | success | schema1 |
      | conn_0 | False   | create table mytest_auto_test(id bigint,time char(120)) | success | schema1 |
      | conn_0 | True    | insert into mytest_auto_test values(curdate())          | success | schema1 |
    Given execute single sql in "dble-2" in "user" mode and save resultset in "ts_time"
      | sql                               | db      |
      | select time from mytest_auto_test | schema1 |
    Given execute single sql in "dble-2" in "user" mode and save resultset in "rs_id"
      | sql                                        | db      |
      | select conv(id,10,2) from mytest_auto_test | schema1 |
    Then get id binary named "a" from "rs_id" and add 0 if binary length less than 64 bits
    Then get binary range start "15" end "18" from "a" named "result1"
    Then get binary range start "10" end "14" from "a" named "result2"
    Then convert binary "result1"  to decimal "dec_result1" and check value is "2"
    Then convert binary "result2"  to decimal "B"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "sysTime" to get "t3"
    Then check time "ts_time" equal to "t3"

  @skip_restart @restore_sys_time
  Scenario: when "system time" less than "start time + 17years", execute insert sql will error #2
    Given execute single sql in "dble-1" in "user" mode and save resultset in "curTime"
      | sql              |
      | select sysdate() |
    When connect ssh execute cmd "date -s 2009/01/01"
    Then execute sql in "dble-1" in "user" mode
      | sql                                    | expect                                          | db      |
      | insert into mytest_auto_test values(1) | Clock moved backwards.  Refusing to generate id | schema1 |

  @skip_restart
  Scenario: when values of key "INSTANCEID" are same and values of key "CLUSTERID" are different, check the correctness of the self-increment sequence #3
    Given execute single sql in "dble-1" in "user" mode and save resultset in "sysTime"
      | sql               |
      | select sysdate()  |
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /CLUSTERID/c CLUSTERID=04
    """
    Then change start_time to current time "sysTime" in "sequence_distributed_conf.properties" in dble "dble-1"
    Given Restart dble in "dble-1" success
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
    Then get binary range start "15" end "18" from "a" named "result1"
    Then get binary range start "10" end "14" from "a" named "result2"
    Then convert binary "result1"  to decimal "dec_rs1" and check value is "4"
    Then convert binary "result2"  to decimal "A"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "sysTime" to get "t3"
    Then check time "ts_time" equal to "t3"

  @skip_restart
  Scenario: when values of key "INSTANCEID" and "CLUSTERID" are same, check the correctness of the self-increment sequence #4
    Given execute single sql in "dble-1" in "user" mode and save resultset in "sysTime"
      | sql              |
      | select sysdate() |
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /CLUSTERID/c CLUSTERID=01
    """
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-2" with sed cmds
    """
    /CLUSTERID/c CLUSTERID=01
    """
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-2" with sed cmds
    """
    /CLUSTERID/c CLUSTERID=01
    """
    Then change start_time to current time "sysTime" in "sequence_distributed_conf.properties" in dble "dble-1"
    Then change start_time to current time "sysTime" in "sequence_distributed_conf.properties" in dble "dble-2"
    Then change start_time to current time "sysTime" in "sequence_distributed_conf.properties" in dble "dble-3"
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
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
    Then get binary range start "15" end "18" from "a" named "result1"
    Then get binary range start "10" end "14" from "a" named "result2"
    Then convert binary "result1"  to decimal "dec_rs1" and check value is "1"
    Then convert binary "result2"  to decimal "A"
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
    Then get binary range start "15" end "18" from "a" named "result1"
    Then get binary range start "10" end "14" from "a" named "result2"
    Then convert binary "result1"  to decimal "dec_result1" and check value is "1"
    Then convert binary "result2"  to decimal "B"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "sysTime" to get "t3"
    Then check time "ts_time" equal to "t3"

  @skip_restart
  Scenario: when values of key "CLUSTERID" are same and values of key "INSTANCEID" are different, check the correctness of the self-increment sequence #5
    Given execute single sql in "dble-1" in "user" mode and save resultset in "sysTime"
      | sql              |
      | select sysdate() |
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /INSTANCEID/c INSTANCEID=01
    """
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-2" with sed cmds
    """
    /INSTANCEID/c INSTANCEID=02
    """
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-2" with sed cmds
    """
    /INSTANCEID/c INSTANCEID=03
    """
    Then change start_time to current time "sysTime" in "sequence_distributed_conf.properties" in dble "dble-1"
    Then change start_time to current time "sysTime" in "sequence_distributed_conf.properties" in dble "dble-2"
    Then change start_time to current time "sysTime" in "sequence_distributed_conf.properties" in dble "dble-3"
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
    Then execute sql in "dble-1" in "user" mode
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
    Then get binary range start "15" end "18" from "a" named "result1"
    Then get binary range start "10" end "14" from "a" named "result2"
    Then convert binary "result1"  to decimal "dec_result1" and check value is "1"
    Then convert binary "result2"  to decimal "B"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "sysTime" to get "t3"
    Then check time "ts_time" equal to "t3"
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /INSTANCEID/c INSTANCEID=01
    /CLUSTERID/c CLUSTERID=01
    /START_TIME/c START_TIME=2010-11-04 09:42:54
    """
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-2" with sed cmds
    """
    /INSTANCEID/c INSTANCEID=01
    /CLUSTERID/c CLUSTERID=01
    /START_TIME/c START_TIME=2010-11-04 09:42:54
    """
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-2" with sed cmds
    """
    /INSTANCEID/c INSTANCEID=01
    /CLUSTERID/c CLUSTERID=01
    /START_TIME/c START_TIME=2010-11-04 09:42:54
    """
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
