drop table if exists test_shard
create table test_shard (id int(11),R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test_shard (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
#!share_conn
#
#contains alter table
#
prepare pre_test from 'alter table test_shard add age int(10)'
execute pre_test
show create table test_shard
drop prepare pre_test
prepare pre_test from 'alter table test_shard drop age'
execute pre_test
show create table test_shard
drop prepare pre_test
prepare pre_test from 'alter table test_shard add index (R_NAME)'
execute pre_test
show index in test_shard where Key_name='R_NAME'
alter table test_shard drop index R_NAME
drop prepare pre_test
prepare pre_test from 'alter table test_shard add index (R_NAME,R_COMMENT)'
execute pre_test
show index in test_shard where Key_name='R_NAME'
alter table test_shard drop index R_NAME
drop prepare pre_test
prepare pre_test from 'alter table test_shard add primary key (id)'
execute pre_test
desc test_shard
alter table test_shard drop primary key
drop prepare pre_test
prepare pre_test from 'alter table test_shard add unique (id)'
execute pre_test
show create table test_shard
drop prepare pre_test
################################unsupported alter...alter....default...##################
#prepare pre_test from 'alter table test_shard alter R_REGIONKEY set default 10'
#execute pre_test
#show create table test_shard
#drop prepare pre_test
#prepare pre_test from 'alter table test_shard alter R_REGIONKEY drop default'
#execute pre_test
#show create table test_shard
#drop prepare pre_test
prepare pre_test from 'alter table test_shard change R_NAME name varchar(50)'
execute pre_test
show create table test_shard
drop prepare pre_test
prepare pre_test from 'alter table test_shard modify name varchar(60)'
execute pre_test
show create table test_shard
drop prepare pre_test
prepare pre_test from 'alter table test_shard drop name'
execute pre_test
show create table test_shard
drop prepare pre_test
alter table test_shard add primary key (id)
show create table test_shard
prepare pre_test from 'alter table test_shard drop primary key'
execute pre_test
show create table test_shard
drop prepare pre_test
alter table test_shard add index (R_COMMENT)
show index from test_shard
prepare pre_test from 'alter table test_shard drop R_COMMENT'
execute pre_test
show index from test_shard
drop prepare pre_test
#
#contains create view
#
drop table if exists a_test
drop table if exists a_order
drop table if exists a_manager
CREATE TABLE a_test(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))
CREATE TABLE a_order(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))
CREATE TABLE a_manager(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))
insert into a_test values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into a_order values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_manager values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
prepare pre_test from 'create view view_test as select a_test.id,a_test.name,a_test.pad,a_order.name as a_name from a_test inner join a_order'
execute pre_test
select * from view_test
drop view view_test
drop prepare pre_test
prepare pre_test from  'create view view_test as select a.id,b.id as b_id,b.pad,a.t_id from a_test a,(select all * from a_order) b where a.t_id=b.o_id'
execute pre_test
select * from view_test
drop view view_test
drop prepare pre_test
#
#contains drop view
#
drop table if exists test_shard
create table test_shard (id int(11),R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test_shard (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
create view view_test as select * from test_shard
prepare pre_test from 'drop view view_test'
execute pre_test
select * from view_test/*error:no view*/
drop prepare pre_test
#
#contains delete
#
select * from test_shard
prepare pre_test from 'delete from test_shard'
execute pre_test
select * from test_shard
insert into test_shard (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
drop prepare pre_test
prepare pre_test from 'delete from test_shard where id=3'
execute pre_test
select * from test_shard
delete from test_shard
insert into test_shard (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
drop prepare pre_test
#
#contains insert
#
prepare pre_test from 'insert into test_shard values(?,?,?,?)'
set @a=20,@b=20,@c='test',@d='test20'
execute pre_test using @a,@b,@c,@d
select * from test_shard
set @a=21,@b=21,@c='test',@d='test21'
execute pre_test using @a,@b,@c,@d
select * from test_shard
drop prepare pre_test
#
#contains replace
#
prepare pre_test from 'replace into test_shard values(?,?,?,?)'
set @a=20,@b=20,@c='test_new',@d='test20'
execute pre_test using @a,@b,@c,@d
select * from test_shard
drop prepare pre_test
#
#contains select
#
prepare pre_test from 'select a_test.id,a_test.name,a_test.pad,a_order.name as a_name from a_test inner join a_order'
execute pre_test
drop prepare pre_test
prepare pre_test from 'select a.id,b.id as b_id,b.pad,a.t_id from a_test a,(select all * from a_order) b where a.t_id=b.o_id'
execute pre_test
drop prepare pre_test
prepare pre_test from 'select * from test_shard where id=3'
execute pre_test
drop prepare pre_test
#
#using set
#
prepare pre_test from 'set @a=?'
set @b=1
execute pre_test using @b
select @a
drop prepare pre_test
#
#contains show
#
prepare pre_test from 'show create table test_shard'
execute pre_test
drop prepare pre_test
###################unsupported show create view#######################
#create view view_test as select * from test_shard
#prepare pre_test from 'show create view view_test'
#execute pre_test
#drop view view_test
#drop prepare pre_test
#
#contains truncate
#
select * from test_shard
prepare pre_test from 'truncate table test_shard'
execute pre_test
insert into test_shard (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
drop prepare pre_test
#
#contains update
#
prepare pre_test from 'update test_shard set R_NAME=? where id=?'
set @a='test',@b=1
execute pre_test using @a,@b
select * from test_shard
drop prepare pre_test
#
#more than one prepare
#
prepare pre_test from 'select * from test_shard where id=?'
prepare pre_set from 'set @a=?'
set @b=1
execute pre_set using @b
execute pre_test using @b
drop prepare pre_test
#
#automatic change prepare
#
prepare pre_test from 'select * from test_shard where id=1'
prepare pre_test from 'select * from test_shard where id=2'
execute pre_test
drop prepare pre_test
#
#error test
#
prepare pre_test from 'select * from test_shard w'
execute pre_test
prepare pre_test fr 'select * from test_shard where id=2'
execute pre_test
execute pret/*error:unknown prepare*/
#
#clear tables
#
drop table if exists test_shard