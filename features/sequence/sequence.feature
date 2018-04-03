Feature: Functional testing of global sequences
  Background: Use conf_template directory configuration
    Given Replace the existing configuration with the conf template directory

  Scenario: Configuration test for local file mode
    #1 test config
    Given Delete the "test_auto" table in the "mytest" logical database in schema.xml
    Given Add a table consisting of "mytest" in schema.xml
    """
    "name":"test_auto","primaryKey":"id","autoIncrement":"true","rule":"hash-four","dataNode:dn1,dn2,dn3,dn4"
    """
    Given Add a system property consisting of "sequnceHandlerType","2" in server.xml
    Given Restart dble in "dble-1"
    Then Testing the global sequence can used in table
    """
    [{"name":"sequnceHandlerType","value":"2"},
    {"name":"table","value":"test_auto"},
    {"name":"auto_col","value":"id"}]
    """
    Given Delete the "test_auto" table in the "mytest" logical database in schema.xml
    Given Add a tableRule consisting of "add_rule","auto_col","rule" in rule.xml
    Given Add a table consisting of "mytest" in schema.xml
    """
    "name":"test_auto","primaryKey":"auto_col","autoIncrement":"true","rule":"add_rule","dataNode:dn1,dn2,dn3,dn4"
    """
    Then excute admin cmd "reload @@config_all"
    Then Testing the global sequence can used in table
    """
    [{"name":"sequnceHandlerType","value":2},
    {"name":"table","value":"test_auto"},
    {"name":"auto_col","value":"auto_col"}]
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