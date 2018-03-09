Feature: # Function
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

  Scenario: #Date function
    Given Drop a tableRule "date_rule" in rule.xml
    Given Drop a "date_func" function in rule.xml
    #test: sBeginDate not configured
    Given Add a "date_func" Date function in rule.xml
    """
    "dateFormat":"yyyy-MM-dd","sEndDate":"2018-01-31","sPartionDay":"10"
    """
    Then Test and check reload config failure
    """
    The reason is com.actiontech.dble.config.util.ConfigException: java.lang.NullPointerException
    """
    #test: sBegin < sEndDate-nodes*sPartition+1
    Given Drop a "date_func" function in rule.xml
    Given Add a "date_func" Date function in rule.xml
    """
    "dateFormat":"yyyy-MM-dd","sBeginDate":"2017-01-01","sEndDate":"2018-01-31","sPartionDay":"10"
    """
    Given Add a tableRule consisting of "date_rule","id","date_func" in rule.xml
    Given Delete the "date_table" table in the "mytest" logical database in schema.xml
    Given Add a table consisting of "mytest" in schema.xml
     """
     "name":"date_table","rule":"date_rule","dataNode":"dn1,dn2,dn3,dn4"
     """
    Then Test and check reload config failure
    """
    please make sure table datanode size = function partition size
    """
    #test: set sBeginDate and defaultNode
    Given Drop a tableRule "date_rule" in rule.xml
    Given Drop a "date_func" function in rule.xml
    Given Add a tableRule consisting of "date_rule","id","date_func" in rule.xml
    Given Add a "date_func" Date function in rule.xml
    """
    "dateFormat":"yyyy-MM-dd","sBeginDate":"2017-12-01","sEndDate":"2018-01-8","sPartionDay":"10","defaultNode":3
    """
    When Execute reload @@config_all
    Then Create table "date_table" and check sharding
    """
    [{"name":"key","value":"id"},
    {"name":"type","value":"date"},
    {"name":"normal_value","value":"2017-11-11,2017-12-01,2017-12-11,2017-12-21,2017-12-31,2018-1-8,2018-01-9"},
    {"name":"dn1","value":"2017-12-01"},
    {"name":"dn2","value":"2017-12-11"},
    {"name":"dn3","value":"2017-12-21"},
    {"name":"dn4","value":"2018-01-8,2018-01-9,2017-11-11,2017-12-31"}]
    """
    #test: set sEndDate and not defaultNode
    Given Drop a tableRule "date_rule" in rule.xml
    Given Drop a "date_func" function in rule.xml
    Given Add a tableRule consisting of "date_rule","id","date_func" in rule.xml
    Given Add a "date_func" Date function in rule.xml
    """
    "dateFormat":"yyyy-MM-dd","sBeginDate":"2017-12-01","sEndDate":"2018-01-8","sPartionDay":"10"
    """
    When Execute reload @@config_all
    Then Create table "date_table" and check sharding
    """
    [{"name":"key","value":"id"},
    {"name":"type","value":"date"},
    {"name":"normal_value","value":"2017-12-01,2017-12-11,2017-12-21,2017-12-31,2018-1-8,2018-01-9"},
    {"name":"abnormal_value","value":"2017-11-11"},
    {"name":"dn1","value":"2017-12-01"},
    {"name":"dn2","value":"2017-12-11"},
    {"name":"dn3","value":"2017-12-21"},
    {"name":"dn4","value":"2018-01-8,2018-01-9,2017-12-31"}]
    """
     #test: not sEndDate and set defaultNode
    Given Drop a tableRule "date_rule" in rule.xml
    Given Drop a "date_func" function in rule.xml
    Given Add a tableRule consisting of "date_rule","id","date_func" in rule.xml
    Given Add a "date_func" Date function in rule.xml
    """
    "dateFormat":"yyyy-MM-dd","sBeginDate":"2017-12-01","sPartionDay":"10","defaultNode":"3"
    """
    When Execute reload @@config_all
    Then Create table "date_table" and check sharding
    """
    [{"name":"key","value":"id"},
    {"name":"type","value":"date"},
    {"name":"normal_value","value":"2017-11-11,2017-12-01,2017-12-11,2017-12-21,2017-12-31,2018-1-8"},
    {"name":"abnormal_value","value":"2018-11-11"},
    {"name":"dn1","value":"2017-12-01"},
    {"name":"dn2","value":"2017-12-11"},
    {"name":"dn3","value":"2017-12-21"},
    {"name":"dn4","value":"2018-01-8,2017-12-31,2017-11-11"}]
    """
    #test: set not sEndDate and not defaultNode
    Given Drop a tableRule "date_rule" in rule.xml
    Given Drop a "date_func" function in rule.xml
    Given Add a tableRule consisting of "date_rule","id","date_func" in rule.xml
    Given Add a "date_func" Date function in rule.xml
    """
    "dateFormat":"yyyy-MM-dd","sBeginDate":"2017-12-01","sPartionDay":"10"
    """
    When Execute reload @@config_all
    Then Create table "date_table" and check sharding
    """
    [{"name":"key","value":"id"},
    {"name":"type","value":"date"},
    {"name":"normal_value","value":"2017-12-01,2017-12-11,2017-12-21,2017-12-31,2018-1-8"},
    {"name":"abnormal_value","value":"2017-11-11,2018-11-11"},
    {"name":"dn1","value":"2017-12-01"},
    {"name":"dn2","value":"2017-12-11"},
    {"name":"dn3","value":"2017-12-21"},
    {"name":"dn4","value":"2018-01-8,2018-01-9,2017-12-31"}]
    """
     #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    [{"name":"table","value":"date_table"},
    {"name":"key","value":"id"}]
    """
     #test: data types in sharding_key
    Then Test the data types supported by the sharding column in "date.sql"
    #clearn all conf
    Given Drop a tableRule "date_rule" in rule.xml
    Given Drop a "date_func" function in rule.xml
    Given Delete the "date_table" table in the "mytest" logical database in schema.xml
    When Execute reload @@config_all

  Scenario: #PatternRange function
    Given Drop a tableRule "patternrange_rule" in rule.xml
    Given Drop a "patternrange_func" function in rule.xml
    Given Delete the "patternrange_table" table in the "mytest" logical database in schema.xml
    Given Add a table consisting of "mytest" in schema.xml
     """
     "name":"patternrange_table","rule":"patternrange_rule","dataNode":"dn1,dn2,dn3,dn4"
     """
    #test: set not sEndDate and not defaultNode
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
    #test: data types in sharding_key
    #Then Test the data types supported by the sharding column in "partition.sql"
    #clearn all conf
    Given Drop a tableRule "patternrange_rule" in rule.xml
    Given Drop a "patternrange_func" function in rule.xml
    Given Delete the "patternrange_table" table in the "mytest" logical database in schema.xml
    When Execute reload @@config_all