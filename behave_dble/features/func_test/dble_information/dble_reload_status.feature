# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/9/2


  @skip
 # DBLE0REQ-965
Feature:  dble_reload_status test
   Scenario:  dble_reload_status  table #1
  #case desc dble_reload_status
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_reload_status_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | desc dble_reload_status | dble_information |
    Then check resultset "dble_reload_status_1" has lines with following column values
      | Field-0           | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | index             | int(11)     | NO     | PRI   | None      |         |
      | cluster           | varchar(20) | NO     |       | None      |         |
      | reload_type       | varchar(20) | NO     |       | None      |         |
      | reload_status     | varchar(20) | NO     |       | None      |         |
      | last_reload_start | varchar(19) | NO     |       | None      |         |
      | last_reload_end   | varchar(19) | NO     |       | None      |         |
      | trigger_type      | varchar(20) | NO     |       | None      |         |
      | end_type          | varchar(20) | NO     |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                 | expect            | db               |
      | conn_0 | False   | desc dble_reload_status             | length{(8)}       | dble_information |
      | conn_0 | False   | select * from dble_reload_status    | length{(1)}       | dble_information |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_reload_status_2"
#      | conn   | toClose | sql                               | db               |
#      | conn_0 | False   | select * from  dble_reload_status | dble_information |
#    Then check resultset "dble_reload_status_2" has lines with following column values
#      | index-0 | cluster-1 | reload_type-2 | reload_status-3 | last_reload_start-4 | last_reload_end-5 | trigger_type-6 | end_type-7 |
#      | 0       | None      |               | NOT_RELOADING   |                     |                   |                |            |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_reload_status_3"
#      | conn   | toClose | sql                     | db               |
#      | conn_0 | False   | show @@reload_status    | dble_information |
#    Then check resultsets "dble_reload_status_2" and "dble_reload_status_3" are same in following columns
#      | column             | column_index |
#      | index              | 0            |
#      | cluster            | 1            |
#      | reload_type        | 2            |
#      | reload_status      | 3            |
#      | last_reload_start  | 4            |
#      | last_reload_end    | 5            |
#      | trigger_type       | 6            |
#      | end_type           | 7            |

  #case change sharding.xml and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="er_parent" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
            <childTable name="er_child" joinColumn="id" parentColumn="id"/>
        </shardingTable>
    </schema>
     <schema shardingNode="dn1" name="schema2" sqlMaxLimit="1000">
        <singleTable name="test1"  shardingNode="dn1" />
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <globalTable name="global_4_t1" shardingNode="dn1,dn2,dn3,dn4" />
     </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    	<shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_reload_status_4"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from  dble_reload_status | dble_information |
    Then check resultset "dble_reload_status_4" has lines with following column values
      | index-0 | cluster-1 | reload_type-2 | reload_status-3 | trigger_type-6 | end_type-7 |
      | 0       | None      | RELOAD_ALL    | NOT_RELOADING   | LOCAL_COMMAND  | RELOAD_END |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_reload_status_5"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | show @@reload_status    | dble_information |
    Then check resultsets "dble_reload_status_4" and "dble_reload_status_5" are same in following columns
      | column             | column_index |
      | index              | 0            |
      | cluster            | 1            |
      | reload_type        | 2            |
      | reload_status      | 3            |
      | last_reload_start  | 4            |
      | last_reload_end    | 5            |
      | trigger_type       | 6            |
      | end_type           | 7            |
    Then execute admin cmd "reload @@metadata"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_reload_status_6"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from  dble_reload_status | dble_information |
    Then check resultset "dble_reload_status_6" has lines with following column values
      | index-0 | cluster-1 | reload_type-2  | reload_status-3 | trigger_type-6 | end_type-7 |
      | 1       | None      | RELOAD_META    | NOT_RELOADING   | LOCAL_COMMAND  | RELOAD_END |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_reload_status_7"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | show @@reload_status    | dble_information |
    Then check resultsets "dble_reload_status_6" and "dble_reload_status_7" are same in following columns
      | column             | column_index |
      | index              | 0            |
      | cluster            | 1            |
      | reload_type        | 2            |
      | reload_status      | 3            |
      | last_reload_start  | 4            |
      | last_reload_end    | 5            |
      | trigger_type       | 6            |
      | end_type           | 7            |
#case check reload_type has /manager_insert/manager_update/mamager_delete
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                                      | expect   | db                 |
      | conn_0 | False    | insert into DBLE_db_group set name='ha_group9',heartbeat_stmt='select 1',rw_split_mode=1 | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_reload_status_8"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from  dble_reload_status | dble_information |
    Then check resultset "dble_reload_status_8" has lines with following column values
      | cluster-1 | reload_type-2     | reload_status-3 | trigger_type-6 | end_type-7 |
      | None      | MANAGER_INSERT    | NOT_RELOADING   | LOCAL_COMMAND  | RELOAD_END |

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                              | expect   | db                 |
      | conn_0 | False    | update dble_db_group set heartbeat_retry=11 where active='true'  | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_reload_status_9"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from  dble_reload_status | dble_information |
    Then check resultset "dble_reload_status_9" has lines with following column values
      | cluster-1 | reload_type-2     | reload_status-3 | trigger_type-6 | end_type-7 |
      | None      | MANAGER_UPDATE    | NOT_RELOADING   | LOCAL_COMMAND  | RELOAD_END |

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                 | expect   | db                 |
      | conn_0 | False    | delete from  DBLE_db_group where name='ha_group9'   | success  | dble_information   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_reload_status_10"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from  dble_reload_status | dble_information |
    Then check resultset "dble_reload_status_10" has lines with following column values
      | cluster-1 | reload_type-2     | reload_status-3 | trigger_type-6 | end_type-7 |
      | None      | MANAGER_DELETE    | NOT_RELOADING   | LOCAL_COMMAND  | RELOAD_END |

#case unsupported update/delete/insert
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                        | expect                                           |
      | conn_0 | False   | delete from dble_reload_status where reload_type='RELOAD_META'                             | Access denied for table 'dble_reload_status'     |
      | conn_0 | False   | update dble_reload_status set reload_type = 'a' where reload_type='RELOAD_META'            | Access denied for table 'dble_reload_status'     |
      | conn_0 | True    | insert into dble_reload_status values (1,'1',1,1,1)                                        | Access denied for table 'dble_reload_status'     |







