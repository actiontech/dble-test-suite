# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2020/12/15

# for DBLE0REQ-189
Feature: test fakeMySQLVersion support mysql8.0
  @skip
  Scenario: check fakeMySQLVersion is 5.7 #1
# fakeMySQLVersion is 5.7.13, backend mysql version is 5.7.13, mysql client version is 5.7.13
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="fakeMySQLVersion">5.7.13</property>
    </system>
    """
    Then restart dble in "dble-1" success

    Given delete the following xml segment
      | file         | parent         | child                  |
      | schema.xml   | {'tag':'root'} | {'tag':'dataHost'}     |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group1" slaveThreshold="100" maxCon="1000" minCon="10" >
        <heartbeat>select user()</heartbeat>
        <writeHost name="hostM2" password="111111" url="172.100.9.6:3306" user="test">
        </writeHost>
    </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group1" database="db2" name="dn2" />
    <dataNode dataHost="ha_group1" database="db3" name="dn3" />
    <dataNode dataHost="ha_group1" database="db4" name="dn4" />
    <dataNode dataHost="ha_group1" database="db5" name="dn5" />
    """
    Then execute admin cmd "reload @@config_all"

    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                                                                           | expect  | db      |
    | conn_0 | False   | drop table if exists sharding_4_t1                                            | success | schema1 |
    | conn_0 | False   | create table sharding_4_t1(id int, name varchar(10))                          | success | schema1 |
    | conn_0 | False   | insert into sharding_4_t1(id, name) values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd') | success | schema1 |
    | conn_0 | False   | update sharding_4_t1 set name='aa' where id=1                                 | success | schema1 |
    | conn_0 | False   | select * from sharding_4_t1                                                   | success | schema1 |
    | conn_0 | True    | delete from sharding_4_t1                                                     | success | schema1 |

# fakeMySQLVersion is 5.7.13, backend mysql version is 5.7.13, mysql client version is 8.0.21
    Given connect "dble-1" with user "test" in "mysql8-master1" to execute sql
    """
    drop table if exists schema1.sharding_4_t1
    create table schema1.sharding_4_t1(id int,name varchar(10))
    insert into schema1.sharding_4_t1(id, name) values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd')
    update schema1.sharding_4_t1 set name='aa' where id=1
    select * from schema1.sharding_4_t1
    delete from schema1.sharding_4_t1
    """

# fakeMySQLVersion is 5.7.13, backend mysql version is 8.0.21, mysql client version is 5.7.13
    Given delete the following xml segment
      | file         | parent         | child                  |
      | schema.xml   | {'tag':'root'} | {'tag':'dataHost'}     |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group1" slaveThreshold="100" maxCon="1000" minCon="10" >
        <heartbeat>select user()</heartbeat>
        <writeHost name="hostM1" password="111111" url="172.100.9.9:3307" user="test">
        </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"

    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                                                                           | expect  | db      |
    | conn_1 | False   | drop table if exists sharding_4_t1                                            | success | schema1 |
    | conn_1 | False   | create table sharding_4_t1(id int, name varchar(10))                          | success | schema1 |
    | conn_1 | False   | insert into sharding_4_t1(id, name) values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd') | success | schema1 |
    | conn_1 | False   | update sharding_4_t1 set name='aa' where id=1                                 | success | schema1 |
    | conn_1 | False   | select * from sharding_4_t1                                                   | success | schema1 |
    | conn_1 | True    | delete from sharding_4_t1                                                     | success | schema1 |

# fakeMySQLVersion is 5.7.13, backend mysql version is 8.0.21, mysql client version is 8.0.21
    Given connect "dble-1" with user "test" in "mysql8-master1" to execute sql
    """
    drop table if exists schema1.sharding_4_t1
    create table schema1.sharding_4_t1(id int,name varchar(10))
    insert into schema1.sharding_4_t1(id, name) values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd')
    update schema1.sharding_4_t1 set name='aa' where id=1
    select * from schema1.sharding_4_t1
    delete from schema1.sharding_4_t1
    drop table if exists schema1.sharding_4_t1
    """

  @skip
  Scenario: check fakeMySQLVersion is 8.0 #2
# fakeMySQLVersion is 8.0.21, backend mysql version is 5.7.13
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="fakeMySQLVersion">8.0.21</property>
    </system>
    """
    Then restart dble in "dble-1" failed for
    """
    com.actiontech.dble.config.util.ConfigException: the dble version\[=8.0.21\] cannot be higher than the minimum version of the backend mysql node,pls check the backend mysql node.
    """

# fakeMySQLVersion is 8.0.21, backend mysql version is 5.7.13 and 8.0.21
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group1" slaveThreshold="100" maxCon="1000" minCon="10" >
        <heartbeat>select user()</heartbeat>
        <writeHost name="hostM1" password="111111" url="172.100.9.9:3307" user="test">
        </writeHost>
    </dataHost>
    """
    Then restart dble in "dble-1" failed for
    """
    com.actiontech.dble.config.util.ConfigException: the dble version\[=8.0.21\] cannot be higher than the minimum version of the backend mysql node,pls check the backend mysql node.
    """

