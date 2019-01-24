Feature: Functional testing of global sequences
  @BLOCKER
  Scenario: Configuration test for local file mode #1
    #1 test config
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="test_auto" dataNode="dn1,dn2,dn3,dn4" primaryKey="id" autoIncrement="true" rule="hash-four" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="sequnceHandlerType">2</property>
    """
    Given Restart dble in "dble-1" success
    Then Testing the global sequence can used in table
    """
    {'sequnceHandlerType':2,'table':'test_auto'}
    """