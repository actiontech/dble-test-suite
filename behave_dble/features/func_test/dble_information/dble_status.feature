# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_status test and check questions/transactions DBLE0REQ-67, DBLE0REQ-982

   Scenario:  dble_status table #1
  #case desc dble_status
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_1"
      | conn   | toClose | sql                 | db               |
      | conn_0 | False   | desc dble_status    | dble_information |
   Then check resultset "dble_status_1" has lines with following column values
      | Field-0        | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |
      | variable_name  | varchar(24)  | NO     | PRI   | None      |         |
      | variable_value | varchar(20)  | NO     |       | None      |         |
      | comment        | varchar(200) | YES    |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                          | expect            | db               |
      | conn_0 | False   | desc dble_status             | length{(3)}       | dble_information |
      | conn_0 | False   | select * from dble_status    | length{(12)}      | dble_information |
   #case select * from dble_status
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_2"
      | conn   | toClose | sql                       | db                |
      | conn_0 | False   | select * from dble_status | dble_information  |
   Then check resultset "dble_status_2" has lines with following column values
      | variable_name-0         | comment-2                                                                                                          |
      | uptime                  | Length of time to start dble                                                                                       |
      | current_timestamp       | The current time of the dble system                                                                                |
      | startup_timestamp       | Dble system startup time                                                                                           |
      | config_reload_timestamp | Last config load time                                                                                              |
      | heap_memory_max         | The maximum amount of memory that the virtual machine will attempt to use, measured in bytes                       |
      | heap_memory_used        | Heap memory usage, measured in bytes                                                                               |
      | heap_memory_total       | The total of heap memory, measured in bytes                                                                        |
      | direct_memory_max       | Max direct memory, measured in bytes                                                                               |
      | direct_memory_pool_size | Size of the memory pool, is equal to the product of BufferPoolPagesize and BufferPoolPagenumber, measured in bytes |
      | direct_memory_pool_used | DirectMemory memory in the memory pool that has been used, measured in bytes                                       |
      | questions               | Number of requests                                                                                                 |
      | transactions            | Number of transactions                                                                                             |
# compare with show @@time.startup
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_3"
      | conn   | toClose | sql                                                                             | db                |
      | conn_0 | False   | select variable_value from dble_status where variable_name ='startup_timestamp' | dble_information  |
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_4"
      | conn   | toClose | sql                    | db               |
      | conn_0 | False   | show @@time.startup    | dble_information |
   Then check resultsets "dble_status_3" and "dble_status_4" are same in following columns
      | column          | column_index |
      | variable_value  | 0            |

   #case supported select  table limit/order by/where like
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect                                                                 |
      | conn_0 | False   | use dble_information                                                                   | success                                                                |
      | conn_0 | False   | select * from dble_status limit 5                                                      | length{(5)}                                                            |
      | conn_0 | False   | select * from dble_status order by variable_name desc limit 6                          | length{(6)}                                                            |
      | conn_0 | False   | select * from dble_status where comment in (select common from dble_status )           | Correlated Sub Queries is not supported                                |
      | conn_0 | False   | select * from dble_status where comment > any (select variable_name from dble_status ) | length{(12)}                                                           |
      | conn_0 | False   | select * from dble_status where comment like '%of%'                                    | length{(7)}                                                            |
      | conn_0 | False   | select comment from dble_status                                                        | length{(12)}                                                           |
  #case supported select max/min from table
      | conn_0 | False   | select max(variable_name) from dble_status                                             | has{('uptime')}                                                        |
      | conn_0 | False   | select min(variable_name) from dble_status                                             | has{('config_reload_timestamp')}                                       |
  #case supported select field from table
      | conn_0 | False   | select variable_name from dble_status where variable_value = '0'                       | has{(('questions',), ('transactions',))}                               |
  #case unsupported update/delete/insert
      | conn_0 | False   | delete from dble_status where variable_name='questions'                                | Access denied for table 'dble_status'   |
      | conn_0 | False   | update dble_status set comment='number of requests' where variable_value='0'           | Access denied for table 'dble_status'   |
      | conn_0 | True    | insert into dble_status values ('a','b','c')                                           | Access denied for table 'dble_status'   |

   Scenario: check questions/transactions - shardingUser #2
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      |
      | conn_1 | False   | use schema1                                              |
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect                                             | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '1',), ('transactions', '1',))} | dble_information |
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      |
      | conn_1 | False   | drop table if exists test                                |
      | conn_1 | False   | create table test(id int,code int)                       |
  #case query correct sql questions and transactions add 2
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '3',), ('transactions', '3',))}      |
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      |
      | conn_1 | False   | insert into test values (1,1),(2,2)                      |
      | conn_1 | False   | update test set code=3 where code=2                      |
      | conn_1 | False   | delete from test where code=3                            |
      | conn_1 | False   | select * from test                                       |
  #case query correct sql questions and transactions add 4
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '7',), ('transactions', '7',))}      |
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      |
      | conn_1 | False   | set autocommit=0                                         |
      | conn_1 | False   | set xa=on                                                |
#case query sql in xa not commit, questions add 2 but transactions donot add
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '9',), ('transactions', '7',))}      |
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      |
      | conn_1 | False   | insert into test values (2,2),(3,3)                      |
      | conn_1 | False   | insert into test values (4,4),(5,5)                      |
#case query sql in xa not commit, questions add 2 but transactions donot add
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '11',), ('transactions', '7',))}     |
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      |
      | conn_1 | False   | commit                                                   |
#case in xa query commit, questions and transactions add 1
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '12',), ('transactions', '8',))}    |
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      |
      | conn_1 | False   | delete from test where code>4                            |
      | conn_1 | False   | insert into test values (5,5)                            |
      | conn_1 | False   | update test set code=5 where id > 3                      |
      | conn_1 | False   | select * from test where code=5                          |
