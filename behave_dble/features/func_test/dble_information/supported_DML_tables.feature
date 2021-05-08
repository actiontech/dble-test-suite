# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2020/9/23 change by quexiuping 2021/5/7

Feature: test addition, deletion and modification of dble_information on the management side
   dble_db_group
   dble_db_instance
   dble_rw_split_entry


  @skip_restart
  Scenario: test the langreage of insert in dble manager   ---- dble_db_group  #1
    # dble_db_group is temporary tables ,restart dble ,the dble_db_group will be null
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                   | expect      | db               |
      | conn_0 | false   | insert into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group3','select 1',60,1,1,-1,'false')                           | success     | dble_information |
      | conn_0 | false   | insert into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) values ('ha_group4','select 2',100,1,2,1000,'false')                       | success     | dble_information |
      | conn_0 | true    | select * from dble_db_group                                                                                                                                                                           | length{(4)} | dble_information |
    Given Restart dble in "dble-1" success

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                   | expect      | db               |
      | conn_0 | true    | select * from dble_db_group                                                                                                                                                                           | length{(2)} | dble_information |
      | conn_0 | false   | insert into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group3','select 1',60,1,1,-1,'false')                           | success     | dble_information |
      | conn_0 | false   | insert into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) values ('ha_group4','select 2',100,1,2,1000,'false')                       | success     | dble_information |
      | conn_0 | false   | insert into dble_information.dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group5','show slave status',88,1,2,999,'true') | success     | dble_information |
      | conn_0 | false   | insert into DBLE_db_group (NAME,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group6','select @@read_only',1,2,0,-1,'true')                   | success     | dble_information |
      | conn_0 | false   | insert into DBLE_db_group (NAME,heartbeat_stmt,rw_split_mode) values ('ha_group7','select 3',1),('ha_group8','select 4',2)                                                                            | success     | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='ha_group9',heartbeat_stmt='select 5',rw_split_mode=1                                                                                                              | success     | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='ha_group10',heartbeat_stmt='select user',rw_split_mode=2,disable_ha='true'                                                                                        | success     | dble_information |
#   1083  1081
#      | conn_0 | false   | insert into DBLE_db_group set name='ha_group11',heartbeat_stmt='select 6',rw_split_mode=3                                                                                                             | success     | dble_information |
#      | conn_0 | false   | insert into dble_db_group (name,heartbeat_timeout,heartbeat_stmt,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('ha_group12',100,'select 7',1,2,1000,'false')                        | success     | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_1"
      | conn   | toClose | sql                         | db               |
      | conn_0 | true   | select * from dble_db_group | dble_information |
    Then check resultset "dble_db_group_1" has lines with following column values
      | name-0     | heartbeat_stmt-1   | heartbeat_timeout-2 | heartbeat_retry-3 | rw_split_mode-4 | delay_threshold-5 | disable_ha-6 | active-7 |
      | ha_group1  | select user()      | 0                   | 1                 | 0               | 100               | false        | true     |
      | ha_group2  | select user()      | 0                   | 1                 | 0               | 100               | false        | true     |
      | ha_group3  | select 1           | 60                  | 1                 | 1               | -1                | false        | false    |
      | ha_group4  | select 2           | 100                 | 1                 | 2               | 1000              | false        | false    |
      | ha_group5  | show slave status  | 88                  | 1                 | 2               | 999               | true         | false    |
      | ha_group6  | select @@read_only | 1                   | 2                 | 0               | -1                | true         | false    |
      | ha_group7  | select 3           | 0                   | 1                 | 1               | -1                | false        | false    |
      | ha_group8  | select 4           | 0                   | 1                 | 2               | -1                | false        | false    |
      | ha_group9  | select 5           | 0                   | 1                 | 1               | -1                | false        | false    |
      | ha_group10 | select user        | 0                   | 1                 | 2               | -1                | true         | false    |
#      | ha_group11 | select 6           | 0                   | 1                 | 3               | -1                | false        | false    |
#      | ha_group12 | NULL               | 100                 | 1                 | NULL            | -1                | false        | false    |

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                    | expect                                                                                 | db               |
      | conn_0 | false   | insert LOW_PRIORITY into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('dbGroup4','select 1',0,1,1,100,'false')                                | update syntax error, not support insert with syntax                                    | dble_information |
      | conn_0 | false   | insert DELAYED into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('dbGroup4','select 1',0,1,1,100,'false')                                     | update syntax error, not support insert with syntax                                    | dble_information |
      | conn_0 | false   | insert HIGH_PRIORITY into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('dbGroup4','select 1',0,1,1,100,'false')                               | update syntax error, not support insert with syntax                                    | dble_information |
      | conn_0 | false   | insert IGNORE into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('dbGroup4','select 1',0,1,1,100,'false')                                      | update syntax error, not support insert with syntax                                    | dble_information |
      | conn_0 | false   | insert into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('dbGroup4','select 1',0,1,1,100,'false') ON DUPLICATE KEY UPDATE heartbeat_timeout=1 | update syntax error, not support insert with syntax                                    | dble_information |
      | conn_0 | false   | insert dble_db_group name select name from dble_db_instance                                                                                                                                                            | Insert syntax error,not support insert ... select                                      | dble_information |
      | conn_0 | false   | insert into dble_db_group value ('group1','select 1',-1,1,1,100,'false','ture')                                                                                                                                        | Column 'active' is not writable                                                        | dble_information |
      | conn_0 | false   | insert into dble_db_group values ('group2',100,'select 2',1,2,1000,'false')                                                                                                                                            | Column count doesn't match value count at row 1                                        | dble_information |
      | conn_0 | false   | insert into dble_in.dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('group3','select 1',0,1,1,100,'false')                                        | Unknown database 'dble_in'                                                             | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group3','select 1',0,1,1,100,'false')                                             | Duplicate entry 'ha_group3' for key 'PRIMARY'                                          | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('ha',1,'s',1,1,100,'false')                                                            | Insert failure.The reason is incorrect integer value: 's'                              | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('ha_group4',null,0,1,1,100,'false')                                                    | Column 'heartbeat_stmt' cannot be null                                                 | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold) value('ha_group4',0,1,1,100)                                                                                           | Field '[heartbeat_stmt]' doesn't have a default value and cannot be null               | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('dbGroup4','select 1',0,1,1,100,'0B01')                                                | Insert failure.The reason is Column 'disable_ha' values only support 'false' or 'true' | dble_information |
      | conn_0 | false   | insert int dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value(('dbGroup4','select 1',0,1,1,100,'false')                                               | You have an error in your SQL syntax                                                   | dble_information |
#      | conn_0 | false   | insert into DBLE_db_group set name='group9',heartbeat_stmt='select 5',rw_split_mode=4                                                                                                                                  | Insert failure.The reason is rwSplitMode should be between 0 and 3!                    | dble_information |
    # DBLE0REQ-1084
#      | conn_0 | false   | insert into DBLE_db_group set name='group9',heartbeat_stmt='select 5',rw_split_mode=0,delay_threshold=9.9                                                                                                              |                     | dble_information |
#      | conn_0 | false   | insert into DBLE_db_group set name='group9',heartbeat_stmt='select 5',rw_split_mode=0,heartbeat_timeout=9.9                                                                                                            |                     | dble_information |
#      | conn_0 | false   | insert into DBLE_db_group set name='group9',heartbeat_stmt='select 5',rw_split_mode=0,heartbeat_retry=9.9                                                                                                              |                     | dble_information |
#      | conn_0 | false   | insert into DBLE_db_group set name='group9',heartbeat_stmt='select 5',rw_split_mode=0,disable_ha=9.9                                                                                                                  | Not Supported of Value EXPR :9.9                  | dble_information |

#    Given execute sql in "dble-1" in "admin" mode
#      | conn   | toClose | sql                                                                                                                                                                  | expect  | db               |
#      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('null','select 1',0,1,1,100,'false') | success | dble_information |
#      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('group1','null',0,1,1,100,'false')  | success | dble_information |
#      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('group2',' ',0,1,1,100,'false')     | success | dble_information |
#      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value (' ',' ',0,1,1,100,'false')          | success | dble_information |
#      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('group3',1,' ',1,1,100,'false')      | success | dble_information |
##      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value (' ',' ',' ',1,1,100,'false')        | success | dble_information |
##      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value (' ',' ',' ',' ',1,100,'false')      | success | dble_information |


  @skip_restart
  Scenario: test the langreage of insert in dble manager   ---- dble_db_instance  #2
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                      | expect  | db               |
      | conn_0 | false    | select * from dble_db_instance                                                                                                                                                                           | length{(2)} | dble_information |

#      | conn_0 | false    | insert into dble_db_instance(name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostM3','ha_group3','172.100.9.1','3306','test','111111','false','true','1','99')         | success        | dble_information |


      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,disabled,min_conn_count,max_conn_count,read_weight,id,connection_timeout,connection_heartbeat_timeout,test_on_create,test_on_borrow,test_on_return,test_while_idle,time_between_eviction_runs_millis,evictor_shutdown_timeout_millis,idle_timeout,heartbeat_period_millis) value ('hostM3','ha_group3','172.100.9.1',3306,'test','111111','false','true','true',10,1000,1,'hostM3',30000,200,'false','false','false','false',1,1,1,1)    | success        | dble_information |


#  @skip_restart
#  Scenario:  test the langreage of update in dble manager  #2
#    Given execute sql in "dble-1" in "admin" mode
#      | conn   | toClose | sql                                                                                                  | expect  | db               |
#      | conn_0 | true    | update dble_db_group set heartbeat_retry=10 where active='true'                                      | success | dble_information |
#      | conn_0 | true    | update dble_db_group set heartbeat_stmt='select user()',heartbeat_timeout=1 where delay_threshold=-1 | success | dble_information |
#      | conn_0 | true    | update dble_db_group set heartbeat_retry=11 where active='true'                                      | success | dble_information |
#      | conn_0 | true    | update dble_db_group set heartbeat_stmt='select @a' where heartbeat_timeout=1 and heartbeat_retry!=1 | success | dble_information |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_2"
#      | conn   | toClose | sql                         | db               |
#      | conn_0 | true    | select * from dble_db_group  | dble_information |
#    Then check resultset "dble_db_group_2" has lines with following column values
#      | name-0    | heartbeat_stmt-1  | heartbeat_timeout-2 | heartbeat_retry-3 | rw_split_mode-4 | delay_threshold-5 | disable_ha-6 | active-7 |
#      | ha_group1 | select user()     | 0                   | 11                | 0               | 100               | false        | true     |
#      | ha_group2 | select user()     | 0                   | 11                | 0               | 100               | false        | true     |
#      | ha_group3 | select 1          | 0                   | 1                 | 0               | 100               | false        | false    |
#      | ha_group5 | show slave status | 0                   | 1                 | 0               | 100               | true         | false    |
#      | ha_group6 | select @a         | 1                   | 2                 | 2               | 10                | true         | false    |
#      | ha_group7 | select user()     | 1                   | 1                 | 1               | -1                | false        | false    |
#      | ha_group8 | select user()     | 1                   | 1                 | 1               | -1                | false        | false    |
#      | ha_group9 | select user()     | 1                   | 1                 | 1               | -1                | false        | false    |
#      | dbGrou-p  | select 1          | 0                   | 1                 | 0               | 100               | false        | false    |
#    Given execute sql in "dble-1" in "admin" mode
#      | conn   | toClose | sql                                                                                                           | expect                                                              | db               |
#      | conn_0 | true    | update dble_db_group,dble_db_instance set heartbeat_retry=10 where active='false';                            | update syntax error, not support update Multiple-Table              | dble_information |
#      | conn_0 | true    | update dble_db_group set heartbeat_retry=10 where (select active from dble_db_group where heartbeat_retry=1); | update syntax error, not support sub-query                          | dble_information |
#      | conn_0 | true    | update dble_db_group set heartbeat=10 where active='false';                                                   | Unknown column 'heartbeat' in 'field list'                          | dble_information |
#      | conn_0 | true    | update dble_db_group set name='ha_group10' where active='false';                                              | Primary column 'name' can not be update, please use delete & insert | dble_information |
#      | conn_0 | true    | update dble_rw_split_entry set username='test' where db_group='db_group1';                                    | Column 'username' is not writable                                   | dble_information |
#      | conn_0 | true    | update dble_db_group set rw_split_mode=null where db_group='db_group1';                                       | Column 'rw_split_mode' cannot be null                               | dble_information |
#      | conn_0 | true    | update LOW_PRIORITY dble_db_group set heartbeat_stmt='select user()' where db_group='db_group1';              | update syntax error, not support update with syntax                 | dble_information |
#      | conn_0 | true    | update IGNORE dble_db_group set heartbeat_stmt='select user()' where db_group='db_group1';                    | update syntax error, not support update with syntax                 | dble_information |
#      | conn_0 | true    | update dble_db_group set heartbeat_stmt='select user()' where db_group='db_group1' order by heartbeat_retry;  | update syntax error, not support update with syntax                 | dble_information |
#      | conn_0 | true    | update dble_db_group set heartbeat_stmt='select user()' where db_group='db_group1' limit 2;                   | update syntax error, not support update with syntax                 | dble_information |
#      | conn_0 | true    | update dble_db_group set heartbeat_stmt='select user()' ;                                                     | update syntax error, not support update without WHERE               | dble_information |
#      | conn_0 | true    | update dble_db_group a set heartbeat_retry=10 where active='true'                                             | update syntax error, not support update with alias                  | dble_information |
#      | conn_0 | true    | update dble_db_group st heartbeat_retry=10 where active='true'                                                | You have an error in your SQL syntax                                | dble_information |
#      | conn_0 | true    | update dble_db_group set active='true' where heartbeat_retry=1                                                | Column 'active' is not writable                                     | dble_information |
#
#
#  Scenario: test the langreage of delete in dble manager #3
#    Given execute sql in "dble-1" in "admin" mode
#      | conn   | toClose | sql                                                                      | expect  | db               |
#      | conn_0 | true   | delete from dble_db_group where name='db_group9';                         | success | dble_information |
#      | conn_0 | true   | delete from dble_db_group where disable_ha='true';                        | success | dble_information |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_2"
#      | conn   | toClose | sql                             | db               |
#      | conn_0 | true    | select * from dble_db_group     | dble_information |
#    Then check resultset "dble_db_group_2" has lines with following column values
#      | name-0    | heartbeat_stmt-1 | heartbeat_timeout-2 | heartbeat_retry-3 | rw_split_mode-4 | delay_threshold-5 | disable_ha-6 | active-7 |
#      | ha_group1 | select user()    | 0                   | 11                | 0               | 100               | false        | true     |
#      | ha_group2 | select user()    | 0                   | 11                | 0               | 100               | false        | true     |
#      | ha_group3 | select 1         | 0                   | 1                 | 0               | 100               | false        | false    |
#      | ha_group7 | select user()    | 1                   | 1                 | 1               | -1                | false        | false    |
#      | ha_group8 | select user()    | 1                   | 1                 | 1               | -1                | false        | false    |
#      | dbGrou-p  | select 1         | 0                   | 1                 | 0               | 100               | false        | false    |
#    Given execute sql in "dble-1" in "admin" mode
#      | conn   | toClose | sql                                                                                         | expect                                                 | db               |
#      | conn_0 | true    | delete from dble_db_group,dble_db_instance where name='db_group9';                          | delete syntax error, not support delete Multiple-Table | dble_information |
#      | conn_0 | true    | delete from dble_db_group where (select active from dble_db_group where heartbeat_retry=1); | delete syntax error, not support sub-query             | dble_information |
#      | conn_0 | true    | delete LOW_PRIORITY from dble_db_group where name='db_group9';                              | delete syntax error, not support delete with syntax    | dble_information |
#      | conn_0 | true    | delete QUICK from dble_db_group where name='db_group9';                                     | delete syntax error, not support delete with syntax    | dble_information |
#      | conn_0 | true    | delete IGNORE from dble_db_group where name='db_group9';                                    | delete syntax error, not support delete with syntax    | dble_information |
#      | conn_0 | true    | delete from dble_db_group where name='db_group9' order by heartbeat_retry;                  | delete syntax error, not support delete with syntax    | dble_information |
#      | conn_0 | true    | delete from dble_db_group where name='db_group9' limit 2;                                   | delete syntax error, not support delete with syntax    | dble_information |
#      | conn_0 | true    | delete from dble_db_grou where name='db_group9';                                            | Table `dble_information`.`dble_db_grou` doesn't exist  | dble_information |
#      | conn_0 | true    | delete from dble_db_group;                                                                  | delete syntax error, not support delete without WHERE  | dble_information |
#      | conn_0 | true    | delete from dble_db_group a where name='db_group9';                                         | delete syntax error, not support delete with alias     | dble_information |
#
#
#
#
#

