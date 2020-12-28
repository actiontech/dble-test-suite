# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/12/25

Feature: test "binlog" in zk cluster
  # Pull the consistent binlog line
  ##########case points:
  #  1.in green area,the session of "commit" be blocked
  #  2.in red area,the admin cmd of session "show @@binlog.status" be blocked
  #  3.in red area,the admin cmd of session "show @@binlog.status" be blocked because sql ddl
  #  4.

#  @restore_mysql_service
  @skip_restart
  Scenario: prepare  #0
#    """
#    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}},{'mysql-slave1':{'start_mysql':1}},{'mysql-slave2':{'start_mysql':1}}}
#    """
#    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
#     """
#     /log-bin=/d
#     /binlog_format=/d
#     /relay-log=/d
#     /server-id/a log-bin=mysql-bin
#     /server-id/a binlog_format=row
#     /server-id/a relay-log=mysql-relay-bin
#     """
#    Given restart mysql in "mysql-slave1" with sed cmds to update mysql config
#     """
#     /log-bin=/d
#     /binlog_format=/d
#     /relay-log=/d
#     /server-id/a log-bin=mysql-bin
#     /server-id/a binlog_format=row
#     /server-id/a relay-log=mysql-relay-bin
#     """
#    Given restart mysql in "mysql-slave2" with sed cmds to update mysql config
#     """
#     /log-bin=/d
#     /binlog_format=/d
#     /relay-log=/d
#     /server-id/a log-bin=mysql-bin
#     /server-id/a binlog_format=row
#     /server-id/a relay-log=mysql-relay-bin
#     """
    Given stop dble cluster and zk service
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
          <singleTable name="sing2" shardingNode="dn2" />
        </schema>

        <schema name="schema2" shardingNode="dn2"/>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
       <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
          <heartbeat>show slave status</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
          <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10"/>
          <dbInstance name="hostS2" password="111111" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10"/>
       </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """
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
      /showBinlogStatusTimeout=/d
      $a showBinlogStatusTimeout=20000
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-2" with sed cmds
      """
      /showBinlogStatusTimeout=/d
      $a showBinlogStatusTimeout=20000
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-3" with sed cmds
      """
      /showBinlogStatusTimeout=/d
      $a showBinlogStatusTimeout=20000
      """
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order
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
      | conn_0 | False   | drop table if exists sing2                                   | success | schema1 |
      | conn_0 | False   | drop table if exists no_sharding1                            | success | schema1 |
      | conn_0 | False   | create table global1 (id int)                                | success | schema1 |
      | conn_0 | False   | create table global2 (id int)                                | success | schema1 |
      | conn_0 | False   | create table sharding4 (id int, name int)                    | success | schema1 |
      | conn_0 | False   | create table sharding2 (id int, fid int)                     | success | schema1 |
      | conn_0 | False   | create table child1 (fid int,name int)                       | success | schema1 |
      | conn_0 | False   | create table sing1 (id int)                                  | success | schema1 |
      | conn_0 | False   | create table sing2 (id int)                                  | success | schema1 |
      | conn_0 | True    | create table no_sharding1 (id int, name int)                 | success | schema1 |


  @skip_restart  @btrace
  Scenario: in green area,the commit of session be blocked,do_execute_query  #1

    # case 1.in green area,the commit of session be blocked,before hang ensure  all open sessions are still connected
    Then execute sql in "dble-2" in "user" mode
      | conn  c | toClose | sql                                | expect  | db      |
      | conn_21 | False   | alter table global1 add name int   | success | schema1 |
      | conn_21 | False   | begin                              | success | schema1 |
      | conn_21 | False   | insert into global1 values (1,1)   | success | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql              | expect  | db      |
      | conn_31 | False   | select 1         | success | schema1 |
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /ShowBinlogStatus/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    #the query will be "hang"
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                  | db               |
      | conn_1  | true    | show @@binlog.status | dble_information |
    Then execute "user" cmd  in "dble-2" at background
      | conn    | toClose | sql            | db      |
      | conn_21 | true    | commit         | schema1 |
    Then execute "user" cmd  in "dble-3" at background
      | conn    | toClose | sql                                      | db      |
      | conn_31 | true    | alter table global1 add name int         | schema1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
      """
      get into ShowBinlogStatus,start sleep
      """
   # during "hang",to check on zk cluster has binlog_pause "status" ,and has ddl_lock
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then get result of oscmd named "B" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.global1" | wc -l
      """
    Then check result "A" value is "1"
    Then check result "B" value is "1"
    #"hang" query has not result
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      172.100.9.5:3306
      172.100.9.6:3306
      """
    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-3"
      """
      ERROR
      """
    #wait 20s,because btrace sleep 20s
    Given sleep "22" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    # check on zk cluster hasn't binlog_pause "status" ,and hasn't ddl_lock
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then get result of oscmd named "B" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/ddl_lock | grep "schema1.global1" | wc -l
      """
    Then check result "A" value is "0"
    Then check result "B" value is "0"
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      Url
      172.100.9.5:3306
      172.100.9.6:3306
      """
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-3"
      """
      ERROR
      Duplicate column name
      """
    Then execute sql in "dble-3" in "user" mode
      | conn      | toClose | sql                      | expect          | db      |
      | conn_31   | true    | desc global1             | length{(2)}     | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn      | toClose | sql                              | expect         | db      |
      | conn_21   | false   | select * from global1            | length{(1)}    | schema1 |
      | conn_21   | true    | alter table global1 drop name    | success        | schema1 |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Given delete file "/tmp/dble_user_query.log" on "dble-3"
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"


   @skip_restart  @btrace
  Scenario: in red area,the admin cmd of "show @@binlog.status " be blocked,do_execute_query  #2
    # 2.1 in red area,the "show @@binlog.status " be blocked
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
      | conn   | toClose | sql                                | expect  | db      |
      | conn_1 | False   | begin                              | success | schema1 |
      | conn_1 | False   | insert into global1 values(2)      | success | schema1 |
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /checkBackupStatus/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    #sleep 2s,because this btrace has returen methon
    Given sleep "2" seconds
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    #route differ node would "hang"
    Then execute "user" cmd  in "dble-1" at background
      | conn    | toClose | sql            | db      |
      | conn_11 | true    | commit         | schema1 |
    Then execute "admin" cmd  in "dble-2" at background
      | conn    | toClose | sql                  | db               |
      | conn_2  | true    | show @@binlog.status | dble_information |
     Then execute "user" cmd  in "dble-3" at background
      | conn    | toClose | sql                                   | db      |
      | conn_31 | true    | insert into global1 values (3)        | schema1 |
      | conn_32 | true    | insert into global2 values (1)        | schema1 |
     Then execute "user" cmd  in "dble-2" at background
      | conn    | toClose | sql                                             | db      |
      | conn_21 | true    | insert into sharding2 values (1,1),(2,2)        | schema1 |
    #route one node wouldn't "hang" ,would succes
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                               | expect  | db      |
      | conn_33 | true    | insert into sharding4 values (1,1),(5,5)          | success | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                           | expect  | db      |
      | conn_22 | true    | insert into sing1 values (1),(2)              | success | schema1 |
      | conn_23 | true    | insert into no_sharding1 values (1,1),(2,2)   | success | schema1 |
      | conn_24 | true    | insert into vertical1 values (1),(2)          | success | schema2 |
   # during "hang",to check on zk cluster has binlog_pause "status"
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "1"
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-2"
      """
      ERROR
      wait all session finished
      """
    #wait 20s,because btrace sleep 20s
    Given sleep "30" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    # check on zk cluster hasn't binlog_pause "status"
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/binlog_pause | grep "status" | wc -l
      """
    Then check result "A" value is "0"
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-2"
      """
      ERROR
      wait all session finished
      """
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                | expect      | db      |
      | conn_11 | False   | select * from global1              | length{(3)} | schema1 |
      | conn_11 | true    | select * from global2              | length{(1)} | schema1 |
     Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                | expect      | db      |
      | conn_21 | False   | select * from sharding2            | length{(2)} | schema1 |
      | conn_21 | true    | select * from sharding4            | length{(2)} | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                | expect      | db      |
      | conn_31 | False   | select * from sing1                | length{(2)} | schema1 |
      | conn_31 | true    | select * from no_sharding1         | length{(2)} | schema1 |
      | conn_32 | true    | select * from vertical1            | length{(2)} | schema2 |












#
#    # because cluster.cnf "showBinlogStatusTimeout" 20000,so sleeptime more than 20000
#    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
#    """
#    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
#    /checkBackupStatus/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(35000L)/;/\}/!ba}
#    """
#    #sleep 2s,because this btrace has returen methon
#    Given sleep "2" seconds
#    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
#    #case the query will be "hang"
##    Then execute admin cmd  in "dble-1" at background
##      | conn   | toClose | sql                  | db               |
##      | conn_0 | true    | show @@binlog.status | dble_information |
#    Given prepare a thread execute sql "show @@binlog.status" with "conn_2" and save resultset in "1"
#    Given prepare a thread execute sql "commit" with "conn_1" and save resultset in "2"
#    Given prepare a thread execute sql "insert into global1 values (3)" with "conn_3" and save resultset in "3"
#    Given prepare a thread execute sql "insert into sharding2 values (1,1),(2,2)" with "conn_21" and save resultset in "4"
#    Given prepare a thread execute sql "insert into global2 values (1)" with "conn_31" and save resultset in "5"
#    #dml not hang
#    Then execute sql in "dble-3" in "user" mode
#      | conn    | toClose | sql                                               | expect  | db      |
#      | conn_32 | true    | insert into sharding4 values (1,1),(5,5)          | success | schema1 |
##      # before the "conn_2" sql "show @@binlog.status" return (1105, "1:Error can't wait all session finished ;"),the hang dml donot finished,check values
##      | conn_32 | false   | select * from global1           | length{(3)}   | schema1 |
##      | conn_32 | false   | select * from global2           | length{(2)}   | schema1 |
##      | conn_32 | true    | select * from sharding2         | length{(2)}   | schema1 |
#    Then execute sql in "dble-2" in "user" mode
#      | conn    | toClose | sql                                           | expect  | db      |
#      | conn_22 | true    | insert into sing1 values (1),(2)              | success | schema1 |
#      | conn_23 | true    | insert into no_sharding1 values (1,1),(2,2)   | success | schema1 |
#      | conn_24 | true    | insert into vertical1 values (1),(2)          | success | schema2 |
###    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
###      """
##
###      """
#    Given sleep "35" seconds
#    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
#    """
#    get into NonBlockingSession,start sleep
#    """
###    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
###      """
##
###      """
#    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
#    Given destroy btrace threads list
#    Given destroy sql threads list
#    Then execute sql in "dble-2" in "admin" mode
#      | conn      | toClose | sql                           | expect      |
#      | conn_2    | true    | show @@binlog.status          | success     |
#    Then execute sql in "dble-1" in "user" mode
#      | conn      | toClose | sql                             | expect        | db      |
#      | conn_1    | false   | select * from global1           | length{(5)}   | schema1 |
#      | conn_1    | true    | select * from global2           | length{(3)}   | schema1 |
#    Then execute sql in "dble-2" in "user" mode
#      | conn      | toClose | sql                           | expect          | db      |
#      | conn_21   | false   | select * from sharding2       | length{(4)}     | schema1 |
#      | conn_21   | true    | select * from sharding4       | length{(6)}     | schema1 |
#    Then execute sql in "dble-3" in "user" mode
#      | conn      | toClose | sql                              | expect          | db      |
#      | conn_3    | true    | select * from sing1              | length{(4)}     | schema1 |
#      | conn_31   | true    | select * from no_sharding1       | length{(4)}     | schema1 |
#      | conn_31   | true    | select * from vertical1          | length{(4)}     | schema2 |

