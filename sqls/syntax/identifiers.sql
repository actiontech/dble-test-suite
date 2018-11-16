DROP TABLE IF EXISTS aly_test_1_1
DROP TABLE IF EXISTS aly_test_1_2
CREATE TABLE aly_test_1_1 (id INT NOT NULL PRIMARY KEY, data VARCHAR(50))
CREATE TABLE aly_test_1_2 (id INT NOT NULL PRIMARY KEY, data VARCHAR(50))
drop table if exists a_test_1_2_3
drop table if exists a_order_1_2_3
drop table if exists a_manager_1_2_3
CREATE TABLE a_test_1_2_3(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_order_1_2_3(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_manager_1_2_3(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into a_test_1_2_3 values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into a_order_1_2_3 values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_manager_1_2_3 values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
#INSERT
insert into aly_test_1_1 (id,data) values(1,'test1'),(2,'test2'),(3,'test3')
insert into aly_test_1_2 (id,data) values(1,'a')
insert into aly_test_1_2 set id = 2,data='b'
insert into aly_test_1_2 values (2,'b') ON DUPLICATE KEY UPDATE data='bb'
insert LOW_PRIORITY into aly_test_1_2 (id,data) value (6,'e')
insert DELAYED into aly_test_1_2 (id,data) value (7,'f')
insert HIGH_PRIORITY into aly_test_1_2 (id,data) value (8,'g')
insert IGNORE into aly_test_1_2 (id,data) value (9,'h')
select * from aly_test_1_2
#REPLACE
replace into aly_test_1_2 values (3, 'c')
replace into aly_test_1_2 set id = 1+3, data='d'
replace into aly_test_1_2 set id=5,data=default
replace aly_test_1_2 select * from aly_test_1_1 where id =1
select * from aly_test_1_2
#SELECT
select * from aly_test_1_2 order by id limit 4
select id,data from aly_test_1_2 order by id limit 4
select distinct id from aly_test_1_2 limit 4
select * from aly_test_1_2 order by id limit 1,1
select * from aly_test_1_2 order by id limit 2,3
select id,data from aly_test_1_2 group by id,data order by id,data limit 2,3
select a.id,b.id,b.pad,a.t_id from (select a_test_1_2_3.id,a_test_1_2_3.pad,a_test_1_2_3.t_id from a_test_1_2_3 join a_order_1_2_3 where a_test_1_2_3.pad=a_order_1_2_3.pad ) a,(select a_manager_1_2_3.id,a_manager_1_2_3.pad from a_test_1_2_3 join a_manager_1_2_3 where a_test_1_2_3.pad=a_manager_1_2_3.pad) b where a.pad=b.pad limit 4
select * from a_test_1_2_3 a join a_order_1_2_3 as b order by a.id,b.id limit 4
select * from a_test_1_2_3 a inner join a_order_1_2_3 b order by a.id,b.id limit 4
select * from a_test_1_2_3 a cross join a_order_1_2_3 b order by a.id,b.id limit 4
select * from a_test_1_2_3 a straight_join (select * from a_order_1_2_3 where pad>0) b on a.id<b.id and a.pad=b.pad order by a.id,b.id limit 4
select * from a_test_1_2_3 a left join (select * from a_order_1_2_3 where pad>2) b on a.pad=b.pad order by a.id,b.id limit 4
select * from a_test_1_2_3 a right join (select * from a_order_1_2_3 where pad>2) b on a.pad=b.pad order by a.id,b.id limit 4
select * from (select * from a_test_1_2_3 where pad>1) a natural left join (select * from a_order_1_2_3 where pad>3) b order by a.id,b.id limit 4
select * from (select * from a_test_1_2_3 where pad>1) a natural right join (select * from a_order_1_2_3 where pad>3) b order by a.id,b.id limit 4
select * from (select * from a_test_1_2_3 where pad>1) a natural left outer join (select * from a_order_1_2_3 where pad>3) b order by a.id,b.id limit 4
select * from (select * from a_test_1_2_3 where pad>1) a natural right outer join (select * from a_order_1_2_3 where pad>3) b order by a.id,b.id limit 4
(select name from a_test_1_2_3 where pad=1 order by id limit 10) union all (select name from a_order_1_2_3 where pad=1 order by id limit 10)
(select name from a_test_1_2_3 where pad=1 order by id limit 10) union distinct (select name from a_order_1_2_3 where pad=1 order by id limit 10)
(select * from a_test_1_2_3 where pad=1) union (select * from a_order_1_2_3 where pad=1) order by name limit 10
(select name as sort_a from a_test_1_2_3 where pad=1) union (select name from a_order_1_2_3 where pad=1) order by sort_a limit 10
(select name as sort_a,pad from a_test_1_2_3 where pad=1) union (select name,pad from a_order_1_2_3 where pad=1) order by sort_a,pad limit 10

#UPDATE
update aly_test_1_2 set data = 'aa' where id =1
update aly_test_1_2 set id=id+10
update aly_test_1_2 set data=DEFAULT where id>13
select * from aly_test_1_2
update aly_test_1_2 set data='test1' where id in (13,14)
update aly_test_1_2 set data='test2' where id between 11 and 13
update aly_test_1_2 set id = 401 WHERE data LIKE '%t1%'
select * from aly_test_1_2
#LOCK
lock tables aly_test_1_2 read
unlock tables
#clear tables
DROP TABLE IF EXISTS aly_test_1_1
drop table if exists aly_test_1_2
drop table if exists a_test_1_2_3
drop table if exists a_order_1_2_3
drop table if exists a_manager_1_2_3
#sql_mode
#mytest Object Names
create table mytest.tb(a int(4))
alter table tb add 01a boolean
alter table tb drop column tb.01a
alter table tb add `011` boolean
alter table tb add $ boolean
alter table tb add _ boolean
alter table tb add abcABC varchar(1)
alter table tb add abc89ABC varchar(1)
alter table tb add `select` int(4)
desc tb
drop table tb
create table `select`(id int(20))
insert into `select` values(1)
select id from `select` where `select`.id = 1
drop table `select`
#!share_conn
set sql_mode='ANSI_QUOTES'
select 'hello dble'
select 1 AS `one`, 2 AS 'two', 3 as "three"
create table `tb1` (col INT)
create table "tb2" (col INT)
drop table if exists `tb1`
drop table if exists "tb2"
#max identifier length
create table mytest.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl(id int)
drop table if exists mytest.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl
create table tb(id int(8))
alter table tb add abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl varchar(10)
create index abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl on tb(id)
drop index abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl on tb
drop table if exists parent
drop table if exists child
CREATE TABLE parent (id INT NOT NULL,PRIMARY KEY (id)) ENGINE=INNODB
CREATE TABLE child (id INT, parent_id INT,INDEX par_ind (parent_id)) ENGINE=INNODB
create view abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl as select * from tb
drop view abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl
drop view if exists abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklm
create view abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklm as select * from tb
select 1 as abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl
select 2 as abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklm
set @abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl='mytest'

#identifier
select id from tb
select tb.id from tb
select `tb`.`id` from tb
select tb.`id` from tb
select mytest.tb.id from tb
select `mytest`.`tb`.`id` from tb
select id from .tb
drop table tb
#use system function name as table name
drop table if EXISTS ADDDATE
create table ADDDATE (i int)
drop table if EXISTS BIT_AND
create table BIT_AND (i int)
drop table if EXISTS BIT_OR
create table BIT_OR (i int)
drop table if EXISTS BIT_XOR
create table BIT_XOR (i int)
drop table if EXISTS CAST
create table CAST (i int)
drop table if EXISTS CURDATE
create table CURDATE (i int)
drop table if EXISTS CURTIME
create table CURTIME (i int)
drop table if EXISTS DATE_ADD
create table DATE_ADD (i int)
drop table if EXISTS DATE_SUB
create table DATE_SUB (i int)
drop table if EXISTS EXTRACT
create table EXTRACT (i int)
drop table if EXISTS GROUP_CONCAT
create table GROUP_CONCAT (i int)
drop table if EXISTS MAX
create table MAX (i int)
drop table if EXISTS MID
create table MID (i int)
drop table if EXISTS MIN
create table MIN (i int)
drop table if EXISTS NOW
create table NOW (i int)
drop table if EXISTS POSITION
create table POSITION (i int)
drop table if EXISTS SESSION_USER
create table SESSION_USER (i int)
drop table if EXISTS STD
create table STD (i int)
drop table if EXISTS STDDEV
create table STDDEV (i int)
drop table if EXISTS STDDEV_POP
create table STDDEV_POP (i int)
drop table if EXISTS STDDEV_SAMP
create table STDDEV_SAMP (i int)
drop table if EXISTS SUBDATE
create table SUBDATE (i int)
drop table if EXISTS SUBSTR
create table SUBSTR (i int)
drop table if EXISTS SUBSTRING
create table SUBSTRING (i int)
drop table if EXISTS SUM
create table SUM (i int)
drop table if EXISTS SYSDATE
create table SYSDATE (i int)
drop table if EXISTS SYSTEM_USER
create table SYSTEM_USER (i int)
drop table if EXISTS TRIM
create table TRIM (i int)
drop table if EXISTS VARIANCE
create table VARIANCE (i int)
drop table if EXISTS VAR_POP
create table VAR_POP (i int)
drop table if EXISTS VAR_SAMP
create table VAR_SAMP (i int)
drop table if EXISTS ADDDATE
create table ADDDATE(i int)
drop table if EXISTS count
create table `count`(id int)
SELECT COUNT(*) FROM count
drop table if EXISTS ascii
create table ascii(i INT)
drop table ascii
create table ascii (i INT)
drop table ascii
#!share_conn IGNORE_SPACE, system function name can be used as table name
SET sql_mode = 'IGNORE_SPACE'
drop table if exists count
create table `count`(id int)
drop table if exists count
#reserved words can not be used as table name
drop table if exists `interval`
CREATE TABLE `interval` (begin INT, end INT)
drop table if exists mytest.interval
CREATE TABLE mytest.interval (begin INT, end INT)
#!share_conn
drop table if exists t
create table t(c1 int)
insert into t values(1),(2),(3)
SET @c = "c1"
SET @s = CONCAT("SELECT ", @c, " FROM t")
PREPARE stmt FROM @s
EXECUTE stmt
DEALLOCATE PREPARE stmt
#Expression Syntax
select 1 OR 0
select 1 || 0
select 1 XOR 0
select 1 AND 0
select 1 && 0
select NOT 1
select !1
select 1 IS TRUE
select 1 IS FALSE
select 1 IS NOT FALSE
select @undefined_uv IS UNKNOWN
create table left_tbl(id int)
insert into left_tbl values(1),(2),(3)
create table right_tbl(id int)
insert into right_tbl values(2),(3),(4)
SELECT left_tbl.* FROM { OJ left_tbl LEFT OUTER JOIN right_tbl ON left_tbl.id = right_tbl.id } WHERE right_tbl.id IS NULL
drop table left_tbl
drop table right_tbl
select 'a'||'b'
select 1/0
#!share_conn
set sql_mode=PIPES_AS_CONCAT
select 'a'||'b'
select not ! 1
#!share_conn
set sql_mode=HIGH_NOT_PRECEDENCE
select ! not 1
select not ! 1
#others select...into,load data infile...
drop table if EXISTS mytest.company_user
CREATE TABLE IF NOT EXISTS mytest.company_user(id int(10) UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY, username VARCHAR(24) NOT NULL UNIQUE, password VARCHAR(8) NOT NULL,company_name VARCHAR(250) NOT NULL UNIQUE, company_type VARCHAR(30) NOT NULL,  company_intro TEXT,  office_image TEXT, register_date DATE NOT NULL)ENGINE=InnoDB DEFAULT CHARSET utf8 COLLATE utf8_general_ci
insert into mytest.company_user values (1, 'user1', '111111', 'action co.', 'limited', 'a company about managing database', NULL, 20131231)
drop table if EXISTS tb_outfile
create table mytest.tb_outfile like mytest.company_user
load data infile '/tmp/outfile.txt' into table mytest.tb_outfile FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'
select id, username from tb_outfile PROCEDURE ANALYSE(1, 1000)
#case for key words as identifier
#!share_conn
drop table if exists `drop`
create table .drop(`order` int, `add` int)
insert into `drop`(`order`, `add`) values(1,1)
insert into .drop(drop.order, drop.add) values(1,1)
insert into .drop(.drop.order, .drop.add) values(1,1)
insert into .drop(mytest.drop.order, mytest.drop.add) values(1,1)
select `order` from .drop
select drop.order from .drop order by `add`
select drop.order from .drop order by drop.add
select drop.order from .drop order by .drop.add