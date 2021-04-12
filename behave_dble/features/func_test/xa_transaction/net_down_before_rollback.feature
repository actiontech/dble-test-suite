# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/4/2

#  3.21.02 dble-9008
#  Before the xa transaction is rolled back, open the firewall to the dble on the host where a certain fragment is located.
#  When the transaction is rolled back, the firewall is open and waits.
#  When the waiting is not ended and after waiting for an error, the firewall is turned off, and the transaction is rolled back successfully.


Feature: Before the xa transaction is rolled back, open the firewall to the dble on the host where a certain fragment is located

  @restore_network
  Scenario: Before the xa transaction is rolled back, open the firewall to the dble on the host where a certain fragment is located    #1
    """
    {'restore_network':'mysql-master1'}
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /DidleTimeout/d
      /# processor/a -DidleTimeout=20000
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
            <property name="heartbeatPeriodMillis">600000</property>
        </dbInstance>
    </dbGroup>
    """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                  | expect      | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                                   | success     | schema1 |
      | conn_0 | False   | create table sharding_4_t1 (id int,customerid int,accountno varchar(20),amount decimal(10,2))        | success     | schema1 |
      | conn_0 | False   | set autocommit = 0                                                                                   | success     | schema1 |
      | conn_0 | False   | set xa=1                                                                                             | success     | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values (1, 1,'a0301',0),(2,2,'a0601',0), (3,3,'a0301',0),(4,601,'a0601',0) | success     | schema1 |
      | conn_0 | true    | select * from sharding_4_t1                                                                          | length{(4)} | schema1 |

    Given execute oscmd in "mysql-master1"
    """
    iptables -A OUTPUT -d 172.100.9.1 -j DROP
    iptables -A INPUT -s 172.100.9.1 -j DROP
    """
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql         | db      |
      | conn_0 | False   | rollback    | schema1 |
    Given sleep "2" seconds
    Given execute oscmd in "mysql-master1"
    """
    iptables -F
    """
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                  | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1                                                                          | length{(0)} | schema1 |
      | conn_0 | False   | set autocommit = 0                                                                                   | success     | schema1 |
      | conn_0 | False   | set xa=1                                                                                             | success     | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values (1, 1,'a0301',0),(2,2,'a0601',0), (3,3,'a0301',0),(4,601,'a0601',0) | success     | schema1 |

    Given execute oscmd in "mysql-master1"
    """
    iptables -A OUTPUT -d 172.100.9.1 -j DROP
    iptables -A INPUT -s 172.100.9.1 -j DROP
    """
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql         | db      |
      | conn_0 | False   | rollback    | schema1 |
    Given sleep "20" seconds
    Given execute oscmd in "mysql-master1"
    """
    iptables -F
    """
    Given sleep "3" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                           | expect                                    | db      |
      | conn_0 | False   | select * from sharding_4_t1                   | MySQL server has gone away                | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                           | expect                     | db      |
      | conn_1 | False   | select * from sharding_4_t1                   | length{(0)}                | schema1 |
      | conn_1 | true    | drop table if exists sharding_4_t1            | success                    | schema1 |