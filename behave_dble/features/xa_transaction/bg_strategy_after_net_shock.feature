# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/2

Feature: net shock causing xa transaction fail to commit, background execution policy recovery transaction

  @skip_restart
  Scenario: mysql node network shock causing xa transaction fail to commit, recovery network before the front end attempts to commit 5 times #1
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}   |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
       <table name="sharding_4_t1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
    </schema>
    <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
    <dataNode name="dn2" dataHost="ha_group2" database="db1"/>
    <dataNode name="dn3" dataHost="ha_group1" database="db2"/>
    <dataNode name="dn4" dataHost="ha_group2" database="db2"/>
    """
    Given delete the following xml segment
      | file       | parent         | child            |
      | schema.xml | {'tag':'root'} | {'tag':'system'} |

    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
    <property name="xaRetryCount">0</property>
    </system>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | test | 111111 | conn_0 | False   | create table sharding_4_t1(id int,name char)            | success | schema1 |
      | test | 111111 | conn_0 | False   | set autocommit=0                                        | success | schema1 |
      | test | 111111 | conn_0 | False   | set xa=on                                               | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Given sleep "3" seconds
    Given execute oscmd in "mysql-master1"
    """
    iptables -A INPUT -s 172.100.9.1 -j REJECT
    """
    Then check btrace "BtraceXaDelay.java" output in "dble-1" with "5" times
    """
    before xa commit
    """
    Given execute oscmd in "mysql-master1"
    """
    iptables -D INPUT -s 172.100.9.1 -j REJECT
    """
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                         | expect      | db      |
      | test | 111111 | conn_1 | False   | select * from sharding_4_t1 | length{(4)} | schema1 |
      | test | 111111 | conn_1 | True    | delete from sharding_4_t1   | success     | schema1 |

  @skip_restart
  Scenario: mysql node network shock causing xa transaction fail to commit, automatic recovery in background attempts #2
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | test | 111111 | conn_0 | False   | create table sharding_4_t1(id int,name char)            | success | schema1 |
      | test | 111111 | conn_0 | False   | set autocommit=0                                        | success | schema1 |
      | test | 111111 | conn_0 | False   | set xa=on                                               | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Given sleep "3" seconds
    Given execute oscmd in "mysql-master1"
    """
    iptables -A INPUT -s 172.100.9.1 -j REJECT
    """
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given sleep "10" seconds
    Given execute oscmd in "dble-1" and assert "5" should less than result
    """
    cat /opt/dble/logs/dble.log |grep "at the 0th time in background" |wc -l
    """
    Given execute oscmd in "mysql-master1"
    """
    iptables -D INPUT -s 172.100.9.1 -j REJECT
    """
    Given sleep "10" seconds
    Then execute oscmd many times in "dble-1" and assert result is constant
    """
    cat /opt/dble/logs/dble.log |grep "at the 0th time in background" |wc -l
    """
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                         | expect      | db      |
      | test | 111111 | conn_1 | False   | select * from sharding_4_t1 | length{(4)} | schema1 |
      | test | 111111 | conn_1 | True    | delete from sharding_4_t1   | success     | schema1 |

  @skip_restart
  Scenario:  mysql node network shock causing xa transaction fail to commit, close background attempts, execute 'kill @@session.xa' and 'xa commit'  #3
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | test | 111111 | conn_0 | False   | create table sharding_4_t1(id int,name char)            | success | schema1 |
      | test | 111111 | conn_0 | False   | set autocommit=0                                        | success | schema1 |
      | test | 111111 | conn_0 | False   | set xa=on                                               | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given prepare a thread run btrace script "BtraceXaDelay.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Given sleep "3" seconds
    Given execute oscmd in "mysql-master1"
    """
    iptables -A INPUT -s 172.100.9.1 -j REJECT
    """
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Then get resultset of admin cmd "show @@session.xa" named "rs_A"
    Then execute admin cmd "kill @@xa_session" with "rs_A" result
    Then execute oscmd many times in "dble-1" and assert result is constant
    """
    cat /opt/dble/logs/dble.log |grep "at the 0th time in background" |wc -l
    """
    Given execute oscmd in "mysql-master1"
    """
    iptables -D INPUT -s 172.100.9.1 -j REJECT
    """
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                    | expect                     | db      |
      | test | 111111 | conn_1 | false   | select * from sharding_4_t1            | length{(2)}                | schema1 |
      | test | 111111 | conn_1 | false   | delete from sharding_4_t1 where id = 1 | success                    | schema1 |
      | test | 111111 | conn_1 | false   | delete from sharding_4_t1 where id = 2 | Lock wait timeout exceeded | schema1 |
      | test | 111111 | conn_1 | false   | delete from sharding_4_t1 where id = 3 | success                    | schema1 |
      | test | 111111 | conn_1 | True    | delete from sharding_4_t1 where id = 4 | Lock wait timeout exceeded | schema1 |
    Then restart dble in "dble-1" failed for
    """
    Fail to recover xa when dble start, please check backend mysql
    """
    Given restart mysql in "mysql-master1"
    Then get resultset of cmd "xa recover" named "rs_A" in mysql "mysql-master1"
    Then execute cmd "xa commit" xid from "rs_A" in mysql "mysql-master1"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                         | expect      | db      |
      | test | 111111 | conn_1 | false   | select * from sharding_4_t1 | length{(2)} | schema1 |
      | test | 111111 | conn_1 | True    | delete from sharding_4_t1   | success     | schema1 |

  Scenario: mysql node network shock causing xa transaction perpare to fail and keep rolling back,but recovered during background attempts,check dble.log #4
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | test | 111111 | conn_0 | False   | create table sharding_4_t1(id int,name char)            | success | schema1 |
      | test | 111111 | conn_0 | False   | set autocommit=0                                        | success | schema1 |
      | test | 111111 | conn_0 | False   | set xa=on                                               | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given prepare a thread run btrace script "DelayBeforeXaPrepare.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Given sleep "3" seconds
    Given execute oscmd in "mysql-master1"
    """
    iptables -A INPUT -s 172.100.9.1 -j REJECT
    """
    Given destroy sql threads list
    Given execute oscmd in "mysql-master1"
    """
    iptables -D INPUT -s 172.100.9.1 -j REJECT
    """
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                         | expect      | db      |
      | test | 111111 | conn_1 | True    | select * from sharding_4_t1 | length{(0)} | schema1 |
