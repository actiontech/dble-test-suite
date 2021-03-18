# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/3/2  quexiuping at 2021/3/18

Feature: sql_statistic_by_frontend_by_backend_by_entry_by_user test

  Scenario: simple sql test #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
      <dbInstance name="hostS3" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false"/>
    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" />
    <rwSplitUser name="split2" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect    | db               |
      | conn_0 | False   | enable @@statistic                                                         | success   | dble_information |
      | conn_0 | False   | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user             | success   | dble_information |
      | conn_0 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{(0,)} | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      #dn1-tx/1/0, dn2-tx/1/0, dn3-tx/1/0, dn4-tx/1/0
      | conn_1 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      #dn1-tx/1/0, dn2-tx/1/0, dn3-tx/1/0, dn4-tx/1/0
      | conn_1 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      #dn1-insert/1/1-tx/1/1, dn2-insert/1/1-tx/1/1, dn3-insert/1/1-tx/1/1, dn4-insert/1/1-tx/1/1
      | conn_1 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      #dn3-insert/1/1-tx/1/1
      | conn_1 | False    | insert into sharding_4_t1 values(6,'name6')                                     | success | schema1 |
      #dn1-select/1/1-tx/1/1, dn2-select/1/1-tx/1/1, dn3-select/1/1-tx/1/1, dn4-select/1/1-tx/1/1
      | conn_1 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      #dn2-select/1/1-tx/1/1
      | conn_1 | False    | select * from sharding_4_t1 where id=1                                          | success | schema1 |
      #dn4-select/1/0-tx/1/0
      | conn_1 | False    | select * from sharding_4_t1 where id=15                                         | success | schema1 |
      #dn1-update/1/1-tx/1/1, dn2-update/1/1-tx/1/1, dn3-update/1/1-tx/1/1, dn4-update/1/1-tx/1/1
      | conn_1 | False    | update sharding_4_t1 set name='test_name'                                       | success | schema1 |
      #dn1-update/1/1-tx/1/1
      | conn_1 | False    | update sharding_4_t1 set name='dn1' where id=4                                  | success | schema1 |
      #dn2-update/1/0-tx/1/0
      | conn_1 | False    | update sharding_4_t1 set name='dn2' where id=9                                  | success | schema1 |
      #dn3-delete/1/1-tx/1/1
      | conn_1 | False    | delete from sharding_4_t1 where id=6                                            | success | schema1 |
      #dn4-delete/1/0-tx/1/0
      | conn_1 | False    | delete from sharding_4_t1 where id=11                                           | success | schema1 |
      #dn1-delete/1/1-tx/1/1, dn2-delete/1/1-tx/1/1, dn3-delete/1/1-tx/1/1, dn4-delete/1/1
      | conn_1 | True     | delete from sharding_4_t1                                                       | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               |
      | conn_1 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{(4,)}   | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resultset_11"
      | conn   | toClose | sql                                                                 | db               |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | dble_information |
    Then check resultset "resultset_11" has lines with following column values
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 8          | 5         | 1                   | 1                  | 2                   | 1                  | 1                   | 1                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 7          | 5         | 1                   | 1                  | 2                   | 2                  | 1                   | 1                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 8          | 4         | 1                   | 1                  | 1                   | 1                  | 2                   | 1                  | 2                   | 1                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 8          | 8         | 2                   | 2                  | 1                   | 2                  | 2                   | 2                  | 1                   | 2                  |

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose  | sql                                                      | expect  | db      |
      #dn5-tx/1/0
      | test1 | 111111 | conn_2 | False    | drop table if exists no_sharding_t1                      | success | schema1 |
      #dn5-tx/1/0
      | test1 | 111111 | conn_2 | False    | create table no_sharding_t1(id int, name varchar(20))    | success | schema1 |
      #dn5-insert/1/2-tx/1/2
      | test1 | 111111 | conn_2 | False    | insert into no_sharding_t1 values(1,'name1'),(2,'name2') | success | schema1 |
      #dn5-update/1/2-tx/1/2
      | test1 | 111111 | conn_2 | False    | update no_sharding_t1 set name='test_name'               | success | schema1 |
      #dn5-select/1/2-tx/1/2
      | test1 | 111111 | conn_2 | False    | select * from no_sharding_t1                             | success | schema1 |
      #dn5-delete/1/2-tx/1/2
      | test1 | 111111 | conn_2 | False    | delete from no_sharding_t1                               | success | schema1 |
      #dn1-tx/1/0, dn2-tx/1/0
      | test1 | 111111 | conn_2 | False    | drop table if exists sharding_2_t1                       | success | schema1 |
      #dn1-tx/1/0, dn2-tx/1/0
      | test1 | 111111 | conn_2 | False    | create table sharding_2_t1(id int, name varchar(20))     | success | schema1 |
      #dn1-insert/1/1-tx/1/1, dn2-insert/1/1-tx/1/1
      | test1 | 111111 | conn_2 | False    | insert into sharding_2_t1 values(1,'name1'),(2,'name2')  | success | schema1 |
      #dn1-select/1/1-tx/1/1, dn2-select/1/1-tx/1/1
      | test1 | 111111 | conn_2 | False    | select * from sharding_2_t1                              | success | schema1 |
      #dn1-update/1/1-tx/1/1, dn2-update/1/1-tx/1/1
      | test1 | 111111 | conn_2 | False    | update sharding_2_t1 set name='test_name'                | success | schema1 |
      #dn2-update/1/0-tx/1/0
      | test1 | 111111 | conn_2 | False    | update sharding_2_t1 set name='test_name' where id=5     | success | schema1 |
      #dn1-delete/1/0-tx/1/0
      | test1 | 111111 | conn_2 | False    | delete from sharding_2_t1 where id=4                     | success | schema1 |
      #dn1-tx/1/0, dn2-tx/1/0
      | test1 | 111111 | conn_2 | True     | truncate table sharding_2_t1                             | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               |
      | conn_1 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{(7,)}   | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resultset_12"
      | conn   | toClose | sql                                                                 | db               |
      | conn_0 | True    | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | dble_information |
    Then check resultset "resultset_12" has lines with following column values
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 8          | 5         | 1                   | 1                  | 2                   | 1                  | 1                   | 1                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 7          | 5         | 1                   | 1                  | 2                   | 2                  | 1                   | 1                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 8          | 4         | 1                   | 1                  | 1                   | 1                  | 2                   | 1                  | 2                   | 1                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 8          | 8         | 2                   | 2                  | 1                   | 2                  | 2                   | 2                  | 1                   | 2                  |
      | 3       | test1  | 172.100.9.6    | 3306           | dn2             | hostM2        | 7          | 3         | 1                   | 1                  | 2                   | 1                  | 0                   | 0                  | 1                   | 1                  |
      | 3       | test1  | 172.100.9.5    | 3306           | dn1             | hostM1        | 7          | 3         | 1                   | 1                  | 1                   | 1                  | 1                   | 0                  | 1                   | 1                  |
      | 3       | test1  | 172.100.9.5    | 3306           | dn5             | hostM1        | 6          | 8         | 1                   | 2                  | 1                   | 2                  | 1                   | 2                  | 1                   | 2                  |

    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                              | expect  | db  |
      #tx/1/0
      | split1 | 111111 | conn_2 | False   | drop table if exists test_table                  | success | db1 |
      #tx/1/0
      | split1 | 111111 | conn_2 | False   | create table test_table(id int,name varchar(20)) | success | db1 |
      #tx/1/1
      | split1 | 111111 | conn_2 | False   | show create table test_table                     | success | db1 |
      #tx/1/2
      | split1 | 111111 | conn_2 | False   | desc test_table                                  | success | db1 |
      #tx/1/2-insert/1/2
      | split1 | 111111 | conn_2 | False   | insert into test_table values (1,'1'),(2, '2')   | success | db1 |
      #tx/1/1-update/1/1
      | split1 | 111111 | conn_2 | False   | update test_table set name='name1' where id=1    | success | db1 |
      #tx/1/1-select/1/2
      | split1 | 111111 | conn_2 | False   | select * from test_table                         | success | db1 |
      #tx/1/1-delete/1/1
      | split1 | 111111 | conn_2 | False   | delete from test_table where id=2                | success | db1 |
      #tx/1/0
      | split1 | 111111 | conn_2 | False   | truncate test_table                              | success | db1 |
      #tx/1/1-select/1/1
      | split1 | 111111 | conn_2 | True    | select 1                                         | success | db1 |
      #tx/1/0
      | split2 | 111111 | conn_3 | False   | drop table if exists test_table                  | success | db2 |
      #tx/1/0
      | split2 | 111111 | conn_3 | False   | create table test_table(id int,name varchar(20)) | success | db2 |
      #tx/1/1
      | split2 | 111111 | conn_3 | False   | show create table test_table                     | success | db2 |
      #tx/1/2
      | split2 | 111111 | conn_3 | False   | desc test_table                                  | success | db2 |
      #tx/1/2-insert/1/2
      | split2 | 111111 | conn_3 | False   | insert into test_table values (1,'1'),(2, '2')   | success | db2 |
      #tx/1/1-update/1/1
      | split2 | 111111 | conn_3 | False   | update test_table set name='name1' where id=1    | success | db2 |
      #tx/1/2-select/1/2
      | split2 | 111111 | conn_3 | False   | select * from test_table                         | success | db2 |
      #tx/1/1-delete/1/1
      | split2 | 111111 | conn_3 | False   | delete from test_table where id=2                | success | db2 |
      #tx/1/1-select/1/1
      | split2 | 111111 | conn_3 | False   | truncate test_table                              | success | db2 |
      #tx/1/1-select/1/1
      | split2 | 111111 | conn_3 | True    | select 1                                         | success | db2 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect    | db               |
      | conn_0 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{(9,)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resultset_13"
      | conn   | toClose | sql                                                                 | db               |
      | conn_0 | True    | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | dble_information |
    Then check resultset "resultset_13" has lines with following column values
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 8          | 5         | 1                   | 1                  | 2                   | 1                  | 1                   | 1                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 7          | 5         | 1                   | 1                  | 2                   | 2                  | 1                   | 1                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 8          | 4         | 1                   | 1                  | 1                   | 1                  | 2                   | 1                  | 2                   | 1                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 8          | 8         | 2                   | 2                  | 1                   | 2                  | 2                   | 2                  | 1                   | 2                  |
      | 3       | test1  | 172.100.9.6    | 3306           | dn2             | hostM2        | 7          | 3         | 1                   | 1                  | 2                   | 1                  | 0                   | 0                  | 1                   | 1                  |
      | 3       | test1  | 172.100.9.5    | 3306           | dn1             | hostM1        | 7          | 3         | 1                   | 1                  | 1                   | 1                  | 1                   | 0                  | 1                   | 1                  |
      | 3       | test1  | 172.100.9.5    | 3306           | dn5             | hostM1        | 6          | 8         | 1                   | 2                  | 1                   | 2                  | 1                   | 2                  | 1                   | 2                  |
      | 4       | split1 | 172.100.9.10   | 3306           | -               | hostM3        | 10         | 10        | 1                   | 2                  | 1                   | 1                  | 1                   | 1                  | 2                   | 3                  |
      | 5       | split2 | 172.100.9.10   | 3306           | -               | hostM3        | 10         | 10        | 1                   | 2                  | 1                   | 1                  | 1                   | 1                  | 2                   | 3                  |

  Scenario: complex sql test #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
      <dbInstance name="hostS3" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false"/>
    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" />
    <rwSplitUser name="split2" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | insert into sharding_2_t1 values(1,'name1'),(2,'name2')                         | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                              | expect  | db  |
      | split1 | 111111 | conn_2 | False   | drop table if exists test_table                  | success | db1 |
      | split1 | 111111 | conn_2 | False   | create table test_table(id int,name varchar(20)) | success | db1 |
      | split1 | 111111 | conn_2 | False   | insert into test_table values (1,'1'),(2, '2')   | success | db1 |
      | split2 | 111111 | conn_3 | False   | drop table if exists test_table                  | success | db2 |
      | split2 | 111111 | conn_3 | False   | create table test_table(id int,name varchar(20)) | success | db2 |
      | split2 | 111111 | conn_3 | False   | insert into test_table values (1,'1'),(2, '2')   | success | db2 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                            | expect  | db               |
      | conn_1 | False   | enable @@statistic                                             | success | dble_information |
      | conn_1 | False   | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user | success | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                       | expect  | db      |
      #dn1-select/2/2-tx/2/2, dn2-select/2/2-tx/2/2, dn3-select/2/2-tx/2/2, dn4-select/2/2-tx/2/2
      | conn_0 | False    | select t1.*,t2.* from sharding_4_t1 t1, sharding_4_t1 t2 where t1.id=t2.id order by t1.id | success | schema1 |
      #dn1-select/2/2-tx/2/2, dn2-select/2/2-tx/2/2, dn3-select/2/2-tx/2/2, dn4-select/2/2-tx/2/2
      | conn_0 | False    | select t1.*, t2.* from sharding_4_t1 t1 join sharding_4_t1 t2 on t1.id=t2.id              | success | schema1 |
      #dn1-select/2/2-tx/2/2, dn2-select/2/2-tx/2/2, dn3-select/1/1-tx/1/1, dn4-select/1/1-tx/1/1
      | conn_0 | False    | select t1.*, t2.* from sharding_4_t1 t1 join sharding_2_t1 t2 on t1.id=t2.id              | success | schema1 |
      #dn1-select/1/0-tx/1/0, dn2-select/2/2-tx/2/2, dn3-select/1/0-tx/1/0, dn4-select/1/0-tx/1/0
      | conn_0 | False    | select * from sharding_2_t1 where id = (select id from sharding_4_t1 where name='name1')  | success | schema1 |
      #dn1-insert/1/1-tx/1/1, dn2-insert/1/1-tx/1/1, dn3-insert/1/1-tx/1/1, dn4-insert/1/1-tx/1/1
      | conn_0 | False    | insert into sharding_4_t1(id, name) select id,name from sharding_4_t1                     | success | schema1 |
      #dn1-select/1/1-tx/1/1, dn2-select/1/1-tx/1/1, dn3-select/1/1-tx/1/1, dn4-select/1/1-tx/1/1
      | conn_0 | False    | select count(*) from sharding_4_t1 where id > 2                                           | success | schema1 |
      #dn1-select/1/1-tx/1/1, dn2-select/1/1-tx/1/1
      | conn_0 | False    | select max(id) from sharding_2_t1                                                         | success | schema1 |
       #dn1-delete/2/2-tx/1/2, dn2-delete/2/2-tx/1/2, dn3-delete/2/2-tx/1/2, dn4-delete/2/2-tx/1/2
      | conn_0 | False    | delete from sharding_4_t1                                                                 | success | schema1 |
      #dn1-delete/1/1-tx/1/1, dn2-delete/1/1-tx/1/1
      | conn_0 | True     | delete from sharding_2_t1                                                                 | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               |
      | conn_1 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{(4,)}   | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resultset_21"
      | conn   | toClose | sql                                                                 | db               |
      | conn_1 | True    | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | dble_information |
    Then check resultset "resultset_21" has lines with following column values
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 13         | 14        | 1                   | 1                  | 0                   | 0                  | 2                   | 3                  | 10                  | 10                 |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 12         | 12        | 1                   | 1                  | 0                   | 0                  | 2                   | 3                  | 9                   | 8                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 9          | 9         | 1                   | 1                  | 0                   | 0                  | 1                   | 2                  | 7                   | 6                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 9          | 9         | 1                   | 1                  | 0                   | 0                  | 1                   | 2                  | 7                   | 6                  |

  Scenario: sharding user hint sql test #3
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_0 | False    | insert into sharding_2_t1 values(1,'name1'),(2,'name2')                         | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                            | expect  | db               |
      | conn_1 | False   | enable @@statistic                                             | success | dble_information |
      | conn_1 | False   | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user | success | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                       | expect  | db      |
      | conn_0 | False    | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1                                    | success | schema1 |
      | conn_0 | False    | /*!dble:shardingNode=dn1*/ insert into sharding_4_t1 values(666, 'name666')               | success | schema1 |
      | conn_0 | False    | /*!dble:shardingNode=dn1*/ update sharding_4_t1 set name = 'dn1' where id=666             | success | schema1 |
      | conn_0 | True     | /*!dble:shardingNode=dn1*/ delete from sharding_4_t1 where id=666                         | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               |
      | conn_1 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{(1,)}   | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resultset_31"
      | conn   | toClose | sql                                                                 | db               |
      | conn_1 | True    | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | dble_information |
    Then check resultset "resultset_31" has lines with following column values
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 4          | 4         | 1                   | 1                  | 1                   | 1                  | 1                   | 1                  | 1                   | 1                  |

  Scenario: transaction sql test #4
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_0 | False    | insert into sharding_2_t1 values(1,'name1'),(2,'name2')                         | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                            | expect  | db               |
      | conn_1 | False   | enable @@statistic                                             | success | dble_information |
      | conn_1 | False   | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user | success | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      #dn1-select/1/1-tx/1/1, dn2-select/1/1-tx/1/2-insert/1/1, dn3-select/1/1-tx/1/1, dn4-select/1/1-tx/1/1
      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(5,'name5')                                     | success | schema1 |
      | conn_0 | False    | commit                                                                          | success | schema1 |
      #dn2-update/1/1-tx/1/2-delete/1/1, dn1-update/1/0-tx/1/0
      | conn_0 | False    | start transaction                                                               | success | schema1 |
      | conn_0 | False    | update sharding_4_t1 set name='dn2' where id=1                                  | success | schema1 |
      | conn_0 | False    | delete from sharding_4_t1 where id=5                                            | success | schema1 |
      | conn_0 | False    | update sharding_4_t1 set name='dn1' where id=100                                | success | schema1 |
      | conn_0 | True     | commit                                                                          | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      #dn2-insert/1/1-tx/1/1, dn3-insert/1/1-tx/1/2-delete/1/1
      | conn_2 | False    | begin                                                                           | success | schema1 |
      | conn_2 | False    | insert into sharding_4_t1 values(5,'name5'),(6,'name6')                         | success | schema1 |
      | conn_2 | False    | delete from sharding_4_t1 where id=6                                            | success | schema1 |
      | conn_2 | False    | rollback                                                                        | success | schema1 |
      #dn1-update/1/0-tx/1/1, dn3-select/1/1-tx/1/1, dn4-update/1/1-tx/1/1
      | conn_2 | False    | start transaction                                                               | success | schema1 |
      | conn_2 | False    | select * from sharding_4_t1 where id=2                                          | success | schema1 |
      | conn_2 | False    | update sharding_4_t1 set name='dn4' where id=3                                  | success | schema1 |
      | conn_2 | False    | update sharding_4_t1 set name='dn1' where id=100                                | success | schema1 |
      | conn_2 | False    | rollback                                                                        | success | schema1 |
      #dn1-delete/1/1-tx/1/1, dn2-delete/1/1-tx/1/1
      | conn_2 | False    | start transaction                                                               | success | schema1 |
      | conn_2 | False    | delete from sharding_2_t1                                                       | success | schema1 |
      #dn1-delete/1/1-tx/1/1, dn2-delete/1/1-tx/1/1, dn3-delete/1/1-tx/1/1, dn4-delete/1/1-tx/1/1
      | conn_2 | False    | begin                                                                           | success | schema1 |
      | conn_2 | True     | delete from sharding_4_t1                                                       | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_3 | False    | set autocommit=0                                                                | success | schema1 |
      #dn1-update/1/1-tx/1/2-select/1/1, dn2-update/1/1-tx/1/2-select/1/1, dn3-update/1/1-tx/1/2-select/1/1, dn4-update/1/1-tx/1/2-select/1/1
      | conn_3 | False    | update sharding_4_t1 set name='test_name'                                       | success | schema1 |
      | conn_3 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_3 | False    | commit                                                                          | success | schema1 |
      #dn1-delete/1/1-tx/1/2-insert/1/1, dn4-delete/1/1-tx/1/2-insert/1/1
      | conn_3 | False    | delete from sharding_4_t1 where id in (3, 4)                                    | success | schema1 |
      | conn_3 | False    | insert into sharding_4_t1 values(3,'name3'),(4,'name4')                         | success | schema1 |
      | conn_3 | False    | rollback                                                                        | success | schema1 |
      #dn1-delete/1/1-tx/1/1, dn2-delete/1/1-tx/1/1, dn3-delete/1/1-tx/1/1, dn4-delete/1/1-tx/1/1
      | conn_3 | True     | delete from sharding_4_t1                                                       | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               |
      | conn_1 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{(4,)}   | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resultset_41"
      | conn   | toClose | sql                                                                 | db               |
      | conn_1 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | dble_information |
    Then check resultset "resultset_41" has lines with following column values
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 7          | 10        | 2                   | 2                  | 2                   | 2                  | 4                   | 4                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 8          | 8         | 1                   | 1                  | 3                   | 1                  | 4                   | 4                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 6          | 8         | 1                   | 1                  | 2                   | 2                  | 3                   | 3                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 6          | 8         | 1                   | 1                  | 1                   | 1                  | 3                   | 3                  | 3                   | 3                  |


  Scenario: xa transaction sql test #5
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                            | expect  | db               |
      | conn_1 | False   | enable @@statistic                                             | success | dble_information |
      | conn_1 | False   | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user | success | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | set autocommit=0                                                                | success | schema1 |
      | conn_0 | False    | set xa=on                                                                       | success | schema1 |
      #dn1-select/1/1-tx/1/1, dn2-select/1/1-tx/1/2-update/1/1, dn3-select/1/1-tx/1/1, dn4-select/1/1-tx/1/1
      | conn_0 | False    | update sharding_4_t1 set name='dn2' where id=1                                  | success | schema1 |
      | conn_0 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_0 | False    | commit                                                                          | success | schema1 |
      #dn2-insert/1/1-tx/1/1, dn1-delete/1/1-tx/1/1
      | conn_0 | False    | insert into sharding_4_t1 values(5,'name5')                                     | success | schema1 |
      | conn_0 | False    | delete from sharding_4_t1 where id=4                                            | success | schema1 |
      | conn_0 | False    | rollback                                                                        | success | schema1 |
      #dn1-delete/1/1-tx/1/1, dn2-delete/1/1-tx/1/1, dn3-delete/1/1-tx/1/1, dn4-delete/1/1-tx/1/1
      | conn_0 | True    | delete from sharding_4_t1                                                        | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               |
      | conn_1 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{(4,)}   | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resultset_51"
      | conn   | toClose | sql                                                                 | db               |
      | conn_1 | True    | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | dble_information |
    Then check resultset "resultset_51" has lines with following column values
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 3          | 4         | 1                   | 1                  | 1                   | 1                  | 1                   | 1                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 3          | 3         | 0                   | 0                  | 0                   | 0                  | 2                   | 2                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 2          | 2         | 0                   | 0                  | 0                   | 0                  | 1                   | 1                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 2          | 2         | 0                   | 0                  | 0                   | 0                  | 1                   | 1                  | 1                   | 1                  |

  Scenario: implict commit test #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_0 | False    | drop table if exists sharding_4_t2                                              | success | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                            | expect  | db               |
      | conn_1 | False   | enable @@statistic                                             | success | dble_information |
      | conn_1 | False   | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user | success | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      #dn1-insert/1/1-tx/1/1, dn2-insert/1/1-tx/1/1, dn3-insert/1/1-tx/1/1, dn4-insert/1/1-tx/1/1
      | conn_0 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_0 | False    | create table sharding_4_t2(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      #dn1-insert/1/1-tx/1/1, dn2-insert/1/1-tx/1/1, dn3-insert/1/1-tx/1/1, dn4-insert/1/1-tx/1/1
      | conn_0 | False    | insert into sharding_4_t2 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_0 | False    | create index index_name1 on sharding_4_t1 (name)                                | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      #dn1-update/1/1-tx/1/1, dn2-tx/1/0, dn3-tx/1/0, dn4-tx/1/0
      | conn_0 | False    | update sharding_4_t1 set name='dn1' where id=4                                  | success | schema1 |
      | conn_0 | False    | drop index index_name1 on sharding_4_t1                                         | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      #dn1-select/1/1-tx/1/1, dn2-select/1/1-tx/1/1, dn3-select/1/1-tx/1/1, dn4-select/1/1-tx/1/1
      | conn_0 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
       #dn4-update/1/1-tx/1/1
      | conn_0 | False    | update sharding_4_t1 set name='dn4' where id=3                                  | success | schema1 |
      | conn_0 | False    | start transaction                                                               | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | set autocommit=0                                                                | success | schema1 |
      #dn1-select/1/1-tx/1/1, dn2-select/1/1-tx/1/1, dn3-select/1/1-tx/1/1, dn4-select/1/1-tx/1/1
      | conn_0 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_0 | False    | set autocommit=1                                                                | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      #dn1-tx/1/0, dn2-delete/1/1-tx/1/1, dn3-tx/1/0, dn4-tx/1/0
      | conn_0 | False    | delete from sharding_4_t1 where id=1                                            | success | schema1 |
      | conn_0 | False    | truncate table sharding_4_t2                                                    | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      #dn1-tx/1/0, dn2-tx/1/0, dn3-delete/1/1-tx/1/0, dn4-tx/1/0
      | conn_0 | False    | delete from sharding_4_t1 where id=2                                            | success | schema1 |
      | conn_0 | False    | drop table sharding_4_t2                                                        | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               |
      | conn_1 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{(4,)}   | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resultset_61"
      | conn   | toClose | sql                                                                 | db               |
      | conn_1 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | dble_information |
    Then check resultset "resultset_61" has lines with following column values
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 7          | 5         | 2                   | 2                  | 0                   | 0                  | 1                   | 1                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 7          | 5         | 2                   | 2                  | 1                   | 1                  | 0                   | 0                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 8          | 5         | 2                   | 2                  | 1                   | 1                  | 0                   | 0                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 7          | 5         | 2                   | 2                  | 0                   | 0                  | 1                   | 1                  | 2                   | 2                  |
