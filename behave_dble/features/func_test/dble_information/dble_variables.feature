# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_variables test


  Scenario:  dble_variables table #1
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     /DbackendProcessorExecutor/d
     /DcomplexExecutor/d
     /DwriteToBackendExecutor/d
     /DbackendProcessors/d
     $a  -DbackendProcessorExecutor=8
     $a  -DcomplexExecutor=8
     $a  -DwriteToBackendExecutor=8
     $a  -DbackendProcessors=8
     """
    Then restart dble in "dble-1" success
  #case desc dble_variables
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_1"
      | conn   | toClose | sql                 | db               |
      | conn_0 | False   | desc dble_variables | dble_information |
    Then check resultset "dble_variables_1" has lines with following column values
      | Field-0        | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |
      | variable_name  | varchar(32)  | NO     | PRI   | None      |         |
      | variable_value | varchar(255) | NO     |       | None      |         |
      | comment        | varchar(255) | NO     |       | None      |         |
      | read_only      | varchar(7)   | NO     |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                             | expect            | db               |
      | conn_0 | False   | desc dble_variables             | length{(4)}       | dble_information |
      | conn_0 | False   | select * from dble_variables    | length{(106)}     | dble_information |
  #case select * from dble_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_2"
      | conn   | toClose | sql                          | db               |
      | conn_0 | False   | select * from dble_variables | dble_information |
    Then check resultset "dble_variables_2" has lines with following column values
      | variable_name-0             | variable_value-1                | comment-2                                                                                                                                                   | read_only-3 |
      | version_comment             | dble Server (ActionTech)        | version_comment                                                                                                                                             | true        |
      | isOnline                    | true                            | When it is set to offline, COM_PING/COM_HEARTBEAT/SELECT USER()/SELECT CURRENT_USER() will return error                                                     | false       |
      | heap_memory_max             | 1029177344B                     | The maximum amount of memory that the virtual machine will attempt to use, measured in bytes                                                                | true        |
      | direct_memory_max           | 1073741824B                     | Max direct memory                                                                                                                                           | true        |
      | enableFlowControl           | false                           | Whether use flow control feature                                                                                                                            | false       |
      | flowControlStartThreshold   | 4096                            | The start threshold of write queue to start the flow control                                                                                                | false       |
      | flowControlStopThreshold    | 256                             | The recover threshold of write queue to stop the flow control                                                                                               | false       |
      | enableSlowLog               | false                           | Enable Slow Query Log                                                                                                                                       | false       |
      | sqlSlowTime                 | 100ms                           | The threshold of Slow Query, the default is 100ms                                                                                                           | false       |
      | flushSlowLogPeriod          | 1s                              | The period for flushing log to disk, the default is 1 second                                                                                                | false       |
      | flushSlowLogSize            | 1000                            | The max size for flushing log to disk, the default is 1000                                                                                                  | false       |
      | enableAlert                 | true                            | Enable or disable alert                                                                                                                                     | false       |
      | capClientFoundRows          | false                           | Whether to turn on EOF_Packet to return found rows, the default value is false                                                                              | false       |
      | enableGeneralLog            | false                           | Enable general log                                                                                                                                          | false       |
      | generalLogFile              | /opt/dble/general/general.log   | The path of general log, the default value is ./general/general.log                                                                                         | false       |
      | clusterEnable               | false                           | Whether enable the cluster mode                                                                                                                             | true        |
      | showBinlogStatusTimeout     | 60000ms                         | The time out from show @@binlog.status.The default value is 60000ms                                                                                         | true        |
      | sequenceHandlerType         | Local TimeStamp(like Snowflake) | Global Sequence Type. The default is Local TimeStamp(like Snowflake)                                                                                        | true        |
      | sequenceStartTime           | None                            | Valid for sequenceHandlerType=2 or 3, default is 2010-11-04 09:42:54                                                                                        | true        |
      | sequenceInstanceByZk        | true                            | Valid for sequenceHandlerType=3 and clusterMode is zk, default true                                                                                         | true        |
      | serverId                    | server_1                        | ServerID of machine which install dble, the default value is the machine IP                                                                                 | true        |
      | instanceName                | 1                               | InstanceName used to create xa transaction and unique key for cluster                                                                                       | true        |
      | instanceId                  | 1                               | InstanceId used to when sequenceHandlerType=2 or (sequenceHandlerType=3 and sequenceInstanceByZk)                                                           | true        |
      | useOuterHa                  | true                            | Whether use outer ha component. The default value is true and it will always true when clusterEnable=true.If no component in fact, nothing will happen.     | true        |
      | fakeMySQLVersion            | 5.7.21                          | MySQL Version showed in Client                                                                                                                              | true        |
      | bindIp                      | 0.0.0.0                         | The host where the server is running. The default is 0.0.0.0                                                                                                | true        |
      | serverPort                  | 8066                            | User connection port. The default number is 8066                                                                                                            | true        |
      | managerPort                 | 9066                            | Manager connection port. The default number is 9066                                                                                                         | true        |
      | processors                  | 1                               | The size of frontend NIOProcessor, the default value is the number of processors available to the Java virtual machine                                      | true        |
      | backendProcessors           | 8                               | The size of backend NIOProcessor, the default value is the number of processors available to the Java virtual machine                                       | true        |
      | processorExecutor           | 1                               | The size of fixed thread pool named of frontend businessExecutor, the default value is the number of processors available to the Java virtual machine * 2   | true        |
      | backendProcessorExecutor    | 8                               | The size of fixed thread pool named of backend businessExecutor,the default value is the number of processors available to the Java virtual machine * 2     | true        |
      | complexExecutor             | 8                               | The size of fixed thread pool named of writeToBackendExecutor,the default is the number of processors available to the Java virtual machine * 2             | true        |
      | writeToBackendExecutor      | 8                               | The executor for complex query.The default value is min(8, default value of processorExecutor)                                                              | true        |
      | serverBacklog               | 2048                            | The NIO/AIO reactor backlog,the max of create connection request at one time. The default value is 2048                                                     | true        |
      | maxCon                      | 0                               | The number of max connections the server allowed, 0 means number of max connections attributes is not limited                                               | true        |
      | useCompression              | 0                               | Whether the Compression is enable, the default number is 0                                                                                                  | true        |
      | usingAIO                    | 0                               | Whether the AIO is enable, the default number is 0(use NIO instead)                                                                                         | true        |
      | useThreadUsageStat          | 0                               | Whether the thread usage statistics function is enabled. The default value is 0                                                                             | true        |
      | usePerformanceMode          | 0                               | Whether use the performance mode is enabled. The default value is 0                                                                                         | true        |
      | useCostTimeStat             | 0                               | Whether the cost time of query can be track by Btrace. The default value is 0                                                                               | true        |
      | maxCostStatSize             | 100                             | The max cost total percentage. The default value is 100                                                                                                     | true        |
      | costSamplePercent           | 1%                              | The percentage of cost sample. The default value is 1%                                                                                                      | true        |
      | charset                     | utf8mb4                         | The initially charset of connection. The default is utf8mb4                                                                                                 | true        |
      | maxPacketSize               | 4194304B                        | The maximum size of one packet. The default is 4MB or (the Minimum value of all dbInstances - 1024).                                                        | true        |
      | txIsolation                 | REPEATABLE_READ                 | The initially isolation level of the front end connection. The default is REPEATABLE_READ                                                                   | true        |
      | autocommit                  | 1                               | The initially autocommit value.The default value is 1                                                                                                       | true        |
      | idleTimeout                 | 600000ms                        | The max allowed idle time of front connection. The connection will be closed if it is timed out after last read/write/heartbeat. The default value is 10min | true        |
      | checkTableConsistency       | 0                               | Whether the consistency tableStructure check is enabled. The default value is 0                                                                             | true        |
      | checkTableConsistencyPeriod | 1800000ms                       | The period of consistency tableStructure check. The default value is 1800000ms(means 30minutes=30*60*1000)                                                  | true        |
      | processorCheckPeriod        | 1000ms                          | The period between the jobs for cleaning the closed or overtime connections. The default is 1000ms                                                          | true        |
      | sqlExecuteTimeout           | 300s                            | The max query executing time.If time out,the connection will be closed. The default is 300 seconds                                                          | true        |
      | recordTxn                   | 0                               | Whether the transaction be recorded as a file, the default value is 0                                                                                       | true        |
      | transactionLogBaseDir       | ./txlogs/                       | The directory of the transaction record file, the default value is ./txlogs/                                                                                | true        |
      | transactionLogBaseName      | server-tx                       | The name of the transaction record file. The default value is server-tx                                                                                     | true        |
      | transactionRotateSize       | 16M                             | The max size of the transaction record file. The default value is 16M                                                                                       | true        |
      | xaRecoveryLogBaseDir        | ./xalogs/                       | The directory of the xa transaction record file, the default value is ./xalogs/                                                                             | true        |
      | xaRecoveryLogBaseName       | xalog                           | The name of the xa transaction record file. The default value is xalog                                                                                      | true        |
      | xaSessionCheckPeriod        | 1000ms                          | The xa transaction status check period. The default value is 1000ms                                                                                         | true        |
      | xaLogCleanPeriod            | 1000ms                          | The xa log clear period. The default value is 1000ms                                                                                                        | true        |
      | xaRetryCount                | 0                               | Indicates the number of background retries if the xa failed to commit/rollback. The default value is 0, retry infinitely                                    | true        |
      | useJoinStrategy             | false                           | Whether nest loop join is enabled. The default value is false                                                                                               | true        |
      | nestLoopConnSize            | 4                               | The nest loop temporary tables block number. The default value is 4                                                                                         | true        |
      | nestLoopRowsSize            | 2000                            | The nest loop temporary tables rows for every block. The default value is 2000                                                                              | true        |
      | otherMemSize                | 4M                              | The additional size of memory can be used in a complex query. The default size is 4M                                                                        | true        |
      | orderMemSize                | 4M                              | The additional size of memory can be used in a complex query order. The default size is 4M                                                                  | true        |
      | joinMemSize                 | 4M                              | The additional size of memory can be used in a complex query join. The default size is 4M                                                                   | true        |
      | bufferPoolChunkSize         | 4096B                           | The chunk size of memory bufferPool. The min direct memory used for allocating                                                                              | true        |
      | bufferPoolPageSize          | 2097152B                        | The page size of memory bufferPool. The max direct memory used for allocating                                                                               | true        |
      | bufferPoolPageNumber        | 409                             | The page number of memory bufferPool. The All bufferPool size is PageNumber * PageSize                                                                      | true        |
      | mappedFileSize              | 67108864B                       | The Memory linked file size,when complex query resultSet is too large the Memory will be turned to file temporary                                           | true        |
      | useSqlStat                  | 1                               | Whether the SQL statistics function is enable or not. The default value is 1                                                                                | true        |
      | sqlRecordCount              | 10                              | The slow SQL statistics limit,if the slow SQL record is large than the size, the record will be clear. The default value is 10                              | true        |
      | maxResultSet                | 524288B                         | The large resultSet SQL standard. The default value is 524288B(means 512*1024)                                                                              | true        |
      | bufferUsagePercent          | 80%                             | Large result set cleanup trigger percentage. The default value is 80                                                                                        | true        |
      | clearBigSQLResultSetMapMs   | 600000ms                        | The period for clear the large resultSet SQL statistics. The default value is 6000000ms                                                                     | true        |
      | frontSocketSoRcvbuf         | 1048576B                        | The buffer size of frontend receive socket. The default value is 1048576B(means 1024*1024)                                                                  | true        |
      | frontSocketSoSndbuf         | 4194304B                        | The buffer size of frontend send socket. The default value is 4194304B(means 1024*1024*4)                                                                   | true        |
      | frontSocketNoDelay          | 1                               | The frontend nagle is disabled. The default value is 1                                                                                                      | true        |
      | backSocketSoRcvbuf          | 4194304B                        | The buffer size of backend receive socket. The default value is 4194304B(means 1024*1024*4)                                                                 | true        |
      | backSocketSoSndbuf          | 1048576B                        | The buffer size of backend send socket. The default value is 1048576B(means 1024*1024)                                                                      | true        |
      | backSocketNoDelay           | 1                               | The backend nagle is disabled. The default value is 1                                                                                                       | true        |
      | viewPersistenceConfBaseDir  | ./viewConf/                     | The directory of the view record file, the default value is ./viewConf/                                                                                     | true        |
      | viewPersistenceConfBaseName | viewJson                        | The name of the view record file. The default value is viewJson                                                                                             | true        |
      | slowLogBaseDir              | ./slowlogs/                     | The directory of slow query log, the default value is ./slowlogs/                                                                                           | true        |
      | slowLogBaseName             | slow-query                      | The name of the slow query log. The default value is slow-query                                                                                             | true        |
      | maxCharsPerColumn           | 65535                           | The maximum number of characters allowed for per column when load data. The default value is 65535                                                          | true        |
      | maxRowSizeToFile            | 100000                          | The maximum row size,if over this value,row data will be saved to file when load data.The default value is 100000                                           | false       |
      | traceEndPoint               | null                            | The trace Jaeger server endPoint                                                                                                                            | true        |
      | generalLogFileSize          | 16M                             | The max size of the general log file. The default value is 16M                                                                                              | true        |
      | generalLogQueueSize         | 4096                            | Sets the queue size for consuming general log, value must not be less than 1 and must be a power of 2, the default value is 4096                            | true        |
      | enableCursor                | false                           | Whether the server-side cursor  is enable or not. The default value is false                                                                                | true        |
      | maxHeapTableSize            | 4096B                           | Used for temp table persistence of cursor, temp table which size larger than that will save to disk.                                                        | true        |
      | heapTableBufferChunkSize    | 4096B                           | Used for temp table persistence of cursor, setting for read-buffer size.                                                                                    | true        |
      | statisticQueueSize          | 4096                            | Sets the queue size for statistic, value must not be less than 1 and must be a power of 2,the default value is 4096                                         | true        |
      | joinQueueSize               | 1024                            | Size of join queue,Avoid using too much memory                                                                                                              | true        |
      | mergeQueueSize              | 1024                            | Size of merge queue,Avoid using too much memory                                                                                                             | true        |
      | orderByQueueSize            | 1024                            | Size of order by queue, avoid using too much memory                                                                                                         | true        |
      | enableStatistic                         | false               | Enable statistic sql, the default is false                                                                                                                  | false       |
      | associateTablesByEntryByUserTableSize   | 1024                | AssociateTablesByEntryByUser table size, the default is 1024                                                                                                | false       |
      | frontendByBackendByEntryByUserTableSize | 1024                | FrontendByBackendByEntryByUser table size, the default is 1024                                                                                              | false       |
      | tableByUserByEntryTableSize             | 1024                | TableByUserByEntry table size, the default is 1024                                                                                                          | false       |
      | enableBatchLoadData                     | false               | Enable Batch Load Data. The default value is false                                                                                                          | false       |
      | sqlLogTableSize                         | 1024                | SqlLog table size, the default is 1024                                                                                                                      | false       |
      | samplingRate                            | 0                   | Sampling rate, the default is 0, it is a percentage                                                                                                         | false       |
      | inSubQueryTransformToJoin               | false               | The inSubQuery is transformed into the join ,the default value is false                                                                                     | true        |
  #case supported select limit /order by/ where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                               | expect       | db               |
      | conn_0 | False   | select * from dble_variables limit 10                             | length{(10)} | dble_information |
      | conn_0 | False   | select * from dble_variables order by variable_name desc limit 10 | length{(10)} | dble_information |
      | conn_0 | False   | select * from dble_variables where read_only ='false'             | length{(20)} | dble_information |
      | conn_0 | False   | select * from dble_variables where read_only like 'fals%'         | length{(20)} | dble_information |
      | conn_0 | False   | select read_only from dble_variables                              | length{(106)}| dble_information |
  #case supported select order by concat()
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_3"
      | conn   | toClose | sql                                                                             | db               |
      | conn_0 | False   | select * from dble_variables order by concat(comment,variable_name) desc limit 5| dble_information |
    Then check resultset "dble_variables_3" has lines with following column values
      | variable_name-0    | variable_value-1 | read_only-3 |
      | usePerformanceMode | 0                | true        |
      | useOuterHa         | true             | true        |
      | enableFlowControl  | false            | false       |
      | capClientFoundRows | false            | false       |
      | recordTxn          | 0                | true        |
  #case supported select where like
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_4"
      | conn   | toClose | sql                                                                                               | db               |
      | conn_0 | False   | select * from dble_variables where read_only like  '%fals%'  order by variable_name desc limit 10 | dble_information |
    Then check resultset "dble_variables_4" has lines with following column values
      | variable_name-0                         | variable_value-1               | read_only-3 |
      | tableByUserByEntryTableSize             | 1024                           | false       |
      | sqlSlowTime                             | 100ms                          | false       |
      | sqlLogTableSize                         | 1024                           | false       |
      | samplingRate                            | 0                              | false       |
      | maxRowSizeToFile                        | 100000                         | false       |
      | isOnline                                | true                           | false       |
      | generalLogFile                          | /opt/dble/general/general.log  | false       |
      | frontendByBackendByEntryByUserTableSize | 1024                           | false       |
      | flushSlowLogSize                        | 1000                           | false       |
      | flushSlowLogPeriod                      | 1s                             | false       |
  #case supported select field from dble_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_5"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select read_only,variable_name from dble_variables | dble_information |
    Then check resultset "dble_variables_5" has lines with following column values
      | read_only-0 | variable_name-1           |
      | true        | version_comment           |
      | false       | isOnline                  |
      | true        | heap_memory_max           |
      | true        | direct_memory_max         |
  #case supported select count(*)
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_6"
      | conn   | toClose | sql                                                              | db               |
      | conn_0 | False   | select read_only,count(*) from dble_variables group by read_only | dble_information |
    Then check resultset "dble_variables_6" has lines with following column values
      | read_only-0 | count-1 |
      | false       | 20      |
      | true        | 86      |

  #case supported select field from dble_variables where XXX  DBLE0REQ-485
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_7"
      | conn   | toClose | sql                                                                                                   | db               |
      | conn_0 | False   | select read_only from dble_variables where comment like  'the%'  order by variable_name desc limit 10 | dble_information |
    Then check resultset "dble_variables_7" has lines with following column values
      | read_only-0 |
      | true        |
      | true        |
      | true        |
      | true        |
      | true        |
      | true        |
      | true        |
      | true        |
      | true        |
      | true        |

  #case supported select * from dble_variables where [sub-query]
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                              | expect               | db               |
      | conn_0 | False   | select max(variable_value) from dble_variables                                                   | has{('./slowlogs/')} | dble_information |
      | conn_0 | False   | select min(variable_value) from dble_variables                                                   | has{('xalog')}       | dble_information |
      | conn_0 | False   | select * from dble_variables where variable_name < any (select variable_name from dble_status )  | length{(89)}         | dble_information |
      | conn_0 | False   | select * from dble_variables where variable_name > any (select variable_name from dble_status )  | length{(87)}         | dble_information |
      | conn_0 | False   | select * from dble_variables where variable_name > all (select variable_name from dble_status )  | length{(17)}         | dble_information |
  #case unsupported update/delete
      | conn_0 | False   | delete from dble_variables where variable_name='sqlSlowTime'                 | Access denied for table 'dble_variables' | dble_information |
      | conn_0 | False   | update dble_variables set comment='sqlSlowTime1' where variable_value='true' | Access denied for table 'dble_variables' | dble_information |
  #case select join
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_9"
      | conn   | toClose | sql                                                                                                                                             | db               |
      | conn_0 | True    | select a.variable_name from dble_variables a inner join dble_status b on a.variable_value=b.variable_value where a.variable_value='1029177344B' | dble_information |
    Then check resultset "dble_variables_9" has lines with following column values
      | variable_name-0    |
      | heap_memory_max    |
      | heap_memory_max    |

  #case change bootstrap/cluster.cnf then restart dble-1
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
     $a -DxaLogCleanPeriod=2000
     $a -DuseJoinStrategy=true
     $a -DfakeMySQLVersion=5.7.11
    """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
     $a showBinlogStatusTimeout=65000
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_variables_10"
      | conn   | toClose | sql                                                                                                                                                                                   | db               |
      | conn_1 | True    | select * from dble_variables where variable_name='xaLogCleanPeriod' or variable_name='useJoinStrategy' or variable_name='fakeMySQLVersion' or variable_name='showBinlogStatusTimeout' | dble_information |
    Then check resultset "dble_variables_10" has lines with following column values
      | variable_name-0         | variable_value-1 | read_only-3 |
      | xaLogCleanPeriod        | 2000ms           | true        |
      | useJoinStrategy         | true             | true        |
      | fakeMySQLVersion        | 5.7.11           | true        |
      | showBinlogStatusTimeout | 65000ms          | true        |
    Then check resultset "dble_variables_10" has not lines with following column values
      | variable_name-0         | variable_value-1 | read_only-3 |
      | xaLogCleanPeriod        | 1000ms           | true        |
      | useJoinStrategy         | false            | true        |
      | fakeMySQLVersion        | None             | true        |
      | showBinlogStatusTimeout | 60000ms          | true        |