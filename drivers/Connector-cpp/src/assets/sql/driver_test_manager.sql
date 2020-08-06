#manager command
check @@metadata
check full @@metadata
check full @@metadata where schema = 'schema1'
#check full @@metadata where schema = 'schema1' and table =
#select
select @@VERSION_COMMENT
select @@SESSION.TX_READ_ONLY
select @@max_allowed_packet
#set
set @a=20
SET SESSION sql_mode = 'TRADITIONAL'
SET sql_mode = 'TRADITIONAL'
#show
show @@algorithm where schema=schema1 and table=aly_test
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
show @@shardingNode
show @@shardingNode where schema=schema1;
show @@shardingNodes where schema=schema1 and table=aly_test;
show @@dbInstance
show @@dbInstance.cluster
show @@dbInstance.synstatus
show @@dbInstance.syndetail where name=172.100.9.1
show @@directmemory
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
show @@ddl
show @@processlist
SHOW VARIABLES WHERE Variable_name ='language' OR Variable_name = 'net_write_timeout' OR Variable_name = 'interactive_timeout' OR Variable_name = 'wait_timeout' OR Variable_name = 'character_set_client' OR Variable_name = 'character_set_connection' OR Variable_name = 'character_set' OR Variable_name = 'character_set_server' OR Variable_name = 'tx_isolation' OR Variable_name = 'transaction_isolation' OR Variable_name = 'character_set_results' OR Variable_name = 'timezone' OR Variable_name = 'time_zone' OR Variable_name = 'system_time_zone' OR Variable_name = 'lower_case_table_names' OR Variable_name = 'max_allowed_packet' OR Variable_name = 'net_buffer_length' OR Variable_name = 'sql_mode' OR Variable_name = 'query_cache_type' OR Variable_name = 'query_cache_size' OR Variable_name = 'init_connect';
switch @@dbInstance dbGroup
switch @@dbInstance 172.100.9.5
switch @@dbInstance dbGroup$0-4
#kill @@connection
#kill @@connection id1,id2,...
stop @@heartbeat dbGroup:5000
reload @@config
reload @@config_all -s
reload @@config_all -f
reload @@config_all -r
reload @@config_all -rf
reload @@config_all -sfr
reload @@metadata
reload @@sqlslow=5
reload @@user_stat
reload @@query_cf=aly_test&id
reload @@query_cf
reload @@query_cf=aly_test&id
reload @@query_cf=NULL
rollback @@config
offline
online
file @@list
file @@show schema.xml
#file @@upload schema.xml <table name="test_global11"
log @@limit=0,5000
log @@key='select *'
log @@regex=from\saly_test$
#log @@file=dble.log @@limit='0:5000' @@key='select *' @@regex='*from aly_test'
dryrun
pause @@shardingNode = 'dn1,dn2' and timeout = 10 ,queue = 10,wait_limit = 10
RESUME
show @@pause
show @@slow_query.time
reload @@slow_query.time=200
show @@slow_query.time
show @@slow_query.flushperiod
reload @@slow_query.flushperiod=2
show @@slow_query.flushperiod
show @@slow_query.flushsize
reload @@slow_query.flushsize=1100
show @@slow_query.flushsize
create database @@shardingNode ='dn1'
create database @@shardingNode ='dn$1-4'
kill @@ddl_lock where schema=schema1 and table=test1