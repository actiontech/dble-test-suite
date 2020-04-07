Feature: jumpstringhash sharding function test suits

  Scenario: jumpstringhash function #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <tableRule name="jump_string_hash_rule">
            <rule>
                <columns>id</columns>
                <algorithm>jump_string_hash_func</algorithm>
            </rule>
        </tableRule>
        <function class="jumpStringHash" name="jump_string_hash_func">
            <property name="partitionCount">4</property>
            <property name="hashSlice">0:2</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="jump_string_hash_table" dataNode="dn1,dn2,dn3,dn4" rule="jump_string_hash_rule" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                 | expect                  | db      |
      | conn_0 | False    | drop table if exists jump_string_hash_table         | success                 | schema1 |
      | conn_0 | False    | create table jump_string_hash_table(id varchar(10)) | success                 | schema1 |
      | conn_0 | False    | insert into jump_string_hash_table values(null)     | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into jump_string_hash_table values('aa')     | dest_node:mysql-master1 | schema1 |
      | conn_0 | False    | insert into jump_string_hash_table values('af')     | dest_node:mysql-master2 | schema1 |
      | conn_0 | False    | insert into jump_string_hash_table values('rr')     | dest_node:mysql-master1 | schema1 |
      | conn_0 | True     | insert into jump_string_hash_table values('zz')     | dest_node:mysql-master2 | schema1 |

    #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    {"table":"jump_string_hash_table","key":"id"}
    """
    #clearn all conf
    Given delete the following xml segment
      |file        | parent                                        | child                                                    |
      |rule.xml    | {'tag':'root'}                                | {'tag':'tableRule','kv_map':{'name':'jump_string_hash_rule'}} |
      |rule.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'jump_string_hash_func'}}  |
      |schema.xml  | {'tag':'schema','kv_map':{'name':'schema1'}}   | {'tag':'table','kv_map':{'name':'jump_string_hash_table'}}    |
    Then execute admin cmd "reload @@config_all"