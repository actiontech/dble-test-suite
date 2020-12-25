# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2020/12/15

# for DBLE0REQ-189
Feature: test fakeMySQLVersion support mysql8.0

  Scenario: check fakeMySQLVersion is 5.7 #1
# fakeMySQLVersion is 5.7.13, backend mysql version is 5.7.13, mysql client version is 5.7.13
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=5.7.13
    """
    Then restart dble in "dble-1" success

    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn3" />
    <shardingNode dbGroup="ha_group1" database="db4" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db5" name="dn5" />
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
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.9:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
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

  Scenario: check fakeMySQLVersion is 8.0 #2
# fakeMySQLVersion is 8.0.21, backend mysql version is 8.0.21, mysql client version is 5.7.13
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=8.0.21
    """
    Then restart dble in "dble-1" success

    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.9:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn3" />
    <shardingNode dbGroup="ha_group1" database="db4" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db5" name="dn5" />
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
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=8.0.15
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

# fakeMySQLVersion is 8.0.15, backend mysql version is 5.7.13, mysql client version is 5.7.13
     Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"

    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                                                                           | expect  | db      |
    | conn_2 | False   | drop table if exists sharding_4_t1                                            | success | schema1 |
    | conn_2 | False   | create table sharding_4_t1(id int, name varchar(10))                          | success | schema1 |
    | conn_2 | False   | insert into sharding_4_t1(id, name) values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd') | success | schema1 |
    | conn_2 | False   | update sharding_4_t1 set name='aa' where id=1                                 | success | schema1 |
    | conn_2 | False   | select * from sharding_4_t1                                                   | success | schema1 |
    | conn_2 | True    | delete from sharding_4_t1                                                     | success | schema1 |

# fakeMySQLVersion is 8.0.15, backend mysql version is 5.7.13, mysql client version is 8.0.21
    Given connect "dble-1" with user "test" in "mysql8-master1" to execute sql
    """
    drop table if exists schema1.sharding_4_t1
    create table schema1.sharding_4_t1(id int,name varchar(10))
    insert into schema1.sharding_4_t1(id, name) values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd')
    update schema1.sharding_4_t1 set name='aa' where id=1
    select * from schema1.sharding_4_t1
    delete from schema1.sharding_4_t1
    """

# fakeMySQLVersion is 8.0.21, backend mysql version is 5.7.13, mysql client version is 5.7.13
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=8.0.21
    """
    Then restart dble in "dble-1" success

    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                                                                           | expect  | db      |
    | conn_3 | False   | drop table if exists sharding_4_t1                                            | success | schema1 |
    | conn_3 | False   | create table sharding_4_t1(id int, name varchar(10))                          | success | schema1 |
    | conn_3 | False   | insert into sharding_4_t1(id, name) values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd') | success | schema1 |
    | conn_3 | False   | update sharding_4_t1 set name='aa' where id=1                                 | success | schema1 |
    | conn_3 | False   | select * from sharding_4_t1                                                   | success | schema1 |
    | conn_3 | True    | delete from sharding_4_t1                                                     | success | schema1 |

# fakeMySQLVersion is 8.0.21, backend mysql version is 5.7.13, mysql client version is 8.0.21
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
