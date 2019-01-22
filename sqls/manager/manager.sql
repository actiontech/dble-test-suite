#select
select @@VERSION_COMMENT
select @@SESSION.TX_READ_ONLY
select @@max_allowed_packet

#set
set @a=20；
SET SESSION sql_mode = 'TRADITIONAL';
SET sql_mode = 'TRADITIONAL';

#show
show @@algorithm where schema=schema1 and table=sharding_4_t1;
show @@backend
show @@backend.old
show @@backend.statistics
show @@binlog.status
show @@cache
show @@command
show @@command.count
show @@connection
show @@connection.count
show @@connection.sql
show @@cost_time
show @@database
show @@datanode
show @@datanode where schema=schema1;
show @@datanodes where schema=schema1 and table=sharding_4_t1;
show @@datasource
show @@datasource.cluster
show @@datasource.synstatus
show @@datasource.syndetail where name=172.100.9.5
show @@directmemory=1
show @@directmemory=2
show @@heartbeat
show @@heartbeat.detail where name=hostM1
show @@processor
show @@help
show @@server
show @@session
show @@sql
show @@sql.condition
show @@sql.high
show @@sql.slow
show @@sql.resultset
show @@sql.large
show @@sql.large true
show @@sql.sum
show @@sql.sum true
show @@sql.sum.user
show @@sql.sum.user true
show @@sql.sum.table
show @@sql.sum.table true
show @@syslog limit=2
show @@sysparam
show @@threadpool
show @@thread_used
show @@time.current
show @@time.startup
show @@version
show @@white
SHOW VARIABLES WHERE Variable_name ='language' OR Variable_name = 'net_write_timeout' OR Variable_name = 'interactive_timeout' OR Variable_name = 'wait_timeout' OR Variable_name = 'character_set_client' OR Variable_name = 'character_set_connection' OR Variable_name = 'character_set' OR Variable_name = 'character_set_server' OR Variable_name = 'tx_isolation' OR Variable_name = 'transaction_isolation' OR Variable_name = 'character_set_results' OR Variable_name = 'timezone' OR Variable_name = 'time_zone' OR Variable_name = 'system_time_zone' OR Variable_name = 'lower_case_table_names' OR Variable_name = 'max_allowed_packet' OR Variable_name = 'net_buffer_length' OR Variable_name = 'sql_mode' OR Variable_name = 'query_cache_type' OR Variable_name = 'query_cache_size' OR Variable_name = 'init_connect';