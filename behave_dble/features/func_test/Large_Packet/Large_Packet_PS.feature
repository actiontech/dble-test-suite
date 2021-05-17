# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/4/2

@skip
Feature:Support MySQL's large package protocol about 'ps protocol'

  Background:delete file and upload file
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"
    Given upload file "./features/steps/LargePacket.py" to "dble-1" success
    Given upload file "./features/steps/SQLContext.py" to "dble-1" success

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-Xmx1G/-Xmx12G/g
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=41943040
      """
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """
    Given Restart dble in "dble-1" success

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="sing1" shardingNode="dn2" />
        <globalTable name="global" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      """
    Then execute admin cmd "reload @@config"

    #prepare largepacket  #sing1 insert 16M/32M   #global insert 14M   #sharding_4_t1 insert 20M/16M/32M/14M
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                            | expect  | db      |
      | conn_0 | false   | drop table if exists sing1                                                                                                                                     | success | schema1 |
      | conn_0 | false   | drop table if exists global                                                                                                                                    | success | schema1 |
      | conn_0 | false   | drop table if exists sharding_4_t1                                                                                                                             | success | schema1 |
      | conn_0 | false   | create table sing1 (id int,name varchar(20),c longblob)                                                                                                        | success | schema1 |
      | conn_0 | false   | create table global (id int,name varchar(20),c longblob)                                                                                                       | success | schema1 |
      | conn_0 | false   | create table sharding_4_t1 (id int,name varchar(20),c longblob)                                                                                                | success | schema1 |
      | conn_0 | false   | insert into sing1 values (7,7,repeat("x",16*1024*1024)),(8,8,repeat("x",32*1024*1024))                                                                         | success | schema1 |
      | conn_0 | false   | insert into global values (7,7,repeat("x",14*1024*1024))                                                                                                       | success | schema1 |
      | conn_0 | true    | insert into sharding_4_t1 values (7,7,repeat("x",14*1024*1024)),(5,5,repeat("x",32*1024*1024)) ,(6,6,repeat("x",20*1024*1024)) ,(8,8,repeat("x",16*1024*1024)) | success | schema1 |

  Scenario: test 'ps protocol' about large packet  ---- Simple query   #1

    #change insert sql to select, select name from sharding_4_t1 where id=? and c='largepacket'
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/14\*1024\*1024/g
      s/sbtest2/sharding_4_t1/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/\"drop table if/# \"drop table if/g
      s/\"create table {0}/# \"create table {0}/g
      s/insert into {0}({1},{2}) values ({3},/select name from {0} where {1}=7 and {2} =/g
      s/.format(self.table, cols_keys, target_col_key, cols_values)/.format(self.table, cols_keys, target_col_key)/g
      s/)'\''/'\''/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/14\*1024\*1024/32\*1024\*1024/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/select name from {0} where {1}=7 and {2} =/select name from {0} where {1}=5 and {2} =/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024/20\*1024\*1024/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/select name from {0} where {1}=5 and {2} =/select name from {0} where {1}=6 and {2} =/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/20\*1024\*1024/16\*1024\*1024/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/select name from {0} where {1}=6 and {2} =/select name from {0} where {1}=8 and {2} =/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    # change insert sql to select, select name from global where id=? and c='largepacket'
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/14\*1024\*1024/g
      s/sharding_4_t1/global/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/select name from {0} where {1}=8 and {2} =/select name from {0} where {1}=7 and {2} =/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    # change insert sql to select, select name from sing1 where id=? and c='largepacket'
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/14\*1024\*1024/16\*1024\*1024/g
      s/global/sing1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/select name from {0} where {1}=7 and {2} =/select name from {0} where {1}=8 and {2} =/g
      """
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/32\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect  | db      |
      | conn_0 | false   | drop table if exists sing1                 | success | schema1 |
      | conn_0 | false   | drop table if exists global                | success | schema1 |
      | conn_0 | true    | drop table if exists sharding_4_t1         | success | schema1 |


   Scenario: test 'ps protocol' about large packet  ---- complex query   #2
    # select g.id,s.id from gloabl g join sharding_4_t1 s on g.id=s.id and s.name=? or s.c='largepacket'
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/14\*1024\*1024/g
      s/sbtest2/sharding_4_t1/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/\"drop table if/# \"drop table if/g
      s/\"create table {0}/# \"create table {0}/g
      s/insert into {0}({1},{2}) values ({3},/select g.id,s.id from global g join {0} s on g.id = s.id and s.name =7 or s.c=/g
      s/.format(self.table, cols_keys, target_col_key, cols_values)/.format(self.table)/g
      s/)'\''/'\''/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/14\*1024\*1024/32\*1024\*1024/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/select g.id,s.id from global g join {0} s on g.id = s.id and s.name =7 or s.c=/select g.id,s.id from global g join {0} s on g.id = s.id and s.name =5 or s.c=/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given Restart dble in "dble-1" success
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024/20\*1024\*1024/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/select g.id,s.id from global g join {0} s on g.id = s.id and s.name =5 or s.c=/select g.id,s.id from global g join {0} s on g.id = s.id and s.name =6 or s.c=/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/20\*1024\*1024/16\*1024\*1024/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/select g.id,s.id from global g join {0} s on g.id = s.id and s.name =6 or s.c=/select g.id,s.id from sing1 g join {0} s on g.id = s.id and s.name =8 or s.c=/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect  | db      |
      | conn_0 | false   | drop table if exists sing1                 | success | schema1 |
      | conn_0 | false   | drop table if exists global                | success | schema1 |
      | conn_0 | true    | drop table if exists sharding_4_t1         | success | schema1 |


   Scenario: test 'ps protocol' about large packet  ---- broadcast query   #3
    #change insert sql to select, select id,c from sharding_4_t1 group by id,c having id>=? or c='largepacket'
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/sbtest2/sharding_4_t1/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/\"drop table if/# \"drop table if/g
      s/\"create table {0}/# \"create table {0}/g
      s/insert into {0}({1},{2}) values ({3},/select id,c from {0} group by id,c having {1}>=5 or {2} =/g
      s/.format(self.table, cols_keys, target_col_key, cols_values)/.format(self.table, cols_keys, target_col_key)/g
      s/)'\''/'\''/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    # change insert sql to select, select id,c from global group by id,c having id>=? or c='largepacket'
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/sharding_4_t1/global/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    # change insert sql to select, select id,c from sing1 group by id,c having id>=? or c='largepacket'
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/global/sing1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect  | db      |
      | conn_0 | false   | drop table if exists sing1                 | success | schema1 |
      | conn_0 | false   | drop table if exists global                | success | schema1 |
      | conn_0 | true    | drop table if exists sharding_4_t1         | success | schema1 |


  Scenario: test 'Multi-sentence' about large packet  ---- Multi-sentence query   #4
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/17\*1024\*1024/g
      s/sbtest2/global/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/\"drop table if/# \"drop table if/g
      s/\"create table {0}/# \"create table {0}/g
      s/insert into {0}({1},{2}) values ({3},/set names utf8mb4;set @a=20,@b=21;insert into {0}({1},name,{2}) values (@a,1,20),(@b,2,21),(22,3,22),(23,4,23),({3},5,/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/17\*1024\*1024/20\*1024\*1024/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/set names utf8mb4;set @a=20,@b=21;insert into {0}({1},name,{2}) values (@a,1,20),(@b,2,21),(22,3,22),(23,4,23),({3},5,/set @a=1,@b=2;insert into global values(@a,1,11),(@b,2,22);select g.id,s.id from sharding_4_t1 s join {0} g on g.id = s.id and s.name =7 or g.c=/g
      s/.format(self.table, cols_keys, target_col_key, cols_values)/.format(self.table)/g
      s/)'\''/'\''/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given Restart dble in "dble-1" success
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/20\*1024\*1024/22\*1024\*1024/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/set @a=1,@b=2;insert into global values(@a,1,11),(@b,2,22);select g.id,s.id from sharding_4_t1 s join {0} g on g.id = s.id and s.name =7 or g.c=/set @a=3,@b=10;insert into {0} values(@a,1,11),(@b,2,22);select id,c from {0} group by id,c having {1}>=5 or {2} =/g
      s/.format(self.table)/.format(self.table, cols_keys, target_col_key)/g

      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect  | db      |
      | conn_0 | false   | drop table if exists sing1                 | success | schema1 |
      | conn_0 | false   | drop table if exists global                | success | schema1 |
      | conn_0 | true    | drop table if exists sharding_4_t1         | success | schema1 |