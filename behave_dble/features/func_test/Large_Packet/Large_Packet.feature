# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/1/7

Feature:Support MySQL's large package protocol

  @skip @restore_mysql_service
  Scenario:
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



  @skip_restart
  Scenario:
    Given delete file "/opt/LargePacket.py" on "dble-1"
    Given delete file "/opt/SQLContext.py" on "dble-1"
    Given delete file "/opt/SQLContext.pyc" on "dble-1"
    Given upload file "./features/steps/LargePacket.py" to "dble-1" success
    Given upload file "./features/steps/SQLContext.py" to "dble-1" success
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
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
    #prepare largepacket 16M-2,the insert sql has 39b, 16M-2=16777175+39
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
      | conn   | toClose | sql                                            | expect       | db       |
      | conn_0 | false   | select * from test1 where length(c)>16777175   | length{(0)}  | schema1  |
      | conn_0 | true    | select * from test1 where length(c)=16777175   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test1(id,c) values (7,\"aaaaaaaaaaa"

    #prepare largepacket 16M-1,the insert sql has 39b, 16M-1=16777176+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-2/16\*1024\*1024-1/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect       | db       |
      | conn_0 | false   | select * from test1 where length(c)>16777176   | length{(0)}  | schema1  |
      | conn_0 | true    | select * from test1 where length(c)=16777176   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test1(id,c) values (7,\"aaaaaaaaaaa" occured "==2" times

    #prepare largepacket 16M,the insert sql has 39b, 16M=16777177+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024-1/16\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect       | db       |
      | conn_0 | false   | select * from test1 where length(c)>16777177   | length{(0)}  | schema1  |
      | conn_0 | true    | select * from test1 where length(c)=16777177   | length{(1)}  | schema1  |
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
      | conn_0 | false   | select * from test1 where length(c)>16777178   | length{(0)}  | schema1  |
      | conn_0 | true    | select * from test1 where length(c)=16777178   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test1(id,c) values (7,\"aaaaaaaaaaa" occured "==4" times

    #prepare largepacket 16M+2,the insert sql has 39b, 16M+2=16777179+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+1/16\*1024\*1024+2/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect       | db       |
      | conn_0 | false   | select * from test1 where length(c)>16777179   | length{(0)}  | schema1  |
      | conn_0 | true    | select * from test1 where length(c)=16777179   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test1(id,c) values (7,\"aaaaaaaaaaa" occured "==5" times


    #prepare largepacket 20M,the insert sql has 39b, 20M=20971481+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/16\*1024\*1024+2/20\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect       | db       |
      | conn_0 | false   | select * from test1 where length(c)>20971481   | length{(0)}  | schema1  |
      | conn_0 | true    | select * from test1 where length(c)=20971481   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test1(id,c) values (7,\"aaaaaaaaaaa" occured "==6" times


    #prepare largepacket 32M-4,the insert sql has 39b, 32M-4=33554389+39
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
      | conn   | toClose | sql                                            | expect       | db       |
      | conn_0 | false   | select * from test2 where length(c)>33554389   | length{(0)}  | schema1  |
      | conn_0 | true    | select * from test2 where length(c)=33554389   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test2(id,c) values (7,\"aaaaaaaaaaa"

    #prepare largepacket 32M-2,the insert sql has 39b, 32M-2=33554391+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-4/32\*1024\*1024-2/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect       | db       |
      | conn_0 | false   | select * from test2 where length(c)>33554391   | length{(0)}  | schema1  |
      | conn_0 | true    | select * from test2 where length(c)=33554391   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test2(id,c) values (7,\"aaaaaaaaaaa" occured "==2" times


    #prepare largepacket 32M,the insert sql has 39b, 32M=33554393+39
    Given update file content "/opt/LargePacket.py" in "dble-1" with sed cmds
      """
      s/32\*1024\*1024-2/32\*1024\*1024/g
      """
    Given execute linux command in "dble-1"
      """
      python /opt/LargePacket.py
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect       | db       |
      | conn_0 | false   | select * from test2 where length(c)>33554393   | length{(0)}  | schema1  |
      | conn_0 | true    | select * from test2 where length(c)=33554393   | length{(1)}  | schema1  |
    Then check general log in host "mysql-master1" has "insert into test2(id,c) values (7,\"aaaaaaaaaaa" occured "==3" times

