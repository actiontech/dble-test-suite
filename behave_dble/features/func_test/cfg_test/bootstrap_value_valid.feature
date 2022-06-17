# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2019/1/3
Feature: if childnodes value of system in bootstrap.cnf are invalid, replace them with default values
  only check part of system childnodes, not all, list from https://github.com/actiontech/dble/issues/579

  @NORMAL
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
      Property \[ autocommit \] '-3' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      property \[ backSocketNoDelay \] '2' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      Property \[ backSocketSoRcvbuf \] '-4194304' in bootstrap.cnf is illegal, you may need use the default value 4194304 replaced
      Property \[ backSocketSoSndbuf \] '-1048576' in bootstrap.cnf is illegal, you may need use the default value 1048576 replaced
      Property \[ backendProcessorExecutor \] '-4' in bootstrap.cnf is illegal, you may need use the default value 16 replaced
      Property \[ backendProcessors \] '-3' in bootstrap.cnf is illegal, you may need use the default value 16 replaced
      Property \[ processorExecutor \] '-3' in bootstrap.cnf is illegal, you may need use the default value 16 replaced
      Property \[ writeToBackendExecutor \] '-4' in bootstrap.cnf is illegal, you may need use the default value 16 replaced
      Property \[ processors \] '-3' in bootstrap.cnf is illegal, you may need use the default value 16 replaced
      Property \[ complexExecutor \] '-4' in bootstrap.cnf is illegal, you may need use the default value 8 replaced
      Property \[ charset \] 'utf-8' in bootstrap.cnf is illegal, use utf8mb4 replaced
      property \[ bufferPoolChunkSize \] '-32767' in bootstrap.cnf is illegal, you may need use the default value 4096 replaced
      Property \[ bufferPoolPageNumber \] '-512' in bootstrap.cnf is illegal, you may need use the default value 409 replaced
      property \[ bufferPoolPageSize \] '-2000' in bootstrap.cnf is illegal, you may need use the default value 2097152 replaced
      property \[ bufferUsagePercent \] '120' in bootstrap.cnf is illegal, you may need use the default value 80 replaced
      property \[ checkTableConsistency \] '-10100101' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      property \[ checkTableConsistencyPeriod \] '-1800' in bootstrap.cnf is illegal, you may need use the default value 1800000 replaced
      property \[ clearBigSQLResultSetMapMs \] '-600000' in bootstrap.cnf is illegal, you may need use the default value 600000 replaced
      Property \[ costSamplePercent \] '-2' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      property \[ enableFlowControl \] '1' data type should be boolean
      property \[ enableSlowLog \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property \[ flushSlowLogPeriod \] '-1' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      Property \[ flushSlowLogSize \] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      property \[ frontSocketNoDelay \] '2' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      Property \[ frontSocketSoRcvbuf \] '-1048576' in bootstrap.cnf is illegal, you may need use the default value 1048576 replaced
      Property \[ frontSocketSoSndbuf \] '-4194304' in bootstrap.cnf is illegal, you may need use the default value 4194304 replaced
      property \[ joinMemSize \] '-5' in bootstrap.cnf is illegal, you may need use the default value 4 replaced
      property \[ joinQueueSize \] '-1024' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
      property \[ mappedFileSize \] '-5' in bootstrap.cnf is illegal, you may need use the default value 67108864 replaced
      property \[ maxCharsPerColumn \] '-65534' in bootstrap.cnf is illegal, you may need use the default value 65535 replaced
      Property \[ maxCon \] '-3' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property \[ maxCostStatSize \] '-10' in bootstrap.cnf is illegal, you may need use the default value 100 replaced
      property \[ maxPacketSize \] '-1000' in bootstrap.cnf is illegal, you may need use the default value 4194304 replaced
      Property \[ maxResultSet \] '-524288' in bootstrap.cnf is illegal, you may need use the default value 524288 replaced
      Property \[ maxRowSizeToFile \] '-10000' in bootstrap.cnf is illegal, you may need use the default value 10000 replaced
      Property \[ mergeQueueSize \] '-1024' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
      property \[ nestLoopConnSize \] '-5' in bootstrap.cnf is illegal, you may need use the default value 4 replaced
      property \[ nestLoopRowsSize \] '-2000' in bootstrap.cnf is illegal, you may need use the default value 2000 replaced
      Property \[ orderByQueueSize \] '-1024' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
      property \[ orderMemSize \] '-5' in bootstrap.cnf is illegal, you may need use the default value 4 replaced
      property \[ otherMemSize \] '-5' in bootstrap.cnf is illegal, you may need use the default value 4 replaced
      Property \[ processorCheckPeriod \] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      property \[ recordTxn \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property \[ sqlExecuteTimeout \] '-20' in bootstrap.cnf is illegal, you may need use the default value 300 replaced
      Property \[ sqlRecordCount \] '-10' in bootstrap.cnf is illegal, you may need use the default value 10 replaced
      property \[ sqlSlowTime \] '-100' in bootstrap.cnf is illegal, you may need use the default value 100 replaced
      Property \[ txIsolation \] '30' in bootstrap.cnf is illegal, you may need use the default value 3 replaced
      property \[ useCompression \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      property \[ useCostTimeStat \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      property \[ useJoinStrategy \] '0' data type should be boolean
      property \[ useOuterHa \] '1' data type should be boolean
      property \[ usePerformanceMode \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      property \[ useSqlStat \] '2' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      property \[ useThreadUsageStat \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      property \[ usingAIO \] '2' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property \[ xaLogCleanPeriod \] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      Property \[ xaRetryCount \] '-1' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property \[ xaSessionCheckPeriod \] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
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
        You must config instanceName in bootstrap.cnf and make sure it is an unique key for cluster
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
    $a\showBinlogStatusTimeout=-60000
    $a\sequenceHandlerType=20
    $a\sequenceStartTime=2010/11/04 09:42:54
    $a\sequenceInstanceByZk=1
    """
    Then restart dble in "dble-1" failed for
    """
    property \[ clusterEnable \] '1' data type should be boolean
    property \[ needSyncHa \] '1' data type should be boolean
    equenceHandlerType value is 20, it will use default value:2
    property \[ sequenceInstanceByZk \] '1' data type should be boolean
    sequenceStartTime in cluster.cnf invalid format, you can use default value 2010-11-04 09:42:54
    showBinlogStatusTimeout value is -60000, you can use default value:60000
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

  @restore_global_setting
  Scenario:config  MaxPacketSize in bootstrap.cnf, dble will get the lower value of MaxPacketSize and (max_allowed_packet-1024) #8
  """
    {'restore_global_setting':{'mysql-master1':{'general_log':0}}}
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DmaxPacketSize=6291456
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sysparam_rs"
      | sql             |
      | show @@sysparam |
    Then check resultset "sysparam_rs" has lines with following column values
      | PARAM_NAME-0  | PARAM_VALUE-1 |
      | maxPacketSize | 6291456       |

    #case2 max_packet_size < max_allowed_packet
    Given stop dble in "dble-1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="user1" maxCon="1000" minCon="10" primary="true">
          </dbInstance>
      </dbGroup>
    """
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                            | expect  |
      | conn_0 | False   | set global general_log=on                      | success |
      | conn_0 | False   | drop user if exists 'user1'@'%'                | success |
      | conn_0 | False   | create user 'user1'@'%' identified by '111111' | success |
      | conn_0 | False   | grant select on *.* to 'user1'@'%'             | success |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DmaxPacketSize=5000000
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sysparam_rs"
      | sql             |
      | show @@sysparam |
    Then check resultset "sysparam_rs" has lines with following column values
      | PARAM_NAME-0  | PARAM_VALUE-1 |
      | maxPacketSize | 5000000       |

    #case 3  max_packet_size > max_allowed_packet
    Given stop dble in "dble-1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="user2" maxCon="1000" minCon="10" primary="true">
          </dbInstance>
      </dbGroup>
    """
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                                            | expect  |
      | conn_0 | False   | set global general_log=on                      | success |
      | conn_0 | False   | drop user if exists 'user2'@'%'                | success |
      | conn_0 | False   | create user 'user2'@'%' identified by '111111' | success |
      | conn_0 | False   | grant select on *.* to 'user2'@'%'             | success |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DmaxPacketSize=5000000/-DmaxPacketSize=8000000/
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sysparam_rs"
      | sql             |
      | show @@sysparam |
    Then check resultset "sysparam_rs" has lines with following column values
      | PARAM_NAME-0  | PARAM_VALUE-1 |
      | maxPacketSize | 6291456       |

  Scenario: homePath and viewPersistenceConfBaseDir in bootstrap.cnf, restart dble and check paths #9
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

  Scenario: homePath and viewPersistenceConfBaseDir in bootstrap.cnf, restart dble and check paths #10
    Given I remove path "/opt/dble/viewConf" in "dble-1" if exist
    Then check path "/opt/dble/viewConf" in "dble-1" should not exist
    Given I remove path "/opt/dble/txlogs" in "dble-1" if exist
    Then check path "/opt/dble/txlogs" in "dble-1" should not exist
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      /-DhomePath/d
      $a\-DrecordTxn=1
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
    Then check path "/opt/dble/viewConf" in "dble-1" should exist
    Then check path "/opt/dble/txlogs" in "dble-1" should exist