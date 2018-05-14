#user_var_name = expr
#SET @var_name = expr [, @var_name = expr] ...
SET @t1=1, @t2=2, @t3:=4
SELECT @t1, @t2, @t3, @t4 := @t1+@t2+@t3
SET @v1 = X'41'
SET @v2 = X'41'+0
SET @v3 = CAST(X'41' AS UNSIGNED)
SELECT @v1, @v2, @v3
SET @v1 = b'1000001'
SET @v2 = b'1000001'+0
SET @v3 = CAST(b'1000001' AS UNSIGNED)
SELECT @v1, @v2, @v3
#DROP TABLE IF EXISTS aly_test
#CREATE TABLE aly_test (id int,data varchar(10))
#INSERT aly_test VALUES (1,'aaa'),(2,'bbb')
#SET @total_tax = (SELECT SUM(id) FROM aly_test)
#SELECT @total_tax
#
#param_name = expr not test, Stored procedure and function parameters, and stored program local variables
#!share_conn
SELECT @@error_count / @@warning_count
DROP TABLE IF EXISTS shop
create table shop(article int(4), dealer varchar(10), price float(8,2))
insert into shop values(1, 'D', 234.25),(2, 'D', 67.29),(3, 'D', 1.25),(4,'D',19.95)
SELECT @min_price:=MIN(price),@max_price:=MAX(price) FROM shop
SELECT * FROM shop WHERE price=@min_price OR price=@max_price
SELECT (@aa:=article) AS a, (@aa+3) AS b FROM shop HAVING b=5
drop table if exists t1
drop table if exists t2
drop table if exists t3
create table t1(a int(4), B int(4))
insert into t1 values (10, 1),(10, 1),(11,1),(10, 1)
create table t2(a int(4), B int(4))
insert into t2 values (10, 1),(11, 2),(10,2)
create table t3(a int(4), B int(4))
insert into t3 values (12, 1),(11, 1),(10,11)
(SELECT @vara:=a FROM t1 WHERE a=10 AND B=1) UNION (SELECT @varb:=B FROM t2 WHERE a=@vara AND B=2) UNION (SELECT a FROM t3 WHERE a=@vara+@varb AND B=1)
SELECT REPEAT('a',1) UNION SELECT REPEAT('b',10)
drop table if exists table_member_comments
drop table if exists table_guest_comments
create table table_member_comments(id int(4), datetime timestamp, widgetID int(8), message varchar(255), active boolean)
create table table_guest_comments(id int(4), datetime timestamp, widgetID int(8), message varchar(255), active boolean)
insert into table_member_comments values(1, 20160825174312, 90, 'hello world', 0),(2, 20160823174313, 100, 'hello python', 1),(3, 20160822174314, 100, 'hello java', 1)
insert into table_guest_comments values(1, 20160825174312, 90, 'hello world', 0),(2, 20160823174313, 100, 'hello php', 1),(3, 20160822174314, 100, 'hello c++', 0)
SELECT @vara,  @varb, mydata.message FROM( (SELECT @vara := 99, datetime, message FROM table_member_comments WHERE widgetID = 100 AND active = 1) UNION (SELECT @varb := 100, datetime, message FROM table_guest_comments WHERE widgetID = 100 AND active = 0) ) mydata ORDER BY mydata.datetime, @vara ASC
#user variables
set @abc123=1
set @123abc=2
set @abc=3
set @123=4
set @$=5
set @.=6
set @_=7
set @.abc_123$=8
#set @-=9
set @`-`=10
set @uv:=11
set @a:=1
set @a:=@a+1
set @b='str', @c=4.4, @d={d'2012@12@31'}
SELECT @abc123, @123abc, @row_format=1, @$ := @t1+@t2+@t3
#SET Syntax for Variable Assignment
set @cnt = (select 1);
#set session character_set_client = @@character_set_client
#set @@session.character_set_client = @@character_set_client
#set @@character_set_client = @@character_set_client
#set @a=1, session character_set_client = @@character_set_client
SET SESSION sort_buffer_size = 1000000
SET @@local.sort_buffer_size = 1000000
SET sort_buffer_size = 1000000
SET @@session.max_join_size=DEFAULT
#SET @@session.max_join_size=@@global.max_join_size
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
set @a=(select 'abc')
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
drop table if exists t1
drop table if exists t2
drop table if exists t3
drop table if exists table_member_comments
drop table if exists table_guest_comments
DROP TABLE IF EXISTS shop
DROP TABLE IF EXISTS aly_test