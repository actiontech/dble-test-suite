#github issue #599
drop table if exists a_two
CREATE TABLE a_two (id int(11) NOT NULL,c_flag char(255) DEFAULT NULL,c_decimal decimal(16,4) DEFAULT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8
SELECT a.id, sum(a.c_decimal) AS c_decimal FROM a_two a GROUP BY a.id HAVING sum(a.c_decimal) != 0
#github issue #600
drop table if exists test1
drop table if exists test2
CREATE TABLE test1 (id bigint(11) NOT NULL,c_char char(255) DEFAULT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8
CREATE TABLE test2 (id bigint(11) NOT NULL,c_char char(255) DEFAULT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8
insert into test1 values(1,'1')
insert into test1(id) values(2)
insert into test2 values(1,'1')
insert into test2(id) values(2)
select * from test1 a inner join test2 b on a.c_char =b.c_char order by a.id
select * from test1 a right join test2 b on a.c_char =b.c_char order by a.id
select * from test1 a left join test2 b on a.c_char =b.c_char order by a.id
#case from gonghang
drop table if exists a_test
drop table if exists a_order
create table a_test(id int, trancode varchar(20), RETCODE char(2), OAPP varchar(20))
create table a_order(id int, trancode varchar(20), RETCODE char(2), OAPP varchar(20))
#!multiline
SELECT COUNT(*) FROM (
     select test1.*
     from mytest.a_test test1
     where test1.trancode = 'ATS000010CHGEBUSSPTBNK'
     AND test1.RETCODE = '0'
     AND test1.OAPP != 'F-CLMS'

     UNION

     SELECT test2.*
     FROM mytest.a_order test2
     WHERE test2.trancode = 'ATS000008QRYBUSSPTGIFTLIST'
     AND test2.RETCODE = '0'
     AND test2.OAPP != 'F-CLMS'
     ) t3
#end multiline
#github issue 581
drop table if exists a_test
drop table if exists a_order
drop table if exists a_manager
drop table if exists test_global
create table a_test(id int primary key,name varchar(10))
create table a_order(id int primary key,name varchar(10))
create table a_manager(id int primary key,name varchar(10))
create table test_global(id int primary key,name varchar(10))
insert into a_test values(1,'actiontech')
insert into a_order values(1,'actiontech')
insert into a_manager values(1,'actiontech')
insert into test_global values(1,'actiontech')
select a.id,a.name from a_test a join a_order b where a.id=b.id union  select id,name from a_manager
select id,concat(id,'_',name)from a_test union all select id,concat(id,'_',name)from a_test
select a.id,concat(a.id,'_',a.name) from a_test a join a_order b where a.id=b.id union  select id,concat(id,'_',name)from a_manager
select 1 union select id from a_test
select id from a_test union select 1
select 1 union select id from test_global
select id from test_global union SELECT 1
#github issue 537
drop table if exists test_shard
create table test_shard (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test_shard (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
explain(select 1 from test_shard)union(select 2)/*allow_diff*/
explain (select 1 from test_shard)union(select 2)/*allow_diff*/
#github issue #535
drop table if exists test_global;
drop table if exists global_table2;
CREATE TABLE test_global(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8;
CREATE TABLE global_table2(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8;
insert into test_global values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6);
insert into global_table2 values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1);
(select a.id,a.t_id,a.name,a.pad from test_global a where a.pad=1) union (select c.id,c.o_id,c.name,c.pad from global_table2 c where c.pad=1) order by id limit 2;
#github issue 567
drop table if exists test_shard
drop table if exists test_global
create table test_shard(id int,c int,name varchar(20))
create table test_global(id int,c int,name varchar(20))
create table enum_patch_string(id varchar(20) ,name varchar(20))
create table date_patch(id Date,name varchar(20))
insert into test_global values(1,1,'test_global_1'),(2,2,'test_global_2'),(2,2,'test_global_3')
insert into test_shard values(null,1,'test_shard_1'),(null,2,'test_shard_2'),(null,3,'test_shard_3')
insert into test_shard set id=null,c=4,name='test_shard_4'
insert into enum_patch_string values(null,'enum_patch_string1'),('aaa','enum_patch_string2')
insert into date_patch values(null,'date_patch1'),('2018-08-21','date_patch2')
update test_shard set name = 'test_shard 1_1' where id is null;
update enum_patch_string set name='enum_patch_string1_1' where id is null
update date_patch set name='date_patch1_1' where id is null
select * from test_shard where id is null
select * from enum_patch_string where id is null
select * from date_patch where id is null
select * from test_shard order by id;
select * from test_shard order by id limit 1,1
select * from test_shard order by id limit 1,2
select id,c from test_shard group by id,c order by id,c limit 1,2
select * from test_shard a join test_global as b on a.id=b.id order by b.id
select * from test_shard a inner join test_global as b on a.id=b.id order by b.id
select * from test_shard a cross join test_global as b on a.id=b.id order by b.id
select * from test_shard a straight_join (select * from test_global where c>0) b on a.id<b.id
select a.id,a.c from test_shard a left join (select * from test_global where c>2) b on a.id=b.id
select * from test_shard a right join (select * from test_global where c>2) b on a.id=b.id
select * from (select * from test_shard where id>1) a natural left join (select * from test_global where id>3) b order by a.id,b.id
select * from (select * from test_shard where id>1) a natural right join (select * from test_global where id>3) b order by a.id,b.id
select * from (select * from test_shard where id>1) a natural left outer join (select * from test_global where id>3) b order by a.id,b.id
select * from (select * from test_shard where id>1) a natural right outer join (select * from test_global where id>3) b order by a.id,b.id
(select name from test_shard where id=null order by id) union all (select name from test_global where id=1 order by id)
(select name from test_shard where id=null order by id) union distinct (select name from test_global where id=1 order by id)
(select a.name,a.c from test_shard a  where id=null) union (select b.name,b.c from test_global b  where id=1) order by name;
(select name as sort_a from test_shard where id=null) union (select name from test_global where id=1)
(select name as sort_a,c from test_shard where id=null) union (select name,c from test_global where id=1) order by sort_a,c
delete from test_shard where id is null
delete from enum_patch_string where id is null
delete from date_patch where id is null
drop table if exists test_shard
drop table if exists test_global
#github issue 624
drop table if exists test_shard;
CREATE TABLE test_shard(id int(11) NOT NULL,c_flag char(255) DEFAULT NULL,c_decimal decimal(16,4) DEFAULT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 select count(*) from test_shard where id = (select * from test_shard where id =1);
drop table if exists test_shard;