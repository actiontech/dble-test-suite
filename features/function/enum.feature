Feature:
  Scenario: #Enum function
    #test: type:integer not default node
    Given Drop a tableRule "enum_rule" in rule.xml
    Given Drop a "enum_func" function in rule.xml
    Given Add a "enum_func" Enum function in rule.xml
    """
    "mapFile":"enum.txt","type":"0"
    """
    When Add some data in "enum.txt"
    """
    0=0
    aaa=0
    1=1
    bbb=1
    2=2
    3=3
    """
    Given Add a tableRule consisting of "enum_rule","id","enum_func" in rule.xml
    Given Add a table consisting of "mytest" in schema.xml
     """
     "name":"enum_table","rule":"enum_rule","dataNode":"dn1,dn2,dn3,dn4"
     """
    When Execute reload @@config_all
    Then Create table "enum_table" and check sharding
    """
    [{"name":"key","value":"id"},
    {"name":"type","value":"number"},
    {"name":"normal_value","value":"0,1,2,3"},
    {"name":"abnormal_value","value":"-1,4,5"},
    {"name":"error_type_value","value":"aaa,bbb"},
    {"name":"dn1","value":"0"},
    {"name":"dn2","value":"1"},
    {"name":"db3","value":"2"},
    {"name":"dn4","value":"3"}]
    """
    #test: type:string default node
    Given Drop a tableRule "enum_rule" in rule.xml
    Given Drop a "enum_func" function in rule.xml
    Given Add a "enum_func" Enum function in rule.xml
    """
    "mapFile":"enum.txt","type":"1","defaultNode":"3"
    """
    When Add some data in "enum.txt"
    """
    aaa=0
    bbb=1
    ccc=2
    ddd=3
    1=1
    2=2
    3=3
    """
    Given Add a tableRule consisting of "enum_rule","id","enum_func" in rule.xml
    Given Add a table consisting of "mytest" in schema.xml
     """
     "name":"enum_table","rule":"enum_rule","dataNode":"dn1,dn2,dn3,dn4"
     """
    When Execute reload @@config_all
    Then Create table "enum_table" and check sharding
    """
    [{"name":"key","value":"id"},
    {"name":"type","value":"string"},
    {"name":"normal_value","value":"0,1,2,3,aaa,bbb,ccc,ddd,eee"},
    {"name":"dn1","value":"aaa"},
    {"name":"dn2","value":"bbb,1"},
    {"name":"dn3","value":"ccc,2"},
    {"name":"dn4","value":"0,3,ddd,eee"}]
    """
    #test: data types in sharding_key
    Then Test the data types supported by the sharding column in "enum.sql"
    #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    [{"name":"table","value":"enum_table"},
    {"name":"key","value":"id"}]
    """
    #clearn all conf
    Given Drop a tableRule "enum_rule" in rule.xml
    Given Drop a "enum_func" function in rule.xml
    Given Delete the "enum_table" table in the "mytest" logical database in schema.xml
    When Execute reload @@config_all