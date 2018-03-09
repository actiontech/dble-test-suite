Feature: Verify that the Reload @@config_all is effective for server.xml

  Scenario: #1 add/delete client user
    Then Delete the user "test_user"
    Given Add a user consisting of "test_user" in server.xml
    """
    "password":"test_password","schemas":"mytest"
    """
    When execute reload @@config_all
    Then Check add "client" user success
    """
    {"user":"test_user","password":"test_password","schemas":"mytest"}
    """
    Then Delete the user "test_user"

  Scenario: #test usingDecrypt
    Then Delete the user "test_user"
    Given Add a user consisting of "test_user" in server.xml
      """
      "password":"test_password","schemas":"mytest","usingDecrypt":"1"
      """
    When execute reload @@config_all
    Then Check add "client" user success
      """
      {"user":"test_user","password":"test_password","schemas":"mytest"}
      """
    Then Delete the user "test_user"

  Scenario: #2 add/delete manager user
   Then Delete the user "test_user"
    Given Add a user consisting of "test_user" in server.xml
    """
    "password":"test_password","manager":"true"
    """
    When Execute reload @@config_all
    Then Check add "manager" user success
    """
    {"user":"test_user","password":"test_password"}
    """
    Then Delete the user "test_user"

  Scenario: #3 add/delete privilege
    Then Delete the "testdb" schema in schema.xml
    Given Add a "testdb" schema in schema.xml
    """
    "dataNode":"dn5","sqlMaxLimit":"100"
    """
    Then Delete the user "test_user"
    Given Add a user consisting of "test_user" in server.xml
    """
    "password":"test_password","schemas":"mytest,testdb","readOnly":"true"
    """
    Given Add a privilege of "test_user" user in server.xml
    """
    "privileges"="fathernode:test_user,check:true"
    "schemas"="name:mytest,dml:0000&name:testdb,dml:1111"
    "tables"="fathernode:mytest,name:tableA,dml:1111&fathernode:mytest,name:tableB,dml:1111&fathernode:testdb,name:test1,dml:0000&fathernode:testdb,name:test2,dml:0110"
    """
     When Execute reload @@config_all
    Then Delete the privilege of "test_user" user in server.xml
    When Execute reload @@config_all
#    Then Check the privilege of user "test_user"
#    """
#    [{"readOnly":"true"},
#    {"privilege":"true"},
#    {"schema":"mytest","dml":"0000","table":
#    [{"name":"tableA","dml":"1111"},
#    {"name":"tableB","dml":"1111"}]
#    },
#    {"schema":"testdb","dml":"1111","table":
#    [{"name":"test1","dml":"0000"},
#    {"name":"test2","dml":"0110"}]
#    }]
#    """

  Scenario: #4 add/delete Firewall
    Then Delete the Firewall in schema.xml
    Given Add a Firewall in schema.xml
    """
    "blacklist"="check:true"
    "propertys"="name:selelctAllow"
    "values"="fatherNode:selelctAllow,value:false"
    """
    When Execute reload @@config_all
    Then Delete the Firewall in schema.xml
    Given Add a Firewall in schema.xml
    """
    "hosts"="host:10.186.23.68,user:test&host:10.186.23.68,user:root&host:172.100.9.253,user:root&host:172.100.9.253,user:test"
    """
    When Execute reload @@config_all
    Given Add a Firewall in schema.xml
    """
    "hosts"="host:10.186.23.68,user:test&host:10.186.23.68,user:root&host:172.100.9.253,user:root&host:172.100.9.253,user:test"
    "blacklist"="check:true"
    "propertys"="name:selelctAllow"
    "values"="fatherNode:selelctAllow,value:false"
    """
    When Execute reload @@config_all
    Then Delete the Firewall in schema.xml
    When Execute reload @@config_all


 Scenario: #
   Given Add some system propertys in server.xml
    |name|text|
    |bindIp|0.0.0.0|
    |serverPort|8066|
    |managerPort|9066|
    |lowerCaseTableNames|true|
    |processor   |1          |
    |processorExecutor|32    |
    |fakeMySQLVersion |5.6.20|
    |sequenceHandlerType|2   |
    |serverNodeId       |1   |
    |showBinlogStatusTimeout|60000|
    |useCompression         |1    |
    |usingAIO               |0    |
    |useZKSwitch            |true |
    |charset                |utf-8|
    |maxPacketSize          |16777216|
    |txIsolation            |3       |
    |checkTableConsistency  |0       |
    |checkTableConsistencyPeriod|60000|
    |useGlobleTableCheck        |0    |
    |glableTableCheckPeriod     |86400000|
    |dataNodeIdleCheckPeriod    |300000  |
    |dataNodeHeartbeatPeriod    |10000   |
    |processorCheckPeriod       |1000    |
    |sqlExecuteTimeout          |300     |
    |idleTimeout                |1800000 |
    |recordTxn                  |0       |
    |transactionLogBaseDir      |/txlogs |
    |transactionLogBaseName     |server-tx|
    |transactionRatateSize      |16       |
    |xaSessionCheckPeriod       |1000     |
    |xaLogCleanPeriod           |1000     |
    |XARecoveryLogBaseDir       |/tmlogs  |
    |XARecoveryLogBaseName      |tmlog    |
    |useJoinStrategy            |true     |
    |nestLoopConnSize           |4        |
    |nestLoopRowsSize           |2000     |
    |bufferPoolChunkSize        |4096     |
    |bufferPoolPageNumber       |512      |
    |bufferPoolPageSize         |2097152  |
    |useOffHeapForMerge         |1m       |
    |spillsFileBufferSize       |2k       |
    |dataNodeSortedTempDir      |/sortDirs|
    |useSqlStat                 |0        |
    |bufferUsagePercent         |80       |
    |clearBigSqLResultSetMapMs  |600000   |
    |sqlRecordCount             |10       |
    |maxResultSet               |524288   |
    |backSocketSoRcvbuf         |4194304  |
    |backSocketSoSndbuf         |1048576  |
    |backSocketNoDelay          |1        |
    |frontSocketSoRcvbuf        |1048576  |
    |frontSocketSoSndbuf        |4194304  |
    |frontSocketNoDelay         |1        |
   Given Restart dble in "dble-1"
    When Log in "management" client

 Scenario: #2
   Given Add a system property consisting of "managerPort","9066" in server.xml
   Given Restart dble in "dble-1"
   When Execute "show @@sysparam" on the managerment client and check system property with "managerPort","9066"

 Scenario: #2
   Given Edit a system property consisting of "managerPort","9066" in server.xml
   Given Restart dble in "dble-1"
   When Execute "show @@sysparam" on the managerment client and check system property with "managerPort","9066"
