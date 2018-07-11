Feature: #
  Scenario:  #1 test parameter"sqlMaxLimit" "dataNode" "needAddLimit"in schema.xml
     Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |

     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
      """
      <schema dataNode="dn5" name="mytest" sqlMaxLimit="3">
		    <table dataNode="dn1,dn3" name="test_table" type="global" />
      </schema>
     """
    Then execute admin cmd "reload @@config_all"
    Then execute sql
        | user | passwd | conn   | toClose  | sql                                                    | expect      | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_table                  | success | mytest |
        | test | 111111 | conn_0 | False    | create table test_table(id int)   | success     | mytest |
        | test | 111111 | conn_0 | False    | insert into test_table values(1),(2),(3),(4),(5)| success     | mytest |
        | test | 111111 | conn_0 | False    | drop table if exists default_table                  | success | mytest |
        | test | 111111 | conn_0 | False    | create table default_table(id int)                    | success | mytest |
        | test | 111111 | conn_0 | True     | insert into default_table values(1)/*dest_node:dn5*/    | success | mytest |
    Then get limited results
    """
    3
    """
    #1.2 test parameter "needAddLimit"
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema dataNode="dn5" name="mytest" sqlMaxLimit="3">
		    <table dataNode="dn1,dn3" name="test_table" type="global" needAddLimit="false"/>
      </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then get limited results
    """
    5
    """
  Scenario:# when table name has multiple values
     Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
     """
        <table name="test_table,test2_table" dataNode="dn1,dn2,dn3,dn4" type="global" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql
        | user | passwd | conn   | toClose  | sql                                           | expect              | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_table          | success             | mytest |
        | test | 111111 | conn_0 | False    | create table test_table(id int)          | success             | mytest |
        | test | 111111 | conn_0 | False    | show full tables                            | has{('test_table','BASE TABLE')}   | mytest |
        | test | 111111 | conn_0 | False    | drop table if exists test2_table          | success             | mytest |
        | test | 111111 | conn_0 | False    | create table test2_table(id int)          | success             | mytest |
        | test | 111111 | conn_0 | True    | show full tables                              | has{('test_table','BASE TABLE')}   | mytest |