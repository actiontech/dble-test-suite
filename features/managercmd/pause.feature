Feature:
    Scenario: #2 pause function test
      #1.1 pause without any parameters
      #1.2 pause with  timeout not in ([0-9]+)
      #1.3 pause with correct timeout
      #1.4 pause with correct timeout,queue
      #1.5 pause with corect timeout,queue,wait_limit
      #1.6 pause with  dataNode not exists
      Then execute sql in "dble-1"use"admin"
        | user | passwd | conn   | toClose  | sql                         | expect                             | db     |
        | root | 111111 | conn_0 | False     | pause @@DataNode          | The sql did not match pause @@dataNode ='dn......' and timeout = ([0-9]+)                      |         |
        | root | 111111 | conn_0 | False     | pause @@DataNode = 'dn1,dn3' and timeout = -1 ,queue = 10,wait_limit = 10          | The sql did not match pause @@dataNode ='dn......' and timeout = ([0-9]+)                      |         |
        | root | 111111 | conn_0 | False     | pause @@DataNode = 'dn1,dn3' and timeout = 10                                | success |         |
        | root | 111111 | conn_0 | False     | resume                                                                              | success |         |
        | root | 111111 | conn_0 | False     | pause @@DataNode = 'dn1,dn3' and timeout = 10,queue=10                      | success |         |
        | root | 111111 | conn_0 | False     | resume                                                                              | success |         |
        | root | 111111 | conn_0 | False     | pause @@DataNode = 'dn1,dn3' and timeout = 10,queue=10,wait_limit=10      | success |         |
        | root | 111111 | conn_0 | False     | resume                                                                               | success |         |
        | root | 111111 | conn_0 | True      | pause @@DataNode = 'dn1,dn3,dn6' and timeout = 10,queue=10                  |DataNode dn6 did not exists |         |

    Scenario: #2 pause function test
     #2.1  verify "wait_limit"
      Then execute sql in "dble-1"use"test"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test                          | success                  |  mytest       |
        | test | 111111 | conn_0 | True     | create table test(id int,name varchar(20))      | success                   |  mytest      |
      Then execute sql in "dble-1"use"admin"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | root | 111111 | conn_0 | True    | pause @@DataNode = 'dn1,dn2,dn3,dn4' and timeout = 10,queue=10,wait_limit=1        | success |         |
        | root | 111111 | conn_0 | True    | show @@pause                                                | has{('dn1',), ('dn2',),('dn3',),('dn4',)} |         |
      Then execute sql in "dble-1"use"test"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | test | 111111 | conn_0 | True     | select * from test                          | wait for backend dataNode timeout                   |   mytest  |
        | test | 111111 | conn_0 | True     | select * from test                          | execute{(1)}                   |   mytest  |
      Then execute sql in "dble-1"use"admin"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | root | 111111 | conn_0 | True     |resume                                                | success |         |
      Then execute sql in "dble-1"use"test"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | test | 111111 | conn_0 | True     | select * from test                          | success                  |   mytest  |

       #2.2 verify "pause"  a.when transaction executing  b.after transaction commit
      Then execute sql in "dble-1"use"test"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test                          | success                  |  mytest       |
        | test | 111111 | conn_0 | False    | create table test(id int,name varchar(20))      | success                   |  mytest      |
        | test | 111111 | conn_0 | False    | begin                         | success                  |  mytest       |
        | test | 111111 | conn_0 | False    | insert into test values(1,'test1'),(2,'test2'),(3,'test3')            | success                  |  mytest       |
      Then execute sql in "dble-1"use"admin"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | root | 111111 | new | False    | pause @@DataNode = 'dn1,dn2,dn3,dn4' and timeout = 5,queue=1,wait_limit=1        | The backend connection recycle failure,try it later |         |
      Then execute sql in "dble-1"use"test"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | test | 111111 | conn_0 | True    | commit                         | success                  |  mytest       |
      Then execute sql in "dble-1"use"admin"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | root | 111111 | conn_0 | False    | pause @@DataNode = 'dn1,dn2,dn3,dn4' and timeout = 5,queue=1,wait_limit=1        |success|         |
        | root | 111111 | conn_0 | False    | show @@pause                                                | has{('dn1',), ('dn2',),('dn3',),('dn4',)} |         |
        | root | 111111 | conn_0 | True     | resume      |success|         |

      #2.2 verify "queue"
      Then execute sql in "dble-1"use"admin"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | root | 111111 | conn_0 | True    | pause @@DataNode = 'dn1,dn2,dn3,dn4' and timeout = 5,queue=1,wait_limit=5       | success|         |
      Then execute sql in "dble-1"use"test"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | test | 111111 | conn_0 | True    | select * from test                          | execute{(5)}                  |  mytest       |
      Given create "1" front connections exec "10" seconds
      Then execute sql in "dble-1"use"test"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | test | 111111 | new | True    | select * from test                          | The node is pausing, wait list is full                  |  mytest       |
      Then execute sql in "dble-1"use"admin"
        | user | passwd | conn   | toClose  | sql                                                          | expect                    | db     |
        | root | 111111 | new | True    | resume       | success|         |
