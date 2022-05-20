# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/7/20

# DBLE0REQ-1003
Feature: check dble_xa_recover and exception xa transactions

   @restore_xa_recover
   Scenario: check dble_xa_recover table #1
   """
   {'restore_xa_recover':['mysql-master1', 'mysql-master2']}
   """
    # case desc dble_xa_recover
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_xa_recover_1"
      | conn   | toClose | sql                  | db               |
      | conn_0 | False   | desc dble_xa_recover | dble_information |
    Then check resultset "dble_xa_recover_1" has lines with following column values
      | Field-0      | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | dbgroup      | varchar(20) | NO     | PRI    | None     |         |
      | instance     | varchar(20) | NO     | PRI    | None     |         |
      | ip           | varchar(20) | NO     | PRI    | None     |         |
      | port         | int(5)      | NO     |        | None     |         |
      | formatid     | int(11)     | NO     |        | None     |         |
      | gtrid_length | int(11)     | NO     |        | None     |         |
      | bqual_length | int(11)     | NO     |        | None     |         |
      | data         | varchar(20) | NO     |        | None     |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                           | expect           | db               |
      | conn_0 | False   | desc dble_xa_recover          | length{(8)}      | dble_information |
      | conn_0 | False   | select * from dble_xa_recover | length{(0)}      | dble_information |
    # prepare data
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                        |
      | conn_1 | False   | drop database if exists xa_test_db         |
      | conn_1 | False   | create database xa_test_db; use xa_test_db |
      | conn_1 | False   | create table xa_test (id int, code int)    |
      | conn_1 | True    | xa start 'Dble_Server.abcd'; insert into xa_test values(1, 1); xa end 'Dble_Server.abcd'; xa prepare 'Dble_Server.abcd' |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                         |
      | conn_1 | False   | use xa_test_db              |
      | conn_1 | True    | xa start 'Dble_Server.1.db1'; insert into xa_test values(1, 1); xa end 'Dble_Server.1.db1'; xa prepare 'Dble_Server.1.db1' |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                        |
      | conn_2 | False   | drop database if exists xa_test_db         |
      | conn_2 | False   | create database xa_test_db; use xa_test_db |
      | conn_2 | False   | create table xa_test (id int, code int)    |
      | conn_2 | True    | xa start 'host_xa_test'; insert into xa_test values(2, 2); xa end 'host_xa_test'; xa prepare 'host_xa_test' |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                         |
      | conn_2 | False   | use xa_test_db              |
      | conn_2 | True    | xa start 'Dble_Server.1.db1.db2'; insert into xa_test values(2, 2); xa end 'Dble_Server.1.db1.db2'; xa prepare 'Dble_Server.1.db1.db2' |
    # case select * from dble_xa_recover
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_xa_recover_2"
      | conn   | toClose | sql                           | db                |
      | conn_0 | False   | select * from dble_xa_recover | dble_information  |
    Then check resultset "dble_xa_recover_2" has lines with following column values
      | dbgroup-0 | instance-1 | ip-2        | port-3 | formatid-4 | gtrid_length-5 | bqual_length-6 | data-7                |
      | ha_group1 | hostM1     | 172.100.9.5 | 3306   |  1         | 16             | 0              | Dble_Server.abcd      |
      | ha_group1 | hostM1     | 172.100.9.5 | 3306   |  1         | 17             | 0              | Dble_Server.1.db1     |
      | ha_group2 | hostM2     | 172.100.9.6 | 3306   |  1         | 12             | 0              | host_xa_test          |
      | ha_group2 | hostM2     | 172.100.9.6 | 3306   |  1         | 21             | 0              | Dble_Server.1.db1.db2 |
    # case supported select  table limit/order by/where like
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect                                    |
      | conn_0 | False   | use dble_information                                                                   | success                                   |
      | conn_0 | False   | select * from dble_xa_recover limit 5                                                  | length{(4)}                               |
      | conn_0 | False   | select * from dble_xa_recover order by data desc limit 3                               | length{(3)}                               |
      | conn_0 | False   | select * from dble_xa_recover where data in (select common from dble_xa_recover )      | Correlated Sub Queries is not supported   |
      | conn_0 | False   | select * from dble_xa_recover where data > any (select data from dble_xa_recover )     | length{(3)}                               |
      | conn_0 | False   | select * from dble_xa_recover where data like '%xa%'                                   | length{(1)}                               |
      | conn_0 | False   | select data from dble_xa_recover                                                       | length{(4)}                               |
    # case supported select max/min from table
      | conn_0 | False   | select max(data) from dble_xa_recover                                                  | has{(('host_xa_test',),)}                     |
      | conn_0 | False   | select min(data) from dble_xa_recover                                                  | has{(('Dble_Server.1.db1',),)}                 |
    # case supported select field from table
      | conn_0 | False   | select data from dble_xa_recover where instance = 'hostM1'                             | has{(('Dble_Server.abcd',), ('Dble_Server.1.db1',))} |
    # case unsupported update/delete/insert
      | conn_0 | False   | delete from dble_xa_recover where instance='hostM1'                                    | Access denied for table 'dble_xa_recover' |
      | conn_0 | False   | update dble_xa_recover set data='number of requests' where instance='hostM1'           | Access denied for table 'dble_xa_recover' |
      | conn_0 | True    | insert into dble_xa_recover values ('a','b','c')                                       | Access denied for table 'dble_xa_recover' |

    # sleep reason: http://10.186.18.11/jira/browse/DBLE0REQ-1683
    Given sleep "2" seconds

    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                             |
      | conn_1 | False   | xa rollback 'Dble_Server.abcd'  |
      | conn_1 | True    | xa rollback 'Dble_Server.1.db1' |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                 |
      | conn_2 | False   | xa rollback 'host_xa_test'          |
      | conn_2 | True    | xa rollback 'Dble_Server.1.db1.db2' |

  @restore_xa_recover
  Scenario: check xa transactions in mysql #2
    """
    {'restore_xa_recover':['mysql-master1', 'mysql-master2']}
    """
    Given delete file "/opt/dble/xalogs/*.log" on "dble-1"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DinstanceName=1/c -DinstanceName=abc
    """
    Then Restart dble in "dble-1" success
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    The serial number of the xid being used:[[]0[]]
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_1 | false   | drop table if exists sharding_4_t1                               | success | schema1 |
      | conn_1 | false   | create table sharding_4_t1(id int, name varchar(10))             | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_1"
      | conn   | toClose | sql                                                                                   | db               |
      | conn_0 | False   | select remote_port,user,schema,sql,sql_stage,xa_id,entry_id from session_connections  | dble_information |
    Then check resultset "session_connections_1" has lines with following column values
      | remote_port-0 | user-1 | schema-2         | sql-3                                                                                | sql_stage-4        | xa_id-5 | entry_id-6 |
      | 9066          | root   | dble_information | select remote_port,user,schema,sql,sql_stage,xa_id,entry_id from session_connections | Manager connection | -       | 1          |
      | 8066          | test   | schema1          | create table sharding_4_t1(id int, name varchar(10))                                 | Finished           | NULL    | 2          |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_1 | false   | set autocommit=0;set xa=1;begin                                  | success | schema1 |
      | conn_1 | false   | insert into sharding_4_t1 values (1,'name1'),(2,'name2')         | success | schema1 |
      | conn_1 | false   | commit                                                           | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_2"
      | conn   | toClose | sql                                                                                   | db               |
      | conn_0 | True    | select remote_port,user,schema,sql,sql_stage,xa_id,entry_id from session_connections  | dble_information |
    Then check resultset "session_connections_2" has lines with following column values
      | remote_port-0 | user-1 | schema-2         | sql-3                                                                                | sql_stage-4        | xa_id-5             | entry_id-6 |
      | 9066          | root   | dble_information | select remote_port,user,schema,sql,sql_stage,xa_id,entry_id from session_connections | Manager connection | -                   | 1          |
      | 8066          | test   | schema1          | commit                                                                               | Finished           | 'Dble_Server.abc.1' | 2          |
    Then check following text exist "Y" in file "/opt/dble/xalogs/xalog-1.log" in host "dble-1"
      """
      Dble_Server.abc.1
      """
    Given record current dble log "/opt/dble/xalogs/xalog-1.log" line number in "xa_log_1"
    Then Restart dble in "dble-1" success
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_2 | false   | set autocommit=0;set xa=1;begin                                  | success | schema1 |
      | conn_2 | false   | insert into sharding_4_t1 values (3,'name3'),(4,'name4')         | success | schema1 |
      | conn_2 | false   | commit                                                           | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_connections_3"
      | conn   | toClose | sql                                                                                   | db               |
      | conn_0 | False   | select remote_port,user,schema,sql,sql_stage,xa_id,entry_id from session_connections  | dble_information |
    Then check resultset "session_connections_3" has lines with following column values
      | remote_port-0 | user-1 | schema-2         | sql-3                                                                                | sql_stage-4        | xa_id-5             | entry_id-6 |
      | 9066          | root   | dble_information | select remote_port,user,schema,sql,sql_stage,xa_id,entry_id from session_connections | Manager connection | -                   | 1          |
      | 8066          | test   | schema1          | commit                                                                               | Finished           | 'Dble_Server.abc.2' | 2          |
    Then check following text exist "Y" in file "/opt/dble/xalogs/xalog-1.log" after line "xa_log_1" in host "dble-1"
      """
      Dble_Server.abc.2
      """
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                        | expect  | db  |
      | conn_3 | False   | xa start 'Dble_Server.abc123.0'            | success | db1 |
      | conn_3 | False   | select * from sharding_4_t1                | success | db1 |
      | conn_3 | False   | xa end 'Dble_Server.abc123.0'              | success | db1 |
      | conn_3 | True    | xa prepare 'Dble_Server.abc123.0'          | success | db1 |
      | conn_4 | False   | xa start 'Dble_Server.abc.0'               | success | db1 |
      | conn_4 | False   | select * from sharding_4_t1                | success | db1 |
      | conn_4 | False   | xa end 'Dble_Server.abc.0'                 | success | db1 |
      | conn_4 | True    | xa prepare 'Dble_Server.abc.0'             | success | db1 |
      | conn_5 | False   | xa start 'Dble_Server.abc.08'              | success | db1 |
      | conn_5 | False   | select * from sharding_4_t1                | success | db1 |
      | conn_5 | False   | xa end 'Dble_Server.abc.08'                | success | db1 |
      | conn_5 | True    | xa prepare 'Dble_Server.abc.08'            | success | db1 |
      | conn_6 | False   | xa start 'test-xa-1'                       | success | db1 |
      | conn_6 | False   | select * from sharding_4_t1                | success | db1 |
      | conn_6 | False   | xa end 'test-xa-1'                         | success | db1 |
      | conn_6 | True    | xa prepare 'test-xa-1'                     | success | db1 |
      | conn_7 | True    | xa recover                                 | has{((1,20,0,'Dble_Server.abc123.0',),(1,17,0,'Dble_Server.abc.0',),(1,18,0,'Dble_Server.abc.08',),(1,9,0,'test-xa-1'))} | db1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "result_1"
      | conn   | toClose | sql                           | db               |
      | conn_0 | True    | select * from dble_xa_recover | dble_information |
    Then check resultset "result_1" has lines with following column values
      | dbgroup-0 | instance-1 | ip-2        | port-3 | formatid-4 | gtrid_length-5 | bqual_length-6 | data-7                |
      | ha_group1 | hostM1     | 172.100.9.5 | 3306   | 1          | 9              | 0              | test-xa-1             |
      | ha_group1 | hostM1     | 172.100.9.5 | 3306   | 1          | 17             | 0              | Dble_Server.abc.0     |
      | ha_group1 | hostM1     | 172.100.9.5 | 3306   | 1          | 18             | 0              | Dble_Server.abc.08    |
      | ha_group1 | hostM1     | 172.100.9.5 | 3306   | 1          | 20             | 0              | Dble_Server.abc123.0  |
    Then restart dble in "dble-1" failed for
    """
    Suspected residual xa transaction, in the DbInstanceConfig [[]hostName=hostM1, url=172.100.9.5:3306[]], have:
    Dble_Server.abc.08
    Dble_Server.abc.0
    Please clean up according to the actual situation.
    """
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                               |
      | conn_8 | False   | xa rollback 'Dble_Server.abc.08'  |
      | conn_8 | True    | xa rollback 'Dble_Server.abc.0'   |
    Then Restart dble in "dble-1" success
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                        | expect  | db  |
      | conn_3 | False   | xa start 'Dble_Server.abc.2.db1'           | success | db1 |
      | conn_3 | False   | select * from sharding_4_t1                | success | db1 |
      | conn_3 | False   | xa end 'Dble_Server.abc.2.db1'             | success | db1 |
      | conn_3 | True    | xa prepare 'Dble_Server.abc.2.db1'         | success | db1 |
      | conn_4 | False   | xa start 'Dble_Server.abc.20'              | success | db1 |
      | conn_4 | False   | select * from sharding_4_t1                | success | db1 |
      | conn_4 | False   | xa end 'Dble_Server.abc.20'                | success | db1 |
      | conn_4 | True    | xa prepare 'Dble_Server.abc.20'            | success | db1 |
      | conn_5 | False   | xa start 'Dble_Server.abc.2'               | success | db1 |
      | conn_5 | False   | select * from sharding_4_t1                | success | db1 |
      | conn_5 | False   | xa end 'Dble_Server.abc.2'                 | success | db1 |
      | conn_5 | True    | xa prepare 'Dble_Server.abc.2'             | success | db1 |
      | conn_6 | False   | xa start 'Dble_Server.abc.1'               | success | db1 |
      | conn_6 | False   | select * from sharding_4_t1                | success | db1 |
      | conn_6 | False   | xa end 'Dble_Server.abc.1'                 | success | db1 |
      | conn_6 | True    | xa prepare 'Dble_Server.abc.1'             | success | db1 |
      | conn_7 | True    | xa recover                                 | has{((1,21,0,'Dble_Server.abc.2.db1',),(1,18,0,'Dble_Server.abc.20',),(1,17,0,'Dble_Server.abc.2'),(1,17,0,'Dble_Server.abc.1'))} | db1 |
    Given sleep "10" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "result_2"
      | conn   | toClose | sql                           | db               |
      | conn_0 | True    | select * from dble_xa_recover | dble_information |
    Then check resultset "result_2" has lines with following column values
      | dbgroup-0 | instance-1 | ip-2        | port-3 | formatid-4 | gtrid_length-5 | bqual_length-6 | data-7                |
      | ha_group2 | hostM2     | 172.100.9.6 | 3306   | 1          | 17             | 0              | Dble_Server.abc.1     |
      | ha_group2 | hostM2     | 172.100.9.6 | 3306   | 1          | 17             | 0              | Dble_Server.abc.2     |
      | ha_group2 | hostM2     | 172.100.9.6 | 3306   | 1          | 18             | 0              | Dble_Server.abc.20    |
      | ha_group2 | hostM2     | 172.100.9.6 | 3306   | 1          | 21             | 0              | Dble_Server.abc.2.db1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect  | db      |
      | conn_9 | true    | drop table if exists sharding_4_t1  | success | schema1 |
    Then restart dble in "dble-1" failed for
    """
    Suspected residual xa transaction, in the DbInstanceConfig [[]hostName=hostM2, url=172.100.9.6:3306[]], have:
    Dble_Server.abc.2
    Dble_Server.abc.2.db1
    Dble_Server.abc.1
    Dble_Server.abc.20
    Please clean up according to the actual situation.
    """
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                               |
      | conn_8 | False   | xa commit 'Dble_Server.abc.2.db1' |
      | conn_8 | False   | xa commit 'Dble_Server.abc.20'    |
      | conn_8 | False   | xa rollback 'Dble_Server.abc.2'   |
      | conn_8 | True    | xa rollback 'Dble_Server.abc.1'   |
    Then Restart dble in "dble-1" success

  @restore_mysql_service @restore_xa_recover
  Scenario: check xa transaction when the mysql stopped #3
  """
  {'restore_mysql_service':{'mysql-master2':{'start_mysql':1}}, 'restore_xa_recover':['mysql-master1', 'mysql-master2']}
  """
    Given delete file "/opt/dble/xalogs/*.log" on "dble-1"
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  | db      |
      | conn_1 | false   | drop table if exists sharding_4_t1               | success | schema1 |
      | conn_1 | false   | create table sharding_4_t1(id int)               | success | schema1 |
      | conn_1 | false   | set autocommit=0;set xa=1;begin                  | success | schema1 |
      | conn_1 | false   | insert into sharding_4_t1 values (1),(2),(3),(4) | success | schema1 |
      | conn_1 | true    | commit                                           | success | schema1 |
    Given stop mysql in host "mysql-master2"
    Then restart dble in "dble-1" failed for
    """
    java.lang.RuntimeException: Fail to recover xa when dble start, please check backend mysql.
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    When prepare execute 'XA RECOVER' in dbInstance[[]name=hostM2,disabled=false,maxCon=1000,minCon=10[]], check it's isAlive is false
    When prepare execute 'XA COMMIT 'Dble_Server.1.1.db1'' in dbInstance[[]name=hostM2,disabled=false,maxCon=1000,minCon=10[]] , check it's isAlive is false
    """
    Given start mysql in host "mysql-master2"
    Then Restart dble in "dble-1" success
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    When prepare execute 'XA RECOVER' in dbInstance[[]name=hostM2,disabled=false,maxCon=1000,minCon=10[]], check it's isAlive is false
    When prepare execute 'XA COMMIT 'Dble_Server.1.1.db1'' in dbInstance[[]name=hostM2,disabled=false,maxCon=1000,minCon=10[]] , check it's isAlive is false
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    XA COMMIT 'Dble_Server.1.1.db1'
    XA RECOVER to con:BackendConnection
    """
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect  | db      |
      | conn_2 | true    | drop table if exists sharding_4_t1  | success | schema1 |