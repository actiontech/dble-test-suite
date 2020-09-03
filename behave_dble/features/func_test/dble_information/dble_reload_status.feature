# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/9/2

Feature:  dble_reload_status test
@skip_restart
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
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_reload_status_2"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from  dble_reload_status | dble_information |
    Then check resultset "dble_reload_status_2" has lines with following column values
      | index-0 | cluster-1 | reload_type-2 | reload_status-3 | last_reload_start-4 | last_reload_end-5 | trigger_type-6 | end_type-7 |
      | 0       | None      |               | NOT_RELOADING   |                     |                   |                |            |
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
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_reload_status_3"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from  dble_reload_status | dble_information |
    Then check resultset "dble_reload_status_3" has lines with following column values
      | index-0 | cluster-1 | reload_type-2 | reload_status-3 | trigger_type-6 | end_type-7 |
      | 0       | None      | RELOAD_ALL    | NOT_RELOADING   | LOCAL_COMMAND  | RELOAD_END |

