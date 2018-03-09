Feature: #
 Scenario: #test add schema/sharding_table/global_table schema+table+user
   Given Add a table consisting of "mytest" in schema.xml
   """
   "name":"test_table","type":"global","dataNode":"dn1,dn2,dn3,dn4"
   """
   When Execute sql in manager
   """
   reload @@config_all
   """
   Then Check add table success
   """
   [{"name":"schema","value":"mytest"},
   {"name":"table","value":"test_table"},
   {"name":"type","value":"GLOBAL"}]
   """
   When Execute sql in manager
   """
   rollback @@config
   """
   Given Delete the "test_table" table in the "mytest" logical database in schema.xml

  Scenario: #test add/drop child table
    Given Delete the "test_table" table in the "mytest" logical database in schema.xml
    Given Add a table consisting of "mytest" in schema.xml
     """
     "name":"test_table","dataNode":"dn1,dn2,dn3,dn4","rule":"hash-four"
     """
    Given Delete the child table in schema.xml
    """
    {"schemaName":"mytest","tableName":"test_table","childTables":"","childName":"child_table"}
    """
    Given Add a " " of the "test_table " table in the "mytest" logical database in schema.xml
    """
    "name":"child_table","primaryKey":"id","joinKey":"id","parentKey":"id"
    """
    #test add/drop dataNode
    Given Delete the dataNode "testdn" in schema.xml
    Given Add the dataNode in schema.xml
    """
    {"name":"testdn","dataHost":"172.100.9.6","database":"db3"}
    """
    When Execute reload @@config_all