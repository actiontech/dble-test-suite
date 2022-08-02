# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/11/6

#2.19.11.0#dble-7889
Feature: when global sequence with timestamp mode, if system time exceeds 69 years after startup time ,it will error #1

  Scenario: when "insert time" greater than "sequenceStartTime" and less than "sequenceStartTime + 69years", check the correctness of the self-increment sequence #1
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="mytest_auto_test" shardingNode="dn1,dn2,dn3,dn4" incrementColumn="id" shardingColumn="id" function="hash-four" />
    """
    Given execute single sql in "dble-1" in "user" mode and save resultset in "sysTime"
      | sql              |
      | select sysdate() |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
        s/instanceId=.*/instanceId=33/
    """
    Then add sequenceStartTime to current time "sysTime" in "cluster.cnf" in dble "dble-1"
#    Then change sequenceStartTime to current time "sysTime" in "cluster.cnf" in dble "dble-1"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | db      |
      | conn_0 | False   | drop table if exists mytest_auto_test                   | schema1 |
      | conn_0 | False   | create table mytest_auto_test(id bigint,time char(120)) | schema1 |
      | conn_0 | True    | insert into mytest_auto_test values(curdate())          | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "ts_time"
      | sql                               | db      |
      | select time from mytest_auto_test | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs"
      | sql                                        | db      |
      | select conv(id,10,2) from mytest_auto_test | schema1 |
    Then get id binary named "binary_a" from "rs" and add 0 if binary length less than 64 bits
    Then get binary range start "30" end "34" from "binary_a" named "binary_sub1"
    Then get binary range start "35" end "39" from "binary_a" named "binary_sub2"
    Then get binary range start "0" end "29" from "binary_a" named "binary_sub3"
    Then get binary range start "52" end "63" from "binary_a" named "binary_sub4"
    Then convert binary "binary_sub1"  to decimal "decimal_sub1" and check value is "1"
    Then convert binary "binary_sub2"  to decimal "decimal_sub2" and check value is "1"

    When connect "binary_sub3" and "binary_sub4" to get new binary "binary_sub5"
    Then convert binary "binary_sub5"  to decimal "decimal_sub5"
    Then convert decimal "decimal_sub5" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "sysTime" to get "t3"
    Then check time "ts_time" equal to "t3"
    Then execute sql in "dble-1" in "user" mode
      | sql                                   | expect  | db      |
      | drop table if exists mytest_auto_test | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
        s/instanceId=.*/instanceId=33/
    """

  @restore_sys_time @skip
  Scenario: when "system time" less than "sequenceStartTime + 69years", execute insert sql will error
    note: this scenerio has issue: https://github.com/actiontech/dble/issues/1665  #2
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="mytest_auto_test" shardingNode="dn1,dn2,dn3,dn4" incrementColumn="id" shardingColumn="id" function="hash-four" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_0 | False   | drop table if exists mytest_auto_test                   | success | schema1 |
      | conn_0 | True    | create table mytest_auto_test(id bigint,time char(120)) | success | schema1 |
    When connect ssh execute cmd "date -s 2009/01/01"
    Then execute sql in "dble-1" in "user" mode
      | sql                                    | expect                                          | db      |
      | insert into mytest_auto_test values(1) | Clock moved backwards.  Refusing to generate id | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | sql                                     | expect  | db      |
      | drop table if exists mytest_auto_test   | success | schema1 |

  Scenario: change configuration file, check the correctness of the self-increment sequence #3
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="mytest_auto_test" shardingNode="dn1,dn2,dn3,dn4" incrementColumn="id" shardingColumn="id" function="hash-four" />
    """
    Given execute single sql in "dble-1" in "user" mode and save resultset in "sysTime"
      | sql              |
      | select sysdate() |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
        s/instanceId=.*/instanceId=994/
    """
    Then add sequenceStartTime to current time "sysTime" in "cluster.cnf" in dble "dble-1"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_0 | False   | drop table if exists mytest_auto_test                   | success | schema1 |
      | conn_0 | False   | create table mytest_auto_test(id bigint,time char(120)) | success | schema1 |
      | conn_0 | True    | insert into mytest_auto_test values(curdate())          | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "ts_time"
      | sql                               | db      |
      | select time from mytest_auto_test | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs"
      | sql                                        | db      |
      | select conv(id,10,2) from mytest_auto_test | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "id_value"
      | sql                                        | db      |
      | select id from mytest_auto_test | schema1 |
    Then get id binary named "binary_a" from "rs" and add 0 if binary length less than 64 bits
    Then get binary range start "30" end "34" from "binary_a" named "binary_sub1"
    Then get binary range start "35" end "39" from "binary_a" named "binary_sub2"
    Then get binary range start "0" end "29" from "binary_a" named "binary_sub3"
    Then get binary range start "52" end "63" from "binary_a" named "binary_sub4"
    Then convert binary "binary_sub1"  to decimal "decimal_sub1" and check value is "31"
    Then convert binary "binary_sub2"  to decimal "decimal_sub2" and check value is "2"

    When connect "binary_sub3" and "binary_sub4" to get new binary "binary_sub5"
    Then convert binary "binary_sub5"  to decimal "decimal_sub5"
    Then convert decimal "decimal_sub5" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "sysTime" to get "t3"
    Then check time "ts_time" equal to "t3"
    Then execute sql in "dble-1" in "user" mode
      | sql                                   | expect  | db      |
      | drop table if exists mytest_auto_test | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
        s/instanceId=.*/instanceId=33/
    """
