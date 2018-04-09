Feature: Functional testing of global sequences
  Scenario: Configuration test for local file mode
    #1 test config
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="test_auto" dataNode="dn1,dn2,dn3,dn4" primaryKey="id" autoIncrement="true" rule="hash-four" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="sequnceHandlerType">2</property>
    """
    Given Restart dble in "dble-1"
    Then Testing the global sequence can used in table
    """
    [{"name":"sequnceHandlerType","value":"2"},
    {"name":"table","value":"test_auto"},
    {"name":"auto_col","value":"id"}]
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <tableRule name="add_rule">
            <rule>
                <columns>auto_col</columns>
                <algorithm>rule</algorithm>
            </rule>
        </tableRule>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="test_auto" dataNode="dn1,dn2,dn3,dn4" primaryKey="auto_col" autoIncrement="true" rule="add_rule" />
    """
    Then excute admin cmd "reload @@config_all"
    Then Testing the global sequence can used in table
    """
    [{"sequnceHandlerType":2},{"table":"test_auto"}]
    """

  Scenario: Configuration test for local file mode
    #2
    Given Delete the "test_auto" table in the "mytest" logical database in schema.xml
    Given Add a table consisting of "mytest","test_auto","primaryKey:id,autoIncrement:true,rule:hash-four,dataNode:dn1,dn2,dn3,dn4" in schema.xml
    Then excute admin cmd "reload @@config_all"
    Then Testing the global sequence can used in table
    """
    [{"name":"sequnceHandlerType","value":2},
    {"name":"table","value":"test_auto"},
    {"name":"auto_col","value":"auto_col"}]
    """
    Then Testing the auto_inc data type constraint:"2","test_auto","id","int"
    Then Testing display specified is not supported for auto_inc columns:"2","test_auto","id"
    Then Testing No auto_inc keys are specified when building a table:"2","test_auto","id"
    Then Testing Global Sequence Uniqueness and uniform partch :"2","test_auto","id","1000"