# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2020/9/23

Feature: test addition, deletion and modification of dble_information on the management side
  @skip_restart
  Scenario: test the langreage of insert in dble manager        #1
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                       | expect     |db|
      | conn_0 | true    | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('ha_group3','select 1',0,1,0,100,'false');                         | success |dble_information|
      | conn_0 | true    | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('dbGrou-p','select 1',0,1,0,100,'false');                           | success |dble_information|
      | conn_0 | true    | insert into dble_information.dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('ha_group5','show slave status',0,1,0,100,'true'); | success |dble_information|
      | conn_0 | true    | insert into DBLE_db_group(NAME,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('ha_group6','select 1',1,2,2,10,'true');                              | success |dble_information  |
      | conn_0 | true    | insert into DBLE_db_group(NAME,heartbeat_stmt,rw_split_mode) values('ha_group7','select 1',1),('ha_group8','select 1',1);                                                                                    | success |dble_information   |
      | conn_0 | true    | insert into DBLE_db_group set name='ha_group9',heartbeat_stmt='select 1',rw_split_mode=1;                                                                                                                        | success |dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_1"
      | conn   | toClose | sql                         | db               |
      | conn_0 | true   | select * from dble_db_group | dble_information |
    Then check resultset "dble_db_group_1" has lines with following column values
      | name-0    | heartbeat_stmt-1  | heartbeat_timeout-2 | heartbeat_retry-3 | rw_split_mode-4 | delay_threshold-5 | disable_ha-6 | active-7 |
      | ha_group1 | select user()     | 0                   | 1                 | 0               | 100               | false        | true     |
      | ha_group2 | select user()     | 0                   | 1                 | 0               | 100               | false        | true     |
      | ha_group3 | select 1          | 0                   | 1                 | 0               | 100               | false        | false    |
      | ha_group5 | show slave status | 0                   | 1                 | 0               | 100               | true         | false    |
      | ha_group6 | select 1          | 1                   | 2                 | 2               | 10                | true         | false    |
      | ha_group7 | select 1          | 0                   | 1                 | 1               | -1                | false        | false    |
      | ha_group8 | select 1          | 0                   | 1                 | 1               | -1                | false        | false    |
      | ha_group9 | select 1          | 0                   | 1                 | 1               | -1                | false        | false    |
      | dbGrou-p  | select 1          | 0                   | 1                 | 0               | 100               | false        | false    |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                        | expect                                                                   | db               |
      | conn_0 | true    | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('ha_group3','select 1',0,1,1,100,'false');                                           | Duplicate entry 'ha_group3' for key 'PRIMARY'                            | dble_information |
      | conn_0 | true    | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('ha_group4',1,'s',1,1,100,'false');                                                   | unknown error:For input string: "s"                                      | dble_information |
      | conn_0 | true    | insert into dble_db_group value('ha_group4','select 1',-1,1,1,100,'false','ture');                                                                                                                                               | Column 'active' is not writable                                          | dble_information |
      | conn_0 | true    | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('ha_group4',null,0,1,1,100,'false');                                                  | Column 'heartbeat_stmt' cannot be null                                   | dble_information |
      | conn_0 | true    | insert into dble_db_group(name,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold) value('ha_group4',0,1,1,100);                                                                                               | Field '[heartbeat_stmt]' doesn't have a default value and cannot be null | dble_information |
#      | conn_0 | true   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('dbGroup4','select 1',0,1,1,100,'0B01');|Column count doesn't match value count at row 1 |dble_information|
      | conn_0 | true    | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('dbGroup4','select 1',0,1,1,100);                                                      | Column count doesn't match value count at row 1                          | dble_information |
      | conn_0 | true    | insert into dble_in.dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('dbGroup4','select 1',0,1,1,100,'false');                                      | Unknown database 'dble_in'                                                | dble_information |
      | conn_0 | true    | insert int dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value(('dbGroup4','select 1',0,1,1,100,'false');                                              | You have an error in your SQL syntax                                     | dble_information |
      | conn_0 | true    | insert LOW_PRIORITY into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('dbGroup4','select 1',0,1,1,100,'false');                                 | update syntax error, not support insert with syntax                       | dble_information |
      | conn_0 | true    | insert DELAYED into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('dbGroup4','select 1',0,1,1,100,'false');                                      | update syntax error, not support insert with syntax                      | dble_information |
      | conn_0 | true    | insert HIGH_PRIORITY into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('dbGroup4','select 1',0,1,1,100,'false');                                | update syntax error, not support insert with syntax                      | dble_information |
      | conn_0 | true    | insert IGNORE into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('dbGroup4','select 1',0,1,1,100,'false');                                       | update syntax error, not support insert with syntax                      | dble_information |
      | conn_0 | true    | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('dbGroup4','select 1',0,1,1,100,'false') ON DUPLICATE KEY UPDATE heartbeat_timeout=1;  | update syntax error, not support insert with syntax                      | dble_information |
      | conn_0 | true    | insert dble_db_group name select name from dble_db_instance;                                                                                                                                                                            | Insert syntax error,not support insert ... select                        | dble_information |

  @skip_restart
  Scenario:  test the langreage of update in dble manager  #2
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                  | expect  | db               |
      | conn_0 | true    | update dble_db_group set heartbeat_retry=10 where active='true'                                      | success | dble_information |
      | conn_0 | true    | update dble_db_group set heartbeat_stmt='select user()',heartbeat_timeout=1 where delay_threshold=-1 | success | dble_information |
      | conn_0 | true    | update dble_db_group set heartbeat_retry=11 where active='true'                                      | success | dble_information |
      | conn_0 | true    | update dble_db_group set heartbeat_stmt='select @a' where heartbeat_timeout=1 and heartbeat_retry!=1 | success | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_2"
      | conn   | toClose | sql                         | db               |
      | conn_0 | true    | select * from dble_db_group  | dble_information |
    Then check resultset "dble_db_group_2" has lines with following column values
      | name-0    | heartbeat_stmt-1  | heartbeat_timeout-2 | heartbeat_retry-3 | rw_split_mode-4 | delay_threshold-5 | disable_ha-6 | active-7 |
      | ha_group1 | select user()     | 0                   | 11                | 0               | 100               | false        | true     |
      | ha_group2 | select user()     | 0                   | 11                | 0               | 100               | false        | true     |
      | ha_group3 | select 1          | 0                   | 1                 | 0               | 100               | false        | false    |
      | ha_group5 | show slave status | 0                   | 1                 | 0               | 100               | true         | false    |
      | ha_group6 | select @a         | 1                   | 2                 | 2               | 10                | true         | false    |
      | ha_group7 | select user()     | 1                   | 1                 | 1               | -1                | false        | false    |
      | ha_group8 | select user()     | 1                   | 1                 | 1               | -1                | false        | false    |
      | ha_group9 | select user()     | 1                   | 1                 | 1               | -1                | false        | false    |
      | dbGrou-p  | select 1          | 0                   | 1                 | 0               | 100               | false        | false    |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                           | expect                                                              | db               |
      | conn_0 | true    | update dble_db_group,dble_db_instance set heartbeat_retry=10 where active='false';                            | update syntax error, not support update Multiple-Table              | dble_information |
      | conn_0 | true    | update dble_db_group set heartbeat_retry=10 where (select active from dble_db_group where heartbeat_retry=1); | update syntax error, not support sub-query                          | dble_information |
      | conn_0 | true    | update dble_db_group set heartbeat=10 where active='false';                                                   | Unknown column 'heartbeat' in 'field list'                          | dble_information |
      | conn_0 | true    | update dble_db_group set name='ha_group10' where active='false';                                              | Primary column 'name' can not be update, please use delete & insert | dble_information |
      | conn_0 | true    | update dble_rw_split_entry set username='test' where db_group='db_group1';                                    | Column 'username' is not writable                                   | dble_information |
      | conn_0 | true    | update dble_db_group set rw_split_mode=null where db_group='db_group1';                                       | Column 'rw_split_mode' cannot be null                               | dble_information |
      | conn_0 | true    | update LOW_PRIORITY dble_db_group set heartbeat_stmt='select user()' where db_group='db_group1';              | update syntax error, not support update with syntax                 | dble_information |
      | conn_0 | true    | update IGNORE dble_db_group set heartbeat_stmt='select user()' where db_group='db_group1';                    | update syntax error, not support update with syntax                 | dble_information |
      | conn_0 | true    | update dble_db_group set heartbeat_stmt='select user()' where db_group='db_group1' order by heartbeat_retry;  | update syntax error, not support update with syntax                 | dble_information |
      | conn_0 | true    | update dble_db_group set heartbeat_stmt='select user()' where db_group='db_group1' limit 2;                   | update syntax error, not support update with syntax                 | dble_information |
      | conn_0 | true    | update dble_db_group set heartbeat_stmt='select user()' ;                                                     | update syntax error, not support update without WHERE               | dble_information |
      | conn_0 | true    | update dble_db_group a set heartbeat_retry=10 where active='true'                                             | update syntax error, not support update with alias                  | dble_information |
      | conn_0 | true    | update dble_db_group st heartbeat_retry=10 where active='true'                                                | You have an error in your SQL syntax                                | dble_information |
      | conn_0 | true    | update dble_db_group set active='true' where heartbeat_retry=1                                                | Column 'active' is not writable                                     | dble_information |


  Scenario: test the langreage of delete in dble manager #3
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                      | expect  | db               |
      | conn_0 | true   | delete from dble_db_group where name='db_group9';                         | success | dble_information |
      | conn_0 | true   | delete from dble_db_group where disable_ha='true';                        | success | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_2"
      | conn   | toClose | sql                             | db               |
      | conn_0 | true    | select * from dble_db_group     | dble_information |
    Then check resultset "dble_db_group_2" has lines with following column values
      | name-0    | heartbeat_stmt-1 | heartbeat_timeout-2 | heartbeat_retry-3 | rw_split_mode-4 | delay_threshold-5 | disable_ha-6 | active-7 |
      | ha_group1 | select user()    | 0                   | 11                | 0               | 100               | false        | true     |
      | ha_group2 | select user()    | 0                   | 11                | 0               | 100               | false        | true     |
      | ha_group3 | select 1         | 0                   | 1                 | 0               | 100               | false        | false    |
      | ha_group7 | select user()    | 1                   | 1                 | 1               | -1                | false        | false    |
      | ha_group8 | select user()    | 1                   | 1                 | 1               | -1                | false        | false    |
      | dbGrou-p  | select 1         | 0                   | 1                 | 0               | 100               | false        | false    |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                         | expect                                                 | db               |
      | conn_0 | true    | delete from dble_db_group,dble_db_instance where name='db_group9';                          | delete syntax error, not support delete Multiple-Table | dble_information |
      | conn_0 | true    | delete from dble_db_group where (select active from dble_db_group where heartbeat_retry=1); | delete syntax error, not support sub-query             | dble_information |
      | conn_0 | true    | delete LOW_PRIORITY from dble_db_group where name='db_group9';                              | delete syntax error, not support delete with syntax    | dble_information |
      | conn_0 | true    | delete QUICK from dble_db_group where name='db_group9';                                     | delete syntax error, not support delete with syntax    | dble_information |
      | conn_0 | true    | delete IGNORE from dble_db_group where name='db_group9';                                    | delete syntax error, not support delete with syntax    | dble_information |
      | conn_0 | true    | delete from dble_db_group where name='db_group9' order by heartbeat_retry;                  | delete syntax error, not support delete with syntax    | dble_information |
      | conn_0 | true    | delete from dble_db_group where name='db_group9' limit 2;                                   | delete syntax error, not support delete with syntax    | dble_information |
      | conn_0 | true    | delete from dble_db_grou where name='db_group9';                                            | Table `dble_information`.`dble_db_grou` doesn't exist  | dble_information |
      | conn_0 | true    | delete from dble_db_group;                                                                  | delete syntax error, not support delete without WHERE  | dble_information |
      | conn_0 | true    | delete from dble_db_group a where name='db_group9';                                         | delete syntax error, not support delete with alias     | dble_information |






