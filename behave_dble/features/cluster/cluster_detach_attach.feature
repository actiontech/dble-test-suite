# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/9/13

# DBLE0REQ-1002
Feature: check single dble detach or attach from cluster

  Scenario: check thread name after cluster @@detach, cluster @@attach #1
    Given delete file "/tmp/jstack.log" on "dble-1"
    Given delete file "/opt/dble/logs/dble_zk_online.log" on "dble-1"
    Given execute oscmd in "dble-1"
    """
    jstack -l `ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'` > /tmp/jstack.log
    """
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i 'Curator-PathChildrenCache' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "6"
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i 'Curator-Framework-0' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "1"
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i 'Curator-ConnectionStateManager-0' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "1"
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i '\-EventThread' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "1"
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i '\-SendThread' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql              | expect                                     |
      | conn_1 | False     | cluster @@detach | success                                    |
      | conn_1 | False     | cluster @@detach | illegal state: cluster is already detached |
      | conn_1 | False     | cluster @@detach | illegal state: cluster is already detached |
    Given delete file "/tmp/jstack.log" on "dble-1"
    Given execute oscmd in "dble-1"
    """
    jstack -l `ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'` > /tmp/jstack.log
    """
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i 'Curator-PathChildrenCache' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "0"
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i 'Curator-Framework-0' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "0"
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i 'Curator-ConnectionStateManager-0' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "0"
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i '\-EventThread' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "0"
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i '\-SendThread' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "0"
    Then check zk has "Y" the following values in "/dble/cluster-1/online" with retry "10,3" times in "dble-1"
      """
      [2,3]
      """
    Given delete file "/tmp/jstack.log" on "dble-1"
    Given delete file "/opt/dble/logs/dble_zk_online.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql              | expect                                 |
      | conn_1 | False     | cluster @@attach | success                                |
      | conn_1 | False     | cluster @@attach | illegal state: cluster is not detached |
      | conn_1 | True      | cluster @@attach | illegal state: cluster is not detached |
    Given execute oscmd in "dble-1"
    """
    jstack -l `ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'` > /tmp/jstack.log
    """
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i 'Curator-PathChildrenCache' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "6"
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i 'Curator-Framework-0' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "1"
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i 'Curator-ConnectionStateManager-0' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "1"
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i '\-EventThread' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "1"
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i '\-SendThread' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "1"
    Then check zk has "Y" the following values in "/dble/cluster-1/online" with retry "10,3" times in "dble-1"
      """
      [1,2,3]
      """
    Given delete file "/tmp/jstack.log" on "dble-1"
    Given delete file "/opt/dble/logs/dble_zk_online.log" on "dble-1"


  Scenario: check cluster @@detach, cluster @@attach command #2
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    /sequenceHandlerType/d
    $a sequenceHandlerType=4
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-2" with sed cmds
    """
    /sequenceHandlerType/d
    $a sequenceHandlerType=4
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-3" with sed cmds
    """
    /sequenceHandlerType/d
    $a sequenceHandlerType=4
    """
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="hostS2" url="172.100.9.6:3307" user="test" password="111111" maxCon="1000" minCon="10"/>
     </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
         <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" incrementColumn="pid" />
         <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
    """
    When Add some data in "sequence_conf.properties"
    """
    `schema1`.`sharding_4_t1`.MINID=1001
    `schema1`.`sharding_4_t1`.MAXID=20000
    `schema1`.`sharding_4_t1`.CURID=1000
    """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose   | sql                                                    | expect  | db      |
      | conn_0 | False     | drop table if exists sharding_4_t1                     | success | schema1 |
      | conn_0 | False     | drop table if exists sharding_4_t2                     | success | schema1 |
      | conn_0 | False     | create table sharding_4_t1(pid int, id int, name char) | success | schema1 |
      | conn_0 | False     | create table sharding_4_t2(id int, name char)          | success | schema1 |

    Then execute admin cmd "cluster @@detach"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql                                | expect                                                  |
      | conn_1 | False     | reload @@config_all                | Reload Failure, The reason is cluster is detached       |
      | conn_1 | False     | show @@binlog.status               | cluster is detached                                     |
      | conn_1 | False     | dbGroup @@disable name='ha_group1' | cluster is detached, you should attach cluster first.   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_A"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_A" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3306   | W     | 0        | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3306   | W     | 0        | false       |
      | ha_group2  | hostS2 | 172.100.9.6 | 3307   | R     | 0        | false       |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql                               | expect                                                |
      | conn_1 | False     | dbGroup @@enable name='ha_group1' | cluster is detached, you should attach cluster first. |
      | conn_1 | False     | dbGroup @@switch name='ha_group2' master='hostS2' | cluster is detached, you should attach cluster first. |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_B"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_B" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3306   | W     | 0        | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3306   | W     | 0        | false       |
      | ha_group2  | hostS2 | 172.100.9.6 | 3307   | R     | 0        | false       |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql                                                                           | expect                                                |
      | conn_1 | False     | pause @@shardingNode = 'dn1,dn2' and timeout = 10 ,queue = 10,wait_limit = 10 | cluster is detached, you should attach cluster first. |
      | conn_1 | False     | show @@pause                                                                  | hasnot{(('dn1',),('dn2',))}                           |
      | conn_1 | False     | resume                                                                        | cluster is detached, you should attach cluster first. |
      | conn_1 | False     | use dble_information                                                          | success |
      | conn_1 | False     | insert into dble_db_group(name, heartbeat_stmt, heartbeat_timeout, heartbeat_retry, rw_split_mode, delay_threshold, disable_ha) value ('ha_group5', 'select user()', 0, 1, 1, 100, 'false') | cluster is detached, you should attach cluster first. |
      | conn_1 | False     | update dble_db_group set rw_split_mode=3 where name='ha_group5'               | cluster is detached, you should attach cluster first. |
      | conn_1 | True      | delete from dble_db_group where name='ha_group5'                              | cluster is detached, you should attach cluster first. |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose   | sql                                                      | expect  | db      |
      | conn_0 | False     | drop table if exists sharding_4_t1                       | cluster is detached, you should attach cluster first. | schema1 |
      | conn_0 | False     | drop table if exists sharding_4_t2                       | cluster is detached, you should attach cluster first. | schema1 |
      | conn_0 | False     | create view test_view as select * from sharding_4_t2     | cluster is detached, you should attach cluster first. | schema1 |
      | conn_0 | False     | begin;insert into sharding_4_t2 values(1,1),(2,2);commit | success | schema1 |
      | conn_0 | False     | select * from sharding_4_t2                              | has{((1,'1'),(2,'2'))} | schema1 |
      | conn_0 | False     | update sharding_4_t2 set name=0 where id=1               | success | schema1 |
      | conn_0 | False     | delete from sharding_4_t2                                | success | schema1 |
      | conn_0 | False     | set xa=on; set autocommit=0                              | success | schema1 |
      | conn_0 | True      | insert into sharding_4_t2 values(3,3),(4,4);commit       | cluster is detached, you should attach cluster first. | schema1 |
      | conn_0 | False     | select * from sharding_4_t2                              | length{(0)} | schema1 |
      | conn_0 | False     | create view test_view as select * from sharding_4_t1     | cluster is detached, you should attach cluster first. | schema1 |
      | conn_0 | False     | insert into sharding_4_t1 (id, name) values (1,1),(2,2)  | cluster is detached, you should attach cluster first. | schema1 |
      | conn_0 | False     | select * from sharding_4_t1                              | length{(0)} | schema1 |
      | conn_0 | False     | update sharding_4_t1 set name=0 where id=1               | success | schema1 |
      | conn_0 | False     | begin;delete from sharding_4_t1;commit                   | success | schema1 |

    Then execute admin cmd "cluster @@attach"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql                                | expect  |
      | conn_1 | False     | reload @@config_all                | success |
      | conn_1 | False     | show @@binlog.status               | success |
      | conn_1 | False     | dbGroup @@disable name='ha_group1' | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_C"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_C" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3306   | W     | 0        | true        |
      | ha_group2  | hostM2 | 172.100.9.6 | 3306   | W     | 0        | false       |
      | ha_group2  | hostS2 | 172.100.9.6 | 3307   | R     | 0        | false       |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql                               | expect  |
      | conn_1 | False     | dbGroup @@enable name='ha_group1' | success |
      | conn_1 | False     | dbGroup @@switch name='ha_group2' master='hostS2' | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_D"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_D" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3306   | W     | 0        | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3306   | R     | 0        | false       |
      | ha_group2  | hostS2 | 172.100.9.6 | 3307   | W     | 0        | false       |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql                                                                           | expect  |
      | conn_1 | False     | dbGroup @@switch name='ha_group2' master='hostM2'                             | success |
      | conn_1 | False     | pause @@shardingNode = 'dn1,dn2' and timeout = 10 ,queue = 10,wait_limit = 10 | success |
      | conn_1 | False     | show @@pause                                                                  | has{(('dn1',), ('dn2',))} |
      | conn_1 | False     | resume                                                                        | success |
      | conn_1 | False     | use dble_information                                                          | success |
      | conn_1 | False     | insert into dble_db_group(name, heartbeat_stmt, heartbeat_timeout, heartbeat_retry, rw_split_mode, delay_threshold, disable_ha) value ('ha_group5', 'select user()', 0, 1, 1, 100, 'false') | success |
      | conn_1 | False     | update dble_db_group set rw_split_mode=3 where name='ha_group5'               | success |
      | conn_1 | True      | delete from dble_db_group where name='ha_group5'                              | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose   | sql                                                      | expect  | db      |
      | conn_0 | False     | drop table if exists sharding_4_t1                       | success | schema1 |
      | conn_0 | False     | create table sharding_4_t1(pid int, id int, name char)   | success | schema1 |
      | conn_0 | False     | drop table if exists sharding_4_t2                       | success | schema1 |
      | conn_0 | False     | create table sharding_4_t2(id int, name char)            | success | schema1 |
      | conn_0 | False     | begin;insert into sharding_4_t2 values(1,1),(2,2);commit | success | schema1 |
      | conn_0 | False     | select * from sharding_4_t2                              | has{((1,'1'),(2,'2'))} | schema1 |
      | conn_0 | False     | create view test_view as select * from sharding_4_t2     | success | schema1 |
      | conn_0 | False     | select * from test_view                                  | has{((1,'1'),(2,'2'))} | schema1 |
      | conn_0 | False     | drop view test_view                                      | success | schema1 |
      | conn_0 | False     | update sharding_4_t2 set name=0 where id=1               | success | schema1 |
      | conn_0 | False     | delete from sharding_4_t2                                | success | schema1 |
      | conn_0 | False     | set xa=on; set autocommit=0                              | success | schema1 |
      | conn_0 | False     | insert into sharding_4_t2 values(3,3),(4,4);commit       | success | schema1 |
      | conn_0 | False     | insert into sharding_4_t1 (id, name) values (1,1),(2,2)  | success | schema1 |
      | conn_0 | False     | select * from sharding_4_t1                              | has{((1001,1,'1'),(1002,2,'2'),)} | schema1 |
      | conn_0 | False     | update sharding_4_t1 set name=0 where id=1               | success | schema1 |
      | conn_0 | False     | begin;delete from sharding_4_t1;commit                   | success | schema1 |
      | conn_0 | False     | set xa=off                                               | success | schema1 |
      | conn_0 | False     | drop table if exists sharding_4_t1                       | success | schema1 |
      | conn_0 | True      | drop table if exists sharding_4_t2                       | success | schema1 |

  @btrace
  Scenario: check cluster @@detach and timeout less than default value when other sql is being executed #3
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Then restart dble in "dble-1" success
    Then restart dble in "dble-2" success
    Then restart dble in "dble-3" success

    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql              | expect  |
      | conn_1  | false     | cluster @@detach | success |
      | conn_2  | false     | cluster @@attach | success |
    Given update file content "./assets/BtraceClusterDetachAttach1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(12000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach timeout=1" with "conn_1" and save resultset in "detach_rs"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given prepare a thread execute sql "show @@general_log" with "conn_2"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Then check sql thread output in "detach_rs_err" by retry "10" times
    """
    detach cluster pause timeout
    """
    Then check sql thread output in "res" by retry "8" times
    """
    ('general_log', 'OFF'), ('general_log_file', '/opt/dble/general/general.log')
    """
    Given stop btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given stop btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql              | expect                                 |
      | conn_1 | True      | cluster @@attach | illegal state: cluster is not detached |

  @btrace
  Scenario: check cluster @@detach and timeout use default value 10s when other sql is being executed #4
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Then restart dble in "dble-1" success
    Then restart dble in "dble-2" success
    Then restart dble in "dble-3" success

    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql              | expect  |
      | conn_1  | false     | cluster @@detach | success |
      | conn_1  | false     | cluster @@attach | success |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                        | expect  | db      |
      | conn_3  | false     | drop table if exists sharding_4_t1         | success | schema1 |
      | conn_3  | false     | create table sharding_4_t1(pid int,id int) | success | schema1 |
    Given update file content "./assets/BtraceClusterDetachAttach1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(8000L)/;/\}/!ba}
    """
    # sleep time > detach timeout default value 10s
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(18000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1" and save resultset in "detach_rs"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given prepare a thread execute sql "create view test_view as select * from sharding_4_t1" with "conn_3"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Then check sql thread output in "detach_rs_err" by retry "10,2" times
    """
    detach cluster pause timeout
    """
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                | expect                 | db      | timeout |
      | conn_4  | true    | show tables                        | has{(('test_view',),)} | schema1 | 10      |
    Given stop btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given stop btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Given destroy sql threads list
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                | expect                | db      |
      | conn_3  | false   | drop view if exists test_view      | success               | schema1 |
      | conn_3  | true    | drop table if exists sharding_4_t1 | success               | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql              | expect                                 |
      | conn_1 | True      | cluster @@attach | illegal state: cluster is not detached |

  @btrace
  Scenario: check cluster @@detach and timeout greater than default value when other sql is being executed #5
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    /sequenceHandlerType/d
    $a sequenceHandlerType=4
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-2" with sed cmds
    """
    /sequenceHandlerType/d
    $a sequenceHandlerType=4
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-3" with sed cmds
    """
    /sequenceHandlerType/d
    $a sequenceHandlerType=4
    """
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
         <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" incrementColumn="pid" />
      </schema>
    """
    When Add some data in "sequence_conf.properties"
    """
    `schema1`.`sharding_4_t1`.MINID=1001
    `schema1`.`sharding_4_t1`.MAXID=20000
    `schema1`.`sharding_4_t1`.CURID=1000
    """
    Then execute admin cmd "reload @@config_all"

    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql              | expect  |
      | conn_1  | false     | cluster @@detach | success |
      | conn_1  | false     | cluster @@attach | success |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                        | expect  | db      |
      | conn_3  | false     | drop table if exists sharding_4_t1         | success | schema1 |
      | conn_3  | false     | create table sharding_4_t1(pid int,id int) | success | schema1 |
    Given update file content "./assets/BtraceClusterDetachAttach1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(8000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach timeout=20" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given prepare a thread execute sql "insert into sharding_4_t1 (id) values (1)" with "conn_3"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      | timeout |
      | conn_4  | true      | select * from sharding_4_t1        | length{(1)} | schema1 | 20      |
    Given stop btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given stop btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java.log" on "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql              | expect  |
      | conn_1  | true      | cluster @@attach | success |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      |
      | conn_3  | true      | drop table if exists sharding_4_t1 | success     | schema1 |

  @btrace
  Scenario: check cluster @@attach and timeout less than default value when other sql is being executed #6
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Then restart dble in "dble-1" success
    Then restart dble in "dble-2" success
    Then restart dble in "dble-3" success
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql              | expect  |
      | conn_1  | false     | cluster @@detach | success |
      | conn_2  | false     | show @@version   | success |
    Given update file content "./assets/BtraceClusterDetachAttach1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(12000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@attach timeout=1" with "conn_1" and save resultset in "detach_rs"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given prepare a thread execute sql "show @@general_log" with "conn_2"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Then check sql thread output in "detach_rs_err" by retry "10" times
    """
    attach cluster pause timeout
    """
    Then check sql thread output in "res" by retry "8" times
    """
    ('general_log', 'OFF'), ('general_log_file', '/opt/dble/general/general.log')
    """
    Given stop btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given stop btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql              | expect  |
      | conn_1 | true      | cluster @@attach | success |

  @btrace
  Scenario: check cluster @@attach and timeout use default value 10s when other sql is being executed #7
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    s/-DmanagerFrontWorker=1/-DmanagerFrontWorker=4/
    """
    Then restart dble in "dble-1" success
    Then restart dble in "dble-2" success
    Then restart dble in "dble-3" success
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql              | expect  |
      | conn_1  | false     | cluster @@detach | success |
      | conn_2  | false     | show @@version   | success |
    Given update file content "./assets/BtraceClusterDetachAttach1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(8000L)/;/\}/!ba}
    """
    # sleep time > detach timeout default value 10s
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(18000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@attach" with "conn_1" and save resultset in "attach_rs"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given prepare a thread execute sql "show @@general_log" with "conn_2"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Then from btrace sleep "18" seconds get sleep end time and save resultset in "show_end_time"
    Given check sql thread output in "res" by retry "20" times and check sleep time use "show_end_time"
    """
    ('general_log', 'OFF'), ('general_log_file', '/opt/dble/general/general.log')
    """
    Then check sql thread output in "attach_rs_err"
    """
    attach cluster pause timeout. some frontend connection is doing operation.
    """
    Given stop btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given stop btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql              | expect  |
      | conn_1 | true      | cluster @@attach | success |

  @btrace
  Scenario: check cluster @@attach and timeout greater than default value when other sql is being executed #8
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql              | expect  |
      | conn_1  | false     | cluster @@detach | success |
      | conn_2  | false     | show @@version   | success |
    Given update file content "./assets/BtraceClusterDetachAttach1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(8000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@attach timeout=20" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given prepare a thread execute sql "show @@general_log" with "conn_2" and save resultset in "show_rs"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Then from btrace sleep "15" seconds get sleep end time and save resultset in "show_end_time"
    Given check sql thread output in "show_rs_result" by retry "20" times and check sleep time use "show_end_time"
    """
    ('general_log', 'OFF'), ('general_log_file', '/opt/dble/general/general.log')
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql             | expect                                 |
      | conn_1 | true     | cluster @@attach | illegal state: cluster is not detached |
    Given stop btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given stop btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"

  @btrace
  Scenario: check cluster @@detach, cluster @@attach when other sql will be executed #9
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    /sequenceHandlerType/d
    $a sequenceHandlerType=4
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-2" with sed cmds
    """
    /sequenceHandlerType/d
    $a sequenceHandlerType=4
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-3" with sed cmds
    """
    /sequenceHandlerType/d
    $a sequenceHandlerType=4
    """
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
         <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" incrementColumn="pid" />
      </schema>
    """
    When Add some data in "sequence_conf.properties"
    """
    `schema1`.`sharding_4_t1`.MINID=1001
    `schema1`.`sharding_4_t1`.MAXID=20000
    `schema1`.`sharding_4_t1`.CURID=1000
    """
    Then execute admin cmd "reload @@config_all"

    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"

     Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql              | expect  |
      | conn_1  | false     | cluster @@detach | success |
      | conn_2  | false     | cluster @@attach | success |

    Given update file content "./assets/BtraceClusterDetachAttach2.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /waitOtherSessionBlocked/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """

    # check detach and manager command 执行集群命令时，有即将执行的管理端命令，集群命令先执行
    Given prepare a thread run btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1"
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "reload @@config_all" with "conn_2" and save resultset in "reload_rs"
    Then check sql thread output in "reload_rs_err" by retry "10" times
    """
    Reload Failure, The reason is cluster is detached
    """

    # check attach and manager command
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1" with "==2" times
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "pause @@shardingNode = 'dn1,dn2' and timeout = 10 ,queue = 10,wait_limit = 10" with "conn_2"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql           | expect                    | timeout |
      | conn_4 | False     | show @@pause  | has{(('dn1',), ('dn2',))} | 8       |
      | conn_4 | True      | resume        | success                   |         |
    Given stop btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                         | db      | expect  |
      | conn_33 | false     | drop table if exists sharding_4_t1          | schema1 | success |
      | conn_33 | false     | create table sharding_4_t1(pid int, id int) | schema1 | success |

    # check detach and ddl
    Given prepare a thread run btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1"
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "create view test_view as select * from sharding_4_t1" with "conn_33" and save resultset in "view_rs"
    Then check sql thread output in "view_rs_err" by retry "10" times
    """
    cluster is detached, you should attach cluster first.
    """

    # check attach and ddl
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1" with "==2" times
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "create view test_view as select * from sharding_4_t1" with "conn_33"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                                   | db      | expect      | timeout |
      | conn_34 | false     | insert into sharding_4_t1 (id) values (1),(2),(3),(4) | schema1 | success     |         |
      | conn_34 | true      | select * from test_view                               | schema1 | length{(4)} | 8       |
    Given stop btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"

    # check detach and xa
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                                  | db      | expect  |
      | conn_33 | false     | set xa=on;set autocommit=0;delete from sharding_4_t1 | schema1 | success |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1"
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "commit" with "conn_33" and save resultset in "commit_rs"
    Then check sql thread output in "commit_rs_err" by retry "10" times
    """
    cluster is detached, you should attach cluster first.
    """

    # check attach and xa
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1" with "==2" times
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "commit" with "conn_33"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                         | db      | expect      | timeout |
      | conn_34 | false     | select * from sharding_4_t1 | schema1 | length{(0)} |    8    |
      | conn_33 | true      | set xa=off                  | schema1 | success     |         |

    Given stop btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list

    # check detach and zk offset-step sequence
    Given prepare a thread run btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1"
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "insert into sharding_4_t1 (id) values (1),(2),(3),(4)" with "conn_34" and save resultset in "insert_rs"
    Then check sql thread output in "insert_rs_err" by retry "10" times
    """
    cluster is detached, you should attach cluster first.
    """

    # check attach and zk offset-step sequence
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1" with "==2" times
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "insert into sharding_4_t1 (id) values (5),(6),(7),(8)" with "conn_34"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                | db      | expect      | timeout |
      | conn_33 | false     | select * from sharding_4_t1        | schema1 | length{(4)} | 8       |
      | conn_33 | false     | drop view if exists test_view      | schema1 | success     |         |
      | conn_33 | true      | drop table if exists sharding_4_t1 | schema1 | success     |         |

    Given stop btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java" on "dble-1"


  @btrace
  Scenario: dble-1 is executing cluster sql, dble-2 is executing detach sql, dble-1 execute success #10
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java.log" on "dble-2"
    Given execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                      | expect                  | db               |
      | conn_1  | false     | select * from dble_table | hasNoStr{sharding_4_t2} | dble_information |
    Given execute sql in "dble-2" in "admin" mode
      | conn    | toClose   | sql                      | expect                  | db               |
      | conn_2  | false     | select * from dble_table | hasNoStr{sharding_4_t2} | dble_information |

    Given update file content "./assets/BtraceClusterDetachAttach5.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /zkOnEvent/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(6000L)/;/\}/!ba}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
         <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
      </schema>
    """
    # check reload
    Given prepare a thread run btrace script "BtraceClusterDetachAttach5.java" in "dble-2"
    Given prepare a thread execute sql "reload @@config_all" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach5.java" output in "dble-2"
    """
    get into zkOnEvent
    """
    Given prepare a thread execute sql "cluster @@detach" with "conn_2"
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                      | expect                | db               | timeout |
      | conn_3  | true      | select * from dble_table | hasStr{sharding_4_t2} | dble_information | 8       |
    # dble-2不使用conn_2的原因：detach可能还没返回，detach返回之前如果同一根连接是执行了select查询，会导致detach包乱序返回lost connection，
    # mysql同一根连接是一问一答的协议，不能在用一根连接下发语句之后未返回结果再下发语句，否则极有可能包乱序导致lost connection
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose   | sql                      | expect                | db               | timeout |
      | conn_22 | false     | select * from dble_table | hasStr{sharding_4_t2} | dble_information | 8       |
      | conn_22 | true      | cluster @@attach         | success               | dble_information | 8       |

    Given stop btrace script "BtraceClusterDetachAttach5.java" in "dble-2"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java.log" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java" on "dble-2"

  @btrace
  Scenario: one dble is executing detach command, another dble will execute cluster sql #11
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    /sequenceHandlerType/d
    $a sequenceHandlerType=4
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-2" with sed cmds
    """
    /sequenceHandlerType/d
    $a sequenceHandlerType=4
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-3" with sed cmds
    """
    /sequenceHandlerType/d
    $a sequenceHandlerType=4
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
         <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" incrementColumn="pid" />
      </schema>
    """
    When Add some data in "sequence_conf.properties"
    """
    `schema1`.`sharding_4_t1`.MINID=1001
    `schema1`.`sharding_4_t1`.MAXID=20000
    `schema1`.`sharding_4_t1`.CURID=1000
    """
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success

    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-2"
    Given update file content "./assets/BtraceClusterDetachAttach6.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /zkDetachCluster/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """

    # case1 check cluster manager command: dble-2 execute cluster @@detach, dble-1 execute reload @@config_all
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                         | expect                    | db               |
      | conn_1  | false     | select name from dble_table | hasNoStr{'sharding_4_t2'} | dble_information |
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose   | sql                         | expect                    | db               |
      | conn_2  | false     | select name from dble_table | hasNoStr{'sharding_4_t2'} | dble_information |
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" incrementColumn="id" shardingColumn="id"/>
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-2"
    Given prepare a thread execute sql "cluster @@detach" with "conn_2"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-2"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "reload @@config_all" with "conn_1"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-2"
    """
    ignore event because of detached
    """
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-2"
    Given destroy btrace threads list
    Given destroy sql threads list
    # dble-1 has new table, dble-2 not
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                         | expect                    | db               | timeout |
      | conn_11 | false     | select name from dble_table | hasStr{'sharding_4_t2'}   | dble_information | 7       |
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose   | sql                         | expect                    | db               | timeout |
      | conn_22 | false     | select name from dble_table | hasNoStr{'sharding_4_t2'} | dble_information | 7       |
      | conn_22 | true      | cluster @@attach            | success                   | dble_information | 7       |
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java" on "dble-2"

    # case2 check ddl: dble-1 execute cluster @@detach, dble-2 execute ddl
    Given record current dble log line number in "log_line_num"
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                  | expect  | db      |
      | conn_3  | false     | drop table if exists sharding_4_t1   | success | schema1 |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "create table sharding_4_t1(pid int, id int)" with "conn_3"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1"
    """
    ignore event because of detached
    """
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    # dble-2 has new table, dble-1 not
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql            | expect                     | db      | timeout |
      | conn_33 | true      | show tables    | has{(('sharding_4_t1',),)} | schema1 | 7       |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql            | expect                        | db      | timeout |
      | conn_4  | false     | show tables    | hasnot{(('sharding_4_t1',),)} | schema1 | 7       |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  |
      | conn_1  | false     | cluster @@attach                  | success |
      | conn_1  | false     | reload @@metadata                 | success |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                                      | expect                     | db      |
      | conn_4  | false     | show tables                                              | has{(('sharding_4_t1',),)} | schema1 |
      | conn_4  | true      | insert into sharding_4_t1 (id) values (1),(2),(3),(4)    | success                    | schema1 |
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"

    # case3 check ddl - view: dble-1 execute cluster @@detach, dble-2 execute view ddl
    Given record current dble log line number in "log_line_num"
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "create view test_view as select * from sharding_4_t1" with "conn_3"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1"
    """
    ignore event because of detached
    """
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    # dble-2 has view, dble-1 not
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                        | expect      | db      | timeout |
      | conn_33 | true      | select * from test_view    | length{(4)} | schema1 | 7       |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                        | expect                    | db      |
      | conn_44 | false     | show tables                | hasnot{(('test_view',),)} | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  |
      | conn_1  | false     | cluster @@attach                  | success |
      | conn_1  | false     | reload @@metadata                 | success |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                           | expect      | db      |
      | conn_44 | false     | select * from test_view       | length{(4)} | schema1 |
      | conn_44 | true      | drop view if exists test_view | success     | schema1 |
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"

    # case4 check xa: dble-1 execute cluster @@detach, dble-2 execute xa
    Given record current dble log line number in "log_line_num"
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                                 | expect  | db      |
      | conn_3  | false     | set xa=1;set autocommit=0;delete from sharding_4_t1 | success | schema1 |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "commit" with "conn_3"
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1"
    """
    ignore event because of detached
    """
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                         | expect      | db      | timeout |
      | conn_4  | true      | select * from sharding_4_t1 | length{(0)} | schema1 | 7       |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                         | expect      | db      | timeout |
      | conn_33 | true      | select * from sharding_4_t1 | length{(0)} | schema1 | 7       |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  |
      | conn_1  | false     | cluster @@attach                  | success |
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"

    # case5 check zk offset-step sequence: dble-1 execute cluster @@detach, dble-2 execute insert
    Given record current dble log line number in "log_line_num"
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      |
      | conn_5  | false     | select * from sharding_4_t1        | length{(0)} | schema1 |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "insert into sharding_4_t1 (id) values (5)" with "conn_5"
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1"
    """
    ignore event because of detached
    """
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      | timeout |
      | conn_4  | true      | select * from sharding_4_t1        | length{(1)} | schema1 | 7       |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      | timeout |
      | conn_33 | true      | select * from sharding_4_t1        | length{(1)} | schema1 | 7       |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  |
      | conn_1  | true      | cluster @@attach                  | success |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      |
      | conn_33 | true      | drop table if exists sharding_4_t1 | success     | schema1 |
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java" on "dble-1"