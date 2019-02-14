#!default_db:schema1
#LOCK
lock tables sharding_4_t1 read
unlock tables
#reserved words
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
create table schema1.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl(id int)
drop table if exists schema1.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl
drop table if exists sharding_4_t1
create table sharding_4_t1(id int(8))
alter table sharding_4_t1 add abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl varchar(10)
create index abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl on sharding_4_t1(id)
drop index abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl on sharding_4_t1
drop table if exists parent
drop table if exists child
CREATE TABLE parent (id INT NOT NULL,PRIMARY KEY (id)) ENGINE=INNODB
CREATE TABLE child (id INT, parent_id INT,INDEX par_ind (parent_id)) ENGINE=INNODB
create view abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl as select * from sharding_4_t1
drop view abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl
drop view if exists abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklm
create view abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklm as select * from sharding_4_t1
select 1 as abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl
select 2 as abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklm
set @abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl='schema1'

#identifier
select id from sharding_4_t1
select sharding_4_t1.id from sharding_4_t1
select `sharding_4_t1`.`id` from sharding_4_t1
select sharding_4_t1.`id` from sharding_4_t1
select schema1.sharding_4_t1.id from sharding_4_t1
select `schema1`.`sharding_4_t1`.`id` from sharding_4_t1
select id from .sharding_4_t1
drop table sharding_4_t1
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
drop table if exists schema1.interval
CREATE TABLE schema1.interval (begin INT, end INT)
#!share_conn
drop table if exists t
create table t(c1 int)
insert into t values(1),(2),(3)
SET @c = "c1"
SET @s = CONCAT("SELECT ", @c, " FROM t")
PREPARE stmt FROM @s
EXECUTE stmt
DEALLOCATE PREPARE stmt
#!share_conn
set sql_mode=PIPES_AS_CONCAT
select 'a'||'b'
select not ! 1
#!share_conn
set sql_mode=HIGH_NOT_PRECEDENCE
select ! not 1
select not ! 1
#case for key words as identifier
#!share_conn
drop table if exists `drop`
create table .drop(`order` int, `add` int)
insert into `drop`(`order`, `add`) values(1,1)
insert into .drop(drop.order, drop.add) values(1,1)
insert into .drop(.drop.order, .drop.add) values(1,1)
insert into .drop(schema1.drop.order, schema1.drop.add) values(1,1)
select `order` from .drop
select drop.order from .drop order by `add`
select drop.order from .drop order by drop.add
select drop.order from .drop order by .drop.add