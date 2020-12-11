# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2020/9/10
#modified by wujinling at 2020/12/09

Feature:#test fresh backend connection pool

  @skip
  Scenario: #Use check session transaction ISOLATION level for any changes to confirm whether the connection pool has been refreshed
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level REPEATABLE READ             | success    | db1 |
    Given execute sql in "mysql-master2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level REPEATABLE READ             | success    | db1 |
    Given execute sql in "mysql-slave1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level REPEATABLE READ             | success    | db1 |
    Given execute sql in "mysql-slave2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level REPEATABLE READ             | success    | db1 |
    Given Restart dble in "dble-1" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="150" minCon="10" readWeight="1" primary="true"/>
          <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="150" minCon="10" readWeight="1"/>
          <dbInstance name="hostM3" password="111111" url="172.100.9.3:3306" user="test" maxCon="150" minCon="10" readWeight="2"/>
      </dbGroup>
    """
    Given execute admin cmd "reload @@config_all" success
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "mysql-master2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "mysql-slave1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "mysql-slave2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql      | expect            | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1   | success          | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int)   | success          | schema1 |
      | conn_0 | False    | begin   | success          | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1),(2),(3),(4)    | success          | schema1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | fresh conn where dbGroup ='ha_group2' and dbInstance='hostM2' | success |
    # ha_group2 master not fresh session.tx_isolation is old
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  hasStr{REPEATABLE-READ}         | schema1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | fresh conn where dbGroup ='ha_group2' and dbInstance='hostM1,hostM3' | success |
    #ha_group2 master fresh session.tx_isolation is new
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}         | schema1 |
    # ha_group1 not fresh session.tx_isolation is old
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}         | schema1 |
    #connection in Transaction is old
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect                  | db      |
      | conn_0 | False   | SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}         | schema1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                        | expect  |
      | fresh conn where dbGroup ='ha_group1' | success |
    # ha_group1 fresh session.tx_isolation is new
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect                                 | db      |
      | conn_1 | True    | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}         | schema1 |
    #connection in Transaction is old
    Then execute sql in "dble-1" in "user" mode                               
      | conn   | toClose | sql                              | expect                         | db      |
      | conn_0 | False   | SELECT @@session.tx_isolation | has{('REPEATABLE-READ',),} | schema1 |
      | conn_0 | True    | commit                           | success                       | schema1 |
    Then execute sql in "dble-1" in "user" mode                               
      | conn   | toClose | sql                               | expect                       | db      |
      | conn_0 | True    | SELECT @@session.tx_isolation | has{('REPEATABLE-READ',),} | schema1 |
    Given execute sql in "dble-1" in "user" mode                              
      | conn   | toClose | sql                                                   | expect  | db      |
      | conn_0 | False   | begin                                                 | success | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1),(2),(3),(4) | success | schema1 |
    Given execute sql in "mysql-master1"                                      
      | conn   | toClose | sql                                                           | expect  | db  |
      | conn_1 | True    | set global transaction ISOLATION level REPEATABLE READ | success | db1 |
    Given execute sql in "mysql-master2"                                      
      | conn   | toClose | sql                                                           | expect  | db  |
      | conn_1 | True    | set global transaction ISOLATION level REPEATABLE READ | success | db1 |
    Given execute sql in "mysql-slave1"                                       
      | conn   | toClose | sql                                                           | expect  | db  |
      | conn_1 | True    | set global transaction ISOLATION level REPEATABLE READ | success | db1 |
    Given execute sql in "mysql-slave2"                                       
      | conn   | toClose | sql                                                           | expect  | db  |
      | conn_1 | True    | set global transaction ISOLATION level REPEATABLE READ | success | db1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | fresh conn where dbGroup ='ha_group1' and dbInstance='hostM1,hostM1' | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}         | schema1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | fresh conn where dbGroup ='ha_group2' and dbInstance='hostM1,hostM1,hostM2' | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}         | schema1 |
    When execute sql in "dble-1" in "admin" mode                              
      | sql                                                | expect  |
      | fresh conn forced where dbGroup ='ha_group1' | success |
    When execute sql in "dble-1" in "admin" mode                              
      | sql                                                | expect  |
      | fresh conn forced where dbGroup ='ha_group2' | success |
    Then execute sql in "dble-1" in "user" mode                               
      | conn   | toClose | sql                              | expect                        | db      |
      | conn_1 | True    | SELECT @@session.tx_isolation | has{('REPEATABLE-READ',),} | schema1 |

  @btrace
  Scenario: #execute fresh command during executing reload command, fresh command will return error #2
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Dprocessors=1/c -Dprocessors=2
    /-DprocessorExecutor=1/c -DprocessorExecutor=2
    """
    Given restart dble in "dble-1" success
    Given update file content "./assets/BtraceFreshConnLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /reloadWithoutCluster/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
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
      | conn   | toClose | sql                                                   | expect                                                                                  |
      | conn_1 | True    | fresh conn where dbGroup ='ha_group1'            | may be other mutex events that cause interrupt, try again later                 |
    Given stop btrace script "BtraceFreshConnLock.java" in "dble-1"
    Given destroy btrace threads list
    #sleep 10s for waiting btrace end and fresh command return success
    Given sleep "10" seconds
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    ERROR
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect           |
      | conn_2 | True    | fresh conn where dbGroup ='ha_group1'            | success          |
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"

  @btrace
  Scenario: #fresh connection multi-times at the same time, other fresh command will return error #3
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
#    Given delete file "/tmp/dble_query.log" on "dble-1"
    Given update file content "./assets/BtraceFreshConnLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /freshConnGetRealodLocekAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceFreshConnLock.java" in "dble-1"
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose | sql                                       |
      | root | 111111 | conn_0 | True    | fresh conn where dbGroup ='ha_group1' |
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    freshConnGetRealodLocekAfter
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect                                                                                  |
      | conn_1 | True    | fresh conn where dbGroup ='ha_group1'            | may be other mutex events that cause interrupt, try again later                 |
    Given stop btrace script "BtraceFreshConnLock.java" in "dble-1"
    Given destroy btrace threads list
    #sleep 10s for waiting btrace end and the first fresh command return success
    Given sleep "10" seconds
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    ERROR
    """
    #after the first fresh command return ok, then execute other fresh command will execute success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect           |
      | conn_2 | True    | fresh conn where dbGroup ='ha_group1'            | success          |
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
#    Given delete file "/tmp/dble_query.log" on "dble-1"

  @btrace
  Scenario: #execute sql during executing fresh command, sql will hang #4
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
#    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
#    """
#    /-Dprocessors=1/c -Dprocessors=2
#    /-DprocessorExecutor=1/c -DprocessorExecutor=2
#    """
#    Given restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                             | expect      | db      |
      | conn_0 | false    | drop table if exists sharding_4_t1                          | success | schema1 |
      | conn_0 | false    | create table sharding_4_t1(id int)                          | success | schema1 |
      | conn_0 | True     | insert into sharding_4_t1 values(101),(102),(103),(104)  | success | schema1 |
    Given update file content "./assets/BtraceFreshConnLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /stopConnGetFrenshLocekAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceFreshConnLock.java" in "dble-1"
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose | sql                                         |db                     |
      | root | 111111 | conn_1 | False    | fresh conn where dbGroup ='ha_group1' | dble_information    |
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1"
    """
    stopConnGetFrenshLocekAfter
    """
    #execute sql will hang until fresh return success
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                    | db      |
      | conn_2 | False   | select * from sharding_4_t1         | schema1 |
    Given stop btrace script "BtraceFreshConnLock.java" in "dble-1"
    Given destroy btrace threads list
    #sleep 10s for waiting btrace end and the first fresh command return ok
    Given sleep "2" seconds
    #block by issue: http://10.186.18.11/jira/browse/DBLE0REQ-793
    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
    """
    102
    """
    Given sleep "5" seconds
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
    """
    102
    """
    #after the first fresh command return ok, then execute other fresh command will return ok
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | expect      | db      |
      | conn_3 | True    | drop table if exists sharding_4_t1  | success     | schema1 |
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"

  @btrace @cur
  Scenario: #execute fresh command during executing sql, fresh command will hang #5
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                              | expect      | db      |
      | conn_0 | false    | drop table if exists sharding_4_t1                          | success | schema1 |
      | conn_0 | false    | create table sharding_4_t1(id int)                          | success | schema1 |
      | conn_0 | True     | insert into sharding_4_t1 values(101),(102),(103),(104)  | success | schema1 |
    Given update file content "./assets/BtraceFreshConnLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /getConnGetFrenshLocekAfter/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceFreshConnLock.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                    | db      |
      | conn_1 | True    | select * from sharding_4_t1         | schema1 |
    #block by issue: http://10.186.18.11/jira/browse/DBLE0REQ-793
    Then check btrace "BtraceFreshConnLock.java" output in "dble-1" with "1" times
    """
    freshConnGetRealodLocekAfter
    """
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                | db                 |
      | conn_2 | True    | fresh conn where dbGroup ='ha_group1'         | dble_information |
    Given stop btrace script "BtraceFreshConnLock.java" in "dble-1"
    Given destroy btrace threads list
    #sleep 40s for waiting btrace end and the first fresh command return ok
    Given sleep "40" seconds
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
    #after the sql return ok, then execute other fresh command will return ok
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect           |
      | conn_3 | True    | fresh conn where dbGroup ='ha_group1'            | success          |
    Given delete file "/opt/dble/BtraceFreshConnLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceFreshConnLock.java.log" on "dble-1"

















