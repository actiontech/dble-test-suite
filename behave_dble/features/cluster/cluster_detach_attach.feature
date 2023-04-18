
  @btrace
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
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(12000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@attach timeout=1" with "conn_1" and save resultset in "detach_rs"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given execute oscmd "cat /opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given prepare a thread execute sql "show @@general_log" with "conn_2"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Given execute oscmd "cat /opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Then check sql thread output in "detach_rs_err" by retry "10" times
    """
    attach cluster pause timeout
    """
    Then check sql thread output in "res" by retry "8" times
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

  @btrace
  Scenario: check cluster @@attach and timeout use default value 10s when other sql is being executed #7
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
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(8000L)/;/\}/!ba}
    """
    # sleep time > detach timeout default value 10s
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(18000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@attach" with "conn_1" and save resultset in "attach_rs"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given execute oscmd "cat /opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given prepare a thread execute sql "show @@general_log" with "conn_2"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Given execute oscmd "cat /opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Then from btrace sleep "18" seconds get sleep end time and save resultset in "show_end_time"
    Given check sql thread output in "res" by retry "20" times and check sleep time use "show_end_time"
    """
    ('general_log', 'OFF'), ('general_log_file', '/opt/dble/general/general.log')
    """
    Then check sql thread output in "attach_rs_err"
    """
    attach cluster pause timeout. some frontend connection is doing operation.
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

  @btrace
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
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /handle/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(8000L)/;/\}/!ba}
    """
    Given update file content "./assets/BtraceClusterDetachAttach3.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /afterDelayServiceMarkDoing/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach1.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@attach timeout=20" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach1.java" output in "dble-1"
    """
    get into cluster detach or attach handle
    """
    Given execute oscmd "cat /opt/dble/BtraceClusterDetachAttach1.java" on "dble-1"
    Given prepare a thread run btrace script "BtraceClusterDetachAttach3.java" in "dble-1"
    Given prepare a thread execute sql "show @@general_log" with "conn_2"
    Then check btrace "BtraceClusterDetachAttach3.java" output in "dble-1"
    """
    get into afterDelayServiceMarkDoing
    """
    Given execute oscmd "cat /opt/dble/BtraceClusterDetachAttach3.java" on "dble-1"
    Then from btrace sleep "15" seconds get sleep end time and save resultset in "show_end_time"
    Given check sql thread output in "res" by retry "20" times and check sleep time use "show_end_time"
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

  @btrace
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
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /waitOtherSessionBlocked/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """

    # check detach and manager command 执行集群命令时，有即将执行的管理端命令，集群命令先执行
    Given prepare a thread run btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1"
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "reload @@config_all" with "conn_2" and save resultset in "reload_rs"
    Then check sql thread output in "reload_rs_err" by retry "5" times
    """
    Reload Failure.The reason is cluster is detached
    """

    # check attach and manager command
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1" with "==2" times
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "pause @@shardingNode = 'dn1,dn2' and timeout = 10 ,queue = 10,wait_limit = 10" with "conn_2"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose   | sql           | expect                    | timeout |
      | conn_4 | False     | show @@pause  | has{(('dn1',), ('dn2',))} | 8       |
      | conn_4 | True      | resume        | success                   |         |
    Given stop btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                         | db      | expect  |
      | conn_33 | false     | drop table if exists sharding_4_t1          | schema1 | success |
      | conn_33 | false     | create table sharding_4_t1(pid int, id int) | schema1 | success |

    # check detach and ddl
    Given prepare a thread run btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1"
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "create view test_view as select * from sharding_4_t1" with "conn_33" and save resultset in "view_rs"
    Then check sql thread output in "view_rs_err" by retry "5" times
    """
    cluster is detached, you should attach cluster first.
    """

    # check attach and ddl
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1" with "==2" times
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "create view test_view as select * from sharding_4_t1" with "conn_33"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                                   | db      | expect      | timeout |
      | conn_34 | false     | insert into sharding_4_t1 (id) values (1),(2),(3),(4) | schema1 | success     |         |
      | conn_34 | true      | select * from test_view                               | schema1 | length{(4)} | 8       |
    Given stop btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"

    # check detach and xa
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                                  | db      | expect  |
      | conn_33 | false     | set xa=on;set autocommit=0;delete from sharding_4_t1 | schema1 | success |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1"
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "commit" with "conn_33" and save resultset in "commit_rs"
    Then check sql thread output in "commit_rs_err" by retry "5" times
    """
    cluster is detached, you should attach cluster first.
    """

    # check attach and xa
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1" with "==2" times
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "commit" with "conn_33"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                         | db      | expect      | timeout |
      | conn_34 | false     | select * from sharding_4_t1 | schema1 | length{(0)} |    8    |
      | conn_33 | true      | set xa=off                  | schema1 | success     |         |

    Given stop btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list

    # check detach and zk offset-step sequence
    Given prepare a thread run btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1"
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "insert into sharding_4_t1 (id) values (1),(2),(3),(4)" with "conn_34" and save resultset in "insert_rs"
    Then check sql thread output in "insert_rs_err" by retry "5" times
    """
    cluster is detached, you should attach cluster first.
    """

    # check attach and zk offset-step sequence
    Given prepare a thread execute sql "cluster @@attach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach2.java" output in "dble-1" with "==2" times
    """
    get into waitOtherSessionBlocked
    """
    Given prepare a thread execute sql "insert into sharding_4_t1 (id) values (5),(6),(7),(8)" with "conn_34"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                | db      | expect      | timeout |
      | conn_33 | false     | select * from sharding_4_t1        | schema1 | length{(4)} | 8       |
      | conn_33 | false     | drop view if exists test_view      | schema1 | success     |         |
      | conn_33 | true      | drop table if exists sharding_4_t1 | schema1 | success     |         |

    Given stop btrace script "BtraceClusterDetachAttach2.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDetachAttach2.java" on "dble-1"


  @btrace
  Scenario: dble-1 is executing cluster sql, dble-2 is executing detach sql, dble-1 execute success #10
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java.log" on "dble-2"
    Given execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                      | expect                  | db               |
      | conn_1  | false     | select * from dble_table | hasNoStr{sharding_4_t2} | dble_information |
    Given execute sql in "dble-2" in "admin" mode
      | conn    | toClose   | sql                      | expect                  | db               |
      | conn_2  | false     | select * from dble_table | hasNoStr{sharding_4_t2} | dble_information |

    Given update file content "./assets/BtraceClusterDetachAttach5.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /zkOnEvent/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(6000L)/;/\}/!ba}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
         <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
      </schema>
    """
    # check reload
    Given prepare a thread run btrace script "BtraceClusterDetachAttach5.java" in "dble-2"
    Given prepare a thread execute sql "reload @@config_all" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach5.java" output in "dble-2"
    """
    get into zkOnEvent
    """
    Given prepare a thread execute sql "cluster @@detach" with "conn_2"
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                      | expect                | db               | timeout |
      | conn_3  | true      | select * from dble_table | hasStr{sharding_4_t2} | dble_information | 8       |
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose   | sql                      | expect                | db               | timeout |
      | conn_2  | false     | select * from dble_table | hasStr{sharding_4_t2} | dble_information | 8       |
      | conn_2  | true      | cluster @@attach         | success               | dble_information | 8       |

    Given stop btrace script "BtraceClusterDetachAttach5.java" in "dble-2"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java.log" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDetachAttach5.java" on "dble-2"

  @btrace
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
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-2"
    Given update file content "./assets/BtraceClusterDetachAttach6.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /zkDetachCluster/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """

    # check cluster manager command: dble-2 execute cluster @@detach, dble-1 execute reload @@config_all
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                         | expect                    | db               |
      | conn_1  | false     | select name from dble_table | hasNoStr{'sharding_4_t2'} | dble_information |
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose   | sql                         | expect                    | db               |
      | conn_2  | false     | select name from dble_table | hasNoStr{'sharding_4_t2'} | dble_information |
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" incrementColumn="id" shardingColumn="id"/>
    """
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-2"
    Given prepare a thread execute sql "cluster @@detach" with "conn_2"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-2"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "reload @@config_all" with "conn_1"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-2"
    """
    ignore event because of detached
    """
    # dble-1 has new table, dble-2 not
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                         | expect                    | db               | timeout |
      | conn_11 | false     | select name from dble_table | hasStr{'sharding_4_t2'}   | dble_information | 7       |
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose   | sql                         | expect                    | db               |
      | conn_2  | false     | select name from dble_table | hasNoStr{'sharding_4_t2'} | dble_information |
      | conn_2  | true      | cluster @@attach            | success                   | dble_information |
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-2"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java" on "dble-2"

    # check ddl: dble-1 execute cluster @@detach, dble-2 execute ddl
    Given record current dble log line number in "log_line_num"
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                  | expect  | db      |
      | conn_3  | false     | drop table if exists sharding_4_t1   | success | schema1 |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "create table sharding_4_t1(pid int, id int)" with "conn_3"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1"
    """
    ignore event because of detached
    """
    # dble-2 has new table, dble-1 not
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql            | expect                     | db      | timeout |
      | conn_33 | true      | show tables    | has{(('sharding_4_t1',),)} | schema1 | 7       |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql            | expect                        | db      |
      | conn_4  | false     | show tables    | hasnot{(('sharding_4_t1',),)} | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  |
      | conn_1  | false     | cluster @@attach                  | success |
      | conn_1  | false     | reload @@metadata                 | success |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                                      | expect                     | db      |
      | conn_4  | false     | show tables                                              | has{(('sharding_4_t1',),)} | schema1 |
      | conn_4  | true      | insert into sharding_4_t1 (id) values (1),(2),(3),(4)    | success                    | schema1 |
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"

    # check ddl - view: dble-1 execute cluster @@detach, dble-2 execute view ddl
    Given record current dble log line number in "log_line_num"
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "create view test_view as select * from sharding_4_t1" with "conn_3"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1"
    """
    ignore event because of detached
    """
    # dble-2 has view, dble-1 not
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                        | expect      | db      | timeout |
      | conn_33 | true      | select * from test_view    | length{(4)} | schema1 | 7       |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                        | expect                    | db      |
      | conn_4  | false     | show tables                | hasnot{(('test_view',),)} | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  |
      | conn_1  | false     | cluster @@attach                  | success |
      | conn_1  | false     | reload @@metadata                 | success |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                        | expect       | db      |
      | conn_4  | true      | select * from test_view    | length{(4)}  | schema1 |
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"

    # check zk offset-step sequence: dble-1 execute cluster @@detach, dble-2 execute insert
    Given record current dble log line number in "log_line_num"
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      |
      | conn_3  | false     | select * from sharding_4_t1        | length{(4)} | schema1 |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "insert into sharding_4_t1 (id) values (5)" with "conn_3"
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1"
    """
    ignore event because of detached
    """
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      | timeout |
      | conn_4  | true      | select * from sharding_4_t1        | length{(5)} | schema1 | 7       |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                | expect      | db      |
      | conn_3  | true      | select * from sharding_4_t1        | length{(5)} | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn    | toClose   | sql                               | expect  |
      | conn_1  | false     | cluster @@attach                  | success |
    Given stop btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceClusterDetachAttach6.java.log" on "dble-1"

    # check xa: dble-1 execute cluster @@detach, dble-2 execute xa
    Given record current dble log line number in "log_line_num"
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose   | sql                                                 | expect  | db      |
      | conn_3  | false     | set xa=1;set autocommit=0;delete from sharding_4_t1 | success | schema1 |
    Given prepare a thread run btrace script "BtraceClusterDetachAttach6.java" in "dble-1"
    Given prepare a thread execute sql "cluster @@detach" with "conn_1"
    Then check btrace "BtraceClusterDetachAttach6.java" output in "dble-1"
    """
    get into zkDetachCluster
    """
    Given prepare a thread execute sql "commit" with "conn_3"
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1"
    """
    ignore event because of detached
    """
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose   | sql                         | expect      | db      | timeout |
      | conn_4  | true      | select * from sharding_4_t1 | length{(0)} | schema1 | 7       |
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