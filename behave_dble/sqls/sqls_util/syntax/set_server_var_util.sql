#!default_db:schema1
#insert_id: The value to be used by the following INSERT or ALTER TABLE statement when inserting an AUTO_INCREMENT value.
#!share_conn
select @@insert_id
drop table if exists test1
create table test1(id int not null primary key auto_increment)
set @@insert_id=10
insert into test1 (id) values (null)
select id from test1
set @@session.insert_id=11
insert into test1 (id) values (null)
select id from test1
set session insert_id=12
insert into test1 (id) values (null)
select id from test1
#
#sql_auto_is_null: If this variable is set to 1, then after a statement that successfully inserts an automatically generated AUTO_INCREMENT value.
#!share_conn
drop table if exists test1
create table test1(id int primary key auto_increment,data varchar(10))
insert into test1 (data) values ('aaa')
select id,data from test1 where id is null
set @@sql_auto_is_null=on
select @@sql_auto_is_null
#insert into test1 (data) values ('bbb')
select id,data from test1 where id is null
set @@session.sql_auto_is_null=off
select @@sql_auto_is_null
#
#clear tables
#
drop table if exists test1