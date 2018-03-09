Feature: Verify that the Reload @@config_all is effective for server.xml
  Scenario: Configuration test for local file mode
    Given Delete the "test_auto" table in the "mytest" logical database in schema.xml
    Given Add a table consisting of "mytest" in schema.xml
    """
    "name":"test_auto","primaryKey":"id","autoIncrement":"true","rule":"hash-four","dataNode":"dn1,dn2,dn3,dn4"
    """
    Given Add a system property consisting of "sequnceHandlerType","2" in server.xml
    Given Restart dble in "dble-1"
    Then Testing the global sequence can used in table
    """
    [{"name":"sequnceHanderType","value":"2"},
    {"name":"table","value":"test_auto"},
    {"name":"auto_col","value":"id"},
    {"name":"count","value":"1000"}]
    """