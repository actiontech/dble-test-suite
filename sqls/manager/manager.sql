#select
select @@VERSION_COMMENT
select @@SESSION.TX_READ_ONLY
select @@max_allowed_packet

#set
set @a=20；
SET SESSION sql_mode = 'TRADITIONAL';
SET sql_mode = 'TRADITIONAL';

#show
show @@session
#show @@cache
show @@connection
show @@connection.sql
show @@backend
show @@command
show @@heartbeat
show @@database
show @@datanode
show @@datanode where schema=mytest;
show @@datanodes where schema=mytest;
show @@datanodes where schema=mytest and table=a_test;
show @@datasource
show @@datasource.synstatus
show @@datasource.syndetail where name="172.100.9.5"
show @@datasource.cluster
show @@processor
show @@help
show @@server
show @@sysparam
show @@sql
show @@sql.high
show @@threadpool
show @@time.current
show @@time.startup
show @@version
show @@algorithm where schema=mytest and table=a_test;
