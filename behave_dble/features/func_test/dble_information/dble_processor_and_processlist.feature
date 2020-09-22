# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_processor test
   Scenario:  dble_processor table #1
  #case desc dble_processor
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_processor_1"
      | conn   | toClose | sql                 | db               |
      | conn_0 | False   | desc dble_processor | dble_information |
    Then check resultset "dble_processor_1" has lines with following column values
      | Field-0      | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name         | varchar(64) | NO     | PRI   | None      |         |
      | type         | varchar(7)  | NO     |       | None      |         |
      | conn_count   | int(11)     | NO     |       | None      |         |
      | conn_net_in  | int(11)     | NO     |       | None      |         |
      | conn_net_out | int(11)     | NO     |       | None      |         |
  #case select * from dble_processor
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_processor_2"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select * from dble_processor | dble_information |
    Then check resultset "dble_processor_2" has lines with following column values
      | name-0            | type-1  |
      | frontProcessor0   | session |
      | backendProcessor0 | backend |
      | backendProcessor1 | backend |
      | backendProcessor2 | backend |
      | backendProcessor3 | backend |
      | backendProcessor4 | backend |
      | backendProcessor5 | backend |
      | backendProcessor6 | backend |
      | backendProcessor7 | backend |
  #case change bootstrap.cnf
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
     $a  -DbackendProcessors=4
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_processor_3"
      | conn   | toClose | sql                                  | db               |
      | conn_1 | false   | select name,type from dble_processor | dble_information |
    Then check resultset "dble_processor_3" has lines with following column values
      | name-0            | type-1  |
      | frontProcessor0   | session |
      | backendProcessor0 | backend |
      | backendProcessor1 | backend |
      | backendProcessor2 | backend |
      | backendProcessor3 | backend |
    Then check resultset "dble_processor_3" has not lines with following column values
      | name-0            | type-1  |
      | backendProcessor4 | backend |
      | backendProcessor5 | backend |
      | backendProcessor6 | backend |
      | backendProcessor7 | backend |

   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                               | expect                                                                     |
      | conn_1 | False   | use dble_information                                              | success                                                                    |
      | conn_1 | False   | select name,type from dble_processor limit 1                      | has{(('frontProcessor0', 'session'),)}                                     |
      | conn_1 | False   | select name,type from dble_processor order by name desc limit 2   | has{(('frontProcessor0', 'session'), ('backendProcessor3', 'backend'))}    |
      | conn_1 | False   | select * from dble_processor where name like '%or%'               | length{(5)}                                                                |
  #case select max/min from
      | conn_1 | False   | select max(name) from dble_processor                      | has{(('frontProcessor0',),)}           |
      | conn_1 | False   | select min(name) from dble_processor                      | has{(('backendProcessor0',),)}         |
  #case where [sub-query]
      | conn_1 | False   | select name from dble_processor where type in (select type from dble_processor where conn_count>0) | length{(5)}    |
   #case select field from
      | conn_1 | False   | select name from dble_processor where conn_net_out > 0         | length{(5)}  |
  #case update/delete
      | conn_1 | False   | delete from dble_processor where name = 'frontProcessor0'            | Access denied for table 'dble_processor'  |
      | conn_1 | False   | update dble_processor set name = '2' where name = 'frontProcessor0'  | Access denied for table 'dble_processor'  |
      | conn_1 | False   | insert into dble_processor values ('1','2', 3, 4.5)                  | Access denied for table 'dble_processor'  |

@skip

@skip_restart
     Scenario:  processlist  table #2
  #case desc processlist
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "processlist_1"
      | conn   | toClose | sql              | db               |
      | conn_0 | False   | desc processlist | dble_information |
    Then check resultset "processlist_1" has lines with following column values
      | Field-0       | Type-1        | Null-2 | Key-3 | Default-4 | Extra-5 |
      | front_id      | int(11)       | NO     |       | None      |         |
      | sharding_node | varchar(12)   | NO     |       | None      |         |
      | db_instance   | varchar(12)   | NO     |       | None      |         |
      | mysql_id      | int(11)       | NO     |       | None      |         |
      | user          | varchar(12)   | NO     |       | None      |         |
      | front_host    | varchar(16)   | NO     |       | None      |         |
      | mysql_db      | varchar(16)   | NO     |       | None      |         |
      | command       | varchar(1024) | YES    |       | None      |         |
      | time          | int(11)       | YES    |       | None      |         |
      | state         | varchar(64)   | YES    |       | None      |         |
      | info          | varchar(64)   | YES    |       | None      |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "processlist_2"
      | conn   | toClose | sql                       | db               |
      | conn_0 | true    | select * from processlist | dble_information |
    Then check resultset "processlist_2" has lines with following column values
