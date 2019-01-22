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
#!share_conn
SELECT @@error_count / @@warning_count
SELECT REPEAT('a',1) UNION SELECT REPEAT('b',10)
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