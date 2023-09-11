# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2019/1/3
Feature: if childnodes value of system in bootstrap.cnf are invalid, replace them with default values
  only check part of system childnodes, not all, list from https://github.com/actiontech/dble/issues/579

  @NORMAL
  Scenario: config all system property, some values are illegal, start dble failed #1
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
      $a\-DuseOuterHa=5
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
      $a\-DenableFlowControl=5
      $a\-DflowControlStartThreshold=-4096
      $a\-DflowControlStopThreshold=-256
      $a\-DsqlSlowTime=-100
      $a\-DuseCompression=2
      $a\-Dcharset=utf-8
      $a\-DtxIsolation=30
      $a\-DrecordTxn=2
      $a\-DfrontSocketNoDelay=2
      $a\-DbackSocketNoDelay=2
      $a\-DusingAIO=2
      $a\-DcheckTableConsistency=-10100101
      $a\-DuseThreadUsageStat=2
      $a\-DusePerformanceMode=2
      $a\-DenableSlowLog=2
      $a\-DuseJoinStrategy=5
      $a\-DbindIp=256.256.256.258
      $a\-DserverPort=-1
      $a\-DmanagerPort=-2
      /-Dprocessors=1/c -Dprocessors=-3
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
      $a\-DmaxResultSet=-524288
      $a\-DbackSocketSoRcvbuf=-4194304
      $a\-DbackSocketSoSndbuf=-1048576
      $a\-DfrontSocketSoRcvbuf=-1048576
      $a\-DfrontSocketSoSndbuf=-4194304
    """
    # 不同环境默认值不同，可能导致案例失败， 如 backendProcessorExecutor，backendProcessors 默认值为宿主机核数
    Then restart dble in "dble-1" failed for
      """
      sequenceHandlerType value is 20, you can use default value:2

      Property \[ backSocketSoRcvbuf \] '-4194304' in bootstrap.cnf is illegal, you may need use the default value 4194304 replaced
      Property \[ backSocketSoSndbuf \] '-1048576' in bootstrap.cnf is illegal, you may need use the default value 1048576 replaced
      property \[ backendProcessorExecutor \] has been replaced by the property \[ backendWorker \].  Property \[ backendWorker \] '-4' in bootstrap.cnf is illegal, you may need use the default value.*replaced
      property \[ backendProcessors \] has been replaced by the property \[ NIOBackendRW \].  Property \[ NIOBackendRW \] '-3' in bootstrap.cnf is illegal, you may need use the default value.*replaced
      Property \[ bufferPoolChunkSize \] '-32767' in bootstrap.cnf is illegal, you may need use the default value 4096 replaced
      Property \[ bufferPoolPageNumber \] '-512' in bootstrap.cnf is illegal, you may need use the default value 409 replaced
      Property \[ bufferPoolPageSize \] '-2000' in bootstrap.cnf is illegal, you may need use the default value 2097152 replaced
      Property \[ charset \] 'utf-8' in bootstrap.cnf is illegal, use utf8mb4 replaced

      Property \[ checkTableConsistencyPeriod \] '-1800' in bootstrap.cnf is illegal, you may need use the default value 1800000 replaced
      property \[ complexExecutor \] has been replaced by the property \[ complexQueryWorker \].  Property \[ complexQueryWorker \] '-4' in bootstrap.cnf is illegal, you may need use the default value.*replaced
      Property \[ costSamplePercent \] '-2' in bootstrap.cnf is illegal, you may need use the default value 1 replaced

      Property \[ flushSlowLogPeriod \] '-1' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      Property \[ flushSlowLogSize \] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced

      Property \[ frontSocketSoRcvbuf \] '-1048576' in bootstrap.cnf is illegal, you may need use the default value 1048576 replaced
      Property \[ frontSocketSoSndbuf \] '-4194304' in bootstrap.cnf is illegal, you may need use the default value 4194304 replaced
      Property \[ joinMemSize \] '-5' in bootstrap.cnf is illegal, you may need use the default value 4 replaced
      Property \[ joinQueueSize \] '-1024' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
      Property \[ mappedFileSize \] '-5' in bootstrap.cnf is illegal, you may need use the default value 67108864 replaced
      Property \[ maxCharsPerColumn \] '-65534' in bootstrap.cnf is illegal, you may need use the default value 65535 replaced
      Property \[ maxCon \] '-3' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property \[ maxCostStatSize \] '-10' in bootstrap.cnf is illegal, you may need use the default value 100 replaced
      Property \[ maxPacketSize \] '-1000' in bootstrap.cnf is illegal, you may need use the default value 4194304 replaced
      Property \[ maxResultSet \] '-524288' in bootstrap.cnf is illegal, you may need use the default value 524288 replaced
      Property \[ maxRowSizeToFile \] '-10000' in bootstrap.cnf is illegal, you may need use the default value 100000 replaced
      Property \[ mergeQueueSize \] '-1024' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
      Property \[ nestLoopConnSize \] '-5' in bootstrap.cnf is illegal, you may need use the default value 4 replaced
      Property \[ nestLoopRowsSize \] '-2000' in bootstrap.cnf is illegal, you may need use the default value 2000 replaced
      Property \[ orderByQueueSize \] '-1024' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
      Property \[ orderMemSize \] '-5' in bootstrap.cnf is illegal, you may need use the default value 4 replaced
      Property \[ otherMemSize \] '-5' in bootstrap.cnf is illegal, you may need use the default value 4 replaced
      Property \[ processorCheckPeriod \] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      property \[ processors \] has been replaced by the property \[ NIOFrontRW \].  Property \[ NIOFrontRW \] '-3' in bootstrap.cnf is illegal, you may need use the default value.*replaced
      property \[ processorExecutor \] has been replaced by the property \[ frontWorker \].  Property \[ frontWorker \] '-3' in bootstrap.cnf is illegal, you may need use the default value.*replaced

      Property \[ sqlExecuteTimeout \] '-20' in bootstrap.cnf is illegal, you may need use the default value 300 replaced
      Property \[ sqlSlowTime \] '-100' in bootstrap.cnf is illegal, you may need use the default value 100 replaced
      Property \[ txIsolation \] '30' in bootstrap.cnf is illegal, you may need use the default value 3 replaced

      property \[ writeToBackendExecutor \] has been replaced by the property \[ writeToBackendWorker \].  Property \[ writeToBackendWorker \] '-4' in bootstrap.cnf is illegal, you may need use the default value.*replaced
      Property \[ xaLogCleanPeriod \] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      Property \[ xaRetryCount \] '-1' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property \[ xaSessionCheckPeriod \] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      The specified MySQL Version (5.6.24.00) is not valid, the version should look like 'x.y.z'.

      check the property \[ autocommit \] '-3' data type or value
      check the property \[ backSocketNoDelay \] '2' data type or value
      check the property \[ checkTableConsistency \] '-10100101' data type or value
      check the property \[ enableSlowLog \] '2' data type or value
      check the property \[ frontSocketNoDelay \] '2' data type or value
      check the property \[ recordTxn \] '2' data type or value
      check the property \[ useCompression \] '2' data type or value
      check the property \[ useCostTimeStat \] '2' data type or value
      check the property \[ usePerformanceMode \] '2' data type or value
      check the property \[ useThreadUsageStat \] '2' data type or value
      check the property \[ usingAIO \] '2' data type or value
      check the property \[ enableFlowControl \] '5' data type or value
      check the property \[ useJoinStrategy \] '5' data type or value
      check the property \[ useOuterHa \] '5' data type or value
      """
      # DBLE0REQ-2293
      # Property \[ autocommit \] '-3' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      # Property \[ backSocketNoDelay \] '2' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      # Property \[ checkTableConsistency \] '-10100101' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      # Property \[ enableSlowLog \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      # Property \[ frontSocketNoDelay \] '2' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      # Property \[ recordTxn \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      # Property \[ useCompression \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      # Property \[ useCostTimeStat \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      # Property \[ usePerformanceMode \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      # Property \[ useThreadUsageStat \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      # Property \[ usingAIO \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      # property \[ enableFlowControl \] '5' data type should be boolean
      # property \[ useJoinStrategy \] '5' data type should be boolean
      # property \[ useOuterHa \] '5' data type should be boolean

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

  Scenario: if bootstrap.cnf is not exist, check the log #3
    Given delete file "/opt/dble/conf/bootstrap.cnf" on "dble-1"
    Then restart dble in "dble-1" failed for
    """
    Configuration file not found: conf/bootstrap.cnf
    """

  Scenario: if bootstrap.dynamic.cnf is not exist, check the log #4
    Given delete file "/opt/dble/conf/bootstrap.dynamic.cnf" on "dble-1"
    Given Restart dble in "dble-1" success
    Then check following " " exist in dir "/opt/dble/conf/" in "dble-1"
      """
      bootstrap.dynamic.cnf
      """
    Then check "/opt/dble/conf/bootstrap.dynamic.cnf" in "dble-1" was empty



  Scenario: if bootstrap.cnf is empty, check the log #5
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
     1,$d
    """
    Then restart dble in "dble-1" failed for
    """
    homePath is not set
    """



  Scenario: config cluster.cnf with illegal values, restart dble fail #6
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    /clusterEnable/c clusterEnable=1
    /clusterMode/c clusterMode=1
    /clusterIP/c clusterIP=5.5
    /clusterId/c clusterId=5.5
    /needSyncHa/c needSyncHa=1
    $a\clusterPort=555
    $a\rootPath=///opt/dble/viewConf/
    $a\showBinlogStatusTimeout=60000.1
    $a\sequenceHandlerType=5.5
    $a\sequenceStartTime=2010/11/04 09:42:54
    $a\sequenceInstanceByZk=1
    """
    Then restart dble in "dble-1" failed for
    """
    property \[ clusterEnable \] '1' data type should be boolean
    property \[ needSyncHa \] '1' data type should be boolean
    property \[ sequenceHandlerType \] '5.5' data type should be int
    property \[ sequenceInstanceByZk \] '1' data type should be boolean
    sequenceStartTime in cluster.cnf invalid format, you can use default value 2010-11-04 09:42:54
    property \[ showBinlogStatusTimeout \] '60000.1' data type should be long
    """



  Scenario: config bootstrap.cnf with unrecognized value, restart dble fail #7
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-Dtestcon=100
    """
    Then restart dble in "dble-1" failed for
    """
    These properties in bootstrap.cnf or bootstrap.dynamic.cnf are not recognized: testcon
    """




  @restore_mysql_config
  Scenario:config  MaxPacketSize in bootstrap.cnf, dble will get the lower value of MaxPacketSize and (max_allowed_packet-1024) #8
    """
    {'restore_mysql_config':{'mysql-master1':{'max_allowed_packet':8388608},'mysql-master2':{'max_allowed_packet':8388608}}}
    """
    #### 9066
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                            | expect               | db               |
      | conn_0 | true    | select @@max_allowed_packet                                    | has{((4194304,),)}   | dble_information |
