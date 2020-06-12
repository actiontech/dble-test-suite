# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2019/1/3
Feature: if childnodes value of system in bootstrap.cnf are invalid, replace them with default values
  only check part of system childnodes, not all, list from https://github.com/actiontech/dble/issues/579

  @NORMAL
  @skip #waiting for warning msg change finished 2020.06.12
  Scenario: config all system property, some values are illegal, start dble success #1
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    $a\sequenceHandlerType=20
    $a\showBinlogStatusTimeout=60000
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      $a\-DuseSqlStat=false
      $a\-DuseCompression=true
      $a\-Dcharset=utf-8
      $a\-DtxIsolation=30
      $a\-DrecordTxn=false
      $a\-DbufferUsagePercent=80%
      $a\-DfrontSocketNoDelay=true
      $a\-DbackSocketNoDelay=true
      $a\-DusingAIO=false
      $a\-DcheckTableConsistency=false
      $a\-DuseCostTimeStat=false
      $a\-DuseThreadUsageStat=false
      $a\-DusePerformanceMode=false
      $a\-DusePerformanceMode=false
      $a\-DenableSlowLog=false
      $a\-DuseJoinStrategy=true
      $a\-DbindIp=0.0.0.0
      $a\-DserverPort=8066
      $a\-DmanagerPort=9066
      $a\-Dprocessors=4
      $a\-DprocessorExecutor=4
      $a\-DbackendProcessors=4
      $a\-DbackendProcessorExecutor=4
      $a\-DcomplexExecutor=4
      $a\-DwriteToBackendExecutor=4
      $a\-DfakeMySQLVersion=5.6.24
      $a\-DmaxPacketSize=16777216
      $a\-DcheckTableConsistencyPeriod=60000
      $a\-DshardingNodeIdleCheckPeriod=300000
      $a\-DshardingNodeHeartbeatPeriod=10000
      $a\-DprocessorCheckPeriod=1000
      $a\-DsqlExecuteTimeout=300
      $a\-DidleTimeout=1800000
      $a\-DtransactionLogBaseDir=/txlogs
      $a\-DtransactionLogBaseName=server-tx
      $a\-DtransactionRatateSize=16
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
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sysparam_rs"
      | sql              |
      | show @@sysparam  |
    Then check resultset "sysparam_rs" has lines with following column values
      | PARAM_NAME-0                | PARAM_VALUE-1                   |
      | bindIp                      | 0.0.0.0                         |
      | serverPort                  | 8066                            |
      | managerPort                 | 9066                            |
      | processors                  | 4                               |
      | backendProcessors           | 4                               |
      | processorExecutor           | 4                               |
      | backendProcessorExecutor    | 4                               |
      | complexExecutor             | 4                               |
      | writeToBackendExecutor      | 4                               |
      | fakeMySQLVersion            | 5.6.24                          |
      | sequenceHandlerType         | Local TimeStamp(like Snowflake) |
      | serverBacklog               | 2048                            |
      | maxCon                      | 0                               |
      | useCompression              | 0                               |
      | usingAIO                    | 0                               |
      | autocommit                  | 1                               |
      | useThreadUsageStat          | 0                               |
      | usePerformanceMode          | 0                               |
      | useCostTimeStat             | 0                               |
      | maxCostStatSize             | 100                             |
      | costSamplePercent           | 1                               |
      | charset                     | utf8mb4                         |
      | maxPacketSize               | 16777216                        |
      | txIsolation                 | REPEATABLE_READ                 |
      | checkTableConsistency       | 0                               |
      | checkTableConsistencyPeriod | 60000ms                         |
      | shardingNodeIdleCheckPeriod     | 300 Seconds                     |
      | shardingNodeHeartbeatPeriod     | 10 Seconds                      |
      | processorCheckPeriod        | 1 Seconds                       |
      | idleTimeout                 | 30 Minutes                      |
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
      | viewPersistenceConfBaseDir  | /opt/dble/viewConf/         |
      | viewPersistenceConfBaseName | viewJson                        |
      | joinQueueSize               | 1024                            |
      | mergeQueueSize              | 1024                            |
      | orderByQueueSize            | 1024                            |
      | enableSlowLog               | 0                               |
      | slowLogBaseDir              |/opt/dble/slowlogs/             |
      | slowLogBaseName             | slow-query                      |
      | flushSlowLogPeriod          | 1s                              |
      | flushSlowLogSize            | 1000                            |
      | sqlSlowTime                 | 100ms                           |
      | maxCharsPerColumn           | 65535                           |
      | maxRowSizeToFile            | 10000                           |
      | useOuterHa                  | true                            |
    And check "dble.log" in "dble-1" has the warnings
      | TYPE-0  | LEVEL-1 | DETAIL-2                                                                       |
      | Xml     | WARNING | property [ backSocketNoDelay ] 'true' data type should be int, skip            |
      | Xml     | WARNING | property [ bufferUsagePercent ] '80%' data type should be int, skip            |
      | Xml     | WARNING | Property [ charset ] 'utf-8' in bootstrap.cnf is illegal, use utf8mb4 replaced       |
      | Xml     | WARNING | property [ checkTableConsistency ] 'false' data type should be int, skip       |
      | Xml     | WARNING | property [ enableSlowLog ] 'false' data type should be int, skip               |
      | Xml     | WARNING | property [ frontSocketNoDelay ] 'true' data type should be int, skip           |
      | Xml     | WARNING | property [ recordTxn ] 'false' data type should be int, skip                   |
      | Xml     | WARNING | sequenceHandlerType value is 20, it will use default value:2                   |
      | Xml     | WARNING | Property [ txIsolation ] '30' in bootstrap.cnf is illegal, use 3 replaced         |
      | Xml     | WARNING | property [ useCompression ] 'true' data type should be int, skip               |
      | Xml     | WARNING | property [ useCostTimeStat ] 'false' data type should be int, skip             |
      | Xml     | WARNING | property [ usePerformanceMode ] 'false' data type should be int, skip          |
      | Xml     | WARNING | property [ useSqlStat ] 'false' data type should be int, skip                  |
      | Xml     | WARNING | property [ useThreadUsageStat ] 'false' data type should be int, skip          |
      | Xml     | WARNING | property [ usingAIO ] 'false' data type should be int, skip                    |