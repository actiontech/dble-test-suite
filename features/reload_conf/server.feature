Feature: Verify that the Reload @@config_all is effective for server.xml

  Scenario: #1 add/delete client user
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">test_password</property>
        <property name="schemas">mytest</property>
    </user>
    """
    Then excute admin cmd "reload @@config_all"
    Then Check add "client" user success
    """
    {"user":"test_user","password":"test_password","schemas":"mytest"}
    """

  Scenario: #test usingDecrypt
    Given encrypt passwd and add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">test_password</property>
        <property name="schemas">mytest</property>
        <property name="usingDecrypt">1</property>
    </user>
    """
    Then excute admin cmd "reload @@config_all"
    Then Check add "client" user success
      """
      {"user":"test_user","password":"test_password","schemas":"mytest"}
      """

  Scenario: #2 add/delete manager user
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">test_password</property>
        <property name="manager">true</property>
    </user>
    """
    Then excute admin cmd "reload @@config_all"
    Then Check add "manager" user success
    """
    {"user":"test_user","password":"test_password"}
    """

  Scenario: #3 add/delete privilege
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn5" name="testdb" sqlMaxLimit="100"></schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">test_password</property>
        <property name="schemas">mytest,testdb</property>
        <property name="readOnly">true</property>
        <privileges check="true">
            <schema name="mytest" dml="0000" >
                <table name="tableA" dml="1111"></table>
                <table name="tableB" dml="1111"></table>
            </schema>
            <schema name="testdb" dml="1111" >
                <table name="test1" dml="0000"></table>
                <table name="test2" dml="0110"></table>
            </schema>
        </privileges>
    </user>
    """
    Then excute admin cmd "reload @@config_all"

    Given delete the following xml segment
      |file        | parent           | child                                        |
      |server.xml  | {'tag':'root'}   | {'tag':'user','kv_map':{'name':'test_user'}} |
    Then excute admin cmd "reload @@config_all"
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
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <firewall>
      <blacklist check="true">
          <property name="selelctAllow">false</property>
      </blacklist>
    </firewall>
    """
    Then excute admin cmd "reload @@config_all"

    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <firewall>
        <whitehost>
            <host host="10.186.23.68" user="test"/>
            <host host="10.186.23.68" user="root"/>
            <host host="172.100.9.253" user="root"/>
            <host host="172.100.9.253" user="test"/>
        </whitehost>
    <firewall>
    """
    Then excute admin cmd "reload @@config_all"

    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <firewall>
        <whitehost>
            <host host="10.186.23.68" user="test"/>
            <host host="10.186.23.68" user="root"/>
            <host host="172.100.9.253" user="root"/>
            <host host="172.100.9.253" user="test"/>
            <blacklist check="true">
                <property name="selelctAllow">false</property>
            </blacklist>
        </whitehost>
    </firewall>
    """
    Then excute admin cmd "reload @@config_all"

    Given delete the following xml segment
      |file        | parent           | child              |
      |rule.xml    | {'tag':'root'}   | {'tag':'firewall'} |
    Then excute admin cmd "reload @@config_all"


 Scenario: #
   Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="bindIp">0.0.0.0</property>
        <property name="serverPort">8066</property>
        <property name="managerPort">9066</property>
        <property name="lowerCaseTableNames">true</property>
        <property name="processor">1</property>
        <property name="processorExecutor">32</property>
        <property name="fakeMySQLVersion">5.6.20</property>
        <property name="sequenceHandlerType">2</property>
        <property name="serverNodeId">1   </property>
        <property name="showBinlogStatusTimeout">60000</property>
        <property name="useCompression">1    </property>
        <property name="usingAIO">0    </property>
        <property name="useZKSwitch">true </property>
        <property name="charset">utf-8</property>
        <property name="maxPacketSize">16777216</property>
        <property name="txIsolation">3       </property>
        <property name="checkTableConsistency">0       </property>
        <property name="checkTableConsistencyPeriod">60000</property>
        <property name="useGlobleTableCheck">0    </property>
        <property name="glableTableCheckPeriod">86400000</property>
        <property name="dataNodeIdleCheckPeriod">300000  </property>
        <property name="dataNodeHeartbeatPeriod">10000   </property>
        <property name="processorCheckPeriod">1000    </property>
        <property name="sqlExecuteTimeout">300     </property>
        <property name="idleTimeout">1800000 </property>
        <property name="recordTxn">0       </property>
        <property name="transactionLogBaseDir">/txlogs </property>
        <property name="transactionLogBaseName">server-tx</property>
        <property name="transactionRatateSize">16       </property>
        <property name="xaSessionCheckPeriod">1000     </property>
        <property name="xaLogCleanPeriod">1000     </property>
        <property name="XARecoveryLogBaseDir">/tmlogs  </property>
        <property name="XARecoveryLogBaseName">tmlog    </property>
        <property name="useJoinStrategy">true     </property>
        <property name="nestLoopConnSize">4        </property>
        <property name="nestLoopRowsSize">2000     </property>
        <property name="bufferPoolChunkSize">4096     </property>
        <property name="bufferPoolPageNumber">512      </property>
        <property name="bufferPoolPageSize">2097152  </property>
        <property name="useOffHeapForMerge">1m       </property>
        <property name="spillsFileBufferSize">2k       </property>
        <property name="dataNodeSortedTempDir">/sortDirs</property>
        <property name="useSqlStat">0        </property>
        <property name="bufferUsagePercent">80        </property>
        <property name="clearBigSqLResultSetMapMs">600000   </property>
        <property name="sqlRecordCount">10            </property>
        <property name="maxResultSet">524288          </property>
        <property name="backSocketSoRcvbuf">4194304   </property>
        <property name="backSocketSoSndbuf">1048576   </property>
        <property name="backSocketNoDelay">1          </property>
        <property name="frontSocketSoRcvbuf">1048576  </property>
        <property name="frontSocketSoSndbuf">4194304  </property>
        <property name="frontSocketNoDelay">1         </property>
    </system>
    """
   Given Restart dble in "dble-1"
   When Execute "show @@sysparam" on the managerment client and check system property with "managerPort","9066"