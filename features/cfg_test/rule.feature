# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
Feature: Verify that the Reload @@config_all is effective for server.xml
#Date Date
#PatternRange Partition
#Enum Enum
#NumberRange NumberRange
#StringHash StringHash
#hash hash
  Scenario: #1 add/edit/drop tableRule
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
    Given delete the following xml segment
      |file        | parent                 | child                                            |
      |rule.xml    | {'tag':'root'}         | {'tag':'tableRule','kv_map':{'name':'add_rule'}} |
    Then execute admin cmd "reload @@config_all"

  Scenario: #2 add/edit/drop HASH function
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
    Given delete the following xml segment
      |file        | parent                 | child                                             |
      |rule.xml    | {'tag':'root'}         | {'tag':'function','kv_map':{'name':'rule_func1'}} |
      |rule.xml    | {'tag':'root'}         | {'tag':'function','kv_map':{'name':'rule_func2'}} |
    Then execute admin cmd "reload @@config_all"

  Scenario: #3 add/edit/drop NumberRange function
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <function class="NumberRange" name="rule_func1">
            <property name="mapFile">numberrange.txt</property>
            <property name="defaultNode">0</property>
            <property name="type">0</property>
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
    Given delete the following xml segment
      |file        | parent                 | child                                             |
      |rule.xml    | {'tag':'root'}         | {'tag':'function','kv_map':{'name':'rule_func1'}} |
      |rule.xml    | {'tag':'root'}         | {'tag':'function','kv_map':{'name':'rule_func2'}} |
    Then execute admin cmd "reload @@config_all"

  Scenario: #4 add/drop Enum function
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
    Given delete the following xml segment
      |file        | parent                 | child                                             |
      |rule.xml    | {'tag':'root'}         | {'tag':'function','kv_map':{'name':'add_rule'}} |
    Then execute admin cmd "reload @@config_all"