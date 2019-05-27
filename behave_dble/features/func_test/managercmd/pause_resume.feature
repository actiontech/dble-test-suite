# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yexiaoli at 2018/12/7
Feature: test "pause/resume" manager cmd

  @NORMAL
  Scenario: basic pause/resume test #1
      #1.1 pause without any parameters
      #1.2 pause with  timeout not in ([0-9]+)
      #1.3 pause with correct timeout
      #1.4 pause with correct timeout,queue
      #1.5 pause with corect timeout,queue,wait_limit
      #1.6 pause with  dataNode not exists
      Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql                                                                       | expect  | db     |
        | root | 111111 | conn_0 | False    | pause @@DataNode                                                          | The sql did not match pause @@dataNode ='dn......' and timeout = ([0-9]+) |         |
        | root | 111111 | conn_0 | False    | pause @@DataNode = 'dn1,dn3' and timeout = -1 ,queue = 10,wait_limit = 10 | The sql did not match pause @@dataNode ='dn......' and timeout = ([0-9]+) |         |
        | root | 111111 | conn_0 | False    | pause @@DataNode = 'dn1,dn3' and timeout = 10                             | success |         |
        | root | 111111 | conn_0 | False    | resume                                                                    | success |         |
        | root | 111111 | conn_0 | False    | pause @@DataNode = 'dn1,dn3' and timeout = 10,queue=10                    | success |         |
        | root | 111111 | conn_0 | False    | resume                                                                    | success |         |
        | root | 111111 | conn_0 | False    | pause @@DataNode = 'dn1,dn3' and timeout = 10,queue=10,wait_limit=10      | success |         |
        | root | 111111 | conn_0 | False    | resume                                                                    | success |         |
        | root | 111111 | conn_0 | True     | pause @@DataNode = 'dn1,dn3,dn6' and timeout = 10,queue=10                |DataNode dn6 did not exists |         |

  @CRITICAL
  Scenario: verify pause "wait_limit" work  #2
      Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                        | expect   | db       |
        | test | 111111 | conn_0 | False    | drop table if exists test                  | success  |  schema1  |
        | test | 111111 | conn_0 | True     | create table test(id int,name varchar(20)) | success  |  schema1  |
      Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose | sql             | expect                    | db     |
        | root | 111111 | conn_0 | True    | pause @@DataNode = 'dn1,dn2,dn3,dn4' and timeout = 10,queue=10,wait_limit=1 | success |         |
        | root | 111111 | conn_0 | True    | show @@pause    | has{('dn1',), ('dn2',),('dn3',),('dn4',)} |         |
      Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                | expect                    | db     |
        | test | 111111 | conn_0 | True     | select * from test | waiting time exceeded wait_limit from pause dataNode |   schema1  |
        | test | 111111 | conn_0 | True     | select * from test | execute_time{(1)}              |   schema1  |
      Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql   | expect  | db     |
        | root | 111111 | conn_0 | True     |resume | success |        |
      Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                | expect  | db        |
        | test | 111111 | conn_0 | True     | select * from test | success |   schema1  |

  @CRITICAL
  Scenario: verify "pause" when transaction executing and after transaction commit #3
      Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test                          | success                  |  schema1       |
        | test | 111111 | conn_0 | False    | create table test(id int,name varchar(20))      | success                   |  schema1      |
        | test | 111111 | conn_0 | False    | begin                         | success                  |  schema1       |
        | test | 111111 | conn_0 | False    | insert into test values(1,'test1'),(2,'test2'),(3,'test3')            | success                  |  schema1       |
      Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | root | 111111 | new    | False    | pause @@DataNode = 'dn1,dn2,dn3,dn4' and timeout = 5,queue=1,wait_limit=1        | The backend connection recycle failure,try it later |         |
      Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql     | expect  | db       |
        | test | 111111 | conn_0 | True    | commit  | success |  schema1  |
      Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql                                                         | expect                    | db     |
        | root | 111111 | conn_0 | False    | pause @@DataNode = 'dn1,dn2,dn3,dn4' and timeout = 5,queue=1,wait_limit=1        |success|         |
        | root | 111111 | conn_0 | False    | show @@pause                                                | has{('dn1',), ('dn2',),('dn3',),('dn4',)} |         |
        | root | 111111 | conn_0 | True     | resume      |success|         |
      # verify "queue"
      Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose | sql                                                          | expect                    | db     |
        | root | 111111 | conn_0 | True    | pause @@DataNode = 'dn1,dn2,dn3,dn4' and timeout = 5,queue=1,wait_limit=10       | success|         |
      Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                | expect             | db      |
        | test | 111111 | conn_0 | True    | select * from test | execute_time{(10)} |  schema1 |
      Given create "2" front connections executing "select * from test"
      """
      The node is pausing, wait list is full
      """
      Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | root | 111111 | new | True    | resume       | success|         |
