Feature:
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