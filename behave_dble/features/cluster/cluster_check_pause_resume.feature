# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/12/11


Feature: test "pause/resume" in zk cluster
  ######case points:
  #  1. pause @@shardingNode
  #  2. resume
  #  3. create xa ,check pause_node.lock
  #  4. create xa ,check pause_node.lock,during pause or resume restart one dble
  #  5. create xa ,check pause_node.lock but pause or resume timeout


  @skip_restart
  Scenario: pause @@shardingNode = 'dn1,dn2' and timeout = 5 ,queue = 10,wait_limit = 1  #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                 | expect   | db       |
      | conn_1 | False    | drop table if exists sharding_4_t1                  | success  | schema1  |
      | conn_1 | True     | create table sharding_4_t1(id int,name varchar(20)) | success  | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose | sql                                                                     | expect                  |
      | conn_11 | False   | pause @@shardingNode = 'dn1,dn2' and timeout = 5,queue=10,wait_limit=1  | success                 |
      | conn_11 | True    | show @@pause                                                            | has{('dn1',), ('dn2',)} |
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose | sql                                                                     | expect                               |
      | conn_21 | True    | pause @@shardingNode = 'dn1,dn2' and timeout = 5,queue=10,wait_limit=1  | Other node in cluster is pausing     |
    Then execute sql in "dble-3" in "admin" mode
      | conn    | toClose | sql                                                                     | expect                               |
      | conn_31 | True    | pause @@shardingNode = 'dn1,dn2' and timeout = 5,queue=10,wait_limit=1  | Other node in cluster is pausing     |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                       | expect                                                    | db       |
      | conn_1 | false    | select * from sharding_4_t1               | waiting time exceeded wait_limit from pause shardingNode  | schema1  |
      | conn_1 | false    | insert into sharding_4_t1 values (1,'1')  | waiting time exceeded wait_limit from pause shardingNode  | schema1  |
      | conn_1 | false    | insert into sharding_4_t1 values (3,'3')  | success                                                   | schema1  |
      | conn_1 | True     | select * from sharding_4_t1 where id =3   | length{(1)}                                               | schema1  |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                       | expect                                                    | db       |
      | conn_2 | false    | select * from sharding_4_t1               | waiting time exceeded wait_limit from pause shardingNode  | schema1  |
      | conn_2 | True     | insert into sharding_4_t1 values (4,'4')  | waiting time exceeded wait_limit from pause shardingNode  | schema1  |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                       | expect                                                    | db       |
      | conn_3 | false    | select * from sharding_4_t1               | waiting time exceeded wait_limit from pause shardingNode  | schema1  |
      | conn_3 | True     | insert into sharding_4_t1 values (2,'2')  | success                                                   | schema1  |


  @skip_restart
  Scenario: resume #2
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose | sql            | expect                      |
      | conn_11 | False   | resume         | success                     |
      | conn_11 | False   | resume         | No shardingNode paused      |
      | conn_11 | True    | show @@pause   | length{(0)}                 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                       | expect    | db       |
      | conn_1 | false    | select * from sharding_4_t1               | success   | schema1  |
      | conn_1 | True     | insert into sharding_4_t1 values (1,'1')  | success   | schema1  |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                       | expect    | db       |
      | conn_2 | false    | select * from sharding_4_t1               | success   | schema1  |
      | conn_2 | True     | insert into sharding_4_t1 values (4,'4')  | success   | schema1  |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                       | expect        | db       |
      | conn_3 | True     | select * from sharding_4_t1               | length{(4)}   | schema1  |
    #case check lock on zookeeper
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock | grep "pause_node.lock" |wc -l
      """
    Then check result "A" value is "0"
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose | sql                                                                     | expect                  |
      | conn_21 | False   | pause @@shardingNode = 'dn3,dn4' and timeout = 5,queue=10,wait_limit=1  | success                 |
      | conn_21 | False   | show @@pause                                                            | has{('dn3',), ('dn4',)} |
      | conn_21 | False   | resume                                                                  | success                 |
      | conn_21 | True    | show @@pause                                                            | length{(0)}             |


  @skip_restart
  Scenario: check pause_node.lock #3
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                             | expect    | db       |
      | conn_3 | false    | begin                                           | success   | schema1  |
      | conn_3 | false    | insert into sharding_4_t1 values (4,'4')        | success   | schema1  |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                                                                                | db                 |
      | conn_11 | True    | pause @@shardingNode = 'dn1,dn2' and timeout = 20,queue=10,wait_limit=1            | dble_information   |
    #case check lock on zookeeper
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock | grep "pause_node.lock" |wc -l
      """
    Then check result "A" value is "1"
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose | sql                                                                     | expect                               |
      | conn_21 | True    | pause @@shardingNode = 'dn1,dn2' and timeout = 5,queue=10,wait_limit=1  | Other node in cluster is pausing     |
    Then execute sql in "dble-3" in "admin" mode
      | conn    | toClose | sql                                                                     | expect                               |
      | conn_31 | True    | pause @@shardingNode = 'dn1,dn2' and timeout = 5,queue=10,wait_limit=1  | Other node in cluster is pausing     |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql        | expect    | db       |
      | conn_3 | True     | commit     | success   | schema1  |
    #case check lock on zookeeper
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock | grep "pause_node.lock" |wc -l
      """
    Then check result "A" value is "1"
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose | sql      | expect                                          |
      | conn_21 | True    | resume   | This node is not the node which start pause     |
    Then execute sql in "dble-3" in "admin" mode
      | conn    | toClose | sql      | expect                                          |
      | conn_31 | True    | resume   | This node is not the node which start pause     |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose | sql      | expect         |
      | conn_11 | True    | resume   | success        |
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose | sql      | expect                     |
      | conn_21 | True    | resume   | No shardingNode paused     |
    Then execute sql in "dble-3" in "admin" mode
      | conn    | toClose | sql      | expect                     |
      | conn_31 | True    | resume   | No shardingNode paused     |
    #case check lock on zookeeper
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock | grep "pause_node.lock" |wc -l
      """
    Then check result "A" value is "0"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                       | expect    | db       |
      | conn_1 | True     | select * from sharding_4_t1               | success   | schema1  |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                       | expect    | db       |
      | conn_2 | True     | select * from sharding_4_t1               | success   | schema1  |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                       | expect        | db       |
      | conn_3 | True     | select * from sharding_4_t1               | length{(5)}   | schema1  |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"


  @skip_restart
  Scenario: create xa ,check pause_node.lock,during pause or resume restart one dble #4
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                             | expect    | db       |
      | conn_2 | false    | begin                                           | success   | schema1  |
      | conn_2 | false    | insert into sharding_4_t1 values (4,'4')        | success   | schema1  |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                                                                                | db                 |
      | conn_11 | True    | pause @@shardingNode = 'dn1,dn2' and timeout = 30,queue=10,wait_limit=1            | dble_information   |
    #case check lock on zookeeper
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock | grep "pause_node.lock" |wc -l
      """
    Then check result "A" value is "1"
    Then stop dble in "dble-3"
    #to check dble-3 had stop
    Given sleep "2" seconds
    Then Start dble in "dble-3"
    Then execute sql in "dble-3" in "admin" mode
      | conn    | toClose | sql                                                                      | expect                               |
      | conn_31 | True    | pause @@shardingNode = 'dn1,dn2' and timeout = 30,queue=10,wait_limit=1  | Other node in cluster is pausing     |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql        | expect    | db       |
      | conn_2 | True     | commit     | success   | schema1  |
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      ERROR
      There are some node in cluster can
      recycle backend
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                       | expect                                                     | db       |
      | conn_1 | True     | select * from sharding_4_t1               | waiting time exceeded wait_limit from pause shardingNode   | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose | sql     | expect                     |
      | conn_11 | false   | resume  | success                    |
    #case check lock on zookeeper
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock | grep "pause_node.lock" |wc -l
      """
    Then check result "A" value is "0"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                       | expect    | db       |
      | conn_1 | True     | select * from sharding_4_t1               | success   | schema1  |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                       | expect    | db       |
      | conn_2 | True     | select * from sharding_4_t1               | success   | schema1  |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                       | expect        | db       |
      | conn_3 | True     | select * from sharding_4_t1               | length{(6)}   | schema1  |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"


  Scenario: create xa ,check pause_node.lock but pause or resume timeout #5
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                             | expect    | db       |
      | conn_3 | false    | begin                                           | success   | schema1  |
      | conn_3 | false    | insert into sharding_4_t1 values (4,'4')        | success   | schema1  |
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql                                                                        | db                 |
      | conn_11 | True    | pause @@shardingNode = 'dn1,dn2' and timeout = 10,queue=10,wait_limit=1    | dble_information   |
    #case check lock on zookeeper
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock | grep "pause_node.lock" |wc -l
      """
    Then check result "A" value is "1"
    Given sleep "10" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
     """
     ERROR
     There are some node in cluster can
     recycle backend
     """
    #case check lock on zookeeper
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock | grep "pause_node.lock" |wc -l
      """
    Then check result "A" value is "0"
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql        | expect    | db       |
      | conn_3 | True     | commit     | success   | schema1  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                       | expect    | db       |
      | conn_1 | True     | select * from sharding_4_t1               | success   | schema1  |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                       | expect    | db       |
      | conn_2 | True     | select * from sharding_4_t1               | success   | schema1  |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                       | expect        | db       |
      | conn_3 | True     | select * from sharding_4_t1               | length{(7)}   | schema1  |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"

    Given stop dble cluster and zk service
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /-DidleTimeout=/d
      $a -DidleTimeout=10000
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
      """
      /-DidleTimeout=/d
      $a -DidleTimeout=10000
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
      """
      /-DidleTimeout=/d
      $a -DidleTimeout=10000
      """
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose | sql                                                                     | expect                  |
      | conn_11 | true    | pause @@shardingNode = 'dn1,dn2' and timeout = 5,queue=10,wait_limit=1  | success                 |
    #sleep 20s,because idleTimeout=10s,timeout more than 10s
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /tryResume/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Then execute "admin" cmd  in "dble-1" at background
      | conn    | toClose | sql       | db                 |
      | conn_11 | True    | resume    | dble_information   |
    #case check lock on zookeeper
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock | grep "pause_node.lock" |wc -l
      """
    Then check result "A" value is "1"
    #sleep 10s,because idleTimeout=10000
    Given sleep "11" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      ERROR
      Lost connection to MySQL server during query
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                       | expect                                                     | db       |
      | conn_1 | True     | select * from sharding_4_t1               | waiting time exceeded wait_limit from pause shardingNode   | schema1  |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                       | expect                                                     | db       |
      | conn_2 | True     | select * from sharding_4_t1               | waiting time exceeded wait_limit from pause shardingNode   | schema1  |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                       | expect                                                     | db       |
      | conn_3 | True     | select * from sharding_4_t1               | waiting time exceeded wait_limit from pause shardingNode   | schema1  |
    Given sleep "10" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceDelayAfterDdl.java" on "dble-1"
    Given delete file "/opt/dble/BtraceDelayAfterDdl.java.log" on "dble-1"
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose | sql     | expect                     |
      | conn_11 | true    | resume  | No shardingNode paused     |
    #case check lock on zookeeper
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock | grep "pause_node.lock" |wc -l
      """
    Then check result "A" value is "0"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                       | expect    | db       |
      | conn_1 | True     | select * from sharding_4_t1               | success   | schema1  |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose  | sql                                       | expect    | db       |
      | conn_2 | True     | select * from sharding_4_t1               | success   | schema1  |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                       | expect        | db       |
      | conn_3 | false    | select * from sharding_4_t1               | length{(7)}   | schema1  |
      | conn_3 | True     | drop table if exists sharding_4_t1        | success       | schema1  |






