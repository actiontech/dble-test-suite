# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# created by caiwei at 20220110

  # about http://10.186.18.11/jira/browse/DBLE0REQ-1572
  # For 3.21.02.99 and later dble versions

Feature: connection test in rwSplit mode

  @skip_restart
  Scenario: [testOnBorrow=false] when connection already has been obtained, old dbGroup will delay to close        #1

       Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
        """
        s/-Dprocessors=1/-Dprocessors=10/
        s/-DprocessorExecutor=1/-DprocessorExecutor=10/
        """

       # test with  testOnBorrow = false
      Given delete the following xml segment
        | file          | parent           | child                   |
        | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
        | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
        | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
        | user.xml        |{'tag':'root'}   | {'tag':'shardingUser'} |
      Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
         """
         <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group2" maxCon="0"/>
         """
      Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
          """
            <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
              <heartbeat>select user()</heartbeat>
              <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="10" minCon="3" primary="true">
                  <property name="testOnBorrow">false</property>
              </dbInstance>

              <dbInstance name="hostM2" password="111111" url="172.100.9.6:3307" user="test" maxCon="10" minCon="3">
                  <property name="testOnBorrow">false</property>
              </dbInstance>
            </dbGroup>
          """
      Given Restart dble in "dble-1" success

      Given execute sql in "dble-1" in "user" mode
       |user| conn   | toClose | sql                                       | expect  |
       |rwS1| conn_0 | False   | drop database if exists testdb            | success |
       |rwS1| conn_0 | true    | create database testdb                    | success |

      Given execute sql in "dble-1" in "user" mode
       |user| conn   | toClose | sql                                     | expect  | db        | timeout |
       |rwS1| conn_1 | False   | create table test(id int)               | success | testdb    | 3       |
       |rwS1| conn_1 | False   | insert into test values(1)              | success | testdb    |         |

     Given delete file "/opt/dble/BtraceRwSelect.java" on "dble-1"
     Given delete file "/opt/dble/BtraceRwSelect.java" on "dble-1"
     Given prepare a thread run Btrace script "BtraceRwSelect.java" in "dble-1"

     Given record current dble log line number in "log_num_1"
     Given prepare a thread execute sql "select * from test" with "conn_1"
     #为何没有进桩判断，还是很多活动都会进桩 所以此处才不做判断的？
       #use delete dbInstance to trigger reload
     Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose | sql                                               | expect           | db      |
        | conn_2 | False   | delete from dble_db_instance where name='hostM2'  | success          | dble_information   |

     Then check sql thread output in "res" by retry "10" times
        """
          (1,)
        """

     Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_1" in host "dble-1" retry "10" times
        """
          \[background task\]recycle old dbInstance:dbInstance\[name=hostM2,disabled=false,maxCon=10,minCon=3\],result:true
        """

     Given prepare a thread execute sql "select * from test" with "conn_1"
     Given record current dble log line number in "log_num_2"

       #use add dbInstance to trigger reload
     Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose | sql                                          |expect               | db      |
        | conn_2 | False   | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostM2','ha_group2','172.100.9.6',3307,'test','111111','false','false',1,99) | success            | dble_information   |

     Then check sql thread output in "res" by retry "10" times
        """
          (1,)
        """

     Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_num_2" in host "dble-1" retry "10" times
        """
          \[background task\]recycle old dbInstance:dbInstance\[name=hostM2,disabled=false,maxCon=10,minCon=3\],result:true
        """
     Then check btrace "BtraceRwSelect.java" output in "dble-1" with "2" times
       """
          get into rwSelect
       """

     Given stop Btrace script "BtraceRwSelect.java" in "dble-1"
     Given destroy Btrace threads list
     Given delete file "/opt/dble/BtraceRwSelect.java" on "dble-1"
     Given delete file "/opt/dble/BtraceRwSelect.java" on "dble-1"

  Scenario: [testOnBorrow = true] when connection already has been obtained, old dbGroup will delay to close        #2

     Given delete the following xml segment
        | file          | parent           | child                   |
        | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
          """
            <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
              <heartbeat>select user()</heartbeat>
              <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="10" minCon="3" primary="true">
                  <property name="testOnBorrow">true</property>
              </dbInstance>

              <dbInstance name="hostM2" password="111111" url="172.100.9.6:3307" user="test" maxCon="10" minCon="3">
                  <property name="testOnBorrow">true</property>
              </dbInstance>
            </dbGroup>
          """
     Given execute admin cmd "reload @@config_all" success

     Given record current dble log line number in "log_num_3"
     Given execute sql in "dble-1" in "user" mode
       |user| conn   | toClose | sql                                            | expect  | db        |
       |rwS1| conn_3 | False   | select * from test                             | success | testdb    |

     Given delete file "/opt/dble/BtraceRwSelect.java" on "dble-1"
     Given delete file "/opt/dble/BtraceRwSelect.java.log" on "dble-1"
     Given prepare a thread run Btrace script "BtraceRwSelect.java" in "dble-1"

     Given prepare a thread execute sql "select * from test" with "conn_3"

       #use delete dbInstance to trigger reload
     Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose | sql                                               | expect           | db      |
        | conn_4 | False   | delete from dble_db_instance where name='hostM2'  | success          | dble_information   |

     Then check sql thread output in "res" by retry "10" times
        """
          (1,)
        """

     Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_3" in host "dble-1" retry "10" times
        """
          \[background task\]recycle old dbInstance:dbInstance\[name=hostM2,disabled=false,maxCon=10,minCon=3\],result:true
        """

     Given prepare a thread execute sql "select * from test" with "conn_3"
     Given record current dble log line number in "log_num_4"

     #use add dbInstance to trigger reload
     Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose | sql                                           |expect              | db      |
        | conn_4 | False   | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostM2','ha_group2','172.100.9.6',3307,'test','111111','false','false',1,99)  | success           | dble_information   |

     Then check sql thread output in "res" by retry "10" times
        """
          (1,)
        """

     Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_num_4" in host "dble-1" retry "10" times
        """
          \[background task\]recycle old dbInstance:dbInstance\[name=hostM2,disabled=false,maxCon=10,minCon=3\],result:true
        """

     Then check btrace "BtraceRwSelect.java" output in "dble-1" with "2" times
       """
          get into rwSelect
       """
     Given stop Btrace script "BtraceRwSelect.java" in "dble-1"
     Given destroy Btrace threads list
     Given delete file "/opt/dble/BtraceRwSelect.java" on "dble-1"
     Given delete file "/opt/dble/BtraceRwSelect.java.log" on "dble-1"

     Then execute sql in "dble-1" in "user" mode
       |user| conn   | toClose | sql                                     | expect  |
       |rwS1| conn_1 | true    | drop database testdb                    | success |


  Scenario: When the front connection is bound with the dbGroup and trigger reload less ten times, result can return correctly      #3

      Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
        """
        s/-Dprocessors=1/-Dprocessors=10/
        s/-DprocessorExecutor=1/-DprocessorExecutor=10/
        """
      Given delete the following xml segment
        | file          | parent           | child                   |
        | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
        | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
        | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
        | user.xml        |{'tag':'root'}   | {'tag':'shardingUser'} |
      Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
         """
         <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group2" maxCon="0"/>
         """
      Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
          """
            <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
              <heartbeat>select user()</heartbeat>
              <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="10" minCon="3" primary="true">
              </dbInstance>
              <dbInstance name="hostM2" password="111111" url="172.100.9.6:3307" user="test" maxCon="10" minCon="3">
              </dbInstance>
            </dbGroup>
          """
      Given Restart dble in "dble-1" success

      Given execute sql in "dble-1" in "user" mode
       |user| conn   | toClose | sql                                       | expect  |
       |rwS1| conn_0 | False   | drop database if exists testdb            | success |
       |rwS1| conn_0 | true    | create database testdb                    | success |
    ###偶现报错 (1045, "Unknown database 'testdb'")   issue:DBLE0REQ-2116,
    ###抓包后发现是登录的时候使用了3307这个库，时间问题，3307可能还没有从主上同步到这个database，现改动case顺序
      Given execute sql in "dble-1" in "user" mode
       |user| conn   | toClose | sql                                     | expect  | timeout |
       |rwS1| conn_1 | False   | use testdb                              | success | 5,2     |
       |rwS1| conn_1 | False   | create table test(id int)               | success | 5,2     |
       |rwS1| conn_1 | False   | insert into test values(1)              | success | 5,2     |
       |rwS1| conn_1 | False   | select * from test                      | success | 5,2     |



     Given delete file "/opt/dble/BtraceSelectRWDbGroup.java" on "dble-1"
     Given delete file "/opt/dble/BtraceSelectRWDbGroup.java.log" on "dble-1"
     Given prepare a thread run Btrace script "BtraceSelectRWDbGroup.java" in "dble-1"
     #delete slave dbInstance
     Given prepare a thread execute sql "select * from test" with "conn_1"
    # 先判断执行select * from test语句进入桩了，再执行delete from dble_db_instance*
    Then check btrace "BtraceSelectRWDbGroup.java" output in "dble-1" with "1" times
      """
        get into reSelectRWDbGroup
      """
     Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose | sql                                                   | expect             | db      |
        | conn_2 | False   | delete from dble_db_instance where name='hostM2'      | success            | dble_information   |
     # 偶发超过10s后 select * from test 语句都未返回结果，观测到和delete from dble_db_instance*语句（此语句会触发reload）执行时间非常近
     # 先在未返回时打印jstack再分析具体原因
     Then check sql thread output in "res" by retry "10" times
        """
          (1,)
        """

     # add slave dbInstance
     Given prepare a thread execute sql "select * from test" with "conn_1"
     Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose | sql                                                         | db      |
        | conn_2 | true    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostM2','ha_group2','172.100.9.6',3307,'test','111111','false','false',1,99)            | dble_information   |

     Then check sql thread output in "res" by retry "10" times
        """
          (1,)
        """
    # 前面select * from test进入了1次桩，加上本次select * from test就是2次，触发reload不会进入桩
    Then check btrace "BtraceSelectRWDbGroup.java" output in "dble-1" with "2" times
      """
        get into reSelectRWDbGroup
      """
    Given stop Btrace script "BtraceSelectRWDbGroup.java" in "dble-1"
    Given destroy Btrace threads list
    Then execute sql in "dble-1" in "user" mode
       |user| conn   | toClose | sql                                     | expect  |
       |rwS1| conn_1 | true    | drop database testdb                    | success |
    Given delete file "/opt/dble/BtraceSelectRWDbGroup.java" on "dble-1"
    Given delete file "/opt/dble/BtraceSelectRWDbGroup.java.log" on "dble-1"


    Scenario: When the front connection is bound with the dbGroup, reload is triggered multiple times and the dbgroup connection is obtained recursively ten times    #4
      Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
        """
        s/-Dprocessors=1/-Dprocessors=10/
        s/-DprocessorExecutor=1/-DprocessorExecutor=10/
        """
      Given delete the following xml segment
        | file          | parent           | child                   |
        | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
        | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
        | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
        | user.xml        |{'tag':'root'}   | {'tag':'shardingUser'} |
      Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
         """
         <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group2" maxCon="0"/>
         """
      Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
          """
            <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
              <heartbeat>select user()</heartbeat>
              <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="10" minCon="3" primary="true"/>
              <dbInstance name="hostM2" password="111111" url="172.100.9.6:3307" user="test" maxCon="10" minCon="3"/>
            </dbGroup>
          """
      Given Restart dble in "dble-1" success

      Given execute sql in "dble-1" in "user" mode
       |user| conn   | toClose | sql                                       | expect  |
       |rwS1| conn_0 | False   | drop database if exists testdb            | success |
       |rwS1| conn_0 | true    | create database testdb                    | success |

      Given execute sql in "dble-1" in "user" mode
       |user| conn   | toClose | sql                                     | expect  | timeout |
       |rwS1| conn_1 | False   | use testdb                              | success | 5,2     |
       |rwS1| conn_1 | False   | create table test(id int)               | success | 5,2     |
       |rwS1| conn_1 | False   | insert into test values(1)              | success | 5,2     |
       |rwS1| conn_1 | False   | select * from test                      | length{(1)} | 5,2     |

     Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                             | expect  |
      | conn_0 | True    | set global max_connections=1000 | success |

     Given delete file "/opt/dble/BtraceRwSplitSession.java" on "dble-1"
     Given delete file "/opt/dble/BtraceRwSplitSession.java.log" on "dble-1"
     Given prepare a thread run Btrace script "BtraceRwSplitSession.java" in "dble-1"
     Given prepare a thread execute sql "select * from test" with "conn_1"

     #every time need 2 seconds,make sure execute time more than 11*2
     Then execute "admin" sql for "24" seconds in "dble-1"
        | conn   | toClose | sql                                                         | db      |
        | conn_2 | False   | delete from dble_db_instance where name='hostM2'            | dble_information   |
        | conn_2 | False   | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostM2','ha_group2','172.100.9.6',3307,'test','111111','false','false',1,99)| dble_information|
     #检测第一次桩至少结束了（select * from test），再去检测后面的步骤
     Then check Btrace "BtraceRwSplitSession.java" output in "dble-1" with ">0" times
        """
         sleep end
        """
     #recursion 10 times still not obtain invalid dbGroup connection, and eleventh return error, enter BtraceRwSplitSession total 11 times
     Then check Btrace "BtraceRwSplitSession.java" output in "dble-1" with "11" times
        """
          get into bindRwSplitSession
        """
     #if check failed, should first try add BtraceRwSplitSession.java sleep time
     Then check sql thread output in "err" by retry "5" times
        """
          is always invalid, pls check reason
        """
     Given stop Btrace script "BtraceRwSplitSession.java" in "dble-1"
     Given destroy Btrace threads list

     Then execute sql in "dble-1" in "user" mode
       |user| conn   | toClose | sql                                     | expect  |
       |rwS1| conn_1 | true    | drop database testdb                    | success |

     Then execute sql in "mysql-slave1"
       | conn   | toClose | sql                             | expect  |
       | conn_0 | True    | set global max_connections=151  | success |

     Given delete file "/opt/dble/BtraceRwSplitSession.java" on "dble-1"
     Given delete file "/opt/dble/BtraceRwSplitSession.java.log" on "dble-1"