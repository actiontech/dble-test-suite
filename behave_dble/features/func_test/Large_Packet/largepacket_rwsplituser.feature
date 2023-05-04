# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 20223/02/15
## case 中的重启dble都是设计过的，每次重启dble是为了内存的释放，修改者移除要注意


Feature:Support MySQL's large package protocol

   Background:delete file , upload file , prepare env
    Given delete file "/opt/LargePacket_rw.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"
    Given upload file "./features/steps/LargePacket_rw.py" to "dble-1" success
    Given upload file "./features/steps/SQLContext.py" to "dble-1" success

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-Xmx1G/-Xmx8G/g
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=167772160
      s/-XX:MaxDirectMemorySize=1G/-XX:MaxDirectMemorySize=8G/g
      $a -DidleTimeout=180000
      $a -DbufferPoolPageSize=33554432
      """
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" />
          <dbInstance name="hostS3" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10"  />
      </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
      """
    Given Restart dble in "dble-1" success
     ## create table
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                            | expect  | db      | timeout |
      | rw1  | 111111 | conn_0 | true    | drop table if exists test1;create table test1 (id int,c longblob);truncate table test1         | success | db1     | 6,2     |
      | rw1  | 111111 | conn_0 | true    | drop table if exists tb1;create table tb1 (id int,c longblob)                                  | success | db1     |         |


#   @restore_mysql_config
   Scenario: test "insert" sql about large packet the sql is "insert into table (id,c) values (x,大包)"   #1
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4194304},'mysql-slave1':{'max_allowed_packet':4194304},'mysql-master2':{'max_allowed_packet':4194304}}}
    """
    Given create folder content "/opt/dble/logs/insert" in "dble-1"
    Given execute oscmd "python3 /opt/LargePacket_rw.py >/opt/dble/logs/insert/rw1.txt" on "dble-1"
    Then check following text exists in file "/opt/dble/logs/insert/rw1.txt" in host "dble-1" with "8" times
      """
      insert into test1
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """


#   @restore_mysql_config
   Scenario: test "update" sql about large packet the sql is "update table set c="大包"    #2
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4194304},'mysql-slave1':{'max_allowed_packet':4194304},'mysql-master2':{'max_allowed_packet':4194304}}}
    """
    Given create folder content "/opt/dble/logs/update" in "dble-1"

    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/insert into {0}({1},{2}) values ({3},/update {0} set {1} =/g
      s/.format(self.table, cols_keys, target_col_key, cols_values)/.format(self.table,target_col_key)/g
      s/)'\''/ '\''/g
      """
    Given execute oscmd "python3 /opt/LargePacket_rw.py >/opt/dble/logs/update/rw2.txt" on "dble-1"
    Then check following text exists in file "/opt/dble/logs/update/rw2.txt" in host "dble-1" with "8" times
      """
      update test1 set c =\"aaaaaaaaaaaaaa
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """


#   @restore_mysql_config
   Scenario: test "delete" sql about large packet the sql is "delete from table where c="大包" or id=7"   #3
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4194304},'mysql-slave1':{'max_allowed_packet':4194304},'mysql-master2':{'max_allowed_packet':4194304}}}
    """
    Given create folder content "/opt/dble/logs/delete" in "dble-1"

    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/insert into {0}({1},{2}) values ({3},/delete from {0} where {1} =/g
      s/.format(self.table, cols_keys, target_col_key, cols_values)/.format(self.table,target_col_key)/g
      s/)'\''/ or id = 7 '\''/g
      """

    Given execute oscmd "python3 /opt/LargePacket_rw.py >/opt/dble/logs/delete/rw3.txt" on "dble-1"
    Then check following text exists in file "/opt/dble/logs/delete/rw3.txt" in host "dble-1" with "8" times
      """
      delete from test1 where c =\"aaaaaaaaaaaaaa
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """


#   @restore_mysql_config
   Scenario: test "select" sql about large packet the sql is "select id from table where c="大包"    #4
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4194304},'mysql-slave1':{'max_allowed_packet':4194304},'mysql-master2':{'max_allowed_packet':4194304}}}
    """
    Given create folder content "/opt/dble/logs/select" in "dble-1"

    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/insert into {0}({1},{2}) values ({3},/select id from {0} where id = 7 or {1} =/g
      s/.format(self.table, cols_keys, target_col_key, cols_values)/.format(self.table, target_col_key)/g
      s/)'\''/'\''/g
      """

    Given execute oscmd "python3 /opt/LargePacket_rw.py >/opt/dble/logs/select/rw4.txt" on "dble-1"
    Then check following text exists in file "/opt/dble/logs/select/rw4.txt" in host "dble-1" with "8" times
      """
      select id from test1 where id = 7 or c =\"aaaaaaaaaaaaaaaaaaaaaaaaaaa
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """


#   @restore_mysql_config
   Scenario: test "select" sql -- about response has large packet coz:DBLE0REQ-2096      #5
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4194304},'mysql-slave1':{'max_allowed_packet':4194304},'mysql-master2':{'max_allowed_packet':4194304}}}
    """
