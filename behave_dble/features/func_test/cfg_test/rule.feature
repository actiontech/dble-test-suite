# Copyright (C) 2016-2021 ActionTech.
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
  @TRIVIAL
  Scenario: illegal tableRule will make reload fail #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <tableRule name="add_rule">
            <rule>
                <columns>id</columns>
            </rule>
        </tableRule>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <tableRule name="add_rule">
            <rule>
                <columns>id_edit</columns>
                <algorithm>-</algorithm>
            </rule>
        </tableRule>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """

  @NORMAL
  Scenario: config Hash sharding will reload success #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
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
  Scenario: config NumberRange sharding will reload success #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
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
  Scenario: config Enum sharding will relaod success #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
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