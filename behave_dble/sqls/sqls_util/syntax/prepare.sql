#!default_db:schema1
drop table if exists test1
create table test1 (id int(11),R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
#!share_conn
#
#contains alter table
#
#!sql_thread_1
prepare pre_test from 'alter table test1 add age int(10)'
execute pre_test
show create table test1
drop prepare pre_test
prepare pre_test from 'alter table test1 drop age'
execute pre_test
show create table test1
drop prepare pre_test
prepare pre_test from 'alter table test1 add index (R_NAME)'
execute pre_test
show index in test1 where Key_name='R_NAME'
alter table test1 drop index R_NAME
drop prepare pre_test
prepare pre_test from 'alter table test1 add index (R_NAME,R_COMMENT)'
execute pre_test
show index in test1 where Key_name='R_NAME'
alter table test1 drop index R_NAME
drop prepare pre_test
prepare pre_test from 'alter table test1 add primary key (id)'
execute pre_test
desc test1
alter table test1 drop primary key
drop prepare pre_test
prepare pre_test from 'alter table test1 add unique (id)'
execute pre_test
show create table test1
drop prepare pre_test
################################unsupported alter...alter....default...##################
#prepare pre_test from 'alter table test1 alter R_REGIONKEY set default 10'
#execute pre_test
#show create table test1
#drop prepare pre_test
#prepare pre_test from 'alter table test1 alter R_REGIONKEY drop default'
#execute pre_test
#show create table test1
#drop prepare pre_test
prepare pre_test from 'alter table test1 change R_NAME name varchar(50)'
execute pre_test
show create table test1
drop prepare pre_test
prepare pre_test from 'alter table test1 modify name varchar(60)'
execute pre_test
show create table test1
drop prepare pre_test
prepare pre_test from 'alter table test1 drop name'
execute pre_test
show create table test1
drop prepare pre_test
alter table test1 add primary key (id)
show create table test1
prepare pre_test from 'alter table test1 drop primary key'
execute pre_test
show create table test1
drop prepare pre_test
alter table test1 add index (R_COMMENT)
show index from test1
prepare pre_test from 'alter table test1 drop R_COMMENT'
execute pre_test
show index from test1
drop prepare pre_test
#
#contains create view
#
drop table if exists test1
drop table if exists schema2.test2
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))
CREATE TABLE schema2.test2(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))
insert into test1 values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into schema2.test2 values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
prepare pre_test from 'create view view_test as select test1.id,test1.name,test1.pad,schema2.test2.name as a_name from test1 inner join schema2.test2'
execute pre_test
select * from view_test
drop view view_test
drop prepare pre_test
prepare pre_test from  'create view view_test as select a.id,b.id as b_id,b.pad,a.t_id from test1 a,(select all * from schema2.test2) b where a.t_id=b.o_id'
execute pre_test
select * from view_test
drop view view_test
drop prepare pre_test
#
#contains select
#
prepare pre_test from 'select test1.id,test1.pad,schema2.test2.name as a_name from test1 inner join schema2.test2'
execute pre_test
drop prepare pre_test
prepare pre_test from 'select a.id as a_id,b.id as b_id,a.pad from test1 a,(select all * from schema2.test2) b where a.t_id=b.o_id'
execute pre_test
drop prepare pre_test
prepare pre_test from 'select * from test1 where id=3'
execute pre_test
drop prepare pre_test
#
#contains drop view
#
drop table if exists test1
create table test1 (id int(11),R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
create view view_test as select * from test1
prepare pre_test from 'drop view view_test'
execute pre_test
select * from view_test/*error:no view*/
drop prepare pre_test
#
#contains delete
#
select * from test1
prepare pre_test from 'delete from test1'
execute pre_test
select * from test1
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
drop prepare pre_test
prepare pre_test from 'delete from test1 where id=3'
execute pre_test
select * from test1
delete from test1
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
drop prepare pre_test
#
#contains insert
#
prepare pre_test from 'insert into test1 values(?,?,?,?)'
set @a=20,@b=20,@c='test',@d='test20'
execute pre_test using @a,@b,@c,@d
select * from test1
set @a=21,@b=21,@c='test',@d='test21'
execute pre_test using @a,@b,@c,@d
select * from test1
drop prepare pre_test
#
#contains replace
#
prepare pre_test from 'replace into test1 values(?,?,?,?)'
set @a=20,@b=20,@c='test_new',@d='test20'
execute pre_test using @a,@b,@c,@d
select * from test1
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
prepare pre_test from 'show create table test1'
execute pre_test
drop prepare pre_test
###################unsupported show create view#######################
#create view view_test as select * from test1
#prepare pre_test from 'show create view view_test'
#execute pre_test
#drop view view_test
#drop prepare pre_test
#
#contains truncate
#
select * from test1
prepare pre_test from 'truncate table test1'
execute pre_test
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
drop prepare pre_test
#
#contains update
#
prepare pre_test from 'update test1 set R_NAME=? where id=?'
set @a='test',@b=1
execute pre_test using @a,@b
select * from test1
drop prepare pre_test
#
#more than one prepare
#
prepare pre_test from 'select * from test1 where id=?'
prepare pre_set from 'set @a=?'
set @b=1
execute pre_set using @b
execute pre_test using @b
drop prepare pre_test
#
#automatic change prepare
#
prepare pre_test from 'select * from test1 where id=1'
prepare pre_test from 'select * from test1 where id=2'
execute pre_test
drop prepare pre_test
#
#error test
#
prepare pre_test from 'select * from test1 w'
execute pre_test
prepare pre_test fr 'select * from test1 where id=2'
execute pre_test
execute pret/*error:unknown prepare*/
#
#clear tables
#
drop table if exists test1