# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/10

Feature: dump file is imported concurrently and check dble is normal

  @skip_restart
  Scenario: 'sysbench' create data, 'mysqldump' backup data, 'split' split dump-file, import shards into nodes and check dble is normal #1
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="sbtest1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="id" autoIncrement="true"/>
    """
    Given Restart dble in "dble-1" success
    When sysbench_cmd parameters(dbName: "schema1" mysqlName: "mysql" num: "100" tableCount: "1" threadCount: "1" intervalCount: "5" cmd: "prepare")
    Then dump database "schema1" from mysql "mysql"
    When sysbench_cmd parameters(dbName: "schema1" mysqlName: "mysql" num: "100" tableCount: "1" threadCount: "1" intervalCount: "5" cmd: "cleanup")
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn | toClose | sql                                      | expect  | db |
      | root | 111111 | new  | true    | split /opt/dump/dump.sql /opt/dump/split | success |    |
    Then get resultset of admin cmd "show @@datanode" named "sql_rs_A"
    Then move dump file to mysql node by "sql_rs_A" and execute
    Then execute admin cmd "reload @@metadata"
    Then get resultset of user cmd "select count(*) from sbtest1" named "sql_rs_B"
    Then assert value of "sql_rs_B" is "100"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                   | expect  | db      |
      | test | 111111 | new  | true    | select * from sbtest1 | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                                         | expect  | db      |
      | test | 111111 | new  | true    | insert into sbtest1 values(1,"test","test") | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                                    | expect  | db      |
      | test | 111111 | new  | true    | update sbtest1 set c="test1" where k=1 | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                           | expect  | db      |
      | test | 111111 | new  | true    | delete from sbtest1 where k=1 | success | schema1 |
