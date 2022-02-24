# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2021/05/08
#github issue 89

Feature:  unexpected packet should not in dble log

  @btrace
  Scenario: unexpected packet should not in dble log
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1000L)/
      /rowResponse/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(200L)/;/\}/!ba}
      """
    Given delete the following xml segment
      |file          | parent          | child                   |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}        |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
        <shardingTable name="aly_test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
        <shardingTable name="aly_order" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
        <shardingTable name="a_manager" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DsqlExecuteTimeout=1000
    $a\-DrecordTxn=1
    $a\-DxaRecoveryLogBaseDir=/opt/dble/xalogs
    $a\-DxaRecoveryLogBaseName=xalog
    $a\-DxaSessionCheckPeriod=2000
    $a\-DxaLogCleanPeriod=100000
    /-DprocessorExecutor=1/c -DprocessorExecutor=4
    """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    $a\sequenceHandlerType=2
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_0 | False   | drop table if exists aly_test                       | success | schema1 |
      | conn_0 | False   | drop table if exists aly_order                      | success | schema1 |
      | conn_0 | False   | drop table if exists a_manager                      | success | schema1 |
      | conn_0 | False   | create table aly_test(id int,name varchar(50))      | success | schema1 |
      | conn_0 | False   | create table aly_order(id int,name varchar(50))     | success | schema1 |
      | conn_0 | False   | create table a_manager (id int,name varchar(50))    | success | schema1 |
      | conn_0 | False   | insert into aly_test set id = 1                     | success | schema1 |
      | conn_0 | False   | insert into a_manager set id = 1                    | success | schema1 |
    Then connect "dble-1" to insert "100" of data for "aly_order"
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect      | db      |
      | conn_0 | False   | set autocommit = 0                                        | success     | schema1 |
      | conn_0 | False   | select a.id from aly_test a,aly_order b where a.id=b.id   | length{(1)} | schema1 |
      | conn_0 | true    | commit                                                    | success     | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect          | db      |
      | conn_1 | False   | set autocommit = 0                                        | success         | schema1 |
      | conn_1 | False   | select * from aly_test                                    | length{(1)}     | schema1 |
      | conn_1 | False   | select * from aly_order                                   | length{(100)}   | schema1 |
      | conn_1 | False   | select t.id,t.name from(select aly_test.id,aly_order.name from aly_test,aly_order where aly_test.id = aly_order.id) t ,a_manager where t.id = a_manager.id | length{(1)}| schema1|
      | conn_1 | true    | commit                                                    | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect | db      |
      | conn_2 | False   | select t.id,t.name from(select aly_test.id,aly_order.name from aly_test,aly_order where aly_test.id = aly_order.id) t ,a_manager where t.id = a_manager.id |length{(1)} | schema1 |
      | conn_2 | False   | drop table if exists aly_test                             | success | schema1 |
      | conn_2 | False   | drop table if exists aly_order                            | success | schema1 |
      | conn_2 | true    | drop table if exists a_manager                            | success | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    unexpected packet for MySQLConnection
    """
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
