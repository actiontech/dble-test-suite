# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_algorithm test
@skip_restart
   Scenario:  dble_algorithm  table #1
  #case desc dble_algorithm
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_algorithm_1"
      | conn   | toClose | sql                 | db               |
      | conn_0 | False   | desc dble_algorithm | dble_information |
    Then check resultset "dble_algorithm_1" has lines with following column values
      | Field-0 | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name    | varchar(64) | NO     | PRI   | None      |         |
      | key     | varchar(64) | NO     | PRI   | None      |         |
      | value   | text        | NO     |       | None      |         |
      | is_file | varchar(5)  | NO     |       | None      |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_algorithm_2"
      | conn   | toClose | sql                          | db               |
      | conn_0 | False   | select * from dble_algorithm | dble_information |
    Then check resultset "dble_algorithm_2" has lines with following column values
      | name-0               | key-1           | value-2                                              | is_file-3 |
      | hash-two             | class           | com.actiontech.dble.route.function.PartitionByLong   | false     |
      | hash-two             | partitionCount  | 2                                                    | false     |
      | hash-two             | partitionLength | 1                                                    | false     |
      | hash-three           | class           | com.actiontech.dble.route.function.PartitionByLong   | false     |
      | hash-three           | partitionCount  | 3                                                    | false     |
      | hash-three           | partitionLength | 1                                                    | false     |
      | hash-four            | class           | com.actiontech.dble.route.function.PartitionByLong   | false     |
      | hash-four            | partitionCount  | 4                                                    | false     |
      | hash-four            | partitionLength | 1                                                    | false     |
      | hash-string-into-two | class           | com.actiontech.dble.route.function.PartitionByString | false     |
      | hash-string-into-two | partitionCount  | 2                                                    | false     |
      | hash-string-into-two | partitionLength | 1                                                    | false     |

  #case change sharding.xml add some schema/function  and reload
    Given delete the following xml segment
      | file         | parent         | child            |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_2_t2" shardingNode="dn3,dn4" function="hash-two" shardingColumn="two" incrementColumn="id"/>
        <shardingTable name="sharding_3_t1" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="three" sqlRequiredSharding="true"/>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="four"/>
        <shardingTable name="sharding_date_t1" shardingNode="dn1,dn2,dn3,dn4" function="date_default_rule" shardingColumn="date"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100">
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform" shardingColumn="code"/>
        <shardingTable name="sharding_4_t3" shardingNode="dn1,dn2,dn3,dn4" function="fixed_nonuniform" shardingColumn="fix"/>
        <shardingTable name="sharding_4_t4" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform_string_rule" shardingColumn="rule"/>
        <shardingTable name="sharding_4_t5" shardingNode="dn1,dn2,dn3,dn4" function="fixed_nonuniform_string_rule" shardingColumn="fixed"/>
    </schema>
     <function name="fixed_uniform" class="Hash">
        <property name="partitionCount">4</property>
        <property name="partitionLength">256</property>
     </function>
     <function name="fixed_nonuniform" class="Hash">
        <property name="partitionCount">2,1</property>
        <property name="partitionLength">256,512</property>
     </function>
     <function name="fixed_uniform_string_rule" class="StringHash">
        <property name="partitionCount">4</property>
        <property name="partitionLength">256</property>
        <property name="hashSlice">0:2</property>
     </function>
     <function name="fixed_nonuniform_string_rule" class="StringHash">
        <property name="partitionCount">2,1</property>
        <property name="partitionLength">256,512</property>
        <property name="hashSlice">0:2</property>
     </function>
     <function name="date_default_rule" class="Date">
        <property name="dateFormat">yyyy-MM-dd</property>
        <property name="sBeginDate">2016-12-01</property>
        <property name="sEndDate">2017-01-9</property>
        <property name="sPartionDay">10</property>
        <property name="defaultNode">0</property>
     </function>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    	<shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_sharding_table_2"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from dble_sharding_table | dble_information |
    Then check resultset "dble_sharding_table_2" has lines with following column values




