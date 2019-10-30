# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/10/25


Feature: verify the release of the lock when the ddl is abnormally closed

  @btrace
  Scenario: ddl executes the select 1 verification connection phase, and closes the connection to verify the release of the ddl lock.
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}   |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
      | schema.xml | {'tag':'root'} | {'tag':'dataHost'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
     <schema name="schema1" sqlMaxLimit="100" dataNode="dn1">
        <table name="test_shard" dataNode="dn1,dn2" rule="hash-two"/>
    </schema>
    <dataNode name="dn1" dataHost="172.100.9.5" database="db1"/>
    <dataNode name="dn2" dataHost="172.100.9.6" database="db1"/>
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" switchType="2" slaveThreshold="100">
        <heartbeat>show slave status</heartbeat>
        <writeHost host="hostM1" url="172.100.9.5:3306" password="111111" user="test">
        </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.6" switchType="2" slaveThreshold="100">
        <heartbeat>show slave status</heartbeat>
        <writeHost host="hostW1" url="172.100.9.6:3306" password="111111" user="test"/>
    </dataHost>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                               | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                                                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test_shard(id int(11) NOT NULL,c_flag char(255),c_decimal decimal(16,4))CHARSET=utf8 | success | schema1 |
    Given prepare a thread run btrace script "SleepWhenAddMetaLock.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | user | passwd | conn   | toClose | sql                       | db      |
      | test | 111111 | conn_0 | False    | truncate table test_shard | schema1 |
    Then check btrace "SleepWhenAddMetaLock.java" output in "dble-1"
    """
    get into addMetaLock,start sleep
    """
    Given kill mysql query in "dble-1" forcely
    """
    truncate table test_shard
    """
    Given sleep "10" seconds
    Then check btrace "SleepWhenAddMetaLock.java" output in "dble-1"
    """
    sleep end
    """
    Given stop btrace script "SleepWhenAddMetaLock.java" in "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                       | expect  | db      |
      | test | 111111 | conn_0 | True    | truncate table test_shard | success | schema1 |
    Given destroy btrace threads list

  @btrace
  Scenario: after the ddl statement is issued, close session to verification table structure and the release of the ddl lock are closed.
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}   |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
      | schema.xml | {'tag':'root'} | {'tag':'dataHost'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
     <schema name="schema1" sqlMaxLimit="100" dataNode="dn1">
        <table name="test_shard" dataNode="dn1,dn2" rule="hash-two"/>
    </schema>
    <dataNode name="dn1" dataHost="172.100.9.5" database="db1"/>
    <dataNode name="dn2" dataHost="172.100.9.6" database="db1"/>
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" switchType="2" slaveThreshold="100">
        <heartbeat>show slave status</heartbeat>
        <writeHost host="hostM1" url="172.100.9.5:3306" password="111111" user="test">
        </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.6" switchType="2" slaveThreshold="100">
        <heartbeat>show slave status</heartbeat>
        <writeHost host="hostW1" url="172.100.9.6:3306" password="111111" user="test"/>
    </dataHost>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                               | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                                                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test_shard(id int(11) NOT NULL,c_flag char(255),c_decimal decimal(16,4))CHARSET=utf8 | success | schema1 |
    Given prepare a thread run btrace script "SleepWhenClearIfSessionClosed.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | user | passwd | conn   | toClose | sql                                | db      |
      | test | 111111 | conn_0 | False    | alter table test_shard drop c_flag | schema1 |
    Given sleep "30" seconds
    Then check btrace "SleepWhenClearIfSessionClosed.java" output in "dble-1"
    """
    __________________________ get into clearIfSessionClosed,start sleep
    """
    Given kill mysql query in "dble-1" forcely
    """
    alter table test_shard drop c_flag
    """
    Then check btrace "SleepWhenClearIfSessionClosed.java" output in "dble-1"
    """
    __________________________ sleep end  __________________________ get into clearIfSessionClosed,start sleep  __________________________ sleep end
    """
    Given stop btrace script "SleepWhenClearIfSessionClosed.java" in "dble-1"
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql             | expect                                                                                               | db  |
      | test | 111111 | conn_0 | True    | desc test_shard | hasStr{(('id', 'int(11)', 'NO', '', None, ''), ('c_decimal', 'decimal(16,4)', 'YES', '', None, ''))} | db1 |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql             | expect                                                                                               | db  |
      | test | 111111 | conn_0 | True    | desc test_shard | hasStr{(('id', 'int(11)', 'NO', '', None, ''), ('c_decimal', 'decimal(16,4)', 'YES', '', None, ''))} | db1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                       | expect  | db      |
      | test | 111111 | conn_0 | True    | truncate table test_shard | success | schema1 |
    Given destroy btrace threads list


  @btrace
  Scenario: after the ddl executes select 1 and returns successfully, the session is alive and closes the connection to verify the release of the ddl lock.
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}   |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
      | schema.xml | {'tag':'root'} | {'tag':'dataHost'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
     <schema name="schema1" sqlMaxLimit="100" dataNode="dn1">
        <table name="test_shard" dataNode="dn1,dn2" rule="hash-two"/>
    </schema>
    <dataNode name="dn1" dataHost="172.100.9.5" database="db1"/>
    <dataNode name="dn2" dataHost="172.100.9.6" database="db1"/>
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" switchType="2" slaveThreshold="100">
        <heartbeat>show slave status</heartbeat>
        <writeHost host="hostM1" url="172.100.9.5:3306" password="111111" user="test">
        </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.6" switchType="2" slaveThreshold="100">
        <heartbeat>show slave status</heartbeat>
        <writeHost host="hostW1" url="172.100.9.6:3306" password="111111" user="test"/>
    </dataHost>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                               | expect  | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                                                   | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test_shard(id int(11) NOT NULL,c_flag char(255),c_decimal decimal(16,4))CHARSET=utf8 | success | schema1 |
    Given prepare a thread run btrace script "SleepWhen2ClearIfSessionClosed.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | user | passwd | conn   | toClose | sql                                   | db      |
      | test | 111111 | conn_0 | False    | alter table test_shard drop c_decimal | schema1 |
    Then check btrace "SleepWhen2ClearIfSessionClosed.java" output in "dble-1"
    """
    get into clearIfSessionClosed,start sleep
    """
    Given kill mysql query in "dble-1" forcely
    """
    alter table test_shard drop c_decimal
    """
    Given sleep "10" seconds
    Then check btrace "SleepWhen2ClearIfSessionClosed.java" output in "dble-1"
    """
    sleep end
    """
    Given stop btrace script "SleepWhen2ClearIfSessionClosed.java" in "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                       | expect  | db      |
      | test | 111111 | conn_0 | True    | truncate table test_shard | success | schema1 |
    Given destroy btrace threads list




