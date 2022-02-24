# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/8/17

Feature: check thread leak

  @btrace
  Scenario: check MultiNodeMergeAndOrderHandler.ownThread #1
    # DBLE0REQ-1274
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <singleTable name="single_t1" shardingNode="dn1" />
      </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Given delete file "/tmp/jstack.log" on "dble-1"
    Given delete file "/opt/dble/BtraceMultiNodeMergeAndOrderHandler.java" on "dble-1"
    Given delete file "/opt/dble/BtraceMultiNodeMergeAndOrderHandler.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1                                                                                 | success | schema1 |
      | conn_0 | False   | drop table if exists single_t1                                                                                     | success | schema1 |
      | conn_0 | False   | create table sharding_2_t1 (id int,start_time int,duration int)                                                    | success | schema1 |
      | conn_0 | False   | create table single_t1 (id int)                                                                                    | success | schema1 |
      | conn_0 | False   | insert into sharding_2_t1 values(1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6),(7,7,7),(8,8,8),(9,9,9),(10,10,10) | success | schema1 |
      | conn_0 | False   | insert into single_t1 values(1)                                                                                    | success | schema1 |
    Given update file content "./assets/BtraceMultiNodeMergeAndOrderHandler.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /ownThread/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(3000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceMultiNodeMergeAndOrderHandler.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "select t1.id from sharding_2_t1 t1 left join single_t1 t2 on t1.id = t2.id" with "conn_0"
    Then check btrace "BtraceMultiNodeMergeAndOrderHandler.java" output in "dble-1"
    """
    get into ownThread
    """
    Given destroy sql threads list
    Given stop btrace script "BtraceMultiNodeMergeAndOrderHandler.java" in "dble-1"
    Given destroy btrace threads list
    Given execute oscmd in "dble-1"
    """
    jstack -l `ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'` > /tmp/jstack.log
    """
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i 'MultiNodeMergeAndOrderHandler.ownThread' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "0"

    Given delete file "/opt/dble/BtraceMultiNodeMergeAndOrderHandler.java" on "dble-1"
    Given delete file "/opt/dble/BtraceMultiNodeMergeAndOrderHandler.java.log" on "dble-1"
    Given delete file "/tmp/jstack.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1   | success | schema1 |
      | conn_0 | True    | drop table if exists single_t1       | success | schema1 |

  @btrace
  Scenario: check group by thread #2
    # DBLE0REQ-1239
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
      </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Given delete file "/tmp/jstack.log" on "dble-1"
    Given delete file "/opt/dble/BtraceGroupByThread.java" on "dble-1"
    Given delete file "/opt/dble/BtraceGroupByThread.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                             | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1                                                              | success | schema1 |
      | conn_0 | False   | create table sharding_2_t1 (id int,start_time int,duration int)                                 | success | schema1 |
      | conn_0 | False   | insert into sharding_2_t1 values(1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6),(7,7,7),(8,8,8) | success | schema1 |
    Given update file content "./assets/BtraceGroupByThread.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /groupByBucket/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(3000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceGroupByThread.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "select sum(t1.id) from sharding_2_t1 t1 left join sharding_2_t1 t2 on t1.id = t2.id group by t1.start_time" with "conn_0"
    Then check btrace "BtraceGroupByThread.java" output in "dble-1"
    """
    get into groupByBucket.start
    """
    Then get index:"0" column value of "select session_conn_id from dble_information.session_connections where sql_stage<>'Manager connection' limit 1" named as "front_id_1"
    Then execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect  | db      |
      | conn_1 | False   | kill query {0} | success | schema1 |
    Given sleep "5" seconds
    Then check sql thread output in "err"
    """
    Query was interrupted
    """
    Given destroy sql threads list
    Given stop btrace script "BtraceGroupByThread.java" in "dble-1"
    Given destroy btrace threads list
    Given execute oscmd in "dble-1"
    """
    jstack -l `ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'` > /tmp/jstack.log
    """
    Then get result of oscmd named "rs_A" in "dble-1"
    """
    grep -i 'GroupByBucket' /tmp/jstack.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "0"

    Given delete file "/opt/dble/BtraceGroupByThread.java" on "dble-1"
    Given delete file "/opt/dble/BtraceGroupByThread.java.log" on "dble-1"
    Given delete file "/tmp/jstack.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect  | db      |
      | conn_1 | True    | drop table if exists sharding_2_t1   | success | schema1 |
