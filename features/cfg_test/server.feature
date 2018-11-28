Feature: Verify that the Reload @@config_all is effective for server.xml

  @regression
  Scenario: #1 add/delete client user
     #1.1  client user with illegal label got error
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">test_password</property>
        <property name="schemas">mytest</property>
        <property name="test">0</property>
    </user>
    """
    Then execute admin cmd "reload @@config_all"
    """
    These properties of user[test_user]  are not recognized: test
    """
       #1.2 client user with readonly
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
     <user name="test_user">
        <property name="password">test_password</property>
        <property name="schemas">mytest</property>
        <property name="readOnly">true</property>
     </user>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd        | conn   | toClose | sql      | expect  | db     |
        | test_user    | test_password | conn_0 | False   | select 1 | success | mytest |
        | test_user    | test_password | conn_0 | True    | drop table if exists test_table | User READ ONLY | mytest |

     #1.3client user with schema which does not exist
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
     <user name="test_user3">
        <property name="password">test_password</property>
        <property name="schemas">testdb</property>
     </user>
    """
    Then Restart dble in "dble-1" failed for
     """
     schema testdb referred by user test_user3 is not exist!
     """
  Scenario: #2 test usingDecrypt
    Given encrypt passwd and add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">test_password</property>
        <property name="schemas">mytest</property>
        <property name="usingDecrypt">1</property>
    </user>
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd        | conn   | toClose | sql      | expect  | db     |
        | test_user    | test_password | conn_0 | True    | select 1 | success | mytest |

  Scenario: #3 server.xml only contains <user>
    Given delete the following xml segment
      |file        | parent           | child                                        |
      |server.xml  | {'tag':'root'}   | {'tag':'system'} |
    Given Restart dble in "dble-1" success

  Scenario: #4 both single & multiple manager user reload and do management cmd success
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "show @@version" with user "root_test" passwd "123"
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">test_password</property>
        <property name="manager">true</property>
    </user>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "show @@version" with user "test_user" passwd "test_password"

  Scenario: #5 add/delete privilege
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
    Then execute admin cmd "reload @@config_all"

    Given delete the following xml segment
      |file        | parent           | child                                        |
      |server.xml  | {'tag':'root'}   | {'tag':'user','kv_map':{'name':'test_user'}} |
    Then execute admin cmd "reload @@config_all"

  Scenario: #7 multiple system property start success
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="bindIp">0.0.0.0</property>
        <property name="serverPort">8066</property>
        <property name="managerPort">9066</property>
        <property name="processors">1</property>
        <property name="processorExecutor">32</property>
        <property name="fakeMySQLVersion">5.6.20</property>
        <property name="sequnceHandlerType">2</property>
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
        <property name="xaRecoveryLogBaseDir">/tmlogs  </property>
        <property name="xaRecoveryLogBaseName">tmlog    </property>
        <property name="useJoinStrategy">true     </property>
        <property name="nestLoopConnSize">4        </property>
        <property name="nestLoopRowsSize">2000     </property>
        <property name="bufferPoolChunkSize">4096     </property>
        <property name="bufferPoolPageNumber">512      </property>
        <property name="bufferPoolPageSize">2097152  </property>
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
    Given Restart dble in "dble-1" success
    Then execute admin cmd "show @@sysparam" get the following output
    """
    has{('managerPort','9066','Manager connection port. The default number is 9066')}
    """
  Scenario:#9 function of whitehost
    Given add xml segment to node with attribute "{'tag':'root','prev':'system'}" in "server.xml"
    """
    <firewall>
        <whitehost>
            <host host="172.100.9.253" user="root,test"/>
        </whitehost>
    </firewall>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">111111</property>
        <property name="schemas">mytest</property>
    </user>
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "show @@version" with user "root" passwd "111111"
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd        | conn   | toClose | sql      | expect  | db     |
        | test   | 111111 | conn_0 | True    | select 1 |success | mytest |
        | test_user   | 111111 | conn_0 | True    | select 1 |Access denied for user 'test_user' with host '172.100.9.253 | mytest |

  Scenario:#10 function of blacklist
    Given add xml segment to node with attribute "{'tag':'root','prev':'system'}" in "server.xml"
    """
    <firewall>
        <blacklist check="true">
                <property name="conditionDoubleConstAllow">false</property>
                <property name="conditionAndAlwayFalseAllow">false</property>
                 <property name="conditionAndAlwayTrueAllow">false</property>
                 <property name="constArithmeticAllow">false</property>
                 <property name="alterTableAllow">false</property>
                 <property name="commitAllow">false</property>
                 <property name="deleteAllow">false</property>
                 <property name="dropTableAllow">false</property>
                 <property name="insertAllow">false</property>
                 <property name="intersectAllow">false</property>
                 <property name="lockTableAllow">false</property>
                 <property name="minusAllow">false</property>
                 <property name="callAllow">false</property>
                 <property name="replaceAllow">false</property>
                 <property name="setAllow">false</property>
                 <property name="describeAllow">false</property>
                 <property name="limitZeroAllow">false</property>
                 <property name="conditionOpXorAllow">false</property>
                 <property name="conditionOpBitwseAllow">false</property>
                 <property name="startTransactionAllow">false</property>
                 <property name="truncateAllow">false</property>
                 <property name="updateAllow">false</property>
                 <property name="useAllow">false</property>
                 <property name="blockAllow">false</property>
                 <property name="deleteWhereNoneCheck">false</property>
                 <property name="updateWhereNoneCheck">false</property>
        </blacklist>
    </firewall>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd        | conn   | toClose | sql      | expect  | db     |
        | test         | 111111 | conn_0 | False    | create table if not exists test_table_1(id int) |success | mytest |
        | test         | 111111 | conn_0 | False    | create table if not exists test_table_12(id int) |success | mytest |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where 1 = 1 and 2 = 1; |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where id = 567 and 1!= 1 |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where id = 567 and 1 = 1 |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where id = 2-1 |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | alter table test_table_1 add name varchar(20)   |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | commit   |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | delete from test_table_1 where id =1   |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | drop table test_table_1   |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | insert test_table_1 values(1)   |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | intersect    |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | lock tables test_table_1 read  |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | minus    |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | call test_table_1    |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | replace into test_table_1(id)values (2)  |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | set xa =1    |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | describe test_table_1    |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 limit 0    |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where id = 1^1   |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where id = 1&1     |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | start transation    |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | truncate table test_table_1    |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | update test_table_1 set id =10 where id =1    |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | use mytest    |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | BEGIN select * from suntest;END;   |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | delete from test_table_1    |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | update test_table_1 set id =10   |error totally whack | mytest |
 #
    Given add xml segment to node with attribute "{'tag':'root','prev':'system'}" in "server.xml"
    """
    <firewall>
        <blacklist check="true">
                <property name="selelctAllow">false</property>
                <property name="createTableAllow">false</property>
                <property name="showAllow">false</property>
        </blacklist>
    </firewall>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd        | conn   | toClose | sql      | expect  | db     |
        | test         | 111111 | conn_0 | False    | create table if not exists test_table_1(id int) |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where 1 = 1 and 2 = 1; |error totally whack | mytest |
        | test         | 111111 | conn_0 | False    | show tables |error totally whack | mytest |

  Scenario: #11 test user maxCon, without system maxCon setting, user's maxCon 0 means using no checking
    Given delete the following xml segment
      |file        | parent           | child              |
      |server.xml  | {'tag':'root'}   | {'tag':'root'} |

    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
      <user name="root">
        <property name="password">111111</property>
        <property name="manager">true</property>
        <property name="maxCon">2</property>
      </user>
      <user name="test">
        <property name="password">123</property>
        <property name="schemas">mytest</property>
         <property name="maxCon">1</property>
      </user>
      <user name="action">
        <property name="password">action</property>
        <property name="schemas">mytest</property>
        <property name="readOnly">true</property>
        <property name="maxCon">1</property>
      </user>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose  | sql      | expect  | db     |
        | test         | 123       | conn_0 | False    | select 1 | success | mytest |
        | test         | 123       | new    | True     | select 1 | Access denied for user 'test',too many connections for this user | mytest |
        | action       | action    | conn_1 | False    | select 1 | success | mytest |
        | action       | action    | new    | True     | select 1 | Access denied for user 'action',too many connections for this user | mytest |
    Then execute sql in "dble-1" in "admin" mode
        | user         | passwd    | conn   | toClose | sql      | expect  | db     |
        | root         | 111111    | conn_2 | False    | show @@version | success | mytest |
        | root         | 111111    | conn_3 |False    | show @@version | success | mytest |
        | root         | 111111    | new    | False    | show @@version | Access denied for user 'root',too many connections for this user | mytest |

    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
      <user name="root">
        <property name="password">111111</property>
        <property name="manager">true</property>
      </user>
      <user name="test">
        <property name="password">123</property>
        <property name="schemas">mytest</property>
         <property name="maxCon">0</property>
      </user>
      <user name="action">
        <property name="password">action</property>
        <property name="schemas">mytest</property>
        <property name="readOnly">true</property>
        <property name="maxCon">0</property>
      </user>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose | sql      | expect  | db     |
        | test         | 123       | conn_4 | False    | select 1 | success | mytest |
        | test         | 123       | conn_5 | False    | select 1 | success | mytest |
        | action       | action    | conn_6 | False    | select 1 | success | mytest |
        | action       | action    | conn_7| False    | select 1 | success | mytest |

  Scenario: #12 test system maxCon
    Given delete the following xml segment
      |file        | parent           | child              |
      |server.xml  | {'tag':'root'}   | {'tag':'root'} |

    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
     <system>
		   <property name="useGlobleTableCheck">1</property>
		   <property name="processors">1</property>
          <property name="processorExecutor">1</property>
          <property name="maxCon">1</property>
     </system>

     <user name="root">
          <property name="password">111111</property>
          <property name="manager">true</property>
     </user>
     <user name="test">
          <property name="password">123</property>
          <property name="schemas">mytest</property>
          <property name="maxCon">1</property>
     </user>
     <user name="action">
          <property name="password">action</property>
          <property name="schemas">mytest</property>
          <property name="readOnly">true</property>
          <property name="maxCon">1</property>
     </user>

    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose | sql      | expect  | db     |
        | test         | 123       | conn_0 | False    | select 1 | success | mytest |
        | test         | 123       | new    | False    | select 1 | too many connections for this user | mytest |
        | action       | action   | conn_1 | False    | select 1 | too many connections for dble server | mytest |
    Then execute sql in "dble-1" in "admin" mode
        | user         | passwd    | conn   | toClose | sql      | expect  | db     |
        | root         | 111111    | conn_2 | False    | show @@version | success | mytest |




