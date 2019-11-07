# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/11/6

Feature: when global sequence with zookeeper mode, if system time exceeds 17 years after startup time ,it will report an error

  @skip_restart
  Scenario: get the binary of the self-increasing id, split id to get the result and compare it with the configuration #1
    Given reset dble registered nodes in zk
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="mytest_auto_test" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="id" autoIncrement="true"/>
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="sequnceHandlerType">3</property>
    """
    Then start dble in order
    Then add some data in "sequence_distributed_conf.properties" in dble "dble-1"
    """
    INSTANCEID=zk
    CLUSTERID=01
    #START_TIME=2010-11-04 09:42:54
    """
    Then add some data in "sequence_distributed_conf.properties" in dble "dble-2"
    """
    INSTANCEID=zk
    CLUSTERID=02
    #START_TIME=2010-11-04 09:42:54
    """
    Then add some data in "sequence_distributed_conf.properties" in dble "dble-3"
    """
    INSTANCEID=zk
    CLUSTERID=03
    #START_TIME=2010-11-04 09:42:54
    """
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists mytest_auto_test                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table mytest_auto_test(id bigint,time char(120)) | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into mytest_auto_test values(curdate())          | success | schema1 |
    Then get resultset of user cmd "select time from mytest_auto_test" named "ts_time"
    Then get resultset of user cmd "select conv(id,10,2) from mytest_auto_test" named "rs_id"
    Then get id binary named "a" from "rs_id" and add 0 if binary length less than 64 bits
    Then get binary range start "15" end "18" from "a" named "result1"
    Then get binary range start "10" end "14" from "a" named "result2"
    Then convert binary "result1"  to decimal "dec_rs1" and check value is "1"
    Then convert binary "result2"  to decimal "A"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "2010-11-04 09:42:54" to get "t3"
    Then check time "ts_time" equal to "t3"

    Then execute sql in "dble-2" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists mytest_auto_test                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table mytest_auto_test(id bigint,time char(120)) | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into mytest_auto_test values(curdate())          | success | schema1 |
    Then get result of user cmd "select time from mytest_auto_test" named "ts_time" in dble "dble-2"
    Then get result of user cmd "select conv(id,10,2) from mytest_auto_test" named "rs_id" in dble "dble-2"
    Then get id binary named "a" from "rs_id" and add 0 if binary length less than 64 bits
    Then get binary range start "15" end "18" from "a" named "result1"
    Then get binary range start "10" end "14" from "a" named "result2"
    Then convert binary "result1"  to decimal "dec_result1" and check value is "2"
    Then convert binary "result2"  to decimal "B"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "2010-11-04 09:42:54" to get "t3"
    Then check time "ts_time" equal to "t3"

  @skip_restart
  Scenario: modify the system time, if system time is less than "start time", insertSql will report error #2
    Then get resultset of user cmd "select sysdate()" named "curTime"
    When connect ssh execute cmd "date -s 2009/01/01"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                    | expect                                          | db      |
      | test | 111111 | conn_0 | True    | insert into mytest_auto_test values(1) | Clock moved backwards.  Refusing to generate id | schema1 |
    Then revert to current time by "curTime"

  @skip_restart
  Scenario: modify properties, make sure values of key "CLUSTERID" are different.
     get the binary of the self-increasing id, split id to get the result and compare it with the configuration #3

    Given update file content "/opt/dble/conf/sequence_distributed_conf.properties" in "dble-1"
     """
      s/CLUSTERID=01/CLUSTERID=04/
    """
    Given update file content "/opt/dble/conf/sequence_distributed_conf.properties" in "dble-1"
     """
      s/#START_TIME/START_TIME/
      s#2010-11-04 09:42:54#2015-11-04 09:42:54#
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists mytest_auto_test                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table mytest_auto_test(id bigint,time char(120)) | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into mytest_auto_test values(curdate())          | success | schema1 |
    Then get resultset of user cmd "select time from mytest_auto_test" named "ts_time"
    Then get resultset of user cmd "select conv(id,10,2) from mytest_auto_test" named "rs_id"
    Then get id binary named "a" from "rs_id" and add 0 if binary length less than 64 bits
    Then get binary range start "15" end "18" from "a" named "result1"
    Then get binary range start "10" end "14" from "a" named "result2"
    Then convert binary "result1"  to decimal "dec_rs1" and check value is "4"
    Then convert binary "result2"  to decimal "A"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "2015-11-04 09:42:54" to get "t3"
    Then check time "ts_time" equal to "t3"

  @skip_restart
  Scenario: modify properties, make sure values of key "INSTANCEID" and "CLUSTERID" is not different.
      get the binary of the self-increasing id, split id to get the result and compare it with the configuration #4
    Then add some data in "sequence_distributed_conf.properties" in dble "dble-1"
    """
    INSTANCEID=zk
    CLUSTERID=01
    START_TIME=2015-11-04 09:42:54
    """
    Then add some data in "sequence_distributed_conf.properties" in dble "dble-2"
    """
    INSTANCEID=zk
    CLUSTERID=01
    START_TIME=2015-11-04 09:42:54
    """
    Then add some data in "sequence_distributed_conf.properties" in dble "dble-3"
    """
    INSTANCEID=zk
    CLUSTERID=01
    START_TIME=2015-11-04 09:42:54
    """
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists mytest_auto_test                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table mytest_auto_test(id bigint,time char(120)) | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into mytest_auto_test values(curdate())          | success | schema1 |
    Then get resultset of user cmd "select time from mytest_auto_test" named "ts_time"
    Then get resultset of user cmd "select conv(id,10,2) from mytest_auto_test" named "rs_id"
    Then get id binary named "a" from "rs_id" and add 0 if binary length less than 64 bits
    Then get binary range start "15" end "18" from "a" named "result1"
    Then get binary range start "10" end "14" from "a" named "result2"
    Then convert binary "result1"  to decimal "dec_rs1" and check value is "1"
    Then convert binary "result2"  to decimal "A"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "2015-11-04 09:42:54" to get "t3"
    Then check time "ts_time" equal to "t3"

    Then execute sql in "dble-2" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists mytest_auto_test                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table mytest_auto_test(id bigint,time char(120)) | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into mytest_auto_test values(curdate())          | success | schema1 |
    Then get result of user cmd "select time from mytest_auto_test" named "ts_time" in dble "dble-2"
    Then get result of user cmd "select conv(id,10,2) from mytest_auto_test" named "rs_id" in dble "dble-2"
    Then get id binary named "a" from "rs_id" and add 0 if binary length less than 64 bits
    Then get binary range start "15" end "18" from "a" named "result1"
    Then get binary range start "10" end "14" from "a" named "result2"
    Then convert binary "result1"  to decimal "dec_result1" and check value is "1"
    Then convert binary "result2"  to decimal "B"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "2015-11-04 09:42:54" to get "t3"
    Then check time "ts_time" equal to "t3"

  @skip_restart
  Scenario: modify properties, make sure values of key "INSTANCEID" is not different.
      get the binary of the self-increasing id, split id to get the result and compare it with the configuration #5
    Then add some data in "sequence_distributed_conf.properties" in dble "dble-1"
    """
    INSTANCEID=01
    CLUSTERID=01
    START_TIME=2015-11-04 09:42:54
    """
    Then add some data in "sequence_distributed_conf.properties" in dble "dble-2"
    """
    INSTANCEID=02
    CLUSTERID=01
    START_TIME=2015-11-04 09:42:54
    """
    Then add some data in "sequence_distributed_conf.properties" in dble "dble-3"
    """
    INSTANCEID=03
    CLUSTERID=01
    START_TIME=2015-11-04 09:42:54
    """
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists mytest_auto_test                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table mytest_auto_test(id bigint,time char(120)) | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into mytest_auto_test values(curdate())          | success | schema1 |
    Then get result of user cmd "select time from mytest_auto_test" named "ts_time" in dble "dble-2"
    Then get result of user cmd "select conv(id,10,2) from mytest_auto_test" named "rs_id" in dble "dble-2"
    Then get id binary named "a" from "rs_id" and add 0 if binary length less than 64 bits
    Then get binary range start "15" end "18" from "a" named "result1"
    Then get binary range start "10" end "14" from "a" named "result2"
    Then convert binary "result1"  to decimal "dec_result1" and check value is "1"
    Then convert binary "result2"  to decimal "B"
    Then get binary range start "25" end "63" from "a" named "b"
    Then convert binary "b"  to decimal "c"
    Then convert decimal "c" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "2015-11-04 09:42:54" to get "t3"
    Then check time "ts_time" equal to "t3"