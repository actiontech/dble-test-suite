# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by mayingle at 2020/09/11

Feature: We will check readonly status on both master and slave even if the heartbeat sql not "select @@read_only;"

#There are 3 kinds of heartbeat SQL in dble for 3.20.07.xx (other version may also like this)
# 1. show slave status
# 2. select @@read_only;
# 3. others (such as "select user()" or "select 1")
# This feature will check readonly status on both master and slave even if the heartbeat sql not "select @@read_only;"

"""
1. heartbeat SQL -- select @@read_only
  1.1 reload @@config_all -r；
  1.2 disabled=true → false
    1.2.1 db.xml add disabled=true & reload @@config_all;
    1.2.2 manager cmd pause→resume(X)
    1.2.3 manager cmd disable→enable
    1.2.4 changing db.xml add new dbinstance & reload @@config_all;
  1.3 restart dble --code_coverage should be considered
  1.4 heartbeat fail and recover
  1.5 master mysql(the dbinstance that primary="true") global variable read_only changing between 0 & 1
2. heartbeat SQL -- show slave status()
  2.1 reload @@config_all -r；
  2.2 disabled=true → false
    2.2.1 db.xml add disabled=true & reload @@config_all;
    2.2.2 manager cmd pause→resume(X)
    2.2.3 manager cmd disable→enable
    2.2.4 changing db.xml add new dbinstance & reload @@config_all;
  2.3 restart dble --code_coverage should be considered
  2.4 heartbeat fail and recover
3. heartbeat SQL -- select user()
  3.1 reload @@config_all -r；
  3.2 disabled=true → false
    3.2.1 db.xml add disabled=true & reload @@config_all;
    3.2.2 manager cmd pause→resume(X)
    3.2.3 manager cmd disable→enable
    3.2.4 changing db.xml add new dbinstance & reload @@config_all;
  3.3 restart dble --code_coverage should be considered
  3.4 heartbeat fail and recover
"""

   @restore_global_setting
  Scenario: all heartbeat SQL -- select user() & show slave status & select @@read_only check after reload @@config_all -r (1.1 & 2.1 & 3.1). #1
     """
     {'restore_global_setting':{'mysql-master1':{'general_log':0},'mysql-master2':{'general_log':0},'mysql-master3':{'general_log':0}}}
     """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
         <heartbeat>show slave status</heartbeat>
         <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
         <heartbeat>select @@read_only</heartbeat>
         <dbInstance name="hostM3" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     """
     Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
     """
        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
        <shardingNode dbGroup="ha_group3" database="db3" name="dn5" />
     """
     Then execute admin cmd "reload @@config_all"

     Given turn on general log in "mysql-master1"
     Given turn on general log in "mysql-master2"
     Given turn on general log in "mysql-master3"
     Given record current dble log line number in "log_linenu"
     # if conn pool is not recreated, global var will not be redetected, so reload must has -r option
     When execute admin cmd "reload @@config_all -r" success
     Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
     """
     con query sql:select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation
     """
     Then check general log in host "mysql-master1" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-master2" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-master3" has "@@read_only" occured ">0" times
     Given turn off general log in "mysql-master1"
     Given turn off general log in "mysql-master2"
     Given turn off general log in "mysql-master3"


   @restore_global_setting
  Scenario: all heartbeat SQL -- select 1 & show slave status & select @@read_only;db.xml add disabled=true & reload @@config_all; (1.2.1 & 2.2.1 & 3.2.1). #2
     """
     {'restore_global_setting':{'mysql-master1':{'general_log':0},'mysql-master2':{'general_log':0},'mysql-master3':{'general_log':0}}}
     """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
         <heartbeat>show slave status</heartbeat>
         <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" disabled="true" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
         <heartbeat>select 1</heartbeat>
         <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" disabled="true" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
         <heartbeat>select @@read_only</heartbeat>
         <dbInstance name="hostM3" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" disabled="true" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     """
     Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
     """
        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
        <shardingNode dbGroup="ha_group3" database="db3" name="dn5" />
     """
     Then execute admin cmd "reload @@config_all"

     Given turn on general log in "mysql-master1"
     Given turn on general log in "mysql-master2"
     Given turn on general log in "mysql-master3"
     Given record current dble log line number in "log_linenu"

     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
         <heartbeat>select @@read_only</heartbeat>
         <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" disabled="false" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
         <heartbeat>show slave status</heartbeat>
         <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" disabled="false" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
         <heartbeat>select 1</heartbeat>
         <dbInstance name="hostM3" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" disabled="false" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     """
     Then execute admin cmd "reload @@config_all"

     Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
     """
     con query sql:select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation
     """
     Then check general log in host "mysql-master1" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-master2" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-master3" has "@@read_only" occured ">0" times
     Given turn off general log in "mysql-master1"
     Given turn off general log in "mysql-master2"
     Given turn off general log in "mysql-master3"


   @restore_global_setting
  Scenario: all heartbeat SQL -- select user() & show slave status & select @@read_only;manager cmd disable→enable; (1.2.3 & 2.2.3 & 3.2.3). #3
     """
     {'restore_global_setting':{'mysql-master1':{'general_log':0},'mysql-master2':{'general_log':0},'mysql-master3':{'general_log':0}}}
     """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
         <heartbeat>show slave status</heartbeat>
         <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
         <heartbeat>select @@read_only</heartbeat>
         <dbInstance name="hostM3" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     """
     Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
     """
        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
        <shardingNode dbGroup="ha_group3" database="db3" name="dn5" />
     """
     Then execute admin cmd "reload @@config_all"

      # begin exec dbGroup @@disable name='ha_group1,2,3';
     Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose  | sql                                | expect  |
        | conn_0 | False    | dbGroup @@disable name='ha_group1' | success |
        | conn_0 | False    | dbGroup @@disable name='ha_group2' | success |
        | conn_0 | True     | dbGroup @@disable name='ha_group3' | success |

      #Then check disable status
     Then check exist xml node "{'tag':'dbGroup/dbInstance','kv_map':{'name':'hostM1','disabled':'true'}}" in " /opt/dble/conf/db.xml" in host "dble-1"
     Then check exist xml node "{'tag':'dbGroup/dbInstance','kv_map':{'name':'hostM2','disabled':'true'}}" in " /opt/dble/conf/db.xml" in host "dble-1"
     Then check exist xml node "{'tag':'dbGroup/dbInstance','kv_map':{'name':'hostM3','disabled':'true'}}" in " /opt/dble/conf/db.xml" in host "dble-1"

     Given turn on general log in "mysql-master1"
     Given turn on general log in "mysql-master2"
     Given turn on general log in "mysql-master3"

     Given record current dble log line number in "log_linenu"

      # enable the dbGroups:
     Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose  | sql                               | expect  |
        | conn_0 | False    | dbGroup @@enable name='ha_group1' | success |
        | conn_0 | False    | dbGroup @@enable name='ha_group2' | success |
        | conn_0 | True     | dbGroup @@enable name='ha_group3' | success |

       #Then check enable status
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
        | sql               |
        | show @@dbinstance |
     Then check resultset "show_ds_rs" has lines with following column values
        | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5 | DISABLED-10 |
        | ha_group1  | hostM1   | 172.100.9.5   | 3306   | W      |      0   | false       |
        | ha_group2  | hostM2   | 172.100.9.6   | 3306   | W      |      0   | false       |
        | ha_group3  | hostM3   | 172.100.9.1   | 3306   | W      |      0   | false       |

     Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
     """
     con query sql:select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation
     """
     Then check general log in host "mysql-master1" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-master2" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-master3" has "@@read_only" occured ">0" times
     Given turn off general log in "mysql-master1"
     Given turn off general log in "mysql-master2"
     Given turn off general log in "mysql-master3"


   @restore_global_setting
  Scenario: all heartbeat SQL -- select user() & show slave status & select @@read_only;add slave mysql on db.xml & reload @@config_all; (1.2.4 & 2.2.4 & 3.2.4). #4
     """
     {'restore_global_setting':{'mysql-master1':{'general_log':0},'mysql-master2':{'general_log':0},'mysql-master3':{'general_log':0},'mysql-slave1':{'general_log':0},'mysql-slave2':{'general_log':0},'mysql':{'general_log':0}}}
     """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
         <heartbeat>show slave status</heartbeat>
         <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
         <heartbeat>select @@read_only</heartbeat>
         <dbInstance name="hostM3" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
         </dbInstance>
     </dbGroup>

     """
     Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
     """
        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
        <shardingNode dbGroup="ha_group3" database="db3" name="dn5" />
     """
     Then execute admin cmd "reload @@config_all"

     Given turn on general log in "mysql-master1"
     Given turn on general log in "mysql-master2"
     Given turn on general log in "mysql-master3"
     Given turn on general log in "mysql-slave1"
     Given turn on general log in "mysql-slave2"
     Given turn on general log in "mysql"
     Given record current dble log line number in "log_linenu"
      # then add slave mysql in db.xml and then reload @@config_all;
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
         <heartbeat>show slave status</heartbeat>
         <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
         </dbInstance>
         <dbInstance name="hosts1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="false">
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
         </dbInstance>
         <dbInstance name="hosts2" password="111111" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10" primary="false">
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
         <heartbeat>select @@read_only</heartbeat>
         <dbInstance name="hostM3" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
         </dbInstance>
         <dbInstance name="hosts3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="false">
         </dbInstance>
     </dbGroup>

     """

     When execute admin cmd "reload @@config_all" success
     Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
     """
     con query sql:select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation
     """
     Then check general log in host "mysql-master1" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-master2" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-master3" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-slave1" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-slave2" has "@@read_only" occured ">0" times
     Then check general log in host "mysql" has "@@read_only" occured ">0" times
     Given turn off general log in "mysql-master1"
     Given turn off general log in "mysql-master2"
     Given turn off general log in "mysql-master3"
     Given turn off general log in "mysql-slave1"
     Given turn off general log in "mysql-slave2"
     Given turn off general log in "mysql"


   @restore_global_setting @restore_network
  Scenario: all heartbeat SQL -- select user() & show slave status & select @@read_only;heartbeat fail & recover by dble network down; (1.4 & 2.4 & 3.4). #5
     """
     {'restore_global_setting':{'mysql-master1':{'general_log':0},'mysql-master2':{'general_log':0},'mysql-master3':{'general_log':0},'mysql-slave1':{'general_log':0},'mysql-slave2':{'general_log':0},'mysql':{'general_log':0}}}
     """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
         <heartbeat>show slave status</heartbeat>
         <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
             <property name="heartbeatPeriodMillis">1000</property>
         </dbInstance>
         <dbInstance name="hosts1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="false">
             <property name="heartbeatPeriodMillis">1000</property>
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
             <property name="heartbeatPeriodMillis">1000</property>
         </dbInstance>
         <dbInstance name="hosts2" password="111111" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10" primary="false">
             <property name="heartbeatPeriodMillis">100</property>
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
         <heartbeat>select @@read_only</heartbeat>
         <dbInstance name="hostM3" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
             <property name="heartbeatPeriodMillis">1000</property>
         </dbInstance>
         <dbInstance name="hosts3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="false">
             <property name="heartbeatPeriodMillis">1000</property>
         </dbInstance>
     </dbGroup>

     """
     Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
     """
        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
        <shardingNode dbGroup="ha_group3" database="db3" name="dn5" />
     """
     Then execute admin cmd "reload @@config_all"

     # start turn on iptables on every mysql node
     Given execute oscmd in "mysql-master1"
     """
     iptables -A OUTPUT -d 172.100.9.1 -j DROP
     """
     Given execute oscmd in "mysql-master2"
     """
     iptables -A OUTPUT -d 172.100.9.1 -j DROP
     """
     Given execute oscmd in "mysql-master3"
     """
     iptables -A OUTPUT -d 172.100.9.1 -j DROP
     """
     Given execute oscmd in "mysql-slave1"
     """
     iptables -A OUTPUT -d 172.100.9.1 -j DROP
     """
     Given execute oscmd in "mysql-slave2"
     """
     iptables -A OUTPUT -d 172.100.9.1 -j DROP
     """
     Given execute oscmd in "mysql"
     """
     iptables -A OUTPUT -d 172.100.9.1 -j DROP
     """

     Given turn on general log in "mysql-master1"
     Given turn on general log in "mysql-master2"
     Given turn on general log in "mysql-master3"
     Given turn on general log in "mysql-slave1"
     Given turn on general log in "mysql-slave2"
     Given turn on general log in "mysql"

     Given record current dble log line number in "log_linenu"

     # sleep 3 sec for
     Given sleep "3" seconds

     # start turn on iptables on every mysql node
     Given execute oscmd in "mysql-master1"
     """
     iptables -F
     """
     Given execute oscmd in "mysql-master2"
     """
     iptables -F
     """
     Given execute oscmd in "mysql-master3"
     """
     iptables -F
     """
     Given execute oscmd in "mysql-slave1"
     """
     iptables -F
     """
     Given execute oscmd in "mysql-slave2"
     """
     iptables -F
     """
     Given execute oscmd in "mysql"
     """
     iptables -F
     """

     Given sleep "3" seconds

     Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
     """
     setTimeout
     """
     Then check general log in host "mysql-master1" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-master2" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-master3" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-slave1" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-slave2" has "@@read_only" occured ">0" times
     Then check general log in host "mysql" has "@@read_only" occured ">0" times
     Given turn off general log in "mysql-master1"
     Given turn off general log in "mysql-master2"
     Given turn off general log in "mysql-master3"
     Given turn off general log in "mysql-slave1"
     Given turn off general log in "mysql-slave2"
     Given turn off general log in "mysql"


   @restore_global_setting
  Scenario: all heartbeat SQL -- select user() & show slave status & select @@read_only; dble reboot; (1.3 & 2.3 & 3.3). #6
     """
     {'restore_global_setting':{'mysql-master1':{'general_log':0},'mysql-master2':{'general_log':0},'mysql-master3':{'general_log':0},'mysql-slave1':{'general_log':0},'mysql-slave2':{'general_log':0},'mysql':{'general_log':0}}}
     """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
         <heartbeat>show slave status</heartbeat>
         <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
             <property name="heartbeatPeriodMillis">1000</property>
         </dbInstance>
         <dbInstance name="hosts1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="false">
             <property name="heartbeatPeriodMillis">1000</property>
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
             <property name="heartbeatPeriodMillis">1000</property>
         </dbInstance>
         <dbInstance name="hosts2" password="111111" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10" primary="false">
             <property name="heartbeatPeriodMillis">100</property>
         </dbInstance>
     </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
         <heartbeat>select @@read_only</heartbeat>
         <dbInstance name="hostM3" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
             <property name="heartbeatPeriodMillis">1000</property>
         </dbInstance>
         <dbInstance name="hosts3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="false">
             <property name="heartbeatPeriodMillis">1000</property>
         </dbInstance>
     </dbGroup>

     """
     Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
     """
        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
        <shardingNode dbGroup="ha_group3" database="db3" name="dn5" />
     """
     Then execute admin cmd "reload @@config_all"

     Given turn on general log in "mysql-master1"
     Given turn on general log in "mysql-master2"
     Given turn on general log in "mysql-master3"
     Given turn on general log in "mysql-slave1"
     Given turn on general log in "mysql-slave2"
     Given turn on general log in "mysql"

     Given Restart dble in "dble-1" success

     Then check general log in host "mysql-master1" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-master2" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-master3" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-slave1" has "@@read_only" occured ">0" times
     Then check general log in host "mysql-slave2" has "@@read_only" occured ">0" times
     Then check general log in host "mysql" has "@@read_only" occured ">0" times
     Given turn off general log in "mysql-master1"
     Given turn off general log in "mysql-master2"
     Given turn off general log in "mysql-master3"
     Given turn off general log in "mysql-slave1"
     Given turn off general log in "mysql-slave2"
     Given turn off general log in "mysql"
