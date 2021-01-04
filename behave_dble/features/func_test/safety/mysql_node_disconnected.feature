# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/4/16
Feature: #mysql node disconnected,check the change of dble
  # Enter feature description here
  @restore_mysql_service
  Scenario: # only one mysql node and it was disconnected    #1
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml|{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml       |{'tag':'root'}   | {'tag':'dbGroup'}  |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                |
      | conn_0 | False   | create database if not exists da1  |
      | conn_0 | True    | create database if not exists da2  |
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="da1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group1" database="da2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "Reload @@config_all"
    Given stop mysql in host "mysql-master1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                   | expect                                                                                                                                |
      | conn_0 | False   | dryrun                | hasStr{Get Vars from backend failed,Maybe all backend MySQL can't connected}                                                          |
      | conn_0 | True    | reload @@config_all   | Reload config failure.The reason is Can't get variables from any dbInstance, because all of dbGroup can't connect to MySQL correctly  |
    Then restart dble in "dble-1" failed for
    """
    Can't get variables from data node
    """
    Given start mysql in host "mysql-master1"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                   | expect                                                                         |
      | conn_0 | False   | dryrun                | hasNoStr{Get Vars from backend failed,Maybe all backend MySQL can't connected} |
      | conn_0 | True    | reload @@config_all   | success                                                                        |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                        | db      |
      | conn_0 | False   | drop table if exists test  | schema1 |
      | conn_0 | True    | create table test(id int)  | schema1 |

  @restore_mysql_service
  Scenario: # some of the backend nodes was disconnected   #2
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="test_table" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
    """
    Then execute admin cmd "Reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | db      |
      | conn_0 | False   | drop table if exists test_table         | schema1 |
      | conn_0 | True    | create table test_table(id int,pad int) | schema1 |
    Given stop mysql in host "mysql-master1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                 | expect                                                                                      |
      | conn_0 | False   | dryrun              | hasStr{shardingNode[dn3] has no available primary dbinstance,The table in this shardingNode has not checked} |
      | conn_0 | True    | reload @@config_all | there are some dbInstance connection failed                                                |
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect               | db      |
      | conn_0 | False   | insert into test_table values(1,3)    | success              | schema1 |
      | conn_0 | True    | insert into test_table values(2,4)    | error totally whack  | schema1 |
    Given start mysql in host "mysql-master1"
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | db      |
      | conn_0 | False   | insert into test_table values(1,3) | schema1 |
      | conn_0 | True    | insert into test_table values(2,4) | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                   | expect                                                                                        |
      | conn_0 | False   | dryrun                | hasNoStr{shardingNode[dn3] has no available primary dbinstance,The table in this shardingNode has not checked} |
      | conn_0 | True    | reload @@config_all   | success                                                                                       |

  @restore_mysql_service
  Scenario: # some of the backend nodes was disconnected in the course of a transaction    #3
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="test_table" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
    """
    Then execute admin cmd "Reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                  | db      |
      | conn_0 | False   | drop table if exists test_table                      | schema1 |
      | conn_0 | False   | create table test_table(id int,pad int)              | schema1 |
      | conn_0 | False   | insert into test_table values(1,1),(2,2),(3,3),(4,4) | schema1 |
      | conn_0 | False   | begin                                                | schema1 |
      | conn_0 | False   | update test_table set pad=1                          | schema1 |
    Given stop mysql in host "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql     | expect      | db      |
      | conn_0 | True    | commit  | Connection  | schema1 |
    Given start mysql in host "mysql-master1"
    Given sleep "30" seconds
    Then execute sql in "dble-1" in "user" mode
      | sql                      | db      |
      | select * from test_table | schema1 |


  # ---the case is no need anymore for new feature on 5.6.29-dble-3.20.05.99-3ddaae7379f6c4e128d47de58ae085dcdb5aa55c-20200612021000 dble Server

#  Scenario: # Sending a statement on a transaction to an uncreated physical database   from issue:1144 author:maofei  #4
#    Then execute sql in "mysql-master1"
#      | sql                          |
#      | drop database if exists db3  |
#    Then execute admin cmd "Reload @@config_all -r"
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose  | sql                     | expect                                      | db      |
#      | conn_0 | False    | set xa=on               | success                                     | schema1 |
#      | conn_0 | False    | begin                   | success                                     | schema1 |
#      | conn_0 | False    | update test11 set pad=1 | Unknown database 'db3'                      | schema1 |
#      | conn_0 | False    | commit                  | Transaction error, need to rollback.Reason  | schema1 |
#      | conn_0 | False    | rollback                | success                                     | schema1 |
#    Then execute sql in "mysql-master1"
#      | sql                                 |
#      | create database if not exists db3   |
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                        | expect  | db      |
#      | conn_0 | True    | create table if not exists test11(id int)  | success | schema1 |



