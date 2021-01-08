# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/1/7

Feature:Support MySQL's large package protocol



  @skip @restore_mysql_service
  Scenario: test dble's maxPacketSize and mysql's max_allowed_packet #1
    """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1},'mysql-master2':{'start_mysql':1}}}
    """
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"
    Given upload file "./features/steps/LargePacket.py" to "dble-1" success
    Given upload file "./features/steps/SQLContext.py" to "dble-1" success

    #set dble.log level "info" , maxPacketSize=8M
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 4M
      """
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 4M
      """
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=8388608
      """
    Given Restart dble in "dble-1" success
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect               | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('8388608',),)} | dble_information |

    #dble accpect largepacket > 8M
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/sbtest2/test/g
      """
    Given execute linux command in "dble-1" and contains exception "Got a packet bigger than 'max_allowed_packet' bytes"
      """
      python /opt/LargePacket.py
      """
    # global table "test"  will route master1: dn1,dn3 and master2:dn2,dn4
    Then check general log in host "mysql-master1" has "create table test(id int,c longblob)" occured "==2" times
    Then check general log in host "mysql-master2" has "create table test(id int,c longblob)" occured "==2" times
    Then check general log in host "mysql-master1" has not "insert into test(id,"
    Then check general log in host "mysql-master2" has not "insert into test(id,"

    #set mysql max_allowed_packet differ dble's max_allowed_packet
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 8M
      """
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 17M
      """
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=16777216
      """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('16777216',),)} | dble_information |
    Then check general log in host "mysql-master1" has "set global max_allowed_packet=16778240"
    Then check general log in host "mysql-master2" has not "set global max_allowed_packet=16778240"
    Given turn off general log in "mysql-master1"
    Given turn off general log in "mysql-master2"
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"

  @skip
  Scenario: test "insert" sql #2
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"
    Given upload file "./features/steps/LargePacket.py" to "dble-1" success
    Given upload file "./features/steps/SQLContext.py" to "dble-1" success
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="test2" shardingNode="dn2" />
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=167772160
      """
    Given Restart dble in "dble-1" success
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """

    #prepare largepacket 16M-2,the insert sql length 39b, 16M-2=16777175+39
    #select length
    #test1 tabletpye is nosharding
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/16\*1024\*1024-2/g
      s/sbtest2/test1/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from test1 where length(c)>16777175   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test1 where length(c)=16777175   | has{((7,),)} | schema1  |
    #nosharingtable route dn5
    Then check general log in host "mysql-master1" has "insert into test1(id,c) values (7,\"aaaaaaaaaaa"
    Then check general log in host "mysql-master2" has not "insert into test1(id,c) values (7,\"aaaaaaaaaaa"

    #prepare largepacket 16M-1,the insert sql length 39b, 16M-1=16777176+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-2/16\*1024\*1024-1/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from test1 where length(c)>16777176   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test1 where length(c)=16777176   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test1(id,c) values (7,\"aaaaaaaaaaa" occured "==2" times

    #prepare largepacket 16M,the insert sql length 39b, 16M=16777177+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-1/16\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from test1 where length(c)>16777177   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test1 where length(c)=16777177   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test1(id,c) values (7,\"aaaaaaaaaaa" occured "==3" times

    #prepare largepacket 16M+1,the insert sql has 39b, 16M+1=16777178+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/16\*1024\*1024+1/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect       | db       |
      | conn_0 | false   | select id from test1 where length(c)>16777178   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test1 where length(c)=16777178   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test1(id,c) values (7,\"aaaaaaaaaaa" occured "==4" times

    #prepare largepacket 16M+2,the insert sql length 39b, 16M+2=16777179+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+1/16\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from test1 where length(c)>16777179   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test1 where length(c)=16777179   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test1(id,c) values (7,\"aaaaaaaaaaa" occured "==5" times


    #prepare largepacket 20M,the insert sql length 39b, 20M=20971481+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+2/20\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from test1 where length(c)>20971481   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test1 where length(c)=20971481   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test1(id,c) values (7,\"aaaaaaaaaaa" occured "==6" times


    #prepare largepacket 32M-4,the insert sql length 39b, 32M-4=33554389+39
    #test2 tabletpye is sing
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/20\*1024\*1024/32\*1024\*1024-4/g
      s/test1/test2/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from test2 where length(c)>33554389   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test2 where length(c)=33554389   | length{(1)}  | schema1  |
    #singtable route dn2
    Then check general log in host "mysql-master2" has "insert into test2(id,c) values (7,\"aaaaaaaaaaa"
    Then check general log in host "mysql-master1" has not "insert into test2(id,c) values (7,\"aaaaaaaaaaa"

    #prepare largepacket 32M-2,the insert sql length 39b, 32M-2=33554391+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-4/32\*1024\*1024-2/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from test2 where length(c)>33554391   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test2 where length(c)=33554391   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "insert into test2(id,c) values (7,\"aaaaaaaaaaa" occured "==2" times

    #prepare largepacket 32M,the insert sql length 39b, 32M=33554393+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-2/32\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from test2 where length(c)>33554393   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test2 where length(c)=33554393   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "insert into test2(id,c) values (7,\"aaaaaaaaaaa" occured "==3" times

    #prepare largepacket 32M+2,the insert sql length 39b, 32M+2=33554395+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024/32\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from test2 where length(c)>33554395   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test2 where length(c)=33554395   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "insert into test2(id,c) values (7,\"aaaaaaaaaaa" occured "==4" times

    #prepare largepacket 32M+4,the insert sql length 39b, 32M+4=33554397+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024+2/32\*1024\*1024+4/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from test2 where length(c)>33554397   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test2 where length(c)=33554397   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "insert into test2(id,c) values (7,\"aaaaaaaaaaa" occured "==5" times

    #prepare largepacket 40M,the insert sql length 39b, 40M=41943001+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024+4/40\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from test2 where length(c)>41943001   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test2 where length(c)=41943001   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "insert into test2(id,c) values (7,\"aaaaaaaaaaa" occured "==6" times

    Given turn off general log in "mysql-master1"
    Given turn off general log in "mysql-master2"
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"

  @skip
  Scenario: test "update" sql #3
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext2.py" on "dble-1"
    Given delete file "/opt/SQLContext2.pyc" on "dble-1"
    Given upload file "./features/steps/LargePacket.py" to "dble-1" success
    Given upload file "./features/steps/SQLContext2.py" to "dble-1" success
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="test2" shardingNode="dn2" />
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=167772160
      """
    Given Restart dble in "dble-1" success
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """

    #prepare largepacket 16M-2,the update sql length 42b, 16M-2=16777172+42
    #select length
    #sharding_2_t1 tabletype is sharding
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/SQLContext/SQLContext2/g
      s/16\*1024\*1024/16\*1024\*1024-2/g
      s/sbtest2/sharding_2_t1/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>16777172   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=16777172   | has{((8,),)} | schema1  |
    #id=8,route dn1
    Then check general log in host "mysql-master1" has "update sharding_2_t1 set c=\"aaaaaa"
    Then check general log in host "mysql-master2" has not "update sharding_2_t1 set c=\"aaaaaa"

    #prepare largepacket 16M-1,the update sql length 42b, 16M-1=16777173+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-2/16\*1024\*1024-1/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>16777173   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=16777173   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "update sharding_2_t1 set c=\"aaaaaa" occured "==2" times

    #prepare largepacket 16M,the update sql length 42b, 16M=16777174+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-1/16\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>16777174   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=16777174   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "update sharding_2_t1 set c=\"aaaaaa" occured "==3" times

    #prepare largepacket 16M+1,the update sql length 42b, 16M+1=16777175+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/16\*1024\*1024+1/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>16777175   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=16777175   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "update sharding_2_t1 set c=\"aaaaaa" occured "==4" times

    #prepare largepacket 16M+2,the update sql length 42b, 16M+2=16777176+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+1/16\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>16777176   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=16777176   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "update sharding_2_t1 set c=\"aaaaaa" occured "==5" times

    #prepare largepacket 20M,the update sql length 42b, 20M=20971478+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+2/20\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>20971478   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=20971478   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "update sharding_2_t1 set c=\"aaaaaa" occured "==6" times


    #prepare largepacket 32M-4,the update sql length 42b, 32M-4=33554386+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/20\*1024\*1024/32\*1024\*1024-4/g
      s/sharding_2_t1/sharding_4_t1/g
      """
    Given update file content "/opt/SQLContext2.py" in "dble-1" with sed cmds
      """
      s/values (8,8)/values (9,9)/g
      s/cols_values = 8/cols_values = 9/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_4_t1 where length(c)>33554386   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_4_t1 where length(c)=33554386   | length{(1)}  | schema1  |
    #id=9,route dn2
    Then check general log in host "mysql-master2" has "update sharding_4_t1 set c=\"aaaaaa"
    Then check general log in host "mysql-master1" has not "update sharding_4_t1 set c=\"aaaaaa"

    #prepare largepacket 32M-2,the update sql length 42b, 32M-2=33554388+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-4/32\*1024\*1024-2/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_4_t1 where length(c)>33554388   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_4_t1 where length(c)=33554388   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "update sharding_4_t1 set c=\"aaaaaa" occured "==2" times

    #prepare largepacket 32M,the update sql length 42b, 32M=33554390+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-2/32\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_4_t1 where length(c)>33554390   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_4_t1 where length(c)=33554390   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "update sharding_4_t1 set c=\"aaaaaa" occured "==3" times

    #prepare largepacket 32+2M,the update sql length 42b, 32M+2=33554392+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024/32\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_4_t1 where length(c)>33554392   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_4_t1 where length(c)=33554392   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "update sharding_4_t1 set c=\"aaaaaa" occured "==4" times

    #prepare largepacket 32+4M,the update sql length 42b, 32M+4=33554394+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024+2/32\*1024\*1024+4/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_4_t1 where length(c)>33554394   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_4_t1 where length(c)=33554394   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "update sharding_4_t1 set c=\"aaaaaa" occured "==5" times

    #prepare largepacket 40M,the update sql length 42b, 40M=41942998+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024+4/40\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_4_t1 where length(c)>41942998   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_4_t1 where length(c)=41942998   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "update sharding_4_t1 set c=\"aaaaaa" occured "==6" times

    Given turn off general log in "mysql-master1"
    Given turn off general log in "mysql-master2"
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext2.py" on "dble-1"
    Given delete file "/opt/SQLContext2.pyc" on "dble-1"



    @skip_restart
  Scenario: test "select" sql #4
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"
    Given upload file "./features/steps/LargePacket.py" to "dble-1" success
    Given upload file "./features/steps/SQLContext.py" to "dble-1" success
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="test2" shardingNode="dn2" />
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=167772160
      """
    Given Restart dble in "dble-1" success
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """

    #prepare largepacket
    # noshardingtable:test1   sharidngtable:sharding_2_t1,sharding_4_t1  singtable:test2

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/sbtest2/test1/g
      s/# sqlContext3/sqlContext3/g
      s/# sqlContext4/sqlContext4/g
      s/# sqlContext5/sqlContext5/g

      s/# large_packet_test(16\*1024\*1024, conn, sqlContext3)/large_packet_test(16\*1024\*1024, conn, sqlContext3)/g
      s/# large_packet_test(16\*1024\*1024, conn, sqlContext4)/large_packet_test(16\*1024\*1024, conn, sqlContext4)/g
      s/# large_packet_test(16\*1024\*1024, conn, sqlContext5)/large_packet_test(16\*1024\*1024, conn, sqlContext5)/g
      """
#    Given execute linux command in "dble-1"
#      """
#      python /opt/LargePacket.py
#      """





