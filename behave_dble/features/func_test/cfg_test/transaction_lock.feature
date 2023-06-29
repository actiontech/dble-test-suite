# Copyright (C) 2016-2023 ActionTech.
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
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /rowResponse/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(200L)/;/\}/!ba}
      """
    Given delete the following xml segment
      |file        | parent           | child                   |
      |schema.xml  | {'tag':'root'}   | {'tag':'schema'}        |
      |schema.xml  | {'tag':'root'}   | {'tag':'dataNode'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
        <table name="aly_test" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
        <table name="aly_order" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
        <table name="a_manager" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
    </schema>

    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="db1" name="dn2" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    <dataNode dataHost="ha_group2" database="db2" name="dn4" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
      <property name="sqlExecuteTimeout">1000</property>
      <property name="recordTxn">1</property>
      <property name="xaRecoveryLogBaseDir">/opt/dble/xalogs</property>
      <property name="xaRecoveryLogBaseName">xalog</property>
      <property name="xaSessionCheckPeriod">2000</property>
      <property name="xaLogCleanPeriod">100000</property>
      <property name="processorExecutor">4</property>
      <property name="sequenceHandlerType">2</property>
    </system>
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
