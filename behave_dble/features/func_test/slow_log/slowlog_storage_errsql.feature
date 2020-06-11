# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/9
# 2.19.11.0#dble-7846
Feature: failed sql will not be logged to slow log; successful SQL will be logged to slow log

  Scenario: enable slow log function and execute sql, failed sql will not be logged to slow log; successful SQL will be logged to slow log #1
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    a/-DenableSlowLog=1
    a/-DslowLogBaseDir=./slowlogs
    a/-DslowLogBaseName=slow-query
    a/-DflushSlowLogSize=1000
    a/-DsqlSlowTime=1
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                       | expect                                   | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                                                                                                                        | success                                  | schema1 |
      | conn_0 | False   | CREATE TABLE sharding_4_t1(id int(10) unsigned NOT NULL,t_id int(10) unsigned NOT NULL DEFAULT "0",name char(1) NOT NULL DEFAULT "",pad int(11) NOT NULL,PRIMARY KEY (id),KEY k_1 (t_id)) | success                                  | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1,"test_1",1),(2,2,"test_2",2),(3,3,"test_3",4),(4,4,"test_4",3),(5,5,5,1),(6,6,"test6",6)                                                             | Data too long for column 'name' at row 1 | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(1,1,1,1)                                                                                                                                                 | success                                  | schema1 |
    Then check following text exist "Y" in file " /opt/dble/slowlogs/slow-query.log" in host "dble-1"
    """
    CREATE TABLE sharding_4_t1(id int(10) unsigned NOT NULL,t_id int(10) unsigned NOT NULL DEFAULT "0",name char(1) NOT NULL DEFAULT "",pad int(11) NOT NULL,PRIMARY KEY (id),KEY k_1 (t_id))
    insert into sharding_4_t1 values(1,1,1,1)
    """
    Then check following text exist "N" in file " /opt/dble/slowlogs/slow-query.log" in host "dble-1"
    """
    insert into sharding_4_t1 values(1,1,1,1),(2,2,"test_2",2),(3,3,"test_3",4),(4,4,4,3),(5,5,"test...5",1),(6,6,"test6",6)
    """
    Then check following text exist "N" in file " /opt/dble/logs/dble.log" in host "dble-1"
    """
    NPE
    """
    Then check following text exist "N" in file " /opt/dble/logs/wrapper.log" in host "dble-1"
    """
    NPE
    """