#case in xa query delete, questions add 4 and transactions  donot add
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '16',), ('transactions', '8',))}     |
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      |
      | conn_1 | False   | rollback                                                 |
 #case in xa query rollback, questions and transactions add 1
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                 |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '17',), ('transactions', '9',))}    |

   Then execute admin cmd "reload @@config"
  #case query reload in admin mode ,questions and transactions not change
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                 |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '17',), ('transactions', '9',))}    |
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      |
      | conn_1 | False   | set autocommit=1                                         |
      | conn_1 | False   | set xa=off                                               |
  #case quit xa query "set autocommit=1"  ,questions add 2 ,but transactions add 2
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '19',), ('transactions', '11',))}    |
   Given prepare a thread execute sql "exit" with "conn_1"
  #case query exit, questions and transactions add 1
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '20',), ('transactions', '12',))}    |
  #case query in different seesion,questions and transactions add 1
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                   |
      | conn_2 | True    | use schema1           |
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '21',), ('transactions', '13',))}    |
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                |
      | conn_1 | False   | insert into test values (60,60); update test set code=50 where id>3; select * from test where code=50; delete from test where id=4 |
      # multiple sql, questions add 4 and transactions add 4
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                               |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '25',), ('transactions', '17',))} |
   #case compare with show @@questions
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_5"
      | conn   | toClose | sql              | db                |
      | conn_0 | True    | show @@questions | dble_information  |
   Then check resultset "dble_status_5" has lines with following column values
      | Questions-0 | Transactions-1 |
      | 25          | 17             |
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                               |
      | conn_1 | True    | drop table if exists test         |

   Scenario: check questions/transactions in transaction - shardingUser #3
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                      |
     | conn_1 | False   | use schema1                                              |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '1',), ('transactions', '1',))} | dble_information |
   # questions + 5, transactions + 4
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                |
     | conn_1 | False   | drop table if exists test                          |
     | conn_1 | False   | create table test(id int,code int)                 |
     | conn_1 | False   | begin                                              |
     | conn_1 | False   | begin                                              |
     | conn_1 | False   | commit                                             |
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '6',), ('transactions', '5',))} | dble_information |
   # questions + 6, transactions + 4
      Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                |
     | conn_1 | False   | set autocommit=0                                   |
     | conn_1 | False   | begin                                              |
     | conn_1 | False   | begin                                              |
     | conn_1 | False   | insert into test values (1,1),(2,2)                |
     | conn_1 | False   | commit                                             |
     | conn_1 | False   | set autocommit=1                                   |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '12',), ('transactions', '9',))} | dble_information |
   # questions + 5, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                |
     | conn_1 | False   | set autocommit=0                                   |
     | conn_1 | False   | insert into test values (3,3)                      |
     | conn_1 | False   | begin                                              |
     | conn_1 | False   | select * from test                                 |
     | conn_1 | False   | set autocommit=1                                   |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '17',), ('transactions', '11',))} | dble_information |
   # questions + 4, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                |
     | conn_1 | False   | begin                                              |
     | conn_1 | False   | set autocommit=0                                   |
     | conn_1 | False   | update test set code=22 where id=2                 |
     | conn_1 | False   | set autocommit=1                                   |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '21',), ('transactions', '12',))} | dble_information |
   # questions + 6, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                |
     | conn_1 | False   | begin                                              |
     | conn_1 | False   | set autocommit=0                                   |
     | conn_1 | False   | delete from test where id=2                        |
     | conn_1 | False   | commit                                             |
     | conn_1 | False   | update test set code=33 where id=3                 |
     | conn_1 | False   | set autocommit=1                                   |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '27',), ('transactions', '14',))} | dble_information |
   # questions + 5, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                |
     | conn_1 | False   | begin                                              |
     | conn_1 | False   | insert into test values (2,2)                      |
     | conn_1 | False   | set autocommit=1                                   |
     | conn_1 | False   | select * from test                                 |
     | conn_1 | False   | commit                                             |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '32',), ('transactions', '15',))} | dble_information |
   # questions + 4, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                |
     | conn_1 | False   | begin                                              |
     | conn_1 | False   | set autocommit=1                                   |
     | conn_1 | False   | select * from test                                 |
     | conn_1 | False   | commit                                             |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '36',), ('transactions', '16',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                |
     | conn_1 | False   | begin                                              |
     | conn_1 | False   | delete from test where id=3                        |
     | conn_1 | False   | rollback                                           |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '39',), ('transactions', '17',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                |
     | conn_1 | False   | begin                                              |
     | conn_1 | False   | select * from test                                 |
     | conn_1 | False   | commit                                             |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '42',), ('transactions', '18',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                |
     | conn_1 | False   | begin                                              |
     | conn_1 | False   | select * from test                                 |
     | conn_1 | False   | create table IF NOT EXISTS sharding_4_t1 (id int)  |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '45',), ('transactions', '19',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                   |
     | conn_1 | False   | begin                                                 |
     | conn_1 | False   | select * from test                                    |
     | conn_1 | False   | alter table sharding_4_t1 add column name varchar(10) |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '48',), ('transactions', '20',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                   |
     | conn_1 | False   | begin                                                 |
     | conn_1 | False   | select * from test                                    |
     | conn_1 | False   | truncate table sharding_4_t1                          |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '51',), ('transactions', '21',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                   |
     | conn_1 | False   | begin                                                 |
     | conn_1 | False   | select * from test                                    |
     | conn_1 | False   | drop table IF EXISTS sharding_4_t1                    |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '54',), ('transactions', '22',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                   |
     | conn_1 | False   | begin                                                 |
     | conn_1 | False   | select * from test                                    |
     | conn_1 | False   | create index id_index on test(id)                     |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '57',), ('transactions', '23',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                   |
     | conn_1 | False   | begin                                                 |
     | conn_1 | False   | select * from test                                    |
     | conn_1 | False   | drop index id_index on test                           |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '60',), ('transactions', '24',))} | dble_information |
   # questions + 3, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                   |
     | conn_1 | False   | set autocommit=0                                      |
     | conn_1 | False   | create table IF NOT EXISTS sharding_4_t1 (id int)     |
     | conn_1 | False   | set autocommit=1                                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '63',), ('transactions', '26',))} | dble_information |
   # questions + 3, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                   |
     | conn_1 | False   | set autocommit=0                                      |
     | conn_1 | False   | alter table sharding_4_t1 add column name varchar(10) |
     | conn_1 | False   | set autocommit=1                                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '66',), ('transactions', '28',))} | dble_information |
   # questions + 4, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                   |
     | conn_1 | False   | set autocommit=0                                      |
     | conn_1 | False   | truncate table sharding_4_t1                          |
     | conn_1 | False   | set autocommit=0                                      |
     | conn_1 | False   | set autocommit=1                                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '70',), ('transactions', '30',))} | dble_information |
   # questions + 3, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                   |
     | conn_1 | False   | set autocommit=0                                      |
     | conn_1 | False   | drop table IF EXISTS sharding_4_t1                    |
     | conn_1 | False   | set autocommit=1                                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '73',), ('transactions', '32',))} | dble_information |
   # questions + 3, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                   |
     | conn_1 | False   | set autocommit=0                                      |
     | conn_1 | False   | create index id_index on test(id)                     |
     | conn_1 | False   | set autocommit=1                                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '76',), ('transactions', '34',))} | dble_information |
   # questions + 3, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                   |
     | conn_1 | False   | set autocommit=0                                      |
     | conn_1 | False   | drop index id_index on test                           |
     | conn_1 | False   | set autocommit=1                                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '79',), ('transactions', '36',))} | dble_information |
   # in transaction query and close connection, questions + 2, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                   |
     | conn_1 | False   | begin                                                 |
     | conn_1 | True    | select * from test                                    |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                       | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '81',), ('transactions', '37',))} | dble_information |
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                                                                                                                 |
     # questions add 1 and transactions add 1
     | conn_2 | False   | use schema1                                                                                                                                         |
     # multiple sql, questions add 6 and transactions add 1
     | conn_2 | False   | begin; delete from test where code>4; insert into test values (50,50); update test set code=55 where id>3; select * from test where code=55; commit |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                       | expect                                               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '88',), ('transactions', '39',))} |
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                      |
     | conn_2 | False   | set autocommit=0; begin; begin; rollback |
     # multiple sql, questions add 4 and transactions add 3
     Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                       | expect                                               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '92',), ('transactions', '42',))} |
   # compare with show @@questions
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_6"
     | conn   | toClose | sql              | db                |
     | conn_0 | True    | show @@questions | dble_information  |
   Then check resultset "dble_status_6" has lines with following column values
     | Questions-0 | Transactions-1 |
     | 92          | 42             |
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                       | db      |
      | conn_2 | True    | drop table if exists test | schema1 |

   Scenario: check questions/transactions error sql - shardingUser #4
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                       |
     | conn_1 | False   | use schema1               |
     | conn_1 | False   | drop table if exists test |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '2',), ('transactions', '2',))} | dble_information |
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                      | expect                                                     |
     | conn_1 | False   | set autocommit=2                         | java.sql.SQLSyntaxErrorException: illegal value[2]         |
   Given prepare a thread execute sql "drop table if exist test" with "conn_1"
   # TODO transactions + 1? transactions + 2?
   # 1064 error, questions + 2, transactions + 1
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '4',), ('transactions', '3',))}      |
   # other error, questions + 2, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                      | expect                                                     |
     | conn_1 | False   | delete from test                         | Table meta 'schema1.test' is lost,PLEASE reload @@metadata |
     | conn_1 | False   | create index id_index on no_sharding(id) | Table 'db3.no_sharding' doesn't exist                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '6',), ('transactions', '5',))} | dble_information |
   # 1064 error in transaction, questions + 2, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                              |
     | conn_1 | False   | begin                            |
   Given prepare a thread execute sql "drop table if exist test" with "conn_1"
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '8',), ('transactions', '5',))} | dble_information |
   # other error, questions + 4, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                      | expect                                                     |
     | conn_1 | False   | rollback                                 | success                                                    |
     | conn_1 | False   | begin                                    | success                                                    |
     | conn_1 | False   | delete from test                         | Table meta 'schema1.test' is lost,PLEASE reload @@metadata |
     | conn_1 | False   | create index id_index on no_sharding(id) | Table 'db3.no_sharding' doesn't exist                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '12',), ('transactions', '7',))} | dble_information |
   # TODO: This step will be deleted after fixed DBLE0REQ-1110
   # rollback Table 'db3.no_sharding' doesn't exist, questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql      |
     | conn_1 | False   | rollback |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '13',), ('transactions', '8',))} | dble_information |

   # no default shardingNode
   Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
   """
   <schema name="schema1" sqlMaxLimit="100">
       <globalTable name="test" shardingNode="dn1,dn2"/>
   </schema>
   """
   Then execute admin cmd "reload @@config_all"
   # compare with show @@questions
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_7"
     | conn   | toClose | sql              | db                |
     | conn_0 | False   | show @@questions | dble_information  |
   Then check resultset "dble_status_7" has lines with following column values
     | Questions-0 | Transactions-1 |
     | 13          | 8              |
   Given prepare a thread execute sql "drop table if exist global_t1" with "conn_1"
   # 1064 error, questions + 1, transactions + 1
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '14',), ('transactions', '9',))}     |
   # other error, questions + 2, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                          | expect                                                           |
     | conn_1 | False   | delete from test                             | Table meta 'schema1.test' is lost,PLEASE reload @@metadata       |
     | conn_1 | False   | create table if not exists global_1 (id int) | Table 'schema1.global_1' doesn't exist in the config of sharding |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '16',), ('transactions', '11',))} | dble_information |
   # 1064 error in transaction, questions + 2, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                              |
     | conn_1 | False   | begin                            |
   Given prepare a thread execute sql "drop table if exist test" with "conn_1"
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '18',), ('transactions', '11',))} | dble_information |
   # return error and table does not config in sharding.xml, questions + 3, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                             | expect                                                           |
     | conn_1 | False   | rollback                        | success                                                          |
     | conn_1 | False   | begin                           | success                                                          |
     | conn_1 | False   | create table global_1 (id int)  | Table 'schema1.global_1' doesn't exist in the config of sharding |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
      #TODO: This step will be deleted after fixed DBLE0REQ-1110
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '21',), ('transactions', '12',))} | dble_information |
#     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '21',), ('transactions', '13',))} | dble_information |
   # no error and table does not config in sharding.xml, questions + 2, transactions + 1
     Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                             |
     | conn_1 | False   | begin                           |
     | conn_1 | False   | drop table if exists global_1   |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     #TODO: This step will be deleted after fixed DBLE0REQ-1110
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '23',), ('transactions', '13',))} | dble_information |
#     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '23',), ('transactions', '14',))} | dble_information |
   # compare with show @@questions
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_8"
     | conn   | toClose | sql              | db                |
     | conn_0 | True    | show @@questions | dble_information  |
   Then check resultset "dble_status_8" has lines with following column values
     | Questions-0 | Transactions-1 |
     | 23          | 13             |
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                       | db      |
     | conn_1 | True    | drop table if exists test | schema1 |

   Scenario: check questions/transactions set command - shardingUser #5
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                    |
     | conn_1 | False   | set autocommit=0                       |
     | conn_1 | False   | set autocommit=1                       |
     | conn_1 | False   | set autocommit=0                       |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '3',), ('transactions', '1',))} | dble_information |
   # questions + 4, transactions + 3
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                    |
     | conn_1 | False   | set autocommit=1                       |
     | conn_1 | False   | set autocommit=1                       |
     | conn_1 | False   | set autocommit=0                       |
     | conn_1 | False   | set autocommit=1                       |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '7',), ('transactions', '4',))} | dble_information |
   # questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                        |
     | conn_1 | False   | set autocommit=1,autocommit=1,autocommit=1 |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '8',), ('transactions', '5',))} | dble_information |
   # questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                        |
     | conn_1 | False   | set autocommit=0, xa=on, xa=off            |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '9',), ('transactions', '5',))} | dble_information |
   # questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                        |
     | conn_1 | False   | set autocommit=1, xa=on, xa=off            |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '10',), ('transactions', '6',))} | dble_information |
   # error sql questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                        | expect                                             |
     | conn_1 | False   | set autocommit=2                           | java.sql.SQLSyntaxErrorException: illegal value[2] |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '11',), ('transactions', '6',))} | dble_information |
   # questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                        |
     | conn_1 | False   | set xa=1, autocommit=0                     |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '12',), ('transactions', '6',))} | dble_information |
   # questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                        |
     | conn_1 | False   | set xa=1, autocommit=1                     |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '13',), ('transactions', '7',))} | dble_information |
   # questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                        |
     | conn_1 | False   | set xa=1, autocommit=1, autocommit=0       |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '14',), ('transactions', '7',))} | dble_information |
   # questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                        |
     | conn_1 | False   | set xa=1, autocommit=0, autocommit=1       |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '15',), ('transactions', '8',))} | dble_information |
   # questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                        |
     | conn_1 | False   | set autocommit=0, autocommit=1             |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '16',), ('transactions', '9',))} | dble_information |
   # questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                        |
     | conn_1 | False   | set autocommit=1, autocommit=0             |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '17',), ('transactions', '9',))} | dble_information |
   # questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                          |
     | conn_1 | False   | set autocommit=1, autocommit=1, autocommit=1 |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '18',), ('transactions', '10',))} | dble_information |
   # questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                          |
     | conn_1 | False   | set trace=1, autocommit=0                    |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '19',), ('transactions', '10',))} | dble_information |
   # set questions + 1, transactions + 0, close connection questions + 0, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                          |
     | conn_1 | True    | set autocommit=1,trace=1,xa=1,autocommit=0   |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '20',), ('transactions', '11',))} | dble_information |
   # compare with show @@questions
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_7"
     | conn   | toClose | sql              | db                |
     | conn_0 | True    | show @@questions | dble_information  |
   Then check resultset "dble_status_7" has lines with following column values
     | Questions-0 | Transactions-1 |
     | 20          | 11             |


   Scenario: check questions/transactions - rwSplitUser #6
   Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
   """
   <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
       <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true">
       </dbInstance>
   </dbGroup>
   """
   Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
   """
   <rwSplitUser name="split" password="111111" dbGroup="ha_group3" />
   """
   Then execute admin cmd "reload @@config_all"
   Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql     |
      | split | 111111 | conn_1 | False   | use db1 |
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect                                             | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '1',), ('transactions', '1',))} | dble_information |
   Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                  |
      | split | 111111 | conn_1 | False   | drop table if exists test_3          |
      | split | 111111 | conn_1 | False   | create table test_3(id int,code int) |
   #case query correct sql questions and transactions add 2
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '3',), ('transactions', '3',))}      |
   Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                   |
      | split | 111111 | conn_1 | False   | insert into test_3 values (1,1),(2,2) |
      | split | 111111 | conn_1 | False   | update test_3 set code=3 where code=2 |
      | split | 111111 | conn_1 | False   | delete from test_3 where code=3       |
      | split | 111111 | conn_1 | False   | select * from test_3                  |
   #case query correct sql questions and transactions add 4
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '7',), ('transactions', '7',))}      |
   Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                   |
      | split | 111111 | conn_1 | False   | set autocommit=0                      |
      | split | 111111 | conn_1 | False   | insert into test_3 values (2,2),(3,3) |
      | split | 111111 | conn_1 | False   | update test_3 set code=4              |
      | split | 111111 | conn_1 | False   | delete from test_3                    |
      | split | 111111 | conn_1 | False   | select * from test_3                  |
   #case sql in transaction not commit, questions add 5 but transactions not add
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '12',), ('transactions', '7',))}     |
   Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql              |
      | split | 111111 | conn_1 | False   | set autocommit=1 |
   #case "set autocommit=1" transaction, questions and transactions add 1
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '13',), ('transactions', '8',))}    |
   Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                   |
      | split | 111111 | conn_1 | False   | begin                                 |
      | split | 111111 | conn_1 | False   | insert into test_3 values (1,1),(2,2) |
      | split | 111111 | conn_1 | False   | update test_3 set code=4 where code>1 |
      | split | 111111 | conn_1 | False   | delete from test_3 where code>1       |
      | split | 111111 | conn_1 | False   | select * from test_3                  |
   #case sql in transaction not commit, questions add 5 and transactions not add
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '18',), ('transactions', '8',))}     |
   Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql      |
      | split | 111111 | conn_1 | False   | rollback |
   #case rollback transaction, questions and transactions add 1
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                 |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '19',), ('transactions', '9',))}    |

   Then execute admin cmd "reload @@config"
   #case query reload in admin mode ,questions and transactions not change
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                 |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '19',), ('transactions', '9',))}    |
   Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql              |
      | split | 111111 | conn_1 | False   | set autocommit=0 |
   #case query "set autocommit=0"  ,questions add 1 ,but transactions not changes
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                 |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '20',), ('transactions', '9',))}    |
   Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql              |
      | split | 111111 | conn_1 | False   | set autocommit=1 |
   #case "set autocommit=1" and error sql,questions and transactions add 1
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '21',), ('transactions', '10',))}    |
   Given prepare a thread execute sql "exit" with "conn_1"
   #case query exit, questions and transactions add 1
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '22',), ('transactions', '11',))}    |
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                           |
     | split | 111111 | conn_1 | False   | xa start 'xa_test_1'          |
     | split | 111111 | conn_1 | False   | update test_3 set code=1      |
     | split | 111111 | conn_1 | False   | xa end 'xa_test_1'            |
     | split | 111111 | conn_1 | False   | xa prepare 'xa_test_1'        |
     | split | 111111 | conn_1 | False   | xa commit 'xa_test_1'         |
     | split | 111111 | conn_1 | False   | xa start 'xa_test_2'          |
     | split | 111111 | conn_1 | False   | delete from test_3 where code=1 |
     | split | 111111 | conn_1 | False   | xa end 'xa_test_2'            |
     | split | 111111 | conn_1 | False   | xa prepare 'xa_test_2'        |
     | split | 111111 | conn_1 | False   | xa rollback 'xa_test_2'       |
   #case in xa, questions and transactions add 10
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '32',), ('transactions', '21',))} | dble_information |
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                   |
     | split | 111111 | conn_2 | True    | use db1               |
   #case query in different seesion,questions and transactions add 1
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                                                  |
      | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '33',), ('transactions', '22',))}    |
