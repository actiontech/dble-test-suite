# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/11/1

Feature: when global sequence with timestamp mode, if system time exceeds 69 years after startup time ,it will report an error

  Scenario: get the binary of the self-increasing id, split id to get the result and compare it with the configuration file
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="mytest_auto_test" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="id" autoIncrement="true"/>
    """
    When Add some data in "sequence_time_conf.properties"
    """
    WORKID=01
    DATAACENTERID=01
    START_TIME=2010-10-01 09:42:54
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists mytest_auto_test                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table mytest_auto_test(id bigint,time char(120)) | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into mytest_auto_test values(curdate())          | success | schema1 |

    Then get resultset of user cmd "select time from mytest_auto_test" named "ts_time"
    Then get resultset of user cmd "select conv(id,10,2) from mytest_auto_test" named "rs"

    Then get id binary named "binary_a" from "rs" and add 0 if binary length less than 64 bits
    Then get binary range start "30" end "34" from "binary_a" named "binary_sub1"
    Then get binary range start "35" end "39" from "binary_a" named "binary_sub2"
    Then get binary range start "0" end "29" from "binary_a" named "binary_sub3"
    Then get binary range start "52" end "63" from "binary_a" named "binary_sub4"
    Then conver binary "binary_sub1"  to decimal "decimal_sub1" and check value is "1"
    Then conver binary "binary_sub2"  to decimal "decimal_sub2" and check value is "1"

    When connect "binary_sub3" and "binary_sub4" to get new binary "binary_sub5"
    Then conver binary "binary_sub5"  to decimal "decimal_sub5"
    Then conver decimal "decimal_sub5" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "2010-10-01 09:42:54" to get "t3"
    Then check time "ts_time" equal to "t3"

  Scenario: get the binary of the self-increasing id, split id to get the result and compare it with the modified configuration file
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="mytest_auto_test" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="id" autoIncrement="true"/>
    """
    When Add some data in "sequence_time_conf.properties"
    """
    WORKID=01
    DATAACENTERID=01
    START_TIME=2010-10-01 09:42:54
    """
    Given Restart dble in "dble-1" success

#    When connect ssh execute cmd "date -s 2019/11/5 13:55:30"
    Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1"
  """
      s/WORKID=01/WORKID=02/
    """
    Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1"
  """
      s/DATAACENTERID=01/DATAACENTERID=31/
    """
    Given update file content "/opt/dble/conf/sequence_time_conf.properties" in "dble-1"
  """
      s/#START_TIME/START_TIME/
      s#2010-10-01 09:42:54#2005-10-01 09:42:54#
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists mytest_auto_test                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table mytest_auto_test(id bigint,time char(120)) | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into mytest_auto_test values(curdate())          | success | schema1 |
    Then get resultset of user cmd "select time from mytest_auto_test" named "ts_time"
    Then get resultset of user cmd "select conv(id,10,2) from mytest_auto_test" named "rs"

    Then get id binary named "binary_a" from "rs" and add 0 if binary length less than 64 bits
    Then get binary range start "30" end "34" from "binary_a" named "binary_sub1"
    Then get binary range start "35" end "39" from "binary_a" named "binary_sub2"
    Then get binary range start "0" end "29" from "binary_a" named "binary_sub3"
    Then get binary range start "52" end "63" from "binary_a" named "binary_sub4"
    Then conver binary "binary_sub1"  to decimal "decimal_sub1" and check value is "31"
    Then conver binary "binary_sub2"  to decimal "decimal_sub2" and check value is "2"

    When connect "binary_sub3" and "binary_sub4" to get new binary "binary_sub5"
    Then conver binary "binary_sub5"  to decimal "decimal_sub5"
    Then conver decimal "decimal_sub5" to datatime "t1"
    Then get datatime "t2" by "t1" minus "1970-01-01"
    Then datatime "t2" plus start_time "2005-10-01 09:42:54" to get "t3"
    Then check time "ts_time" equal to "t3"



