Feature: Verify that the Reload @@config_all is effective for server.xml

  Scenario: #1 add/edit/drop tableRule
    Given Add a tableRule consisting of "add_rule","id","rule" in rule.xml
    When Execute reload @@config_all anomalous
    Given Edit a tableRule consisting of "add_rule","id_edit","-" rule.xml
    When Execute reload @@config_all anomalous
    Given Drop a tableRule "add_rule" in rule.xml
    When Execute reload @@config_all

  Scenario: #1 add/edit/drop HASH function
    Given Add a "add_rule" hash function in rule.xml
    """
    "partitionCount":4,"partitionLength":256
    """
    When Execute reload @@config_all
    Given Edit a "add_rule" hash function in rule.xml
    """
    "partitionCount":"1,3","partitionLength":"400,200"
    """
    When Execute reload @@config_all
    Given Drop a "add_rule" function in rule.xml
    When Execute reload @@config_all

  Scenario: #1 add/drop StringHASH function; edit need drop/add
    Given Add a "add_rule" StringHash function in rule.xml
    """
    "partitionCount":"4","partitionLength":"256","hashSlice":"0:2"
    """
    When Execute reload @@config_all
    Given Drop a "add_rule" function in rule.xml
    When Execute reload @@config_all

  Scenario: #1 add/edit/drop NumberRange function
    Given Add a "add_rule" NumberRange function in rule.xml
    """
    "mapFile":"numberrange.txt","defaultNode":"0","type":"0"
    """
    When Add some data in "numberrange.txt"
    '''
    0-200=0
    201-500=1
    501-1000=2
    1001-5000=3
    '''
    When Execute reload @@config_all
    Given Edit a "add_rule" NumberRange function in rule.xml
    """
    "mapFile":"numberrange.txt","defaultNode":"0"
    """
    When Execute reload @@config_all
    Given Drop a "add_rule" function in rule.xml
    When Execute reload @@config_all

  Scenario: #1 add/drop Enum function
    Given Add a "add_rule" Enum function in rule.xml
    """
    "mapFile":"enum.txt","defaultNode":"0","type":"0"
    """
    When Add some data in "enum.txt"
    '''
    1=0
    2=0
    3=0
    4=0
    5=1
    6=1
    7=1
    8=2
    9=3
    '''
    When Execute reload @@config_all
    Given Drop a "add_rule" function in rule.xml
    When Execute reload @@config_all

 Scenario: #1 add/edit/drop Date function
   Given Add a "add_rule" Date function in rule.xml
    """
    "dateFormat":"yyyy-MM-dd","sBeginDate":"2015-01-01","sEndDate":"2015-01-31","sPartionDay":"10","defaultNode":"0"
    """
    When Execute reload @@config_all
    Given Edit a "add_rule" Date function in rule.xml
    """
    "dateFormat":"yyyy-MM-dd","sBeginDate":"2015-01-01","sEndDate":"2015-01-31","sPartionDay":"10","defaultNode":"0"
    """
    When Execute reload @@config_all
    Given Drop a "add_rule" function in rule.xml
    When Execute reload @@config_all

  Scenario: #1 add/edit/drop Partition function
   Given Add a "add_rule" Partition function in rule.xml
    """
    "mapFile":"partition.txt","patternValue":"256","defaultNode":"0"
    """
    When Add some data in "partition.txt"
    '''
    0-100=0
    101-150=1
    151-200=2
    201-255=3
    '''
    When Execute reload @@config_all
    Given Drop a "add_rule" function in rule.xml
    When Execute reload @@config_all