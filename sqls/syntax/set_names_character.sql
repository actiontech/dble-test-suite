#character_set_client: The character set for statements that arrive from the client.
#
#character_set_results: The character set used for returning query results such as result sets or error messages to the client.
#
#character_set_connection: The character set used for literals that do not have a character set introducer and for number-to-string conversion.
#
#testing selest SQL, about character_set_client and character_set_results.
#share_conn
set names 'utf8'
select @@character_set_client,@@character_set_connection,@@character_set_results
drop table if exists mytest_test1
create table mytest_test1(id int,data varchar(10))
insert into mytest_test1 values (1,'测试1')
select * from mytest_test1
set @@character_set_client='gbk'
select * from mytest_test1
set @@character_set_results='gbk'
select * from mytest_test1
select concat('123','测试2')
#end
#
#testing insert SQL, about character_set_client,character_set_connection and character_set_results.
#!share_conn
set names 'utf8'
select @@character_set_client,@@character_set_connection,@@character_set_results
drop table if exists mytest_test1
create table mytest_test1(id int,data varchar(10))
insert into mytest_test1 values (1,'测试1')
select * from mytest_test1
set @@character_set_connection='gbk'
insert into mytest_test1 values (2,'测试2')
select * from mytest_test1
set @@character_set_connection='ascii'
insert into mytest_test1 values (3,'测试3')
select * from mytest_test1
set @@character_set_connection='utf8'
select @@character_set_connection
set @@character_set_client='gbk'
select @@character_set_client
insert into mytest_test1 values (4,'测试4')
select * from mytest_test1
set @@character_set_client='utf8'
select * from mytest_test1
set @@character_set_results='gbk'
insert into mytest_test1 values (5,'测试5')
select * from mytest_test1
set @@character_set_results='utf8'
set @@character_set_client='utf8'
select @@character_set_client,@@character_set_connection,@@character_set_results
insert into mytest_test1 value (6,'测试6')
select * from mytest_test1
#SET NAMES {'charset_name'
#    [COLLATE 'collation_name'] | DEFAULT}
#!share_conn
set character set ascii
select @@character_set_client
select @@character_set_results
set character set DEFAULT
select @@character_set_client
select @@character_set_results
set charset ascii
select @@character_set_client
select @@character_set_results
set charset DEFAULT
select @@character_set_client
select @@character_set_results
set names default
select @@character_set_client
select @@character_set_results
select @@character_set_connection
set names 'ascii' collate 'ascii_general_ci'
select @@character_set_client
select @@character_set_results
select @@character_set_connection
#
#clear tables
#
drop table if exists mytest_test1