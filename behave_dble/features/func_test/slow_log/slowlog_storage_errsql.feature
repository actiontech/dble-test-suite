# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/9

Feature: failed sql will not be logged to slow log; successful SQL will be logged to slow log

  Scenario: enable slow log function and execute sql, failed sql will not be logged to slow log; successful SQL will be logged to slow log #1
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="enableSlowLog">1</property>
    <property name="sqlSlowTime">1</property>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                                                                                       | expect                                   | db      |
      | test | 111111 | conn_0 | True    | drop table if exists sharding_4_t1                                                                                                                                                        | success                                  | schema1 |
      | test | 111111 | conn_0 | True    | CREATE TABLE sharding_4_t1(id int(10) unsigned NOT NULL,t_id int(10) unsigned NOT NULL DEFAULT "0",name char(1) NOT NULL DEFAULT "",pad int(11) NOT NULL,PRIMARY KEY (id),KEY k_1 (t_id)) | success                                  | schema1 |
      | test | 111111 | conn_0 | True    | insert into sharding_4_t1 values(1,1,"test_1",1),(2,2,"test_2",2),(3,3,"test_3",4),(4,4,"test_4",3),(5,5,5,1),(6,6,"test6",6)                                                                  | Data too long for column 'name' at row 1 | schema1 |
      | test | 111111 | conn_0 | True    | insert into sharding_4_t1 values(1,1,1,1)                                                                                                                                                 | success                                  | schema1 |
    Then check following " " exist in file "/opt/dble/slowlogs/slow-query.log" in "dble-1"
    """
    CREATE TABLE sharding_4_t1(id int(10) unsigned NOT NULL,t_id int(10) unsigned NOT NULL DEFAULT "0",name char(1) NOT NULL DEFAULT "",pad int(11) NOT NULL,PRIMARY KEY (id),KEY k_1 (t_id))
    insert into sharding_4_t1 values(1,1,1,1)
    """
    Then check following "not" exist in file "/opt/dble/slowlogs/slow-query.log" in "dble-1"
    """
    insert into sharding_4_t1 values(1,1,1,1),(2,2,"test_2",2),(3,3,"test_3",4),(4,4,4,3),(5,5,"test...5",1),(6,6,"test6",6)
    """
    Then check following "not" exist in file "/opt/dble/logs/dble.log" in "dble-1"
    """
    NPE
    """
    Then check following "not" exist in file "/opt/dble/logs/wrapper.log" in "dble-1"
    """
    NPE
    """