#    prepare large packet values
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                    | expect  | db  |
      | rw1 | 111111 | conn_0 | false   | drop table if exists sharding_4_t1;create table sharding_4_t1 (id int,c longblob);truncate table sharding_4_t1          | success | db1 |
      | rw1 | 111111 | conn_0 | false   | insert into test1 values (0,repeat("x",16*1024*1024)),(1,repeat("x",16*1024*1024-1)),(2,repeat("x",16*1024*1024-2)),(3,repeat("x",16*1024*1024-3)),(4,repeat("x",16*1024*1024-4)),(5,repeat("x",16*1024*1024-5))               | success | db1 |
       ## response  16*1024*1024-5的前后是边界,response里面还有其他占位，包头和包体
      | rw1 | 111111 | conn_0 | false   | insert into sharding_4_t1 values (0,repeat("x",16*1024*1024)),(1,repeat("x",16*1024*1024-1)),(2,repeat("x",16*1024*1024-2)),(3,repeat("x",16*1024*1024-3)),(4,repeat("x",16*1024*1024-4)),(5,repeat("x",16*1024*1024-5))               | success | db1 |
      | rw1 | 111111 | conn_0 | false   | insert into sharding_4_t1 values (6,repeat("x",16*1024*1024-6)),(7,repeat("x",16*1024*1024-7)),(8,repeat("x",16*1024*1024-8)),(9,repeat("x",16*1024*1024-9)),(10,repeat("x",16*1024*1024-10))                                          | success | db1 |
       ## response  32*1024*1024-11的前后是边界
      | rw1 | 111111 | conn_0 | false   | insert into sharding_4_t1 values (11,repeat("y",32*1024*1024)),(12,repeat("y",32*1024*1024-3)),(13,repeat("y",32*1024*1024-5)),(14,repeat("y",32*1024*1024-7)),(15,repeat("y",32*1024*1024-9)),(16,repeat("y",32*1024*1024-11))        | success | db1 |
      | rw1 | 111111 | conn_0 | false   | insert into sharding_4_t1 values (17,repeat("y",32*1024*1024-13)),(18,repeat("y",32*1024*1024-15)),(19,repeat("y",32*1024*1024-17)),(20,repeat("y",32*1024*1024-19)),(21,repeat("y",32*1024*1024-21))                                  | success | db1 |
      ## response 其余的大包值
      | rw1 | 111111 | conn_0 | true    | insert into sharding_4_t1 values (22,repeat("z",14*1024*1024)),(23,repeat("z",24*1024*1024-7)),(24,repeat("z",40*1024*1024)),(25,repeat("z",repeat("x",16*1024*1024-5)))                                                               | success | db1 |
    Given Restart dble in "dble-1" success
      ##### select from largepacket response
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                                                                    | expect       | db  | timeout |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 0                                                                                                                                | length{(1)}  | db1 | 6,2     |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 1                                                                                                                                | length{(1)}  | db1 |         |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 2                                                                                                                                | length{(1)}  | db1 |         |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 3                                                                                                                                | length{(1)}  | db1 |         |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 4                                                                                                                                | length{(1)}  | db1 |         |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 5                                                                                                                                | length{(1)}  | db1 |         |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 6                                                                                                                                | length{(1)}  | db1 |         |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 7                                                                                                                                | length{(1)}  | db1 |         |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 8                                                                                                                                | length{(1)}  | db1 |         |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 9                                                                                                                                | length{(1)}  | db1 |         |
      | rw1 | 111111 | conn_0 | true    | select c from sharding_4_t1 where id = 10                                                                                                                               | length{(1)}  | db1 |         |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                                                                    | expect       | db  | timeout |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 11;select c from sharding_4_t1 where id = 12;select c from sharding_4_t1 where id = 13;select c from sharding_4_t1 where id = 14 | success      | db1 | 6,2     |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 15;select c from sharding_4_t1 where id = 16;select c from sharding_4_t1 where id = 17;select c from sharding_4_t1 where id = 18 | success      | db1 |         |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 19;select c from sharding_4_t1 where id = 20;select c from sharding_4_t1 where id = 21;select c from sharding_4_t1 where id = 22 | success      | db1 |         |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 23                                                                                                                               | length{(1)}  | db1 |         |
      | rw1 | 111111 | conn_0 | false   | select c from sharding_4_t1 where id = 24                                                                                                                               | length{(1)}  | db1 |         |
      | rw1 | 111111 | conn_0 | true    | select c from sharding_4_t1 where id = 25                                                                                                                               | length{(1)}  | db1 |         |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                                                                    | expect       | db  | timeout |
      | rw1 | 111111 | conn_0 | false   | select * from sharding_4_t1 where id in (select a.id from test1 a right join sharding_4_t1 b on a.id = b.id and a.id > 22)                                              | success      | db1 | 6,2     |
      | rw1 | 111111 | conn_0 | false   | select 2                                                                                                                                                                | success      | db1 |         |
      | rw1 | 111111 | conn_0 | false   | select * from sharding_4_t1 a join test1 b using(id,c) where a.id=16 or b.id=32;select 1                                                                                | success      | db1 |         |
      | rw1 | 111111 | conn_0 | false   | /*!dble:db_type=master*/select * from sharding_4_t1 a join test1 b using(id,c) where a.id=16 or b.id=32                                                                 | success      | db1 |         |
      | rw1 | 111111 | conn_0 | true    | drop table if exists test1;drop table if exists sharding_4_t1       | success      | db1 | 5       |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """


#   @restore_mysql_config
   Scenario: test hint  and  mulit sql    #6
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4194304},'mysql-slave1':{'max_allowed_packet':4194304},'mysql-master2':{'max_allowed_packet':4194304}}}
    """
    Given create folder content "/opt/dble/logs/mulit" in "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | rw1  | 111111 | conn_0 | false   | drop table if exists sharding_4_t1;create table sharding_4_t1 (id int,c longblob);truncate table sharding_4_t1         | success | db1     |
      | rw1  | 111111 | conn_0 | true    | insert into sharding_4_t1 values (0,repeat("x",16*1024*1024)),(1,repeat("x",16*1024*1024-1)),(2,repeat("x",16*1024*1024-2)),(3,repeat("x",16*1024*1024-3)),(4,repeat("x",16*1024*1024-4)),(5,repeat("x",16*1024*1024-5))               | success | db1 |

    ##### /*!dble:db_type=master*/insert into table(id,c) values (7,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/insert into {0}({1},{2}) values ({3},/\/*!dble:db_type=master*\/insert into {0}({1},{2}) values ({3},/g
      """
    Given execute oscmd "python3 /opt/LargePacket_rw.py >/opt/dble/logs/mulit/insert.txt" on "dble-1"
    Then check following text exists in file "/opt/dble/logs/mulit/insert.txt" in host "dble-1" with "8" times
      """
      db_type=master
      insert into test1
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """
    Given Restart dble in "dble-1" success

    ##### /*!dble:db_type=slave*/update table set c=" " where id =7
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/dble:db_type=master/dble:db_type=slave/g
      s/insert into {0}({1},{2}) values ({3},/update {0} set {1}=/g
      s/.format(self.table, cols_keys, target_col_key, cols_values)/.format(self.table,target_col_key)/g
      s/)'\''/ where {0}={1}'\''.format(cols_keys,cols_values)/g
      """
    Given update file content "/opt/LargePacket_rw.py" in "dble-1" with sed cmds
      """
      s/test1/sharding_4_t1/g
      """
    Given execute oscmd "python3 /opt/LargePacket_rw.py >/opt/dble/logs/mulit/update.txt" on "dble-1"
    Then check following text exists in file "/opt/dble/logs/mulit/update.txt" in host "dble-1" with "8" times
      """
      db_type=slave
      update sharding_4_t1 set
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """
    Given Restart dble in "dble-1" success

    #####  select 1;update table set c=" " where id =7
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/\/\*\!dble:db_type=slave\*\/update/select 1;update/g
      """
    Given execute oscmd "python3 /opt/LargePacket_rw.py >/opt/dble/logs/mulit/update2.txt" on "dble-1"
    Then check following text exists in file "/opt/dble/logs/mulit/update2.txt" in host "dble-1" with "8" times
      """
      select 1
      update sharding_4_t1 set
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """
    Given Restart dble in "dble-1" success

    #####   select c from sharding_4_t1;delete from table where c="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/select 1;update {0} set {1}=/select c from sharding_4_t1;delete from {0} where {1}=/g
      s/where {0}={1}'\''.format(cols_keys,cols_values)/or {0}={1}'\''.format(cols_keys,cols_values)/g
      """
    Given execute oscmd "python3 /opt/LargePacket_rw.py >/opt/dble/logs/mulit/delete.txt" on "dble-1"
    Then check following text exists in file "/opt/dble/logs/mulit/delete.txt" in host "dble-1" with "8" times
      """
      select c from sharding_4_t1
      delete from sharding_4_t1 where
      """
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                               | expect  | db  |
      | rw1  | 111111 | conn_1 | true    | drop table if exists test1;drop table if exists sharding_4_t1                     | success | db1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """


#   @restore_mysql_config
   Scenario: test Prepared sql    #7
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4194304},'mysql-slave1':{'max_allowed_packet':4194304},'mysql-master2':{'max_allowed_packet':4194304}}}
    """
    Given create folder content "/opt/dble/logs/prepared" in "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                   | expect  | db  |
      | rw1 | 111111 | conn_0 | false   | drop table if exists sharding_4_t1;create table sharding_4_t1 (id int,c longblob)      | success | db1 |
      | rw1 | 111111 | conn_0 | true    | insert into sharding_4_t1 values (7,repeat("x",7*1024*1024)),(7,repeat("x",16*1024*1024)),(7,repeat("x",20*1024*1024)),(7,repeat("x",32*1024*1024))            | success | db1 |


      ### PREPARE stmt1 FROM 'select c from table where id = ? and c = ';SET @1 = 7;EXECUTE stmt1 USING @1;DEALLOCATE PREPARE stmt1;
     Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/pre = '\''insert/# pre = '\''inser/g
      s/post = '\''\"/# post = '\''\"/g
      s/#pre = '\''PREPARE /pre= '\''PREPARE /g
      s/#post /post /g
      """

    Given execute oscmd "python3 /opt/LargePacket_rw.py >/opt/dble/logs/prepared/select.txt" on "dble-1"
    Then check following text exists in file "/opt/dble/logs/prepared/select.txt" in host "dble-1" with "8" times
      """
      PREPARE stmt1 FROM
      select c from test1 where id = ? and c =
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """
    Given Restart dble in "dble-1" success
      ### PREPARE stmt1 FROM 'select a.id,b.id from table a join sharding_4_t1 b on a.id=b.id and a.id= ? or b.c = ';SET @1 = 7;EXECUTE stmt1 USING @1;DEALLOCATE PREPARE stmt1;
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/select c from {0} where id = ? and {1}/select a.id,b.id from {0} a join sharding_4_t1 b on a.id=b.id and a.id= ? or b.{1}/g
      """
    Given execute oscmd "python3 /opt/LargePacket_rw.py >/opt/dble/logs/prepared/select1.txt" on "dble-1"
    Then check following text exists in file "/opt/dble/logs/prepared/select1.txt" in host "dble-1" with "8" times
      """
      PREPARE stmt1 FROM
      select a.id,b.id from test1 a join sharding_4_t1 b on a.id=b.id and a.id= ? or b.c
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """
    Given Restart dble in "dble-1" success
      ### PREPARE stmt1 FROM 'select id,c from sharding_4_t1 group by id,c having id >= ? or c ';SET @1 = 7;EXECUTE stmt1 USING @1;DEALLOCATE PREPARE stmt1;
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/select a.id,b.id from {0} a join sharding_4_t1 b on a.id=b.id and a.id= ? or b.{1}/select id,c from {0} group by id,c having id >= ? or {1}/g
      """
    Given execute oscmd "python3 /opt/LargePacket_rw.py >/opt/dble/logs/prepared/select2.txt" on "dble-1"
    Then check following text exists in file "/opt/dble/logs/prepared/select2.txt" in host "dble-1" with "8" times
      """
      PREPARE stmt1 FROM
      select id,c from test1 group by id,c having id
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                               | expect  | db  |
      | rw1  | 111111 | conn_0 | true    | drop table if exists sharding_4_t1;drop table if exists test1     | success | db1 |

    Given delete file "/opt/LargePacket_rw.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"