| sharding_node-1 | db_instance-2 | mysql_id-3 | user-4 | mysql_db-6 | command-7 | time-8 | state-9 | info-10 |
| None          | None        |     None | root | None     | None    | None | None  | None |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | use schema1                                      | success |
      | conn_1 | False   | drop table if exists sharding_4_t1               | success |
      | conn_1 | False   | create table sharding_4_t1 (id int)              | success |
      | conn_1 | False   | set autocommit=0                                 | success |
      | conn_1 | False   | set xa=on                                        | success |
      | conn_1 | False   | insert into sharding_2_t1 values (1),(2),(3),(4) | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "processlist_3"
      | conn   | toClose | sql                                                                                                      | db               |
      | conn_0 | true    | select front_id,sharding_node,mysql_id,user,front_host,mysql_db,command,time,state,info from processlist | dble_information |
    Then check resultset "processlist_3" has lines with following column values
| sharding_node-1 | mysql_id-3 | user-4  | mysql_db-6 | command-7 | time-8 | state-9 | info-10 |



    Given execute single sql in "dble-1" in "admin" mode and save resultset in "processlist_4"
      | conn   | toClose | sql                   | db               |
      | conn_0 | true    | show @@processlist    | dble_information |
    Then check resultset "processlist_4" has lines with following column values
| shardingNode-1 | MysqlId-2 | User-3 |  db-5   | Command-6 | Time-7 | State-8 | Info-9 |


    Then check resultsets "processlist_3" and "processlist_4" are same in following columns
      | column         | column_index |
      | front_id       | 0            |
      | shardingNode   | 1            |
      | mysql_id       | 2            |
      | user           | 3            |
      | front_host     | 4            |
      | command        | 5            |
      | time           | 6            |
      | state          | 7            |
      | info           | 8            |


    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  |
      | conn_1 | False   | set autocommit=1                                 | success |
      | conn_1 | False   | set xa=off                                       | success |
      | conn_1 | False   | drop table if exists test                        | success |
      | conn_1 | False   | create table test (id int)                       | success |
      | conn_1 | False   | set autocommit=0                                 | success |
      | conn_1 | False   | set xa=on                                        | success |
      | conn_1 | False   | insert into test values (1),(2),(3),(4)          | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "processlist_5"
      | conn   | toClose | sql                                                                                                      | db               |
      | conn_0 | true    | select front_id,sharding_node,mysql_id,user,front_host,mysql_db,command,time,state,info from processlist | dble_information |
    Then check resultset "processlist_5" has lines with following column values
| sharding_node-1 | mysql_id-3 | user-4 | mysql_db-6 | command-7 | time-8 | state-9 | info-10 |



    Given execute single sql in "dble-1" in "admin" mode and save resultset in "processlist_6"
      | conn   | toClose | sql                   | db               |
      | conn_0 | true    | show @@processlist    | dble_information |
    Then check resultset "processlist_6" has lines with following column values
| shardingNode-1 | MysqlId-2 | User-3 |  db-5   | Command-6 | Time-7 | State-8 | Info-9 |


    Then check resultsets "processlist_5" and "processlist_6" are same in following columns
      | column         | column_index |
      | front_id       | 0            |
      | shardingNode   | 1            |
      | mysql_id       | 2            |
      | user           | 3            |
      | front_host     | 4            |
      | command        | 5            |
      | time           | 6            |
      | state          | 7            |
      | info           | 8            |




   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                               | expect                                                                     |
      | conn_1 | False   | use dble_information                                              | success                                                                    |
      | conn_1 | False   | select name,type from processlist limit 1                      | has{(('frontProcessor0', 'session'),)}                                     |
      | conn_1 | False   | select name,type from processlist order by name desc limit 2   | has{(('frontProcessor0', 'session'), ('backendProcessor3', 'backend'))}    |
      | conn_1 | False   | select * from processlist where name like '%or%'               | length{(5)}                                                                |
  #case select max/min from
      | conn_1 | False   | select max(name) from processlist                      | has{(('frontProcessor0',),)}           |
      | conn_1 | False   | select min(name) from processlist                      | has{(('backendProcessor0',),)}         |
  #case where [sub-query]
      | conn_1 | False   | select shardingNode,user from processlist where type in (select type from dble_processor where conn_count>0) | length{(5)}    |
   #case select field from
      | conn_1 | False   | select user,shardingNode from processlist where time > 0         | length{(5)}  |
  #case update/delete
      | conn_1 | False   | delete from processlist where front_id = 3                  | Access denied for table 'processlist'  |
      | conn_1 | False   | update processlist set mysql_id = 1 where mysql_id is null  | Access denied for table 'processlist'  |
      | conn_1 | False   | insert into processlist values ('1','2', 3, 4.5)            | Access denied for table 'processlist'  |

