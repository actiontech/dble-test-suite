# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/12/23


Feature: on zookeeper to check "xa"

  @btrace @restore_xa_recover
  Scenario: check during xa ,check xalog on zookeeper #1
   """
   {'restore_xa_recover':['mysql-master1', 'mysql-master2']}
   """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                     | expect   | db       |
      | conn_1 | False    | drop table if exists sharding_4_t1                      | success  | schema1  |
      | conn_1 | False    | create table sharding_4_t1(id int,name varchar(20))     | success  | schema1  |
      | conn_1 | false    | set autocommit=0                                        | success  | schema1  |
      | conn_1 | false    | set xa=on                                               | success  | schema1  |
      | conn_1 | False    | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success  | schema1  |
    Given update file content "./assets/BtraceXaDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /delayBeforeXaCommit/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(2000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given prepare a thread execute sql "commit" with "conn_1"
    Then check zk has "Y" the following values in "/dble/cluster-1" with retry "10,3" times in "dble-1"
      """
      xalog
      """
    #sleep 10s, because btrace sleep (4node x 2s)=8s
    Given sleep "10" seconds
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"
    #use "select" to check "commit" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                   | expect       | db       |
      | conn_1 | false    | set autocommit=1                      | success      | schema1  |
      | conn_1 | false    | set xa=off                            | success      | schema1  |
      | conn_1 | false    | select * from sharding_4_t1           | length{(4)}  | schema1  |
      | conn_1 | True     | drop table if exists sharding_4_t1    | success      | schema1  |
    Given execute linux command in "dble-1"
    """
    rm -rf /opt/dble/logs/dble_*
    """