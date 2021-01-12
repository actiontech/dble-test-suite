# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/12/
Feature: test "binlog" in zk cluster
  # Pull the consistent binlog line


  Background: prepare env
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
     """
     /log-bin=/d
     /binlog_format=/d
     /relay-log=/d
     /server-id/a log-bin=mysql-bin
     /server-id/a binlog_format=row
     /server-id/a relay-log=mysql-relay-bin
     """

  @skip_restart   @restore_mysql_config
  Scenario: during "transaction",happen bad block,check "showBinlogStatusTimeout" #1
    """
    {'restore_mysql_config':{'mysql-master1':{'log-bin':0,'binlog_format':0,'relay-log':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
          <globalTable name="global1" shardingNode="dn1,dn2,dn3,dn4"/>
          <globalTable name="global2" shardingNode="dn4,dn2"/>
          <shardingTable name="sharding4" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="sharding2" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id">
              <childTable name="child1" joinColumn="fid" parentColumn="id" />
          </shardingTable>
          <singleTable name="sing1" shardingNode="dn1" />
        </schema>

        <schema name="schema2" shardingNode="dn2"/>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
         <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10"/>
         <dbInstance name="hostS2" password="111111" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10"/>
      </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """
    Then execute admin cmd "reload @@config_all"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /-Dprocessors=/d
      /-DprocessorExecutor=/d
      $a -Dprocessors=8
      $a -DprocessorExecutor=8
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
      """
      /-Dprocessors=/d
      /-DprocessorExecutor=/d
      $a -Dprocessors=8
      $a -DprocessorExecutor=8
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
      """
      /-Dprocessors=/d
      /-DprocessorExecutor=/d
      $a -Dprocessors=8
      $a -DprocessorExecutor=8
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      $a showBinlogStatusTimeout=5000
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-2" with sed cmds
      """
      $a showBinlogStatusTimeout=5000
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-3" with sed cmds
      """
      $a showBinlogStatusTimeout=5000
      """
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                          | expect  | db      |
      | conn_1 | False   | drop table if exists vertical1                               | success | schema2 |
      | conn_1 | True    | create table vertical1 (id int)                              | success | schema2 |
      | conn_0 | False   | drop table if exists global1                                 | success | schema1 |
      | conn_0 | False   | drop table if exists global2                                 | success | schema1 |
      | conn_0 | False   | drop table if exists sharding4                               | success | schema1 |
      | conn_0 | False   | drop table if exists sharding2                               | success | schema1 |
      | conn_0 | False   | drop table if exists child1                                  | success | schema1 |
      | conn_0 | False   | drop table if exists sing1                                   | success | schema1 |
      | conn_0 | False   | drop table if exists no_sharding1                            | success | schema1 |
      | conn_0 | False   | create table global1 (id int)                                | success | schema1 |
      | conn_0 | False   | create table global2 (id int)                                | success | schema1 |
      | conn_0 | False   | create table sharding4 (id int, name int)                    | success | schema1 |
      | conn_0 | False   | create table sharding2 (id int, fid int)                     | success | schema1 |
      | conn_0 | False   | create table child1 (fid int,name int)                       | success | schema1 |
      | conn_0 | False   | create table sing1 (id int)                                  | success | schema1 |
      | conn_0 | True    | create table no_sharding1 (id int, name int)                 | success | schema1 |


    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                | expect  | db      |
      | conn_11 | False   | begin                              | success | schema1 |
      | conn_11 | False   | insert into global1 values (1)     | success | schema1 |
    #query would "hang"
    Given execute sqls in "dble-2" at background
      | conn    | toClose | sql                                                 | db      |
      | conn_21 | false    | alter table global1 add name int default 2021      | schema1 |
    #query would "hang",happen bad block,wait showBinlogStatusTimeout
    Then execute "admin" cmd  in "dble-3" at background
      | conn    | toClose | sql                  | db               |
      | conn_3  | true    | show @@binlog.status | dble_information |
    Given sleep "6" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-3"
      """
      wait all session finished
      """
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql       | expect  | db      |
      | conn_11 | true    | commit    | success | schema1 |
    Given sleep "1" seconds
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                | expect         | db      |
      | conn_21 | False   | desc global1                       | hasStr{2021}   | schema1 |
      | conn_21 | true    | alter table global1 drop name      | success        | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-3"


  @skip_restart @btrace   @restore_mysql_config
  Scenario: query "show @@binlog.status" timeout, do ddl #2
    """
    {'restore_mysql_config':{'mysql-master1':{'log-bin':0,'binlog_format':0,'relay-log':0}}}
    """
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /sleepWhenClearIfSessionClosed/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
      """
    #global table ddl
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-2"
    Given execute sqls in "dble-2" at background
      | conn    | toClose | sql                                                 | db      |
      | conn_21 | true    | alter table global1 add age int default 2020122001  | schema1 |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      wait all session finished
      """
   # during "hang",to check on zk cluster has binlog_pause "status"
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "1"
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-2"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      wait all session finished
      """
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                  | expect              | db      |
      | conn_31 | false   | insert into global1(id) values (1)   | success             | schema1 |
      | conn_31 | True    | select * from global1                | hasStr{2020122001}  | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Given delete file "/tmp/dble_user_query.log" on "dble-2"

    #global table online ddl
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-2"
    Given execute sqls in "dble-2" at background
      | conn    | toClose | sql                                  | db      |
      | conn_21 | true    | create index suoyin ON global2(id)   | schema1 |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      wait all session finished
      """
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "1"
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-2"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      wait all session finished
      """
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                  | expect                         | db      |
      | conn_31 | True    | create index suoyin ON global2(id)   | Duplicate key name 'suoyin'    | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Given delete file "/tmp/dble_user_query.log" on "dble-2"

    #sharding table ddl
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-3"
    Given execute sqls in "dble-3" at background
      | conn    | toClose | sql                                                   | db      |
      | conn_31 | true    | alter table sharding2 add age int default 2020122002  | schema1 |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      wait all session finished
      """
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "1"
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-3"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      wait all session finished
      """
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                          | expect              | db      |
      | conn_21 | false   | insert into sharding2(id,fid) values (1,1)   | success             | schema1 |
      | conn_21 | True    | select * from sharding2                      | hasStr{2020122002}  | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Given delete file "/tmp/dble_user_query.log" on "dble-3"

    #sharding table ddl
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn    | toClose | sql                                                   | db      |
      | conn_11 | true    | alter table sharding4 add age int default 2020122003  | schema1 |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      timeout while waiting for unfinished distributed transactions
      """
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      timeout while waiting for unfinished distributed transactions
      """
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                          | expect              | db      |
      | conn_21 | false   | insert into sharding4(id,name) values (1,1)  | success             | schema1 |
      | conn_21 | True    | select * from sharding4                      | hasStr{2020122003}  | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Given delete file "/tmp/dble_user_query.log" on "dble-1"

    #ER table online ddl
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-3"
    Given execute sqls in "dble-3" at background
      | conn    | toClose | sql                                          | db      |
      | conn_31 | true    | alter table child1 add index ceshi(name)     | schema1 |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      wait all session finished
      """
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "1"
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-3"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      wait all session finished
      """
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                          | expect                         | db      |
      | conn_21 | True    | alter table child1 add index ceshi(name)     | Duplicate key name 'ceshi'     | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Given delete file "/tmp/dble_user_query.log" on "dble-3"

    #sing table ddl,the singtable doing ddl "hang",but doing "show @@binlog.status" donot "hang"
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn    | toClose | sql                                               | db      |
      | conn_11 | true    | alter table sing1 add age int default 2020122004  | schema1 |
    Then execute "admin" cmd  in "dble-2" at background
      | conn    | toClose | sql                  | db               |
      | conn_21 | true    | show @@binlog.status | dble_information |
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-2"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                               | expect              | db      |
      | conn_21 | false   | insert into sing1(id) values (1)  | success             | schema1 |
      | conn_21 | True    | select * from sing1               | hasStr{2020122004}  | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-2"
    Given delete file "/tmp/dble_user_query.log" on "dble-1"

    #nosharding table ddl,the noshardingtable doing ddl "hang",but doing "show @@binlog.status" donot "hang"
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn    | toClose | sql                                                      | db      |
      | conn_11 | true    | alter table no_sharding1 add age int default 2020122005  | schema1 |
    Then execute "admin" cmd  in "dble-2" at background
      | conn    | toClose | sql                  | db               |
      | conn_21 | true    | show @@binlog.status | dble_information |
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-2"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                             | expect              | db      |
      | conn_21 | false   | insert into no_sharding1(id,name) values (1,1)  | success             | schema1 |
      | conn_21 | True    | select * from no_sharding1                      | hasStr{2020122005}  | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-2"
    Given delete file "/tmp/dble_user_query.log" on "dble-1"

    #vertical table ddl,the verticaltable doing ddl "hang",but doing "show @@binlog.status" donot "hang"
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn    | toClose | sql                                                      | db      |
      | conn_11 | true    | alter table vertical1 add age int default 2020122006     | schema2 |
    Then execute "admin" cmd  in "dble-2" at background
      | conn    | toClose | sql                  | db               |
      | conn_21 | true    | show @@binlog.status | dble_information |
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-2"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                          | expect              | db      |
      | conn_21 | false   | insert into vertical1(id) values (1)         | success             | schema2 |
      | conn_21 | True    | select * from vertical1                      | hasStr{2020122006}  | schema2 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-2"
    Given delete file "/tmp/dble_user_query.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-3"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-3"


  @skip_restart  @btrace @restore_mysql_config
  Scenario: during "transaction" ,the admin cmd of "show @@binlog.status" be blocked,and set timeout  #3
    """
    {'restore_mysql_config':{'mysql-master1':{'log-bin':0,'binlog_format':0,'relay-log':0}}}
    """
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose | sql                     | expect  |
      | conn_2  | False    | show databases         | success |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql               | expect  | db      |
      | conn_21 | False   | select 1          | success | schema1 |
      | conn_22 | False   | select 1          | success | schema1 |
      | conn_23 | False   | select 1          | success | schema1 |
      | conn_24 | False   | select 1          | success | schema2 |
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql               | expect  | db      |
      | conn_31 | False   | select 1          | success | schema1 |
      | conn_32 | False   | select 1          | success | schema1 |
      | conn_33 | False   | select 1          | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                | expect  | db      |
      | conn_11 | False   | begin                              | success | schema1 |
      | conn_11 | False   | insert into global1 values(2,2)    | success | schema1 |
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
      /checkBackupStatus/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    #route differ node would "hang"
    Given prepare a thread execute sql "commit" with "conn_11"
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
      """
      get into NonBlockingSession,start sleep
      """
     Then execute "admin" cmd  in "dble-2" at background
      | conn    | toClose | sql                  | db               |
      | conn_2  | False   | show @@binlog.status | dble_information |
    Given prepare a thread execute sql "insert into global1 values (3,3)" with "conn_31"
    Given prepare a thread execute sql "insert into global2 values (1)" with "conn_32"
    Given prepare a thread execute sql "insert into sharding2 values (1,1,1),(2,2,2)" with "conn_21"
    #route one node wouldn't "hang" ,would succes
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                                   | expect  | db      |
      | conn_33 | true    | insert into sharding4 values (1,1,1),(5,5,5)          | success | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                               | expect  | db      |
      | conn_22 | true    | insert into sing1 values (1,1),(2,2)              | success | schema1 |
      | conn_23 | true    | insert into no_sharding1 values (1,1,1),(2,2,2)   | success | schema1 |
      | conn_24 | true    | insert into vertical1 values (1,1),(2,2)          | success | schema2 |
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-2"
      """
      wait all session finished
      172.100.9.6:3306
      """
   # check on zk cluster has binlog_pause "status"
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "1"
    #wait 15s,because btrace sleep 15s,create timeout showBinlogStatusTimeout=5000
    Given sleep "15" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-2"
      """
      wait all session finished
      """
   # check on zk cluster hasn't binlog_pause "status"
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "0"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                | expect      | db      |
      | conn_11 | False   | select * from global1              | length{(4)} | schema1 |
      | conn_11 | true    | select * from global2              | length{(1)} | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                | expect      | db      |
      | conn_21 | False   | select * from sharding2            | length{(3)} | schema1 |
      | conn_21 | true    | select * from sharding4            | length{(3)} | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                | expect      | db      |
      | conn_31 | False   | select * from sing1                | length{(3)} | schema1 |
      | conn_32 | true    | select * from no_sharding1         | length{(3)} | schema1 |
      | conn_32 | true    | select * from vertical1            | length{(3)} | schema2 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"


  @skip_restart @btrace @restore_mysql_config
  Scenario: query "show @@binlog.status" don't timeout, do ddl #4
    """
    {'restore_mysql_config':{'mysql-master1':{'log-bin':0,'binlog_format':0,'relay-log':0}}}
    """
    Given stop dble cluster and zk service
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      s/showBinlogStatusTimeout=5000/showBinlogStatusTimeout=20000/
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-2" with sed cmds
      """
      s/showBinlogStatusTimeout=5000/showBinlogStatusTimeout=20000/
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-3" with sed cmds
      """
      s/showBinlogStatusTimeout=5000/showBinlogStatusTimeout=20000/
      """
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order
   #set sleep time < 20s
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /sleepWhenClearIfSessionClosed/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
      """
    #global table ddl
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-2"
    Given execute sqls in "dble-2" at background
      | conn    | toClose | sql                                                 | db      |
      | conn_21 | true    | alter table global1 add tal int default 2020122801  | schema1 |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
   # during "hang",to check on zk cluster has binlog_pause "status"
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "1"
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-2"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                  | expect              | db      |
      | conn_31 | false   | insert into global1(id) values (2)   | success             | schema1 |
      | conn_31 | True    | select * from global1                | hasStr{2020122801}  | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Given delete file "/tmp/dble_user_query.log" on "dble-2"

    #global table online ddl
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-2"
    Given execute sqls in "dble-2" at background
      | conn    | toClose | sql                                  | db      |
      | conn_21 | true    | create index index1 ON global2(id)   | schema1 |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "1"
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-2"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                  | expect                         | db      |
      | conn_31 | True    | create index index1 ON global2(id)   | Duplicate key name 'index1'    | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Given delete file "/tmp/dble_user_query.log" on "dble-2"

    #sharding table ddl
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-3"
    Given execute sqls in "dble-3" at background
      | conn    | toClose | sql                                                   | db      |
      | conn_31 | true    | alter table sharding2 add tal int default 2020122802  | schema1 |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "1"
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-3"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                          | expect              | db      |
      | conn_21 | false   | insert into sharding2(id,fid) values (2,2)   | success             | schema1 |
      | conn_21 | True    | select * from sharding2                      | hasStr{2020122802}  | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Given delete file "/tmp/dble_user_query.log" on "dble-3"

    #sharding table ddl
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn    | toClose | sql                                                   | db      |
      | conn_11 | true    | alter table sharding4 add tal int default 2020122803  | schema1 |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                          | expect              | db      |
      | conn_21 | false   | insert into sharding4(id,name) values (2,2)  | success             | schema1 |
      | conn_21 | True    | select * from sharding4                      | hasStr{2020122803}  | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Given delete file "/tmp/dble_user_query.log" on "dble-1"

    #ER table online ddl
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-3"
    Given execute sqls in "dble-3" at background
      | conn    | toClose | sql                                          | db      |
      | conn_31 | true    | alter table child1 add index index2(name)    | schema1 |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "1"
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-3"
    Given destroy btrace threads list
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.6:3306
      172.100.9.5:3306
      """
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                          | expect                         | db      |
      | conn_21 | True    | alter table child1 add index index2(name)    | Duplicate key name 'index2'    | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Given delete file "/tmp/dble_user_query.log" on "dble-3"
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-3"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-3"


  @skip_restart  @btrace @restore_mysql_config
  Scenario: during "transaction" ,the commit would "hang" #5
    """
    {'restore_mysql_config':{'mysql-master1':{'log-bin':0,'binlog_format':0,'relay-log':0}}}
    """
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                    | expect  | db      |
      | conn_21 | False   | begin                                  | success | schema1 |
      | conn_21 | False   | insert into global1 values (1,1,1)     | success | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql              | expect  | db      |
      | conn_31 | False   | select 1         | success | schema1 |
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /ShowBinlogStatus/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    #the query will be "hang"
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Given prepare a thread execute sql "commit" with "conn_21"
    Given prepare a thread execute sql "alter table global1 add name int" with "conn_31"
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
      """
      get into ShowBinlogStatus,start sleep
      """
   # during "hang",to check on zk cluster has binlog_pause "status"
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "1"
    #"hang" query has not result
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.5:3306
      172.100.9.6:3306
      """
    #wait 15s,because btrace sleep 15s
    Given sleep "15" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
   # check on zk cluster hasn't binlog_pause "status"
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "0"
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.5:3306
      172.100.9.6:3306
      """
    Then execute sql in "dble-3" in "user" mode
      | conn      | toClose | sql                      | expect          | db      |
      | conn_31   | true    | desc global1             | length{(4)}     | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn      | toClose | sql                              | expect         | db      |
      | conn_21   | false   | select * from global1            | length{(6)}    | schema1 |
      | conn_21   | true    | alter table global1 drop name   | success        | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"


  @skip_restart  @btrace @restore_mysql_config
  Scenario: during "transaction" ,the admin cmd of "show @@binlog.status" be blocked,and set not timeout  #6
    """
    {'restore_mysql_config':{'mysql-master1':{'log-bin':0,'binlog_format':0,'relay-log':0}}}
    """
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose | sql                     | expect  |
      | conn_2  | False    | show databases         | success |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql               | expect  | db      |
      | conn_21 | False   | select 1          | success | schema1 |
      | conn_22 | False   | select 1          | success | schema1 |
      | conn_23 | False   | select 1          | success | schema1 |
      | conn_24 | False   | select 1          | success | schema2 |
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql               | expect  | db      |
      | conn_31 | False   | select 1          | success | schema1 |
      | conn_32 | False   | select 1          | success | schema1 |
      | conn_33 | False   | select 1          | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                | expect  | db      |
      | conn_11 | False   | begin                              | success | schema1 |
      | conn_11 | False   | select * from global1              | success | schema1 |
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
      /checkBackupStatus/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(18000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    #route differ node would "hang"
    Given prepare a thread execute sql "commit" with "conn_11"
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
      """
      get into NonBlockingSession,start sleep
      """
     Then execute "admin" cmd  in "dble-2" at background
      | conn    | toClose | sql                  | db               |
      | conn_2  | False   | show @@binlog.status | dble_information |
    Given prepare a thread execute sql "insert into global1 values (4,4,4)" with "conn_31"
    Given prepare a thread execute sql "insert into global2 values (2)" with "conn_32"
    Given prepare a thread execute sql "insert into sharding2 values (1,1,1,1),(2,2,2,2)" with "conn_21"
    #route one node wouldn't "hang" ,would succes
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                                  | expect  | db      |
      | conn_33 | true    | insert into sharding4 values (1,1,1,1),(5,5,5,5)     | success | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                             | expect  | db      |
      | conn_22 | true    | insert into sing1 values (3,3),(4,4)            | success | schema1 |
      | conn_23 | true    | insert into no_sharding1 values (3,3,3)         | success | schema1 |
      | conn_24 | true    | insert into vertical1 values (3,3)              | success | schema2 |
   # check on zk cluster has binlog_pause "status"
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "1"
    #wait 18s,because btrace sleep 18s,create not timeout ,showBinlogStatusTimeout=20000
    Given sleep "18" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-2"
      """
      wait all session finished
      """
   # check on zk cluster hasn't binlog_pause "status"
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "0"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                | expect      | db      |
      | conn_11 | False   | select * from global1              | length{(7)} | schema1 |
      | conn_11 | true    | select * from global2              | length{(2)} | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                | expect      | db      |
      | conn_21 | False   | select * from sharding2            | length{(6)} | schema1 |
      | conn_21 | true    | select * from sharding4            | length{(6)} | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                | expect      | db      |
      | conn_31 | False   | select * from sing1                | length{(5)} | schema1 |
      | conn_32 | true    | select * from no_sharding1         | length{(4)} | schema1 |
      | conn_32 | true    | select * from vertical1            | length{(4)} | schema2 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"


  @btrace @restore_mysql_config
  Scenario: during query ,one dble stop,check other dble status #7
    """
    {'restore_mysql_config':{'mysql-master1':{'log-bin':0,'binlog_format':0,'relay-log':0}}}
    """
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "0"
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /ShowBinlogStatus/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause/status | grep "1, 2, 3" | wc -l
      """
    Then check result "A" value is "1"
    Given stop dble in "dble-1"
    Then execute sql in "dble-2" in "admin" mode
      | conn     | toClose | sql                      | expect                                               |
      | conn_2   | true    | show @@binlog.status     | There is another command is showing BinlogStatus     |
    Given sleep "15" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    Given start dble in "dble-1"
    Then execute sql in "dble-2" in "admin" mode
      | conn     | toClose | sql                      | expect     |
      | conn_2   | true    | show @@binlog.status     | success    |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                          | expect  | db      |
      | conn_1 | True    | drop table if exists vertical1                               | success | schema2 |
      | conn_0 | False   | drop table if exists global1                                 | success | schema1 |
      | conn_0 | False   | drop table if exists global2                                 | success | schema1 |
      | conn_0 | False   | drop table if exists sharding4                               | success | schema1 |
      | conn_0 | False   | drop table if exists sharding2                               | success | schema1 |
      | conn_0 | False   | drop table if exists child1                                  | success | schema1 |
      | conn_0 | False   | drop table if exists sing1                                   | success | schema1 |
      | conn_0 | True    | drop table if exists no_sharding1                            | success | schema1 |
