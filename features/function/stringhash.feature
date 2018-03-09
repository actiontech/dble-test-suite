Feature:
  Scenario: #stringhash function
    #test: <= 2880
    Given Drop a tableRule "string_hash_rule" in rule.xml
    Given Drop a "string_hash_func" function in rule.xml
    Given Add a "string_hash_func" StringHash function in rule.xml
    """
    "partitionCount":4,"partitionLength":"721","hashSlice":"0:2"
    """
    Then Test and check reload config failure
    """
    Sum(count[i]*length[i]) must be less than 2880
    """
    #test: uniform
    Given Drop a tableRule "string_hash_rule" in rule.xml
    Given Drop a "string_hash_func" function in rule.xml
    Given Add a "string_hash_func" StringHash function in rule.xml
    """
    "partitionCount":4,"partitionLength":256,"hashSlice":"0:2"
    """
    Given Add a tableRule consisting of "string_hash_rule","id","string_hash_func" in rule.xml
    Given Add a table consisting of "mytest" in schema.xml
     """
     "name":"string_hash_table","rule":"string_hash_rule","dataNode":"dn1,dn2,dn3,dn4"
     """
    When Execute reload @@config_all
    Then Create table "string_hash_table" and check sharding
    """
    [{"name":"type","value":"string"},
    {"name":"key","value":"id"},
    {"name":"normal_value","value":"aa,bb,jj,rr,zz"},
    {"name":"dn1","value":"bb,aa"},
    {"name":"dn2","value":"jj"},
    {"name":"dn3","value":"rr"},
    {"name":"dn4","value":"zz"}]
    """
    #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    [{"name":"table","value":"string_hash_table"},
    {"name":"key","value":"id"}]
    """
     #test: data types in sharding_key
    #Then Test the data types supported by the sharding column in "hashString.sql"
    #test: non-uniform
    Given Drop a tableRule "string_hash_rule" in rule.xml
    Given Drop a "string_hash_func" function in rule.xml
    Given Add a "string_hash_func" StringHash function in rule.xml
    """
    "partitionCount":"2,1","partitionLength":"256,512","hashSlice":"0:2"
    """
    Given Add a tableRule consisting of "string_hash_rule","id","string_hash_func" in rule.xml
    Given Add a table consisting of "mytest" in schema.xml
     """
     "name":"string_hash_table","rule":"string_hash_rule","dataNode":"dn1,dn2,dn3"
     """
    When Execute reload @@config_all
    #Then Create table "string_hash_table" and check sharding
    """
    [{"name":"type","value":"string"},
    {"name":"key","value":"id"},
    {"name":"normal_value","value":"aa,bb,jj,rr,zz"},
    {"name":"dn1","value":"bb,aa,jj"},
    {"name":"dn2","value":"rr"},
    {"name":"dn3","value":"zz"}]
    """
    #clearn all conf
    Given Drop a tableRule "string_hash_rule" in rule.xml
    Given Drop a "string_hash_func" function in rule.xml
    Given Delete the "string_hash_table" table in the "mytest" logical database in schema.xml
    When Execute reload @@config_all