##case 2.2.in red area,the admin cmd of "show @@binlog.status " be blocked and the blocked not timeout
#   Given execute single sql in "dble-2" in "admin" mode and save resultset in "compare2_1"
#      | conn   | toClose | sql                  |
#      | conn_2 | False   | show @@binlog.status |
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                | expect  | db      |
#      | conn_1 | False   | begin                              | success | schema1 |
#      | conn_1 | False   | select * from global1              | success | schema1 |
##    Then execute sql in "dble-2" in "admin" mode
##      | conn   | toClose | sql                  | expect  |
##      | conn_2 | False   | show databases       | success |
#    Then execute sql in "dble-2" in "user" mode
#      | conn    | toClose | sql               | expect  | db      |
#      | conn_21 | False   | select 1          | success | schema1 |
#      | conn_22 | False   | select 1          | success | schema1 |
#      | conn_23 | False   | select 1          | success | schema1 |
#      | conn_24 | False   | select 1          | success | schema2 |
#    Then execute sql in "dble-3" in "user" mode
#      | conn    | toClose | sql               | expect  | db      |
#      | conn_3  | False   | select 1          | success | schema1 |
#      | conn_31 | False   | select 1          | success | schema1 |
#      | conn_32 | False   | select 1          | success | schema1 |
#    # because cluster.cnf "showBinlogStatusTimeout" 30000,so sleeptime less than 30000
#    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
#    """
#    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
#    /checkBackupStatusbinlog/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(25000L)/;/\}/!ba}
#    """
#    #sleep 2s,because this btrace has returen methon
#    Given sleep "5" seconds
#    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
#    #dml hang
#    Given prepare a thread execute sql "show @@binlog.status" with "conn_2"
#    Given prepare a thread execute sql "commit" with "conn_1"
#    Given prepare a thread execute sql "insert into global1 values (4)" with "conn_3"
#    Given prepare a thread execute sql "insert into global2 values (2)" with "conn_31"
#    Given prepare a thread execute sql "insert into sharding2 values (3,3),(4,4)" with "conn_21"
#    #dml not hang
#    Then execute sql in "dble-3" in "user" mode
#      | conn    | toClose | sql                                               | expect  | db      |
#      | conn_32 | false   | insert into sharding4 values (2,2),(6,6)          | success | schema1 |
#    #before the "conn_1" sql "commit" return result,(the time less 25s),the hang dml donot finished,check values
#      | conn_32 | false   | select * from global1           | length{(5)}     | schema1 |
#      | conn_32 | false   | select * from global2           | length{(3)}     | schema1 |
#      | conn_32 | true    | select * from sharding2         | length{(4)}     | schema1 |
#    Then execute sql in "dble-2" in "user" mode
#      | conn    | toClose | sql                                       | expect  | db      |
#      | conn_22 | true    | insert into sing1 values (3)              | success | schema1 |
#      | conn_23 | true    | insert into no_sharding1 values (3,3)     | success | schema1 |
#      | conn_24 | true    | insert into vertical1 values (5)          | success | schema2 |
#    Given sleep "25" seconds
#    Given execute single sql in "dble-2" in "admin" mode and save resultset in "compare2_2"
#      | conn   | toClose | sql                    | db               |
#      | conn_2 | true    | show @@binlog.status   | dble_information |
#    Then check resultsets "compare2_1" and "compare2_2" are same in following columns
#      | column             | column_index |
#      | Url                | 0            |
#      | File               | 1            |
##    Then execute sql in "dble-2" in "admin" mode
##      | conn      | toClose | sql                           | expect      |
##      | conn_2    | true    | show @@binlog.status          | success     |
#    Then execute sql in "dble-1" in "user" mode
#      | conn      | toClose | sql                             | expect        | db      |
#      | conn_1    | false   | select * from global1           | length{(6)}   | schema1 |
#      | conn_1    | true    | select * from global2           | length{(4)}   | schema1 |
#    Then execute sql in "dble-2" in "user" mode
#      | conn      | toClose | sql                           | expect          | db      |
#      | conn_21   | false   | select * from sharding2       | length{(6)}     | schema1 |
#      | conn_21   | true    | select * from sharding4       | length{(8)}     | schema1 |
#    Then execute sql in "dble-3" in "user" mode
#      | conn      | toClose | sql                              | expect          | db      |
#      | conn_3    | true    | select * from sing1              | length{(5)}     | schema1 |
#      | conn_31   | true    | select * from no_sharding1       | length{(5)}     | schema1 |
#      | conn_31   | true    | select * from vertical1          | length{(5)}     | schema2 |
#
##case 3.1 in red area,the admin cmd of session "show @@binlog.status" be blocked because sql ddl  but blocked not timeout
#    #case set showBinlogStatusTimeout values less ddl timevalues
#    #case  global table
#    Given prepare a thread execute sql "insert into global1 values (4)" with "conn_3"
#
#
##    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
##    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
#    Given delete file "/tmp/dble_user_query.log" on "dble-1"
#    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
#    Given delete file "/tmp/dble_user_query.log" on "dble-2"
#    Given delete file "/tmp/dble_admin_query.log" on "dble-2"
#    Given delete file "/tmp/dble_user_query.log" on "dble-3"
#    Given delete file "/tmp/dble_admin_query.log" on "dble-3"
#    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
#    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
