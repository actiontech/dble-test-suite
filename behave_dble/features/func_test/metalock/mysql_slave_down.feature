# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/4/6
Feature: test mysql one node down
#  3.21.02 dble-9035
#  During the transaction, after one of the mysql nodes hangs up, verify the commit error. After the node is restored, verify the correctness of the transaction and the successful release of the lock
#  ddl executes the issue of select 1 to verify the connection phase, the back-end mysql node is disconnected, and the error report of the ddl is verified. After the node is restored,
#      the successful release of the lock and the correctness of the data are verified
#  When the ddl statement is issued in the second step of the ddl execution process, the back-end mysql node is disconnected, and the error report of the ddl is verified.
#       After the node is restored, the successful release of the lock is verified


   @btrace   @restore_mysql_service
  Scenario: mysql one node down     #1
    """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1},'mysql-master2':{'start_mysql':1}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="sing1" shardingNode="dn1" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                               | expect   | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                | success  | schema1 |
      | conn_1 | False   | drop table if exists sing1                                        | success  | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name int,age int)               | success  | schema1 |
      | conn_1 | False   | create table sing1(id int,name int,age int)                       | success  | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4)  | success  | schema1 |
      | conn_1 | False   | insert into sing1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4)          | success  | schema1 |
      | conn_1 | False   | begin                                                             | success  | schema1 |
      | conn_1 | False   | update sharding_4_t1 set age=18                                   | success  | schema1 |

    #stop one mysql
    Given stop mysql in host "mysql-master2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql             | expect                               | db      |
      | conn_1 | False   | commit          | Transaction error, need to rollback  | schema1 |
    Given start mysql in host "mysql-master2"
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect                                   | db      |
      | conn_1 | False   | select * from sharding_4_t1           | Transaction error, need to rollback      | schema1 |
      | conn_1 | False   | rollback                              | success                                  | schema1 |
      | conn_1 | False   | select * from sharding_4_t1           | has{((1,1,1),(2,2,2),(3,3,3),(4,4,4))}   | schema1 |
      | conn_1 | False   | delete from sharding_4_t1             | success                                  | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                               | expect   | db      |
      | conn_1 | False   | begin                                                             | success  | schema1 |
      | conn_1 | False   | update sing1 set age=18                                           | success  | schema1 |

    #stop one mysql #case singtable
    Given stop mysql in host "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql             | expect                               | db      |
      | conn_1 | False   | commit          | Transaction error, need to rollback  | schema1 |
    Given start mysql in host "mysql-master1"
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                           | expect                                   | db      |
      | conn_1 | False   | select * from sing1           | Transaction error, need to rollback      | schema1 |
      | conn_1 | False   | rollback                      | success                                  | schema1 |
      | conn_1 | False   | select * from sing1           | has{((1,1,1),(2,2,2),(3,3,3),(4,4,4))}   | schema1 |
      | conn_1 | False   | delete from sing1             | success                                  | schema1 |


    Given delete file "/opt/dble/BtraceAddMetaLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAddMetaLock.java.log" on "dble-1"
    Given update file content "./assets/BtraceAddMetaLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /sleepWhenAddMetaLock/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceAddMetaLock.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                         | db      |
      | conn_1 | False   | alter table sharding_4_t1 drop age          | schema1 |
    Then check btrace "BtraceAddMetaLock.java" output in "dble-1"
    """
    get into addMetaLock,start sleep
    """
    Given stop mysql in host "mysql-master1"
    Given sleep "15" seconds
     # ERROR 3009 (HY000) at line 1: java.io.IOException: the dbInstance[172.100.9.5:3306] can't reach. Please check the dbInstance status
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      the dbInstance\[172.100.9.5:3306\] can
      t reach. Please check the dbInstance status
      """
    Given stop btrace script "BtraceAddMetaLock.java" in "dble-1"
    Given destroy btrace threads list

    Given start mysql in host "mysql-master1"
    Given sleep "10" seconds
    Then execute sql in "mysql-master1"
      | conn    | toClose | sql                         | expect                                                                                                                           | db  |
      | conn_11 | true    | desc sharding_4_t1          | has{(('id', 'int(11)', 'YES', '', None, ''), ('name', 'int(11)', 'YES', '', None, ''), ('age', 'int(11)', 'YES', '', None, ''))} | db1 |
      | conn_21 | true    | desc sharding_4_t1          | has{(('id', 'int(11)', 'YES', '', None, ''), ('name', 'int(11)', 'YES', '', None, ''), ('age', 'int(11)', 'YES', '', None, ''))} | db2 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect       | db      |
      | conn_1 | False   | alter table sharding_4_t1 drop age     | success      | schema1 |
      | conn_1 | False   | desc sharding_4_t1                     | has{(('id', 'int(11)', 'YES', '', None, ''), ('name', 'int(11)', 'YES', '', None, ''))}     | schema1 |


    #case singtable
    Given prepare a thread run btrace script "BtraceAddMetaLock.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                 | db      |
      | conn_1 | False   | alter table sing1 drop age          | schema1 |
    Then check btrace "BtraceAddMetaLock.java" output in "dble-1"
    """
    get into addMetaLock,start sleep
    """
    Given stop mysql in host "mysql-master1"
    Given sleep "15" seconds
     # ERROR 3009 (HY000) at line 1: java.io.IOException: the dbInstance[172.100.9.5:3306] can't reach. Please check the dbInstance status
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      the dbInstance\[172.100.9.5:3306\] can
      t reach. Please check the dbInstance status
      """
    Given stop btrace script "BtraceAddMetaLock.java" in "dble-1"
    Given destroy btrace threads list
    Given start mysql in host "mysql-master1"
    Given sleep "10" seconds
    Then execute sql in "mysql-master1"
      | conn    | toClose | sql                 | expect                                                                                                                           | db  |
      | conn_11 | true    | desc sing1          | has{(('id', 'int(11)', 'YES', '', None, ''), ('name', 'int(11)', 'YES', '', None, ''), ('age', 'int(11)', 'YES', '', None, ''))} | db1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                            | expect       | db      |
      | conn_1 | False   | alter table sing1 drop age     | success      | schema1 |
      | conn_1 | False   | desc sing1                     | has{(('id', 'int(11)', 'YES', '', None, ''), ('name', 'int(11)', 'YES', '', None, ''))}     | schema1 |


    Given delete file "/opt/dble/BtraceAddMetaLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAddMetaLock.java.log" on "dble-1"
  # DBLE0REQ-1044
    Given update file content "./assets/BtraceAddMetaLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /sleepWhenClearIfSession/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceAddMetaLock.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                            | db      |
      | conn_1 | False   | alter table sharding_4_t1 add age int          | schema1 |
    Then check btrace "BtraceAddMetaLock.java" output in "dble-1"
    """
    get into clearIfSessionClosed,start sleep
    """
    Given stop mysql in host "mysql-master2"
    Given stop btrace script "BtraceAddMetaLock.java" in "dble-1"
    Given destroy btrace threads list
    Given sleep "6" seconds
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      was closed ,reason is
      """
    Given start mysql in host "mysql-master2"
    Given sleep "30" seconds
    Then execute sql in "mysql-master1"
      | conn    | toClose | sql                         | expect                                                                                                                           | db  |
      | conn_11 | true    | desc sharding_4_t1          | has{(('id', 'int(11)', 'YES', '', None, ''), ('name', 'int(11)', 'YES', '', None, ''), ('age', 'int(11)', 'YES', '', None, ''))} | db1 |
      | conn_12 | true    | desc sharding_4_t1          | has{(('id', 'int(11)', 'YES', '', None, ''), ('name', 'int(11)', 'YES', '', None, ''), ('age', 'int(11)', 'YES', '', None, ''))} | db2 |
    Then execute sql in "mysql-master2"
      | conn    | toClose | sql                         | expect                                                                                  | db  |
      | conn_21 | true    | desc sharding_4_t1          | has{(('id', 'int(11)', 'YES', '', None, ''), ('name', 'int(11)', 'YES', '', None, ''))} | db1 |
      | conn_22 | true    | desc sharding_4_t1          | has{(('id', 'int(11)', 'YES', '', None, ''), ('name', 'int(11)', 'YES', '', None, ''))} | db2 |
    Given delete file "/opt/dble/BtraceAddMetaLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAddMetaLock.java.log" on "dble-1"


    #case singtable
    Given update file content "./assets/BtraceAddMetaLock.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /sleepWhensingTable/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceAddMetaLock.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                    | db      |
      | conn_1 | False   | alter table sing1 add age int          | schema1 |
    Then check btrace "BtraceAddMetaLock.java" output in "dble-1"
    """
    get into clearIfSessionClosed,start sleep
    """
    Given stop mysql in host "mysql-master1"
    Given stop btrace script "BtraceAddMetaLock.java" in "dble-1"
    Given destroy btrace threads list
    Given sleep "6" seconds
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      the dbInstance\[172.100.9.5:3306\] can
      t reach. Please check the dbInstance status
      """
    Given start mysql in host "mysql-master1"
    Given sleep "30" seconds
    Then execute sql in "mysql-master1"
      | conn    | toClose | sql                 | expect                                                                                  | db  |
      | conn_11 | False   | desc sing1          | has{(('id', 'int(11)', 'YES', '', None, ''), ('name', 'int(11)', 'YES', '', None, ''))} | db1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect       | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1     | success      | schema1 |
      | conn_1 | true    | drop table if exists sing1             | success      | schema1 |
    Given delete file "/opt/dble/BtraceAddMetaLock.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAddMetaLock.java.log" on "dble-1"




