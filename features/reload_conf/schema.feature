Feature: #
  Scenario: #test add schema/sharding_table/global_table schema+table+user
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" type="global" />
    """
    Then excute admin cmd "reload @@config_all"
    Then execute sql
        | user | passwd | conn   | toClose  | sql                                           | expect                             | db     |
        | test | 111111 | conn_0 | False    | create table if not exists test_table(id int) | success                            | mytest |
        | test | 111111 | conn_0 | False    | show full tables                              | has{('test_table','GLOBAL TABLE')} | mytest |
        | test | 111111 | conn_0 | False    | drop table test_table                         | success                            | mytest |
    Then excute admin cmd "rollback @@config"
    Given delete the following xml segment
      |file        | parent                                       | child                                           |
      |schema.xml  |{'tag':'schema','kv_map':{'name':'mytest'}}   | {'tag':'table','kv_map':{'name':'test_table'}}  |

  Scenario: #test add/drop child table
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" >
            <childTable name="child_table" primaryKey="id" joinKey="id" parentKey="id" />
        </table>
    """
    #test add/drop dataNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataNode dataHost="172.100.9.6" database="db3" name="testdn"/>
    """
    Then excute admin cmd "reload @@config_all"
    Given delete the following xml segment
      |file        | parent                                        | child                                          |
      |schema.xml  |{'tag':'schema','kv_map':{'name':'mytest'}}   | {'tag':'table','kv_map':{'name':'test_table'}}  |
    Then excute admin cmd "reload @@config_all"