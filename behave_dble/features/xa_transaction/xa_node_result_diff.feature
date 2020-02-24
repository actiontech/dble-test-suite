# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/4

Feature: xa nodes have different result after execute transaction

  @skip_restart
  Scenario: xa prepare is abnormal, but some nodes successfully prepare. After dble restart, the successful preparation needs rolled back. #1
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
    Given prepare a thread run btrace script "DelayBeforeXaPrepare.java" in "dble-1"
    Given sleep "10" seconds
    Given prepare a thread execute sql "commit" with "conn_0"
    Given sleep "3" seconds
    Then check btrace "DelayBeforeXaPrepare.java" output in "dble-1" with "1" times
    """
    before xa prepare
    """
    Given Restart dble in "dble-1" success
    Given destroy sql threads list
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                     | expect      | db      |
      | test | 111111 | conn_1 | False   | select * from sharding_4_t1                             | length{(0)} | schema1 |
      | test | 111111 | conn_1 | False   | begin                                                   | success     | schema1 |
      | test | 111111 | conn_1 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success     | schema1 |
      | test | 111111 | conn_1 | True    | commit                                                  | success     | schema1 |
      | test | 111111 | new    | True    | select * from sharding_4_t1                             | length{(4)} | schema1 |
      | test | 111111 | new    | True    | delete from sharding_4_t1                               | success     | schema1 |

  @skip_restart
  Scenario: when xa start, some backend nodes execute successfully and some errors . dble give a reasonable error #2
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                            | expect  | db |
      | test | 111111 | conn_0 | False   | set global log_output=file                     | success |    |
      | test | 111111 | conn_0 | False   | set global general_log_file='/tmp/general.log' | success |    |
      | test | 111111 | conn_0 | False   | set global general_log=on                      | success |    |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                                            | expect  | db |
      | test | 111111 | conn_4 | False   | set global log_output=file                     | success |    |
      | test | 111111 | conn_4 | False   | set global general_log_file='/tmp/general.log' | success |    |
      | test | 111111 | conn_4 | False   | set global general_log=on                      | success |    |
    Given prepare a thread run btrace script "DelayBeforeXaStart.java" in "dble-1"
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql         | expect  | db      |
      | test | 111111 | conn_1 | False   | set xa = on | success | schema1 |
      | test | 111111 | conn_1 | False   | begin       | success | schema1 |
    Given prepare a thread execute sql "insert into schema1.sharding_4_t1 values(1,1),(2,2),(3,3),(4,4)" with "conn_1"
    Given sleep "3" seconds
    Then check btrace "DelayBeforeXaStart.java" output in "dble-1" with "1" times
    """
    before xa start
    """
    Given get resultset of oscmd in "dble-1" with pattern "Dble_Server.*db1" name "rs_A"
    """
    cat /opt/dble/DelayBeforeXaStart.java.log
    """
    Then execute sql "xa start" in "mysql-master1" with "rs_A" result
      | user | passwd | conn   | toClose | expect  | db |
      | test | 111111 | conn_2 | False   | success |    |
    Then execute sql "xa start" in "mysql-master2" with "rs_A" result
      | user | passwd | conn   | toClose | expect  | db |
      | test | 111111 | conn_3 | False   | success |    |
    Given destroy sql threads list
    Then check sql thread output in "err"
    """
    The XID already exists
    """
    Given stop btrace script "DelayBeforeXaStart.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                         | expect      | db      |
      | test | 111111 | conn_1 | False   | rollback                    | success     | schema1 |
      | test | 111111 | conn_1 | False   | select * from sharding_4_t1 | length{(0)} | schema1 |
    Given sleep "10" seconds
    Then get result of oscmd name "rs_B" in "mysql-master1"
    """
    grep -c -i 'rollback' /tmp/general.log
    """
    Then get result of oscmd name "rs_C" in "mysql-master1"
    """
    grep -c -i 'quit' /tmp/general.log
    """
    Then get result of oscmd name "rs_D" in "mysql-master2"
    """
    grep -c -i 'rollback' /tmp/general.log
    """
    Then get result of oscmd name "rs_E" in "mysql-master2"
    """
    grep -c -i 'quit' /tmp/general.log
    """
    Then check result "rs_B" value is "1"
    Then check result "rs_C" value is "1"
    Then check result "rs_D" value is "1"
    Then check result "rs_E" value is "1"
    Given execute oscmd in "mysql-master1"
    """
    rm -rf /tmp/general.log
    """
    Given execute oscmd in "mysql-master2"
    """
    rm -rf /tmp/general.log
    """
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                        | expect  | db |
      | test | 111111 | conn_0 | True    | set global general_log=off | success |    |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                        | expect  | db |
      | test | 111111 | conn_4 | True    | set global general_log=off | success |    |