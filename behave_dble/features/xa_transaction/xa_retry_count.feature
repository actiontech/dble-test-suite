# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/3

Feature: change xaRetryCount value and check result

  @skip_restart
  Scenario: Setting xaRetryCount to an illegal value, dble report warning #1
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
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="xaRetryCount">-1</property>
    """
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql    | expect                                                                          | db |
      | root | 111111 | conn_0 | True    | dryrun | hasStr{Property [ xaRetryCount ] '-1' in server.xml is illegal, use 0 replaced} |    |
    Then check "dble.log" in "dble-1" has the warnings
      | TYPE-0 | LEVEL-1 | DETAIL-2                                                                |
      | Xml    | WARNING | Property [ xaRetryCount ] '-1' in server.xml is illegal, use 0 replaced |

  @skip_restart
  Scenario: xaRetryCount value to 3 , dble report 3 warnings, recovery node by manual, check data not lost #2
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="xaRetryCount">3</property>
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
    Given stop mysql in host "mysql-master1"
    Given destroy sql threads list
    Given stop btrace script "BtraceXaDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given sleep "10" seconds
    Then get result of oscmd name "rs_A" in "dble-1"
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Then check result "rs_A" value is "3"
    Given start mysql in host "mysql-master1"
    Given Restart dble in "dble-1" success
    Given sleep "3" seconds
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                  | expect  | db      |
      | test | 111111 | conn_1 | False   | select * from sharding_4_t1          | success | schema1 |
      | test | 111111 | conn_1 | False   | delete from sharding_4_t1 where id=1 | success | schema1 |
      | test | 111111 | conn_1 | False   | delete from sharding_4_t1 where id=2 | success | schema1 |
      | test | 111111 | conn_1 | False   | delete from sharding_4_t1 where id=3 | success | schema1 |
      | test | 111111 | conn_1 | True    | delete from sharding_4_t1 where id=4 | success | schema1 |

  @skip_restart
  Scenario: when xa attempts does not reach the specified value, start mysql node and check data not lost #3
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect  | db      |
      | test | 111111 | conn_0 | False   | set autocommit=0                                        | success | schema1 |
      | test | 111111 | conn_0 | False   | set xa=on                                               | success | schema1 |
      | test | 111111 | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Given prepare a thread run btrace script "BeforeAddXaToQueue.java" in "dble-1"
    Given sleep "3" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Given sleep "3" seconds
    Given stop mysql in host "mysql-master1"
    Given destroy sql threads list
    Then check btrace "BeforeAddXaToQueue.java" output in "dble-1" with "1" times
    """
    before add xa
    """
    Given start mysql in host "mysql-master1"
    Given stop btrace script "BeforeAddXaToQueue.java" in "dble-1"
    Given destroy btrace threads list
    Given sleep "10" seconds
    Then get result of oscmd name "rs_B" in "dble-1"
    """
    cat /opt/dble/logs/dble.log |grep "time in background" |wc -l
    """
    Then check result "rs_B" value less than "3"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                  | expect  | db      |
      | test | 111111 | conn_1 | False   | select * from sharding_4_t1          | success | schema1 |
      | test | 111111 | conn_1 | False   | delete from sharding_4_t1 where id=1 | success | schema1 |
      | test | 111111 | conn_1 | False   | delete from sharding_4_t1 where id=2 | success | schema1 |
      | test | 111111 | conn_1 | False   | delete from sharding_4_t1 where id=3 | success | schema1 |
      | test | 111111 | conn_1 | True    | delete from sharding_4_t1 where id=4 | success | schema1 |