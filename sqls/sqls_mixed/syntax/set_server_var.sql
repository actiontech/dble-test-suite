#!default_db:schema1
#System variables:
#auto_increment_increment: controls the interval between successive column values. (both)
#!share_conn
set @@auto_increment_increment=10
select @@auto_increment_increment
set session auto_increment_increment=11
select @@auto_increment_increment
set @@session.auto_increment_increment=12
select @@auto_increment_increment
#
#auto_increment_offset: determines the starting point for the AUTO_INCREMENT
#When the value of auto_increment_offset is greater than of auto_increment_increment,the value of auto_increment_offset is ignored 
#!share_conn
set @@auto_increment_offset=10
select @@auto_increment_offset
set session auto_increment_offset=11
select @@auto_increment_offset
set @@session.auto_increment_offset=12
select @@auto_increment_offset
set @@session.auto_increment_offset=10,@@session.auto_increment_increment=11
#
#big_tables:If set to 1,all temporary tables are stored on disk rather than in memory
#!share_conn
set @@big_tables=1
select @@big_tables
set session big_tables=0
select @@big_tables
set @@session.big_tables=1
select @@big_tables
set @@session.big_tables=off
select @@big_tables
set @@session.big_tables=on
select @@big_tables
#
#binlog_direct_non_transactional_updates: writing nontransactional statements to the transaction cache. 
#default: OFF(writing nontransactional statement to binary log)
#In mysql 5.7,this variables has no effect when the binary log format is ROW or MIXED
#!share_conn
set @@binlog_direct_non_transactional_updates=on
select @@binlog_direct_non_transactional_updates
set session binlog_direct_non_transactional_updates=off
select @@binlog_direct_non_transactional_updates
set @@session.binlog_direct_non_transactional_updates=on
select @@binlog_direct_non_transactional_updates
set session binlog_direct_non_transactional_updates=1
select @@binlog_direct_non_transactional_updates
#
#binlog_error_action:  In MYSQL5.7 and later,this variable defaults to ABORT_SERVER,which makes server halt #logging and shut down whenever it encounters such an error whit the binary log.
#set @@binlog_error_action='abort_server'
#
#binlog_format: This variable sets the binary logging format,and can be any one of STATEMENT,ROW,or MIXED.
#!share_conn
set @@binlog_format='row'
select @@binlog_format
set session binlog_format='statement'
select @@binlog_format
set @@session.binlog_format='mixed'
select @@binlog_format
#
#binlog_row_image: For MYSQL row-based replication,this variable determines how row images are written to the binary log
#!share_conn
set @@binlog_row_image='full'
select @@binlog_row_image
set session binlog_row_image='minimal'
select @@binlog_row_image
set @@session.binlog_row_image='noblob'
select @@binlog_row_image
#
#binlog_rows_query_log_events: This variable affects row-based logging only.
#Enabled: to write informational log events such as row query log events into its binary log.
#!share_conn
set @@binlog_rows_query_log_events=1
select @@binlog_rows_query_log_events
set session binlog_rows_query_log_events=0
select @@binlog_rows_query_log_events
set @@binlog_rows_query_log_events=1
select @@binlog_rows_query_log_events
#
#block_encryption_mode: This variable controls the block encrytion mode for block-based algorithms such as AES.
#!share_conn
set @@block_encryption_mode='aes-256-cbc'
select @@block_encryption_mode
set session block_encryption_mode='aes-128-ecb'
select @@block_encryption_mode
set @@session.block_encryption_mode='aes-256-cbc'
select @@block_encryption_mode
#
#completion_type: The transaction completion type.
#NO_CHAIN(0): commit and rollback are unaffected. This is the default value.
#CHAIN(1): After commit and rollback, a new transaction starts immediately with the same isolation level.
#RELEASE(2): After commit and rollback, the server disconnects after terminating the transaction.
#!share_conn
set @@completion_type=1
select @@completion_type
set @@completion_type=2
select @@completion_type
set @@completion_type='NO_CHAIN'
select @@completion_type
set @@completion_type='RELEASE'
select @@completion_type
set @@completion_type='CHAIN'
select @@completion_type
set session completion_type=0
select @@completion_type
set @@session.completion_type=2
select @@completion_type
#
#default_storage_engine: set the default storage engine for tables
#!share_conn
set @@default_storage_engine='myisam'
select @@default_storage_engine
set session default_storage_engine='innodb'
select @@default_storage_engine
set @@session.default_storage_engine='myisam'
select @@default_storage_engine
#
# default_tmp_storage_engine: set the default storage engine for temporary table.
#!share_conn
set @@default_tmp_storage_engine='myisam'
select @@default_tmp_storage_engine
set session default_tmp_storage_engine='memory'
select @@default_tmp_storage_engine
set @@session.default_tmp_storage_engine='innodb'
select @@default_tmp_storage_engine
#
#default_week_format: The default mode value to use for the WEEK() function.
#value: [0,7]
#!share_conn
set @@default_week_format=1
select @@default_week_format
select week('2008-02-20')
set @@default_week_format=2
select @@default_week_format
select week('2008-02-20')
set session default_week_format=0
select @@default_week_format
select week('2000-01-01')
#
#div_precision_increment: This variable indicates the number of digits.(/ operator)
#!share_conn
set @@div_precision_increment=12
select @@div_precision_increment
select 1/7
set @@session.div_precision_increment=6
select @@div_precision_increment
select 1/7
set session div_precision_increment=4
select @@div_precision_increment
select 1/7
#
#end_markers_in_json: Whether optimizer JSON output should add end markers.
#!share_conn
set @@end_markers_in_json=1
select @@end_markers_in_json
set @@session.end_markers_in_json=on
select @@end_markers_in_json
set session end_markers_in_json=off
select @@end_markers_in_json
#
#eq_range_index_dive_limit
#!share_conn
set @@eq_range_index_dive_limit=100
select @@eq_range_index_dive_limit
set session eq_range_index_dive_limit=150
select @@eq_range_index_dive_limit
set @@session.eq_range_index_dive_limit=200
select @@eq_range_index_dive_limit
#
#foreign_key_checks: If set to 1 (the default), foreign key constraints for InnoDB tables are checked.
#!share_conn
set @@foreign_key_checks=0
select @@foreign_key_checks
set @@session.foreign_key_checks=1
select @@foreign_key_checks
set session foreign_key_checks=on
select @@foreign_key_checks
#
#group_concat_max_len: The maximum permitted result length in bytes for the GROUP_CONCAT() function. 
#The default is 1024.
#!share_conn
set @@group_concat_max_len=2048
select @@group_concat_max_len
set @@session.group_concat_max_len=3072
select @@group_concat_max_len
set session group_concat_max_len=1024
select @@group_concat_max_len
#
#gtid_next: This variable is used to specify whether and how the next GTID is obtained
#AUTOMATIC: Use the next automatically-generated global transaction ID.
#ANONYMOUS: Transactions do not have global identifiers, and are identified by file and position only.
#UUID:NUMBER: A global transaction ID in UUID:NUMBER format.
#!share_conn
set @@gtid_next='AUTOMATIC'
select @@gtid_next
#set @@session.gtid_next='ANONYMOUS'
#select @@gtid_next
#set session gtid_next='AUTOMATIC'
#select @@gtid_next
#
#innodb_strict_mode: When innodb_strict_mode is enabled, InnoDB returns errors rather than warnings for certain conditions.
#!share_conn
set @@innodb_strict_mode=1
select @@innodb_strict_mode
set session innodb_strict_mode=off
select @@innodb_strict_mode
set @@session.innodb_strict_mode=on
select @@innodb_strict_mode
#
#innodb_support_xa: Enables InnoDB support for two-phase commit in XA transactions, causing an extra disk flush for transaction preparation. 
#set the variable to off, that is not effect
#!share_conn
set @@innodb_support_xa=off
select @@innodb_support_xa
set @@session.innodb_support_xa=on
select @@innodb_support_xa
#
#innodb_table_locks: If autocommit=0,InnoDB honors LOCK TABLES.
#!share_conn
set @@innodb_table_locks=off
select @@innodb_table_locks
set session innodb_table_locks=on
select @@innodb_table_locks
#
#interactive_timeout: The number of seconds the server waits for activity on an interactive connection before closing it.
#!share_conn
set @@interactive_timeout=10
select @@interactive_timeout
set session interactive_timeout=100
select @@interactive_timeout
set @@session.interactive_timeout=28800
select @@interactive_timeout
#
#join_buffer_size:  Increase the value of join_buffer_size to get a faster full join when adding indexes is not possible.
#!share_conn
select @@join_buffer_size
set @@join_buffer_size=1000
select @@join_buffer_size
set @@session.join_buffer_size=2000
select @@join_buffer_size
set session join_buffer_size=262144
#
#last_insert_id: The value to be returned from LAST_INSERT_ID().
#
#lc_messages: The locate to use for error messages.
#!share_conn
select @@lc_messages
set @@lc_messages='fr_FR'
select @@lc_messages
set session lc_messages='en_AU'
select @@lc_messages
set @@session.lc_messages='en_US'
select @@lc_messages
#
#lc_time_names: This variable specifies the locale that controls the language used to display day and month names and abbreviations.
#This variable affects the output from the DATE_FORMAT(), DAYNAME() and MONTHNAME() functions.
#!share_conn
select @@lc_time_names
SELECT DAYNAME('2010-01-01'), MONTHNAME('2010-01-01')
SELECT DATE_FORMAT('2010-01-01','%W %a %M %b')
SET lc_time_names = 'es_MX'
select @@lc_time_names
SELECT DAYNAME('2010-01-01'), MONTHNAME('2010-01-01')
SELECT DATE_FORMAT('2010-01-01','%W %a %M %b')
set @@session.lc_time_names='zh_CN'
select @@lc_time_names
set session lc_time_names='en_US'
select @@lc_time_names
#
#long_query_time: If a query takes longer than this many seconds,the server increments the Slow_queries status variable.
#!share_conn
set @@long_query_time=5
select @@long_query_time
set @@session.long_query_time=3
select @@long_query_time
set session long_query_time=10
select @@long_query_time
#
#max_error_count: The maximum number of error, warning, and note messages to be stored for display by the SHOW ERRORS and SHOW WARNINGS statements.
#!share_conn
set @@max_error_count=5
select @@max_error_count
set @@session.max_error_count=3
select @@max_error_count
set session max_error_count=64
select @@max_error_count
#
#max_execution_time: The execution timeout for SELECT statements,in milliseconds.
#!share_conn
set @@max_execution_time=5
select @@max_execution_time
set @@session.max_execution_time=3
select @@max_execution_time
set session max_execution_time=0
select @@max_execution_time
#
#max_join_size:
#!share_conn
set @@max_join_size=5
select @@max_join_size
set @@session.max_join_size=3
select @@max_join_size
set session max_join_size=18446744073709551615
select @@max_join_size
#
#max_length_for_sort_data: The cutoff on the size of index values that determines which filesort algorithm to use. 
#!share_conn
set @@max_length_for_sort_data=5
select @@max_length_for_sort_data
set @@session.max_length_for_sort_data=4
select @@max_length_for_sort_data
set session max_length_for_sort_data=1024
select @@max_length_for_sort_data
#
#max_seeks_for_key: Limit the assumed maximum number of seeks when looking up rows based on a key. 
#!share_conn
set @@max_seeks_for_key=5
select @@max_seeks_for_key
set @@session.max_seeks_for_key=4
select @@max_seeks_for_key
set session max_seeks_for_key=4294967295
select @@max_seeks_for_key
#max_sort_length: The number of bytes to use when sorting data values.
#!share_conn
set @@max_sort_length=5
select @@max_sort_length
set @@session.max_sort_length=4
select @@max_sort_length
set session max_sort_length=1024
select @@max_sort_length
#
#max_sp_recursion_depth: The number of times that any given stored procedure may be called recursively.
#!share_conn
set @@max_sp_recursion_depth=5
select @@max_sp_recursion_depth
set @@session.max_sp_recursion_depth=4
select @@max_sp_recursion_depth
set session max_sp_recursion_depth=0
select @@max_sp_recursion_depth
#
#min_examined_row_limit: Queries that examine fewer than this number of rows are not logged to the slow query log.
#!share_conn
set @@min_examined_row_limit=5
select @@min_examined_row_limit
set @@session.min_examined_row_limit=4
select @@min_examined_row_limit
set session min_examined_row_limit=0
select @@min_examined_row_limit
#
#net_read_timeout: The number of seconds to wait for more data from a connection before aborting the read.
#!share_conn
set @@net_read_timeout=5
select @@net_read_timeout
set @@session.net_read_timeout=4
select @@net_read_timeout
set session net_read_timeout=30
select @@net_read_timeout
#
#net_retry_count: If a read or write on a communication port is interrupted, retry this many times before giving up.
#!share_conn
set @@net_retry_count=5
select @@net_retry_count
set @@session.net_retry_count=4
select @@net_retry_count
set session net_retry_count=10
select @@net_retry_count
#
#net_write_timeout: The number of seconds to wait for a block to be written to a connection before aborting the write.
#!share_conn
set @@net_read_timeout=5
select @@net_write_timeout
set @@session.net_write_timeout=4
select @@net_read_timeout
set session net_write_timeout=60
select @@net_write_timeout
#
#new:
#!share_conn
set @@new=OFF
select @@new
set @@session.new=on
select @@new
set session new=OFF
select @@new
#
#old_alter_table: When this variable is enabled, the server does not use the optimized method of processing an ALTER TABLE operation.
#!share_conn
set @@old_alter_table=OFF
select @@old_alter_table
set @@session.old_alter_table=on
select @@old_alter_table
set session old_alter_table=OFF
select @@old_alter_table
#
#old_passwords: This variable controls the password hashing method used by the PASSWORD() function.
#!share_conn
set @@old_passwords=1
select @@old_passwords
set @@session.old_passwords=2
select @@old_passwords
set session old_passwords=0
select @@old_passwords
#
#optimizer_prune_level: Controls the heuristics applied during query optimization to prune less-promising partial plans from the optimizer search space. 
#!share_conn
set @@optimizer_prune_level=1
select @@optimizer_prune_level
set @@session.optimizer_prune_level=0
select @@optimizer_prune_level
set session optimizer_prune_level=1
select @@optimizer_prune_level
#
#optimizer_search_depth: The maximum depth of search performed by the query optimizer.
#!share_conn
set @@optimizer_search_depth=30
select @@optimizer_search_depth
set @@session.optimizer_search_depth=40
select @@optimizer_search_depth
set session optimizer_search_depth=64
select @@optimizer_search_depth
#
#optimizer_switch: The optimizer_switch system variable enables control over optimizer behavior.
#!share_conn
set @@optimizer_switch='index_merge=off'
select @@optimizer_switch
set @@session.optimizer_switch='index_merge_union=off'
select @@optimizer_switch
set session optimizer_switch='index_merge=on,index_merge_union=on'
select @@optimizer_switch
#
#optimizer_trace: This variable controls optimizer tracing. 
#optimizer_trace_features: This variable enables or disables selected optimizer tracing features.
#optimizer_trace_limit: The maximum number of optimizer traces to display. 
#optimizer_trace_max_mem_size: The maximum cumulative size of stored optimizer traces. 
#optimizer_trace_offset: The offset of optimizer traces to display. 
#!share_conn
set @@optimizer_trace='enabled=on'
select @@optimizer_trace
set session optimizer_trace='enabled=off'
select @@optimizer_trace
set @@optimizer_trace_features='greedy_search=off,range_optimizer=off'
select @@optimizer_trace_features
set @@session.optimizer_trace_features='greedy_search=on,range_optimizer=on'
select @@optimizer_trace_features
set @@optimizer_trace_limit=10
select @@optimizer_trace_limit
set session optimizer_trace_limit=1
select @@optimizer_trace_limit
set @@optimizer_trace_max_mem_size=1000
select @@optimizer_trace_max_mem_size
set @@session.optimizer_trace_max_mem_size=10000000
select @@optimizer_trace_max_mem_size
set @@optimizer_trace_offset=1
select @@optimizer_trace_offset
set session optimizer_trace_offset=-1
select @@optimizer_trace_offset
#
#parser_max_mem_size: The maximum amount of memory available to the parser. 
#!share_conn
set @@parser_max_mem_size=10000000
select @@parser_max_mem_size
set @@session.parser_max_mem_size=10000002
select @@parser_max_mem_size
set session parser_max_mem_size=18446744073709551615
select @@parser_max_mem_size
#
#preload_buffer_size: The size of the buffer that is allocated when preloading indexes.
#!share_conn
set @@preload_buffer_size=1024
select @@preload_buffer_size
set @@session.preload_buffer_size=2048
select @@preload_buffer_size
set session preload_buffer_size=32768
select @@preload_buffer_size
#
#profiling: If set to 0 or OFF (the default), statement profiling is disabled.
#!share_conn
set @@profiling=0
select @@profiling
set @@session.profiling=1
select @@profiling
set session profiling=off
select @@profiling
#
#profiling_history_size: The number of statements for which to maintain profiling information if profiling is enabled.
#!share_conn
set @@profiling_history_size=16
select @@profiling_history_size
set @@session.profiling_history_size=17
select @@profiling_history_size
set session profiling_history_size=15
select @@profiling_history_size
#
#pseudo_slave_mode/pseudo_thread_id: Those variables are for internal server use.
#!share_conn
set @@pseudo_slave_mode=1
select @@pseudo_slave_mode
set session pseudo_slave_mode=0
select @@pseudo_slave_mode
set @@pseudo_thread_id=1
select @@pseudo_thread_id
set @@session.pseudo_thread_id=2
select @@pseudo_thread_id
set session pseudo_thread_id=2445
select @@pseudo_thread_id
#
#query_alloc_block_size: The allocation size of memory blocks that are allocated for objects created during statement parsing and execution.
#!share_conn
set @@query_alloc_block_size=1024
select @@query_alloc_block_size
set session query_alloc_block_size=8192
select @@query_alloc_block_size
#
#query_cache_type: Set the query cache type.
#set @@query_cache_type=1
#select @@query_cache_type
#set @@session.query_cache_type=2
#select @@query_cache_type
#set session query_cache_type=0,
#select @@query_cache_type
#
#query_prealloc_size: The size of the persistent buffer used for statement parsing and execution.
#!share_conn
set @@query_prealloc_size=9216
select @@query_prealloc_size
set @@session.query_prealloc_size=8192
select @@query_prealloc_size
#
#rand_seed1/rand_seed2: 
#
#range_alloc_block_size: The size of blocks that are allocated when doing range optimization.
#range_optimizer_max_mem_size: The limit on memory consumption for the range optimizer. 
#rbr_exec_mode:
#!share_conn
set @@range_alloc_block_size=8192
select @@range_alloc_block_size
set session range_alloc_block_size=4096
select @@range_alloc_block_size
set @@range_optimizer_max_mem_size=1024
select @@range_optimizer_max_mem_size
set @@session.range_optimizer_max_mem_size=8388608
select @@range_optimizer_max_mem_size
set @@rbr_exec_mode='idempotent'
select @@rbr_exec_mode
set session rbr_exec_mode='strict'
select @@rbr_exec_mode
#
#session_track_gtids: Controls a tracker for capuring GTIDs and returning them in the OK packet.
#!share_conn
set session session_track_gtids='own_gtid'
select @@session_track_gtids
set @@session_track_gtids='all_gtids'
select @@session_track_gtids
set session session_track_gtids='off'
select @@session_track_gtids
#
#session_track_schema: Controls whether the server tracks changes to the default schema name within the current session and makes this information available to the client when changes occur.
#!share_conn
set session session_track_schema=off
select @@session.session_track_schema
set @@session.session_track_schema=on
select @@session_track_schema
#
#session_track_state_change: Controls whether the server tracks changes to the state of the current session and notifies the client when state changes occur.
#!share_conn
set session session_track_state_change=off
select @@session_track_state_change
set @@session.session_track_state_change=on
select @@session_track_state_change 
set @@session_track_schema=off
select @@session_track_state_change
#
#session_track_system_variables: Controls whether the server tracks changes to the session system variables and makes this information available to the client when changes occur. 
#!share_conn
set @@session_track_system_variables='time_zone'
select @@session_track_system_variables
set session session_track_system_variables='autocommit'
select @@session_track_system_variables
set @@session.session_track_system_variables='time_zone, autocommit, character_set_client, character_set_results, character_set_connection'
select @@session_track_system_variables
#
#show_old_temporals:
#!share_conn
set session show_old_temporals=off
select @@show_old_temporals
set @@session.show_old_temporals=on
select @@show_old_temporals 
set @@show_old_temporals=off
select @@show_old_temporals
#
#sort_buffer_size: 
#!share_conn
set @@sort_buffer_size=32768
select @@sort_buffer_size
set @@session.sort_buffer_size=262144
select @@sort_buffer_size
#
#sql_big_selects: If set to 0,MySQL aborts SELECT statements that are likely to take a very long time to execute.
#!share_conn
set @@sql_big_selects=0
select @@sql_big_selects
set session sql_big_selects=1
select @@sql_big_selects
#
#sql_buffer_result: If set to 1, sql_buffer_result forces results from SELECT statements to be put into temporary tables. 
#!share_conn
set @@sql_buffer_result=1
select @@sql_buffer_result
set @@session.sql_buffer_result=0
select @@sql_buffer_result
#
#sql_log_off: This variable controls whether logging to the general query log is done.
#!share_conn
set @@sql_log_off=1
select @@sql_log_off
set @@session.sql_log_off=0
select @@sql_log_off
#
#sql_notes: If set to 1 (the default), warnings of Note level increment warning_count and the server records them. 
#!share_conn
set @@sql_notes=1
select @@sql_notes
set session sql_notes=0
select @@sql_notes
#
#sql_quote_show_create: If set to 1 (the default), the server quotes identifiers for SHOW CREATE TABLE and SHOW CREATE DATABASE statements.
#!share_conn
set @@sql_quote_show_create=0
select @@sql_quote_show_create
set session sql_quote_show_create=1
select @@sql_quote_show_create
#
#sql_safe_update: If set to 1, MySQL aborts UPDATE or DELETE statements that do not use a key in the WHERE clause or a LIMIT clause.
#!share_conn
set @@sql_safe_updates=1
select @@sql_safe_updates
set session sql_safe_updates=0
select @@sql_safe_updates
#
#sql_select_limit: The maximum number of rows to return from SELECT statements.
#!share_conn
set @@sql_select_limit=4294967295
select @@sql_select_limit
set session sql_select_limit=18446744073709551615
select @@sql_select_limit
#
#sql_warnings: This variable controls whether single-row INSERT statements produce an information string if warnings occur.
#!share_conn
set @@sql_warnings=1
select @@sql_warnings
set session sql_warnings=0
select @@sql_warnings
#
#time_zone: The current time zone. This variable is used to initialize the time zone for each client that connects. 
#!share_conn
set @@time_zone='+00:00'
select @@time_zone
set session time_zone='system'
select @@time_zone
#
#timestamp: Set the time for this client.
#!share_conn
set @@timestamp=123076799
select @@timestamp
set session timestamp=1508403167.668069
select @@timestamp
#
#transaction_alloc_block_size:  The amount in bytes by which to increase a per-transaction memory pool which needs memory.
#!share_conn
set @@transaction_alloc_block_size=1024
select @@transaction_alloc_block_size
set session transaction_alloc_block_size=8192
select @@transaction_alloc_block_size
#
#transaction_prealloc_size: There is a per-transaction memory pool from which various transaction-related allocations take memory.
#!share_conn
set @@transaction_prealloc_size=1024
select @@transaction_prealloc_size
set session transaction_prealloc_size=4096
select @@transaction_prealloc_size
#
#unique_checks: If set to 1 (the default), uniqueness checks for secondary indexes in InnoDB tables are performed. 
#If set to 0, storage engines are permitted to assume that duplicate keys are not present in input data. 
#!share_conn
set @@unique_checks=0
select @@unique_checks
set @@session.unique_checks=on
select @@unique_checks
#
#updatable_views_with_limit: 
#!share_conn
set @@updatable_views_with_limit=0
select @@updatable_views_with_limit
set session updatable_views_with_limit=`yes`
select @@updatable_views_with_limit
#
#wait_timeout: The number of seconds the server waits for activity on a noninteractive connection before closing it.
#!share_conn
set @@wait_timeout=10
select @@wait_timeout
set session wait_timeout=28800
select @@wait_timeout