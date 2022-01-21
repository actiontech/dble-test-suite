# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: Verify that Reload @@config_all would success with correct sharding rule
#  shardingRuleConfigClass realClass
# ---------------------------------------
# Date Date
# PatternRange Partition
# Enum Enum
# NumberRange NumberRange
# StringHash StringHash
# hash hash

  @NORMAL
  Scenario: config Hash sharding will reload success #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="Hash" name="rule_func1">
            <property name="partitionCount">4</property>
            <property name="partitionLength">256</property>
        </function>
        <function class="Hash" name="rule_func2">
            <property name="partitionCount">1,3</property>
            <property name="partitionLength">400,200</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all"

  @TRIVIAL
  Scenario: config NumberRange sharding will reload success #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="NumberRange" name="rule_func1">
            <property name="mapFile">numberrange.txt</property>
            <property name="defaultNode">0</property>
        </function>
        <function class="NumberRange" name="rule_func2">
            <property name="mapFile">numberrange.txt</property>
            <property name="defaultNode">0</property>
        </function>
    """
    When Add some data in "numberrange.txt"
    """
    0-200=0
    201-500=1
    501-1000=2
    1001-5000=3
    """
    Then execute admin cmd "reload @@config_all"

  @TRIVIAL
  Scenario: config Enum sharding will relaod success #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <function class="Enum" name="add_rule">
            <property name="mapFile">enum.txt</property>
            <property name="defaultNode">0</property>
            <property name="type">0</property>
        </function>
    """
    When Add some data in "enum.txt"
    """
    1=0
    2=0
    3=0
    4=0
    5=1
    6=1
    7=1
    8=2
    9=3
    """
    Then execute admin cmd "reload @@config_all"


  Scenario: config jumpStringHash sharding has default hashSlice will relaod success #4
     ### DBLE0REQ-1272    default  :<property name="hashSlice">0:-1</property>
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
          <shardingTable name="test" shardingNode="dn1,dn2" function="func_jumpHash" shardingColumn="id"/>
        </schema>

         <function name="func_jumpHash" class="jumpStringHash">
         <property name="partitionCount">2</property>
         </function>
      """
    Then execute admin cmd "Reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                          | db      |
      | conn_0 | False    | drop table if exists test    | schema1 |
      | conn_0 | False    | create table test(id int)    | schema1 |
      | conn_0 | False    | insert into test values(11)  | schema1 |
      | conn_0 | False    | insert into test values(12)  | schema1 |
      | conn_0 | False    | insert into test values(13)  | schema1 |
      | conn_0 | False    | insert into test values(14)  | schema1 |
      | conn_0 | true     | drop table if exists test    | schema1 |


