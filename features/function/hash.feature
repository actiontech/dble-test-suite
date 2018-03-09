Feature:
  Scenario: #hash function
    #test: <= 2880
    Given Drop a tableRule "hash_rule" in rule.xml
    Given Drop a "hash_func" function in rule.xml
    Given Add a "hash_func" hash function in rule.xml
    """
    "partitionCount":4,"partitionLength":721
    """
    Then Test and check reload config failure
    """
    Sum(count[i]*length[i]) must be less than 2880
    """
    Given Drop a "hash_func" function in rule.xml
    #test: uniform
    Given Add a "hash_func" hash function in rule.xml
    """
    "partitionCount":4,"partitionLength":1
    """
    Given Add a tableRule consisting of "hash_rule","id","hash_func" in rule.xml
    Given Delete the "hash_table" table in the "mytest" logical database in schema.xml
    Given Add a table consisting of "mytest" in schema.xml
     """
     "name":"hash_table","rule":"hash_rule","dataNode":"dn1,dn2,dn3,dn4"
     """
    When Execute reload @@config_all
    Then Create table "hash_table" and check sharding
    """
    [{"name":"type","value":"number"},
    {"name":"key","value":"id"},
    {"name":"normal_value","value":"-1,-2,0,1,2,3"},
    {"name":"dn1","value":"0"},
    {"name":"dn2","value":"1"},
    {"name":"dn3","value":"2,-2"},
    {"name":"dn4","value":"3,-1"}]
    """
     #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    [{"name":"table","value":"hash_table"},
    {"name":"key","value":"id"}]
    """
    #test: data types in sharding_key
    Then Test the data types supported by the sharding column in "hashInteger.sql"
    #test: non-uniform
    Given Drop a tableRule "hash_rule" in rule.xml
    Given Drop a "hash_func" function in rule.xml
    Given Add a "hash_func" hash function in rule.xml
    """
    "partitionCount":"3,1","partitionLength":"200,300"
    """
    Given Add a tableRule consisting of "hash_rule","id","hash_func" in rule.xml
    Given Add a table consisting of "mytest" in schema.xml
     """
     "name":"hash_table","rule":"hash_rule","dataNode":"dn1,dn2,dn3,dn4"
     """
    When Execute reload @@config_all
    Then Create table "hash_table" and check sharding
    """
    [{"name":"type","value":"number"},
    {"name":"key","value":"id"},
    {"name":"normal_value","value":"-1,-2,-300,-301,0,1,2,199,200,399,400,599,600,999,1000"},
    {"name":"dn1","value":"0,1,2,199,999,1000"},
    {"name":"dn2","value":"200,399"},
    {"name":"dn3","value":"400,599,-301"},
    {"name":"dn4","value":"600,-1,-2,-300"}]
    """
    #clearn all conf
    Given Drop a tableRule "hash_rule" in rule.xml
    Given Drop a "hash_func" function in rule.xml
    Given Delete the "hash_table" table in the "mytest" logical database in schema.xml
    When Execute reload @@config_all