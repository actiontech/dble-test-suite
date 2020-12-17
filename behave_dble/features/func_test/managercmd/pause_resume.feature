# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yexiaoli at 2018/12/7
# Modified by yangxiaoliang at 2020/1/19
  #2.19.11.0#dble-7858
Feature: test "pause/resume" manager cmd

  @NORMAL
  Scenario: basic pause/resume test #1
      #1.1 pause without any parameters


      #1.2 pause with  timeout not in ([0-9]+)
      #1.3 pause with correct timeout
      #1.4 pause with correct timeout,queue
      #1.5 pause with corect timeout,queue,wait_limit
      #1.6 pause with  shardingNode not exists
      Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose  | sql                                                                           | expect  |
        | conn_0 | False    | pause @@shardingNode                                                          | The sql did not match pause @@shardingNode ='dn......' and timeout = ([0-9]+) |
        | conn_0 | False    | pause @@shardingNode = 'dn1,dn3' and timeout = -1 ,queue = 10,wait_limit = 10 | The sql did not match pause @@shardingNode ='dn......' and timeout = ([0-9]+) |
        | conn_0 | False    | pause @@shardingNode = 'dn1,dn3' and timeout = 10                             | success |
        | conn_0 | False    | resume                                                                        | success |
        | conn_0 | False    | pause @@shardingNode = 'dn1,dn3' and timeout = 10,queue=10                    | success |
        | conn_0 | False    | resume                                                                        | success |
        | conn_0 | False    | pause @@shardingNode = 'dn1,dn3' and timeout = 10,queue=10,wait_limit=10      | success |
        | conn_0 | False    | resume                                                                        | success |
        | conn_0 | True     | pause @@shardingNode = 'dn1,dn3,dn6' and timeout = 10,queue=10                |ShardingNode dn6 did not exists |

  @CRITICAL
  Scenario: verify pause "wait_limit" work  #2
      Then execute sql in "dble-1" in "user" mode
        | conn   | toClose  | sql                                        | expect   | db       |
        | conn_0 | False    | drop table if exists test                  | success  | schema1  |
        | conn_0 | True     | create table test(id int,name varchar(20)) | success  | schema1  |
      Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose | sql                                                                             | expect                                    |
        | conn_0 | False   | pause @@shardingNode = 'dn1,dn2,dn3,dn4' and timeout = 10,queue=10,wait_limit=1 | success                                   |
        | conn_0 | True    | show @@pause                                                                    | has{('dn1',), ('dn2',),('dn3',),('dn4',)} |
      Then execute sql in "dble-1" in "user" mode
        | conn   | toClose  | sql                | expect                                                   | db      |
        | conn_0 | False    | select * from test | waiting time exceeded wait_limit from pause shardingNode | schema1 |
        | conn_0 | True     | select * from test | execute_time{(1)}                                        | schema1 |
      Then execute sql in "dble-1" in "admin" mode
        | sql   | expect  |
        |resume | success |
      Then execute sql in "dble-1" in "user" mode
        | sql                | expect      | db       |
        | select * from test | length{(0)} | schema1  |

  @CRITICAL
  Scenario: verify "pause" when transaction executing and after transaction commit #3
      Then execute sql in "dble-1" in "user" mode
        | conn   | toClose  | sql                                                        | expect  | db      |
        | conn_0 | False    | drop table if exists test                                  | success | schema1 |
        | conn_0 | False    | create table test(id int,name varchar(20))                 | success | schema1 |
        | conn_0 | False    | begin                                                      | success | schema1 |
        | conn_0 | False    | insert into test values(1,'test1'),(2,'test2'),(3,'test3') | success | schema1 |
      Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose  | sql                                                                           | expect                                               |
        | new    | False    | pause @@shardingNode = 'dn1,dn2,dn3,dn4' and timeout = 5,queue=1,wait_limit=1 | The backend connection recycle failure, try it later |
      Then execute sql in "dble-1" in "user" mode
        | conn   | toClose | sql     | expect  | db       |
        | conn_0 | True    | commit  | success | schema1  |
      Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose  | sql                                                                           | expect                                    |
        | conn_0 | False    | pause @@shardingNode = 'dn1,dn2,dn3,dn4' and timeout = 5,queue=1,wait_limit=1 | success                                  |
        | conn_0 | False    | show @@pause                                                              | has{('dn1',), ('dn2',),('dn3',),('dn4',)}  |
        | conn_0 | True     | resume                                                                    | success                                    |
      # verify "queue"
      Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose | sql                                                                        |
        | conn_0 | True    | pause @@shardingNode = 'dn1,dn2,dn3,dn4' and timeout = 5,queue=1,wait_limit=10 |
      Then execute sql in "dble-1" in "user" mode
        | conn   | toClose | sql                | expect             | db       |
        | conn_0 | True    | select * from test | execute_time{(10)} |  schema1 |
      Given create "2" front connections executing "select * from test"
      """
      The node is pausing, wait list is full
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn | toClose | sql    | expect  | db |
      | new  | True    | resume | success |    |

  @CRITICAL
  Scenario: resume shardingNode which not stop data flow #4
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                  | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                   | success | schema1 |
      | conn_0 | True    | create table sharding_4_t1 (id int,name varchar(20)) | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | sql    | expect             |
      | resume | No shardingNode paused |

  @CRITICAL
  Scenario: execute manager cmd "pause @@shardingNode" many times #5
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                  | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                   | success | schema1 |
      | conn_0 | True    | create table sharding_4_t1 (id int,name varchar(20)) | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_0 | false   | begin                                                   | success | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values(1,1),(2,1),(3,1),(4,1) | success | schema1 |
    Then execute admin cmd  in "dble-1" at background
      | sql                                                                            | db                |
      | pause @@shardingNode = 'dn1,dn2,dn3' and timeout =10 ,queue = 1,wait_limit = 5 | dble_information   |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                            | expect                                            |
      | pause @@shardingNode = 'dn1,dn2,dn3' and timeout =10 ,queue = 1,wait_limit = 5 | Some shardingNodes is paused, please resume first |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "admin" mode
      | sql                                                                            | expect                                               |
      | pause @@shardingNode = 'dn1,dn2,dn3' and timeout =10 ,queue = 1,wait_limit = 5 | The backend connection recycle failure, try it later |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                          | expect      | db      |
      | conn_0 | false   | select *  from sharding_4_t1 | length{(4)} | schema1 |
      | conn_0 | true    | commit                       | success     | schema1 |

  @CRITICAL @current
  Scenario: execute "resume" before the pause command expires #6
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_0 | false   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_0 | false   | create table sharding_4_t1 (id int,name varchar(20))    | success | schema1 |
      | conn_0 | false   | begin                                                   | success | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values(1,1),(2,1),(3,1),(4,1) | success | schema1 |
    Then execute admin cmd  in "dble-1" at background
      | sql                                                                            | db               |
      | pause @@shardingNode = 'dn1,dn2,dn3' and timeout =10 ,queue = 1,wait_limit = 5 | dble_information |
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "admin" mode
      | sql    | expect  |
      | resume | success |
    Then check log "/tmp/dble_admin_query.log" output in "dble-1"
    """
    Pause resume when recycle connection, pause revert
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                          | expect      |
      | conn_0 | false   | select *  from sharding_4_t1 | length{(4)} |
      | conn_0 | true    | commit                       | success     |
    Given delete file "/tmp/dble_admin_query.log" on "dble-1"
