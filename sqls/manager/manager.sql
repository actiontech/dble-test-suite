#select
select @@VERSION_COMMENT
select @@SESSION.TX_READ_ONLY
select @@max_allowed_packet

#set
set @a=20；
SET SESSION sql_mode = 'TRADITIONAL';
SET sql_mode = 'TRADITIONAL';

#show
show @@algorithm where schema=mytest and table=aly_test;
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
show @@datanode where schema=mytest;
show @@datanodes where schema=mytest and table=aly_test;
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