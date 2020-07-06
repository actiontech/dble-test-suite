# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by lizizi at 2020/6/30
Feature: config all dble config files correct and restart dble

  Scenario: config bootstrap property, start dble success #1
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    $a\sequenceHandlerType=2
    $a\showBinlogStatusTimeout=60000
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      $a\-DmaxCon=1024
      $a\-DserverBacklog=2048
      $a\-DuseOuterHa=true
      $a\-Dautocommit=1
      $a\-DuseCostTimeStat=0
      $a\-DmaxCostStatSize=100
      $a\-DcostSamplePercent=1
      $a\-DorderMemSize=4
      $a\-DotherMemSize=4
      $a\-DjoinMemSize=4
      $a\-DmappedFileSize=67108864
      $a\-DtransactionRotateSize=16
      $a\-DxaRetryCount=0
      $a\-DviewPersistenceConfBaseDir=/opt/dble/viewConf/
      $a\-DviewPersistenceConfBaseName=viewJson
      $a\-DjoinQueueSize=1024
      $a\-DmergeQueueSize=1024
      $a\-DorderByQueueSize=1024
      $a\-DslowLogBaseDir=/opt/dble/slowlogs/
      $a\-DslowLogBaseName=slow-query
      $a\-DflushSlowLogPeriod=1
      $a\-DflushSlowLogSize=1000
      $a\-DmaxCharsPerColumn=65535
      $a\-DmaxRowSizeToFile=10000
      $a\-DenableFlowControl=false
      $a\-DflowControlStartThreshold=4096
      $a\-DflowControlStopThreshold=256
      $a\-DsqlSlowTime=100
      $a\-DuseSqlStat=1
      $a\-DuseCompression=0
      $a\-Dcharset=utf8mb4
      $a\-DtxIsolation=3
      $a\-DrecordTxn=0
      $a\-DbufferUsagePercent=80
      $a\-DfrontSocketNoDelay=1
      $a\-DbackSocketNoDelay=1
      $a\-DusingAIO=0
      $a\-DcheckTableConsistency=0
      $a\-DuseCostTimeStat=0
      $a\-DuseThreadUsageStat=0
      $a\-DusePerformanceMode=0
      $a\-DenableSlowLog=0
      $a\-DuseJoinStrategy=true
      $a\-DbindIp=0.0.0.0
      $a\-DserverPort=8066
      $a\-DmanagerPort=9066
      $a\-DbackendProcessors=4
      $a\-DbackendProcessorExecutor=4
      $a\-DcomplexExecutor=4
      $a\-DwriteToBackendExecutor=4
      $a\-DfakeMySQLVersion=5.6.24
      $a\-DmaxPacketSize=1073741824
      $a\-DcheckTableConsistencyPeriod=60000
      $a\-DprocessorCheckPeriod=1000
      $a\-DsqlExecuteTimeout=300
      $a\-DtransactionLogBaseDir=/txlogs
      $a\-DtransactionLogBaseName=server-tx
      $a\-DtransactionRotateSize=16
      $a\-DxaSessionCheckPeriod=1000
      $a\-DxaLogCleanPeriod=1000
      $a\-DxaRecoveryLogBaseDir=/tmlogs
      $a\-DxaRecoveryLogBaseName=tmlog
      $a\-DnestLoopConnSize=4
      $a\-DnestLoopRowsSize=2000
      $a\-DbufferPoolChunkSize=4096
      $a\-DbufferPoolPageNumber=512
      $a\-DbufferPoolPageSize=2097152
      $a\-DclearBigSQLResultSetMapMs=600000
      $a\-DsqlRecordCount=10
      $a\-DmaxResultSet=524288
      $a\-DbackSocketSoRcvbuf=4194304
      $a\-DbackSocketSoSndbuf=1048576
      $a\-DfrontSocketSoRcvbuf=1048576
      $a\-DfrontSocketSoSndbuf=4194304
    """
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sysparam_rs"
      | sql             |
      | show @@sysparam |
    Then check resultset "sysparam_rs" has lines with following column values
      | PARAM_NAME-0                | PARAM_VALUE-1                   |
      | bindIp                      | 0.0.0.0                         |
      | serverPort                  | 8066                            |
      | managerPort                 | 9066                            |
      | processors                  | 1                               |
      | backendProcessors           | 4                               |
      | processorExecutor           | 1                               |
      | backendProcessorExecutor    | 4                               |
      | complexExecutor             | 4                               |
      | writeToBackendExecutor      | 4                               |
      | fakeMySQLVersion            | 5.6.24                          |
      | sequenceHandlerType         | Local TimeStamp(like Snowflake) |
      | serverBacklog               | 2048                            |
      | maxCon                      | 1024                            |
      | useCompression              | 0                               |
      | usingAIO                    | 0                               |
      | autocommit                  | 1                               |
      | useThreadUsageStat          | 0                               |
      | usePerformanceMode          | 0                               |
      | useCostTimeStat             | 0                               |
      | maxCostStatSize             | 100                             |
      | costSamplePercent           | 1                               |
      | charset                     | utf8mb4                         |
      | maxPacketSize               | 1073741824                      |
      | txIsolation                 | REPEATABLE_READ                 |
      | checkTableConsistency       | 0                               |
      | checkTableConsistencyPeriod | 60000ms                         |
      | processorCheckPeriod        | 1 Seconds                       |
      | sqlExecuteTimeout           | 300 Seconds                     |
      | recordTxn                   | 0                               |
      | transactionLogBaseDir       | /txlogs                         |
      | transactionLogBaseName      | server-tx                       |
      | transactionRotateSize       | 16M                             |
      | xaRecoveryLogBaseDir        | /tmlogs                         |
      | xaRecoveryLogBaseName       | tmlog                           |
      | xaSessionCheckPeriod        | 1000ms                          |
      | xaLogCleanPeriod            | 1000ms                          |
      | xaRetryCount                | 0                               |
      | useJoinStrategy             | true                            |
      | nestLoopConnSize            | 4                               |
      | nestLoopRowsSize            | 2000                            |
      | otherMemSize                | 4M                              |
      | orderMemSize                | 4M                              |
      | joinMemSize                 | 4M                              |
      | bufferPoolChunkSize         | 4096B                           |
      | bufferPoolPageSize          | 2097152B                        |
      | bufferPoolPageNumber        | 512                             |
      | mappedFileSize              | 67108864                        |
      | useSqlStat                  | 1                               |
      | sqlRecordCount              | 10                              |
      | maxResultSet                | 524288B                         |
      | bufferUsagePercent          | 80%                             |
      | clearBigSQLResultSetMapMs   | 600000ms                        |
      | frontSocketSoRcvbuf         | 1048576B                        |
      | frontSocketSoSndbuf         | 4194304B                        |
      | frontSocketNoDelay          | 1                               |
      | backSocketSoRcvbuf          | 4194304B                        |
      | backSocketSoSndbuf          | 1048576B                        |
      | backSocketNoDelay           | 1                               |
      | viewPersistenceConfBaseDir  | /opt/dble/viewConf/             |
      | viewPersistenceConfBaseName | viewJson                        |
      | joinQueueSize               | 1024                            |
      | mergeQueueSize              | 1024                            |
      | orderByQueueSize            | 1024                            |
      | enableSlowLog               | 0                               |
      | slowLogBaseDir              | /opt/dble/slowlogs/             |
      | slowLogBaseName             | slow-query                      |
      | flushSlowLogPeriod          | 1s                              |
      | flushSlowLogSize            | 1000                            |
      | sqlSlowTime                 | 100ms                           |
      | maxCharsPerColumn           | 65535                           |
      | maxRowSizeToFile            | 10000                           |
      | useOuterHa                  | true                            |

  Scenario: config cluster property, start dble success #2
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    $a\sequenceHandlerType=2
    $a\showBinlogStatusTimeout=60000
    $a\clusterPort=5700
    $a\rootPath=dble
    $a\sequenceStartTime=2010-11-04 09:42:54
    $a\sequenceInstanceByZk=false
    """
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sysparam_rs"
      | sql             |
      | show @@sysparam |
    Then check resultset "sysparam_rs" has lines with following column values
      | PARAM_NAME-0            | PARAM_VALUE-1       |
      | showBinlogStatusTimeout | 60000ms             |
      | sequenceStartTime       | 2010-11-04 09:42:54 |
      | sequenceInstanceByZk    | false               |

  Scenario: config user property, start dble success #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
      <managerUser name="root_test" password="111111" usingDecrypt="false" whiteIPs="172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" maxCon="0"/>
      <shardingUser name="sharding_test" password="111111" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" tenant="tenant1" schemas="schema1" maxCon="0" blacklist="blacklist1"/>
      <rwSplitUser name="rwSplit" password="111111" usingDecrypt="false" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" dbGroup="ha_group1" tenant="tenant1" maxCon="20" blacklist="blacklist1"/>
      <blacklist name="blacklist1">
        <property name="selectHavingAlwayTrueCheck">true</property>
        <property name="selectWhereAlwayTrueCheck">true</property>
        <property name="doPrivilegedAllow">false</property>
        <property name="wrapAllow">true</property>
        <property name="metadataAllow">true</property>
        <property name="completeInsertValuesCheck">false</property>
        <property name="mergeAllow">true</property>
        <property name="conditionLikeTrueAllow">true</property>
        <property name="conditionDoubleConstAllow">false</property>
        <property name="conditionAndAlwayFalseAllow">false</property>
        <property name="conditionAndAlwayTrueAllow">false</property>
        <property name="selectAllColumnAllow">true</property>
        <property name="multiStatementAllow">false</property>
        <property name="constArithmeticAllow">false</property>
        <property name="alterTableAllow">true</property>
        <property name="commitAllow">true</property>
        <property name="createTableAllow">true</property>
        <property name="deleteAllow">true</property>
        <property name="dropTableAllow">true</property>
        <property name="insertAllow">true</property>
        <property name="intersectAllow">true</property>
        <property name="lockTableAllow">true</property>
        <property name="minusAllow">true</property>
        <property name="callAllow">true</property>
        <property name="selectIntoOutfileAllow">false</property>
        <property name="selectIntoAllow">true</property>
        <property name="selelctAllow">true</property>
        <property name="renameTableAllow">true</property>
        <property name="replaceAllow">true</property>
        <property name="rollbackAllow">true</property>
        <property name="setAllow">true</property>
        <property name="describeAllow">true</property>
        <property name="limitZeroAllow">false</property>
        <property name="showAllow">true</property>
        <property name="hintAllow">true</property>
        <property name="commentAllow">true</property>
        <property name="mustParameterized">false</property>
        <property name="conditionOpXorAllow">false</property>
        <property name="conditionOpBitwseAllow">true</property>
        <property name="startTransactionAllow">true</property>
        <property name="truncateAllow">true</property>
        <property name="updateAllow">true</property>
        <property name="useAllow">true</property>
        <property name="blockAllow">true</property>
        <property name="deleteWhereNoneCheck">false</property>
        <property name="updateWhereNoneCheck">false</property>
        <property name="deleteWhereAlwayTrueCheck">true</property>
        <property name="updateWhereAlayTrueCheck">true</property>
        <property name="selectIntersectCheck">true</property>
        <property name="selectExceptCheck">true</property>
        <property name="selectMinusCheck">true</property>
        <property name="selectUnionCheck">true</property>
        <property name="caseConditionConstAllow">false</property>
        <property name="strictSyntaxCheck">true</property>
        <property name="schemaCheck">true</property>
        <property name="tableCheck">true</property>
        <property name="functionCheck">true</property>
        <property name="objectCheck">true</property>
        <property name="variantCheck">true</property>
      </blacklist>
    """
    Given add xml segment to node with attribute "{'tag':'shardingUser','kv_map':{'name':'sharding_test'}}" in "user.xml"
    """
      <privileges check="true">
        <schema name="TESTDB" dml="0110">
            <table name="tb01" dml="0000"/>
            <table name="tb02" dml="1111"/>
        </schema>
      </privileges>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "show @@version" with user "root_test" passwd "111111"

  Scenario: config db property, start dble success #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="0">select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" usingDecrypt="false" maxCon="1000" minCon="10" readWeight="0" primary="true" disabled="false">
          <property name="evictorShutdownTimeoutMillis">10L * 1000L</property>
          <property name="numTestsPerEvictionRun">3</property>
          <property name="testOnCreate">false</property>
          <property name="testOnBorrow">false</property>
          <property name="testOnReturn">false</property>
          <property name="testWhileIdle">false</property>
          <property name="connectionTimeout">10s</property>
          <property name="connectionHeartbeatTimeout">20ms</property>
          <property name="timeBetweenEvictionRunsMillis">30s</property>
          <property name="idleTimeout">10minute</property>
          <property name="heartbeatPeriodMillis">10s</property>
        </dbInstance>
      </dbGroup>
    """
  Then execute admin cmd "reload @@config_all"

  Scenario: config sharding property, start dble success #3
    Given add xml segment to node with attribute "{'tag':'schema'}" in "sharding.xml"
    """
      <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" sqlMaxLimit="100" checkClass="CHECKSUM" cron="0 0 0 * * ?"/>
      <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" sqlMaxLimit="105" sqlRequiredSharding="false">
        <childTable name="tb_child1" joinColumn="child1_id" parentColumn="id" sqlMaxLimit="201">
          <childTable name="tb_grandson1" joinColumn="grandson1_id" parentColumn="child1_id"/>
          <childTable name="tb_grandson2" joinColumn="grandson2_id" parentColumn="child1_id2"/>
        </childTable>
        <childTable name="tb_child2" joinColumn="child2_id" parentColumn="id"/>
        <childTable name="tb_child3" joinColumn="child3_id" parentColumn="id2"/>
      </shardingTable>
      <singleTable name="tb_single" shardingNode="dn5" sqlMaxLimit="105"/>
    """
    Then execute admin cmd "reload @@config_all"
