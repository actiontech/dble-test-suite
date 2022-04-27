# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/9/13

# DBLE0REQ-1002
Feature: check single dble detach or attach from cluster

  Scenario: check thread name after cluster @@detach, cluster @@attach #1
    Given delete file "/tmp/jstack.log" on "dble-1"
    Given delete file "/tmp/dble_zk_online.log" on "dble-1"
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
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh ls /dble/cluster-1/online  >/tmp/dble_zk_online.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_online.log" in host "dble-1"
      """
      [2,3]
      """
    Given delete file "/tmp/jstack.log" on "dble-1"
    Given delete file "/tmp/dble_zk_online.log" on "dble-1"
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
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh ls /dble/cluster-1/online  >/tmp/dble_zk_online.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_online.log" in host "dble-1"
      """
      [1,2,3]
      """
    Given delete file "/tmp/jstack.log" on "dble-1"
    Given delete file "/tmp/dble_zk_online.log" on "dble-1"

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
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="hostS2" url="172.100.9.2:3307" user="test" password="111111" maxCon="1000" minCon="10"/>
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
      | conn_1 | False     | reload @@config_all                | Reload config failure.The reason is cluster is detached |
      | conn_1 | False     | show @@binlog.status               | cluster is detached                                     |
      | conn_1 | False     | dbGroup @@disable name='ha_group1' | cluster is detached, you should attach cluster first.   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_A"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_A" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3307   | W     | 0        | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3307   | W     | 0        | false       |
      | ha_group2  | hostS2 | 172.100.9.2 | 3307   | R     | 0        | false       |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql                               | expect                                                |
      | conn_1 | False     | dbGroup @@enable name='ha_group1' | cluster is detached, you should attach cluster first. |
      | conn_1 | False     | dbGroup @@switch name='ha_group2' master='hostS2' | cluster is detached, you should attach cluster first. |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_B"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_B" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3307   | W     | 0        | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3307   | W     | 0        | false       |
      | ha_group2  | hostS2 | 172.100.9.2 | 3307   | R     | 0        | false       |
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
      | ha_group1  | hostM1 | 172.100.9.5 | 3307   | W     | 0        | true        |
      | ha_group2  | hostM2 | 172.100.9.6 | 3307   | W     | 0        | false       |
      | ha_group2  | hostS2 | 172.100.9.2 | 3307   | R     | 0        | false       |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql                               | expect  |
      | conn_1 | False     | dbGroup @@enable name='ha_group1' | success |
      | conn_1 | False     | dbGroup @@switch name='ha_group2' master='hostS2' | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_D"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_D" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3307   | W     | 0        | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3307   | R     | 0        | false       |
      | ha_group2  | hostS2 | 172.100.9.2 | 3307   | W     | 0        | false       |
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

  Scenario: check cluster @@detach and timeout less than default value when other sql is being executed #3
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
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
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@detach timeout=1" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "show @@general_log" with "conn_2"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Given sleep "3" seconds
    Then check sql thread output in "err"
    """
    detach cluster pause timeout
    """
    Given sleep "10" seconds
    Then check sql thread output in "res"
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

  Scenario: check cluster @@detach and timeout use default value when other sql is being executed #4
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
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
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "create view test_view as select * from sharding_4_t1" with "conn_3"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Given sleep "12" seconds
    Then check sql thread output in "err"
    """
    detach cluster pause timeout
    """
    Given sleep "3" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                | expect                | db      |
      | conn_3  | false   | show tables                        | has{(('test_view',),)} | schema1 |
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

  Scenario: check cluster @@detach and timeout greater than default value when other sql is being executed #5
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
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
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@detach timeout=20" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "insert into sharding_4_t1 (id) values (1)" with "conn_3"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Given sleep "15" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      |
      | conn_3  | false     | select * from sharding_4_t1        | length{(1)} | schema1 |
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

  Scenario: check cluster @@attach and timeout less than default value when other sql is being executed #6
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
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
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@attach timeout=1" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "show @@general_log" with "conn_2"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Given sleep "3" seconds
    Then check sql thread output in "err"
    """
    attach cluster pause timeout
    """
    Given sleep "10" seconds
    Then check sql thread output in "res"
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

  Scenario: check cluster @@attach and timeout use default value when other sql is being executed #7
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    s/-Dprocessors=1/-Dprocessors=4/
    s/-DprocessorExecutor=1/-DprocessorExecutor=4/
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
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "show @@general_log" with "conn_2"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Given sleep "12" seconds
    Then check sql thread output in "err"
    """
    attach cluster pause timeout
    """
    Given sleep "3" seconds
    Then check sql thread output in "res"
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
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(12000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@attach timeout=20" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "show @@general_log" with "conn_2"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Given sleep "10" seconds
    Then check sql thread output in "res"
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
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /waitOtherSessionBlocked/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """

    # check detach and manager command
    Given prepare a thread run btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1"
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "reload @@config_all" with "conn_2"
    Given sleep "5" seconds
    Then check sql thread output in "err"
    """
    Reload config failure.The reason is cluster is detached
    """

    # check attach and manager command
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1" with "==2" times
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "pause @@shardingNode = 'dn1,dn2' and timeout = 10 ,queue = 10,wait_limit = 10" with "conn_2"
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql           | expect  |
      | conn_2 | False     | show @@pause  | has{(('dn1',), ('dn2',))} |
      | conn_2 | True      | resume        | success |
    Given stop btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                         | db      | expect  |
      | conn_3  | false     | drop table if exists sharding_4_t1          | schema1 | success |
      | conn_3  | false     | create table sharding_4_t1(pid int, id int) | schema1 | success |

    # check detach and ddl
    Given prepare a thread run btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1"
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "create view test_view as select * from sharding_4_t1" with "conn_3"
    Given sleep "5" seconds
    Then check sql thread output in "err"
    """
    cluster is detached, you should attach cluster first.
    """

    # check attach and ddl
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1" with "==2" times
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "create view test_view as select * from sharding_4_t1" with "conn_3"
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                                   | db      | expect      |
      | conn_3  | false     | insert into sharding_4_t1 (id) values (1),(2),(3),(4) | schema1 | success     |
      | conn_3  | false     | select * from test_view                               | schema1 | length{(4)} |
    Given stop btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"

    # check detach and xa
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                                 | db      | expect  |
      | conn_3  | false     | set xa=on;set autocommit=0;delete from sharding_4_t1 | schema1 | success |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1"
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "commit" with "conn_3"
    Given sleep "5" seconds
    Then check sql thread output in "err"
    """
    cluster is detached, you should attach cluster first.
    """

    # check attach and xa
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1" with "==2" times
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "commit" with "conn_3"
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                         | db      | expect      |
      | conn_3  | false     | set xa=off                  | schema1 | success     |
      | conn_3  | false     | select * from sharding_4_t1 | schema1 | length{(0)} |

    Given stop btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list

    # check detach and zk offset-step sequence
    Given prepare a thread run btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1"
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "insert into sharding_4_t1 (id) values (1),(2),(3),(4)" with "conn_3"
    Given sleep "5" seconds
    Then check sql thread output in "err"
    """
    cluster is detached, you should attach cluster first.
    """

    # check attach and xa
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1" with "==2" times
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "insert into sharding_4_t1 (id) values (1),(2),(3),(4)" with "conn_3"
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                | db      | expect      |
      | conn_3  | false     | select * from sharding_4_t1        | schema1 | length{(4)} |
      | conn_3  | false     | drop view if exists test_view      | schema1 | success     |
      | conn_3  | true      | drop table if exists sharding_4_t1 | schema1 | success     |

    Given stop btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java" on "dble-1"

  Scenario: one dble is executing detach command, another dble is executing cluster sql #10
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

    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java.log" on "dble-1"

     Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql          | expect      |
      | conn_1  | false     | show @@pause | length{(0)} |
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose   | sql          | expect      |
      | conn_2  | false     | show @@pause | length{(0)} |
    Given update file content "./assets/BtraceClusterDetachAttach5.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /zkOnEvent/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(3000L)/;/\}/!ba}
    """

    # check manager command
    Given prepare a thread run btrace script "BtraceClusterDetachAttach5.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "pause @@shardingNode = 'dn1,dn2' and timeout = 10 ,queue = 10,wait_limit = 10" with "conn_2"
    Given sleep "1" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Given sleep "3" seconds
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose   | sql           | expect                   |
      | conn_2  | false     | show @@pause  | has{(('dn1',),('dn2',))} |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql               | expect                    |
      | conn_1  | false     | show @@pause      | has{(('dn1',), ('dn2',))} |
      | conn_1  | false     | cluster @@attach  | success                   |
    Given stop btrace script "BtraceClusterDetachAttach5.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql               | expect                    |
      | conn_1  | false     | resume            | success                   |
      | conn_1  | false     | show @@pause      | hasnot{(('dn1',), ('dn2',))} |

    # check ddl
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                  | expect  | db      |
      | conn_3  | false     | drop table if exists sharding_4_t1   | success | schema1 |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach5.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "create table sharding_4_t1(pid int, id int)" with "conn_3"
    Given sleep "1" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Given sleep "3" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql             | expect                    | db      |
      | conn_4 | false   | show tables     | has{(('sharding_4_t1',),)} | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql             | expect                    | db      |
      | conn_3 | false   | show tables     | has{(('sharding_4_t1',),)} | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  | db      |
      | conn_1  | false     | cluster @@attach                  | success | schema1 |
    Given stop btrace script "BtraceClusterDetachAttach5.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java.log" on "dble-1"

    # check ddl - view
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                                      | expect  | db      |
      | conn_3  | false     | insert into sharding_4_t1 (id) values (1),(2),(3),(4)    | success | schema1 |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach5.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "create view test_view as select * from sharding_4_t1" with "conn_3"
    Given sleep "1" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Given sleep "3" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql            | expect                | db      |
      | conn_4  | false     | show tables    | has{(('test_view',),)} | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql            | expect                | db      |
      | conn_3  | false     | show tables    | has{(('test_view',),)} | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                        | expect  | db      |
      | conn_1  | false     | cluster @@attach           | success | schema1 |
    Given stop btrace script "BtraceClusterDetachAttach5.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java.log" on "dble-1"

    # check zk offset-step sequence
    Given prepare a thread run btrace script "BtraceClusterDetachAttach5.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "insert into sharding_4_t1 (id) values (5)" with "conn_3"
    Given sleep "1" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Given sleep "3" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      |
      | conn_4  | false     | select * from sharding_4_t1        | length{(5)} | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      |
      | conn_3  | false     | select * from sharding_4_t1        | length{(5)} | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  | db      |
      | conn_1  | false     | cluster @@attach                  | success | schema1 |
    Given stop btrace script "BtraceClusterDetachAttach5.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java.log" on "dble-1"

    # check xa
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                                 | expect  | db      |
      | conn_3  | false     | set xa=1;set autocommit=0;delete from sharding_4_t1 | success | schema1 |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach5.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "commit" with "conn_3"
    Given sleep "1" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Given sleep "3" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                         | expect      | db      |
      | conn_4  | false     | select * from sharding_4_t1 | length{(0)} | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                         | expect      | db      |
      | conn_3  | true      | select * from sharding_4_t1 | length{(0)} | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                         | expect  | db      |
      | conn_1  | true      | cluster @@attach            | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                | expect  | db      |
      | conn_4  | false     | drop view if exists test_view      | success | schema1 |
      | conn_4  | true      | drop table if exists sharding_4_t1 | success | schema1 |
    Given stop btrace script "BtraceClusterDetachAttach5.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java" on "dble-1"

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

    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"

     Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql              | expect      |
      | conn_1  | false     | show @@pause     | length{(0)} |

    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose   | sql              | expect      |
      | conn_2  | false     | show @@pause     | length{(0)} |

    Given update file content "./assets/BtraceClusterDetachAttach6.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /zkDetachCluster/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """

    # check cluster manager command
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "pause @@shardingNode = 'dn1,dn2' and timeout = 10 ,queue = 10,wait_limit = 10" with "conn_2"
    Given sleep "5" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    ignore event because of detached
    """
    Given record current dble log line number in "log_line_num"
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect                       |
      | conn_1  | false     | show @@pause                      | hasnot{(('dn1',),('dn2',))}  |
      | conn_1  | false     | cluster @@attach                  | success                      |
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose   | sql          | expect                    |
      | conn_2  | false     | show @@pause | has{(('dn1',), ('dn2',))} |
      | conn_2  | false     | resume       | success                   |
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"

    # check cluster manager command
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "reload @@config_all" with "conn_2"
    Given sleep "5" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    ignore event because of detached
    """
    Given record current dble log line number in "log_line_num"
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  |
      | conn_1  | false     | cluster @@attach                  | success |
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"

    # check ddl
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                  | expect  | db      |
      | conn_3  | false     | drop table if exists sharding_4_t1   | success | schema1 |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "create table sharding_4_t1(pid int, id int)" with "conn_3"
    Given sleep "5" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1"
    """
    ignore event because of detached
    """
    Given record current dble log line number in "log_line_num"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql            | expect                     | db      |
      | conn_4  | false     | show tables    | hasnot{(('sharding_4_t1',),)} | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql            | expect                     | db      |
      | conn_3  | false     | show tables    | has{(('sharding_4_t1',),)}    | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  |
      | conn_1  | false     | cluster @@attach                  | success |
      | conn_1  | false     | reload @@metadata                 | success |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                                      | expect                    | db      |
      | conn_4  | false     | show tables                                              | has{(('sharding_4_t1',),)} | schema1 |
      | conn_4  | false     | insert into sharding_4_t1 (id) values (1),(2),(3),(4)    | success                   | schema1 |
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"

    # check ddl - view
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "create view test_view as select * from sharding_4_t1" with "conn_3"
    Given sleep "5" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1"
    """
    ignore event because of detached
    """
    Given record current dble log line number in "log_line_num"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                        | expect                  | db      |
      | conn_4  | false     | show tables                | hasnot{(('test_view',),)}  | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                        | expect      | db      |
      | conn_3  | false     | select * from test_view    | length{(4)} | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  |
      | conn_1  | false     | cluster @@attach                  | success |
      | conn_1  | false     | reload @@metadata                 | success |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                        | expect       | db      |
      | conn_4  | false     | select * from test_view    | length{(4)}  | schema1 |
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"

    # check zk offset-step sequence
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      |
      | conn_3  | false     | select * from sharding_4_t1        | length{(4)} | schema1 |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "insert into sharding_4_t1 (id) values (5)" with "conn_3"
    Given sleep "5" seconds
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1"
    """
    ignore event because of detached
    """
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      |
      | conn_3  | false     | select * from sharding_4_t1        | length{(5)} | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      |
      | conn_4  | false     | select * from sharding_4_t1        | length{(5)} | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  |
      | conn_1  | false     | cluster @@attach                  | success |
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"

    # check xa
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                                 | expect  | db      |
      | conn_3  | false     | set xa=1;set autocommit=0;delete from sharding_4_t1 | success | schema1 |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "commit" with "conn_3"
    Given sleep "5" seconds
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1"
    """
    ignore event because of detached
    """
    Given record current dble log line number in "log_line_num"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                         | expect      | db      |
      | conn_4  | true      | select * from sharding_4_t1 | length{(0)} | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                         | expect      | db      |
      | conn_3  | false     | set xa=off                  | success     | schema1 |
      | conn_3  | false     | select * from sharding_4_t1 | length{(0)} | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  |
      | conn_1  | true      | cluster @@attach                  | success |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      |
      | conn_3  | false     | drop view if exists test_view      | success     | schema1 |
      | conn_3  | true      | drop table if exists sharding_4_t1 | success     | schema1 |
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java" on "dble-1"