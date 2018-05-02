drop table if exists a_test
CREATE TABLE a_test(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
insert into a_test values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
#port:9066
show @@session
show @@connection.sql
show @@connection
show @@backend
show @@command
show @@heartbeat
show @@database
show @@datanode
show @@datasource
show @@datasource.synstatus
show @@processor
show @@help
show @@server
show @@sysparam
show @@threadpool
show @@time.current
show @@time.startup
show @@version
show @@datanodes where schema=mytest and table=a_test;
show @@algorithm where schema=mytest and table=a_test;
