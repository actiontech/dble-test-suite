# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2023/02/15  2023/06/21
## case 中的重启dble都是设计过的，每次重启dble是为了内存的释放，修改者移除要注意


  @skip
  #coz DBLE0REQ-2209
Feature:Support MySQL's large package protocol

  Background:delete file , upload file , prepare env

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-Xmx1G/-Xmx4G/g
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=167772160
      s/-XX:MaxDirectMemorySize=1G/-XX:MaxDirectMemorySize=4G/g
      $a -DbufferPoolPageSize=33554432
      """
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """
    Given Restart dble in "dble-1" success

  ## create table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | false   | drop table if exists sing;create table sing (id int,c longblob);truncate table sing                                    | success | schema1 |
      | conn_0 | false   | drop table if exists test;create table test (id int,c longblob);truncate table test                                    | success | schema1 |
      | conn_0 | true    | drop table if exists sharding_4_t1;create table sharding_4_t1 (id int,c longblob);truncate table sharding_4_t1         | success | schema1 |


  Scenario: test "insert" sql about large packet    #1

    ## case 1，shardinguser  tabletype is sharding table sql length 43 ,加上5-6的大包占位符，所以边界值 是 48 或 49
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (0," large data "20*1024*1024" on db "schema1" with user "test"
#    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (7," large data "40*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (1," large data "16*1024*1024-46" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (2," large data "16*1024*1024-47" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (3," large data "16*1024*1024-48" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (4," large data "16*1024*1024-49" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (5," large data "16*1024*1024-50" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (6," large data "16*1024*1024-51" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (1," large data "32*1024*1024-46" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (2," large data "32*1024*1024-47" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (3," large data "32*1024*1024-48" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (4," large data "32*1024*1024-49" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (5," large data "32*1024*1024-50" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sharding_4_t1 (id,c) values (6," large data "32*1024*1024-51" on db "schema1" with user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob);select * from tb1                                        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"
    Given Restart dble in "dble-1" success

     ## case 2，shardinguser  tabletype is global table sql length 34 ,加上5-6的大包占位符，所以边界值 是 39 或 40
    Then connect "dble-1" to execute "insert into test (id,c) values (0," large data "12*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (7," large data "40*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (1," large data "16*1024*1024-37" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (2," large data "16*1024*1024-38" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (3," large data "16*1024*1024-39" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (4," large data "16*1024*1024-40" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (5," large data "16*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (6," large data "16*1024*1024-42" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (1," large data "32*1024*1024-37" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (2," large data "32*1024*1024-38" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (3," large data "32*1024*1024-39" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (4," large data "32*1024*1024-40" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (5," large data "32*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into test (id,c) values (6," large data "32*1024*1024-42" on db "schema1" with user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob);select * from tb1                                        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"
    Given Restart dble in "dble-1" success

     ## case 3，shardinguser  tabletype is sing table sql length 34 ,加上5-6的大包占位符，所以边界值 是 39 或 40
    Then connect "dble-1" to execute "insert into sing (id,c) values (0," large data "12*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (7," large data "40*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (1," large data "16*1024*1024-37" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (2," large data "16*1024*1024-38" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (3," large data "16*1024*1024-39" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (4," large data "16*1024*1024-40" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (5," large data "16*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (6," large data "16*1024*1024-42" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (1," large data "32*1024*1024-37" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (2," large data "32*1024*1024-38" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (3," large data "32*1024*1024-39" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (4," large data "32*1024*1024-40" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (5," large data "32*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "insert into sing (id,c) values (6," large data "32*1024*1024-42" on db "schema1" with user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob);select * from tb1                                        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: test "update" sql about large packet     #2
    ## case 1，shardinguser  tabletype is sharding table sql length 43 ,加上5-6的大包占位符，所以边界值 是 48 或 49
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "12*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "40*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "16*1024*1024-46" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "16*1024*1024-47" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "16*1024*1024-48" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "16*1024*1024-49" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "16*1024*1024-50" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "16*1024*1024-51" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "32*1024*1024-46" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "32*1024*1024-47" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "32*1024*1024-48" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "32*1024*1024-49" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "32*1024*1024-50" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sharding_4_t1 set c = 24 where c = (" large data "32*1024*1024-51" on db "schema1" with user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob);select * from tb1                                        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"
    Given Restart dble in "dble-1" success

     ## case 2，shardinguser  tabletype is global table sql length 34 ,加上5-6的大包占位符，所以边界值 是 39 或 40
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "12*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "40*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "16*1024*1024-37" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "16*1024*1024-38" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "16*1024*1024-39" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "16*1024*1024-40" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "16*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "16*1024*1024-42" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "32*1024*1024-37" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "32*1024*1024-38" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "32*1024*1024-39" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "32*1024*1024-40" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "32*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update test set c = 24 where c = (" large data "32*1024*1024-42" on db "schema1" with user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob);select * from tb1                                        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"
    Given Restart dble in "dble-1" success

     ## case 3，shardinguser  tabletype is sing table sql length 34 ,加上5-6的大包占位符，所以边界值 是 39 或 40
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "12*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "40*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "16*1024*1024-37" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "16*1024*1024-38" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "16*1024*1024-39" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "16*1024*1024-40" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "16*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "16*1024*1024-42" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "32*1024*1024-37" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "32*1024*1024-38" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "32*1024*1024-39" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "32*1024*1024-40" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "32*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "update sing set c = 24 where c = (" large data "32*1024*1024-42" on db "schema1" with user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob);select * from tb1                                        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: test "delete" sql about large packet    #3
    ## case 1，shardinguser  tabletype is sharding table sql length 47 ,加上5-6的大包占位符，所以边界值 是 52 或 53
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "12*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "40*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "16*1024*1024-50" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "16*1024*1024-51" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "16*1024*1024-52" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "16*1024*1024-53" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "16*1024*1024-54" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "16*1024*1024-55" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "32*1024*1024-50" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "32*1024*1024-51" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "32*1024*1024-52" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "32*1024*1024-53" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "32*1024*1024-54" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sharding_4_t1 where id = 1 or c = (" large data "32*1024*1024-55" on db "schema1" with user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob);select * from tb1                                        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"
    Given Restart dble in "dble-1" success

     ## case 2，shardinguser  tabletype is global table sql length 38 ,加上5-6的大包占位符，所以边界值 是 43 或 44
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "12*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "40*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "16*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "16*1024*1024-42" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "16*1024*1024-43" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "16*1024*1024-44" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "16*1024*1024-45" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "16*1024*1024-46" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "32*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "32*1024*1024-42" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "32*1024*1024-43" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "32*1024*1024-44" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "32*1024*1024-45" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from test where id = 1 or c = (" large data "32*1024*1024-46" on db "schema1" with user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob);select * from tb1                                        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"
    Given Restart dble in "dble-1" success

     ## case 3，shardinguser  tabletype is sing table sql length 38 ,加上5-6的大包占位符，所以边界值 是 43 或 44
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "12*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "40*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "16*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "16*1024*1024-42" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "16*1024*1024-43" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "16*1024*1024-44" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "16*1024*1024-45" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "16*1024*1024-46" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "32*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "32*1024*1024-42" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "32*1024*1024-43" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "32*1024*1024-44" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "32*1024*1024-45" on db "schema1" with user "test"
    Then connect "dble-1" to execute "delete from sing where id = 1 or c = (" large data "32*1024*1024-46" on db "schema1" with user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob);select * from tb1                                        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: test "select" sql about large packet    #4
    ## case 1，shardinguser  tabletype is sharding table sql length 46 ,加上5-6的大包占位符，所以边界值 是 51 或 52
    Then connect "dble-1" to execute "select c,id from sharding_4_t1 a where a.c = (" large data "12*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sharding_4_t1 a where a.c = (" large data "40*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sharding_4_t1 a where a.c = (" large data "16*1024*1024-50" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sharding_4_t1 a where a.c = (" large data "16*1024*1024-51" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sharding_4_t1 a where a.c = (" large data "16*1024*1024-52" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sharding_4_t1 a where a.c = (" large data "16*1024*1024-53" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sharding_4_t1 a where a.c = (" large data "32*1024*1024-50" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sharding_4_t1 a where a.c = (" large data "32*1024*1024-51" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sharding_4_t1 a where a.c = (" large data "32*1024*1024-52" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sharding_4_t1 a where a.c = (" large data "32*1024*1024-53" on db "schema1" with user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob);select * from tb1                                        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"
    Given Restart dble in "dble-1" success

     ## case 2，shardinguser  tabletype is global table sql length 37 ,加上5-6的大包占位符，所以边界值 是 43 或 42
    Then connect "dble-1" to execute "select c,id from test a where a.c = (" large data "12*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from test a where a.c = (" large data "40*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from test a where a.c = (" large data "16*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from test a where a.c = (" large data "16*1024*1024-42" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from test a where a.c = (" large data "16*1024*1024-43" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from test a where a.c = (" large data "16*1024*1024-44" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from test a where a.c = (" large data "32*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from test a where a.c = (" large data "32*1024*1024-42" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from test a where a.c = (" large data "32*1024*1024-43" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from test a where a.c = (" large data "32*1024*1024-44" on db "schema1" with user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob);select * from tb1                                        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"
    Given Restart dble in "dble-1" success

     ## case 3，shardinguser  tabletype is sing table sql length 37 ,加上5-6的大包占位符，所以边界值 是 43 或 42
    Then connect "dble-1" to execute "select c,id from sing a where a.c = (" large data "12*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sing a where a.c = (" large data "40*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sing a where a.c = (" large data "16*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sing a where a.c = (" large data "16*1024*1024-42" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sing a where a.c = (" large data "16*1024*1024-43" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sing a where a.c = (" large data "16*1024*1024-44" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sing a where a.c = (" large data "32*1024*1024-41" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sing a where a.c = (" large data "32*1024*1024-42" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sing a where a.c = (" large data "32*1024*1024-43" on db "schema1" with user "test"
    Then connect "dble-1" to execute "select c,id from sing a where a.c = (" large data "32*1024*1024-44" on db "schema1" with user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob);select * from tb1                                        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: test "select" sql -- about response has large packet coz:DBLE0REQ-2096      #5
    ##prepare large packet values
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | false   | drop table if exists test;create table test (id int,c longblob);truncate table test                                    | success | schema1 |
      | conn_0 | false   | insert into test values (0,repeat("x",16*1024*1024)),(1,repeat("x",16*1024*1024-1)),(2,repeat("x",16*1024*1024-2)),(3,repeat("x",16*1024*1024-3)),(4,repeat("x",16*1024*1024-4)),(5,repeat("x",16*1024*1024-5))                        | success | schema1 |
       ## response  16*1024*1024-5的前后是边界
      | conn_0 | false   | insert into sharding_4_t1 values (0,repeat("x",16*1024*1024)),(1,repeat("x",16*1024*1024-1)),(2,repeat("x",16*1024*1024-2)),(3,repeat("x",16*1024*1024-3)),(4,repeat("x",16*1024*1024-4)),(5,repeat("x",16*1024*1024-5))               | success | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values (6,repeat("x",16*1024*1024-6)),(7,repeat("x",16*1024*1024-7)),(8,repeat("x",16*1024*1024-8)),(9,repeat("x",16*1024*1024-9)),(10,repeat("x",16*1024*1024-10))                                          | success | schema1 |
       ## response  32*1024*1024-11的前后是边界
      | conn_0 | false   | insert into sharding_4_t1 values (11,repeat("y",32*1024*1024)),(12,repeat("y",32*1024*1024-3)),(13,repeat("y",32*1024*1024-5)),(14,repeat("y",32*1024*1024-7)),(15,repeat("y",32*1024*1024-9)),(16,repeat("y",32*1024*1024-11))        | success | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values (17,repeat("y",32*1024*1024-13)),(18,repeat("y",32*1024*1024-15)),(19,repeat("y",32*1024*1024-17)),(20,repeat("y",32*1024*1024-19)),(21,repeat("y",32*1024*1024-21))                                  | success | schema1 |
      ## response 其余的大包值
      | conn_0 | true    | insert into sharding_4_t1 values (22,repeat("z",14*1024*1024)),(23,repeat("z",24*1024*1024-7)),(24,repeat("z",40*1024*1024)),(25,repeat("z",repeat("x",16*1024*1024-5)))                                                               | success | schema1 |
      ### select 返回大包

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                     | expect       | db      | timeout |
      | conn_0 | false   | select c from sharding_4_t1 where id = 0                                                                                                                                | length{(1)}  | schema1 | 6,2     |
      | conn_0 | false   | select c from sharding_4_t1 where id = 1                                                                                                                                | length{(1)}  | schema1 |         |
      | conn_0 | false   | select c from sharding_4_t1 where id = 2                                                                                                                                | length{(1)}  | schema1 |         |
      | conn_0 | false   | select c from sharding_4_t1 where id = 3                                                                                                                                | length{(1)}  | schema1 |         |
      | conn_0 | false   | select c from sharding_4_t1 where id = 4                                                                                                                                | length{(1)}  | schema1 |         |
      | conn_0 | false   | select c from sharding_4_t1 where id = 5                                                                                                                                | length{(1)}  | schema1 |         |
      | conn_0 | false   | select c from sharding_4_t1 where id = 6                                                                                                                                | length{(1)}  | schema1 |         |
      | conn_0 | false   | select c from sharding_4_t1 where id = 7                                                                                                                                | length{(1)}  | schema1 |         |
      | conn_0 | false   | select c from sharding_4_t1 where id = 8                                                                                                                                | length{(1)}  | schema1 |         |
      | conn_0 | false   | select c from sharding_4_t1 where id = 9                                                                                                                                | length{(1)}  | schema1 |         |
      | conn_0 | true    | select c from sharding_4_t1 where id = 10                                                                                                                               | length{(1)}  | schema1 |         |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                     | expect       | db      | timeout |
      | conn_0 | false   | select c from sharding_4_t1 where id = 11;select c from sharding_4_t1 where id = 12;select c from sharding_4_t1 where id = 13;select c from sharding_4_t1 where id = 14 | success      | schema1 | 6,2     |
      | conn_0 | false   | select c from sharding_4_t1 where id = 15;select c from sharding_4_t1 where id = 16;select c from sharding_4_t1 where id = 17;select c from sharding_4_t1 where id = 18 | success      | schema1 |         |
      | conn_0 | false   | select c from sharding_4_t1 where id = 19;select c from sharding_4_t1 where id = 20;select c from sharding_4_t1 where id = 21;select c from sharding_4_t1 where id = 22 | success      | schema1 |         |
      | conn_0 | false   | select c from sharding_4_t1 where id = 23                                                                                                                               | length{(1)}  | schema1 |         |
      | conn_0 | false   | select c from sharding_4_t1 where id = 24                                                                                                                               | length{(1)}  | schema1 |         |
      | conn_0 | true    | select c from sharding_4_t1 where id = 25                                                                                                                               | length{(1)}  | schema1 |         |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                     | expect       | db      | timeout |
      | conn_0 | false   | select * from sharding_4_t1 where id in (select a.id from test a right join sharding_4_t1 b on a.id = b.id and a.id > 22)                                               | success      | schema1 | 6,2     |
      | conn_0 | false   | select 2                                                                                                                                                                | success      | schema1 |         |
      | conn_0 | false   | select * from sharding_4_t1 a join test b using(id,c) where a.id=16 or b.id=32;select 1                                                                                 | success      | schema1 |         |
      | conn_0 | false   | /*!dble:shardingNode=dn1*/select * from sharding_4_t1 a join test b using(id,c) where a.id=16 or b.id=32                                                                | success      | schema1 |         |
      | conn_0 | false   | /*!dble:shardingNode=dn1*/select c,id from sharding_4_t1;select id from sharding_4_t1;select * from test                                                                | success      | schema1 |         |

      | conn_0 | true    | drop table if exists test;drop table if exists sharding_4_t1          | success      | schema1 | 5       |

    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: test 多语句组合  #6
    Then connect "dble-1" to execute mulit "begin;update test set c = 24 where c = (" and ");commit" large data "16*1024*1024" on db "schema1" with user "test"
    ###coz issue:DBLE0REQ-2271
#    Then connect "dble-1" to execute mulit "set trace = 1;select * from sing where c <> (select c from test where c = (" and ") or id = 1);show trace" large data "16*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute mulit "begin;/*!dble:shardingNode=dn4*/ delete from sharding_4_t1 where c = (" and ") or id = 1;select 1" large data "16*1024*1024" on db "schema1" with user "test"
    Then connect "dble-1" to execute mulit "select 1; select a.id,b.id from test a join sharding_4_t1 b on a.id=b.id and b.c = " and " or a.id = 1; begin" large data "16*1024*1024" on db "schema1" with user "test"

    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: test Prepared sql    #7
    Then execute large data prepared sql "select id from sharding_4_t1 where id =%s or c =" data "16*1024*1024" with params "(1)" on db "schema1" and user "test"
    Then execute large data prepared sql "select id from sharding_4_t1 where id =%s or c =" data "32*1024*1024" with params "(1)" on db "schema1" and user "test"
    Then execute large data prepared sql "select id from sharding_4_t1 where id =%s or c =" data "40*1024*1024" with params "(1)" on db "schema1" and user "test"

    Then execute large data prepared sql "select id from test where id =%s or c =" data "16*1024*1024" with params "(2)" on db "schema1" and user "test"
    Then execute large data prepared sql "select id from test where id =%s or c =" data "32*1024*1024" with params "(2)" on db "schema1" and user "test"
    Then execute large data prepared sql "select id from test where id =%s or c =" data "40*1024*1024" with params "(2)" on db "schema1" and user "test"

    Then execute large data prepared sql "select id from sing where id =%s or c =" data "16*1024*1024" with params "(3)" on db "schema1" and user "test"
    Then execute large data prepared sql "select id from sing where id =%s or c =" data "32*1024*1024" with params "(3)" on db "schema1" and user "test"
    Then execute large data prepared sql "select id from sing where id =%s or c =" data "40*1024*1024" with params "(3)" on db "schema1" and user "test"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                           | expect  | db      |
      | conn_0 | true    | drop table if exists sing;drop table if exists test;drop table if exists sharding_4_t1        | success | schema1 |
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"