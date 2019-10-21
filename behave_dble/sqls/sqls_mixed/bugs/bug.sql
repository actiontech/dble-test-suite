#github issue #599
drop table if exists sharding_2_t1
CREATE TABLE sharding_2_t1 (id int(11) NOT NULL,c_flag char(255) DEFAULT NULL,c_decimal decimal(16,4) DEFAULT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8
SELECT a.id, sum(a.c_decimal) AS c_decimal FROM sharding_2_t1 a GROUP BY a.id HAVING sum(a.c_decimal) != 0
#github issue #600
drop table if exists sharding_1_t1
drop table if exists sharding_1_t2
CREATE TABLE sharding_1_t1 (id bigint(11) NOT NULL,c_char char(255) DEFAULT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8
CREATE TABLE sharding_1_t2 (id bigint(11) NOT NULL,c_char char(255) DEFAULT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8
insert into sharding_1_t1 values(1,'1')
insert into sharding_1_t1(id) values(2)
insert into sharding_1_t2 values(1,'1')
insert into sharding_1_t2(id) values(2)
select * from sharding_1_t1 a inner join sharding_1_t2 b on a.c_char =b.c_char order by a.id
select * from sharding_1_t1 a right join sharding_1_t2 b on a.c_char =b.c_char order by a.id
select * from sharding_1_t1 a left join sharding_1_t2 b on a.c_char =b.c_char order by a.id
#case from somebank
drop table if exists sharding_4_t1
drop table if exists schema2.sharding_4_t2
create table sharding_4_t1(id int, trancode varchar(20), RETCODE char(2), OAPP varchar(20))
create table schema2.sharding_4_t2(id int, trancode varchar(20), RETCODE char(2), OAPP varchar(20))
#!multiline
SELECT COUNT(*) FROM (
     select test1.*
     from schema1.sharding_4_t1 test1
     where test1.trancode = 'AAA'
     AND test1.RETCODE = '0'
     AND test1.OAPP != 'bbb'

     UNION

     SELECT test2.*
     FROM schema2.sharding_4_t2 test2
     WHERE test2.trancode = 'BBB'
     AND test2.RETCODE = '0'
     AND test2.OAPP != 'bbb'
     ) t3
#end multiline
#github issue 581
drop table if exists sharding_4_t1
drop table if exists schema2.sharding_4_t2
drop table if exists schema3.sharding_4_t3
drop table if exists schema2.global_4_t1
create table sharding_4_t1(id int primary key,name varchar(10))
create table schema2.sharding_4_t2(id int primary key,name varchar(10))
create table schema3.sharding_4_t3(id int primary key,name varchar(10))
create table schema2.global_4_t1(id int primary key,name varchar(10))
insert into sharding_4_t1 values(1,'actiontech')
insert into schema2.sharding_4_t2 values(1,'actiontech')
insert into schema3.sharding_4_t3 values(1,'actiontech')
insert into schema2.global_4_t1 values(1,'actiontech')
select a.id,a.name from sharding_4_t1 a join schema2.sharding_4_t2 b where a.id=b.id union  select id,name from schema3.sharding_4_t3
select id,concat(id,'_',name)from sharding_4_t1 union all select id,concat(id,'_',name)from sharding_4_t1
select a.id,concat(a.id,'_',a.name) from sharding_4_t1 a join schema2.sharding_4_t2 b where a.id=b.id union  select id,concat(id,'_',name)from schema3.sharding_4_t3
select 1 union select id from sharding_4_t1
select id from sharding_4_t1 union select 1
select 1 union select id from schema2.global_4_t1
select id from schema2.global_4_t1 union SELECT 1
#github issue 537
drop table if exists sharding_4_t1
create table sharding_4_t1 (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))DEFAULT CHARSET=UTF8
insert into sharding_4_t1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
#explain(select 1 from sharding_4_t1)union(select 2)/*allow_diff*/
#explain (select 1 from sharding_4_t1)union(select 2)/*allow_diff*/
#github issue #535
drop table if exists schema2.global_4_t1
drop table if exists schema2.global_4_t2
CREATE TABLE schema2.global_4_t1(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE schema2.global_4_t2(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
insert into schema2.global_4_t1 values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into schema2.global_4_t2 values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
(select a.id,a.t_id,a.name,a.pad from schema2.global_4_t1 a where a.pad=1) union (select c.id,c.o_id,c.name,c.pad from schema2.global_4_t2 c where c.pad=1) order by name limit 2
#github issue 567
drop table if exists sharding_4_t1
drop table if exists schema2.global_4_t1
drop table if exists sharding_enum_string_t1
drop table if exists sharding_date_t1
create table sharding_4_t1(id int,c int,name varchar(20))
create table schema2.global_4_t1(id int,c int,name varchar(20))
create table sharding_enum_string_t1(id varchar(20) ,name varchar(20))
create table sharding_date_t1(id Date,name varchar(20))
insert into schema2.global_4_t1 values(1,1,'test_global_1'),(2,2,'test_global_2'),(2,2,'test_global_3')
insert into sharding_4_t1 values(null,1,'test_shard_1'),(null,2,'test_shard_2'),(null,3,'test_shard_3')
insert into sharding_4_t1 set id=null,c=4,name='test_shard_4'
insert into sharding_enum_string_t1 values(null,'enum_patch_string1'),('aaa','enum_patch_string2')
insert into sharding_date_t1 values(null,'date_patch1'),('2018-08-21','date_patch2')
update sharding_4_t1 set name = 'sharding_4_t1 1_1' where id is null
update sharding_enum_string_t1 set name='enum_patch_string1_1' where id is null
update sharding_date_t1 set name='date_patch1_1' where id is null
select * from sharding_4_t1 where id is null
select * from sharding_enum_string_t1 where id is null
select * from sharding_date_t1 where id is null
select * from sharding_4_t1 order by id
select * from sharding_4_t1 order by id limit 1,1
select * from sharding_4_t1 order by id limit 1,2
select id,c from sharding_4_t1 group by id,c order by id,c limit 1,2
select * from sharding_4_t1 a join schema2.global_4_t1 as b on a.id=b.id order by b.id
select * from sharding_4_t1 a inner join schema2.global_4_t1 as b on a.id=b.id order by b.id
select * from sharding_4_t1 a cross join schema2.global_4_t1 as b on a.id=b.id order by b.id
select * from sharding_4_t1 a straight_join (select * from schema2.global_4_t1 where c>0) b on a.id<b.id
select a.id,a.c from sharding_4_t1 a left join (select * from schema2.global_4_t1 where c>2) b on a.id=b.id
select * from sharding_4_t1 a right join (select * from schema2.global_4_t1 where c>2) b on a.id=b.id
select * from (select * from sharding_4_t1 where id>1) a natural left join (select * from schema2.global_4_t1 where id>3) b order by a.id,b.id
select * from (select * from sharding_4_t1 where id>1) a natural right join (select * from schema2.global_4_t1 where id>3) b order by a.id,b.id
select * from (select * from sharding_4_t1 where id>1) a natural left outer join (select * from schema2.global_4_t1 where id>3) b order by a.id,b.id
select * from (select * from sharding_4_t1 where id>1) a natural right outer join (select * from schema2.global_4_t1 where id>3) b order by a.id,b.id
(select name from sharding_4_t1 where id=null order by id) union all (select name from schema2.global_4_t1 where id=1 order by id)
(select name from sharding_4_t1 where id=null order by id) union distinct (select name from schema2.global_4_t1 where id=1 order by id)
(select a.name,a.c from sharding_4_t1 a  where id=null) union (select b.name,b.c from schema2.global_4_t1 b  where id=1) order by name
(select name as sort_a from sharding_4_t1 where id=null) union (select name from schema2.global_4_t1 where id=1)
(select name as sort_a,c from sharding_4_t1 where id=null) union (select name,c from schema2.global_4_t1 where id=1) order by sort_a,c
delete from sharding_4_t1 where id is null
delete from sharding_enum_string_t1 where id is null
delete from sharding_date_t1 where id is null
drop table if exists sharding_4_t1
drop table if exists schema2.global_4_t1
drop table if exists sharding_enum_string_t1
drop table if exists sharding_date_t1
#github issue 624
drop table if exists sharding_4_t1
CREATE TABLE sharding_4_t1(id int(11) NOT NULL,c_flag char(255) DEFAULT NULL,c_decimal decimal(16,4) DEFAULT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8
 select count(*) from sharding_4_t1 where id = (select id from sharding_4_t1 where id =1)
drop table if exists sharding_4_t1
#github issue 651
drop table if exists sharding_4_t1
drop table if exists schema2.sharding_4_t2
create table sharding_4_t1(id int primary key,name varchar(10))
create table schema2.sharding_4_t2(id int primary key,name varchar(10))
insert into sharding_4_t1 values(1,'actiontech')
insert into schema2.sharding_4_t2 values(1,'actiontech')
select `A`.* FROM (select sharding_4_t1.id,schema2.sharding_4_t2.name from schema2.sharding_4_t2, sharding_4_t1 where  sharding_4_t1.id = schema2.sharding_4_t2.id) `A` where `A`.id = 99 order by `A`.id
#github issue 126
drop table if exists sharding_4_t1
create table sharding_4_t1(id int,c int,name varchar(20))
insert into sharding_4_t1 values(1,1,'test_global_1'),(2,2,'test_global_2'),(2,2,'test_global_3')
update sharding_4_t1 set name ='test' wher id=1
delete from sharding_4_t1 wher id=2
select * from sharding_4_t1 wher id=3
select * from sharding_4_t1 where id=3 orde by id
drop table if exists sharding_4_t1
#github issue 666
drop table if exists sharding_4_t1
CREATE TABLE sharding_4_t1(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
insert into sharding_4_t1 values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
select id a,t_id b,name c,pad d from (select * from sharding_4_t1 union SELECT'20180716' AS BUSIDATE,'00119' AS ZONENO,'260' AS BRNO,'34890' AS TELLERNO)t order by a
select id,t_id,name,pad from sharding_4_t1 union (SELECT'20180716' AS id,'00119' AS ZONENO,'260' AS BRNO,'34890' AS TELLERNO) order by id
drop table if exists schema2.global_4_t1
CREATE TABLE schema2.global_4_t1(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
insert into schema2.global_4_t1 values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
select id a,t_id b,name c,pad d from (select id,t_id,name,pad from schema2.global_4_t1 union SELECT'20180716' AS BUSIDATE,'00119' AS ZONENO,'260' AS BRNO,'34890' AS TELLERNO)t order by a
select id,t_id,name,pad from schema2.global_4_t1 union (SELECT'20180716' AS id,'00119' AS ZONENO,'260' AS BRNO,'34890' AS TELLERNO) order by id
drop table if exists a_test_no_shard
CREATE TABLE a_test_no_shard(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
insert into a_test_no_shard values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
select id a,t_id b,name c,pad d from (select * from a_test_no_shard union SELECT'20180716' AS BUSIDATE,'00119' AS ZONENO,'260' AS BRNO,'34890' AS TELLERNO)t order by a
select id,t_id,name,pad from a_test_no_shard union (SELECT'20180716' AS id,'00119' AS ZONENO,'260' AS BRNO,'34890' AS TELLERNO) order by id
#github issue 681
drop table if exists sharding_2_t1
drop table if exists sharding_3_t1
create table sharding_2_t1(id int, aa int)
create table sharding_3_t1(id int, bb int)
insert into sharding_2_t1 values(1,123)
insert into sharding_3_t1 values(2,111),(2,123),(2,NULL)
select * from sharding_2_t1 a,sharding_3_t1 b where a.aa = b.bb
#github issue #678 #671
drop table if exists sharding_2_t1
create table sharding_2_t1 (id int,busidate char(20),zoneno char(20),brno int,tellerno int)
SELECT T.BUSIDATE AS occurDate, T.ZONENO AS zoneNo, IFNULL(T.BRNO, 0) AS uncheckPicture, IFNULL(T.TELLERNO, 0) AS uncheckFlow FROM ( SELECT F.BUSIDATE, F.ZONENO, F.BRNO, F.TELLERNO FROM sharding_2_t1 F WHERE F.id = 1 UNION ALL SELECT '20180716', '00119', 1, 0 UNION ALL SELECT '20180716', '00119', 1, 2 ) T
SELECT BUSIDATE AS occurDate, ZONENO AS zoneNo, IFNULL(BRNO, 0) AS uncheckPicture, IFNULL(TELLERNO, 0) AS uncheckFlow FROM ( SELECT F.BUSIDATE, F.ZONENO, F.BRNO, F.TELLERNO FROM sharding_2_t1 F WHERE F.id = 1 UNION ALL SELECT '20180716' , '00119' , 0 , 0 ) T
drop table if exists sharding_2_t1
#github issue #717
drop table if exists sharding_4_t1
drop table if exists schema2.sharding_4_t2
create table sharding_4_t1(id int, name varchar(20))
create table schema2.sharding_4_t2(id int, name varchar(20))
insert into sharding_4_t1 value(1,'a')
insert into schema2.sharding_4_t2 values(1,'d'),(2,'b'),(3,'c')
select b.* from sharding_4_t1 b left join schema2.sharding_4_t2 a on a.id=b.id where a.id is NULL
drop table if exists sharding_4_t1
drop table if exists schema2.sharding_4_t2
#github issue #687
drop table if exists sharding_one_1
drop table if exists sharding_one_2
create table sharding_one_1(id int)
create table sharding_one_2(id int)
select * from sharding_one_1 a where exists (select * from sharding_one_2 b where a.id =b.id)
drop table if exists sharding_one_1
drop table if exists sharding_one_2
#github issue #679 added by zhj
drop table if exists sharding_4_t1
CREATE TABLE sharding_4_t1(id int(11) NOT NULL,c_flag char(255),c_decimal decimal(16,4),PRIMARY KEY (id)) DEFAULT CHARSET=utf8
insert into sharding_4_t1 values(18,'美国',20.0),(530,'中国',20.0)
select c_decimal,group_concat(c_flag) from sharding_4_t1 where c_decimal =20 group by c_decimal
#github issue #758 #760
drop table if exists sharding_4_t1
create table sharding_4_t1(id int, c_decimal float)
select sum(c_decimal) c_alias from sharding_4_t1 order by c_alias
select -sum(c_decimal) c_alias from sharding_4_t1 order by c_alias
select abs(sum(c_decimal)) c_alias from sharding_4_t1 order by c_alias
drop table if exists sharding_4_t1
#github issue #779
drop table if exists schema2.global_4_t1
drop table if exists schema2.global_4_t2
create table schema2.global_4_t1 (DATANUM int,EXPORT_DATA_FILENAME varchar(50))
create table schema2.global_4_t2(id int)
SELECT tempview1.tablename,tempview1.datanum,tempview2.tablename,tempview2.datanum FROM (SELECT SUBSTRING_INDEX(t.EXPORT_DATA_FILENAME, '-', '1') tablename,SUM(t.DATANUM) datanum FROM schema2.global_4_t1 t GROUP BY SUBSTRING_INDEX(t.EXPORT_DATA_FILENAME, '-', '1')) tempview1,(SELECT 'ctp_user' tablename, COUNT(1) datanum FROM schema2.global_4_t2) tempview2 WHERE tempview1.tablename = tempview2.tablename
drop table if exists schema2.global_4_t1
drop table if exists schema2.global_4_t2
#github issue 258
drop table if exists sharding_4_t1
create table sharding_4_t1(id int,c_id int,name varchar(8)) partition by linear key algorithm=2 (id,c_id) partitions 4 (partition p0,partition p1,partition p2,partition p3)
drop table if exists sharding_4_t1
create table sharding_4_t1(id int,c_id int,name varchar(8)) partition by key  algorithm=1(id) partitions 4 (partition p0,partition p1,partition p2,partition p3)
drop table if exists sharding_4_t1
#github issue 316
set session tx_read_only=1
set session tx_read_only=0
#github issue 845
drop table if exists sharding_3_t1
create table sharding_3_t1(id int, c binary)
insert into sharding_3_t1 values(1, 0x1),(2,0),(3,null),(4,1),(2,1),(null,0)
select count(distinct id) from sharding_3_t1 group by c
select count(distinct c) from sharding_3_t1 group by c
select count(distinct id, c) from sharding_3_t1 group by c
drop table if exists sharding_4_t1
#github issue 800
drop table if EXISTS sharding_3_t1
CREATE  table sharding_3_t1(id int)
insert into sharding_3_t1 values(null)
select * from sharding_3_t1 a where a.id is null
drop table if EXISTS sharding_3_t1
#github issue 884
drop table if exists sharding_4_t1
create table sharding_4_t1 (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),t datetime,b bool)DEFAULT CHARSET=UTF8
insert into sharding_4_t1 (id,R_REGIONKEY,R_NAME,t,b) values (1,1, 'a string','2012/12/31 11:30:45',0),(2,2, 'a string','2012/12/31 11:30:45',0),(5,5, 'a string','2018/12/03 11:30:45',0)
select * from sharding_4_t1 where exists(select * from sharding_4_t1 where id=1||id=3)
drop table if exists sharding_4_t1
#github issue 829
drop table if exists schema2.global_4_t1
create table schema2.global_4_t1(id int,name varchar(30),role varchar(30))
/* ApplicationName=DBeaver 5.2.4 - Main */ create or replace view schema2.view_tg as select name,role from schema2.global_4_t1
/* ApplicationName=DBeaver 5.2.4 - Metadata / SHOW FULL TABLES FROM schema2 */
drop table if exists schema2.global_4_t1
drop view if exists view_tg
#issue:1023
drop table if exists sharding_4_t1
drop table if exists sharding_1_t1
drop table if exists schema2.global_4_t1
create table sharding_4_t1(id int,name varchar(30))
create table sharding_1_t1(id int,name varchar(30))
create table schema2.global_4_t1(id int,name varchar(30))
select a.id,b.id,c.id from schema2.global_4_t1 a,sharding_1_t1 b,sharding_4_t1 c order by a.id,c.id
#issue:1027
select a.id,b.name from schema2.global_4_t1 a,sharding_4_t1 b where a.id < (select id from sharding_1_t1 where id = 1)
#issue:1203
drop table if exists sharding_4_t1
create table sharding_4_t1(id int,name varchar(30))
lock tables `sharding_4_t1` write
insert into `sharding_4_t1` values(1,'1'),(2,'2'),(3,'3'),(4,'4')
insert into `sharding_4_t1` values(5,'5'),(6,'6'),(7,'7'),(8,'8')
unlock tables
#issue:1385
drop table if exists sharding_4_t1
create table sharding_4_t1(id int,goods_id varchar(40),city varchar(40))
insert into sharding_4_t1 values(1,"goods","city")
drop table if exists schema2.sharding_4_t2
drop table if exists schema2.global_4_t1
create table schema2.sharding_4_t2(id int,goods_id varchar(40))
insert into schema2.sharding_4_t2 values(2,"goods")
create table schema2.global_4_t1(id int,city varchar(50),wid int)
insert into schema2.global_4_t1 values(3,"city",4)
drop table if exists schema3.sharding_4_t3
create table schema3.sharding_4_t3(id int,name varchar(100))
insert into schema3.sharding_4_t3 values(4,"12345AAA")
select dg.id aaaa, dgw.id bbbb, ew.id cccc from schema1.sharding_4_t1 dgw inner join schema2.sharding_4_t2 dg on dgw.goods_id = dg.goods_id left join schema2.global_4_t1 dwp on dgw.city = dwp.city left join schema3.sharding_4_t3 ew on ew.id = dwp.wid where dgw.id = 1 and ew.name regexp 'AAA'
select dg.id aaaa, dgw.id bbbb, ew.id cccc from schema1.sharding_4_t1 dgw inner join schema2.sharding_4_t2 dg on dgw.goods_id = dg.goods_id left join schema2.global_4_t1 dwp on dgw.city = dwp.city left join schema3.sharding_4_t3 ew on ew.id = dwp.wid where dgw.id = 1 and ew.name regexp 'AAA$'
select dg.id aaaa, dgw.id bbbb, ew.id cccc from schema1.sharding_4_t1 dgw inner join schema2.sharding_4_t2 dg on dgw.goods_id = dg.goods_id left join schema2.global_4_t1 dwp on dgw.city = dwp.city left join schema3.sharding_4_t3 ew on ew.id = dwp.wid where dgw.id = 1 and ew.name not regexp '^AAA'
drop table if exists sharding_4_t1
drop table if exists schema2.sharding_4_t2
drop table if exists schema2.global_4_t1
drop table if exists schema3.sharding_4_t3
#issue:1429
drop table if exists global_4_t1
drop table if exists sharding_4_t1
drop table if exists sharding_4_t2
CREATE TABLE `global_4_t1` (`id` char(6) COLLATE utf8mb4_bin NOT NULL,`a_id` char(10) COLLATE utf8mb4_bin DEFAULT NULL,`q_id` char(30) COLLATE utf8mb4_bin DEFAULT NULL,`s_id` char(10) COLLATE utf8mb4_bin DEFAULT NULL,PRIMARY KEY (`id`),KEY `idx_q_s_id` (`q_id`,`s_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin
CREATE TABLE `sharding_4_t1` (`id` char(36) COLLATE utf8mb4_bin NOT NULL,`code` varchar(30) COLLATE utf8mb4_bin NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY `idx__code_qk` (`code`) USING BTREE,KEY `idx__a_code` (`code`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin
CREATE TABLE `sharding_4_t2` (`id` char(36) COLLATE utf8mb4_bin NOT NULL ,`code` varchar(30) COLLATE utf8mb4_bin NOT NULL,`ck` varchar(50) COLLATE utf8mb4_bin NOT NULL,`pre` varchar(10) COLLATE utf8mb4_bin NOT NULL DEFAULT '' ,PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin
insert into global_4_t1(id,a_id,q_id,s_id) values(1,'00001a','0001code','00001s'),(2,'0002code','f330f7','e4c9a8'),(3,'0003code','f32825','4c9a89')
insert into sharding_4_t1 values(1,'0001code'),(2,'0002code'),(3,'0003code')
insert into sharding_4_t2 values(1,'0001code','0001ck','0001pre'),(2,'0002code','0002ck','0002pre'),(3,'0003code','0003ck','0003pre')
SELECT t2.pre,t2.ck, COUNT(*) AS count FROM sharding_4_t1 t1 INNER JOIN sharding_4_t2 t2 ON t1.code = t2.code INNER JOIN (SELECT id, a_id FROM global_4_t1 WHERE q_id = 'f330f7' AND s_id = 'e4c9a8') t3 ON t1.id = t3.a_id INNER JOIN (SELECT id, a_id FROM global_4_t1 WHERE q_id = 'f32825' AND s_id = '4c9a89') t4 ON t1.id = t4.a_id GROUP BY t2.pre, t2.ck
drop table if exists global_4_t1
drop table if exists sharding_4_t1
drop table if exists sharding_4_t2