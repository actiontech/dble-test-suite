# Copyright (C) 2016-2023 ActionTech.
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
      | conn   | toClose | sql                                                                                                                                                                                                   | expect      | db               | timeout |
      | conn_0 | false   | insert into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group3','select 1',60,1,1,-1,'false')                           | success     | dble_information | 5       |
      | conn_0 | false   | insert into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) values ('ha_group4','select 2',100,1,2,1000,'false')                       | success     | dble_information | 5       |
      | conn_0 | true    | select * from dble_db_group                                                                                                                                                                           | length{(4)} | dble_information | 5       |
    Given Restart dble in "dble-1" success
    ###重启后，新增的dble_db_group没有生效
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
      | conn_0 | false   | insert into DBLE_db_group set name='ha_group11',heartbeat_stmt='select 6',rw_split_mode=3                                                                                                             | success     | dble_information |
      | conn_0 | false   | insert into dble_db_group (name,heartbeat_timeout,heartbeat_stmt,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('ha_group12',100,'select 7',1,3,1000,'false')                        | success     | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_1"
      | conn   | toClose | sql                         | db               |
      | conn_0 | true    | select * from dble_db_group | dble_information |
    Then check resultset "dble_db_group_1" has lines with following column values
      | name-0     | heartbeat_stmt-1   | heartbeat_timeout-2 | heartbeat_retry-3 | heartbeat_keep_alive-4 | rw_split_mode-5 | delay_threshold-6 | delay_period_millis-7 | delay_database-8 | disable_ha-9 | active-10 |
      | ha_group1  | select user()      | 0                   | 1                 | 60                     | 0               | 100               | -1                    | null             | false        | true      |
      | ha_group2  | select user()      | 0                   | 1                 | 60                     | 0               | 100               | -1                    | null             | false        | true      |
      | ha_group3  | select 1           | 60                  | 1                 | 60                     | 1               | -1                | -1                    | null             | false        | false     |
      | ha_group4  | select 2           | 100                 | 1                 | 60                     | 2               | 1000              | -1                    | null             | false        | false     |
      | ha_group5  | show slave status  | 88                  | 1                 | 60                     | 2               | 999               | -1                    | null             | true         | false     |
      | ha_group6  | select @@read_only | 1                   | 2                 | 60                     | 0               | -1                | -1                    | null             | true         | false     |
      | ha_group7  | select 3           | 0                   | 1                 | 60                     | 1               | -1                | -1                    | null             | false        | false     |
      | ha_group8  | select 4           | 0                   | 1                 | 60                     | 2               | -1                | -1                    | null             | false        | false     |
      | ha_group9  | select 5           | 0                   | 1                 | 60                     | 1               | -1                | -1                    | null             | false        | false     |
      | ha_group10 | select user        | 0                   | 1                 | 60                     | 2               | -1                | -1                    | null             | true         | false     |
      | ha_group11 | select 6           | 0                   | 1                 | 60                     | 3               | -1                | -1                    | null             | false        | false     |
      | ha_group12 | select 7           | 100                 | 1                 | 60                     | 3               | 1000              | -1                    | null             | false        | false     |

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                    | expect                                                                                 | db               |
      | conn_0 | false   | insert LOW_PRIORITY into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('dbGroup4','select 1',0,1,1,100,'false')                                | update syntax error, not support insert with syntax                                    | dble_information |
      | conn_0 | false   | insert DELAYED into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('dbGroup4','select 1',0,1,1,100,'false')                                     | update syntax error, not support insert with syntax                                    | dble_information |
      | conn_0 | false   | insert HIGH_PRIORITY into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('dbGroup4','select 1',0,1,1,100,'false')                               | update syntax error, not support insert with syntax                                    | dble_information |
      | conn_0 | false   | insert IGNORE into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('dbGroup4','select 1',0,1,1,100,'false')                                      | update syntax error, not support insert with syntax                                    | dble_information |
      | conn_0 | false   | insert into dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('dbGroup4','select 1',0,1,1,100,'false') ON DUPLICATE KEY UPDATE heartbeat_timeout=1 | update syntax error, not support insert with syntax                                    | dble_information |
      | conn_0 | false   | insert dble_db_group name select name from dble_db_instance                                                                                                                                                            | Insert syntax error,not support insert ... select                                      | dble_information |
      | conn_0 | false   | insert into dble_db_group value ('group1','select 1',-1,1,60,1,100,-1,null,'false','ture')                                                                                                                             | Column 'active' is not writable                                                     | dble_information |
      | conn_0 | false   | insert into dble_db_group values ('group2',100,'select 2',1,2,1000,'false')                                                                                                                                            | Column count doesn't match value count at row 1                                        | dble_information |
      | conn_0 | false   | insert into dble_in.dble_db_group (name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('group3','select 1',0,1,1,100,'false')                                       | Unknown database 'dble_in'                                                             | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group3','select 1',0,1,1,100,'false')                                             | Duplicate entry 'ha_group3' for key 'PRIMARY'                                          | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('ha',1,'s',1,1,100,'false')                                                            | Insert failure.The reason is incorrect integer value: 's'                              | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('ha_group4',null,0,1,1,100,'false')                                                    | Column 'heartbeat_stmt' cannot be null                                                 | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold) value('ha_group4',0,1,1,100)                                                                                           | Field '[heartbeat_stmt]' doesn't have a default value and cannot be null               | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('dbGroup4','select 1',0,1,1,100,'0B01')                                                | Insert failure.The reason is Column 'disable_ha' values only support 'false' or 'true' | dble_information |
      | conn_0 | false   | insert int dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value(('dbGroup4','select 1',0,1,1,100,'false')                                               | You have an error in your SQL syntax                                                   | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='group9',heartbeat_stmt='select 5',rw_split_mode=4                                                                                                                                  | Insert failure.The reason is rwSplitMode should be between 0 and 3!                    | dble_information |
     ## DBLE0REQ-1084
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect                                            | db               |
      | conn_0 | false   | insert into DBLE_db_group set name='group9',heartbeat_stmt='select 5',rw_split_mode=0,delay_threshold=9.9            | Not Supported of Value EXPR :9.9                  | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='group9',heartbeat_stmt='select 5',rw_split_mode=0,heartbeat_timeout=9.9          | Not Supported of Value EXPR :9.9                  | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='group9',heartbeat_stmt='select 5',rw_split_mode=0,heartbeat_retry=9.9            | Not Supported of Value EXPR :9.9                  | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='group9',heartbeat_stmt='select 5',rw_split_mode=0,disable_ha=9.9                 | Not Supported of Value EXPR :9.9                  | dble_information |
      ## DBLE0REQ-1085  name-0
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                  | expect                               | db               |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('null','select 1',0,1,1,100,'false') | Not Supported of Value EXPR :'null'  | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('group1','null',0,1,1,100,'false')  | Not Supported of Value EXPR :'null'  | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('group2',' ',0,1,1,100,'false')     | Not Supported of Value EXPR :' '     | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value (' ',' ',0,1,1,100,'false')          | Not Supported of Value EXPR :' '     | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value('group3',1,' ',1,1,100,'false')      | Not Supported of Value EXPR :' '     | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value (' ',' ',' ',1,1,100,'false')        | Not Supported of Value EXPR :' '     | dble_information |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value (' ',' ',' ',' ',1,100,'false')      | Not Supported of Value EXPR :' '     | dble_information |
    ####name-0
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                              | expect                                 | db               |
      | conn_0 | false   | insert into DBLE_db_group set name=null,heartbeat_stmt='select 5',rw_split_mode=1                                                | Column 'name' cannot be null           | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name=0B01,heartbeat_stmt='select 5',rw_split_mode=1                                                | Not Supported of Value EXPR :0B01      | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name=1.3,heartbeat_stmt='select 5',rw_split_mode=1                                                 | Not Supported of Value EXPR :1.3       | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0101',heartbeat_stmt=null,rw_split_mode=1                                                    | Column 'heartbeat_stmt' cannot be null | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0201',heartbeat_stmt=0B01,rw_split_mode=1                                                    | Not Supported of Value EXPR :0B01      | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0401',heartbeat_stmt=1.3,rw_split_mode=1                                                     | Not Supported of Value EXPR :1.3       | dble_information |
    ####rw_split_mode-5
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                              | expect                                                                | db               |
      | conn_0 | false   | insert into DBLE_db_group set name='0B01',heartbeat_stmt='select 5',rw_split_mode=null                                           | Column 'rw_split_mode' cannot be null                                 | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B01',heartbeat_stmt='select 5',rw_split_mode='null'                                         | Not Supported of Value EXPR :'null'                                   | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B01',heartbeat_stmt='select 5',rw_split_mode=0B01                                           | Not Supported of Value EXPR :0B01                                     | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B01',heartbeat_stmt='select 5',rw_split_mode='0B01'                                         | Insert failure.The reason is incorrect integer value: '0B01'          | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B01',heartbeat_stmt='select 5',rw_split_mode=-1                                             | Insert failure.The reason is rwSplitMode should be between 0 and 3    | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B01',heartbeat_stmt='select 5',rw_split_mode=1.3                                            | Not Supported of Value EXPR :1.3                                      | dble_information |
    ####heartbeat_timeout-2
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                              | expect                                                                                                 | db               |
      | conn_0 | false   | insert into DBLE_db_group set name='0B00',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_timeout=' '                        | Not Supported of Value EXPR :' '                                                                       | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B01',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_timeout='null'                     | Not Supported of Value EXPR :'null'                                                                    | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B03',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_timeout=0B01                       | Not Supported of Value EXPR :0B01                                                                      | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B04',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_timeout='0B01'                     | Insert failure.The reason is incorrect integer value: '0B01'                                                | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B05',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_timeout=-1                         | Insert failure.The reason is Column 'heartbeat_timeout' should be an integer greater than or equal to 0!    | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B06',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_timeout=1.5                        | Not Supported of Value EXPR :1.5                                                                       | dble_information |
    ###heartbeat_retry-3
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                            | expect                                                                                              | db               |
      | conn_0 | false   | insert into DBLE_db_group set name='0B00',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_retry=' '                        | Not Supported of Value EXPR :' '                                                                    | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B01',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_retry='null'                     | Not Supported of Value EXPR :'null'                                                                 | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B03',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_retry=0B01                       | Not Supported of Value EXPR :0B01                                                                   | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B04',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_retry='0B01'                     | Insert failure.The reason is incorrect integer value: '0B01'                                        | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B25',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_retry=-1                         | Insert failure.The reason is Column 'heartbeat_retry' should be an integer greater than or equal to 0!   | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B06',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_retry=1.5                        | Not Supported of Value EXPR :1.5                                                                         | dble_information |
    ####delay_threshold-6
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                            | expect                                                                                                | db               |
      | conn_0 | false   | insert into DBLE_db_group set name='0B00',heartbeat_stmt='select 5',rw_split_mode=1,delay_threshold=' '                        | Not Supported of Value EXPR :' '                                                                      | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B01',heartbeat_stmt='select 5',rw_split_mode=1,delay_threshold='null'                     | Not Supported of Value EXPR :'null'                                                                   | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B03',heartbeat_stmt='select 5',rw_split_mode=1,delay_threshold=0B01                       | Not Supported of Value EXPR :0B01                                                                     | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B04',heartbeat_stmt='select 5',rw_split_mode=1,delay_threshold='0B01'                     | Insert failure.The reason is incorrect integer value: '0B01'                                          | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B07',heartbeat_stmt='select 5',rw_split_mode=1,delay_threshold=-2                         | Insert failure.The reason is Column 'delay_threshold' should be an integer greater than or equal to -1!    | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B06',heartbeat_stmt='select 5',rw_split_mode=1,delay_threshold=1.5                        | Not Supported of Value EXPR :1.5                                                                           | dble_information |
    ####disable_ha-9
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                       | expect                                                                                         | db               |
      | conn_0 | false   | insert into DBLE_db_group set name='0B00',heartbeat_stmt='select 5',rw_split_mode=1,disable_ha=' '                        | Not Supported of Value EXPR :' '                                                               | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B01',heartbeat_stmt='select 5',rw_split_mode=1,disable_ha='null'                     | Not Supported of Value EXPR :'null'                                                            | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B03',heartbeat_stmt='select 5',rw_split_mode=1,disable_ha=0B01                       | Not Supported of Value EXPR :0B01                                                              | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B04',heartbeat_stmt='select 5',rw_split_mode=1,disable_ha='0B01'                     | Insert failure.The reason is Column 'disable_ha' values only support 'false' or 'true'         | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='1B05',heartbeat_stmt='select 5',rw_split_mode=1,disable_ha=-1                         | Insert failure.The reason is Column 'disable_ha' values only support 'false' or 'true'         | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B06',heartbeat_stmt='select 5',rw_split_mode=1,disable_ha=1.5                        | Not Supported of Value EXPR :1.5                                                               | dble_information |
   ###### delay_period_millis-7
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                | expect                                                                                         | db               |
      | conn_0 | false   | insert into DBLE_db_group set name='0B00',heartbeat_stmt='select 5',rw_split_mode=1,delay_period_millis=' '                        | Not Supported of Value EXPR :' '                                                               | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B01',heartbeat_stmt='select 5',rw_split_mode=1,delay_period_millis='null'                     | Not Supported of Value EXPR :'null'                                                            | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B03',heartbeat_stmt='select 5',rw_split_mode=1,delay_period_millis=0B01                       | Not Supported of Value EXPR :0B01                                                              | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B04',heartbeat_stmt='select 5',rw_split_mode=1,delay_period_millis='0B01'                     | Insert failure.The reason is incorrect integer value: '0B01'                                   | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='1B05',heartbeat_stmt='select 5',rw_split_mode=1,delay_period_millis=-2                         | Insert failure.The reason is Column 'delay_threshold' should be an integer greater than -1     | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B06',heartbeat_stmt='select 5',rw_split_mode=1,delay_period_millis=1.5                        | Not Supported of Value EXPR :1.5                                                               | dble_information |
   ###### delay_database-8
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                           | expect                                                                                         | db               |
      | conn_0 | false   | insert into DBLE_db_group set name='0B00',heartbeat_stmt='select 5',rw_split_mode=1,delay_database=' '                        | Not Supported of Value EXPR :' '                                                               | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B00',heartbeat_stmt='select 5',rw_split_mode=1,delay_database='null'                     | Not Supported of Value EXPR :'null'                                                            | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B03',heartbeat_stmt='select 5',rw_split_mode=1,delay_database=0B01                       | Not Supported of Value EXPR :0B01                                                              | dble_information |
      | conn_0 | false   | insert into DBLE_db_group set name='0B06',heartbeat_stmt='select 5',rw_split_mode=1,delay_database=1.5                        | Not Supported of Value EXPR :1.5                                                               | dble_information |



    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
#    Given sleep "2" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble_admin_query.log" in host "dble-1" retry "5,2" times
      """
      {\"dbGroup\":\[
      {\"rwSplitMode\":0,\"name\":\"ha_group1\",\"delayThreshold\":100,\"heartbeat\":{\"value\":\"select user\(\)\"},
      \"dbInstance\":\[{\"name\":\"hostM1\",\"url\":\"172.100.9.5:3306\",\"password\":\"111111\",\"user\":\"test\",\"maxCon\":1000,\"minCon\":10,\"primary\":true}\]},
      {\"rwSplitMode\":0,\"name\":\"ha_group2\",\"delayThreshold\":100,\"heartbeat\":{\"value\":\"select user\(\)\"},
      \"dbInstance\":\[{\"name\":\"hostM2\",\"url\":\"172.100.9.6:3306\",\"password\":\"111111\",\"user\":\"test\",\"maxCon\":1000,\"minCon\":10,\"primary\":true}\]
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble_admin_query.log" in host "dble-1"
      """
      \"name\":\"ha_group3\"
      \"name\":\"ha_group4\"
      \"name\":\"ha_group5\"
      \"name\":\"ha_group6\"
      \"name\":\"ha_group7\"
      \"name\":\"ha_group8\"
      \"name\":\"ha_group9\"
      \"name\":\"ha_group10\"
      \"name\":\"ha_group11\"
      \"name\":\"ha_group12\"
      """

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                        | expect             | db               |
      | conn_5 | false   | insert into DBLE_db_group set name='0B02',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_timeout=null | success            | dble_information |
      | conn_5 | false   | insert into DBLE_db_group set name='0B03',heartbeat_stmt='select 5',rw_split_mode=1,heartbeat_retry=null   | success            | dble_information |
      | conn_5 | false   | insert into DBLE_db_group set name='0B04',heartbeat_stmt='select 5',rw_split_mode=1,delay_threshold=null   | success            | dble_information |
      | conn_5 | false   | insert into DBLE_db_group set name='0B05',heartbeat_stmt='select 5',rw_split_mode=1,disable_ha=null        | success            | dble_information |
      | conn_5 | false   | select heartbeat_timeout from DBLE_db_group where name ='0B02'                                             | has{((0,),)}       | dble_information |
      | conn_5 | false   | select heartbeat_retry from DBLE_db_group where name ='0B03'                                               | has{((1,),)}       | dble_information |
      | conn_5 | false   | select delay_threshold from DBLE_db_group where name ='0B04'                                               | has{((-1,),)}      | dble_information |
      | conn_5 | true    | select disable_ha from DBLE_db_group where name ='0B05'                                                    | has{(('false',),)} | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      """



  @skip_restart
  Scenario: test the langreage of insert in dble manager   ---- dble_db_instance  #2
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                       | expect      | db               |
      | conn_0 | false   | select * from dble_db_instance                                            | length{(2)} | dble_information |
      | conn_0 | false   | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,disabled,min_conn_count,max_conn_count,read_weight,id,connection_timeout,connection_heartbeat_timeout,test_on_create,test_on_borrow,test_on_return,test_while_idle,time_between_eviction_runs_millis,evictor_shutdown_timeout_millis,idle_timeout,heartbeat_period_millis) value ('hostM3','ha_group3','172.100.9.6',3306,'test','111111','false','true','true',10,1000,1,'hostM3',30000,200,'false','false','false','false',1,1,1,1)                     | success   | dble_information |
      | conn_0 | false   | insert into dble_information.dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,disabled,min_conn_count,max_conn_count,read_weight,id,connection_timeout,connection_heartbeat_timeout,test_on_create,test_on_borrow,test_on_return,test_while_idle,time_between_eviction_runs_millis,evictor_shutdown_timeout_millis,idle_timeout,heartbeat_period_millis) value ('hostS31','ha_group3','172.100.9.6',3307,'test','111111','false','false','false',1,10,2,'hostS31',3,1,'true','true','true','true',2,2,2,2)             | success   | dble_information |
      | conn_0 | false   | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,disabled,min_conn_count,max_conn_count,read_weight,id,connection_timeout,connection_heartbeat_timeout,test_on_create,test_on_borrow,test_on_return,test_while_idle,time_between_eviction_runs_millis,evictor_shutdown_timeout_millis,idle_timeout,heartbeat_period_millis) value ('hostS32','ha_group3','172.100.9.6',3308,'test','111111','false','false','true',2,99,3,'hostS32',5,2,'false','false','false','false',1,1,1,1)                           | success   | dble_information |

      | conn_0 | false    | insert into DBLE_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostM4','ha_group4','172.100.9.6',3307,'test','111111','false','true',1,99)                         | success        | dble_information |
      | conn_0 | false    | insert into DBLE_db_instance (NAME,db_group,addr,port,USER,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostM5','ha_group5','172.100.9.6',3306,'test','111111','false','true',1,99)                         | success        | dble_information |
      | conn_0 | false    | insert into DBLE_db_instance (NAME,db_group,addr,port,USER,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) values ('hostS51','ha_group5','172.100.9.6',3307,'test','111111','false','false',0,99)                      | success        | dble_information |
      | conn_0 | false    | insert into DBLE_db_instance (NAME,db_group,addr,port,USER,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,read_weight) values ('hostS52','ha_group5','172.100.9.6',3308,'test','111111','false','false',0,99,3)        | success        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM6',db_group='ha_group6',addr='172.100.9.4',port=3306,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=4,max_conn_count=9                              | success        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM7',db_group='ha_group7',addr='172.100.9.5',port=3306,user='test',password_encrypt='UHH6o0jOcaXRYzvyQrUN/P5avdmyoxpHO8B54y7+RkiIC73G1qgFr5X+mewtlC6p/v7Gc/NXD7sPDFB/kPM5aA==',encrypt_configured='true',`primary`='true',min_conn_count=4,max_conn_count=9,id='hostM7'                  | success        | dble_information |
      | conn_0 | false    | insert into DBLE_db_instance (NAME,db_group,addr,port,password_encrypt,USER,encrypt_configured,primary,max_conn_count,min_conn_count) value ('hostM12','ha_group12','172.100.9.1','3306','111111','test','false','true','100','9')                | success        | dble_information |

#    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_1"
      | conn   | toClose | sql                            | db               |
      | conn_0 | true    | select name,db_group,addr,port,user,encrypt_configured,primary,disabled,min_conn_count,max_conn_count,read_weight,id from dble_db_instance            | dble_information |
    Then check resultset "dble_db_instance_1" has lines with following column values
      | name-0  | db_group-1 | addr-2      | port-3 | user-4 | encrypt_configured-5 | primary-6 | disabled-7 | min_conn_count-8 | max_conn_count-9 | read_weight-10 | id-11   |
      | hostM1  | ha_group1  | 172.100.9.5 | 3306   | test   | false                | true      | false      | 10               | 1000             | 0              | hostM1  |
      | hostM2  | ha_group2  | 172.100.9.6 | 3306   | test   | false                | true      | false      | 10               | 1000             | 0              | hostM2  |
      | hostM3  | ha_group3  | 172.100.9.6 | 3306   | test   | false                | true      | true       | 10               | 1000             | 1              | hostM3  |
      | hostS31 | ha_group3  | 172.100.9.6 | 3307   | test   | false                | false     | false      | 1                | 10               | 2              | hostS31 |
      | hostS32 | ha_group3  | 172.100.9.6 | 3308   | test   | false                | false     | true       | 2                | 99               | 3              | hostS32 |
      | hostM4  | ha_group4  | 172.100.9.6 | 3307   | test   | false                | true      | false      | 1                | 99               | 0              | hostM4  |
      | hostS52 | ha_group5  | 172.100.9.6 | 3308   | test   | false                | false     | false      | 0                | 99               | 3              | hostS52 |
      | hostM5  | ha_group5  | 172.100.9.6 | 3306   | test   | false                | true      | false      | 1                | 99               | 0              | hostM5  |
      | hostS51 | ha_group5  | 172.100.9.6 | 3307   | test   | false                | false     | false      | 0                | 99               | 0              | hostS51 |
      | hostM6  | ha_group6  | 172.100.9.4 | 3306   | test   | false                | true      | false      | 4                | 9                | 0              | hostM6  |
      | hostM7  | ha_group7  | 172.100.9.5 | 3306   | test   | true                 | true      | false      | 4                | 9                | 0              | hostM7  |
      | hostM12 | ha_group12 | 172.100.9.1 | 3306   | test   | false                | true      | false      | 9                | 100              | 0              | hostM12 |


    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_2"
      | conn   | toClose | sql                            | db               |
      | conn_0 | true    | select connection_timeout,connection_heartbeat_timeout,test_on_create,test_on_borrow,test_on_return,test_while_idle,time_between_eviction_runs_millis,evictor_shutdown_timeout_millis,idle_timeout,heartbeat_period_millis from dble_db_instance     | dble_information |
    Then check resultset "dble_db_instance_2" has lines with following column values
      | connection_timeout-0 | connection_heartbeat_timeout-1 | test_on_create-2 | test_on_borrow-3 | test_on_return-4 | test_while_idle-5 | time_between_eviction_runs_millis-6 | evictor_shutdown_timeout_millis-7 | idle_timeout-8 | heartbeat_period_millis-9 |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 200                            | false            | false            | false            | false             | 1                                   | 1                                 | 1              | 1                         |
      | 3                    | 1                              | true             | true             | true             | true              | 2                                   | 2                                 | 2              | 2                         |
      | 5                    | 2                              | false            | false            | false            | false             | 1                                   | 1                                 | 1              | 1                         |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_3"
      | conn   | toClose | sql                            | db               |
      | conn_0 | true    | select active_conn_count,idle_conn_count,read_conn_request,write_conn_request,last_heartbeat_ack,heartbeat_failure_in_last_5min from dble_db_instance       | dble_information |
    Then check resultset "dble_db_instance_3" has lines with following column values
      | active_conn_count-0 | idle_conn_count-1 | read_conn_request-2 | write_conn_request-3 | last_heartbeat_ack-4 | heartbeat_failure_in_last_5min-5 |
      | 0                   | 10                | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 10                | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | init                 | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | init                 | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |

    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |

    Then check following text exist "Y" in file "/opt/dble/logs/dble_admin_query.log" in host "dble-1" retry "5,2" times
      """
      rwSplitMode\":0.*ha_group1.*name\":\"hostM1\",\"url\":\"172.100.9.5:3306
      rwSplitMode\":0.*ha_group2.*name\":\"hostM2\",\"url\":\"172.100.9.6:3306
      rwSplitMode\":1.*ha_group3.*name\":\"hostM3\",\"url\":\"172.100.9.6:3306.*name\":\"hostS31\",\"url\":\"172.100.9.6:3307.*name\":\"hostS32\",\"url\":\"172.100.9.6:3308
      rwSplitMode\":2.*ha_group4.*name\":\"hostM4\",\"url\":\"172.100.9.6:3307
      rwSplitMode\":2.*ha_group5.*name\":\"hostM5\",\"url\":\"172.100.9.6:3306.*name\":\"hostS51\",\"url\":\"172.100.9.6:3307.*name\":\"hostS52\",\"url\":\"172.100.9.6:3308
      rwSplitMode\":0.*ha_group6.*name\":\"hostM6\",\"url\":\"172.100.9.4:3306
      rwSplitMode\":1.*ha_group7.*name\":\"hostM7\",\"url\":\"172.100.9.5:3306
      rwSplitMode\":3.*ha_group12.*\"name\":\"hostM12\",\"url\":\"172.100.9.1:3306
      """


    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert LOW_PRIORITY into DBLE_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('host1','group1','172.100.9.5',3307,'test','111111','false','true',1,99)                        | update syntax error, not support insert with syntax        | dble_information |
      | conn_0 | false    | insert DELAYED into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('host1','group1','172.100.9.5',3307,'test','111111','false','true',1,99)                             | update syntax error, not support insert with syntax        | dble_information |
      | conn_0 | false    | insert HIGH_PRIORITY into DBLE_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('host1','group1','172.100.9.5',3307,'test','111111','false','true',1,99)                       | update syntax error, not support insert with syntax        | dble_information |
      | conn_0 | false    | insert IGNORE into DBLE_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('host1','group1','172.100.9.5',3307,'test','111111','false','true',1,99)                              | update syntax error, not support insert with syntax        | dble_information |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('host1','group1','172.100.9.5',3307,'test','111111','false','true',1,99) ON DUPLICATE KEY UPDATE port=3308   | update syntax error, not support insert with syntax        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM6',db_group='ha_group6',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',primary='true',min_conn_count=4,max_conn_count=9                                        | You have an error in your SQL syntax                       | dble_information |
      | conn_0 | false    | insert dble_db_instance name select name from dble_db_instance                                                                                                                                                                                            | Insert syntax error,not support insert ... select          | dble_information |
      # DBLE0REQ-1100
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,active_conn_count) value ('host10','ha_group10','172.100.9.5',3307,'test','111111','false','true',1,99,0)            | Column 'active_conn_count' is not writable       | dble_information |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,active_conn_count) value ('host10','ha_group10','172.100.9.5',3307,'test','111111','false','true',1,99,1)            | Column 'active_conn_count' is not writable       | dble_information |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,idle_conn_count) value ('host9','ha_group9','172.100.9.5',3307,'test','111111','false','true',1,99,1)                | Column 'idle_conn_count' is not writable         | dble_information |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,read_conn_request) value ('host8','ha_group8','172.100.9.5',3307,'test','111111','false','true',1,99,1)              | Column 'read_conn_request' is not writable       | dble_information |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,write_conn_request) value ('host9','ha_group9','172.100.9.5',3307,'test','111111','false','true',1,99,1)             | Column 'write_conn_request' is not writable      | dble_information |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,write_conn_request) value ('host10','ha_group10','172.100.9.5',3307,'test','111111','false','true',1,99,1)           | Column 'write_conn_request' is not writable      | dble_information |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,last_heartbeat_ack_timestamp) value ('host9','ha_group9','172.100.9.5',3307,'test','111111','false','true',1,99,1)                  | Column 'last_heartbeat_ack_timestamp' is not writable       | dble_information |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,last_heartbeat_ack) value ('host9','ha_group9','172.100.9.5',3307,'test','111111','false','true',1,99,'ok')                         | Column 'last_heartbeat_ack' is not writable                 | dble_information |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,heartbeat_status) value ('host9','ha_group9','172.100.9.5',3307,'test','111111','false','true',1,99,'ok')                           | Column 'heartbeat_status' is not writable                   | dble_information |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,heartbeat_failure_in_last_5min) value ('host9','ha_group9','172.100.9.5',3307,'test','111111','false','true',1,99,0)                | Column 'heartbeat_failure_in_last_5min' is not writable     | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count) value ('host9','ha_group9','172.100.9.5',3307,'test','111111','false','true',1)                                                    | Field '[max_conn_count]' doesn't have a default value and cannot be null                      | dble_information |
      | conn_0 | false    | insert into dble_in.dble_db_instance set name='hostM6',db_group='ha_group6',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=4,max_conn_count=9                              | Unknown database 'dble_in'                                            | dble_information |
      | conn_0 | false    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,active_conn_count) value ('host1','group1','172.100.9.5',3307,'test','111111','false','true',1,99,0)                 | Column 'active_conn_count' is not writable                            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM6',db_group='ha_group6',addr='172.100.9.8',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=4,max_conn_count=9                                      | Duplicate entry 'hostM6-ha_group6' for key 'PRIMARY'                  | dble_information |
      | conn_0 | false    | insert into DBLE_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostS4','ha_group4','172.100.9.5',3307,'test','111111','false','true',1,99)                                 | Insert failure.The reason is dbGroup[ha_group4] has multi primary instance        | dble_information |
      | conn_0 | false    | insert into DBLE_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostS4','ha_group4','172.100.9.2',3307,'test','111111','false','true',1,99)                                 | Insert failure.The reason is dbGroup[ha_group4] has multi primary instance        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM8',db_group='ha_group8',addr='172.100.9.14',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9                                     | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group8.hostM8]}    | dble_information |
      #DBLE0REQ-1101
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=-1,max_conn_count=9.9                                   | Not Supported of Value EXPR :9.9                                                                          | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=-9                                     | Insert failure.The reason is Column 'max_conn_count' value cannot be less than 0                          | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=0,max_conn_count=9.9                                    | Not Supported of Value EXPR :9.9                                                                          | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr=1,port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9                                                  | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group9.hostM9]}    | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt=' ',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9                                           | Not Supported of Value EXPR :' '                                                                          | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured=' ',`primary`='true',min_conn_count=1,max_conn_count=9                                          | Not Supported of Value EXPR :' '                                                                          | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`=' ',min_conn_count=1,max_conn_count=9                                         | Not Supported of Value EXPR :' '                                                                          | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=' ',max_conn_count=9                                    | Not Supported of Value EXPR :' '                                                                          | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=' '                                    | Not Supported of Value EXPR :' '                                                                          | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='0',`primary`='true',min_conn_count=1,max_conn_count=9                                          | The reason is Column 'encrypt_configured' values only support 'false' or 'true'                           | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='1',min_conn_count=1,max_conn_count=9                                         | The reason is Column 'primary' values only support 'false' or 'true'                                      | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=33.8,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9                                      | Not Supported of Value EXPR :33.8                                                                         | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3308,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9                                      | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group9.hostM9]}    | dble_information |
       ####   name
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false   | insert into dble_db_instance set name=null,db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9          | Column 'name' cannot be null                 | dble_information |
      | conn_0 | false   | insert into dble_db_instance set name='null',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9        | Not Supported of Value EXPR :'null'          | dble_information |
      | conn_0 | false   | insert into dble_db_instance set name=0B01,db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9          | Not Supported of Value EXPR :0B01            | dble_information |
      | conn_0 | false   | insert into dble_db_instance set name=' ',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9           | Not Supported of Value EXPR :' '             | dble_information |
       ####   db_group
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='a',db_group='ha_group0',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9           | Cannot add or update a child row: a logical foreign key 'db_group':ha_group0 constraint fails                 | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='b',db_group=-1,addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9                    | Cannot add or update a child row: a logical foreign key 'db_group':-1 constraint fails                        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='null',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9           | Not Supported of Value EXPR :'null'         | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group=null,addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9             | Column 'db_group' cannot be null            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group=' ',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9              | Not Supported of Value EXPR :' '            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='c',db_group=1.3,addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9                   | Not Supported of Value EXPR :1.3            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='c',db_group=0B01,addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9                  | Not Supported of Value EXPR :0B01           | dble_information |
       ####   addr
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr=' ',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9                | Not Supported of Value EXPR :' '            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr=null,port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9               | Column 'addr' cannot be null                | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='null',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9             | Not Supported of Value EXPR :'null'         | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr=1.3,port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9                | Not Supported of Value EXPR :1.3            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr=0B01,port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9               | Not Supported of Value EXPR :0B01           | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='0B01',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9             | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group9.hostM9]}         | dble_information |
       ####   port
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=null,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9          | Column 'port' cannot be null                                          | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM8',db_group='ha_group8',addr='172.100.9.8',port='s',user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=4,max_conn_count=9           | java.lang.NumberFormatException: For input string: "s"                | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM8',db_group='ha_group8',addr='172.100.9.8',port=s,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=4,max_conn_count=9             | Not Supported of Value EXPR :s                                        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port='null',user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9        | Not Supported of Value EXPR :'null                                    | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port='0B01',user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9        | java.lang.NumberFormatException: For input string: "0B01"             | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=-1,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9            | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group9.hostM9]}  | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=1.3,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9           | Not Supported of Value EXPR :1.3                                       | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=8066,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9          | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group9.hostM9]}  | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=9066,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9          | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group9.hostM9]}  | dble_information |
       ####   user
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user=null,password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9         | Column 'user' cannot be null                       | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='null',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9       | Not Supported of Value EXPR :'null'                | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user=-1,password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9           | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group9.hostM9]} | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user=1.3,password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9          | Not Supported of Value EXPR :1.3                   | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user=' ',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9          | Not Supported of Value EXPR :' '                   | dble_information |
       ####   password_encrypt
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt=null,encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9           | Column 'password_encrypt' cannot be null    | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='null',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9         | Not Supported of Value EXPR :'null'         | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt=1.3,encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9            | Not Supported of Value EXPR :1.3            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt=-1,encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9             |  there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group9.hostM9]}   | dble_information |
       ####   encrypt_configured
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured=null,`primary`='true',min_conn_count=1,max_conn_count=9       | user test password need to decrypt, but failed                                                    | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='null',`primary`='true',min_conn_count=1,max_conn_count=9     | Not Supported of Value EXPR :'null'                                                               | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured=-1,`primary`='true',min_conn_count=1,max_conn_count=9         | Insert failure.The reason is Column 'encrypt_configured' values only support 'false' or 'true'    | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured=0B01,`primary`='true',min_conn_count=1,max_conn_count=9       | Not Supported of Value EXPR :0B01                                                                 | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='0B01',`primary`='true',min_conn_count=1,max_conn_count=9     | Insert failure.The reason is Column 'encrypt_configured' values only support 'false' or 'true'    | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured=' ',`primary`='true',min_conn_count=1,max_conn_count=9        | Not Supported of Value EXPR :' '                                                                  | dble_information |
       ####   primary
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`=null,min_conn_count=1,max_conn_count=9       | Column 'primary' cannot be null             | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='null',min_conn_count=1,max_conn_count=9     | Not Supported of Value EXPR :'null'         | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`=-1,min_conn_count=1,max_conn_count=9         | Insert failure.The reason is Column 'primary' values only support 'false' or 'true'             | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`=1.3,min_conn_count=1,max_conn_count=9        | Not Supported of Value EXPR :1.3            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`=0B01,min_conn_count=1,max_conn_count=9       | Not Supported of Value EXPR :0B01           | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='0B01',min_conn_count=1,max_conn_count=9     | Insert failure.The reason is Column 'primary' values only support 'false' or 'true'             | dble_information |
       ####   min_conn_count
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=null,max_conn_count=9        | Column 'min_conn_count' cannot be null      | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count='null',max_conn_count=9      | Not Supported of Value EXPR :'null'         | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=' ',max_conn_count=9         | Not Supported of Value EXPR :' '            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=-1,max_conn_count=9          | Insert failure.The reason is Column 'min_conn_count' value cannot be less than 0      | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1.3,max_conn_count=9         | Not Supported of Value EXPR :1.3            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=0B01,max_conn_count=9        | Not Supported of Value EXPR :0B01           | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count='0B01',max_conn_count=9      | Insert failure.The reason is incorrect integer value: '0B01'                          | dble_information |
       ####   max_conn_count
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=null        | Column 'max_conn_count' cannot be null      | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count='null'      | Not Supported of Value EXPR :'null'         | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=0B01        | Not Supported of Value EXPR :0B01           | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count='0B01'      | Insert failure.The reason is incorrect integer value: '0B01'                       | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=-1          | Insert failure.The reason is Column 'max_conn_count' value cannot be less than 0   | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=1.3         | Not Supported of Value EXPR :1.3            | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,disabled='1'                       | Insert failure.The reason is Column 'disabled' values only support 'false' or 'true'      | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,disabled='null'                    | Not Supported of Value EXPR :'null'                                                       | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,disabled=' '                       | Not Supported of Value EXPR :' '                                                          | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,read_weight='null'                 | Not Supported of Value EXPR :'null'                                   | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,read_weight=' '                    | Not Supported of Value EXPR :' '                                      | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,read_weight='0B01'                 | java.lang.NumberFormatException: For input string: "0B01"             | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,read_weight=0B01                   | Not Supported of Value EXPR :0B01                                     | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,read_weight=-1                     | readWeight attribute in dbInstance[hostM9] can't be less than 0!      | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,read_weight=1.3                    | Not Supported of Value EXPR :1.3                                      | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,id='null'                 | Not Supported of Value EXPR :'null'            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,id=' '                    | Not Supported of Value EXPR :' '               | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,id=0B01                   | Not Supported of Value EXPR :0B01                                     | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,id=1.3                    | Not Supported of Value EXPR :1.3                                     | dble_information |
      ####  db.xml  property values check  ####  DBLE0REQ-1212
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_timeout='null'                 | Not Supported of Value EXPR :'null'             | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_timeout=' '                    | Not Supported of Value EXPR :' '                | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_timeout='0B01'                 | property [ connectionTimeout ] '0B01' data type should be long               | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_timeout=0B01                   | Not Supported of Value EXPR :0B01                                            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_timeout=-1                     | property [ connectionTimeout ] '-1' should be an integer greater than 0!     | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_timeout=0                      | property [ connectionTimeout ] '0' should be an integer greater than 0!      | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_timeout=1.3                    | Not Supported of Value EXPR :1.3                                     | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_timeout='abcd'                 | property [ connectionTimeout ] 'abcd' data type should be long       | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_heartbeat_timeout='null'                 | Not Supported of Value EXPR :'null'          | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_heartbeat_timeout=' '                    | Not Supported of Value EXPR :' '             | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_heartbeat_timeout='0B01'                 | property [ connectionHeartbeatTimeout ] '0B01' data type should be long               | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_heartbeat_timeout=0B01                   | Not Supported of Value EXPR :0B01                                                     | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_heartbeat_timeout=-1                     | property [ connectionHeartbeatTimeout ] '-1' should be an integer greater than 0      | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_heartbeat_timeout=0                      | property [ connectionHeartbeatTimeout ] '0' should be an integer greater than 0       | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_heartbeat_timeout=1.3                    | Not Supported of Value EXPR :1.3                                              | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_heartbeat_timeout='abcd'                 | property [ connectionHeartbeatTimeout ] 'abcd' data type should be long       | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,time_between_eviction_runs_millis='null'                  | Not Supported of Value EXPR :'null'            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,time_between_eviction_runs_millis=' '                     | Not Supported of Value EXPR :' '               | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,time_between_eviction_runs_millis='0B01'                  | property [ timeBetweenEvictionRunsMillis ] '0B01' data type should be long                | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,time_between_eviction_runs_millis=0B01                    | Not Supported of Value EXPR :0B01                                                         | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,time_between_eviction_runs_millis=-1                      | property [ timeBetweenEvictionRunsMillis ] '-1' should be an integer greater than 0       | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,time_between_eviction_runs_millis=0                       | property [ timeBetweenEvictionRunsMillis ] '0' should be an integer greater than 0        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,time_between_eviction_runs_millis=1.3                     | Not Supported of Value EXPR :1.3                                                 | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,time_between_eviction_runs_millis='abvd'                  | property [ timeBetweenEvictionRunsMillis ] 'abvd' data type should be long       | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,evictor_shutdown_timeout_millis='null'                 | Not Supported of Value EXPR :'null'            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,evictor_shutdown_timeout_millis=' '                    | Not Supported of Value EXPR :' '               | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,evictor_shutdown_timeout_millis='0B01'                 | property [ evictorShutdownTimeoutMillis ] '0B01' data type should be long                | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,evictor_shutdown_timeout_millis=0B01                   | Not Supported of Value EXPR :0B01                                                        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,evictor_shutdown_timeout_millis=-1                     | property [ evictorShutdownTimeoutMillis ] '-1' should be an integer greater than 0       | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,evictor_shutdown_timeout_millis=0                      | property [ evictorShutdownTimeoutMillis ] '0' should be an integer greater than 0        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,evictor_shutdown_timeout_millis=1.3                    | Not Supported of Value EXPR :1.3                                                | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,evictor_shutdown_timeout_millis='abcd'                 | property [ evictorShutdownTimeoutMillis ] 'abcd' data type should be long               | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,idle_timeout='null'                 | Not Supported of Value EXPR :'null'             | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,idle_timeout=' '                    | Not Supported of Value EXPR :' '                | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,idle_timeout='0B01'                 | property [ idleTimeout ] '0B01' data type should be long             | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,idle_timeout=0B01                   | Not Supported of Value EXPR :0B01                                    | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,idle_timeout=-1                     | property [ idleTimeout ] '-1' should be an integer greater than 0           | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,idle_timeout=0                      | property [ idleTimeout ] '0' should be an integer greater than 0            | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,idle_timeout=1.3                    | Not Supported of Value EXPR :1.3                                     | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,idle_timeout='abcd'                 | property [ idleTimeout ] 'abcd' data type should be long             | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,heartbeat_period_millis='null'                 | Not Supported of Value EXPR :'null'             | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,heartbeat_period_millis=' '                    | Not Supported of Value EXPR :' '                | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,heartbeat_period_millis='0B01'                 | property [ heartbeatPeriodMillis ] '0B01' data type should be long    | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,heartbeat_period_millis=0B01                   | Not Supported of Value EXPR :0B01                                     | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,heartbeat_period_millis=-1                     | property [ heartbeatPeriodMillis ] '-1' should be an integer greater than 0   | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,heartbeat_period_millis=0                      | property [ heartbeatPeriodMillis ] '0' should be an integer greater than 0    | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,heartbeat_period_millis=1.3                    | Not Supported of Value EXPR :1.3                                      | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,heartbeat_period_millis='abcd'                 | property [ heartbeatPeriodMillis ] 'abcd' data type should be long    | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_create='null'                 | Not Supported of Value EXPR :'null'                                                                     | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_create=' '                    | Not Supported of Value EXPR :' '                                                                        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_create='0B01'                 | Insert failure.The reason is Column 'test_on_create' values only support 'false' or 'true'              | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_create=0B01                   | Not Supported of Value EXPR :0B01                                                                       | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_create=-1                     | Insert failure.The reason is Column 'test_on_create' values only support 'false' or 'true'.             | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_create=1.3                    | Not Supported of Value EXPR :1.3                                                                        | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_borrow='null'                 | Not Supported of Value EXPR :'null'                                                                     | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_borrow=' '                    | Not Supported of Value EXPR :' '                                                                        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_borrow='0B01'                 | Insert failure.The reason is Column 'test_on_borrow' values only support 'false' or 'true'              | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_borrow=0B01                   | Not Supported of Value EXPR :0B01                                                                       | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_borrow=-1                     | Insert failure.The reason is Column 'test_on_borrow' values only support 'false' or 'true'.             | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_borrow=1.3                    | Not Supported of Value EXPR :1.3                                                                        | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_return='null'                 | Not Supported of Value EXPR :'null'                                                                     | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_return=' '                    | Not Supported of Value EXPR :' '                                                                        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_return='0B01'                 | Insert failure.The reason is Column 'test_on_return' values only support 'false' or 'true'              | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_return=0B01                   | Not Supported of Value EXPR :0B01                                                                       | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_return=-1                     | Insert failure.The reason is Column 'test_on_return' values only support 'false' or 'true'.             | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_return=1.3                    | Not Supported of Value EXPR :1.3                                                                        | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_while_idle='null'                | Not Supported of Value EXPR :'null'                                                                      | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_while_idle=' '                   | Not Supported of Value EXPR :' '                                                                         | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_while_idle='0B01'                | Insert failure.The reason is Column 'test_while_idle' values only support 'false' or 'true'              | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_while_idle=0B01                  | Not Supported of Value EXPR :0B01                                                                        | dble_information |
      | conn_0 | false    | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_while_idle=-1                    | Insert failure.The reason is Column 'test_while_idle' values only support 'false' or 'true'.             | dble_information |
      | conn_0 | true     | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.9',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_while_idle=1.3                   | Not Supported of Value EXPR :1.3                                                                         | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      """

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                           | expect             | db               |
      | conn_0 | false   | insert into dble_db_instance set name='hostM8',db_group='ha_group8',addr='172.100.9.6',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_timeout=null                  | success            | dble_information |
      | conn_0 | false   | insert into dble_db_instance set name='hostM9',db_group='ha_group9',addr='172.100.9.6',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,connection_heartbeat_timeout=null        | success            | dble_information |
      | conn_0 | false   | insert into dble_db_instance set name='hostM10',db_group='ha_group10',addr='172.100.9.6',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,time_between_eviction_runs_millis=null | success            | dble_information |
      | conn_0 | false   | insert into dble_db_instance set name='hostM11',db_group='ha_group11',addr='172.100.9.6',port=3306,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,evictor_shutdown_timeout_millis=null   | success            | dble_information |
      | conn_0 | false   | insert into dble_db_instance set name='hostS11',db_group='ha_group11',addr='172.100.9.6',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='false',min_conn_count=1,max_conn_count=9,idle_timeout=null                     | success            | dble_information |
      | conn_0 | false   | insert into dble_db_instance set name='0B02',db_group='0B02',addr='172.100.9.6',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,heartbeat_period_millis=null                    | success            | dble_information |
      | conn_0 | false   | insert into dble_db_instance set name='0B03',db_group='0B03',addr='172.100.9.6',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_create=null                             | success            | dble_information |
      | conn_0 | false   | insert into dble_db_instance set name='0B04',db_group='0B04',addr='172.100.9.6',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_borrow=null                             | success            | dble_information |
      | conn_0 | false   | insert into dble_db_instance set name='0B05',db_group='0B05',addr='172.100.9.6',port=3306,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='true',min_conn_count=1,max_conn_count=9,test_on_return=null                             | success            | dble_information |
      | conn_0 | false   | insert into dble_db_instance set name='0B051',db_group='0B05',addr='172.100.9.6',port=3307,user='test',password_encrypt='111111',encrypt_configured='false',`primary`='false',min_conn_count=1,max_conn_count=9,test_while_idle=null                          | success            | dble_information |
      | conn_0 | false   | select connection_timeout from dble_db_instance where name ='hostM8'                       | has{((30000,),)}   | dble_information |
      | conn_0 | false   | select time_between_eviction_runs_millis from dble_db_instance where name ='hostM10'       | has{((30000,),)}   | dble_information |
      | conn_0 | false   | select evictor_shutdown_timeout_millis from dble_db_instance where name ='hostM11'         | has{((10000,),)}   | dble_information |
      | conn_0 | false   | select idle_timeout from dble_db_instance where name ='hostS11'                            | has{((600000,),)}  | dble_information |
      | conn_0 | false   | select heartbeat_period_millis from dble_db_instance where name ='0B02'                    | has{((10000,),)}   | dble_information |
      | conn_0 | false   | select test_on_create from dble_db_instance where name ='0B03'                             | has{(('false',),)} | dble_information |
      | conn_0 | false   | select test_on_borrow from dble_db_instance where name ='0B04'                             | has{(('false',),)} | dble_information |
      | conn_0 | false   | select test_on_return from dble_db_instance where name ='0B05'                             | has{(('false',),)} | dble_information |
      | conn_0 | true    | select test_while_idle from dble_db_instance where name ='0B051'                           | has{(('false',),)} | dble_information |

    Then execute admin cmd "reload @@config_all"
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      """



  @skip_restart
  Scenario: test the langreage of insert in dble manager   ---- dble_rw_split_entry  #3
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                  | expect      | db               |
      | conn_0 | false   | select * from dble_rw_split_entry                                    | length{(0)} | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry (username,password_encrypt,encrypt_configured,conn_attr_key,conn_attr_value,white_ips,max_conn_count,db_group) value ('rw1','111111','false','tenant','tenant1','%.%.%.1','100','ha_group3')                                         | success        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry (username,password_encrypt,encrypt_configured,conn_attr_key,conn_attr_value,white_ips,max_conn_count,db_group) values ('rw2','111111','false','tenant','tenant2','172.100.9.2/20','100','ha_group4')                                 | success        | dble_information |
      | conn_0 | false   | insert into dble_information.dble_rw_split_entry (username,password_encrypt,encrypt_configured,conn_attr_key,conn_attr_value,white_ips,max_conn_count,db_group) value ('rw3','111111','false','tenant','tenant3','fe80::fea4:9473:b424:bb41/64','1','ha_group5')     | success        | dble_information |
      | conn_0 | false   | insert into Dble_information.dble_rw_split_entry (username,password_encrypt,encrypt_configured,conn_attr_key,conn_attr_value,white_ips,max_conn_count,db_group) value ('rw4','111111','false','tenant','tenant4','172.100.9.7-172.100.9.3',0,'ha_group6')            | success        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry (username,password_encrypt,encrypt_configured,white_ips,max_conn_count,db_group) value ('rw5','FmMxCqFCorImAesW5TbLHbEHaaN+pHAVSXAvlDry5ZW3ZWkIymOMJyXF3Jrg9IKJVArxPQ3YKKisnGmiwCOOJg==','true','::1','100','ha_group4')             | success        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry (username,password_encrypt,encrypt_configured,max_conn_count,db_group) values ('rw6','111111','false','100','ha_group3'),('rw7','111111','false','100','ha_group4'),('rw8','111111','false','100','ha_group5')                       | success        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='rw9',password_encrypt='111111',encrypt_configured='false',conn_attr_key='tenant',conn_attr_value='tenant5',white_ips='172.%.9.%,172.100.%.1',max_conn_count=99,db_group='ha_group6'                                    | success        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='rw10',password_encrypt='111111',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'                                                                                                                   | success        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry (username,password_encrypt,encrypt_configured,conn_attr_value,conn_attr_key,white_ips,max_conn_count,db_group) value ('rw20','111111','false','tenant00','tenant','%.%.%.1','100','ha_group7')                                       | success        | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_rw_split_entry_1"
      | conn   | toClose | sql                                          | db               |
      | conn_0 | true    | select * from dble_rw_split_entry            | dble_information |
    Then check resultset "dble_rw_split_entry_1" has lines with following column values
      | id-0 | type-1    | username-2 | encrypt_configured-4 | conn_attr_key-5 | conn_attr_value-6 | white_ips-7                  | max_conn_count-8 | blacklist-9 | db_group-10 |
      | 3    | conn_attr | rw1        | false                | tenant          | tenant1           | %.%.%.1                      | 100              | None        | ha_group3   |
      | 4    | conn_attr | rw2        | false                | tenant          | tenant2           | 172.100.9.2/20               | 100              | None        | ha_group4   |
      | 5    | conn_attr | rw3        | false                | tenant          | tenant3           | fe80::fea4:9473:b424:bb41/64 | 1                | None        | ha_group5   |
      | 6    | conn_attr | rw4        | false                | tenant          | tenant4           | 172.100.9.7-172.100.9.3      | no limit         | None        | ha_group6   |
      | 7    | username  | rw5        | true                 | None            | None              | ::1                          | 100              | None        | ha_group4   |
      | 8    | username  | rw6        | false                | None            | None              | None                         | 100              | None        | ha_group3   |
      | 9    | username  | rw7        | false                | None            | None              | None                         | 100              | None        | ha_group4   |
      | 10   | username  | rw8        | false                | None            | None              | None                         | 100              | None        | ha_group5   |
      | 11   | conn_attr | rw9        | false                | tenant          | tenant5           | 172.%.9.%,172.100.%.1        | 99               | None        | ha_group6   |
      | 12   | username  | rw10       | false                | None            | None              | None                         | 100              | None        | ha_group6   |
      | 13   | conn_attr | rw20       | false                | tenant          | tenant00          | %.%.%.1                      | 100              | None        | ha_group7   |

    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble_admin_query.log" in host "dble-1"
    """
    \"user\":\[
    {\"type\":\"ManagerUser\",\"properties\":{\"name\":\"root\",\"password\":\"111111\"}},
    {\"type\":\"ShardingUser\",\"properties\":{\"schemas\":\"schema1\",\"name\":\"test\",\"password\":\"111111\"}},
    {\"type\":\"RwSplitUser\",\"properties\":{\"dbGroup\":\"ha_group3\",\"tenant\":\"tenant1\",\"name\":\"rw1\",\"password\":\"111111\",\"usingDecrypt\":\"false\",\"whiteIPs\":\"%.%.%.1\",\"maxCon\":100}},
    {\"type\":\"RwSplitUser\",\"properties\":{\"dbGroup\":\"ha_group4\",\"tenant\":\"tenant2\",\"name\":\"rw2\",\"password\":\"111111\",\"usingDecrypt\":\"false\",\"whiteIPs\":\"172.100.9.2/20\",\"maxCon\":100}},
    {\"type\":\"RwSplitUser\",\"properties\":{\"dbGroup\":\"ha_group5\",\"tenant\":\"tenant3\",\"name\":\"rw3\",\"password\":\"111111\",\"usingDecrypt\":\"false\",\"whiteIPs\":\"fe80::fea4:9473:b424:bb41/64\",\"maxCon\":1}},
    {\"type\":\"RwSplitUser\",\"properties\":{\"dbGroup\":\"ha_group6\",\"tenant\":\"tenant4\",\"name\":\"rw4\",\"password\":\"111111\",\"usingDecrypt\":\"false\",\"whiteIPs\":\"172.100.9.7-172.100.9.3\",\"maxCon\":0}},
    {\"type\":\"RwSplitUser\",\"properties\":{\"dbGroup\":\"ha_group4\",\"name\":\"rw5\",\"password\":\"
    \",\"usingDecrypt\":\"true\",\"whiteIPs\":\"::1\",\"maxCon\":100}},
    {\"type\":\"RwSplitUser\",\"properties\":{\"dbGroup\":\"ha_group3\",\"name\":\"rw6\",\"password\":\"111111\",\"usingDecrypt\":\"false\",\"maxCon\":100}},
    {\"type\":\"RwSplitUser\",\"properties\":{\"dbGroup\":\"ha_group4\",\"name\":\"rw7\",\"password\":\"111111\",\"usingDecrypt\":\"false\",\"maxCon\":100}},
    {\"type\":\"RwSplitUser\",\"properties\":{\"dbGroup\":\"ha_group5\",\"name\":\"rw8\",\"password\":\"111111\",\"usingDecrypt\":\"false\",\"maxCon\":100}},
    {\"type\":\"RwSplitUser\",\"properties\":{\"dbGroup\":\"ha_group6\",\"tenant\":\"tenant5\",\"name\":\"rw9\",\"password\":\"111111\",\"usingDecrypt\":\"false\",\"whiteIPs\":\"172.%.9.%,172.100.%.1\",\"maxCon\":99}},
    {\"type\":\"RwSplitUser\",\"properties\":{\"dbGroup\":\"ha_group6\",\"name\":\"rw10\",\"password\":\"111111\",\"usingDecrypt\":\"false\",\"maxCon\":100}},
    {\"type\":\"RwSplitUser\",\"properties\":{\"dbGroup\":\"ha_group7\",\"tenant\":\"tenant00\",\"name\":\"rw20\",\"password\":\"111111\",\"usingDecrypt\":\"false\",\"whiteIPs\":\"%.%.%.1\",\"maxCon\":100}
    """


    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false   | insert LOW_PRIORITY into dble_rw_split_entry (username,password_encrypt,encrypt_configured,white_ips,max_conn_count,db_group) value ('rw','111111','false','::1','100','ha_group4')                           | update syntax error, not support insert with syntax        | dble_information |
      | conn_0 | false   | insert DELAYED into dble_rw_split_entry (username,password_encrypt,encrypt_configured,white_ips,max_conn_count,db_group) value ('rw','111111','false','::1','100','ha_group4')                                | update syntax error, not support insert with syntax        | dble_information |
      | conn_0 | false   | insert HIGH_PRIORITY into dble_rw_split_entry (username,password_encrypt,encrypt_configured,white_ips,max_conn_count,db_group) value ('rw','111111','false','::1','100','ha_group4')                          | update syntax error, not support insert with syntax        | dble_information |
      | conn_0 | false   | insert IGNORE into dble_rw_split_entry (username,password_encrypt,encrypt_configured,white_ips,max_conn_count,db_group) value ('rw','111111','false','::1','100','ha_group4')                                 | update syntax error, not support insert with syntax        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry (username,password_encrypt,encrypt_configured,white_ips,max_conn_count,db_group) value ('rw','111111','false','::1','100','ha_group4') ON DUPLICATE KEY UPDATE username='r'   | update syntax error, not support insert with syntax        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry username select username from dble_rw_split_entry                                                                                                                             | Insert syntax error,not support insert ... select          | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set id=4,username='R10',password_encrypt='111111',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'                       | Column 'id' is not writable          | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set type='username',username='R10',password_encrypt='111111',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'            | Column 'type' is not writable        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set blacklist='blacklist1',username='R10',password_encrypt='111111',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'     | Column 'blacklist' is not writable   | dble_information |
      | conn_0 | false   | insert into dble_in.dble_rw_split_entry set username='R10',password_encrypt='111111',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'                    | Unknown database 'dble_in'           | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry (username,password_encrypt,encrypt_configured,conn_attr_key,conn_attr_value,white_ips,max_conn_count,db_group) value ('RW1','111111','false','tenant','tenant1','%.%.%.1','100')    | Column count doesn't match value count at row 1        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry (username,password_encrypt,encrypt_configured,conn_attr_key,conn_attr_value,white_ips,max_conn_count,db_group) value ('rw1','111111','false','tenant','tenant1','%.%.%.1','100','ha_group3')      | Duplicate entry 'rw1-tenant-tenant1'for logical unique 'username-conn_attr_key-conn_attr_value'        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='rw10',password_encrypt='111111',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'                                                                                | Duplicate entry 'rw10-null-null'for logical unique 'username-conn_attr_key-conn_attr_value'            | dble_information |
      #DBLE0REQ-1126
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false   | insert into dble_rw_split_entry set username='rw111',password_encrypt='111111',encrypt_configured='false',conn_attr_key='tenant',max_conn_count='100',db_group='ha_group6'            | Insert failure.The reason is 'conn_attr_key' and 'conn_attr_value' are used together        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='rw112',password_encrypt='111111',encrypt_configured='false',conn_attr_value='tenant',max_conn_count='100',db_group='ha_group6'          | Insert failure.The reason is 'conn_attr_key' and 'conn_attr_value' are used together        | dble_information |
      #DBLE0REQ-1127
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false   | insert into dble_rw_split_entry set username='null',password_encrypt='111111',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'             | Not Supported of Value EXPR :'null'        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username=' ',password_encrypt='111111',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'                | Not Supported of Value EXPR :' '           | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username=null,password_encrypt='111111',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'               | Column 'username' cannot be null           | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username=0B01,password_encrypt='111111',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'               | Not Supported of Value EXPR :0B01          | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username=1.3,password_encrypt='111111',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'                | Not Supported of Value EXPR :1.3        | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B01',password_encrypt='null',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'             | Not Supported of Value EXPR :'null'             | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B02',password_encrypt=' ',encrypt_configured='false',max_conn_count='100',db_group='ha_group6'                | Not Supported of Value EXPR :' '                | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B03',password_encrypt=null,encrypt_configured='false',max_conn_count='100',db_group='ha_group6'               | Column 'password_encrypt' cannot be null        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B05',password_encrypt=0B01,encrypt_configured='false',max_conn_count='100',db_group='ha_group6'               | Not Supported of Value EXPR :0B01               | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B07',password_encrypt=1.3,encrypt_configured='false',max_conn_count='100',db_group='ha_group6'                | Not Supported of Value EXPR :1.3                | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B01',password_encrypt='111111',encrypt_configured='null',max_conn_count='100',db_group='ha_group6'          | Not Supported of Value EXPR :'null'                                                             | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B02',password_encrypt='111111',encrypt_configured=' ',max_conn_count='100',db_group='ha_group6'             | Not Supported of Value EXPR :' '                                                                | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B04',password_encrypt='111111',encrypt_configured='0B01',max_conn_count='100',db_group='ha_group6'          | Insert failure.The reason is Column 'encrypt_configured' values only support 'false' or 'true'  | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B05',password_encrypt='111111',encrypt_configured=0B01,max_conn_count='100',db_group='ha_group6'            | Not Supported of Value EXPR :0B01                                                               | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B06',password_encrypt='111111',encrypt_configured=-1,max_conn_count='100',db_group='ha_group6'              | Insert failure.The reason is Column 'encrypt_configured' values only support 'false' or 'true'  | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B07',password_encrypt='111111',encrypt_configured=1.3,max_conn_count='100',db_group='ha_group6'             | Not Supported of Value EXPR :1.3                                                                | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B07',password_encrypt='111111',encrypt_configured=1,max_conn_count='100',db_group='ha_group6'               | Insert failure.The reason is Column 'encrypt_configured' values only support 'false' or 'true'  | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B07',password_encrypt='111111',encrypt_configured=0,max_conn_count='100',db_group='ha_group6'               | Insert failure.The reason is Column 'encrypt_configured' values only support 'false' or 'true'  | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='unique1',password_encrypt='111111',encrypt_configured=null,max_conn_count='100',db_group='ha_group6'         | user unique1 password need to decrypt ,but failed                                               | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B01',password_encrypt='111111',encrypt_configured='false',max_conn_count='null',db_group='ha_group6'        | Not Supported of Value EXPR :'null'                                                | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B02',password_encrypt='111111',encrypt_configured='false',max_conn_count=' ',db_group='ha_group6'           | Not Supported of Value EXPR :' '                                                   | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B03',password_encrypt='111111',encrypt_configured='false',max_conn_count=null,db_group='ha_group6'          | Column 'max_conn_count' cannot be null                                             | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B04',password_encrypt='111111',encrypt_configured='false',max_conn_count='0B01',db_group='ha_group6'        | Insert failure.The reason is incorrect integer value: '0B01'                       | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B05',password_encrypt='111111',encrypt_configured='false',max_conn_count=0B01,db_group='ha_group6'          | Not Supported of Value EXPR :0B01                                                  | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B06',password_encrypt='111111',encrypt_configured='false',max_conn_count=-1,db_group='ha_group6'            | Insert failure.The reason is Column 'max_conn_count' value cannot be less than 0   | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B07',password_encrypt='111111',encrypt_configured='false',max_conn_count=1.3,db_group='ha_group6'           | Not Supported of Value EXPR :1.3                                                   | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B01',password_encrypt='111111',encrypt_configured='false',max_conn_count=11,db_group='null'        | Not Supported of Value EXPR :'null'     | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B02',password_encrypt='111111',encrypt_configured='false',max_conn_count=12,db_group=' '           | Not Supported of Value EXPR :' '        | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B03',password_encrypt='111111',encrypt_configured='false',max_conn_count=13,db_group=null          | Column 'db_group' cannot be null                                                           | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B04',password_encrypt='111111',encrypt_configured='false',max_conn_count=14,db_group='0B01'        | Insert failure.The reason is Column 'db_group' value '0B01' does not exist or not active   | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B05',password_encrypt='111111',encrypt_configured='false',max_conn_count=15,db_group=0B01          | Not Supported of Value EXPR :0B01                                                          | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B06',password_encrypt='111111',encrypt_configured='false',max_conn_count=16,db_group=-1            | Insert failure.The reason is Column 'db_group' value '-1' does not exist or not active     | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B07',password_encrypt='111111',encrypt_configured='false',max_conn_count=17,db_group=1.3           | Not Supported of Value EXPR :1.3                                                           | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B08',password_encrypt='111111',encrypt_configured='false',max_conn_count=0,db_group=0              | Insert failure.The reason is Column 'db_group' value '0' does not exist or not active      | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B01',password_encrypt='111111',encrypt_configured='false',max_conn_count=11,db_group='ha_group6',white_ips='null'        | Not Supported of Value EXPR :'null'                                             | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B02',password_encrypt='111111',encrypt_configured='false',max_conn_count=12,db_group='ha_group6',white_ips=' '           | Not Supported of Value EXPR :' '                                                | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B04',password_encrypt='111111',encrypt_configured='false',max_conn_count=14,db_group='ha_group6',white_ips='0B01'        | Insert failure.The reason is The configuration contains incorrect IP["0B01"]    | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B05',password_encrypt='111111',encrypt_configured='false',max_conn_count=15,db_group='ha_group6',white_ips=0B01          | Not Supported of Value EXPR :0B01                                               | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B06',password_encrypt='111111',encrypt_configured='false',max_conn_count=16,db_group='ha_group6',white_ips=-1            | Insert failure.The reason is The configuration contains incorrect IP["-1"]      | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B07',password_encrypt='111111',encrypt_configured='false',max_conn_count=17,db_group='ha_group6',white_ips=1.3           | Not Supported of Value EXPR :1.3                                                | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B08',password_encrypt='111111',encrypt_configured='false',max_conn_count=18,db_group='ha_group6',white_ips=0             | Insert failure.The reason is The configuration contains incorrect IP["0"]       | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B01',password_encrypt='111111',encrypt_configured='false',max_conn_count=11,db_group='ha_group6',conn_attr_key='null',conn_attr_value='aa'        | Not Supported of Value EXPR :'null'                                                    | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B02',password_encrypt='111111',encrypt_configured='false',max_conn_count=12,db_group='ha_group6',conn_attr_key=' ',conn_attr_value='aa'           | Not Supported of Value EXPR :' '                                                       | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B03',password_encrypt='111111',encrypt_configured='false',max_conn_count=13,db_group='ha_group6',conn_attr_key=null,conn_attr_value='aa'          | Insert failure.The reason is 'conn_attr_key' and 'conn_attr_value' are used together   | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B04',password_encrypt='111111',encrypt_configured='false',max_conn_count=14,db_group='ha_group6',conn_attr_key='0B01',conn_attr_value='aa'        | Insert failure.The reason is 'conn_attr_key' value is ['tenant',null]                  | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B05',password_encrypt='111111',encrypt_configured='false',max_conn_count=15,db_group='ha_group6',conn_attr_key=0B01,conn_attr_value='aa'          | Not Supported of Value EXPR :0B01                                                      | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B06',password_encrypt='111111',encrypt_configured='false',max_conn_count=16,db_group='ha_group6',conn_attr_key=-1,conn_attr_value='aa'            | Insert failure.The reason is 'conn_attr_key' value is ['tenant',null]                  | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B07',password_encrypt='111111',encrypt_configured='false',max_conn_count=17,db_group='ha_group6',conn_attr_key=1.3,conn_attr_value='aa'           | Not Supported of Value EXPR :1.3                                                       | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B08',password_encrypt='111111',encrypt_configured='false',max_conn_count=18,db_group='ha_group6',conn_attr_key=0,conn_attr_value='aa'             | Insert failure.The reason is 'conn_attr_key' value is ['tenant',null]                  | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                      | expect      | db               |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B01',password_encrypt='111111',encrypt_configured='false',max_conn_count=11,db_group='ha_group6',conn_attr_value='null',conn_attr_key='tenant'        | Not Supported of Value EXPR :'null'                                                    | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B02',password_encrypt='111111',encrypt_configured='false',max_conn_count=12,db_group='ha_group6',conn_attr_value=' ',conn_attr_key='tenant'           | Not Supported of Value EXPR :' '                                                       | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B03',password_encrypt='111111',encrypt_configured='false',max_conn_count=13,db_group='ha_group6',conn_attr_value=null,conn_attr_key='tenant'          | Insert failure.The reason is 'conn_attr_key' and 'conn_attr_value' are used together   | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B05',password_encrypt='111111',encrypt_configured='false',max_conn_count=15,db_group='ha_group6',conn_attr_value=0B01,conn_attr_key='tenant'          | Not Supported of Value EXPR :0B01                                                      | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B07',password_encrypt='111111',encrypt_configured='false',max_conn_count=17,db_group='ha_group6',conn_attr_value=1.3,conn_attr_key='tenant'           | Not Supported of Value EXPR :1.3                                                       | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='0B01',password_encrypt='111111',encrypt_configured='false',max_conn_count=11,db_group='ha_group6',conn_attr_value='null',conn_attr_key='null'          | Not Supported of Value EXPR :'null'                                                    | dble_information |

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                      | expect       | db               |
      | conn_0 | true    | select * from dble_rw_split_entry        | length{(11)} | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                     | expect      | db               |
      | conn_0 | false   | insert into dble_rw_split_entry set username='unique2',password_encrypt='111111',encrypt_configured='false',max_conn_count=13,db_group='ha_group6',white_ips=null                                       | success     | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='unique3',password_encrypt='111111',encrypt_configured='false',max_conn_count=14,db_group='ha_group6',conn_attr_value='0B01',conn_attr_key='tenant'        | success     | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='unique4',password_encrypt='111111',encrypt_configured='false',max_conn_count=16,db_group='ha_group6',conn_attr_value=-1,conn_attr_key='tenant'            | success     | dble_information |
      | conn_0 | false   | insert into dble_rw_split_entry set username='unique5',password_encrypt='111111',encrypt_configured='false',max_conn_count=18,db_group='ha_group6',conn_attr_value=0,conn_attr_key='tenant'             | success     | dble_information |
      | conn_0 | true    | insert into dble_rw_split_entry set username='unique6',password_encrypt='111111',encrypt_configured='false',max_conn_count=11,db_group='ha_group6',conn_attr_value=null,conn_attr_key=null              | success     | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      """
    Then execute admin cmd "reload @@config_all"



  @skip_restart
  Scenario:  test the langreage of update in dble manager ----- dble_db_group #4

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                       | expect  | db               |
      | conn_0 | false   | update dble_db_group set heartbeat_stmt='select 55' where name='ha_group1'                                | success | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_timeout=100 where heartbeat_timeout=0                                  | success | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_retry=10 where active='false'                                          | success | dble_information |
      | conn_0 | false   | update dble_db_group set rw_split_mode=2 where delay_threshold=-1                                         | success | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold=1000 where active='false'                                        | success | dble_information |
      | conn_0 | false   | update dble_db_group set disable_ha='true' where heartbeat_stmt='select @@read_only'                      | success | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_stmt='select user()',heartbeat_timeout=1 where delay_threshold=-1      | success | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_stmt='select @a' where heartbeat_timeout=1 and heartbeat_retry!=1      | success | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_stmt='select @a' where heartbeat_timeout=1 or heartbeat_retry!=1       | success | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_retry=100 where rw_split_mode=2 or rw_split_mode=1 and rw_split_mode=0 | success | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold=100 where rw_split_mode in (0,2)                                 | success | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold=99,heartbeat_timeout=999 where rw_split_mode not in (0,2)        | success | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold=88,heartbeat_timeout=888 where rw_split_mode >1                  | success | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold=88,heartbeat_timeout=888 where rw_split_mode <1                  | success | dble_information |
      | conn_0 | false   | update dble_information.dble_db_group set rw_split_mode=1 where heartbeat_stmt like 'select %'            | success | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_1"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select * from dble_db_group  | dble_information |
    Then check resultset "dble_db_group_1" has lines with following column values
      | name-0     | heartbeat_stmt-1  | heartbeat_timeout-2 | heartbeat_retry-3 | heartbeat_keep_alive-4 | rw_split_mode-5 | delay_threshold-6 | delay_period_millis-7 | delay_database-8 | disable_ha-9 | active-10 |
      | ha_group1  | select 55         | 888                 | 1                 | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group2  | select user()     | 888                 | 1                 | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group3  | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group4  | select 2          | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group5  | show slave status | 888                 | 100               | 60                     | 2               | 88                | -1                    | null             | true         | true      |
      | ha_group6  | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | true         | true      |
      | ha_group7  | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group12 | select 7          | 888                 | 1                 | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group8  | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group9  | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group10 | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | true         | true      |
      | ha_group11 | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | 0B02       | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | 0B03       | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | 0B04       | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | 0B05       | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |


    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                                                           | expect                                                              | db               |
      | conn_0 | false    | update dble_db_group,dble_db_instance set heartbeat_retry=10 where active='false'                             | update syntax error, not support update Multiple-Table              | dble_information |
      | conn_0 | false    | update dble_db_group set heartbeat_stmt='select user()'                                                       | update syntax error, not support update without WHERE               | dble_information |
      | conn_0 | false    | update dble_db_group set heartbeat_retry=10 where (select active from dble_db_group where heartbeat_retry=1)  | update syntax error, not support sub-query                          | dble_information |
      | conn_0 | false    | update dble_db_group a set a.heartbeat_retry=100  where a.active='false'                                      | update syntax error, not support update with alias                  | dble_information |
      | conn_0 | false    | update dble_db_group set heartbeat_stmt='select user()' where db_group='db_group1' order by heartbeat_retry   | update syntax error, not support update with syntax :[LOW_PRIORITY] [IGNORE] ... [ORDER BY ...] [LIMIT row_count]  | dble_information |
      | conn_0 | false    | update dble_db_group set heartbeat_stmt='select user()' where db_group='db_group1' limit 2                    | update syntax error, not support update with syntax :[LOW_PRIORITY] [IGNORE] ... [ORDER BY ...] [LIMIT row_count]  | dble_information |
      | conn_0 | false    | update LOW_PRIORITY dble_db_group set heartbeat_retry=100 where active='false'                                | update syntax error, not support update with syntax :[LOW_PRIORITY] [IGNORE] ... [ORDER BY ...] [LIMIT row_count]  | dble_information |
      | conn_0 | false    | update IGNORE dble_db_group set heartbeat_retry=100 where active='false'                                      | update syntax error, not support update with syntax :[LOW_PRIORITY] [IGNORE] ... [ORDER BY ...] [LIMIT row_count]  | dble_information |
      | conn_0 | false    | update dble_db_group set active='false' where heartbeat_retry=100                                             | Column 'active' is not writable                                     | dble_information |
      | conn_0 | false    | update dble_db_group set delay_threshold=88,heartbeat_timeout=888 where rw_split_mode BETWEEN 0 AND 2         | unknown error:not supportted yet!                                   | dble_information |
      | conn_0 | false    | update dble_db_group set heartbeat=10 where active='false'                                                    | Unknown column 'heartbeat' in 'field list'                          | dble_information |
      | conn_0 | false    | update dble_db_group set name='ha_group10' where active='false'                                               | Primary column 'name' can not be update, please use delete & insert | dble_information |
      | conn_0 | false    | update dble_db_group st heartbeat_retry=10 where active='true'                                                | You have an error in your SQL syntax                                | dble_information |
      | conn_0 | false    | update dble_db_group set heartbeat_retry=10 where disable='true'                                              | unknown error:field not found:disable                               | dble_information |

      #### heartbeat_stmt
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_group set heartbeat_stmt=1.3 where heartbeat_stmt like 'select %'         | Not Supported of Value EXPR :1.3         | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_stmt=null where heartbeat_stmt like 'select %'        | Column 'heartbeat_stmt' cannot be null   | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_stmt='null' where heartbeat_stmt like 'select %'      | Not Supported of Value EXPR :'null'      | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_stmt=0B01 where heartbeat_stmt like 'select %'        | Not Supported of Value EXPR :0B01        | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_stmt=' ' where heartbeat_stmt like 'select %'         | Not Supported of Value EXPR :' '         | dble_information |
      #### heartbeat_stmt
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_group set heartbeat_timeout=1.3 where rw_split_mode = 1                           | Not Supported of Value EXPR :1.3                               | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_timeout='null' where rw_split_mode = 1                        | Not Supported of Value EXPR :'null'                            | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_timeout=0B01 where rw_split_mode = 1                          | Not Supported of Value EXPR :0B01                              | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_timeout='0B01' where rw_split_mode = 1                        | Update failure.The reason is incorrect integer value: '0B01'   | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_timeout=' ' where rw_split_mode = 1                           | Not Supported of Value EXPR :' '                               | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_timeout=heartbeat_timeout*10  where rw_split_mode = 1         | Not Supported of Value EXPR :heartbeat_timeout * 10            | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_timeout=SYSDATE()  where rw_split_mode = 1                    | Not Supported of Value EXPR :SYSDATE()                         | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_timeout=-1 where rw_split_mode = 1                            | Update failure.The reason is Column 'heartbeat_timeout' should be an integer greater than or equal to 0! | dble_information |
      #### heartbeat_retry
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_group set heartbeat_retry=1.3 where rw_split_mode = 1                           | Not Supported of Value EXPR :1.3                               | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_retry='null' where rw_split_mode = 1                        | Not Supported of Value EXPR :'null'                            | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_retry=0B01 where rw_split_mode = 1                          | Not Supported of Value EXPR :0B01                              | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_retry='0B01' where rw_split_mode = 1                        | Update failure.The reason is incorrect integer value: '0B01'   | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_retry=' ' where rw_split_mode = 1                           | Not Supported of Value EXPR :' '                               | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_retry=heartbeat_retry*10  where rw_split_mode = 1           | Not Supported of Value EXPR :heartbeat_retry * 10              | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_retry=SYSDATE()  where rw_split_mode = 1                    | Not Supported of Value EXPR :SYSDATE()                         | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_retry=-1 where rw_split_mode = 1                            | Update failure.The reason is Column 'heartbeat_retry' should be an integer greater than or equal to 0!  | dble_information |
      #### rw_split_mode
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_group set rw_split_mode=1.3 where rw_split_mode = 1                           | Not Supported of Value EXPR :1.3                                   | dble_information |
      | conn_0 | false   | update dble_db_group set rw_split_mode='null' where rw_split_mode = 1                        | Not Supported of Value EXPR :'null'                                | dble_information |
      | conn_0 | false   | update dble_db_group set rw_split_mode=null where rw_split_mode = 1                          | Column 'rw_split_mode' cannot be null                              | dble_information |
      | conn_0 | false   | update dble_db_group set rw_split_mode=0B01 where rw_split_mode = 1                          | Not Supported of Value EXPR :0B01                                  | dble_information |
      | conn_0 | false   | update dble_db_group set rw_split_mode='0B01' where rw_split_mode = 1                        | Update failure.The reason is incorrect integer value: '0B01'       | dble_information |
      | conn_0 | false   | update dble_db_group set rw_split_mode=' ' where rw_split_mode = 1                           | Not Supported of Value EXPR :' '                                   | dble_information |
      | conn_0 | false   | update dble_db_group set rw_split_mode=rw_split_mode*10  where rw_split_mode = 1             | Not Supported of Value EXPR :rw_split_mode * 10                    | dble_information |
      | conn_0 | false   | update dble_db_group set rw_split_mode=SYSDATE()  where rw_split_mode = 1                    | Not Supported of Value EXPR :SYSDATE()                             | dble_information |
      | conn_0 | false   | update dble_db_group set rw_split_mode=-1 where rw_split_mode = 1                            | Update failure.The reason is rwSplitMode should be between 0 and 3 | dble_information |
      | conn_0 | false   | update dble_db_group set rw_split_mode=4 where rw_split_mode = 1                             | Update failure.The reason is rwSplitMode should be between 0 and 3 | dble_information |
      #### delay_threshold
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_group set delay_threshold=1.3 where rw_split_mode = 1                           | Not Supported of Value EXPR :1.3                                   | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold='null' where rw_split_mode = 1                        | Not Supported of Value EXPR :'null'                                | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold=0B01 where rw_split_mode = 1                          | Not Supported of Value EXPR :0B01                                  | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold='0B01' where rw_split_mode = 1                        | Update failure.The reason is incorrect integer value: '0B01'       | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold=' ' where rw_split_mode = 1                           | Not Supported of Value EXPR :' '                                   | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold=delay_threshold*10  where rw_split_mode = 1           | Not Supported of Value EXPR :delay_threshold * 10                  | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold=SYSDATE()  where rw_split_mode = 1                    | Not Supported of Value EXPR :SYSDATE()                             | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold=-2 where rw_split_mode = 1                            | Update failure.The reason is Column 'delay_threshold' should be an integer greater than or equal to -1! | dble_information |
      #### disable_ha
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_group set disable_ha=1.3 where rw_split_mode = 1                           | Not Supported of Value EXPR :1.3                                   | dble_information |
      | conn_0 | false   | update dble_db_group set disable_ha='null' where rw_split_mode = 1                        | Not Supported of Value EXPR :'null'                                | dble_information |
      | conn_0 | false   | update dble_db_group set disable_ha=0B01 where rw_split_mode = 1                          | Not Supported of Value EXPR :0B01                                  | dble_information |
      | conn_0 | false   | update dble_db_group set disable_ha='0B01' where rw_split_mode = 1                        | Update failure.The reason is Column 'disable_ha' values only support 'false' or 'true' | dble_information |
      | conn_0 | false   | update dble_db_group set disable_ha=' ' where rw_split_mode = 1                           | Not Supported of Value EXPR :' '                                   | dble_information |
      | conn_0 | false   | update dble_db_group set disable_ha=disable_ha*10  where rw_split_mode = 1                | Not Supported of Value EXPR :disable_ha * 10                       | dble_information |
      | conn_0 | false   | update dble_db_group set disable_ha=SYSDATE()  where rw_split_mode = 1                    | Not Supported of Value EXPR :SYSDATE()                             | dble_information |
      | conn_0 | false   | update dble_db_group set disable_ha=-2 where rw_split_mode = 1                            | Update failure.The reason is Column 'disable_ha' values only support 'false' or 'true' | dble_information |
   #####delay_period_millis
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_group set delay_period_millis=1.3 where rw_split_mode = 1                           | Not Supported of Value EXPR :1.3                                   | dble_information |
      | conn_0 | false   | update dble_db_group set delay_period_millis='null' where rw_split_mode = 1                        | Not Supported of Value EXPR :'null'                                | dble_information |
      | conn_0 | false   | update dble_db_group set delay_period_millis=0B01 where rw_split_mode = 1                          | Not Supported of Value EXPR :0B01                                  | dble_information |
      | conn_0 | false   | update dble_db_group set delay_period_millis='0B01' where rw_split_mode = 1                        | Update failure.The reason is incorrect integer value: '0B01'       | dble_information |
      | conn_0 | false   | update dble_db_group set delay_period_millis=' ' where rw_split_mode = 1                           | Not Supported of Value EXPR :' '                                   | dble_information |
      | conn_0 | false   | update dble_db_group set delay_period_millis=delay_period_millis*10  where rw_split_mode = 1       | Not Supported of Value EXPR :delay_period_millis * 10              | dble_information |
      | conn_0 | false   | update dble_db_group set delay_period_millis=SYSDATE()  where rw_split_mode = 1                    | Not Supported of Value EXPR :SYSDATE()                             | dble_information |
      | conn_0 | false   | update dble_db_group set delay_period_millis=-2 where rw_split_mode = 1                            | Update failure.The reason is Column 'delay_threshold' should be an integer greater than -1! | dble_information |
    #####delay_database
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_group set delay_database=1.3 where rw_split_mode = 1                           | Not Supported of Value EXPR :1.3                                   | dble_information |
      | conn_0 | false   | update dble_db_group set delay_database='null' where rw_split_mode = 1                        | Not Supported of Value EXPR :'null'                                | dble_information |
      | conn_0 | false   | update dble_db_group set delay_database=0B01 where rw_split_mode = 1                          | Not Supported of Value EXPR :0B01                                  | dble_information |
      | conn_0 | false   | update dble_db_group set delay_database=' ' where rw_split_mode = 1                           | Not Supported of Value EXPR :' '                                   | dble_information |
      | conn_0 | false   | update dble_db_group set delay_database=disable_ha*10  where rw_split_mode = 1                | Not Supported of Value EXPR :disable_ha * 10                       | dble_information |
      | conn_0 | false   | update dble_db_group set delay_database=SYSDATE()  where rw_split_mode = 1                    | Not Supported of Value EXPR :SYSDATE()                             | dble_information |


    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                          | expect   | db               |
      | conn_0 | false   | update dble_db_group set heartbeat_timeout=null where rw_split_mode = 1      | success  | dble_information |
      | conn_0 | false   | update dble_db_group set heartbeat_retry=null where rw_split_mode = 1        | success  | dble_information |
      | conn_0 | false   | update dble_db_group set delay_threshold=null where rw_split_mode = 1        | success  | dble_information |
      | conn_0 | false   | update dble_db_group set disable_ha=null where rw_split_mode = 1             | success  | dble_information |
### coz  DBLE0REQ-2129
#    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
#      """
#      NullPointerException
#      """
    Then execute admin cmd "reload @@config_all"



  @skip_restart
  Scenario:  test the langreage of update in dble manager ----- dble_db_instance #5

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                             | expect  | db               |
      | conn_0 | false   | update dble_db_instance set max_conn_count=100 where name='hostM1'                              | success | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=100 where db_group='ha_group1'                          | success | dble_information |
      | conn_0 | false   | update dble_db_instance set id=10 where disabled='false'                                        | success | dble_information |
      | conn_0 | false   | update dble_db_instance set id=2 where db_group='ha_group1'                                     | success | dble_information |
      | conn_0 | false   | update dble_db_instance set max_conn_count=1000 where min_conn_count < 10                       | success | dble_information |
      | conn_0 | false   | update dble_db_instance set disabled='false' where min_conn_count=0                             | success | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=3,id='test' where id='888'                              | success | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=3,id='test' where id='888' and test_on_borrow !='false' | success | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=3,id='test' where id='888' or test_on_borrow !='false'  | success | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=3,id='test' where max_conn_count in (10000,1000000)     | success | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=3,id='test' where max_conn_count not in (1,1000000)     | success | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=3,id='test' where port > 3308                           | success | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=3,id='test3' where port > -1                            | success | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=3,id='test' where encrypt_configured like 'aa'          | success | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_1"
      | conn   | toClose | sql                            | db               |
      | conn_0 | true    | select name,db_group,addr,port,user,encrypt_configured,primary,disabled,min_conn_count,max_conn_count,read_weight,id from dble_db_instance            | dble_information |
    Then check resultset "dble_db_instance_1" has lines with following column values
      | name-0  | db_group-1 | addr-2      | port-3 | user-4 | encrypt_configured-5 | primary-6 | disabled-7 | min_conn_count-8 | max_conn_count-9 | read_weight-10 | id-11 |
      | hostM1  | ha_group1  | 172.100.9.5 | 3306   | test   | false                | true      | false      | 10               | 100              | 3              | test3 |
      | hostM2  | ha_group2  | 172.100.9.6 | 3306   | test   | false                | true      | false      | 10               | 1000             | 3              | test3 |
      | hostM3  | ha_group3  | 172.100.9.6 | 3306   | test   | false                | true      | true       | 10               | 1000             | 3              | test3 |
      | hostS31 | ha_group3  | 172.100.9.6 | 3307   | test   | false                | false     | false      | 1                | 1000             | 3              | test3 |
      | hostS32 | ha_group3  | 172.100.9.6 | 3308   | test   | false                | false     | true       | 2                | 1000             | 3              | test3 |
      | hostM4  | ha_group4  | 172.100.9.6 | 3307   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | hostS52 | ha_group5  | 172.100.9.6 | 3308   | test   | false                | false     | false      | 0                | 1000             | 3              | test3 |
      | hostM5  | ha_group5  | 172.100.9.6 | 3306   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | hostS51 | ha_group5  | 172.100.9.6 | 3307   | test   | false                | false     | false      | 0                | 1000             | 3              | test3 |
      | hostM6  | ha_group6  | 172.100.9.4 | 3306   | test   | false                | true      | false      | 4                | 1000             | 3              | test3 |
      | hostM7  | ha_group7  | 172.100.9.5 | 3306   | test   | true                 | true      | false      | 4                | 1000             | 3              | test3 |
      | hostM12 | ha_group12 | 172.100.9.1 | 3306   | test   | false                | true      | false      | 9                | 1000             | 3              | test3 |
      | hostM8  | ha_group8  | 172.100.9.6 | 3307   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | hostM9  | ha_group9  | 172.100.9.6 | 3307   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | hostM10 | ha_group10 | 172.100.9.6 | 3307   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | hostS11 | ha_group11 | 172.100.9.6 | 3307   | test   | false                | false     | false      | 1                | 1000             | 3              | test3 |
      | hostM11 | ha_group11 | 172.100.9.6 | 3306   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | 0B02    | 0B02       | 172.100.9.6 | 3307   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | 0B03    | 0B03       | 172.100.9.6 | 3307   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | 0B04    | 0B04       | 172.100.9.6 | 3307   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | 0B05    | 0B05       | 172.100.9.6 | 3306   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | 0B051   | 0B05       | 172.100.9.6 | 3307   | test   | false                | false     | false      | 1                | 1000             | 3              | test3 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_2"
      | conn   | toClose | sql                            | db               |
      | conn_0 | true    | select connection_timeout,connection_heartbeat_timeout,test_on_create,test_on_borrow,test_on_return,test_while_idle,time_between_eviction_runs_millis,evictor_shutdown_timeout_millis,idle_timeout,heartbeat_period_millis from dble_db_instance     | dble_information |
    Then check resultset "dble_db_instance_2" has lines with following column values
      | connection_timeout-0 | connection_heartbeat_timeout-1 | test_on_create-2 | test_on_borrow-3 | test_on_return-4 | test_while_idle-5 | time_between_eviction_runs_millis-6 | evictor_shutdown_timeout_millis-7 | idle_timeout-8 | heartbeat_period_millis-9 |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 200                            | false            | false            | false            | false             | 1                                   | 1                                 | 1              | 1                         |
      | 3                    | 1                              | true             | true             | true             | true              | 2                                   | 2                                 | 2              | 2                         |
      | 5                    | 2                              | false            | false            | false            | false             | 1                                   | 1                                 | 1              | 1                         |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
      | 30000                | 20                             | false            | false            | false            | false             | 30000                               | 10000                             | 600000         | 10000                     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_3"
      | conn   | toClose | sql                            | db               |
      | conn_0 | true    | select active_conn_count,idle_conn_count,read_conn_request,write_conn_request,last_heartbeat_ack,heartbeat_failure_in_last_5min from dble_db_instance       | dble_information |
    Then check resultset "dble_db_instance_3" has lines with following column values
      | active_conn_count-0 | idle_conn_count-1 | read_conn_request-2 | write_conn_request-3 | last_heartbeat_ack-4 | heartbeat_failure_in_last_5min-5 |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 1                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 10                | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 1                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 4                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | init                 | 0                                |
      | 0                   | 1                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | init                 | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 0                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 4                 | 0                   | 0                    | ok                   | 0                                |
      | 0                   | 10                | 0                   | 0                    | ok                   | 0                                |

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                                                              | expect                                                              | db               |
      | conn_0 | false    | update dble_db_instance,DBLE_db_group set min_conn_count=10 where max_conn_count=1000                            | update syntax error, not support update Multiple-Table              | dble_information |
      | conn_0 | false    | update dble_db_instance set min_conn_count=10                                                                    | update syntax error, not support update without WHERE               | dble_information |
      | conn_0 | false    | update dble_db_instance set min_conn_count=10 where (select active from dble_db_group where heartbeat_retry=1)   | update syntax error, not support sub-query                          | dble_information |
      | conn_0 | false    | update dble_db_instance a set a.min_conn_count=10=100 where a.min_conn_count=10                                  | update syntax error, not support update with alias                  | dble_information |
      | conn_0 | false    | update dble_db_instance set min_conn_count=10 where db_group='ha_group1' order by heartbeat_retry                | update syntax error, not support update with syntax :[LOW_PRIORITY] [IGNORE] ... [ORDER BY ...] [LIMIT row_count]  | dble_information |
      | conn_0 | false    | update dble_db_instance set min_conn_count=10 where db_group='ha_group1' limit 2                                 | update syntax error, not support update with syntax :[LOW_PRIORITY] [IGNORE] ... [ORDER BY ...] [LIMIT row_count]  | dble_information |
      | conn_0 | false    | update LOW_PRIORITY dble_db_instance set min_conn_count=10 where db_group='ha_group1'                            | update syntax error, not support update with syntax :[LOW_PRIORITY] [IGNORE] ... [ORDER BY ...] [LIMIT row_count]  | dble_information |
      | conn_0 | false    | update IGNORE dble_db_instance set min_conn_count=10 where db_group='ha_group1'                                  | update syntax error, not support update with syntax :[LOW_PRIORITY] [IGNORE] ... [ORDER BY ...] [LIMIT row_count]  | dble_information |
      #### not writable column and Primary column
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                                                  | expect                                                        | db               |
      | conn_0 | false    | update dble_db_instance set active_conn_count='false' where db_group='ha_group1'                     | Column 'active_conn_count' is not writable                    | dble_information |
      | conn_0 | false    | update dble_db_instance set idle_conn_count='false' where db_group='ha_group1'                       | Column 'idle_conn_count' is not writable                      | dble_information |
      | conn_0 | false    | update dble_db_instance set read_conn_request='false' where db_group='ha_group1'                     | Column 'read_conn_request' is not writable                    | dble_information |
      | conn_0 | false    | update dble_db_instance set write_conn_request='false' where db_group='ha_group1'                    | Column 'write_conn_request' is not writable                   | dble_information |
      | conn_0 | false    | update dble_db_instance set last_heartbeat_ack_timestamp='false' where db_group='ha_group1'          | Column 'last_heartbeat_ack_timestamp' is not writable         | dble_information |
      | conn_0 | false    | update dble_db_instance set last_heartbeat_ack='false' where db_group='ha_group1'                    | Column 'last_heartbeat_ack' is not writable                   | dble_information |
      | conn_0 | false    | update dble_db_instance set heartbeat_status='false' where db_group='ha_group1'                      | Column 'heartbeat_status' is not writable                     | dble_information |
      | conn_0 | false    | update dble_db_instance set heartbeat_failure_in_last_5min='false' where db_group='ha_group1'        | Column 'heartbeat_failure_in_last_5min' is not writable       | dble_information |
      | conn_0 | false    | update dble_db_instance set name='qqqq' where db_group='ha_group1'                                   | Primary column 'name' can not be update, please use delete & insert          | dble_information |
      | conn_0 | false    | update dble_db_instance set db_group='qqqq' where db_group='ha_group1'                               | Primary column 'db_group' can not be update, please use delete & insert      | dble_information |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false    | update dble_db_instance set min_conn_count=10 where min_conn_count BETWEEN 0 AND 100                 | unknown error:not supportted yet!                                   | dble_information |
      | conn_0 | false    | update dble_db_instance set min_conn_=10 where db_group='ha_group1'                                  | Unknown column 'min_conn_' in 'field list'                          | dble_information |
      | conn_0 | false    | update dble_db_instance st disabled='false' where min_conn_count=0                                   | You have an error in your SQL syntax                                | dble_information |
      | conn_0 | false    | update dble_db_instance set disabled='false' where active='false'                                    | unknown error:field not found:active                                | dble_information |
#      | conn_0 | false    | update dble_db_instance set addr='172.100.9.1' where db_group='ha_group3'                            | dbGroup[ha_group3]'s child url [172.100.9.6:3308]  duplicated!      | dble_information |
      #### addr
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set addr=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set addr='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set addr=null where db_group='ha_group1'              | Column 'addr' cannot be null                                                                                      | dble_information |
      | conn_0 | false   | update dble_db_instance set addr=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set addr='0B01' where db_group='ha_group1'            | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group1.hostM1]}            | dble_information |
      | conn_0 | false   | update dble_db_instance set addr=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set addr=addr*10  where db_group='ha_group1'          | Not Supported of Value EXPR :addr * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set addr=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set addr=-2 where db_group='ha_group1'                | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group1.hostM1]}            | dble_information |
      #### port
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set port=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set port='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set port=null where db_group='ha_group1'              | Column 'port' cannot be null                                                                                      | dble_information |
      | conn_0 | false   | update dble_db_instance set port=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set port='0B01' where db_group='ha_group1'            | java.lang.NumberFormatException: For input string: "0B01"                                                         | dble_information |
      | conn_0 | false   | update dble_db_instance set port=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set port=port*10  where db_group='ha_group1'          | Not Supported of Value EXPR :port * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set port=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set port=-2 where db_group='ha_group1'                | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group1.hostM1]}            | dble_information |
      | conn_0 | false   | update dble_db_instance set port=8066 where db_group='ha_group1'              | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group1.hostM1]}            | dble_information |
      | conn_0 | false   | update dble_db_instance set port=9066 where db_group='ha_group1'              | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group1.hostM1]}            | dble_information |
      #### user
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set user=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set user='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set user=null where db_group='ha_group1'              | Column 'user' cannot be null                                                                                      | dble_information |
      | conn_0 | false   | update dble_db_instance set user=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set user='0B01' where db_group='ha_group1'            | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group1.hostM1]}            | dble_information |
      | conn_0 | false   | update dble_db_instance set user=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set user=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set user=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set user=-2 where db_group='ha_group1'                | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group1.hostM1]}            | dble_information |
      #### password_encrypt
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set password_encrypt=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set password_encrypt='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set password_encrypt=null where db_group='ha_group1'              | Column 'password_encrypt' cannot be null                                                                          | dble_information |
      | conn_0 | false   | update dble_db_instance set password_encrypt=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set password_encrypt='0B01' where db_group='ha_group1'            | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group1.hostM1]}            | dble_information |
      | conn_0 | false   | update dble_db_instance set password_encrypt=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set password_encrypt=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set password_encrypt=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set password_encrypt=-2 where db_group='ha_group1'                | there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group1.hostM1]}            | dble_information |
      #### encrypt_configured
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set encrypt_configured=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set encrypt_configured='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set encrypt_configured=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set encrypt_configured='0B01' where db_group='ha_group1'            | Update failure.The reason is Column 'encrypt_configured' values only support 'false' or 'true'                    | dble_information |
      | conn_0 | false   | update dble_db_instance set encrypt_configured=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set encrypt_configured=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set encrypt_configured=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set encrypt_configured=-2 where db_group='ha_group1'                | Update failure.The reason is Column 'encrypt_configured' values only support 'false' or 'true'                    | dble_information |
      | conn_0 | false   | update dble_db_instance set encrypt_configured='true' where db_group='ha_group1'            | host hostM1,user test password need to decrypt, but failed !                                                      | dble_information |
       ####   primary
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set `primary`=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set `primary`='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set `primary`=null where db_group='ha_group1'              | Column 'primary' cannot be null                                                                                   | dble_information |
      | conn_0 | false   | update dble_db_instance set `primary`=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set `primary`='0B01' where db_group='ha_group1'            | Update failure.The reason is Column 'primary' values only support 'false' or 'true'                               | dble_information |
      | conn_0 | false   | update dble_db_instance set `primary`=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set `primary`=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set `primary`=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set `primary`=-2 where db_group='ha_group1'                | Update failure.The reason is Column 'primary' values only support 'false' or 'true'                               | dble_information |
       ####   disabled
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set disabled=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set disabled='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set disabled=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set disabled='0B01' where db_group='ha_group1'            | Update failure.The reason is Column 'disabled' values only support 'false' or 'true'                              | dble_information |
      | conn_0 | false   | update dble_db_instance set disabled=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set disabled=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set disabled=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set disabled=-2 where db_group='ha_group1'                | Update failure.The reason is Column 'disabled' values only support 'false' or 'true'                              | dble_information |
       ####   max_conn_count
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set max_conn_count=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set max_conn_count='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set max_conn_count=null where db_group='ha_group1'              | Column 'max_conn_count' cannot be null                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set max_conn_count=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set max_conn_count='0B01' where db_group='ha_group1'            | Update failure.The reason is incorrect integer value: '0B01'                                                      | dble_information |
      | conn_0 | false   | update dble_db_instance set max_conn_count=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set max_conn_count=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set max_conn_count=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set max_conn_count=-2 where db_group='ha_group1'                | Update failure.The reason is Column 'max_conn_count' value cannot be less than 0                                  | dble_information |
       ####   min_conn_count
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set min_conn_count=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set min_conn_count='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set min_conn_count=null where db_group='ha_group1'              | Column 'min_conn_count' cannot be null                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set min_conn_count=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set min_conn_count='0B01' where db_group='ha_group1'            | Update failure.The reason is incorrect integer value: '0B01'                                                      | dble_information |
      | conn_0 | false   | update dble_db_instance set min_conn_count=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set min_conn_count=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set min_conn_count=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set min_conn_count=-2 where db_group='ha_group1'                | Update failure.The reason is Column 'min_conn_count' value cannot be less than 0                                  | dble_information |
       ####   read_weight
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set read_weight=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight='0B01' where db_group='ha_group1'            | java.lang.NumberFormatException: For input string: "0B01"                                                         | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=-2 where db_group='ha_group1'                | readWeight attribute in dbInstance[hostM1] can't be less than 0                                                   | dble_information |
       ####   id
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set id=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set id='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set id=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set id=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set id=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set id=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |

       ####   connection_timeout
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set connection_timeout=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_timeout='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_timeout=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_timeout='0B01' where db_group='ha_group1'            | property [ connectionTimeout ] '0B01' data type should be long                                                    | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_timeout=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_timeout=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_timeout=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_timeout=-2 where db_group='ha_group1'                | property [ connectionTimeout ] '-2' should be an integer greater than 0                                           | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_timeout=0 where db_group='ha_group1'                 | property [ connectionTimeout ] '0' should be an integer greater than 0                                            | dble_information |
       ####   connection_heartbeat_timeout
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set connection_heartbeat_timeout=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_heartbeat_timeout='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_heartbeat_timeout=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_heartbeat_timeout='0B01' where db_group='ha_group1'            | property [ connectionHeartbeatTimeout ] '0B01' data type should be long                                           | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_heartbeat_timeout=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_heartbeat_timeout=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_heartbeat_timeout=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_heartbeat_timeout=-2 where db_group='ha_group1'                | property [ connectionHeartbeatTimeout ] '-2' should be an integer greater than 0                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_heartbeat_timeout=0 where db_group='ha_group1'                 | property [ connectionHeartbeatTimeout ] '0' should be an integer greater than 0                                   | dble_information |
       ####   time_between_eviction_runs_millis
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set time_between_eviction_runs_millis=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set time_between_eviction_runs_millis='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set time_between_eviction_runs_millis=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set time_between_eviction_runs_millis='0B01' where db_group='ha_group1'            | property [ timeBetweenEvictionRunsMillis ] '0B01' data type should be long                                        | dble_information |
      | conn_0 | false   | update dble_db_instance set time_between_eviction_runs_millis=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set time_between_eviction_runs_millis=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set time_between_eviction_runs_millis=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set time_between_eviction_runs_millis=-2 where db_group='ha_group1'                | property [ timeBetweenEvictionRunsMillis ] '-2' should be an integer greater than 0                               | dble_information |
      | conn_0 | false   | update dble_db_instance set time_between_eviction_runs_millis=0 where db_group='ha_group1'                 | property [ timeBetweenEvictionRunsMillis ] '0' should be an integer greater than 0                                | dble_information |
       ####   evictor_shutdown_timeout_millis
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set evictor_shutdown_timeout_millis=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set evictor_shutdown_timeout_millis='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set evictor_shutdown_timeout_millis=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set evictor_shutdown_timeout_millis='0B01' where db_group='ha_group1'            | property [ evictorShutdownTimeoutMillis ] '0B01' data type should be long                                         | dble_information |
      | conn_0 | false   | update dble_db_instance set evictor_shutdown_timeout_millis=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set evictor_shutdown_timeout_millis=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set evictor_shutdown_timeout_millis=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set evictor_shutdown_timeout_millis=-2 where db_group='ha_group1'                | property [ evictorShutdownTimeoutMillis ] '-2' should be an integer greater than 0                                | dble_information |
      | conn_0 | false   | update dble_db_instance set evictor_shutdown_timeout_millis=0 where db_group='ha_group1'                 | property [ evictorShutdownTimeoutMillis ] '0' should be an integer greater than 0                                 | dble_information |
       ####   idle_timeout
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set idle_timeout=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set idle_timeout='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set idle_timeout=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set idle_timeout='0B01' where db_group='ha_group1'            | property [ idleTimeout ] '0B01' data type should be long                                                          | dble_information |
      | conn_0 | false   | update dble_db_instance set idle_timeout=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set idle_timeout=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set idle_timeout=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set idle_timeout=-2 where db_group='ha_group1'                | property [ idleTimeout ] '-2' should be an integer greater than 0                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set idle_timeout=0 where db_group='ha_group1'                 | property [ idleTimeout ] '0' should be an integer greater than 0                                                  | dble_information |
       ####   heartbeat_period_millis
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set heartbeat_period_millis=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set heartbeat_period_millis='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set heartbeat_period_millis=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set heartbeat_period_millis='0B01' where db_group='ha_group1'            | property [ heartbeatPeriodMillis ] '0B01' data type should be long                                                | dble_information |
      | conn_0 | false   | update dble_db_instance set heartbeat_period_millis=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set heartbeat_period_millis=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set heartbeat_period_millis=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set heartbeat_period_millis=-2 where db_group='ha_group1'                | property [ heartbeatPeriodMillis ] '-2' should be an integer greater than 0                                       | dble_information |
      | conn_0 | false   | update dble_db_instance set heartbeat_period_millis=0 where db_group='ha_group1'                 | property [ heartbeatPeriodMillis ] '0' should be an integer greater than 0                                        | dble_information |
       ####   test_on_create
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set test_on_create=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_create='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_create=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_create='0B01' where db_group='ha_group1'            | Update failure.The reason is Column 'test_on_create' values only support 'false' or 'true'                        | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_create=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_create=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_create=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_create=-2 where db_group='ha_group1'                | Update failure.The reason is Column 'test_on_create' values only support 'false' or 'true'                        | dble_information |
       ####   test_on_borrow
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set test_on_borrow=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_borrow='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_borrow=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_borrow='0B01' where db_group='ha_group1'            | Update failure.The reason is Column 'test_on_borrow' values only support 'false' or 'true'                        | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_borrow=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_borrow=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_borrow=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_borrow=-2 where db_group='ha_group1'                | Update failure.The reason is Column 'test_on_borrow' values only support 'false' or 'true'                        | dble_information |
       ####   test_on_return
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set test_on_return=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_return='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_return=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_return='0B01' where db_group='ha_group1'            | Update failure.The reason is Column 'test_on_return' values only support 'false' or 'true'                        | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_return=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_return=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_return=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_return=-2 where db_group='ha_group1'                | Update failure.The reason is Column 'test_on_return' values only support 'false' or 'true'                        | dble_information |
       ####   test_while_idle
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                   | expect               | db               |
      | conn_0 | false   | update dble_db_instance set test_while_idle=1.3 where db_group='ha_group1'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set test_while_idle='null' where db_group='ha_group1'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_db_instance set test_while_idle=0B01 where db_group='ha_group1'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_db_instance set test_while_idle='0B01' where db_group='ha_group1'            | Update failure.The reason is Column 'test_while_idle' values only support 'false' or 'true'                       | dble_information |
      | conn_0 | false   | update dble_db_instance set test_while_idle=' ' where db_group='ha_group1'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_db_instance set test_while_idle=user*10  where db_group='ha_group1'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set test_while_idle=SYSDATE()  where db_group='ha_group1'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_db_instance set test_while_idle=-2 where db_group='ha_group1'                | Update failure.The reason is Column 'test_while_idle' values only support 'false' or 'true'                       | dble_information |

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                              | expect       | db               |
      | conn_0 | false   | update dble_db_instance set encrypt_configured=null where db_group='ha_group1'                   | success      | dble_information |
      | conn_0 | false   | update dble_db_instance set primary='true' where db_group='ha_group1'                            | success      | dble_information |
      | conn_0 | false   | update dble_db_instance set disabled='true' where db_group='ha_group1'                           | success      | dble_information |
      | conn_0 | false   | update dble_db_instance set read_weight=null where db_group='ha_group1'                          | success      | dble_information |
      | conn_0 | false   | update dble_db_instance set id=null where db_group='ha_group1'                                   | success      | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_timeout=null where db_group='ha_group1'                   |  success     | dble_information |
      | conn_0 | false   | update dble_db_instance set connection_heartbeat_timeout=null where db_group='ha_group1'         |  success     | dble_information |
      | conn_0 | false   | update dble_db_instance set time_between_eviction_runs_millis=null where db_group='ha_group1'    |  success     | dble_information |
      | conn_0 | false   | update dble_db_instance set evictor_shutdown_timeout_millis=null where db_group='ha_group1'      |  success     | dble_information |
      | conn_0 | false   | update dble_db_instance set idle_timeout=null where db_group='ha_group1'                         |  success     | dble_information |
      | conn_0 | false   | update dble_db_instance set heartbeat_period_millis=null where db_group='ha_group1'              |  success     | dble_information |
      | conn_0 | false   | update dble_db_instance set test_while_idle=null where db_group='ha_group1'                      |  success     | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_return=null where db_group='ha_group1'                       |  success     | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_borrow=null where db_group='ha_group1'                       |  success     | dble_information |
      | conn_0 | false   | update dble_db_instance set test_on_create=null where db_group='ha_group1'                       |  success     | dble_information |

### coz  DBLE0REQ-2129
#    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
#      """
#      NullPointerException
#      """
    Then execute admin cmd "reload @@config_all"



  @skip_restart
  Scenario:  test the langreage of update in dble manager ----- dble_rw_split_entry #6

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                  | expect  | db               |
      | conn_0 | false   | update dble_rw_split_entry set white_ips='::1' where id=3                                                            | success | dble_information |
      | conn_0 | false   | update dble_Rw_split_entry set max_conn_count=200 where type='conn_attr'                                             | success | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set max_conn_count=1000 where max_conn_count ='no limit'                                  | success | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips='::1',max_conn_count=1000 where type='conr'                                 | success | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips='::1',max_conn_count=1000 where type='conr' and id=4                        | success | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips='::1',max_conn_count=1000 where type='conr' and encrypt_configured !='true' | success | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips=null where id in (4,5)                                                      | success | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips=null where id not  in (134,543)                                             | success | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips=null where id > 333                                                         | success | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips=null where id < > -1                                                        | success | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set max_conn_count=1000 where max_conn_count like '%limit'                                | success | dble_information |


    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_rw_split_entry_1"
      | conn   | toClose | sql                                          | db               |
      | conn_0 | true    | select * from dble_rw_split_entry            | dble_information |
    Then check resultset "dble_rw_split_entry_1" has lines with following column values
      | id-0 | type-1    | username-2 | encrypt_configured-4 | conn_attr_key-5 | conn_attr_value-6 | white_ips-7                  | max_conn_count-8 | blacklist-9 | db_group-10 |
      | 3    | conn_attr | rw1        | false                | tenant          | tenant1           | ::1                          | 200              | None        | ha_group3   |
      | 4    | conn_attr | rw2        | false                | tenant          | tenant2           | 172.100.9.2/20               | 200              | None        | ha_group4   |
      | 5    | conn_attr | rw3        | false                | tenant          | tenant3           | fe80::fea4:9473:b424:bb41/64 | 200              | None        | ha_group5   |
      | 6    | conn_attr | rw4        | false                | tenant          | tenant4           | 172.100.9.7-172.100.9.3      | 200              | None        | ha_group6   |
      | 7    | username  | rw5        | true                 | None            | None              | ::1                          | 100              | None        | ha_group4   |
      | 8    | username  | rw6        | false                | None            | None              | None                         | 100              | None        | ha_group3   |
      | 9    | username  | rw7        | false                | None            | None              | None                         | 100              | None        | ha_group4   |
      | 10   | username  | rw8        | false                | None            | None              | None                         | 100              | None        | ha_group5   |
      | 11   | conn_attr | rw9        | false                | tenant          | tenant5           | 172.%.9.%,172.100.%.1        | 200              | None        | ha_group6   |
      | 12   | username  | rw10       | false                | None            | None              | None                         | 100              | None        | ha_group6   |
      | 13   | conn_attr | rw20       | false                | tenant          | tenant00          | %.%.%.1                      | 200              | None        | ha_group7   |
      | 14   | username  | unique2    | false                | None            | None              | None                         | 13               | None        | ha_group6   |
      | 15   | conn_attr | unique3    | false                | tenant          | 0B01              | None                         | 200              | None        | ha_group6   |
      | 16   | conn_attr | unique4    | false                | tenant          | -1                | None                         | 200              | None        | ha_group6   |
      | 17   | conn_attr | unique5    | false                | tenant          | 0                 | None                         | 200              | None        | ha_group6   |
      | 18   | username  | unique6    | false                | None            | None              | None                         | 11               | None        | ha_group6   |

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                                                                 | expect                                                              | db               |
      | conn_0 | false    | update dble_rw_split_entry,DBLE_db_group set min_conn_count=10 where max_conn_count=1000                            | update syntax error, not support update Multiple-Table              | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set max_conn_count=10                                                                    | update syntax error, not support update without WHERE               | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set max_conn_count=10 where (select active from dble_db_group where heartbeat_retry=1)   | update syntax error, not support sub-query                          | dble_information |
      | conn_0 | false    | update dble_rw_split_entry a set a.max_conn_count=10=100 where a.max_conn_count=10                                  | update syntax error, not support update with alias                  | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set max_conn_count=10 where db_group='ha_group1' order by heartbeat_retry                | update syntax error, not support update with syntax :[LOW_PRIORITY] [IGNORE] ... [ORDER BY ...] [LIMIT row_count]  | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set max_conn_count=10 where db_group='ha_group1' limit 2                                 | update syntax error, not support update with syntax :[LOW_PRIORITY] [IGNORE] ... [ORDER BY ...] [LIMIT row_count]  | dble_information |
      | conn_0 | false    | update LOW_PRIORITY dble_rw_split_entry set max_conn_count=10 where db_group='ha_group1'                            | update syntax error, not support update with syntax :[LOW_PRIORITY] [IGNORE] ... [ORDER BY ...] [LIMIT row_count]  | dble_information |
      | conn_0 | false    | update IGNORE dble_rw_split_entry set max_conn_count=10 where db_group='ha_group1'                                  | update syntax error, not support update with syntax :[LOW_PRIORITY] [IGNORE] ... [ORDER BY ...] [LIMIT row_count]  | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set max_conn_count=10 where max_conn_count BETWEEN 0 AND 100                 | unknown error:not supportted yet!                                  | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set max_conn=10 where max_conn_count >100                                    | Unknown column 'max_conn' in 'field list'                          | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set max_conn_count=10 where conn_count >100                                  | unknown error:field not found:conn_count                           | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set max_conn=10 whre max_conn_count >100                                     | You have an error in your SQL syntax                               | dble_information |
       #### not writable column and Primary column
      | conn_0 | false    | update dble_rw_split_entry set blacklist='black1' where id=3            | Column 'blacklist' is not writable                                   | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set type='username' where id=3               | Column 'type' is not writable                                        | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set id=33 where id=3                         | Primary column 'id' can not be update, please use delete & insert    | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set username='unique' where id=3             | Column 'username' is not writable.Because of the logical primary key ["conn_attr_key","conn_attr_value","username"]           | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set conn_attr_key='unique' where id=3        | Column 'conn_attr_key' is not writable.Because of the logical primary key ["conn_attr_key","conn_attr_value","username"]      | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set conn_attr_value='unique' where id=3      | Column 'conn_attr_value' is not writable.Because of the logical primary key ["conn_attr_key","conn_attr_value","username"]    | dble_information |
      #### password_encrypt
      | conn_0 | false   | update dble_rw_split_entry set password_encrypt=1.3 where db_group='ha_group6'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set password_encrypt='null' where db_group='ha_group6'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set password_encrypt=null where db_group='ha_group6'              | Column 'password_encrypt' cannot be null                                                                          | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set password_encrypt=0B01 where db_group='ha_group6'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set password_encrypt=' ' where db_group='ha_group6'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set password_encrypt=user*10  where db_group='ha_group6'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set password_encrypt=SYSDATE()  where db_group='ha_group6'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      #### encrypt_configured
      | conn_0 | false   | update dble_rw_split_entry set encrypt_configured=1.3 where db_group='ha_group6'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set encrypt_configured='null' where db_group='ha_group6'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set encrypt_configured=0B01 where db_group='ha_group6'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set encrypt_configured='0B01' where db_group='ha_group6'            | Update failure.The reason is Column 'encrypt_configured' values only support 'false' or 'true'                    | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set encrypt_configured=' ' where db_group='ha_group6'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set encrypt_configured=user*10  where db_group='ha_group6'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set encrypt_configured=SYSDATE()  where db_group='ha_group6'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set encrypt_configured=-2 where db_group='ha_group6'                | Update failure.The reason is Column 'encrypt_configured' values only support 'false' or 'true'                    | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set encrypt_configured='true' where db_group='ha_group3'            | user rw1 password need to decrypt ,but failed                                                                     | dble_information |
      #### white_ips
      | conn_0 | false   | update dble_rw_split_entry set white_ips=1.3 where db_group='ha_group6'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips='null' where db_group='ha_group6'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips=0B01 where db_group='ha_group6'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips='0B01' where db_group='ha_group6'            | Update failure.The reason is The configuration contains incorrect IP["0B01"]                                      | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips=' ' where db_group='ha_group6'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips=user*10  where db_group='ha_group6'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips=SYSDATE()  where db_group='ha_group6'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips=-2 where db_group='ha_group6'                | Update failure.The reason is The configuration contains incorrect IP["-2"]                                        | dble_information |
      #### max_conn_count
      | conn_0 | false   | update dble_rw_split_entry set max_conn_count=1.3 where db_group='ha_group6'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set max_conn_count='null' where db_group='ha_group6'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set max_conn_count=null where db_group='ha_group6'              | Column 'max_conn_count' cannot be null                                                                            | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set max_conn_count=0B01 where db_group='ha_group6'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set max_conn_count='0B01' where db_group='ha_group6'            | Update failure.The reason is incorrect integer value: '0B01'                                                      | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set max_conn_count=' ' where db_group='ha_group6'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set max_conn_count=user*10  where db_group='ha_group6'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set max_conn_count=SYSDATE()  where db_group='ha_group6'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set max_conn_count=-2 where db_group='ha_group6'                | Update failure.The reason is Column 'max_conn_count' value cannot be less than 0                                  | dble_information |
      #### db_group
      | conn_0 | false   | update dble_rw_split_entry set db_group=1.3 where db_group='ha_group6'               | Not Supported of Value EXPR :1.3                                                                                  | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set db_group='null' where db_group='ha_group6'            | Not Supported of Value EXPR :'null'                                                                               | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set db_group=null where db_group='ha_group6'              | Column 'db_group' cannot be null                                                                                  | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set db_group=0B01 where db_group='ha_group6'              | Not Supported of Value EXPR :0B01                                                                                 | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set db_group=' ' where db_group='ha_group6'               | Not Supported of Value EXPR :' '                                                                                  | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set db_group=user*10  where db_group='ha_group6'          | Not Supported of Value EXPR :user * 10                                                                            | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set db_group=SYSDATE()  where db_group='ha_group6'        | Not Supported of Value EXPR :SYSDATE()                                                                            | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set db_group=-2 where db_group='ha_group6'                | Update failure.The reason is Column 'db_group' value '-2' does not exist or not active                            | dble_information |

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                            | expect       | db               |
      | conn_0 | false   | update dble_rw_split_entry set encrypt_configured=null where db_group='ha_group6'              | success      | dble_information |
      | conn_0 | false   | update dble_rw_split_entry set white_ips=null where db_group='ha_group3'                       | success      | dble_information |
### coz  DBLE0REQ-2129
#    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
#      """
#      NullPointerException
#      """
    Then execute admin cmd "reload @@config_all"



  Scenario: test the langreage of delete in dble manager   ---- dble_db_group dble_db_instance  dble_rw_split_entry #7

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                         | expect       | db               |
      | conn_0 | false   | select * from dble_db_instance                                              | length{(22)} | dble_information |
      | conn_0 | false   | select * from dble_db_group                                                 | length{(16)} | dble_information |
      | conn_0 | false   | delete from dble_db_instance where name='0B051'                             | success      | dble_information |
      | conn_0 | false   | delete from dble_db_instance where name='0B05'                              | success      | dble_information |
      | conn_0 | false   | select * from dble_db_instance                                              | length{(20)} | dble_information |
      | conn_0 | false   | select * from dble_db_group                                                 | length{(15)} | dble_information |
      | conn_0 | false   | delete from dble_db_instance where name ='hostM8' and db_group ='ha_group8' | success      | dble_information |
      | conn_0 | false   | delete from dble_db_instance where name ='hostM10' or db_group ='ha_group9' | success      | dble_information |
      | conn_0 | false   | delete from dble_db_instance where max_conn_count >10000                    | success      | dble_information |
      | conn_0 | false   | select * from dble_db_instance                                              | length{(17)} | dble_information |
      | conn_0 | false   | select * from dble_db_group                                                 | length{(12)} | dble_information |
      | conn_0 | false   | select * from dble_rw_split_entry                                           | length{(16)} | dble_information |
      | conn_0 | false   | delete from dble_rw_split_entry where id in (3,5)                           | success      | dble_information |
      | conn_0 | false   | delete from dble_rw_split_entry where username like 'unique%'               | success      | dble_information |
      | conn_0 | false   | select * from dble_rw_split_entry                                           | length{(9)}  | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_1"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select * from dble_db_group  | dble_information |
    Then check resultset "dble_db_group_1" has lines with following column values
      | name-0     | heartbeat_stmt-1  | heartbeat_timeout-2 | heartbeat_retry-3 | heartbeat_keep_alive-4 | rw_split_mode-5 | delay_threshold-6 | delay_period_millis-7 | delay_database-8 | disable_ha-9 | active-10 |
      | ha_group1  | select 55         | 888                 | 1                 | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group2  | select user()     | 888                 | 1                 | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group3  | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group4  | select 2          | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group5  | show slave status | 888                 | 100               | 60                     | 2               | 88                | -1                    | null             | true         | true      |
      | ha_group6  | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | true         | true      |
      | ha_group7  | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group12 | select 7          | 888                 | 1                 | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | ha_group11 | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | 0B02       | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | 0B03       | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |
      | 0B04       | select @a         | 888                 | 100               | 60                     | 1               | 88                | -1                    | null             | false        | true      |


    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_1"
      | conn   | toClose | sql                                                                                                                                                   | db               |
      | conn_0 | true    | select name,db_group,addr,port,user,encrypt_configured,primary,disabled,min_conn_count,max_conn_count,read_weight,id from dble_db_instance            | dble_information |
    Then check resultset "dble_db_instance_1" has lines with following column values
      | name-0  | db_group-1 | addr-2      | port-3 | user-4 | encrypt_configured-5 | primary-6 | disabled-7 | min_conn_count-8 | max_conn_count-9 | read_weight-10 | id-11 |
      | hostM1  | ha_group1  | 172.100.9.5 | 3306   | test   | false                | true      | true       | 10               | 100              | 3              | test3 |
      | hostM2  | ha_group2  | 172.100.9.6 | 3306   | test   | false                | true      | false      | 10               | 1000             | 3              | test3 |
      | hostM3  | ha_group3  | 172.100.9.6 | 3306   | test   | false                | true      | true       | 10               | 1000             | 3              | test3 |
      | hostS31 | ha_group3  | 172.100.9.6 | 3307   | test   | false                | false     | false      | 1                | 1000             | 3              | test3 |
      | hostS32 | ha_group3  | 172.100.9.6 | 3308   | test   | false                | false     | true       | 2                | 1000             | 3              | test3 |
      | hostM4  | ha_group4  | 172.100.9.6 | 3307   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | hostS52 | ha_group5  | 172.100.9.6 | 3308   | test   | false                | false     | false      | 0                | 1000             | 3              | test3 |
      | hostM5  | ha_group5  | 172.100.9.6 | 3306   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | hostS51 | ha_group5  | 172.100.9.6 | 3307   | test   | false                | false     | false      | 0                | 1000             | 3              | test3 |
      | hostM6  | ha_group6  | 172.100.9.4 | 3306   | test   | false                | true      | false      | 4                | 1000             | 3              | test3 |
      | hostM7  | ha_group7  | 172.100.9.5 | 3306   | test   | true                 | true      | false      | 4                | 1000             | 3              | test3 |
      | hostM12 | ha_group12 | 172.100.9.1 | 3306   | test   | false                | true      | false      | 9                | 1000             | 3              | test3 |
      | hostS11 | ha_group11 | 172.100.9.6 | 3307   | test   | false                | false     | false      | 1                | 1000             | 3              | test3 |
      | hostM11 | ha_group11 | 172.100.9.6 | 3306   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | 0B02    | 0B02       | 172.100.9.6 | 3307   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | 0B03    | 0B03       | 172.100.9.6 | 3307   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |
      | 0B04    | 0B04       | 172.100.9.6 | 3307   | test   | false                | true      | false      | 1                | 1000             | 3              | test3 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_rw_split_entry_1"
      | conn   | toClose | sql                                          | db               |
      | conn_0 | true    | select * from dble_rw_split_entry            | dble_information |
    Then check resultset "dble_rw_split_entry_1" has lines with following column values
      | id-0 | type-1    | username-2 | encrypt_configured-4 | conn_attr_key-5 | conn_attr_value-6 | white_ips-7             | max_conn_count-8 | blacklist-9 | db_group-10 |
      | 3    | conn_attr | rw2        | false                | tenant          | tenant2           | 172.100.9.2/20          | 200              | None        | ha_group4   |
      | 4    | conn_attr | rw4        | false                | tenant          | tenant4           | 172.100.9.7-172.100.9.3 | 200              | None        | ha_group6   |
      | 5    | username  | rw5        | true                 | None            | None              | ::1                     | 100              | None        | ha_group4   |
      | 6    | username  | rw6        | false                | None            | None              | None                    | 100              | None        | ha_group3   |
      | 7    | username  | rw7        | false                | None            | None              | None                    | 100              | None        | ha_group4   |
      | 8    | username  | rw8        | false                | None            | None              | None                    | 100              | None        | ha_group5   |
      | 9    | conn_attr | rw9        | false                | tenant          | tenant5           | 172.%.9.%,172.100.%.1   | 200              | None        | ha_group6   |
      | 10   | username  | rw10       | false                | None            | None              | None                    | 100              | None        | ha_group6   |
      | 11   | conn_attr | rw20       | false                | tenant          | tenant00          | %.%.%.1                 | 200              | None        | ha_group7   |


    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                              | expect                                                                                                                    | db               |
      | conn_0 | false   | delete from dble_db_group,dble_db_instance where name='db_group9'                                | delete syntax error, not support delete Multiple-Table                                                                    | dble_information |
      | conn_0 | false   | delete from dble_db_group,dble_rw_split_entry where name='db_group9'                             | delete syntax error, not support delete Multiple-Table                                                                    | dble_information |
      | conn_0 | false   | delete from dble_db_instance,dble_rw_split_entry where name='db_group9'                          | delete syntax error, not support delete Multiple-Table                                                                    | dble_information |
      | conn_0 | false   | delete from dble_db_group where (select active from dble_db_group where heartbeat_retry=1)       | delete syntax error, not support sub-query                                                                                | dble_information |
      | conn_0 | false   | delete from dble_db_instance where (select active from dble_db_group where heartbeat_retry=1)    | delete syntax error, not support sub-query                                                                                | dble_information |
      | conn_0 | false   | delete from dble_rw_split_entry where (select active from dble_db_group where heartbeat_retry=1) | delete syntax error, not support sub-query                                                                                | dble_information |
      | conn_0 | false   | delete from dble_db_group                                                                        | delete syntax error, not support delete without WHERE                                                                     | dble_information |
      | conn_0 | false   | delete from dble_db_instance                                                                     | delete syntax error, not support delete without WHERE                                                                     | dble_information |
      | conn_0 | false   | delete from dble_rw_split_entry                                                                  | delete syntax error, not support delete without WHERE                                                                     | dble_information |
      | conn_0 | false   | delete LOW_PRIORITY from dble_db_group where name='db_group9'                                    | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete QUICK from dble_db_group where name='db_group9'                                           | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete IGNORE from dble_db_group where name='db_group9'                                          | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete from dble_db_group where name='db_group9' order by heartbeat_retry                        | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete from dble_db_group where name='db_group9' limit 2                                         | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete from dble_db_group a where name='db_group9'                                               | delete syntax error, not support delete with alias                                                                        | dble_information |
      | conn_0 | false   | delete LOW_PRIORITY from dble_db_instance where name='db_group9'                                 | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete QUICK from dble_db_instance where name='db_group9'                                        | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete IGNORE from dble_db_instance where name='db_group9'                                       | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete from dble_db_instance where name='db_group9' order by heartbeat_retry                     | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete from dble_db_instance where name='db_group9' limit 2                                      | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete from dble_db_instance a where name='db_group9'                                            | delete syntax error, not support delete with alias                                                                        | dble_information |
      | conn_0 | false   | delete LOW_PRIORITY from dble_rw_split_entry where db_group='db_group9'                          | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete QUICK from dble_rw_split_entry where db_group='db_group9'                                 | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete IGNORE from dble_rw_split_entry where db_group='db_group9'                                | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete from dble_rw_split_entry where db_group='db_group9' order by heartbeat_retry              | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete from dble_rw_split_entry where db_group='db_group9' limit 2                               | delete syntax error, not support delete with syntax :[LOW_PRIORITY] [QUICK] [IGNORE] ... [ORDER BY ...] [LIMIT row_count] | dble_information |
      | conn_0 | false   | delete from dble_rw_split_entry a where db_group='db_group9'                                     | delete syntax error, not support delete with alias                                                                        | dble_information |
      | conn_0 | false   | delete from dble_db_grou where name='db_group9'                                                  | Table `dble_information`.`dble_db_grou` doesn't exist           | dble_information |
      | conn_0 | false   | delete from dble_db_instan where name='db_group9'                                                | Table `dble_information`.`dble_db_instan` doesn't exist         | dble_information |
      | conn_0 | false   | delete from dble_rw_split_ent where name='db_group9'                                             | Table `dble_information`.`dble_rw_split_ent` doesn't exist      | dble_information |
      | conn_0 | false   | delete from dble_db_group where username='db_group9'                                             | unknown error:field not found:username        | dble_information |
      | conn_0 | false   | delete from dble_db_instance where group='db_group9'                                             | unknown error:field not found:group           | dble_information |
      | conn_0 | false   | delete from dble_rw_split_entry where white_ip='db_group9'                                       | unknown error:field not found:white_ip        | dble_information |
      | conn_0 | false   | delete from dble_db_group where heartbeat_retry BETWEEN 0 AND 2                                  | unknown error:not supportted yet!        | dble_information |
      | conn_0 | false   | delete from dble_db_instance where max_conn_count BETWEEN 0 AND 2                                | unknown error:not supportted yet!        | dble_information |
      | conn_0 | false   | delete from dble_rw_split_entry where max_conn_count BETWEEN 0 AND 2                             | unknown error:not supportted yet!        | dble_information |

      | conn_0 | false   | delete from dble_db_group where active ='true'                                 | Delete failure.The reason is Cannot delete or update a parent row: a foreign key constraint fails `dble_db_instance`(`db_group`) REFERENCES `dble_db_group`(`name`)    | dble_information |
      | conn_0 | false   | delete from dble_db_group where name ='ha_group2'                              | Delete failure.The reason is Cannot delete or update a parent row: a foreign key constraint fails `dble_db_instance`(`db_group`) REFERENCES `dble_db_group`(`name`)    | dble_information |

### coz  DBLE0REQ-2129
#    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
#      """
#      NullPointerException
#      """
    Then execute admin cmd "reload @@config_all"