# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: test slow query log related manager command

  @NORMAL
  Scenario:test "enable @@slow_query_log"，"disable @@slow_query_log"，"show @@slow_query_log" #1
      Then execute sql in "dble-1" in "admin" mode
        | user  | passwd    | conn   | toClose | sql                     | expect       | db  |
        | root  | 111111    | conn_0 | False   | enable @@slow_query_log | success      |     |
        | root  | 111111    | conn_0 | False   | show @@slow_query_log   | has{('1',)}  |     |
        | root  | 111111    | conn_0 | False   | disable @@slow_query_log| success      |     |
        | root  | 111111    | conn_0 | True    | show @@slow_query_log   | has{('0',)}  |     |

  @NORMAL
  Scenario: test "show @@slow_query.time", "reload @@slow_query.time", "show @@slow_query.flushperid", "reload @@slow_query.flushperid", "show @@slow_query.flushsize", "reload @@slow_query.flushsize" #2
      Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
      """
      <system>
           <property name="enableSlowLog">1 </property>
            <property name="sqlSlowTime">30 </property>
            <property name="flushSlowLogPeriod">1000 </property>
           <property name="flushSlowLogSize">5 </property>
      </system>
      """
       Given Restart dble in "dble-1" success
       Then execute sql in "dble-1" in "admin" mode
        | user   | passwd  | conn   | toClose | sql                            | expect        | db |
        | root   | 111111  | conn_0 | False   | show @@slow_query.time         | has{('30',)}  |    |
        | root   | 111111  | conn_0 | False   | reload @@slow_query.time = 200 | success       |    |
        | root   | 111111  | conn_0 | False   | show @@slow_query.time         | has{('200',)} |    |

        | root   | 111111  | conn_0 | False   | show @@slow_query.flushperiod         | has{('1000',)} |    |
        | root   | 111111  | conn_0 | False   | reload @@slow_query.flushperiod = 200 | success        |    |
        | root   | 111111  | conn_0 | False   | show @@slow_query.flushperiod         | has{('200',)}  |    |

        | root   | 111111  | conn_0 | False   | show @@slow_query.flushsize           | has{('5',)}    |    |
        | root   | 111111  | conn_0 | False   | reload @@slow_query.flushsize = 50    | success        |    |
        | root   | 111111  | conn_0 | True    | show @@slow_query.flushsize           | has{('50',)}   |    |

  @NORMAL
  Scenario: check slow query log written in assigned file #3
      Given delete file "/opt/dble/slowQuery" on "dble-1"
      Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
      """
       <system>
            <property name="enableSlowLog">1</property>
            <property name="slowLogBaseDir">./slowQuery</property>
            <property name="slowLogBaseName">query</property>
            <property name="sqlSlowTime">1</property>
       </system>
     """
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn2,dn3,dn4" name="a_test" rule="hash-four" />
        </schema>
     """
      Given Restart dble in "dble-1" success
      Then check following " " exist in dir "/opt/dble/" in "dble-1"
      """
      slowQuery
      query.log
      """
      Then execute sql in "dble-1" in "admin" mode
        | user         | passwd    | conn   | toClose  | sql                            | expect   | db   |
        | root         | 111111    | conn_0 | True     | disable @@slow_query_log       | success  |      |
      Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose  | sql                             | expect    | db     |
        | test         | 111111    | conn_0 | False    | drop table if exists a_test     |  success  | schema1 |
        | test         | 111111    | conn_0 | False    | create table a_test(id int)     |  success  | schema1 |
        | test         | 111111    | conn_0 | False    | alter table a_test add age int  |  success  | schema1 |
        | test         | 111111    | conn_0 | False    | insert into a_test values(1,20) |  success  | schema1 |
        | test         | 111111    | conn_0 | False    | select id from a_test           |  success  | schema1 |
        | test         | 111111    | conn_0 | False    | select count(id) from a_test    |  success  | schema1 |
        | test         | 111111    | conn_0 | True     | delete from a_test              |  success  | schema1 |

      Then check following "not" exist in file "/opt/dble/slowQuery/query.log" in "dble-1"
      """
      drop table if exists a_test
      create table a_test(id int)
      alter table a_test add name char(20)
      insert into a_test values(1,20)
      select id from a_test
      select count(id) from a_test
      delete from a_test
      """
      Then execute sql in "dble-1" in "admin" mode
        | user         | passwd    | conn   | toClose | sql                     | expect  | db     |
        | root         | 111111    | conn_0 | True    | enable @@slow_query_log |  success|        |
      Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose  | sql                             | expect  | db     |
        | test         | 111111    | conn_0 | False    | drop table if exists a_test     | success |  schema1|
        | test         | 111111    | conn_0 | False    | create table a_test(id int)     | success |  schema1|
        | test         | 111111    | conn_0 | False    | alter table a_test add age int  | success |  schema1|
        | test         | 111111    | conn_0 | False    | insert into a_test values(1,20) | success |  schema1|
        | test         | 111111    | conn_0 | False    | select id from a_test           | success |  schema1|
        | test         | 111111    | conn_0 | False    | select count(id) from a_test    | success |  schema1|
        | test         | 111111    | conn_0 | True     | delete from a_test              | success |  schema1|
      Then check following " " exist in file "/opt/dble/slowQuery/query.log" in "dble-1"
      """
      drop table if exists a_test
      create table a_test(id int)
      alter table a_test add age int
      insert into a_test values(1,20)
      select id from a_test
      select count(id) from a_test
      delete from a_test
      """
     Then execute sql in "dble-1" in "admin" mode
        | user         | passwd    | conn   | toClose | sql                     | expect  | db     |
        | root         | 111111    | conn_0 | True    | enable @@slow_query_log |  success|        |
     Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose  | sql                                                             | expect                           | db     |
        | test         | 111111    | conn_0 | False    | drop table if exists a_test                                     |  success                         | schema1 |
        | test         | 111111    | conn_0 | False    | create table a_test(id int(10) unsigned NOT NULL,name char(1))  |  success                         | schema1 |
        | test         | 111111    | conn_0 | False    | insert into a_test values(1,1),(2,1111)                         |  Data too long for column 'name' | schema1 |
        | test         | 111111    | conn_0 | False    | insert into a_test values(3,3)                                  |  success                         | schema1 |
     Then check following " " exist in file "/opt/dble/slowQuery/query.log" in "dble-1"
     """
     drop table if exists a_test
     create table a_test(id int(10) unsigned NOT NULL,name char(1))
     insert into a_test values(3,3)
     """
     Then check following "not" exist in file "/opt/dble/slowQuery/query.log" in "dble-1"
     """
     insert into a_test values(1,1),(2,1111)
     """