#      | conn_0 | true    | SELECT @@session.auto_increment_increment,@@max_allowed_packet | has{((1, 8388608),)} | dble_information |
    #### 8066
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                            | expect                   | db      |
      | conn_1 | true    | select @@max_allowed_packet                                    | has{((4194304,),)}       | schema1 |
      | conn_1 | true    | SELECT @@session.auto_increment_increment,@@max_allowed_packet | has{(('1', '4194304'),)} | schema1 |


    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DmaxPacketSize=6291456
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                | db               |
      | conn_0 | true    | select @@max_allowed_packet                                                      | has{((6291456,),)}    | dble_information |
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('6291456B',),)} | dble_information |
#      | conn_0 | true    | SELECT @@session.auto_increment_increment,@@max_allowed_packet                   | has{((1, 8388608),)}  | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect              | db        |
      | conn_1 | true    | select @@max_allowed_packet      | has{((6291456,),)}  | schema1   |
      | conn_1 | true    | SELECT @@session.auto_increment_increment,@@max_allowed_packet | has{(('1', '6291456'),)} | schema1 |

    #case2 max_packet_size < max_allowed_packet
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 8388608
      """
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
      """
      /max_allowed_packet/d
      /server-id/a max_allowed_packet = 8388608
      """
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                            | expect                                    |
      | conn_1 | True    | show variables like 'max_allowed_packet%'      | has{(('max_allowed_packet', '8388608'),)} |
    Given execute sql in "mysql-master2"
      | conn   | toClose | sql                                            | expect                                    |
      | conn_2 | True    | show variables like 'max_allowed_packet%'      | has{(('max_allowed_packet', '8388608'),)} |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                | db               |
      | conn_0 | true    | select @@max_allowed_packet                                                      | has{((6291456,),)}    | dble_information |
      | conn_0 | true    | SELECT @@session.auto_increment_increment,@@max_allowed_packet                   | has{((1, 8388608),)}  | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect              | db        |
      | conn_1 | true    | select @@max_allowed_packet      | has{((6291456,),)}  | schema1   |
      | conn_1 | true    | SELECT @@session.auto_increment_increment,@@max_allowed_packet | has{(('1', '6291456'),)} | schema1 |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DmaxPacketSize=6291456/-DmaxPacketSize=9437184/
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                 | db               |
      | conn_0 | true    | select @@max_allowed_packet                                                      | has{((9437184,),)}     | dble_information |
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('9437184B',),)}  | dble_information |
      | conn_0 | true    | SELECT @@session.auto_increment_increment,@@max_allowed_packet                   | has{((1, 9438208),)}  | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect              | db        |
      | conn_1 | true    | select @@max_allowed_packet      | has{((9437184,),)}  | schema1   |
      | conn_1 | true    | SELECT @@session.auto_increment_increment,@@max_allowed_packet | has{(('1', '9437184'),)} | schema1 |

    #case 3  max_packet_size > max_allowed_packet
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                            | expect                                    |
      | conn_1 | True    | show variables like 'max_allowed_packet%'      | has{(('max_allowed_packet', '9438208'),)} |
    Given execute sql in "mysql-master2"
      | conn   | toClose | sql                                            | expect                                    |
      | conn_2 | True    | show variables like 'max_allowed_packet%'      | has{(('max_allowed_packet', '9438208'),)} |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DmaxPacketSize=9437184/-DmaxPacketSize=8000000/
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name='maxPacketSize'    | has{(('8000000B',),)} | dble_information |
      | conn_0 | true    | select @@max_allowed_packet                                                      | has{((8000000,),)}    | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect              | db        |
      | conn_1 | true    | select @@max_allowed_packet      | has{((8000000,),)}  | schema1   |


  @restore_view
  Scenario: homePath and viewPersistenceConfBaseDir in bootstrap.cnf, restart dble and check paths #9
     """
    {'restore_view':{'dble-1':{'schema1':'view1'}}}
    """
    Given I remove path "/opt/logs/view_logs" in "dble-1" if exist
    Then check path "/opt/logs/view_logs" in "dble-1" should not exist
    Given I remove path "/opt/logs/tx_logs" in "dble-1" if exist
    Then check path "/opt/logs/tx_logs" in "dble-1" should not exist
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      /-DhomePath=./c -DhomePath=/opt/logs
      $a\-DviewPersistenceConfBaseDir=/view_logs
      $a\-DrecordTxn=1
      $a\-DtransactionLogBaseDir=/tx_logs
    """
    Then restart dble in "dble-1" success
    Then  execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1;                      | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20));     | success | schema1 |
      | conn_0 | False   | drop view if exists view1 ;                              | success | schema1 |
      | conn_0 | False   | create view view1 as select id from sharding_4_t1;       | success | schema1 |
      | conn_0 | False   | begin;                                                   | success | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4); | success | schema1 |
      | conn_0 | True    | commit;                                                  | success | schema1 |
    Then check path "/opt/logs/view_logs" in "dble-1" should exist
    Then check path "/opt/logs/tx_logs" in "dble-1" should exist

  Scenario: DO NOT config 'homePath' in bootstrap.cnf, restart dble failed #10
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DhomePath/d
    """
    Then restart dble in "dble-1" failed for
    """
    homePath is not set
    """


  Scenario: enable/disable parameters support 0/1/false/true #11
    # set parameters values: 0
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      $a\-DuseCompression=0
      $a\-DusingAIO=0
      $a\-DuseThreadUsageStat=0
      $a\-DusePerformanceMode=0
      $a\-DuseCostTimeStat=0
      $a\-Dautocommit=0
      $a\-DcheckTableConsistency=0
      $a\-DrecordTxn=0
      $a\-DfrontSocketNoDelay=0
      $a\-DbackSocketNoDelay=0
      $a\-DenableGeneralLog=0
      $a\-DenableBatchLoadData=0
      $a\-DenableRoutePenetration=0
      $a\-DenableAlert=0
      $a\-DenableStatistic=0
      $a\-DenableStatisticAnalysis=0
      $a\-DenableSessionActiveRatioStat=0
      $a\-DenableConnectionAssociateThread=0
      $a\-DenableAsyncRelease=0
      $a\-DenableMemoryBufferMonitor=0
      $a\-DenableMemoryBufferMonitorRecordPool=0
      $a\-DenableSlowLog=0
      $a\-DenableSqlDumpLog=0
      $a\-DuseSerializableMode=0
      $a\-DsqlDumpLogOnStartupRotate=0

      $a\-DcapClientFoundRows=0
      $a\-DuseJoinStrategy=0
      $a\-DenableCursor=0
      $a\-DenableFlowControl=0
      $a\-DuseOuterHa=0
      $a\-DuseNewJoinOptimizer=0
      $a\-DinSubQueryTransformToJoin=0
      $a\-DcloseHeartBeatRecord=0
    """
      #$a\-DsupportSSL=0

    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_rs1"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select * from dble_variables | dble_information |
    Then check resultset "dble_variables_rs1" has lines with following column values
      | variable_name-0                         | variable_value-1                            | comment-2                                                                                                                                                                                                            | read_only-3 |
      # useNewJoinOptimizer, useSerializableMode, enableTrace未显示
      | useCompression                          | 0                                           | Whether the Compression is enable, the default number is 0                                                                                                                                                           | true        |
      | usingAIO                                | 0                                           | Whether the AIO is enable, the default number is 0(use NIO instead)                                                                                                                                                  | true        |
      | useThreadUsageStat                      | 0                                           | Whether the thread usage statistics function is enabled. The default value is 0                                                                                                                                      | true        |
      | usePerformanceMode                      | 0                                           | Whether use the performance mode is enabled. The default value is 0                                                                                                                                                  | true        |
      | useCostTimeStat                         | 0                                           | Whether the cost time of query can be track by Btrace. The default value is 0                                                                                                                                        | true        |
      | autocommit                              | 0                                           | The initially autocommit value.The default value is 1                                                                                                                                                                | true        |
      | checkTableConsistency                   | 0                                           | Whether the consistency tableStructure check is enabled. The default value is 0                                                                                                                                      | true        |
      | recordTxn                               | 0                                           | Whether the transaction be recorded as a file, the default value is 0                                                                                                                                                | true        |
      | frontSocketNoDelay                      | 0                                           | The frontend nagle is disabled. The default value is 1                                                                                                                                                               | true        |
      | backSocketNoDelay                       | 0                                           | The backend nagle is disabled. The default value is 1                                                                                                                                                                | true        |
      | enableGeneralLog                        | 0                                           | Enable general log                                                                                                                                                                                                   | false       |
      | enableBatchLoadData                     | 0                                           | Enable Batch Load Data. The default value is 0(false)                                                                                                                                                                | false       |
      | enableRoutePenetration                  | 0                                           | Whether enable route penetration.The default value is 0                                                                                                                                                              | true        |
      | enableAlert                             | 0                                           | Enable or disable alert                                                                                                                                                                                              | false       |
      | enableStatistic                         | 0                                           | Enable statistic sql, the default is 0(false)                                                                                                                                                                        | false       |
      | enableStatisticAnalysis                 | 0                                           | Enable statistic analysis sql('show @@sql.sum.user/table' or 'show @@sql.condition'), the default is 0(false)                                                                                                        | false       |
      | enableSessionActiveRatioStat            | 0                                           | Whether frontend connection activity ratio statistics are enabled. The default value is 1.                                                                                                                           | true        |
      | enableConnectionAssociateThread         | 0                                           | Whether to open frontend connection and backend connection are associated with threads. The default value is 1.                                                                                                      | true        |
      | enableAsyncRelease                      | 0                                           | Whether enable async release . default value is 1(on).                                                                                                                                                               | true        |
      | enableMemoryBufferMonitor               | 0                                           | Whether enable memory buffer monitor, enable this option will cost a lot of  resources. the default value is 0(off)                                                                                                  | false       |
      | enableMemoryBufferMonitorRecordPool     | 0                                           | Whether record the connection pool memory if the memory buffer monitor is ON. the default value is 1(ON).                                                                                                            | true        |
      | enableSlowLog                           | 0                                           | Enable Slow Query Log                                                                                                                                                                                                | false       |
      | enableSqlDumpLog                        | 0                                           | Whether enable sqlDumpLog, the default value is 0(off)                                                                                                                                                               | false       |
      | capClientFoundRows                      | false                                       | Whether to turn on EOF_Packet to return found rows, the default value is false                                                                                                                                       | false       |
      | useJoinStrategy                         | false                                       | Whether nest loop join is enabled. The default value is false                                                                                                                                                        | true        |
      | enableCursor                            | false                                       | Whether the server-side cursor  is enable or not. The default value is false                                                                                                                                         | true        |
      | enableFlowControl                       | false                                       | Whether use flow control feature                                                                                                                                                                                     | false       |
      | useOuterHa                              | false                                       | Whether use outer ha component. The default value is true and it will always true when clusterEnable=true.If no component in fact, nothing will happen.                                                              | true        |
      | inSubQueryTransformToJoin               | false                                       | The inSubQuery is transformed into the join ,the default value is false                                                                                                                                              | true        |
      | closeHeartBeatRecord                    | false                                       | close heartbeat record. if closed, `show @@dbinstance.synstatus`,`show @@dbinstance.syndetail`,`show @@heartbeat.detail` will be empty and `show @@heartbeat`'s EXECUTE_TIME will be '-' .The default value is false | true        |
      | isSupportSSL                            | false                                       | isSupportSSL in configuration                                                                                                                                                                                        | true        |
      | sqlDumpLogOnStartupRotate               | 0                                           | The onStartup of rotate policy, the default value is 1; -1 said not to participate in the strategy                                                                                                                   | true        |

    # set parameters values: 1
     Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      s/-DenableSessionActiveRatioStat=0/-DenableSessionActiveRatioStat=1/
      s/-DenableConnectionAssociateThread=0/-DenableConnectionAssociateThread=1/
      s/-DenableFlowControl=0/-DenableFlowControl=1/
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_rs2"
      | conn   | toClose | sql                                                                                                                                         | db               |
      | conn_1 | true    | select * from dble_variables where variable_name in ('enableSessionActiveRatioStat','enableConnectionAssociateThread','enableFlowControl') | dble_information |
    Then check resultset "dble_variables_rs2" has lines with following column values
      | variable_name-0                         | variable_value-1                            | comment-2                                                                                                                                                                                                            | read_only-3 |
      | enableSessionActiveRatioStat            | 1                                           | Whether frontend connection activity ratio statistics are enabled. The default value is 1.                                                                                                                           | true        |
      | enableConnectionAssociateThread         | 1                                           | Whether to open frontend connection and backend connection are associated with threads. The default value is 1.                                                                                                      | true        |
      | enableFlowControl                       | true                                        | Whether use flow control feature                                                                                                                                                                                     | false       |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      s/-DuseCompression=0/-DuseCompression=1/
      s/-DusingAIO=0/-DusingAIO=1/
      s/-DuseThreadUsageStat=0/-DuseThreadUsageStat=1/
      s/-DusePerformanceMode=0/-DusePerformanceMode=1/
      s/-DuseCostTimeStat=0/-DuseCostTimeStat=1/
      s/-Dautocommit=0/-Dautocommit=1/
      s/-DcheckTableConsistency=0/-DcheckTableConsistency=1/
      s/-DrecordTxn=0/-DrecordTxn=1/
      s/-DfrontSocketNoDelay=0/-DfrontSocketNoDelay=1/
      s/-DbackSocketNoDelay=0/-DbackSocketNoDelay=1/
      s/-DenableGeneralLog=0/-DenableGeneralLog=1/
      s/-DenableBatchLoadData=0/-DenableBatchLoadData=1/
      s/-DenableRoutePenetration=0/-DenableRoutePenetration=1/
      s/-DenableAlert=0/-DenableAlert=1/
      s/-DenableStatistic=0/-DenableStatistic=1/
      s/-DenableStatisticAnalysis=0/-DenableStatisticAnalysis=1/
      s/-DenableAsyncRelease=0/-DenableAsyncRelease=1/
      s/-DenableMemoryBufferMonitor=0/-DenableMemoryBufferMonitor=1/
      s/-DenableMemoryBufferMonitorRecordPool=0/-DenableMemoryBufferMonitorRecordPool=1/
      s/-DenableSlowLog=0/-DenableSlowLog=1/
      s/-DenableSqlDumpLog=0/-DenableSqlDumpLog=1/
      s/-DuseSerializableMode=0/-DuseSerializableMode=1/
      s/-DsqlDumpLogOnStartupRotate=0/-DsqlDumpLogOnStartupRotate=1/

      s/-DcapClientFoundRows=0/-DcapClientFoundRows=1/
      s/-DuseJoinStrategy=0/-DuseJoinStrategy=1/
      s/-DenableCursor=0/-DenableCursor=1/
      s/-DuseOuterHa=0/-DuseOuterHa=1/
      s/-DuseNewJoinOptimizer=0/-DuseNewJoinOptimizer=1/
      s/-DinSubQueryTransformToJoin=0/-DinSubQueryTransformToJoin=1/
      s/-DcloseHeartBeatRecord=0/-DcloseHeartBeatRecord=1/

      $a -DroutePenetrationRules={"rules":[{"regex":"select\\\\sid\\\\sfrom\\\\ssharding_2_t1"}]}
    """
      #s/-DsupportSSL=0/-DsupportSSL=1/

    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_rs2"
      | conn   | toClose | sql                          | db               |
      | conn_1 | true    | select * from dble_variables | dble_information |
    Then check resultset "dble_variables_rs2" has lines with following column values
      | variable_name-0                         | variable_value-1                            | comment-2                                                                                                                                                                                                            | read_only-3 |
      # useNewJoinOptimizer, useSerializableMode, enableTrace未显示
      | useCompression                          | 1                                           | Whether the Compression is enable, the default number is 0                                                                                                                                                           | true        |
      | usingAIO                                | 1                                           | Whether the AIO is enable, the default number is 0(use NIO instead)                                                                                                                                                  | true        |
      | useThreadUsageStat                      | 1                                           | Whether the thread usage statistics function is enabled. The default value is 0                                                                                                                                      | true        |
      | usePerformanceMode                      | 1                                           | Whether use the performance mode is enabled. The default value is 0                                                                                                                                                  | true        |
      | useCostTimeStat                         | 1                                           | Whether the cost time of query can be track by Btrace. The default value is 0                                                                                                                                        | true        |
      | autocommit                              | 1                                           | The initially autocommit value.The default value is 1                                                                                                                                                                | true        |
      | checkTableConsistency                   | 1                                           | Whether the consistency tableStructure check is enabled. The default value is 0                                                                                                                                      | true        |
      | recordTxn                               | 1                                           | Whether the transaction be recorded as a file, the default value is 0                                                                                                                                                | true        |
      | frontSocketNoDelay                      | 1                                           | The frontend nagle is disabled. The default value is 1                                                                                                                                                               | true        |
      | backSocketNoDelay                       | 1                                           | The backend nagle is disabled. The default value is 1                                                                                                                                                                | true        |
      | enableGeneralLog                        | 1                                           | Enable general log                                                                                                                                                                                                   | false       |
      | enableBatchLoadData                     | 1                                           | Enable Batch Load Data. The default value is 0(false)                                                                                                                                                                | false       |
      | enableRoutePenetration                  | 1                                           | Whether enable route penetration.The default value is 0                                                                                                                                                              | true        |
      | enableAlert                             | 1                                           | Enable or disable alert                                                                                                                                                                                              | false       |
      | enableStatistic                         | 1                                           | Enable statistic sql, the default is 0(false)                                                                                                                                                                        | false       |
      | enableStatisticAnalysis                 | 1                                           | Enable statistic analysis sql('show @@sql.sum.user/table' or 'show @@sql.condition'), the default is 0(false)                                                                                                        | false       |
      # usePerformanceMode=1时，配置不生效
      | enableSessionActiveRatioStat            | 0                                           | Whether frontend connection activity ratio statistics are enabled. The default value is 1.                                                                                                                           | true        |
      # usePerformanceMode=1时，配置不生效
      | enableConnectionAssociateThread         | 0                                           | Whether to open frontend connection and backend connection are associated with threads. The default value is 1.                                                                                                      | true        |
      | enableAsyncRelease                      | 1                                           | Whether enable async release . default value is 1(on).                                                                                                                                                               | true        |
      | enableMemoryBufferMonitor               | 1                                           | Whether enable memory buffer monitor, enable this option will cost a lot of  resources. the default value is 0(off)                                                                                                  | false       |
      | enableMemoryBufferMonitorRecordPool     | 1                                           | Whether record the connection pool memory if the memory buffer monitor is ON. the default value is 1(ON).                                                                                                            | true        |
      | enableSlowLog                           | 1                                           | Enable Slow Query Log                                                                                                                                                                                                | false       |
      | enableSqlDumpLog                        | 1                                           | Whether enable sqlDumpLog, the default value is 0(off)                                                                                                                                                               | false       |
      | capClientFoundRows                      | true                                        | Whether to turn on EOF_Packet to return found rows, the default value is false                                                                                                                                       | false       |
      | useJoinStrategy                         | true                                        | Whether nest loop join is enabled. The default value is false                                                                                                                                                        | true        |
      | enableCursor                            | true                                        | Whether the server-side cursor  is enable or not. The default value is false                                                                                                                                         | true        |
      # usingAIO=1时，配置不生效 flow control is not support AIO
      | enableFlowControl                       | false                                       | Whether use flow control feature                                                                                                                                                                                     | false       |
      | useOuterHa                              | true                                        | Whether use outer ha component. The default value is true and it will always true when clusterEnable=true.If no component in fact, nothing will happen.                                                              | true        |
      | inSubQueryTransformToJoin               | true                                        | The inSubQuery is transformed into the join ,the default value is false                                                                                                                                              | true        |
      | closeHeartBeatRecord                    | true                                        | close heartbeat record. if closed, `show @@dbinstance.synstatus`,`show @@dbinstance.syndetail`,`show @@heartbeat.detail` will be empty and `show @@heartbeat`'s EXECUTE_TIME will be '-' .The default value is false | true        |
      | isSupportSSL                            | false                                       | isSupportSSL in configuration                                                                                                                                                                                        | true        |
      | sqlDumpLogOnStartupRotate               | 1                                           | The onStartup of rotate policy, the default value is 1; -1 said not to participate in the strategy                                                                                                                   | true        |

    # set parameters values: false
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      $a\-DuseCompression=false
      $a\-DusingAIO=false
      $a\-DuseThreadUsageStat=false
      $a\-DusePerformanceMode=false
      $a\-DuseCostTimeStat=false
      $a\-Dautocommit=false
      $a\-DcheckTableConsistency=false
      $a\-DrecordTxn=false
      $a\-DfrontSocketNoDelay=false
      $a\-DbackSocketNoDelay=false
      $a\-DenableGeneralLog=false
      $a\-DenableBatchLoadData=false
      $a\-DenableRoutePenetration=false
      $a\-DenableAlert=false
      $a\-DenableStatistic=false
      $a\-DenableStatisticAnalysis=false
      $a\-DenableSessionActiveRatioStat=false
      $a\-DenableConnectionAssociateThread=false
      $a\-DenableAsyncRelease=false
      $a\-DenableMemoryBufferMonitor=false
      $a\-DenableMemoryBufferMonitorRecordPool=false
      $a\-DenableSlowLog=false

      $a\-DcapClientFoundRows=false
      $a\-DuseJoinStrategy=false
      $a\-DenableCursor=false
      $a\-DenableFlowControl=false
      $a\-DuseOuterHa=false
      $a\-DuseNewJoinOptimizer=false
      $a\-DinSubQueryTransformToJoin=false
      $a\-DcloseHeartBeatRecord=false
      $a\-DsupportSSL=false
    """
      #$a\-DenableSqlDumpLog=false
      #$a\-DuseSerializableMode=false
      #$a\-DsqlDumpLogOnStartupRotate=false

    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_rs1"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select * from dble_variables | dble_information |
    Then check resultset "dble_variables_rs1" has lines with following column values
      | variable_name-0                         | variable_value-1                            | comment-2                                                                                                                                                                                                            | read_only-3 |
        # useNewJoinOptimizer, useSerializableMode, enableTrace未显示
      | useCompression                          | 0                                           | Whether the Compression is enable, the default number is 0                                                                                                                                                           | true        |
      | usingAIO                                | 0                                           | Whether the AIO is enable, the default number is 0(use NIO instead)                                                                                                                                                  | true        |
      | useThreadUsageStat                      | 0                                           | Whether the thread usage statistics function is enabled. The default value is 0                                                                                                                                      | true        |
      | usePerformanceMode                      | 0                                           | Whether use the performance mode is enabled. The default value is 0                                                                                                                                                  | true        |
      | useCostTimeStat                         | 0                                           | Whether the cost time of query can be track by Btrace. The default value is 0                                                                                                                                        | true        |
      | autocommit                              | 0                                           | The initially autocommit value.The default value is 1                                                                                                                                                                | true        |
      | checkTableConsistency                   | 0                                           | Whether the consistency tableStructure check is enabled. The default value is 0                                                                                                                                      | true        |
      | recordTxn                               | 0                                           | Whether the transaction be recorded as a file, the default value is 0                                                                                                                                                | true        |
      | frontSocketNoDelay                      | 0                                           | The frontend nagle is disabled. The default value is 1                                                                                                                                                               | true        |
      | backSocketNoDelay                       | 0                                           | The backend nagle is disabled. The default value is 1                                                                                                                                                                | true        |
      | enableGeneralLog                        | 0                                           | Enable general log                                                                                                                                                                                                   | false       |
      | enableBatchLoadData                     | 0                                           | Enable Batch Load Data. The default value is 0(false)                                                                                                                                                                | false       |
      | enableRoutePenetration                  | 0                                           | Whether enable route penetration.The default value is 0                                                                                                                                                              | true        |
      | enableAlert                             | 0                                           | Enable or disable alert                                                                                                                                                                                              | false       |
      | enableStatistic                         | 0                                           | Enable statistic sql, the default is 0(false)                                                                                                                                                                        | false       |
      | enableSessionActiveRatioStat            | 0                                           | Whether frontend connection activity ratio statistics are enabled. The default value is 1.                                                                                                                           | true        |
      | enableConnectionAssociateThread         | 0                                           | Whether to open frontend connection and backend connection are associated with threads. The default value is 1.                                                                                                      | true        |
      | enableAsyncRelease                      | 0                                           | Whether enable async release . default value is 1(on).                                                                                                                                                               | true        |
      | enableMemoryBufferMonitor               | 0                                           | Whether enable memory buffer monitor, enable this option will cost a lot of  resources. the default value is 0(off)                                                                                                  | false       |
      | enableMemoryBufferMonitorRecordPool     | 0                                           | Whether record the connection pool memory if the memory buffer monitor is ON. the default value is 1(ON).                                                                                                            | true        |
      | enableSlowLog                           | 0                                           | Enable Slow Query Log                                                                                                                                                                                                | false       |
  #      | enableSqlDumpLog                        | 0                                           | Whether enable sqlDumpLog, the default value is 0(off)                                                                                                                                                               | false       |
      | capClientFoundRows                      | false                                       | Whether to turn on EOF_Packet to return found rows, the default value is false                                                                                                                                       | false       |
      | useJoinStrategy                         | false                                       | Whether nest loop join is enabled. The default value is false                                                                                                                                                        | true        |
      | enableCursor                            | false                                       | Whether the server-side cursor  is enable or not. The default value is false                                                                                                                                         | true        |
      | enableFlowControl                       | false                                       | Whether use flow control feature                                                                                                                                                                                     | false       |
      | useOuterHa                              | false                                       | Whether use outer ha component. The default value is true and it will always true when clusterEnable=true.If no component in fact, nothing will happen.                                                              | true        |
      | inSubQueryTransformToJoin               | false                                       | The inSubQuery is transformed into the join ,the default value is false                                                                                                                                              | true        |
      | closeHeartBeatRecord                    | false                                       | close heartbeat record. if closed, `show @@dbinstance.synstatus`,`show @@dbinstance.syndetail`,`show @@heartbeat.detail` will be empty and `show @@heartbeat`'s EXECUTE_TIME will be '-' .The default value is false | true        |
      | isSupportSSL                            | false                                       | isSupportSSL in configuration                                                                                                                                                                                        | true        |
