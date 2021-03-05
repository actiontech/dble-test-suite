# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  processlist test


 Scenario:  processlist  table #1
  #case desc processlist
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "processlist_1"
      | conn   | toClose | sql              | db               |
      | conn_0 | False   | desc processlist | dble_information |
    Then check resultset "processlist_1" has lines with following column values
      | Field-0       | Type-1        | Null-2 | Key-3 | Default-4 | Extra-5 |
      | front_id      | int(11)       | NO     | PRI   | None      |         |
      | db_instance   | varchar(12)   | NO     |       | None      |         |
      | mysql_id      | int(11)       | NO     | PRI   | None      |         |
      | user          | varchar(12)   | NO     |       | None      |         |
      | front_host    | varchar(16)   | NO     |       | None      |         |
      | mysql_db      | varchar(16)   | NO     |       | None      |         |
      | command       | varchar(1024) | YES    |       | None      |         |
      | time          | int(11)       | YES    |       | None      |         |
      | state         | varchar(64)   | YES    |       | None      |         |
      | info          | varchar(64)   | YES    |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                          | expect            | db               |
      | conn_0 | False   | desc processlist             | length{(10)}      | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1               | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1 (id int)              | success | schema1 |
      | conn_1 | False   | begin                                            | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values (1),(2),(3),(4) | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "processlist_3"
      | conn   | toClose | sql                                                                             | db               |
      | conn_0 | true    | select db_instance,user,mysql_db,command,state,info from processlist            | dble_information |
    Then check resultset "processlist_3" has lines with following column values
      | db_instance-0   | user-1 | mysql_db-2 | command-3 | state-4 | info-5 |
      | hostM1          | test   | db2        | Sleep     |         | None   |
      | hostM1          | test   | db1        | Sleep     |         | None   |
      | hostM2          | test   | db2        | Sleep     |         | None   |
      | hostM2          | test   | db1        | Sleep     |         | None   |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | commit                                           | success |
      | conn_1 | False   | drop table if exists test                        | success |
      | conn_1 | False   | create table test (id int)                       | success |
      | conn_1 | False   | begin                                            | success |
      | conn_1 | False   | insert into test values (1),(2),(3),(4)          | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "processlist_4"
      | conn   | toClose | sql                                                                           | db               |
      | conn_0 | False   | select db_instance,user,mysql_db,command,state,info from processlist          | dble_information |
    Then check resultset "processlist_4" has lines with following column values
      | db_instance-0   | user-1 | mysql_db-2 | command-3 | state-4 | info-5 |
      | hostM1          | test   | db2        | Sleep     |         | None   |
      | hostM1          | test   | db1        | Sleep     |         | None   |
      | hostM2          | test   | db2        | Sleep     |         | None   |
      | hostM2          | test   | db1        | Sleep     |         | None   |

  #case supported select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                    | expect                       |
      | conn_0 | False   | select user from processlist limit 1                                   | has{(('test',),)}            |
      | conn_0 | False   | select user,command from processlist order by mysql_db desc limit 1    | has{(('test', 'Sleep'),)}    |
      | conn_0 | False   | select * from processlist where db_instance like '%host%'              | length{(4)}                  |
  #case supported select max/min from
      | conn_0 | False   | select max(db_instance) from processlist                  | has{(('hostM2',),)}       |
      | conn_0 | False   | select min(command) from processlist                      | has{(('Sleep',),)}        |
  #case supported select field from
      | conn_0 | False   | select user,db_instance from processlist where time > 0         | success |
  #case unsupported update/delete/insert
      | conn_0 | False   | delete from processlist where front_id = 3                  | Access denied for table 'processlist'  |
      | conn_0 | False   | update processlist set mysql_id = 1 where mysql_id is null  | Access denied for table 'processlist'  |
      | conn_0 | True    | insert into processlist values ('1','2', 3, 4.5)            | Access denied for table 'processlist'  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | commit                                           | success |
      | conn_1 | False   | drop table if exists test                        | success |
      | conn_1 | True    | drop table if exists sharding_4_t1               | success |


    Given delete the following xml segment
      | file         | parent         | child                  |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group1" maxCon="0"/>
    """
    Then execute admin cmd "reload @@config"
    Then execute admin cmd "select * from dble_information.processlist"

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_1 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_1 | False   | create table test_table(id int)               | success | db1 |
      | rwS1 | 111111 | conn_1 | False   | begin                                         | success | db1 |
      | rwS1 | 111111 | conn_1 | False   | insert into test_table values (1),(2),(3),(4) | success | db1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "processlist_5"
      | conn   | toClose | sql                                                                           | db               |
      | conn_0 | True    | select db_instance,user,mysql_db,command,state,info from processlist          | dble_information |
    Then check resultset "processlist_5" has lines with following column values
      | db_instance-0   | user-1 | mysql_db-2 | command-3 | state-4 | info-5 |
      | hostM1          | rwS1   | db1        | Sleep     |         | None   |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_1 | False   | commit                                        | success | db1 |
      | rwS1 | 111111 | conn_1 | True    | drop table if exists test_table                | success | db1 |
