# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2019/1/3
Feature: if childnodes value of system in server.xml are invalid, replace them with default values
  only check part of system childnodes, not all, list from https://github.com/actiontech/dble/issues/579

  @NORMAL
  Scenario: config all system property, some values are illegal, start dble success #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="sequnceHandlerType">20</property>
        <property name="useSqlStat">false        </property>
        <property name="useCompression">true    </property>
        <property name="charset">utf-8</property>
        <property name="txIsolation">30       </property>
        <property name="recordTxn">false       </property>
        <property name="bufferUsagePercent">80%        </property>
        <property name="frontSocketNoDelay">true         </property>
        <property name="backSocketNoDelay">true          </property>
        <property name="usingAIO">false    </property>
        <property name="checkTableConsistency">false       </property>
        <property name="useCostTimeStat">false       </property>
        <property name="useThreadUsageStat">false       </property>
        <property name="usePerformanceMode">false       </property>
        <property name="usePerformanceMode">false       </property>
        <property name="enableSlowLog">false </property>
        <property name="useJoinStrategy">true     </property>

        <property name="bindIp">0.0.0.0</property>
        <property name="serverPort">8066</property>
        <property name="managerPort">9066</property>
        <property name="processors">4</property>
        <property name="processorExecutor">4</property>
        <property name="backendProcessors">4</property>
        <property name="backendProcessorExecutor">4</property>
        <property name="complexExecutor">4</property>
        <property name="writeToBackendExecutor">4</property>
        <property name="fakeMySQLVersion">5.6.24   </property>
        <property name="serverNodeId">1   </property>
        <property name="showBinlogStatusTimeout">60000</property>
        <property name="maxPacketSize">16777216</property>
        <property name="checkTableConsistencyPeriod">60000</property>
        <property name="dataNodeIdleCheckPeriod">300000  </property>
        <property name="dataNodeHeartbeatPeriod">10000   </property>
        <property name="processorCheckPeriod">1000    </property>
        <property name="sqlExecuteTimeout">300     </property>
        <property name="idleTimeout">1800000 </property>
        <property name="transactionLogBaseDir">/txlogs </property>
        <property name="transactionLogBaseName">server-tx</property>
        <property name="transactionRatateSize">16       </property>
        <property name="xaSessionCheckPeriod">1000     </property>
        <property name="xaLogCleanPeriod">1000     </property>
        <property name="xaRecoveryLogBaseDir">/tmlogs  </property>
        <property name="xaRecoveryLogBaseName">tmlog    </property>
        <property name="nestLoopConnSize">4        </property>
        <property name="nestLoopRowsSize">2000     </property>
        <property name="bufferPoolChunkSize">4096     </property>
        <property name="bufferPoolPageNumber">512      </property>
        <property name="bufferPoolPageSize">2097152  </property>
        <property name="clearBigSqLResultSetMapMs">600000   </property>
        <property name="sqlRecordCount">10            </property>
        <property name="maxResultSet">524288          </property>
        <property name="backSocketSoRcvbuf">4194304   </property>
        <property name="backSocketSoSndbuf">1048576   </property>
        <property name="frontSocketSoRcvbuf">1048576  </property>
        <property name="frontSocketSoSndbuf">4194304  </property>
    </system>
    """
    Given Restart dble in "dble-1" success
    Then get resultset of admin cmd "show @@sysparam" named "sysparam_rs"
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
      | sequnceHandlerType          | Local TimeStamp(like Snowflake) |
      | serverBacklog               | 2048                            |
      | serverNodeId                | 1                               |
      | showBinlogStatusTimeout     | 300ms                           |
      | maxCon                      | 0                            |
      | useCompression              | 0                               |
      | usingAIO                    | 0                               |
      | useZKSwitch                 | true                            |
      | useThreadUsageStat          | 0                               |
      | usePerformanceMode          | 0                               |
      | useCostTimeStat             | 0                               |
      | maxCostStatSize             | 100                             |
      | costSamplePercent           | 1                               |
      | charset                     | utf8mb4                            |
      | maxPacketSize               | 16M                             |
      | txIsolation                 | REPEATABLE_READ                 |
      | checkTableConsistency       | 0                               |
      | checkTableConsistencyPeriod | 60000ms                         |
      | dataNodeIdleCheckPeriod     | 300 Seconds                     |
      | dataNodeHeartbeatPeriod     | 10 Seconds                      |
      | processorCheckPeriod        | 1 Seconds                       |
      | idleTimeout                 | 30 Minutes                      |
      | sqlExecuteTimeout           | 300 Seconds                     |
      | recordTxn                   | 0                               |
      | transactionLogBaseDir       | /txlogs                         |
      | transactionLogBaseName      | server-tx                       |
      | transactionRatateSize       | 16M                             |
      | xaRecoveryLogBaseDir        | /tmlogs                         |
      | xaRecoveryLogBaseName       | tmlog                           |
      | xaSessionCheckPeriod        | 1000ms                          |
      | xaLogCleanPeriod            | 1000ms                          |
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
      | clearBigSqLResultSetMapMs   | 600000ms                        |
      | frontSocketSoRcvbuf         | 1048576B                        |
      | frontSocketSoSndbuf         | 4194304B                        |
      | frontSocketNoDelay          | 1                               |
      | backSocketSoRcvbuf          | 4194304B                        |
      | backSocketSoSndbuf          | 1048576B                        |
      | backSocketNoDelay           | 1                               |
      | clusterHeartbeatUser        | _HEARTBEAT_USER_                |
      | clusterHeartbeatPass        | _HEARTBEAT_PASS_                |
      | viewPersistenceConfBaseDir  | ./viewConf/                     |
      | viewPersistenceConfBaseName | viewJson                        |
      | joinQueueSize               | 1024                            |
      | mergeQueueSize              | 1024                            |
      | orderByQueueSize            | 1024                            |
      | enableSlowLog               | 0                               |
      | slowLogBaseDir              | ./slowlogs/                     |
      | slowLogBaseName             | slow-query                      |
      | flushSlowLogPeriod          | 1s                              |
      | flushSlowLogSize            | 1000                            |
      | sqlSlowTime                 | 100ms                           |
    Then get resultset of admin cmd "dryrun" named "dryrun_rs"
    Then check resultset "dryrun_rs" has lines with following column values
      | TYPE-0  | LEVEL-1 | DETAIL-2                                                                       |
      | Xml     | WARNING | property [ backSocketNoDelay ] 'true' data type should be int, skip            |
      | Xml     | WARNING | property [ bufferUsagePercent ] '80%' data type should be int, skip            |
      | Xml     | WARNING | Property [ charset ] 'utf-8' in server.xml is illegal, use utf8mb4 replaced       |
      | Xml     | WARNING | property [ checkTableConsistency ] 'false' data type should be int, skip       |
      | Xml     | WARNING | property [ enableSlowLog ] 'false' data type should be int, skip               |
      | Xml     | WARNING | property [ frontSocketNoDelay ] 'true' data type should be int, skip           |
      | Xml     | WARNING | property [ recordTxn ] 'false' data type should be int, skip                   |
      | Xml     | WARNING | Property [ sequnceHandlerType ] '20' in server.xml is illegal, use 2 replaced  |
      | Xml     | WARNING | Property [ txIsolation ] '30' in server.xml is illegal, use 3 replaced         |
      | Xml     | WARNING | property [ useCompression ] 'true' data type should be int, skip               |
      | Xml     | WARNING | property [ useCostTimeStat ] 'false' data type should be int, skip             |
      | Xml     | WARNING | property [ usePerformanceMode ] 'false' data type should be int, skip          |
      | Xml     | WARNING | property [ useSqlStat ] 'false' data type should be int, skip                  |
      | Xml     | WARNING | property [ useThreadUsageStat ] 'false' data type should be int, skip          |
      | Xml     | WARNING | property [ usingAIO ] 'false' data type should be int, skip                    |
    And check "dble.log" in "dble-1" has the warnings
      | TYPE-0  | LEVEL-1 | DETAIL-2                                                                       |
      | Xml     | WARNING | property [ backSocketNoDelay ] 'true' data type should be int, skip            |
      | Xml     | WARNING | property [ bufferUsagePercent ] '80%' data type should be int, skip            |
      | Xml     | WARNING | Property [ charset ] 'utf-8' in server.xml is illegal, use utf8mb4 replaced       |
      | Xml     | WARNING | property [ checkTableConsistency ] 'false' data type should be int, skip       |
      | Xml     | WARNING | property [ enableSlowLog ] 'false' data type should be int, skip               |
      | Xml     | WARNING | property [ frontSocketNoDelay ] 'true' data type should be int, skip           |
      | Xml     | WARNING | property [ recordTxn ] 'false' data type should be int, skip                   |
      | Xml     | WARNING | Property [ sequnceHandlerType ] '20' in server.xml is illegal, use 2 replaced  |
      | Xml     | WARNING | Property [ txIsolation ] '30' in server.xml is illegal, use 3 replaced         |
      | Xml     | WARNING | property [ useCompression ] 'true' data type should be int, skip               |
      | Xml     | WARNING | property [ useCostTimeStat ] 'false' data type should be int, skip             |
      | Xml     | WARNING | property [ usePerformanceMode ] 'false' data type should be int, skip          |
      | Xml     | WARNING | property [ useSqlStat ] 'false' data type should be int, skip                  |
      | Xml     | WARNING | property [ useThreadUsageStat ] 'false' data type should be int, skip          |
      | Xml     | WARNING | property [ usingAIO ] 'false' data type should be int, skip                    |