#      | sqlDumpLogOnStartupRotate               | 0                                           | The onStartup of rotate policy, the default value is 1; -1 said not to participate in the strategy                                                                                                                   | true        |

      # set parameters values: 1
     Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      s/-DenableSessionActiveRatioStat=false/-DenableSessionActiveRatioStat=true/
      s/-DenableConnectionAssociateThread=false/-DenableConnectionAssociateThread=true/
      s/-DenableFlowControl=false/-DenableFlowControl=true/
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_rs2"
      | conn   | toClose | sql                                                                                                                                                     | db               |
      | conn_1 | true    | select * from dble_variables where variable_name in ('enableSessionActiveRatioStat','enableConnectionAssociateThread','enableFlowControl','supportSSL') | dble_information |
    Then check resultset "dble_variables_rs2" has lines with following column values
      | variable_name-0                         | variable_value-1                            | comment-2                                                                                                                                                                                                            | read_only-3 |
      | enableSessionActiveRatioStat            | 1                                           | Whether frontend connection activity ratio statistics are enabled. The default value is 1.                                                                                                                           | true        |
      | enableConnectionAssociateThread         | 1                                           | Whether to open frontend connection and backend connection are associated with threads. The default value is 1.                                                                                                      | true        |
      | enableFlowControl                       | true                                        | Whether use flow control feature                                                                                                                                                                                     | false       |

    # set parameters values: true
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      s/-DuseCompression=false/-DuseCompression=true/
      s/-DusingAIO=false/-DusingAIO=true/
      s/-DuseThreadUsageStat=false/-DuseThreadUsageStat=true/
      s/-DusePerformanceMode=false/-DusePerformanceMode=true/
      s/-DuseCostTimeStat=false/-DuseCostTimeStat=true/
      s/-Dautocommit=false/-Dautocommit=true/
      s/-DcheckTableConsistency=false/-DcheckTableConsistency=true/
      s/-DrecordTxn=false/-DrecordTxn=true/
      s/-DfrontSocketNoDelay=false/-DfrontSocketNoDelay=true/
      s/-DbackSocketNoDelay=false/-DbackSocketNoDelay=true/
      s/-DenableGeneralLog=false/-DenableGeneralLog=true/
      s/-DenableBatchLoadData=false/-DenableBatchLoadData=true/
      s/-DenableRoutePenetration=false/-DenableRoutePenetration=true/
      s/-DenableAlert=false/-DenableAlert=true/
      s/-DenableStatistic=false/-DenableStatistic=true/
      s/-DenableStatisticAnalysis=false/-DenableStatisticAnalysis=true/
      s/-DenableAsyncRelease=false/-DenableAsyncRelease=true/
      s/-DenableMemoryBufferMonitor=false/-DenableMemoryBufferMonitor=true/
      s/-DenableMemoryBufferMonitorRecordPool=false/-DenableMemoryBufferMonitorRecordPool=true/
      s/-DenableSlowLog=false/-DenableSlowLog=true/

      s/-DcapClientFoundRows=false/-DcapClientFoundRows=true/
      s/-DuseJoinStrategy=false/-DuseJoinStrategy=true/
      s/-DenableCursor=false/-DenableCursor=true/
      s/-DuseOuterHa=false/-DuseOuterHa=true/
      s/-DuseNewJoinOptimizer=false/-DuseNewJoinOptimizer=true/
      s/-DinSubQueryTransformToJoin=false/-DinSubQueryTransformToJoin=true/
      s/-DcloseHeartBeatRecord=false/-DcloseHeartBeatRecord=true/

      $a -DroutePenetrationRules={"rules":[{"regex":"select\\\\sid\\\\sfrom\\\\ssharding_2_t1"}]}
    """
      #s/-DsupportSSL=false/-DsupportSSL=true/ supportSSL为true时需要配置证书dble才能启动成功
      #s/-DenableSqlDumpLog=false/-DenableSqlDumpLog=true/
      #s/-DuseSerializableMode=false/-DuseSerializableMode=true/
      #s/-DsqlDumpLogOnStartupRotate=false/-DsqlDumpLogOnStartupRotate=true/

    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_rs2"
      | conn   | toClose | sql                          | db               |
      | conn_1 | true    | select * from dble_variables | dble_information |
    Then check resultset "dble_variables_rs2" has lines with following column values
      | variable_name-0                         | variable_value-1                            | comment-2                                                                                                                                                                                                            | read_only-3 |
      # useNewJoinOptimizer, useSerializableMode, enableTrace未显示
      | useCompression                          | 1                                           | Whether the Compression is enable, the default number is 0                                                                                                                                                           | true        |
      | usingAIO                                | 1                                           | Whether the AIO is enable, the default number is 0(use NIO instead)                                                                                                                                                  | true        |
      | useThreadUsageStat                      | 1                                           | Whether the thread usage statistics function is enabled. The default value is 0                                                                                                                                      | true        |
      | usePerformanceMode                      | 1                                           | Whether use the performance mode is enabled. The default value is 0                                                                                                                                                  | true        |
      | useCostTimeStat                         | 1                                           | Whether the cost time of query can be track by Btrace. The default value is 0                                                                                                                                        | true        |
      | autocommit                              | 1                                           | The initially autocommit value.The default value is 1                                                                                                                                                                | true        |
      | checkTableConsistency                   | 1                                           | Whether the consistency tableStructure check is enabled. The default value is 0                                                                                                                                      | true        |
      | recordTxn                               | 1                                           | Whether the transaction be recorded as a file, the default value is 0                                                                                                                                                | true        |
      | frontSocketNoDelay                      | 1                                           | The frontend nagle is disabled. The default value is 1                                                                                                                                                               | true        |
      | backSocketNoDelay                       | 1                                           | The backend nagle is disabled. The default value is 1                                                                                                                                                                | true        |
      | enableGeneralLog                        | 1                                           | Enable general log                                                                                                                                                                                                   | false       |
      | enableBatchLoadData                     | 1                                           | Enable Batch Load Data. The default value is 0(false)                                                                                                                                                                | false       |
      | enableRoutePenetration                  | 1                                           | Whether enable route penetration.The default value is 0                                                                                                                                                              | true        |
      | enableAlert                             | 1                                           | Enable or disable alert                                                                                                                                                                                              | false       |
      | enableStatistic                         | 1                                           | Enable statistic sql, the default is 0(false)                                                                                                                                                                        | false       |
      # usePerformanceMode=1时，配置不生效
      | enableSessionActiveRatioStat            | 0                                           | Whether frontend connection activity ratio statistics are enabled. The default value is 1.                                                                                                                           | true        |
      # usePerformanceMode=1时，配置不生效
      | enableConnectionAssociateThread         | 0                                           | Whether to open frontend connection and backend connection are associated with threads. The default value is 1.                                                                                                      | true        |
      | enableAsyncRelease                      | 1                                           | Whether enable async release . default value is 1(on).                                                                                                                                                               | true        |
      | enableMemoryBufferMonitor               | 1                                           | Whether enable memory buffer monitor, enable this option will cost a lot of  resources. the default value is 0(off)                                                                                                  | false       |
      | enableMemoryBufferMonitorRecordPool     | 1                                           | Whether record the connection pool memory if the memory buffer monitor is ON. the default value is 1(ON).                                                                                                            | true        |
      | enableSlowLog                           | 1                                           | Enable Slow Query Log                                                                                                                                                                                                | false       |
      | enableSqlDumpLog                        | 1                                           | Whether enable sqlDumpLog, the default value is 0(off)                                                                                                                                                               | false       |

      | capClientFoundRows                      | true                                        | Whether to turn on EOF_Packet to return found rows, the default value is false                                                                                                                                       | false       |
      | useJoinStrategy                         | true                                        | Whether nest loop join is enabled. The default value is false                                                                                                                                                        | true        |
      | enableCursor                            | true                                        | Whether the server-side cursor  is enable or not. The default value is false                                                                                                                                         | true        |
      # usingAIO=1时，配置不生效 flow control is not support AIO
      | enableFlowControl                       | false                                       | Whether use flow control feature                                                                                                                                                                                     | false       |
      | useOuterHa                              | true                                        | Whether use outer ha component. The default value is true and it will always true when clusterEnable=true.If no component in fact, nothing will happen.                                                              | true        |
      | inSubQueryTransformToJoin               | true                                        | The inSubQuery is transformed into the join ,the default value is false                                                                                                                                              | true        |
      | closeHeartBeatRecord                    | true                                        | close heartbeat record. if closed, `show @@dbinstance.synstatus`,`show @@dbinstance.syndetail`,`show @@heartbeat.detail` will be empty and `show @@heartbeat`'s EXECUTE_TIME will be '-' .The default value is false | true        |
      | isSupportSSL                            | false                                       | isSupportSSL in configuration                                                                                                                                                                                        | true        |
#      | sqlDumpLogOnStartupRotate               | 1                                           | The onStartup of rotate policy, the default value is 1; -1 said not to participate in the strategy                                                                                                                   | true        |