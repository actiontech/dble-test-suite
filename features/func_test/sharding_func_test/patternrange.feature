Feature: PatternRange sharding function test suits
  @smoke
  Scenario: PatternRange sharding function #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <tableRule name="patternrange_rule">
            <rule>
                <columns>id</columns>
                <algorithm>patternrange_func</algorithm>
            </rule>
        </tableRule>
        <function class="PatternRange" name="patternrange_func">
            <property name="mapFile">partition.txt</property>
            <property name="patternValue">1000</property>
            <property name="defaultNode">3</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="patternrange_table" dataNode="dn1,dn2,dn3,dn4" rule="patternrange_rule" />
    """
    #test: set not sEndDate and not defaultNode
    When Add some data in "partition.txt"
    """
    0-255=0
    256-500=1
    501-755=2
    756-1000=3
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                   | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists patternrange_table                      | success | mytest |
        | test | 111111 | conn_0 | False    | create table patternrange_table(id int)                      | success | mytest |
        | test | 111111 | conn_0 | False    | insert into patternrange_table values(null)/*dest_node:dn4*/   | success | mytest |
        | test | 111111 | conn_0 | False    | insert into patternrange_table values(-1)/*dest_node:dn4*/   | success | mytest |
        | test | 111111 | conn_0 | False    | insert into patternrange_table values(0)/*dest_node:dn1*/    | success | mytest |
        | test | 111111 | conn_0 | False    | insert into patternrange_table values(255)/*dest_node:dn1*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into patternrange_table values(256)/*dest_node:dn2*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into patternrange_table values(500)/*dest_node:dn2*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into patternrange_table values(501)/*dest_node:dn3*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into patternrange_table values(755)/*dest_node:dn3*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into patternrange_table values(756)/*dest_node:dn4*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into patternrange_table values(1000)/*dest_node:dn1*/ | success | mytest |
        | test | 111111 | conn_0 | True     | insert into patternrange_table values(1001)/*dest_node:dn1*/ | success | mytest |

    #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    {"table":"patternrange_table","key":"id"}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <function class="PatternRange" name="patternrange_func">
            <property name="mapFile">partition.txt</property>
            <property name="patternValue">1000</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                          | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists patternrange_table      | success | mytest |
        | test | 111111 | conn_0 | False    | create table patternrange_table(id int)      | success | mytest |
        | test | 111111 | conn_0 | False    | insert into patternrange_table values(null)  | can't find any valid data node | mytest |
        | test | 111111 | conn_0 | True     | insert into patternrange_table values(-1)    | can't find any valid data node | mytest |

    #test: data types in sharding_key
    #Then Test the data types supported by the sharding column in "partition.sql"
    #clearn all conf
    Given delete the following xml segment
      |file        | parent                                        | child                                  |
      |rule.xml    | {'tag':'root'}                                | {'tag':'tableRule','kv_map':{'name':'patternrange_rule'}} |
      |rule.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'patternrange_func'}}  |
      |schema.xml  | {'tag':'schema','kv_map':{'name':'mytest'}}   | {'tag':'table','kv_map':{'name':'patternrange_table'}}    |
    Then execute admin cmd "reload @@config_all"