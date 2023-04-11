# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/1/7
# update by quexiuping at 2023/2/27


Feature:Support MySQL's large package protocol about maxPacketSize and use checksum check value


  @restore_mysql_config
   Scenario: test dble's maxPacketSize and mysql's max_allowed_packet  #1
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4194304},'mysql-slave1':{'max_allowed_packet':4194304},'mysql-master2':{'max_allowed_packet':4194304}}}
    """
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
     Given restart mysql in "mysql-slave1" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 4M
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" readWeight="1" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" readWeight="2"/>
      </dbGroup>
      """
    Then execute admin cmd "reload @@config_all"

    #### case 1  dble的默认值
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('4194304',),)} | dble_information |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                              | expect                                    | timeout |
      | conn_1 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '4195328'),)} | 10      |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                              | expect                                    | timeout |
      | conn_2 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '4195328'),)} | 10      |
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                                              | expect                                    | timeout |
      | conn_3 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '4195328'),)} | 10      |

    #### case 2  当mysql的值小于dble的时候，dble会对后端mysql下发 set global max_allowed_packet，还会加上1024
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=9437184
      """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('9437184',),)} | dble_information |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                              | expect                                    | timeout |
      | conn_1 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '9438208'),)} | 10      |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                              | expect                                    | timeout |
      | conn_2 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '9438208'),)} | 10      |
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                                              | expect                                    | timeout |
      | conn_3 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '9438208'),)} | 10      |
    Then check general log in host "mysql-master1" has "set global max_allowed_packet=9438208"
    Then check general log in host "mysql-master2" has "set global max_allowed_packet=9438208"
    Then check general log in host "mysql-slave1" has "set global max_allowed_packet=9438208"

    #### case 3  当mysql的值大于dble的时候，dble不会对后端mysql下发 set global max_allowed_packet
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=5242880
      """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('5242880',),)} | dble_information |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                              | expect                                    | timeout |
      | conn_1 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '9438208'),)} | 10      |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                              | expect                                    | timeout |
      | conn_2 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '9438208'),)} | 10      |
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                                              | expect                                    | timeout |
      | conn_3 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '9438208'),)} | 10      |
    Then check general log in host "mysql-master1" has "set global max_allowed_packet=9438208" occured "==1" times
    Then check general log in host "mysql-master2" has "set global max_allowed_packet=9438208" occured "==1" times
    Then check general log in host "mysql-slave1" has "set global max_allowed_packet=9438208" occured "==1" times
    Then check general log in host "mysql-master1" has not "set global max_allowed_packet=5243904"
    Then check general log in host "mysql-master2" has not "set global max_allowed_packet=5243904"
    Then check general log in host "mysql-slave1" has not "set global max_allowed_packet=5243904"

     #### case 4  后端mysql的值大小不一的时候，dble会补齐，就是比dble小的下发，比dble大的不处理
     Given restart mysql in "mysql-master1" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 17M
      """
    Given turn on general log in "mysql-master1"

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=10485760
      """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                 | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('10485760',),)} | dble_information |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                              | expect                                     | timeout |
      | conn_1 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '17825792'),)} | 10      |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                              | expect                                     | timeout |
      | conn_2 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '10486784'),)} | 10      |
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                                              | expect                                     | timeout |
      | conn_3 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '10486784'),)} | 10      |

    Then check general log in host "mysql-master1" has not "set global max_allowed_packet=10486784"
    Then check general log in host "mysql-master2" has "set global max_allowed_packet=10486784" occured "==1" times
    Then check general log in host "mysql-slave1" has "set global max_allowed_packet=10486784" occured "==1" times

    Given turn off general log in "mysql-master1"
    Given turn off general log in "mysql-master2"
    Given turn off general log in "mysql-slave1"



  @restore_mysql_config
   Scenario: maxPacketSize 小于大包的值，会报错        #2
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4194304},'mysql-master2':{'max_allowed_packet':4194304}}}
    """

    Given upload file "./features/steps/LargePacket.py" to "dble-1" success
    Given upload file "./features/steps/SQLContext.py" to "dble-1" success

     ####case1 当dble和mysql都小于大包值时
    ####mysql_exceptions.OperationalError: (1153, "Got a packet bigger than 'max_allowed_packet' bytes")       # DBLE0REQ-960
    #####Packet for query is too large (12582915 > 4194304).You can change maxPacketSize value in bootstrap.cnf  #DBLE0REQ-2004
    Given execute linux command in "dble-1" and contains exception "Got a packet bigger than 'max_allowed_packet' bytes"
      """
      python3 /opt/LargePacket.py
      """
     ####case3 当dble小于大包值时，但mysql的值大于大包时
     Given restart mysql in "mysql-master1" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 17M
      """
     Given restart mysql in "mysql-master2" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 17M
      """
    Given Restart dble in "dble-1" success
    Given execute linux command in "dble-1" and contains exception "Got a packet bigger than 'max_allowed_packet' bytes"
      """
      python3 /opt/LargePacket.py
      """
     Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """
     Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      Got a packet bigger than 'max_allowed_packet' bytes
      """



  @restore_mysql_config
  Scenario:  repeat() 函数下发大包校验 --- repeat受后端mysql max_allowed_packet参数限制   #4
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4194304},'mysql-master2':{'max_allowed_packet':4194304}}}
    """
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
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                         | expect  | db      |
      | conn_0 | false   | drop table if exists test;create table test (id int,c longblob);truncate table test         | success | schema1 |
      | conn_0 | true    | insert into test values (0,repeat("x",16*1024*1024))                                        | Result of repeat() was larger than max_allowed_packet (4195328) - truncated | schema1 |

     Given restart mysql in "mysql-master1" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 8M
      """
     Given restart mysql in "mysql-master2" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 8M
      """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "admin" mode
      | conn  | toClose | sql                                                                              | expect                | db               |
      | new   | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('4194304',),)} | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                         | expect  | db      |
      | conn_0 | false    | insert into test values (1,repeat("x",6*1024*1024))                                        | success | schema1 |
      | conn_0 | true     | insert into test values (1,repeat("x",16*1024*1024))                                       | Result of repeat() was larger than max_allowed_packet (8388608) - truncated | schema1 |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """


  @restore_mysql_config
  Scenario: source 大包校验    #5
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4194304},'mysql-master2':{'max_allowed_packet':4194304}}}
    """
    Given set log4j2 log level to "info" in "dble-1"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-Xmx1G/-Xmx8G/g
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=167772160
      s/-XX:MaxDirectMemorySize=1G/-XX:MaxDirectMemorySize=8G/g
      $a -DidleTimeout=180000
      $a -DbufferPoolPageSize=33554432
      """
    Given Restart dble in "dble-1" success
    Given create folder content "/opt/dble/logs/insert" in "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                   | expect  | db      |
      | conn_0 | false   | drop table if exists test;create table test (id int,c longblob);truncate table test                                                                                                   | success | schema1 |
      | conn_0 | true    | insert into test values (0,repeat("x",16*1024*1024)),(1,repeat("x",16*1024*1024-1)),(2,repeat("x",16*1024*1024-2)),(3,repeat("x",16*1024*1024+1)),(4,repeat("x",16*1024*1024+2))      | success | schema1 |

    ##### 通过concat函数拼接大包字段和insert到test.sql文件再通过source下发
    Given execute oscmd in "dble-1"
      """
      mysql -utest -P8066 -h172.100.9.1 -Dschema1 --max_allowed_packet=1G -e "select concat('insert into test values (1,\'',c,'\');') as 'select 10086;' from test" >/opt/dble/logs/insert/test.sql && \
      mysql -utest -P8066 -h172.100.9.1 -Dschema1 --max_allowed_packet=1G -e "source /opt/dble/logs/insert/test.sql" >/opt/dble/logs/insert/test.txt
      """
    Then check following text exists in file "/opt/dble/logs/insert/test.sql" in host "dble-1" with "5" times
      """
      insert into test values
      """
    Then check following text exists in file "/opt/dble/logs/insert/test.txt" in host "dble-1" with "2" times
      """
      10086
      """

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      unknown error:
      NullPointerException
      """

    #### 依赖case生成的test.sql验证maxPacketSize参数报错
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /DmaxPacketSize/d
      """
    Given Restart dble in "dble-1" success
    Given execute oscmd in "dble-1"
      """
      mysql -utest -P8066 -h172.100.9.1 -Dschema1 --max_allowed_packet=1G -e "source /opt/dble/logs/insert/test.sql" >/opt/dble/logs/insert/test.txt 2>&1 &
      """
    Then check following text exist "Y" in file "/opt/dble/logs/insert/test.txt" in host "dble-1"
      """
      Packet for query is too large.* 4194304.*You can change maxPacketSize value in bootstrap.cnf
      10086
      """