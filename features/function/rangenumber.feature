Feature:
  Scenario: #PatternRange function
    Given Drop a tableRule "patternrange_rule" in rule.xml
    Given Drop a "patternrange_func" function in rule.xml
    Given Delete the "patternrange_table" table in the "mytest" logical database in schema.xml
    Given Add a table consisting of "mytest" in schema.xml
     """
     "name":"patternrange_table","rule":"patternrange_rule","dataNode":"dn1,dn2,dn3,dn4"
     """
    #test: set defaultNode
    Given Add a tableRule consisting of "patternrange_rule","id","patternrange_func" in rule.xml
    Given Add a "patternrange_func" Partition function in rule.xml
    """
    "mapFile":"partition.txt","patternValue":"1000","defaultNode":"3"
    """
    When Add some data in "partition.txt"
    """
    0-255=0
    256-500=1
    501-755=2
    756-1000=3
    """
    When Execute reload @@config_all
    Then Create table "patternrange_table" and check sharding
    """
    [{"name":"key","value":"id"},
    {"name":"type","value":"number"},
    {"name":"normal_value","value":"-1,0,255,256,500,501,755,756,1000,1001"},
    {"name":"dn1","value":"0,255,1001"},
    {"name":"dn2","value":"256,500"},
    {"name":"dn3","value":"501,755"},
    {"name":"dn4","value":"756,1000,-1"}]
    """
     #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    [{"name":"table","value":"patternrange_table"},
    {"name":"key","value":"id"}]
    """
    #test: not defaultNode
    Given Drop a tableRule "patternrange_rule" in rule.xml
    Given Drop a "patternrange_func" function in rule.xml
    Given Add a "patternrange_func" Partition function in rule.xml
    """
    "mapFile":"partition.txt","patternValue":"1000"
    """
    Given Add a tableRule consisting of "patternrange_rule","id","patternrange_func" in rule.xml
    When Execute reload @@config_all
    Then Create table "patternrange_table" and check sharding
    """
    [{"name":"key","value":"id"},
    {"name":"type","value":"number"},
    {"name":"normal_value","value":"0,255,256,500,501,755,756,1000,1001"},
    {"name":"abnormal_value","value":"-1,-2"},
    {"name":"dn1","value":"0,255,1001"},
    {"name":"dn2","value":"256,500"},
    {"name":"dn3","value":"501,755"},
    {"name":"dn4","value":"756,1000"}]
    """
    #test: data types in sharding_key
    Then Test the data types supported by the sharding column in "range.sql"
    #clearn all conf
    Given Drop a tableRule "patternrange_rule" in rule.xml
    Given Drop a "patternrange_func" function in rule.xml
    Given Delete the "patternrange_table" table in the "mytest" logical database in schema.xml
    When Execute reload @@config_all