# fakeMySQLVersion is 8.0.21, backend mysql version is 8.0.21, mysql client version is 5.7.13
    Given delete the following xml segment
      | file         | parent         | child              |
      | schema.xml   | {'tag':'root'} | {'tag':'dataHost'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group1" slaveThreshold="100" maxCon="1000" minCon="10" >
        <heartbeat>select user()</heartbeat>
        <writeHost name="hostM1" password="111111" url="172.100.9.9:3307" user="test">
        </writeHost>
    </dataHost>

    <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10" >
        <heartbeat>select user()</heartbeat>
        <writeHost name="hostM2" password="111111" url="172.100.9.10:3307" user="test">
        </writeHost>
    </dataHost>
    """
    Then restart dble in "dble-1" success

    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                                                                           | expect  | db      |
    | conn_0 | False   | drop table if exists sharding_4_t1                                            | success | schema1 |
    | conn_0 | False   | create table sharding_4_t1(id int, name varchar(10))                          | success | schema1 |
    | conn_0 | False   | insert into sharding_4_t1(id, name) values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd') | success | schema1 |
    | conn_0 | False   | update sharding_4_t1 set name='aa' where id=1                                 | success | schema1 |
    | conn_0 | False   | select * from sharding_4_t1                                                   | success | schema1 |
    | conn_0 | True    | delete from sharding_4_t1                                                     | success | schema1 |

# fakeMySQLVersion is 8.0.21, backend mysql version is 8.0.21, mysql client version is 8.0.21
    Given connect "dble-1" with user "test" in "mysql8-master1" to execute sql
    """
    drop table if exists schema1.sharding_4_t1
    create table schema1.sharding_4_t1(id int,name varchar(10))
    insert into schema1.sharding_4_t1(id, name) values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd')
    update schema1.sharding_4_t1 set name='aa' where id=1
    select * from schema1.sharding_4_t1
    delete from schema1.sharding_4_t1
    """

# fakeMySQLVersion is 8.0.15, backend mysql version is 8.0.21, mysql client version is 5.7.13
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="fakeMySQLVersion">8.0.15</property>
    </system>
    """
    Then restart dble in "dble-1" success

    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                                                                           | expect  | db      |
    | conn_1 | False   | drop table if exists sharding_4_t1                                            | success | schema1 |
    | conn_1 | False   | create table sharding_4_t1(id int, name varchar(10))                          | success | schema1 |
    | conn_1 | False   | insert into sharding_4_t1(id, name) values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd') | success | schema1 |
    | conn_1 | False   | update sharding_4_t1 set name='aa' where id=1                                 | success | schema1 |
    | conn_1 | False   | select * from sharding_4_t1                                                   | success | schema1 |
    | conn_1 | True    | delete from sharding_4_t1                                                     | success | schema1 |

# fakeMySQLVersion is 8.0.15, backend mysql version is 8.0.21, mysql client version is 8.0.21
    Given connect "dble-1" with user "test" in "mysql8-master1" to execute sql
    """
    drop table if exists schema1.sharding_4_t1
    create table schema1.sharding_4_t1(id int,name varchar(10))
    insert into schema1.sharding_4_t1(id, name) values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd')
    update schema1.sharding_4_t1 set name='aa' where id=1
    select * from schema1.sharding_4_t1
    delete from schema1.sharding_4_t1
    """

# fakeMySQLVersion is 8.0.15, backend mysql version is 5.7.13 and 8.0.21
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group1" slaveThreshold="100" maxCon="1000" minCon="10" >
        <heartbeat>select user()</heartbeat>
        <writeHost name="hostM1" password="111111" url="172.100.9.5:3306" user="test">
        </writeHost>
    </dataHost>
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                 | expect                                                                                                                                                              |
      | conn_2 | True    | reload @@config_all | Reload Failure.The reason is the dble version[=8.0.15] cannot be higher than the minimum version of the backend mysql node,pls check the backend mysql node. |
    Given delete the following xml segment
      | file        | parent         | child                                                 |
      | server.xm   | {'tag':'root'} | {'tag':'system','kv_map':{'name':'fakeMySQLVersion'}} |
    Then restart dble in "dble-1" success

