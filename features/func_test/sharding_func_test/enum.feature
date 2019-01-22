Feature:enum sharding function
  @smoke
  Scenario: Enum sharding function #1
    #test: type:integer not default node
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <tableRule name="enum_rule">
            <rule>
                <columns>id</columns>
                <algorithm>enum_func</algorithm>
            </rule>
        </tableRule>
        <function class="Enum" name="enum_func">
            <property name="mapFile">enum.txt</property>
            <property name="type">0</property>
        </function>
    """
    When Add some data in "enum.txt"
    """
    0=0
    aaa=0
    1=1
    bbb=1
    2=2
    3=3
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="enum_table" dataNode="dn1,dn2,dn3,dn4" rule="enum_rule" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                           | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists enum_table                               | success | mytest |
        | test | 111111 | conn_0 | False    | create table enum_table(id int)                               | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values (null)              | can't find any valid data node | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values (0)/*dest_node:dn1*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values (1)/*dest_node:dn2*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values (2)/*dest_node:dn3*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values (3)/*dest_node:dn4*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values (-1)                  | can't find any valid data node | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values (4)                   | can't find any valid data node | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values (5)                   | can't find any valid data node | mytest |
        | test | 111111 | conn_0 | True     | insert into enum_table values ('aaa')               | Please check if the format satisfied | mytest |

    #test: type:string default node
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <function class="Enum" name="enum_func">
            <property name="mapFile">enum.txt</property>
            <property name="type">1</property>
            <property name="defaultNode">3</property>
        </function>
    """
    When Add some data in "enum.txt"
    """
    aaa=0
    bbb=1
    ccc=2
    ddd=3
    1=1
    2=2
    3=3
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                           | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists enum_table                               | success | mytest |
        | test | 111111 | conn_0 | False    | create table enum_table(id varchar(10))                       | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values(null)/*dest_node:dn4*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values(0)/*dest_node:dn4*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values(1)/*dest_node:dn2*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values(2)/*dest_node:dn3*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values(3)/*dest_node:dn4*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values('aaa')/*dest_node:dn1*/ | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values('bbb')/*dest_node:dn2*/ | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values('ccc')/*dest_node:dn3*/ | success | mytest |
        | test | 111111 | conn_0 | False    | insert into enum_table values('ddd')/*dest_node:dn4*/ | success | mytest |
        | test | 111111 | conn_0 | True     | insert into enum_table values('eee')/*dest_node:dn4*/ | success | mytest |

    #test: data types in sharding_key
    Then Test the data types supported by the sharding column in "enum.sql"
    #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    {"table":"enum_table","key":"id"}
    """
    #clearn all conf
    Given delete the following xml segment
      |file        | parent                                        | child                                  |
      |rule.xml    | {'tag':'root'}                                | {'tag':'tableRule','kv_map':{'name':'enum_rule'}} |
      |rule.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'enum_func'}}  |
      |schema.xml  | {'tag':'schema','kv_map':{'name':'mytest'}}   | {'tag':'table','kv_map':{'name':'enum_table'}}    |
    Then execute admin cmd "reload @@config_all"