# DBLE0REQ-1117
#   Then execute sql in "dble-1" in "user" mode
#     | user  | passwd | conn   | toClose | sql                                                                                                                                        |
#     # multiple sql, questions add 4 and transactions add 4
#     | split | 111111 | conn_2 | False   | insert into test_3 values (60,60); update test_3 set code=66 where id>3; select * from test_3 where code=66; delete from test_3 where id=4 |
#   Then execute sql in "dble-1" in "admin" mode
#     | conn   | toClose | sql                                                                                       | expect                                               |
#     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '37',), ('transactions', '26',))} |
   #case compare with show @@questions
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_8"
      | conn   | toClose | sql              | db                |
      | conn_0 | True    | show @@questions | dble_information  |
   Then check resultset "dble_status_8" has lines with following column values
      | Questions-0 | Transactions-1 |
      | 33          | 22             |
   Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                               |
      | split | 111111 | conn_1 | True    | drop table if exists test_3       |

   Scenario: check questions/transactions in transaction - rwSplitUser #7
   Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
   """
   <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
       <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true">
       </dbInstance>
   </dbGroup>
   """
   Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
   """
   <rwSplitUser name="split" password="111111" dbGroup="ha_group3" />
   """
   Then execute admin cmd "reload @@config_all"
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                      |
     | split | 111111 | conn_1 | False   | use db1                                                  |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '1',), ('transactions', '1',))} | dble_information |
   # questions + 5, transactions + 4
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                |
     | split | 111111 | conn_1 | False   | drop table if exists test_2                        |
     | split | 111111 | conn_1 | False   | create table test_2(id int,code int)               |
     | split | 111111 | conn_1 | False   | begin                                              |
     | split | 111111 | conn_1 | False   | begin                                              |
     | split | 111111 | conn_1 | False   | commit                                             |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '6',), ('transactions', '5',))} | dble_information |
   # questions + 6, transactions + 4
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                |
     | split | 111111 | conn_1 | False   | set autocommit=0                                   |
     | split | 111111 | conn_1 | False   | begin                                              |
     | split | 111111 | conn_1 | False   | begin                                              |
     | split | 111111 | conn_1 | False   | insert into test_2 values (1,1),(2,2)              |
     | split | 111111 | conn_1 | False   | commit                                             |
     | split | 111111 | conn_1 | False   | set autocommit=1                                   |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '12',), ('transactions', '9',))} | dble_information |
   # questions + 5, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                |
     | split | 111111 | conn_1 | False   | set autocommit=0                                   |
     | split | 111111 | conn_1 | False   | insert into test_2 values (3,3)                    |
     | split | 111111 | conn_1 | False   | begin                                              |
     | split | 111111 | conn_1 | False   | select * from test_2                               |
     | split | 111111 | conn_1 | False   | set autocommit=1                                   |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '17',), ('transactions', '11',))} | dble_information |
   # questions + 4, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                |
     | split | 111111 | conn_1 | False   | begin                                              |
     | split | 111111 | conn_1 | False   | set autocommit=0                                   |
     | split | 111111 | conn_1 | False   | update test_2 set code=22 where id=2               |
     | split | 111111 | conn_1 | False   | set autocommit=1                                   |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '21',), ('transactions', '12',))} | dble_information |
   # questions + 6, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                |
     | split | 111111 | conn_1 | False   | begin                                              |
     | split | 111111 | conn_1 | False   | set autocommit=0                                   |
     | split | 111111 | conn_1 | False   | delete from test_2 where id=2                      |
     | split | 111111 | conn_1 | False   | commit                                             |
     | split | 111111 | conn_1 | False   | update test_2 set code=33 where id=3               |
     | split | 111111 | conn_1 | False   | set autocommit=1                                   |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '27',), ('transactions', '14',))} | dble_information |
   # questions + 5, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                |
     | split | 111111 | conn_1 | False   | begin                                              |
     | split | 111111 | conn_1 | False   | insert into test_2 values (2,2)                    |
     | split | 111111 | conn_1 | False   | set autocommit=1                                   |
     | split | 111111 | conn_1 | False   | select * from test_2                               |
     | split | 111111 | conn_1 | False   | commit                                             |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '32',), ('transactions', '15',))} | dble_information |
   # questions + 4, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                |
     | split | 111111 | conn_1 | False   | begin                                              |
     | split | 111111 | conn_1 | False   | set autocommit=1                                   |
     | split | 111111 | conn_1 | False   | select * from test_2                               |
     | split | 111111 | conn_1 | False   | commit                                             |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '36',), ('transactions', '16',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                |
     | split | 111111 | conn_1 | False   | begin                                              |
     | split | 111111 | conn_1 | False   | delete from test_2 where id=3                      |
     | split | 111111 | conn_1 | False   | rollback                                           |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '39',), ('transactions', '17',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                |
     | split | 111111 | conn_1 | False   | begin                                              |
     | split | 111111 | conn_1 | False   | select * from test_2                               |
     | split | 111111 | conn_1 | False   | commit                                             |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '42',), ('transactions', '18',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                |
     | split | 111111 | conn_1 | False   | begin                                              |
     | split | 111111 | conn_1 | False   | select * from test_2                               |
     | split | 111111 | conn_1 | False   | create table IF NOT EXISTS sharding_4_t1 (id int)  |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '45',), ('transactions', '19',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                   |
     | split | 111111 | conn_1 | False   | begin                                                 |
     | split | 111111 | conn_1 | False   | select * from test_2                                  |
     | split | 111111 | conn_1 | False   | alter table sharding_4_t1 add column name varchar(10) |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '48',), ('transactions', '20',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                   |
     | split | 111111 | conn_1 | False   | begin                                                 |
     | split | 111111 | conn_1 | False   | select * from test_2                                  |
     | split | 111111 | conn_1 | False   | truncate table sharding_4_t1                          |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '51',), ('transactions', '21',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                   |
     | split | 111111 | conn_1 | False   | begin                                                 |
     | split | 111111 | conn_1 | False   | select * from test_2                                  |
     | split | 111111 | conn_1 | False   | drop table IF EXISTS sharding_4_t1                    |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '54',), ('transactions', '22',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                   |
     | split | 111111 | conn_1 | False   | begin                                                 |
     | split | 111111 | conn_1 | False   | select * from test_2                                  |
     | split | 111111 | conn_1 | False   | create index id_index on test_2(id)                   |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '57',), ('transactions', '23',))} | dble_information |
   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                   |
     | split | 111111 | conn_1 | False   | begin                                                 |
     | split | 111111 | conn_1 | False   | select * from test_2                                  |
     | split | 111111 | conn_1 | False   | drop index id_index on test_2                         |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '60',), ('transactions', '24',))} | dble_information |
   # questions + 3, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                   |
     | split | 111111 | conn_1 | False   | set autocommit=0                                      |
     | split | 111111 | conn_1 | False   | create table IF NOT EXISTS sharding_4_t1 (id int)     |
     | split | 111111 | conn_1 | False   | set autocommit=1                                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '63',), ('transactions', '26',))} | dble_information |
   # questions + 3, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                   |
     | split | 111111 | conn_1 | False   | set autocommit=0                                      |
     | split | 111111 | conn_1 | False   | alter table sharding_4_t1 add column name varchar(10) |
     | split | 111111 | conn_1 | False   | set autocommit=1                                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '66',), ('transactions', '28',))} | dble_information |
   # questions + 4, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                   |
     | split | 111111 | conn_1 | False   | set autocommit=0                                      |
     | split | 111111 | conn_1 | False   | truncate table sharding_4_t1                          |
     | split | 111111 | conn_1 | False   | set autocommit=0                                      |
     | split | 111111 | conn_1 | False   | set autocommit=1                                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '70',), ('transactions', '30',))} | dble_information |
   # questions + 3, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                   |
     | split | 111111 | conn_1 | False   | set autocommit=0                                      |
     | split | 111111 | conn_1 | False   | drop table IF EXISTS sharding_4_t1                |
     | split | 111111 | conn_1 | False   | set autocommit=1                                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '73',), ('transactions', '32',))} | dble_information |
   # questions + 3, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                   |
     | split | 111111 | conn_1 | False   | set autocommit=0                                      |
     | split | 111111 | conn_1 | False   | create index id_index on test_2(id)                   |
     | split | 111111 | conn_1 | False   | set autocommit=1                                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '76',), ('transactions', '34',))} | dble_information |
   # questions + 3, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                   |
     | split | 111111 | conn_1 | False   | set autocommit=0                                      |
     | split | 111111 | conn_1 | False   | drop index id_index on test_2                         |
     | split | 111111 | conn_1 | False   | set autocommit=1                                      |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '79',), ('transactions', '36',))} | dble_information |
   # questions + 8, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                         |
     | split | 111111 | conn_1 | False   | set autocommit=0            |
     | split | 111111 | conn_1 | False   | xa start 'xa_test_1'        |
     | split | 111111 | conn_1 | False   | delete from test_2 where id=3 |
     | split | 111111 | conn_1 | False   | xa end 'xa_test_1'          |
     | split | 111111 | conn_1 | False   | xa prepare 'xa_test_1'      |
     | split | 111111 | conn_1 | False   | xa commit 'xa_test_1'       |
     | split | 111111 | conn_1 | False   | commit                      |
     | split | 111111 | conn_1 | False   | set autocommit=1            |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '87',), ('transactions', '38',))} | dble_information |
   # questions + 7, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                         | expect                                                                                            |
     | split | 111111 | conn_1 | False   | begin                       | success                                                                                           |
     | split | 111111 | conn_1 | False   | xa start 'xa_test_2'        | XAER_OUTSIDE: Some work is done outside global transaction                                        |
     | split | 111111 | conn_1 | False   | delete from test_2 where id=2 | success                                                                                           |
     | split | 111111 | conn_1 | False   | xa end 'xa_test_2'          | XAER_RMFAIL: The command cannot be executed when global transaction is in the  NON-EXISTING state |
     | split | 111111 | conn_1 | False   | xa prepare 'xa_test_2'      | XAER_RMFAIL: The command cannot be executed when global transaction is in the  NON-EXISTING state |
     | split | 111111 | conn_1 | False   | xa rollback 'xa_test_2'     | XAER_NOTA: Unknown XID                                                                            |
     | split | 111111 | conn_1 | False   | rollback                    | success                                                                                           |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '94',), ('transactions', '39',))} | dble_information |
   # query and close connection, questions + 2, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                   |
     | split | 111111 | conn_1 | False   | begin                                                 |
     | split | 111111 | conn_1 | True    | select * from test_2                                  |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                       | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '96',), ('transactions', '40',))} | dble_information |
