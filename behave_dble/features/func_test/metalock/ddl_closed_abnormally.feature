# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/4/6
Feature: test ddl closed abnormally
  #   3.21.02 dble-9017
#  ddl executes the select 1 to verify the connection phase, closes the connection to verify the release of the ddl lock
#  In the second step of the ddl execution process: after issuing the ddl statement, and some nodes have completed the ddl, and some nodes have not completed the ddl,
#          the connection is closed to verify the consistency of the table structure and the release of the ddl lock
#  After the ddl executes select 1 and returns successfully, when checking whether the session is alive, close the connection to verify the release of the ddl lock


   @btrace
  Scenario: Once the DDL task has been executed, regardless of whether the front-end connection exists, it does not affect the execution of the internal DDL      #1

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
           <property name="heartbeatPeriodMillis">60000</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
           <property name="heartbeatPeriodMillis">100000</property>
        </dbInstance>
    </dbGroup>
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /-DsqlExecuteTimeout=1000/d
      /-DrecordTxn=1/d
      /-DxaRecoveryLogBaseName=xalog/d
      /-DxaSessionCheckPeriod=2000/d
      /-DxaLogCleanPeriod=100000/d
      /-DprocessorExecutor=4/d

      /# processor/a -DsqlExecuteTimeout=1000
      /# processor/a -DrecordTxn=1
      /# processor/a -DxaSessionCheckPeriod=2000
      /# processor/a -DxaLogCleanPeriod=100000
      /# processor/a -DprocessorExecutor=4
      """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect   | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1                  | success  | schema1 |
      | conn_1 | False   | create table sharding_2_t1(id int,name int,age int) | success  | schema1 |

    Given delete file "/opt/dble/BtraceAddMetaLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAddMetaLock.java.log" on "dble-1"

    Given update file content "./assets/BtraceAddMetaLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /sleepWhenAddMetaLock/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceAddMetaLock.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                   | db      |
      | conn_1 | False   | truncate table sharding_2_t1          | schema1 |
    Then check btrace "BtraceAddMetaLock.java" output in "dble-1"
    """
    get into addMetaLock,start sleep
    """
    Given kill mysql query in "dble-1" forcely
    """
    truncate table sharding_2_t1
    """
    Given sleep "15" seconds
    Given stop btrace script "BtraceAddMetaLock.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                            | expect      | db      |
      | conn_2 | False   | truncate table sharding_2_t1   | success     | schema1 |

   # After the ddl is actually issued
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /delayDdLToDeliver/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                         | db      |
      | conn_2 | False   | alter table sharding_2_t1 drop name         | schema1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
    """
    get into delayDdLToDeliver
    """
    Given kill mysql query in "dble-1" forcely
    """
    alter table sharding_2_t1 drop name
    """
    Given sleep "20" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                            | expect      | db      |
      | conn_3 | False   | truncate table sharding_2_t1   | success     | schema1 |

    Then execute sql in "mysql-master1"
      | conn    | toClose | sql                         | expect                                                                                 | db  |
      | conn_11 | False   | desc sharding_2_t1          | has{(('id', 'int(11)', 'YES', '', None, ''), ('age', 'int(11)', 'YES', '', None, ''))} | db1 |
    Then execute sql in "mysql-master2"
      | conn    | toClose | sql                         | expect                                                                                 | db  |
      | conn_22 | False   | desc sharding_2_t1          | has{(('id', 'int(11)', 'YES', '', None, ''), ('age', 'int(11)', 'YES', '', None, ''))} | db1 |


   # After the select 1 returns successfully, verify that the session is alive
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /delayDdLToDeliver/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                         | db      |
      | conn_3 | False   | alter table sharding_2_t1 drop age          | schema1 |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
    """
    get into delayDdLToDeliver
    """
    Given kill mysql query in "dble-1" forcely
    """
    alter table sharding_2_t1 drop age
    """
    Given sleep "20" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list

    Then execute sql in "mysql-master1"
      | conn    | toClose | sql                         | expect                                        | db  |
      | conn_11 | true    | desc sharding_2_t1          | has{(('id', 'int(11)', 'YES', '', None, ''))} | db1 |
    Then execute sql in "mysql-master2"
      | conn    | toClose | sql                         | expect                                        | db  |
      | conn_22 | true    | desc sharding_2_t1          | has{(('id', 'int(11)', 'YES', '', None, ''))} | db1 |

    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                      | expect      | db      |
      | conn_31 | False   | truncate table sharding_2_t1             | success     | schema1 |
      | conn_31 | False   | drop table if exists sharding_2_t1       | success     | schema1 |

    Given delete file "/opt/dble/BtraceAddMetaLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAddMetaLock.java.log" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
