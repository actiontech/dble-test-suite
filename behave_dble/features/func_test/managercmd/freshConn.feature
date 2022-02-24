# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2020/9/10
#modified by wujinling at 2020/12/09

Feature: test fresh backend connection pool
  @CRITICAL
  Scenario: Use check session transaction ISOLATION level for any changes to confirm whether the connection pool has been refreshed #1
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "mysql-master2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                          | expect            | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                        | success          | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int)                        | success          | schema1 |
      | conn_0 | False    | begin                                                        | success          | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1),(2),(3),(4)    | success          | schema1 |
    #1.fresh single dbInstance
    When execute sql in "dble-1" in "admin" mode
      | sql                                                                   | expect   | db                 |
      | fresh conn where dbGroup ='ha_group2' and dbInstance='hostM2'         | success  | dble_information   |
    # The 4 in-used connections in hostM2 have not been refresh, and other connections in hostM2 have been refreshed
    # except hostM2, the other dbInstances' connections all have been refreshed
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect                         | db      |
      | conn_0 | False   | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}    | schema1  |
      | conn_1 | True    | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}   | schema1  |
      | conn_2 | True    | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}    | schema1  |
    #2.fresh dbGroup
    When execute sql in "dble-1" in "admin" mode
      | sql                                                                          | expect  |db                 |
      | fresh conn forced where dbGroup ='ha_group2'                                  | success |dble_information   |
    # all the connections(include connections in transaction) in ha_group2 will be refresh when the command contains force keyword
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                               | expect                         | db      |
      | conn_0 | True    | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  MySQL server has gone away   | schema1  |
      | conn_1 | True    | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}   | schema1  |
      | conn_2 | True    | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}    | schema1  |

  @CRITICAL @btrace
  Scenario: execute fresh command during executing reload command, fresh command will return error #2
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Dprocessors=1/c -Dprocessors=2
    /-DprocessorExecutor=1/c -DprocessorExecutor=2
    """
    Given restart dble in "dble-1" success
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                                                 | expect      | db  |
      | conn_0 | True    | set global transaction ISOLATION level READ UNCOMMITTED             | success     | db1 |
    Given update file content "./assets/BtraceFreshConnLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /startReload/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceFreshConnLock.java" in "dble-1"
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose  | sql                                     |db                    |
      | root | 111111 | conn_0 | True    | reload @@config_all                    | dble_information   |
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    get reload lock
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect                                                                          |
      | conn_1 | True    | fresh conn where dbGroup ='ha_group1'                 | may be other mutex events that cause interrupt, try again later                 |
    Given stop btrace script "BtraceFreshConnLock.java" in "dble-1"
    Given destroy btrace threads list
    #sleep 10s for waiting btrace end and fresh command return success
    Given sleep "10" seconds
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    ERROR
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect                         | db      |
      | conn_0 | True    | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}    | schema1  |
      | conn_1 | True    | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}    | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect           |
      | conn_2 | True    | fresh conn where dbGroup ='ha_group1'                 | success          |
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"

  @CRITICAL @btrace
  Scenario: fresh connection multi-times at the same time, other fresh command will return error #3
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Dprocessors=1/c -Dprocessors=2
    /-DprocessorExecutor=1/c -DprocessorExecutor=2
    """
    Given restart dble in "dble-1" success
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                                                 | expect      | db  |
      | conn_0 | True    | set global transaction ISOLATION level READ UNCOMMITTED             | success     | db1 |
    Given update file content "./assets/BtraceFreshConnLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /freshConnGetRealodLocekAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceFreshConnLock.java" in "dble-1"
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose | sql                                       |db                    |
      | root | 111111 | conn_0 | True    | fresh conn where dbGroup ='ha_group1' | dble_information   |
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    freshConnGetRealodLocekAfter
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                        | expect                                                                                  |
      | conn_1 | True    | fresh conn where dbGroup ='ha_group1'                 | may be other mutex events that cause interrupt, try again later                 |
    Given stop btrace script "BtraceFreshConnLock.java" in "dble-1"
    Given destroy btrace threads list
    #sleep 10s for waiting btrace end and the first fresh command return success
    Given sleep "10" seconds
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    ERROR
    """
    #after the first fresh command return ok, then execute other fresh command will execute success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect                         | db      |
      | conn_0 | True    | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}   | schema1  |
      | conn_1 | True    | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}    | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect           |
      | conn_2 | True    | fresh conn where dbGroup ='ha_group1'                 | success          |
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"

  @CRITICAL @btrace
  Scenario: execute sql during executing fresh command, sql will hang #4
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Dprocessors=1/c -Dprocessors=2
    /-DprocessorExecutor=1/c -DprocessorExecutor=2
    """
    Given restart dble in "dble-1" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                             | expect      | db      |
      | conn_0 | false    | drop table if exists nosharding                                 | success | schema1 |
      | conn_0 | false    | create table nosharding(id int)                                 | success | schema1 |
      | conn_0 | True     | insert into nosharding values(102)                              | success | schema1 |
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                                                 | expect      | db  |
      | conn_0 | True    | set global transaction ISOLATION level READ UNCOMMITTED             | success     | db1 |
    Given update file content "./assets/BtraceFreshConnLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /stopConnGetFrenshLocekAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceFreshConnLock.java" in "dble-1"
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose  | sql                                         |db                   |
      | root | 111111 | conn_1 | True     | fresh conn where dbGroup ='ha_group1'       | dble_information    |
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    stopConnGetFrenshLocekAfter
    """
    #execute sql will hang until fresh return success
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                       | db      |
      | conn_2 | True    | select * from nosharding               | schema1 |
    #sleep 5s and check sql still hang
    Given sleep "5" seconds
    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
    """
    102
    """
    Given stop btrace script "BtraceFreshConnLock.java" in "dble-1"
    Given destroy btrace threads list
    #sleep 15s for waiting btrace end and the first fresh command return ok
    Given sleep "15" seconds
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
    """
    102
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect                         | db      |
      | conn_0 | True    | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}   | schema1  |
      | conn_0 | True    | /*!dble:shardingNode=dn3*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}   | schema1  |
      | conn_0 | True    | /*!dble:shardingNode=dn5*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}   | schema1  |
      | conn_1 | True    | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}    | schema1  |
      | conn_1 | True    | /*!dble:shardingNode=dn4*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}    | schema1  |
    #after the first fresh command return ok, then execute other sql will return ok
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect      | db      |
      | conn_3 | True    | drop table if exists nosharding         | success     | schema1 |
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"

  @CRITICAL @btrace
  Scenario: execute fresh command during executing sql, fresh command will hang #5
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                      | expect  | db      |
      | conn_0 | false    | drop table if exists nosharding                          | success | schema1 |
      | conn_0 | false    | create table nosharding(id int)                          | success | schema1 |
      | conn_0 | True     | insert into nosharding values(101),(102),(103),(104)     | success | schema1 |
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                                                 | expect      | db  |
      | conn_0 | True    | set global transaction ISOLATION level READ UNCOMMITTED             | success     | db1 |
    Given update file content "./assets/BtraceFreshConnLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /getConnGetFrenshLocekAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceFreshConnLock.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                       | db      |
      | conn_1 | True    | select * from nosharding               | schema1 |
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1" with "1" times
    """
    getConnGetFrenshLocekAfter
    """
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                | db                 |
      | conn_2 | True    | fresh conn where dbGroup ='ha_group1'              | dble_information |
    Given stop btrace script "BtraceFreshConnLock.java" in "dble-1"
    Given destroy btrace threads list
    #sleep 10s for waiting btrace end and the fresh command return ok
    Given sleep "10" seconds
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
    """
    id
    101
    102
    103
    104
    """
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    ERROR
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect                         | db      |
      | conn_0 | True    | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}   | schema1  |
      | conn_1 | True    | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation    |  has{('REPEATABLE-READ',),}    | schema1  |
    #after the sql return ok, then execute other fresh command will return ok
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                                                 | expect      | db  |
      | conn_0 | True    | set global transaction ISOLATION level REPEATABLE READ              | success     | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                         | expect           |
      | conn_3 | True    | fresh conn forced where dbGroup ='ha_group1'                 | success          |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect                         | db      |
      | conn_0 | True    | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}    | schema1  |
      | conn_1 | True    | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation    |  has{('REPEATABLE-READ',),}    | schema1  |
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"