# DBLE0REQ-1117
#   Then execute sql in "dble-1" in "user" mode
#     | user  | passwd | conn   | toClose | sql                                                                                                                                                       |
#     # questions add 2 and transactions add 2
#     | split | 111111 | conn_2 | False   | use db1;create table if not exists test_2(id int, code int)                                                                                               |
#     # multiple sql, questions add 6 and transactions add 1
#     | split | 111111 | conn_2 | False   | begin; insert into test_2 values (60,60); update test_2 set code=66 where id>3; select * from test_2 where code=66; delete from test_2 where id=3; commit |
#   Then execute sql in "dble-1" in "admin" mode
#     | conn   | toClose | sql                                                                                       | expect                                                |
#     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '104',), ('transactions', '43',))} |
#   Then execute sql in "dble-1" in "user" mode
#     | user  | passwd | conn   | toClose | sql                                      |
#     | split | 111111 | conn_2 | False   | set autocommit=0; begin; begin; rollback |
#     # multiple sql, questions add 4 and transactions add 3
#     Then execute sql in "dble-1" in "admin" mode
#     | conn   | toClose | sql                                                                                       | expect                                                |
#     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '108',), ('transactions', '45',))} |
   # compare with show @@questions
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_9"
     | conn   | toClose | sql              | db                |
     | conn_0 | True    | show @@questions | dble_information  |
   Then check resultset "dble_status_9" has lines with following column values
     | Questions-0 | Transactions-1 |
     | 96          | 40             |
   Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                               | db  |
      | split | 111111 | conn_2 | True    | drop table if exists test_2       | db1 |

   Scenario: check questions/transactions set command - rwSplitUser #8
   Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
   """
   <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
       <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true">
       </dbInstance>
   </dbGroup>
   """
   Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
   """
   <rwSplitUser name="split" password="111111" dbGroup="ha_group3" />
   """
   Then execute admin cmd "reload @@config_all"

   # questions + 3, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                    |
     | split | 111111 | conn_1 | False   | set autocommit=0                       |
     | split | 111111 | conn_1 | False   | set autocommit=1                       |
     | split | 111111 | conn_1 | False   | set autocommit=0                       |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '3',), ('transactions', '1',))} | dble_information |
   # questions + 4, transactions + 3
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                    |
     | split | 111111 | conn_1 | False   | set autocommit=1                       |
     | split | 111111 | conn_1 | False   | set autocommit=1                       |
     | split | 111111 | conn_1 | False   | set autocommit=0                       |
     | split | 111111 | conn_1 | False   | set autocommit=1                       |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '7',), ('transactions', '4',))} | dble_information |
   # questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                        |
     | split | 111111 | conn_1 | False   | set autocommit=1,autocommit=1,autocommit=1 |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '8',), ('transactions', '5',))} | dble_information |
   # error sql questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                        | expect                                               |
     | split | 111111 | conn_1 | False   | set autocommit=0, xa=on, xa=off            | java.sql.SQLSyntaxErrorException: unsupported set xa |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '9',), ('transactions', '5',))} | dble_information |
   # error sql questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                        | expect                                               |
     | split | 111111 | conn_1 | False   | set autocommit=1, xa=1, xa=0               | java.sql.SQLSyntaxErrorException: unsupported set xa |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '10',), ('transactions', '5',))} | dble_information |
   # error sql questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                        | expect                                             |
     | split | 111111 | conn_1 | False   | set autocommit=2                           | java.sql.SQLSyntaxErrorException: illegal value[2] |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '11',), ('transactions', '5',))} | dble_information |
   # questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                        |
     | split | 111111 | conn_1 | False   | set autocommit=0, autocommit=1             |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '12',), ('transactions', '6',))} | dble_information |
   # questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                        |
     | split | 111111 | conn_1 | False   | set autocommit=1, autocommit=0             |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                              | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '13',), ('transactions', '6',))} | dble_information |
   # questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                          |
     | split | 111111 | conn_1 | False   | set character_set_client=utf8, autocommit=0  |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '14',), ('transactions', '6',))}  | dble_information |
   # questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                          |
     | split | 111111 | conn_1 | False   | set character_set_client=utf8, autocommit=1  |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '15',), ('transactions', '7',))}  | dble_information |
   # set questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                     |
     | split | 111111 | conn_1 | False   | set autocommit=1,character_set_client=utf8,autocommit=0 |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '16',), ('transactions', '7',))} | dble_information |
   # set questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                     |
     | split | 111111 | conn_1 | False   | set autocommit=0,character_set_client=utf8,autocommit=1 |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '17',), ('transactions', '8',))} | dble_information |
   # questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                          |
     | split | 111111 | conn_1 | False   | set character_set_client=utf8                |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '18',), ('transactions', '9',))}  | dble_information |
   # questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                          |
     | split | 111111 | conn_1 | False   | set trace=1, autocommit=0                    |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '19',), ('transactions', '9',))}  | dble_information |
   # set questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                          |
     | split | 111111 | conn_1 | False   | set autocommit=0,trace=1                     |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '20',), ('transactions', '9',))} | dble_information |
   # set questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                          |
     | split | 111111 | conn_1 | False   | set autocommit=1,trace=1,autocommit=0        |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '21',), ('transactions', '9',))} | dble_information |
   # set questions + 1, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                          |
     | split | 111111 | conn_1 | False   | set trace=1                                  |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '22',), ('transactions', '9',))} | dble_information |
   # DBLE0REQ-1108
   # questions + 1, transactions + 1
