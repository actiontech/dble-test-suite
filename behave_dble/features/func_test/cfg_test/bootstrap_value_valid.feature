# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2019/1/3
Feature: if childnodes value of system in bootstrap.cnf are invalid, replace them with default values
  only check part of system childnodes, not all, list from https://github.com/actiontech/dble/issues/579

  @NORMAL @test
  Scenario: config all system property, some values are illegal, start dble success #1
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    $a\sequenceHandlerType=20
    $a\showBinlogStatusTimeout=60000
    """
    # invalid data
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      $a\-DmaxCon=-3
      $a\-DserverBacklog=-2000
      $a\-DuseOuterHa=1
      $a\-Dautocommit=-3
      $a\-DuseCostTimeStat=2
      $a\-DmaxCostStatSize=-10
      $a\-DcostSamplePercent=-2
      $a\-DorderMemSize=-5
      $a\-DotherMemSize=-5
      $a\-DjoinMemSize=-5
      $a\-DmappedFileSize=-5
      $a\-DtransactionRotateSize=-10
      $a\-DxaRetryCount=-1
      $a\-DviewPersistenceConfBaseDir=///opt/dble/viewConf/
      $a\-DviewPersistenceConfBaseName=view/Json
      $a\-DjoinQueueSize=-1024
      $a\-DmergeQueueSize=-1024
      $a\-DorderByQueueSize=-1024
      $a\-DslowLogBaseDir=///opt/dble/slowlogs/
      $a\-DslowLogBaseName=slow/query
      $a\-DflushSlowLogPeriod=-1
      $a\-DflushSlowLogSize=-1000
      $a\-DmaxCharsPerColumn=-65534
      $a\-DmaxRowSizeToFile=-10000
      $a\-DenableFlowControl=1
      $a\-DflowControlStartThreshold=-4096
      $a\-DflowControlStopThreshold=-256
      $a\-DsqlSlowTime=-100
      $a\-DuseSqlStat=2
      $a\-DuseCompression=2
      $a\-Dcharset=utf-8
      $a\-DtxIsolation=30
      $a\-DrecordTxn=2
      $a\-DbufferUsagePercent=120
      $a\-DfrontSocketNoDelay=2
      $a\-DbackSocketNoDelay=2
      $a\-DusingAIO=2
      $a\-DcheckTableConsistency=-10100101
      $a\-DuseThreadUsageStat=2
      $a\-DusePerformanceMode=2
      $a\-DenableSlowLog=2
      $a\-DuseJoinStrategy=0
      $a\-DbindIp=256.256.256.258
      $a\-DserverPort=-1
      $a\-DmanagerPort=-2
      /-DProcessors=1/c -DProcessors=-3
      $a\-DbackendProcessors=-3
      $a\-DbackendProcessorExecutor=-4
      /-DprocessorExecutor=1/c -DprocessorExecutor=-3
      /-DserverId=server_1/c -DserverId=server_test
      $a\-DcomplexExecutor=-4
      $a\-DwriteToBackendExecutor=-4
      $a\-DfakeMySQLVersion=5.6.24.00
      $a\-DmaxPacketSize=-1000
      $a\-DcheckTableConsistencyPeriod=-1800
      $a\-DprocessorCheckPeriod=-1000
      $a\-DsqlExecuteTimeout=-20
      $a\-DtransactionLogBaseDir=///txlogs
      $a\-DtransactionLogBaseName=server/tx
      $a\-DtransactionRotateSize=16
      $a\-DxaSessionCheckPeriod=-1000
      $a\-DxaLogCleanPeriod=-1000
      $a\-DxaRecoveryLogBaseDir=///tmlogs
      $a\-DxaRecoveryLogBaseName=tm/log
      $a\-DnestLoopConnSize=-5
      $a\-DnestLoopRowsSize=-2000
      $a\-DbufferPoolChunkSize=-32767
      $a\-DbufferPoolPageNumber=-512
      $a\-DbufferPoolPageSize=-2000
      $a\-DclearBigSQLResultSetMapMs=-600000
      $a\-DsqlRecordCount=-10
      $a\-DmaxResultSet=-524288
      $a\-DbackSocketSoRcvbuf=-4194304
      $a\-DbackSocketSoSndbuf=-1048576
      $a\-DfrontSocketSoRcvbuf=-1048576
      $a\-DfrontSocketSoSndbuf=-4194304
    """
    Then restart dble in "dble-1" failed for
    """
      Property [ autocommit ] '-3' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      property [ backSocketNoDelay ] '2' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      Property [ backSocketSoRcvbuf ] '-4194304' in bootstrap.cnf is illegal, you may need use the default value 4194304 replaced
      Property [ backSocketSoSndbuf ] '-1048576' in bootstrap.cnf is illegal, you may need use the default value 1048576 replaced
      Property [ backendProcessorExecutor ] '-4' in bootstrap.cnf is illegal, you may need use the default value 5 replaced
      Property [ backendProcessors ] '-3' in bootstrap.cnf is illegal, you may need use the default value 5 replaced
      property [ bufferPoolChunkSize ] '-32767' in bootstrap.cnf is illegal, you may need use the default value 4096 replaced
      Property [ bufferPoolPageNumber ] '-2000' in bootstrap.cnf is illegal, you may need use the default value 2097152 replaced
      property [ bufferPoolPageSize ] 'abc' data type should be int
      property [ bufferUsagePercent ] '120' in bootstrap.cnf is illegal, you may need use the default value 80 replaced
      Property [ charset ] 'utf-8' in bootstrap.cnf is illegal, use utf8mb4 replaced
      property [ checkTableConsistency ] '-10100101' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      property [ checkTableConsistencyPeriod ] '-1800' in bootstrap.cnf is illegal, you may need use the default value 1800000 replaced
      property [ clearBigSQLResultSetMapMs ] '-600000' in bootstrap.cnf is illegal, you may need use the default value 600000 replaced
      Property [ complexExecutor ] '-4' in bootstrap.cnf is illegal, you may need use the default value 5 replaced
      Property [ costSamplePercent ] '-2' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      property [ enableFlowControl ] '1' data type should be boolean
      property [ enableSlowLog ] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property [ flushSlowLogPeriod ] '-1' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      Property [ flushSlowLogSize ] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      property [ frontSocketNoDelay ] '2' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      Property [ frontSocketSoRcvbuf ] '-1048576' in bootstrap.cnf is illegal, you may need use the default value 1048576 replaced
      Property [ frontSocketSoSndbuf ] '-4194304' in bootstrap.cnf is illegal, you may need use the default value 4194304 replaced
      property [ joinMemSize ] '-5' in bootstrap.cnf is illegal, you may need use the default value 4 replaced
      property [ joinQueueSize ] '-1024' data type should be int
      property [ mappedFileSize ] '-5' in bootstrap.cnf is illegal, you may need use the default value 67108864 replaced
      property [ maxCharsPerColumn ] '-65534' in bootstrap.cnf is illegal, you may need use the default value 65535 replaced
      Property [ maxCon ] '-3' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property [ maxCostStatSize ] '-10' in bootstrap.cnf is illegal, you may need use the default value 100 replaced
      property [ maxPacketSize ] '-1000' in bootstrap.cnf is illegal, you may need use the default value 4194304 replaced
      Property [ maxResultSet ] '-524288' in bootstrap.cnf is illegal, you may need use the default value 524288 replaced
      Property [ maxRowSizeToFile ] '-10000' in bootstrap.cnf is illegal, you may need use the default value 10000 replaced
      Property [ mergeQueueSize ] '-1024' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
      property [ nestLoopConnSize ] '-5' in bootstrap.cnf is illegal, you may need use the default value 4 replaced
      property [ nestLoopRowsSize ] '-2000' in bootstrap.cnf is illegal, you may need use the default value 2000 replaced
      Property [ orderByQueueSize ] '-1024' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
      property [ orderMemSize ] '-5' in bootstrap.cnf is illegal, you may need use the default value 4 replaced
      property [ otherMemSize ] '-5' in bootstrap.cnf is illegal, you may need use the default value 4 replaced
      Property [ processorCheckPeriod ] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      Property [ processorExecutor ] '-3' in bootstrap.cnf is illegal, you may need use the default value 5 replaced
      property [ recordTxn ] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property [ sqlExecuteTimeout ] '-20' in bootstrap.cnf is illegal, you may need use the default value 300 replaced
      Property [ sqlRecordCount ] '-10' in bootstrap.cnf is illegal, you may need use the default value 10 replaced
      property [ sqlSlowTime ] '-100' in bootstrap.cnf is illegal, you may need use the default value 100 replaced
      Property [ txIsolation ] '30' in bootstrap.cnf is illegal, you may need use the default value 3 replaced
      property [ useCompression ] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      property [ useCostTimeStat ] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      property [ useJoinStrategy ] '0' data type should be boolean
      property [ useOuterHa ] '1' data type should be boolean
      property [ usePerformanceMode ] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      property [ useSqlStat ] '2' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      property [ useThreadUsageStat ] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      property [ usingAIO ] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property [ writeToBackendExecutor ] '-4' in bootstrap.cnf is illegal, you may need use the default value 5 replaced
      Property [ xaLogCleanPeriod ] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      Property [ xaRetryCount ] '-1' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property [ xaSessionCheckPeriod ] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      The specified MySQL Version (5.6.24.00) is not valid, the version should look like 'x.y.z'
    """

  Scenario: config bootstrap property, some parameter spell illegal, start dble failed #2
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    $a\sequenceHandlerType=20
    $a\showBinlogStatusTimeout=60000
    """
    # invalid data
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      $a\-DmaxCom=-1
    """
    Then restart dble in "dble-1" failed for
    """
      These properties in bootstrap.cnf or bootstrap.dynamic.cnf are not recognized: maxCom
    """
    
  Scenario: if bootstrap.cnf is not exist, check the log
    Given delete file "/opt/dble/conf/bootstrap.cnf" on "dble-1"
    Then restart dble in "dble-1" failed for
    """
        Configuration file not found: conf/bootstrap.cnf
    """

  Scenario: if bootstrap.dynamic.cnf is not exist, check the log
    Given delete file "/opt/dble/conf/bootstrap.dynamic.cnf" on "dble-1"
    Given Restart dble in "dble-1" success
    Then check following " " exist in dir "/opt/dble/conf/" in "dble-1"
      """
        bootstrap.dynamic.cnf
      """
    Then check "/opt/dble/conf/bootstrap.dynamic.cnf" in "dble-1" was empty

  Scenario: if bootstrap.cnf is empty, check the log
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      1,$d
    """
    Then restart dble in "dble-1" failed for
    """
        You must config instanceName in bootstrap.cnf and make sure it is an unique key for cluster
    """

  Scenario: config cluster.cnf with illegal values, restart dble fail
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    /clusterEnable/c clusterEnable=1
    /clusterMode/c clusterMode=1
    /clusterIP/c clusterIP=5.5
    /clusterId/c clusterId=5.5
    /needSyncHa/c needSyncHa=1
    $a\clusterPort=555
    $a\rootPath=///opt/dble/viewConf/
    $a\showBinlogStatusTimeout=-60000
    $a\sequenceHandlerType=20
    $a\sequenceStartTime=2010/11/04 09:42:54
    $a\sequenceInstanceByZk=1
    """
    Then restart dble in "dble-1" failed for
    """
    property [ clusterEnable ] '1' data type should be boolean
    property [ needSyncHa ] '1' data type should be boolean
    property [ sequenceHandlerType ] '5.5' data type should be int
    property [ sequenceInstanceByZk ] '1' data type should be boolean
    sequenceStartTime in cluster.cnf invalid format, you can use default value 2010-11-04 09:42:54
    property [ showBinlogStatusTimeout ] '60000.1' data type should be long
    """

  Scenario: config bootstrap.cnf with unrecognized value, restart dble fail
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-Dtestcon=100
    """
    Then restart dble in "dble-1" failed for
    """
    These properties in bootstrap.cnf or bootstrap.dynamic.cnf are not recognized: testcon
    """


  @skip
  Scenario: config bootstrap.cnf with illegal homepath, restart dble fail
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DhomePath=./c -DhomePath=/opt/dble/conf/
    """
    Then restart dble in "dble-1" success

    Then  execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                           | expect  | db      |
      | conn_0 | False   | drop table if exists test                     | success | schema1 |
      | conn_0 | False   | create table test(id int)                     | success | schema1 |
      | conn_0 | False   | drop view if exists view_test                 | success | schema1 |
      | conn_0 | True    | create view view_test01 as select * from test | success | schema1 |
