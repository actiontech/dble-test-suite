# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/1/7
# update by quexiuping at 2023/2/27


Feature:Support MySQL's large package protocol about maxPacketSize and use checksum check value


  @restore_mysql_config
   Scenario: test dble's maxPacketSize and mysql's max_allowed_packet  #1
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4M},'mysql-slave1':{'max_allowed_packet':4M},'mysql-master2':{'max_allowed_packet':4M}}}
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
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('4194304B',),)} | dble_information |

    #### case 2  当mysql的值小于dble的时候，dble会对后端mysql下发 set global max_allowed_packet，还会加上1024
#    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
#    """
#     /max_allowed_packet/d
#     /server-id/a max_allowed_packet=5242880
#     """
#    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
#    """
#     /max_allowed_packet/d
#     /server-id/a max_allowed_packet=5242880
#     """
#    Given restart mysql in "mysql-slave1" with sed cmds to update mysql config
#    """
#     /max_allowed_packet/d
#     /server-id/a max_allowed_packet=5242880
#     """

#    Then execute sql in "mysql-master1"
#      | conn   | toClose | sql                                              | expect                                    | timeout |
#      | conn_1 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '5242880'),)} | 10      |
#    Then execute sql in "mysql-slave1"
#      | conn   | toClose | sql                                              | expect                                    | timeout |
#      | conn_3 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '5242880'),)} | 10      |
#    Then execute sql in "mysql-master2"
#      | conn   | toClose | sql                                              | expect                                    | timeout |
#      | conn_2 | True    | show variables like 'max_allowed_packet%'        | has{(('max_allowed_packet', '5242880'),)} | 10      |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /DmaxPacketSize/d
      /# processor/a -DmaxPacketSize=9437184
      """
    Given Restart dble in "dble-1" success

    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('9437184B',),)} | dble_information |
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
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('5242880B',),)} | dble_information |
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
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('10485760B',),)} | dble_information |
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



   Scenario: maxPacketSize 小于大包的值，会报错        #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="3" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" />
      </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
      """
    Then execute admin cmd "reload @@config_all"
    Given upload file "./features/steps/LargePacket.py" to "dble-1" success
    Given upload file "./features/steps/LargePacket_rw.py" to "dble-1" success
    Given upload file "./features/steps/SQLContext.py" to "dble-1" success
    ####mysql_exceptions.OperationalError: (1153, "Got a packet bigger than 'max_allowed_packet' bytes")       # DBLE0REQ-960
    #####Packet for query is too large (12582915 > 4194304).You can change maxPacketSize value in bootstrap.cnf  #DBLE0REQ-2004
    Given execute linux command in "dble-1" and contains exception "Packet for query is too large (12582915 > 4194304).You can change maxPacketSize value in bootstrap.cnf"
      """
      python3 /opt/LargePacket.py
      """
     #### 按理，读写分离用户的报错参考应该是mysql的值，后续优化的时候再更改case DBLE0REQ-2051
    Given execute linux command in "dble-1" and contains exception "Packet for query is too large (12582915 > 4194304).You can change maxPacketSize value in bootstrap.cnf"
      """
      python3 /opt/LargePacket_rw.py
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """



  @restore_mysql_config
   Scenario: 大包下，执行相关管理命令（如show @@connection.sql；show @@sql; sql_log sqldump等） 结果收敛 展示1024    #3
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':4194304},'mysql-master2':{'max_allowed_packet':4194304}}}
    """
    Given upload file "./features/steps/LargePacket.py" to "dble-1" success
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
      <dbGroup rwSplitMode="3" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" />
      </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
      """
    Given Restart dble in "dble-1" success
    ###开启sql_log和sql_dump的统计
    Then execute admin cmd "enable @@statistic"
    Then execute admin cmd "reload @@samplingRate=100"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                            | expect  | db      |
      | rw1  | 111111 | conn_0 | false   | drop table if exists tb1;create table tb1 (id int,c longblob)                                  | success | db1     |
      | rw1  | 111111 | conn_0 | true    | drop table if exists test1;create table test1 (id int,c longblob);truncate table test1         | success | db1     |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | false   | drop table if exists tb1;create table tb1 (id int,c longblob)                                                          | success | schema1 |
      | conn_1 | true    | drop table if exists sharding_4_t1;create table sharding_4_t1 (id int,c longblob);truncate table sharding_4_t1         | success | schema1 |

    Given create filder content "/opt/dble/logs/insert" in "dble-1"
    Given execute oscmd "python3 /opt/LargePacket.py >/opt/dble/logs/insert/sharding.txt" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect                 | db               |
      | conn_2 | False    | show @@sql                                                                | hasStr{aaaaaaaaaa...}     | dble_information |
      | conn_2 | False    | select * from sql_log where sql_stmt like "%insert into sharding_4_t1%"   | hasStr{aaaaaaaaaa...}     | dble_information |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "enable @@sqldump_sql"
    Given execute oscmd "python3 /opt/LargePacket_rw.py >/opt/dble/logs/insert/rwSplitUser.txt" on "dble-1"
    Then check following text exist "Y" in file "/opt/dble/sqldump/sqldump.log" in host "dble-1"
       """
       INSERT INTO test1\(id, c\) VALUES \(\?, \?\)
       """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """