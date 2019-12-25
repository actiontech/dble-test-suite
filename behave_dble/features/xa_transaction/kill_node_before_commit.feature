# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/12/24

Feature: xa_trancation: kill node before trancation commit

  Scenario: begin trancation and insert data , kill one node before trancation commit #1
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}   |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
      | schema.xml | {'tag':'root'} | {'tag':'dataHost'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
       <schema name="schema1" sqlMaxLimit="100">
                <table dataNode="dn1,dn3" name="account" rule="hash-two" />
        </schema>
        <dataNode dataHost="ha_group1" database="db1" name="dn1" />
        <dataNode dataHost="ha_group2" database="db1" name="dn3" />
        <dataHost balance="1" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" switchType="-1" tempReadHostAvailable="1">
                <heartbeat>select user()</heartbeat>
                <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
                </writeHost>
        </dataHost>
        <dataHost balance="1" maxCon="1000" minCon="10" name="ha_group2" slaveThreshold="100" switchType="-1" tempReadHostAvailable="1">
                <heartbeat>select user()</heartbeat>
                <writeHost host="hostS1" password="111111" url="172.100.9.6:3306" user="test" >
                </writeHost>
        </dataHost>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                                 | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists account                                                                                                        | success | schema1 |
      | test | 111111 | conn_0 | False   | create table account (id int,customerid int,accountno varchar(20),amount decimal(10,2),ts timestamp default now())                  | success | schema1 |
      | test | 111111 | conn_0 | False   | set xa=1                                                                                                                            | success | schema1 |
      | test | 111111 | conn_0 | False   | begin                                                                                                                               | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into account (id, customerid, accountno, amount) values (1, 1,'a0301',0),(2,2,'a0601',0), (3,3,'a0301',0),(4,601,'a0601',0); | success | schema1 |
    Then get resultset of user cmd "select * from account" named "rs_A" with connection "conn_0"
    Then check resultset "rs_A" has lines with following column values
      | id-0 | customerid-1 | accountno-2 | amount-3 |
      | 1    | 1            | a0301       | 0.00     |
      | 3    | 3            | a0301       | 0.00     |
      | 2    | 2            | a0601       | 0.00     |
      | 4    | 601          | a0601       | 0.00     |
    Given stop mysql in host "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                   | expect                              | db      |
      | test | 111111 | conn_0 | False   | commit                | Connection                          | schema1 |
      | test | 111111 | conn_0 | False   | select * from account | Transaction error, need to rollback | schema1 |
      | test | 111111 | conn_0 | False   | rollback              | success                             | schema1 |
    Given start mysql in host "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                   | expect      | db      |
      | test | 111111 | conn_0 | False   | select * from account | length{(0)} | schema1 |