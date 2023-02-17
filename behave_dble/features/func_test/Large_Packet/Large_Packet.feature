# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/1/7


Feature:Support MySQL's large package protocol

  Background:delete file and upload file
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"
    Given upload file "./features/steps/LargePacket.py" to "dble-1" success
    Given upload file "./features/steps/SQLContext.py" to "dble-1" success


   @restore_mysql_config
   Scenario: test dble's maxPacketSize and mysql's max_allowed_packet #1
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':8388608},'mysql-master2':{'max_allowed_packet':8388608}}}
    """
    #set dble.log level "info" , maxPacketSize=5M
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 6M
      """
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 6M
      """
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-Xmx1G/-Xmx4G/g
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=7340032
      """
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('7340032B',),)} | dble_information |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                              | expect                                    |
      | conn_1 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '7341056'),)} |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                              | expect                                    |
      | conn_2 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '7341056'),)} |


    #dble accpect largepacket > 8M
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/sbtest2/test/g
      """
    #_mysql_exceptions.OperationalError: (1153, "Got a packet bigger than 'max_allowed_packet' bytes")       # DBLE0REQ-960
     ## Packet for query is too large (16777219 > 7340032).You can change maxPacketSize value in bootstrap.cnf  #DBLE0REQ-2004
    Given execute linux command in "dble-1" and contains exception "Packet for query is too large (16777219 > 7340032).You can change maxPacketSize value in bootstrap.cnf"
      """
      python3 /opt/LargePacket.py
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
      | conn   | toClose | sql                                                                              | expect                 | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('16777216B',),)} | dble_information |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                              | expect                                     |
      | conn_1 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '17825792'),)} |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                              | expect                                     |
      | conn_2 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '16778240'),)} |
    # 16777216+1024
    Then check general log in host "mysql-master1" has "set global max_allowed_packet=16778240"
    Then check general log in host "mysql-master2" has not "set global max_allowed_packet=16778240"
    Given turn off general log in "mysql-master1"
    Given turn off general log in "mysql-master2"


   Scenario: test "insert" sql about large packet#2
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="sing1" shardingNode="dn2" />
        <globalTable name="global" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-Xmx1G/-Xmx4G/g
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=167772160
      s/-XX:MaxDirectMemorySize=1G/-XX:MaxDirectMemorySize=2G/g
      """
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """
    Given Restart dble in "dble-1" success


    #prepare largepacket 16M-2,the insert sql length 39b, 16M-2=16777175+39
    #select length('insert into test1(id,c) values (7,"")')
    #test1 tabletpye is nosharding
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/16\*1024\*1024-2/g
      s/sbtest2/test1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
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
      python3 /opt/LargePacket.py
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
      python3 /opt/LargePacket.py
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
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
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
      python3 /opt/LargePacket.py
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
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from test1 where length(c)>20971481   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from test1 where length(c)=20971481   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test1(id,c) values (7,\"aaaaaaaaaaa" occured "==6" times


    #prepare largepacket 32M-4,the insert sql length 39b, 32M-4=33554389+39
    #sing1 tabletpye is sing1
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/20\*1024\*1024/32\*1024\*1024-4/g
      s/test1/sing1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from sing1 where length(c)>33554389   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sing1 where length(c)=33554389   | length{(1)}  | schema1  |
    #singtable route dn2
    Then check general log in host "mysql-master2" has "insert into sing1(id,c) values (7,\"aaaaaaaaaaa"
    Then check general log in host "mysql-master1" has not "insert into sing1(id,c) values (7,\"aaaaaaaaaaa"

    #prepare largepacket 32M-2,the insert sql length 39b, 32M-2=33554391+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-4/32\*1024\*1024-2/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from sing1 where length(c)>33554391   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sing1 where length(c)=33554391   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "insert into sing1(id,c) values (7,\"aaaaaaaaaaa" occured "==2" times

    #prepare largepacket 32M,the insert sql length 39b, 32M=33554393+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-2/32\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from sing1 where length(c)>33554393   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sing1 where length(c)=33554393   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "insert into sing1(id,c) values (7,\"aaaaaaaaaaa" occured "==3" times

    #prepare largepacket 32M+2,the insert sql length 39b, 32M+2=33554395+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024/32\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from sing1 where length(c)>33554395   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sing1 where length(c)=33554395   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "insert into sing1(id,c) values (7,\"aaaaaaaaaaa" occured "==4" times

    #prepare largepacket 32M+4,the insert sql length 39b, 32M+4=33554397+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024+2/32\*1024\*1024+4/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from sing1 where length(c)>33554397   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sing1 where length(c)=33554397   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "insert into sing1(id,c) values (7,\"aaaaaaaaaaa" occured "==5" times

    #prepare largepacket 40M,the insert sql length 39b, 40M=41943001+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024+4/40\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from sing1 where length(c)>41943001   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sing1 where length(c)=41943001   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "insert into sing1(id,c) values (7,\"aaaaaaaaaaa" occured "==6" times


    #global tabletpye is global
    #prepare largepacket 40M,the insert sql length 40b, 40M=41943000+40
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/sing1/global/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect       | db       |
      | conn_0 | false   | select id from global where length(c)>41943000   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from global where length(c)=41943000   | length{(1)}  | schema1  |
    #global route dn1-4
    Then check general log in host "mysql-master2" has "insert into global(id,c) values (7,\"aaaaaaaaaaa" occured "==2" times
    Then check general log in host "mysql-master1" has "insert into global(id,c) values (7,\"aaaaaaaaaaa" occured "==2" times

    #sharding_2_t1 tabletpye is sharding
    #prepare largepacket 20M,the insert sql length 47b, 20M=20971473+47
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/global/sharding_2_t1/g
      s/40\*1024\*1024/20\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>20971473   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=20971473   | length{(1)}  | schema1  |

    Given turn off general log in "mysql-master1"
    Given turn off general log in "mysql-master2"


   Scenario: test "update" sql #3
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="sing1" shardingNode="dn2" />
        <globalTable name="global" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-Xmx1G/-Xmx4G/g
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=167772160
      s/-XX:MaxDirectMemorySize=1G/-XX:MaxDirectMemorySize=2G/g
      """
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """
    Given Restart dble in "dble-1" success


    #prepare largepacket 16M-2,the update sql length 42b, 16M-2=16777172+42
    #select length('update sharding_2_t1 set c="" where id=7')
    #sharding_2_t1 tabletype is sharding
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/16\*1024\*1024-2/g
      s/sbtest2/sharding_2_t1/g
      """
    #change insert sql to update
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/# \"insert into/\"insert into/g
      s/insert into {0}({1},{2}) values ({3},/update {0} set {1}=/g
      s/.format(self.table, cols_keys, target_col_key, cols_values)/.format(self.table,target_col_key)/g
      s/)'\''/ where {0}={1}'\''.format(cols_keys,cols_values)/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>16777172   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=16777172   | has{((7,),)} | schema1  |
    #id=7,route dn2
    Then check general log in host "mysql-master2" has "update sharding_2_t1 set c=\"aaaaaa"
    Then check general log in host "mysql-master1" has not "update sharding_2_t1 set c=\"aaaaaa"

    #prepare largepacket 16M-1,the update sql length 42b, 16M-1=16777173+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-2/16\*1024\*1024-1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>16777173   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=16777173   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "update sharding_2_t1 set c=\"aaaaaa" occured "==2" times

    #prepare largepacket 16M,the update sql length 42b, 16M=16777174+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-1/16\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>16777174   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=16777174   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "update sharding_2_t1 set c=\"aaaaaa" occured "==3" times

    #prepare largepacket 16M+1,the update sql length 42b, 16M+1=16777175+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/16\*1024\*1024+1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>16777175   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=16777175   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "update sharding_2_t1 set c=\"aaaaaa" occured "==4" times

    #prepare largepacket 16M+2,the update sql length 42b, 16M+2=16777176+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+1/16\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>16777176   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=16777176   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "update sharding_2_t1 set c=\"aaaaaa" occured "==5" times

    #prepare largepacket 20M,the update sql length 42b, 20M=20971478+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+2/20\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_2_t1 where length(c)>20971478   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_2_t1 where length(c)=20971478   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "update sharding_2_t1 set c=\"aaaaaa" occured "==6" times


    #prepare largepacket 32M-4,the update sql length 42b, 32M-4=33554386+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/20\*1024\*1024/32\*1024\*1024-4/g
      s/sharding_2_t1/sharding_4_t1/g
      """
    #change id values
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/values (7,7)/values (8,8)/g
      s/cols_values = 7/cols_values = 8/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_4_t1 where length(c)>33554386   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_4_t1 where length(c)=33554386   | length{(1)}  | schema1  |
    #id=8,route dn1
    Then check general log in host "mysql-master1" has "update sharding_4_t1 set c=\"aaaaaa"
    Then check general log in host "mysql-master2" has not "update sharding_4_t1 set c=\"aaaaaa"

    #prepare largepacket 32M-2,the update sql length 42b, 32M-2=33554388+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-4/32\*1024\*1024-2/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_4_t1 where length(c)>33554388   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_4_t1 where length(c)=33554388   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "update sharding_4_t1 set c=\"aaaaaa" occured "==2" times

    #prepare largepacket 32M,the update sql length 42b, 32M=33554390+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-2/32\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_4_t1 where length(c)>33554390   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_4_t1 where length(c)=33554390   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "update sharding_4_t1 set c=\"aaaaaa" occured "==3" times

    #prepare largepacket 32+2M,the update sql length 42b, 32M+2=33554392+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024/32\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_4_t1 where length(c)>33554392   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_4_t1 where length(c)=33554392   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "update sharding_4_t1 set c=\"aaaaaa" occured "==4" times

    #prepare largepacket 32+4M,the update sql length 42b, 32M+4=33554394+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024+2/32\*1024\*1024+4/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_4_t1 where length(c)>33554394   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_4_t1 where length(c)=33554394   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "update sharding_4_t1 set c=\"aaaaaa" occured "==5" times

    #prepare largepacket 40M,the update sql length 42b, 40M=41942998+42
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024+4/40\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect       | db       |
      | conn_0 | false   | select id from sharding_4_t1 where length(c)>41942998   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sharding_4_t1 where length(c)=41942998   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "update sharding_4_t1 set c=\"aaaaaa" occured "==6" times

    #table is singtable
    #prepare largepacket 40M,the update sql length 34b, 40M=41943006+34
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/sharding_4_t1/sing1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect       | db       |
      | conn_0 | false   | select id from sing1 where length(c)>41943006   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from sing1 where length(c)=41943006   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master2" has "update sing1 set c=\"aaaaaa"

    #table is global
    #prepare largepacket 40M,the update sql length 35b, 40M=41943005+35
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/sing1/global/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect       | db       |
      | conn_0 | false   | select id from global where length(c)>41943005   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from global where length(c)=41943005   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "update global set c=\"aaaaaa" occured "==2" times
    Then check general log in host "mysql-master2" has "update global set c=\"aaaaaa" occured "==2" times

    #table is nosharding
    #prepare largepacket 40M,the update sql length 35b, 40M=41943005+35
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/global/noshar/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect       | db       |
      | conn_0 | false   | select id from noshar where length(c)>41943005   | length{(0)}  | schema1  |
      | conn_0 | true    | select id from noshar where length(c)=41943005   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "update noshar set c=\"aaaaaa"
    Then check general log in host "mysql-master2" has not "update noshar set c=\"aaaaaa"

    Given turn off general log in "mysql-master1"
    Given turn off general log in "mysql-master2"


   Scenario: test "delete" sql #4
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="sing1" shardingNode="dn2" />
        <globalTable name="global" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-Xmx1G/-Xmx8G/g
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=167772160
      s/-XX:MaxDirectMemorySize=1G/-XX:MaxDirectMemorySize=2G/g
      """
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """
    Given Restart dble in "dble-1" success


    #prepare largepacket 16M-2,the delete sql length 39b, 16M-2=16777175+39
    #select length('delete from test1 where c="" and id=7')
    #test1 tabletype is nosharding
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/16\*1024\*1024-2/g
      s/sbtest2/test1/g
      """
    #change insert sql to delete   delete from table where c='' or id =7
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/# \"insert into/"insert into/g
      s/insert into {0}({1},{2}) values ({3},/delete from {0} where {1}=/g
      s/.format(self.table, cols_keys, target_col_key, cols_values)/.format(self.table,target_col_key)/g
      s/)'\''/ or {0}={1}'\''.format(cols_keys,cols_values)/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   | expect       | db       |
      | conn_0 | true    | select * from test1   | length{(0)}  | schema1  |
    #id=7,route dn5
    Then check general log in host "mysql-master1" has "delete from test1 where c=\"aaaaaa"
    Then check general log in host "mysql-master2" has not "delete from test1 where c=\"aaaaaa"

    #prepare largepacket 16M-1,the delete sql length 39b, 16M-1=16777176+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-2/16\*1024\*1024-1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   | expect       | db       |
      | conn_0 | true    | select * from test1   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master1" has "delete from test1 where c=\"aaaaaa" occured "==2" times

    #prepare largepacket 16M,the delete sql length 39b, 16M=16777177+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-1/16\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   | expect       | db       |
      | conn_0 | true    | select * from test1   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master1" has "delete from test1 where c=\"aaaaaa" occured "==3" times

    #prepare largepacket 16M+1,the delete sql length 39b, 16M+1=16777178+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/16\*1024\*1024+1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   | expect       | db       |
      | conn_0 | true    | select * from test1   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master1" has "delete from test1 where c=\"aaaaaa" occured "==4" times

    #prepare largepacket 16M+2,the delete sql length 39, 16M+2=16777179+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+1/16\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   | expect       | db       |
      | conn_0 | true    | select * from test1   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master1" has "delete from test1 where c=\"aaaaaa" occured "==5" times

    #prepare largepacket 20M,the delete sql length 39, 20M=20971481+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+2/20\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   | expect       | db       |
      | conn_0 | true    | select * from test1   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master1" has "delete from test1 where c=\"aaaaaa" occured "==6" times

    #prepare largepacket 32M-4,the delete sql length 39b, 32M-4=33554389+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/20\*1024\*1024/32\*1024\*1024-4/g
      s/test1/sing1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   | expect       | db       |
      | conn_0 | true    | select * from sing1   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master1" has not "delete from sing1 where c=\"aaaaaa"
    Then check general log in host "mysql-master2" has "delete from sing1 where c=\"aaaaaa"

    #prepare largepacket 32M-2,the delete sql length 39b, 32M-2=33554391+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-4/32\*1024\*1024-2/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   | expect       | db       |
      | conn_0 | true    | select * from sing1   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master2" has "delete from sing1 where c=\"aaaaaa" occured "==2" times

    #prepare largepacket 32M,the delete sql length 39, 32M=33554393+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-2/32\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   | expect       | db       |
      | conn_0 | true    | select * from sing1   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master2" has "delete from sing1 where c=\"aaaaaa" occured "==3" times

    #prepare largepacket 32M+2,the delete sql length 39, 32M+2=33554395+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024/32\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   | expect       | db       |
      | conn_0 | true    | select * from sing1   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master2" has "delete from sing1 where c=\"aaaaaa" occured "==4" times

    #prepare largepacket 32M+4,the delete sql length 39, 32M+4=33554397+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024+2/32\*1024\*1024+4/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   | expect       | db       |
      | conn_0 | true    | select * from sing1   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master2" has "delete from sing1 where c=\"aaaaaa" occured "==5" times

    #prepare largepacket 40M,the delete sql length 39, 40M=41943001+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024+4/40\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   | expect       | db       |
      | conn_0 | true    | select * from sing1   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master2" has "delete from sing1 where c=\"aaaaaa" occured "==6" times

    #prepare largepacket 20M,the delete sql length 47, 20M=20971473+47
    #shardingtable
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/40\*1024\*1024/20\*1024\*1024/g
      s/sing1/sharding_4_t1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                           | expect       | db       |
      | conn_0 | true    | select * from sharding_4_t1   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master2" has "delete from sharding_4_t1 where c=\"aaaaaa" occured "==2" times
    Then check general log in host "mysql-master1" has "delete from sharding_4_t1 where c=\"aaaaaa" occured "==2" times

    #prepare largepacket 20M,the delete sql length 40, 20M=20971480+40
    #globaltable
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/sharding_4_t1/global/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                    | expect       | db       |
      | conn_0 | true    | select * from global   | length{(0)}  | schema1  |
    Then check general log in host "mysql-master2" has "delete from global where c=\"aaaaaa" occured "==2" times
    Then check general log in host "mysql-master1" has "delete from global where c=\"aaaaaa" occured "==2" times

    Given turn off general log in "mysql-master1"
    Given turn off general log in "mysql-master2"


   Scenario: test "select" sql #5
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="sing1" shardingNode="dn2" />
        <globalTable name="global1" shardingNode="dn1,dn2,dn3,dn4" />
        <globalTable name="global2" shardingNode="dn1,dn3" />
        <globalTable name="global3" shardingNode="dn2,dn3" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-Xmx1G/-Xmx8G/g
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=167772160
      s/-XX:MaxDirectMemorySize=1G/-XX:MaxDirectMemorySize=2G/g
      """
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """
    Given Restart dble in "dble-1" success

    #prepare largepacket
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/16\*1024\*1024-2/g
      s/sbtest2/sing1/g
      """
    #change insert sql to select
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/insert into {0}({1},{2}) values ({3},/select * from {0} where {1}={3} or {2} =/g
      s/.format(self.table, cols_keys, target_col_key, cols_values)/.format(self.table, cols_keys, target_col_key,cols_values)/g
      s/)'\''/'\''/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    #16-1
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-2/16\*1024\*1024-1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    #16
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-1/16\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/16\*1024\*1024+1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+1/16\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+2/20\*1024\*1024/g
      s/sing1/global1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/20\*1024\*1024/32\*1024\*1024-4/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-4/32\*1024\*1024-2/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-2/32\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024/32\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024+2/32\*1024\*1024+4/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/global1/sharding_4_t1/g
      s/32\*1024\*1024+4/40\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/sharding_4_t1/noshar/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"
    Given turn off general log in "mysql-master1"
    Given turn off general log in "mysql-master2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect  | db      |
      | conn_0 | true   | drop table if exists noshar                | success | schema1 |


   Scenario: test "select" sql -- about response has large packet coz:DBLE0REQ-2096   #6
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':8388608},'mysql-master2':{'max_allowed_packet':8388608}}}
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-Xmx1G/-Xmx8G/g
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=167772160
      s/-XX:MaxDirectMemorySize=1G/-XX:MaxDirectMemorySize=4G/g
      $a -DsqlExecuteTimeout=1800000
      $a -DidleTimeout=1800000
      $a -DbufferPoolChunkSize=8192
      """
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """
    Given Restart dble in "dble-1" success

#    prepare large packet values
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | false   | drop table if exists test;create table test (id int,c longblob);truncate table test                                    | success | schema1 |
      | conn_0 | false   | drop table if exists sharding_4_t1;create table sharding_4_t1 (id int,c longblob);truncate table sharding_4_t1         | success | schema1 |
      | conn_0 | false   | insert into test values (0,repeat("x",16*1024*1024)),(1,repeat("x",16*1024*1024-1)),(2,repeat("x",16*1024*1024-2)),(3,repeat("x",16*1024*1024-3)),(4,repeat("x",16*1024*1024-4)),(5,repeat("x",16*1024*1024-5))               | success | schema1 |

       ## response  16*1024*1024-5的前后是边界
      | conn_0 | false   | insert into sharding_4_t1 values (0,repeat("x",16*1024*1024)),(1,repeat("x",16*1024*1024-1)),(2,repeat("x",16*1024*1024-2)),(3,repeat("x",16*1024*1024-3)),(4,repeat("x",16*1024*1024-4)),(5,repeat("x",16*1024*1024-5))               | success | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values (6,repeat("x",16*1024*1024-6)),(7,repeat("x",16*1024*1024-7)),(8,repeat("x",16*1024*1024-8)),(9,repeat("x",16*1024*1024-9)),(10,repeat("x",16*1024*1024-10))                                          | success | schema1 |
       ## response  32*1024*1024-11的前后是边界
      | conn_0 | false   | insert into sharding_4_t1 values (11,repeat("y",32*1024*1024)),(12,repeat("y",32*1024*1024-3)),(13,repeat("y",32*1024*1024-5)),(14,repeat("y",32*1024*1024-7)),(15,repeat("y",32*1024*1024-9)),(16,repeat("y",32*1024*1024-11))        | success | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values (17,repeat("y",32*1024*1024-13)),(18,repeat("y",32*1024*1024-15)),(19,repeat("y",32*1024*1024-17)),(20,repeat("y",32*1024*1024-19)),(21,repeat("y",32*1024*1024-21))                                  | success | schema1 |
      ## response 其余的大包值
      | conn_0 | true    | insert into sharding_4_t1 values (22,repeat("z",14*1024*1024)),(23,repeat("z",24*1024*1024-7)),(24,repeat("z",40*1024*1024)),(25,repeat("z",repeat("x",16*1024*1024-5)))                                                               | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                     | expect       | db      |
      | conn_0 | false   | select c from sharding_4_t1 where id = 0                                                                                                                                | length{(1)}  | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 1                                                                                                                                | length{(1)}  | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 2                                                                                                                                | length{(1)}  | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 3                                                                                                                                | length{(1)}  | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 4                                                                                                                                | length{(1)}  | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 5                                                                                                                                | length{(1)}  | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 6                                                                                                                                | length{(1)}  | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 7                                                                                                                                | length{(1)}  | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 8                                                                                                                                | length{(1)}  | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 9                                                                                                                                | length{(1)}  | schema1 |
      | conn_0 | true    | select c from sharding_4_t1 where id = 10                                                                                                                               | length{(1)}  | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 11;select c from sharding_4_t1 where id = 12;select c from sharding_4_t1 where id = 13;select c from sharding_4_t1 where id = 14 | success      | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 15;select c from sharding_4_t1 where id = 16;select c from sharding_4_t1 where id = 17;select c from sharding_4_t1 where id = 18 | success      | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 19;select c from sharding_4_t1 where id = 20;select c from sharding_4_t1 where id = 21;select c from sharding_4_t1 where id = 22 | success      | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 23                                                                                                                               | length{(1)}  | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 24                                                                                                                               | length{(1)}  | schema1 |
      | conn_0 | false   | select c from sharding_4_t1 where id = 25                                                                                                                               | length{(1)}  | schema1 |
      | conn_0 | true    | select id,c from sharding_4_t1                                                                                                                                          | length{(26)} | schema1 |

      | conn_0 | false   | select * from sharding_4_t1 where id in (select a.id from test a right join sharding_4_t1 b on a.id = b.id and a.id > 22)                                               | success     | schema1 |
      | conn_0 | false   | select 2                                                                                                                                                                | success      | schema1 |
      | conn_0 | false   | select * from sharding_4_t1 a join test b using(id,c) where a.id=16 or b.id=32;select 1                                                                                 | success      | schema1 |
      | conn_0 | false   | /*!dble:shardingNode=dn1*/select * from sharding_4_t1 a join test b using(id,c) where a.id=16 or b.id=32                                                                | success      | schema1 |
      | conn_0 | false   | /*!dble:shardingNode=dn1*/select c,id from sharding_4_t1;select id from sharding_4_t1;select * from test                                                                | success      | schema1 |

      | conn_0 | true    | drop table if exists test;drop table if exists sharding_4_t1                                                                                | success      | schema1 |

   @restore_mysql_config
   Scenario: test hint  and  mulit sql    #7
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':8388608},'mysql-master2':{'max_allowed_packet':8388608}}}
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-Xmx1G/-Xmx8G/g
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=167772160
      s/-XX:MaxDirectMemorySize=1G/-XX:MaxDirectMemorySize=4G/g
      """
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/info/g
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" readWeight="1" >
        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" readWeight="2">
        </dbInstance>
    </dbGroup>
    """
    Given Restart dble in "dble-1" success

    ##### /*!dble:shardingNode=dn1*/insert into sharding_4_t1(id,c) values (7,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/16\*1024\*1024-2/g
      s/sbtest2/sharding_4_t1/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/insert into {0}({1},{2}) values ({3},/\/*!dble:shardingNode=dn1*\/insert into {0}({1},{2}) values ({3},/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-2/16\*1024\*1024-1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    ##### /*!dble:sql=select c from test*/update test set c="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-1/16\*1024\*1024/g
      s/sharding_4_t1/test/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/dble:shardingNode=dn1/dble:sql=select c from test/g
      s/insert into {0}({1},{2}) values ({3},/update {0} set {1}=/g
      s/.format(self.table, cols_keys, target_col_key, cols_values)/.format(self.table,target_col_key)/g
      s/)'\''/ where {0}={1}'\''.format(cols_keys,cols_values)/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024/16\*1024\*1024+1/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    ##### /*!dble:db_type=master*/update test set c="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+1/16\*1024\*1024+2/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/dble:sql=select c from test/dble:db_type=master/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+2/32\*1024\*1024-4/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    ##### /*!dble:db_type=master*/select 1;update test set c="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-4/32\*1024\*1024-2/g
      """
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/update {0} set {1}=/select 1;update {0} set {1}=/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-2/32\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    #####  /*!dble:db_type=master*/delete from test where c="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    Given update file content "/opt/SQLContext.py" in "dble-1" with sed cmds
      """
      s/select 1;update {0} set {1}=/delete from {0} where {1}=/g
      s/where {0}={1}'\''.format(cols_keys,cols_values)/or {0}={1}'\''.format(cols_keys,cols_values)/g
      """
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024/32\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024+2/32\*1024\*1024+4/g
      """
    Given execute linux command in "dble-1"
      """
      python3 /opt/LargePacket.py
      """

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                              | expect      | db      |
      | conn_0 | true    | drop table if exists test;drop table if exists sharding_4_t1                     | success | schema1 |

    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"