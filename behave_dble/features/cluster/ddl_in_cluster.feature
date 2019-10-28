# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2019/10/16

Feature:check ddl related functionality work fine
  @btrace
  Scenario: can see ddl in all dbles in cluster if ddl happen in one dble #1
    Given stop dble cluster and zk service
    Given delete the following xml segment
      | file       | parent         | child            |
      | schema.xml | {'tag':'root'} | {'tag':'schema'} |
      | server.xml | {'tag':'root'} | {'tag':'user'}   |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" dataNode="dn5">
        <table name="test" dataNode="dn3,dn4" type="global"/>
      </schema>
      <schema name="schema2" sqlMaxLimit="100" dataNode="dn1">
        <table name="test" dataNode="dn1,dn2" type="global"/>
      </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
      <user name="test">
         <property name="password">111111</property>
         <property name="schemas">schema1,schema2</property>
      </user>
      <user name="root">
         <property name="password">111111</property>
         <property name="manager">true</property>
      </user>
   """
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order
    #Then Start dble in "dble-1"

    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql         | expect                               | db |
      | root | 111111 | conn_0 | True    | show @@help | hasStr{show @@ddl}                   |    |
      | root | 111111 | conn_0 | True    | show @@help | hasStr{kill @@ddl_lock where schema} |    |
    Given prepare a thread run btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | user | passwd | conn   | toClose | sql                       | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test | schema1 |
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose | sql        | expect                              | db |
      | root | 111111 | conn_0 | True    | show @@ddl | hasStr{'drop table if exists test'} |    |
    Then execute admin cmd  in "dble-2" at background
      | user | passwd | conn   | toClose | sql        | expect                              | db |
      | root | 111111 | conn_0 | True    | show @@DDL | hasStr{'drop table if exists test'} |    |
    Given sleep "60" seconds
    Then execute admin cmd  in "dble-2" at background
      | user | passwd | conn   | toClose | sql        | expect    | db |
      | root | 111111 | conn_0 | True    | show @@ddl | Empty set |    |
    Given execute sqls in "dble-1" at background
      | user | passwd | conn   | toClose | sql                       | db      |
      | test | 111111 | conn_0 | True    | create table test(id int) | schema1 |
      | test | 111111 | conn_0 | True    | create table test(id int) | schema2 |
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose | sql        | expect                                                                                             | db |
      | root | 111111 | conn_0 | True    | show @@ddl | has{('schema1','test','create table test(id int)'),('schema2','test','create table test(id int)')} |    |
    Then execute admin cmd  in "dble-2" at background
      | user | passwd | conn   | toClose | sql        | expect                                                                                             | db |
      | root | 111111 | conn_0 | True    | show @@ddl | has{('schema1','test','create table test(id int)'),('schema2','test','create table test(id int)')} |    |
    Given sleep "60" seconds
    Then execute admin cmd  in "dble-2" at background
      | user | passwd | conn   | toClose | sql        | expect    | db |
      | root | 111111 | conn_0 | True    | show @@ddl | Empty set |    |
    Given execute sqls in "dble-1" at background
      | user | passwd | conn   | toClose | sql                        | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test2 | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test1 | schema1 |
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose | sql        | expect                                                                                                 | db |
      | root | 111111 | conn_0 | True    | show @@ddl | has{('schema1','test2','drop table if exists test2'),('schema1','test1','drop table if exists test1')} |    |
    Then execute admin cmd  in "dble-2" at background
      | user | passwd | conn   | toClose | sql        | expect                                                                                                 | db |
      | root | 111111 | conn_0 | True    | show @@ddl | has{('schema1','test2','drop table if exists test2'),('schema1','test1','drop table if exists test1')} |    |
    Given sleep "60" seconds
    Then execute admin cmd  in "dble-2" at background
      | user | passwd | conn   | toClose | sql        | expect    | db |
      | root | 111111 | conn_0 | True    | show @@ddl | Empty set |    |
    Given stop btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given destroy btrace threads list
  
  @btrace
  Scenario: check 'kill @@ddl_lock where schema=? and table=?' work fine #2
    Given stop dble cluster and zk service
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}   |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
      | schema.xml | {'tag':'root'} | {'tag':'dataHost'} |
      | server.xml | {'tag':'root'} | {'tag':'user'}   |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" dataNode="dn1">
        <table name="test" dataNode="dn1,dn2" type="global"/>
    </schema>

    <schema name="schema2" sqlMaxLimit="100" dataNode="dn4">
        <table name="test" dataNode="dn3,dn4" type="global"/>
    </schema>

    <dataNode name="dn1" dataHost="172.100.9.5" database="db1"/>
    <dataNode name="dn2" dataHost="172.100.9.5" database="db2"/>
    <dataNode name="dn3" dataHost="172.100.9.5" database="db3"/>
    <dataNode name="dn4" dataHost="172.100.9.5" database="db4"/>
    <dataHost balance="0" maxCon="5" minCon="4" name="172.100.9.5" switchType="1" slaveThreshold="100">
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM1" url="172.100.9.5:3306" password="111111" user="test"/>
    </dataHost>

    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
      <user name="test">
         <property name="password">111111</property>
         <property name="schemas">schema1,schema2</property>
      </user>
      <user name="root">
         <property name="password">111111</property>
         <property name="manager">true</property>
      </user>
   """
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order
    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql         | expect                               | db |
      | root | 111111 | conn_0 | True    | show @@help | hasStr{show @@ddl}                   |    |
      | root | 111111 | conn_0 | True    | show @@help | hasStr{kill @@ddl_lock where schema} |    |
    Given prepare a thread run btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given execute sqls in "dble-1" at background
      | user | passwd | conn   | toClose | sql                       | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test | schema2 |
    Then execute admin cmd  in "dble-2" at background
      | user | passwd | conn   | toClose | sql                                                | expect                                     | db |
      | root | 111111 | conn_0 | False   | show @@ddl                                         | hasStr{'drop table if exists test'}        |    |
      | root | 111111 | conn_0 | True    | kill @@ddl_lock where schema=schema2 and table=test | hasStr{'ddl lock is removed successfully'} |    |
    Then execute admin cmd  in "dble-1" at background
      | user | passwd | conn   | toClose | sql                                                | expect                                     | db |
      | root | 111111 | conn_0 | False   | kill @@ddl_lock where schema=schema2 and table=test | hasStr{'ddl lock is removed successfully'} |    |
      | root | 111111 | conn_0 | True    | reload @@metadata                                  | success                                    |    |
    Then execute admin cmd  in "dble-2" at background
      | user | passwd | conn   | toClose | sql                       | expect      | db |
      | root | 111111 | conn_0 | True    | show @@backend.statistics | length{(5)} |    |
    Given stop btrace script "BtraceDelayAfterDdl.java" in "dble-1"
    Given destroy btrace threads list
    Given sleep "60" seconds
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                            | expect  | db      |
      | test | 111111 | conn_0 | False   | create table test(id int)      | success | schema2 |
      | test | 111111 | conn_0 | False   | insert into test values(1),(2) | success | schema2 |
      | test | 111111 | conn_0 | False   | begin                          | success | schema2 |
      | test | 111111 | conn_0 | False   | select * from test             | success | schema2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                | expect | db |
      | test | 111111 | conn_1 | False   | begin              | success | schema2 |
      | test | 111111 | conn_1 | False   | select * from test | success | schema2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                | expect | db |
      | test | 111111 | conn_2 | False   | begin              | success | schema2 |
      | test | 111111 | conn_2 | False   | select * from test | success | schema2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                    | expect | db |
      | test | 111111 | conn_3 | False   | begin                  | success | schema2 |
      | test | 111111 | conn_3 | False   | select * from test   | success | schema2 |
      | test | 111111 | conn_3 | True    | commit                 | success | schema2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                  | expect | db |
      | test | 111111 | conn_2 | True   | commit              | success | schema2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                  | expect | db |
      | test | 111111 | conn_1 | True   | commit              | success | schema2 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                  | expect | db |
      | test | 111111 | conn_0 | True   | commit              | success | schema2 |