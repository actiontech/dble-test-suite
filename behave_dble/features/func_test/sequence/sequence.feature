Feature: Functional testing of global sequences
  @BLOCKER @skip
  Scenario: test global sequnceHandlerType:1(timestamp) #1
#    case points:
#  1.sequence column can't be inserted by client
#  2.sequence column value should be unique
#  3.if sharding by sequence column, data distribution should be reasonable
#  4.single thread insert values to sequenceColumn, the values should be continuous
#  5.multiple thread insert values to sequenceColumn, the vlaues should be unique, and insert time should be tolerable(<1s)
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_auto" dataNode="dn1,dn2,dn3,dn4" primaryKey="id" autoIncrement="true" rule="hash-four" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="sequnceHandlerType">1</property>
    """
    When Add some data in "sequence_db_conf.properties"
    """
    `schema1`.`test_auto`=dn1
    """
    Then execute sqlFile to initialize sequence table
    Given Restart dble in "dble-1" success
    Then test queries with table using global sequence
    """
    {'sequnceHandlerType':1,'table':'test_auto'}
    """

  @BLOCKER @skip
  Scenario: test global sequnceHandlerType:2(timestamp) #2
#    case points:
#  1.sequence column can't be inserted by client
#  2.sequence column value should be unique
#  3.if sharding by sequence column, data distribution should be reasonable
#  4.multiple thread insert values to sequenceColumn, the vlaues should be unique, and insert time should be tolerable(<1s)
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_auto" dataNode="dn1,dn2,dn3,dn4" primaryKey="id" autoIncrement="true" rule="hash-four" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="sequnceHandlerType">2</property>
    """
    Given Restart dble in "dble-1" success
    Then test queries with table using global sequence
    """
    {'sequnceHandlerType':2,'table':'test_auto'}
    """