#   Then execute sql in "dble-1" in "user" mode
#     | user  | passwd | conn   | toClose | sql                                          |
#     | split | 111111 | conn_1 | False   | set trace=1,autocommit=1                     |
#   Then execute sql in "dble-1" in "admin" mode
#     | conn   | toClose | sql                                                                                     | expect                                               | db               |
#     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '23',), ('transactions', '10',))} | dble_information |
   # set questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                     |
     | split | 111111 | conn_1 | False   | set autocommit=1        |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '23',), ('transactions', '10',))} | dble_information |
   # set questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                          |
     | split | 111111 | conn_1 | False   | set autocommit=1,trace=1                     |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '24',), ('transactions', '11',))} | dble_information |
   # set questions + 1, transactions + 1
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                          |
     | split | 111111 | conn_1 | True    | set autocommit=0,trace=1,autocommit=1        |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '25',), ('transactions', '12',))} | dble_information |
   # compare with show @@questions
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_10"
     | conn   | toClose | sql              | db                |
     | conn_0 | True    | show @@questions | dble_information  |
   Then check resultset "dble_status_10" has lines with following column values
     | Questions-0 | Transactions-1 |
     | 25          | 12             |

   Scenario: check questions/transactions error sql - rwSplitUser #9
   Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
   """
   <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
       <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true">
       </dbInstance>
   </dbGroup>
   """
   Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
   """
   <rwSplitUser name="split" password="111111" dbGroup="ha_group3" />
   """
   Then execute admin cmd "reload @@config_all"
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql     |
     | split | 111111 | conn_1 | False   | use db1 |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '1',), ('transactions', '1',))} | dble_information |
   Given prepare a thread execute sql "drop table if exist test_1" with "conn_1"
   # 1064 error sql questions and transactions add 1
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                       | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '2',), ('transactions', '2',))} | dble_information |
   Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql              | expect                                               |
     | split | 111111 | conn_1 | False   | set xa=off       | java.sql.SQLSyntaxErrorException: unsupported set xa |
   # TODO transactions + 1? transactions + 2?
   # 1064 error sql,questions add 1 ,but transactions add 0
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                       | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%'   | has{(('questions', '3',), ('transactions', '2',))} | dble_information |
   # other error, questions + 2, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                 | expect                           |
     | conn_1 | False   | delete from test_1                  | Table 'db1.test_1' doesn't exist |
     | conn_1 | False   | create index id_index on test_1(id) | Table 'db1.test_1' doesn't exist |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '5',), ('transactions', '4',))} | dble_information |
   # 1064 error in transaction, questions + 2, transactions + 0
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                              |
     | conn_1 | False   | begin                            |
   Given prepare a thread execute sql "drop table if exist test_1" with "conn_1"
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                             | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '7',), ('transactions', '4',))} | dble_information |
   # other error, questions + 3, transactions + 2
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                 | expect                           |
     | conn_1 | False   | rollback                            | success                          |
     | conn_1 | False   | begin                               | success                          |
     | conn_1 | False   | create index id_index on test_1(id) | Table 'db1.test_1' doesn't exist |
   Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                     | expect                                               | db               |
     | conn_0 | False   | select variable_name,variable_value from dble_status where variable_name like '%tions%' | has{(('questions', '10',), ('transactions', '6',))} | dble_information |
   # compare with show @@questions
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_status_8"
     | conn   | toClose | sql              | db                |
     | conn_0 | True    | show @@questions | dble_information  |
   Then check resultset "dble_status_8" has lines with following column values
     | Questions-0 | Transactions-1 |
     | 10          | 6              |
   Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                         | db      |
     | conn_1 | True    | drop table if exists test_1 | schema1 |