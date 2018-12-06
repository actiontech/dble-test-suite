use mytest;
drop table if exists test_shard;
drop table if exists a_manager;
drop table if exists aly_test;
drop table if exists aly_order;
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(40) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8;
CREATE TABLE aly_order(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(40) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8;
CREATE TABLE a_manager(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(40) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8;
create table test_shard (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),t datetime,b bool)DEFAULT CHARSET=UTF8;
CREATE UNIQUE INDEX idx_id USING BTREE ON aly_test (id,pad(3) ASC);
insert into aly_test values(1,1,'test中id为1',1),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6);
insert into aly_order values(1,1,'order中id为1',1),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1);
insert into a_manager values(1,1,'manager中id为1',1),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6);
insert into test_shard (id,R_REGIONKEY,R_NAME,t,b) values (1,1, 'a string','2012/12/31 11:30:45',0),(2,2, 'a string','2012/12/31 11:30:45',0),(5,5, 'a string','2018/12/03 11:30:45',0);
#insert into test_shard (id,R_REGIONKEY,R_NAME,t,b) values (3,3, 'a string','2012/12/31 11:30:45',0),(4,4, 'a string','2012/12/31 11:30:45',0),(null,null, null,null,null);
select * from test_shard where R_NAME=_utf8'中'COLLATE utf8_danish_ci;
explain SELECT select * from aly_test where id=1;
explain2 datanode=dn2 sql=select * from test_shard where id=1;
help;
/*!40101 SET character_set_client = utf8*/;
/*!40102 SET character_set_client = gbk*/;
/*40101%%%%%????&&&**djdjj*/;
/*dfghdfgh*/;
select (@aa:=id) AS a, (@aa+3) AS b from test_shard where R_NAME=(select CHARSET(X'4D7953514C'));
select mytest.test_shard.R_NAME from test_shard;
select * from test_shard where exists(select * from test_shard where id=1||id=3);
select * from test_shard where DATE_SUB(CURDATE(),INTERVAL 30 DAY)=2017-08-13;
select * from test_shard where id= (b'01' | B'11');
select * from test_shard where b'1000001'  in (select R_NAME from test_shard where id =18);
select * from test_shard where HEX(R_NAME) not between 0b11+0 and (select HEX(R_NAME) from test_shard where HEX(R_NAME) not in (select HEX(R_NAME) from test_shard where id <4));
select * from test_shard where HEX(R_NAME) like (select '%A%') escape (select '%') and HEX(R_NAME) not like (select '%A%');
select * from test_shard where false <> (select HEX(R_NAME) from test_shard where HEX(R_NAME)  not regexp '^A' limit 1 );
select * from test_shard where !(true is not true);
select count(distinct id),sum(distinct R_NAME), R_REGIONKEY from test_shard where id=3 or id=7 group by R_REGIONKEY;
select * from test_shard where id>(SELECT ABS(2)) order by id limit 1 offset 1;
select pad,count(id) t from aly_test group by pad having t>1;
select pad,count(id) t from aly_test group by pad with rollup;
select * from test_shard order by id lock in share mode;
select * from test_shard where id=2 for update;
select a.id,b.id,b.pad,a.t_id from (select aly_test.id,aly_test.pad,aly_test.t_id from aly_test join aly_order where aly_test.pad=aly_order.pad ) a,(select a_manager.id,a_manager.pad from aly_test join a_manager where aly_test.pad=a_manager.pad) b where a.pad=b.pad;
select * from aly_test a join (select * from aly_order where pad>2) b on a.id<b.id and a.pad=b.pad order by a.id,b.id;
select * from aly_test a join (select * from aly_order where pad>2) b  using(pad) order by a.id,b.id;
select * from (select * from aly_test where pad>0) a straight_join (select * from aly_order where pad>0) b order by a.id,b.id;
select * from (select * from aly_test where pad>1) a left outer join (select * from aly_order where pad>3 group by pad) b on a.pad=b.pad order by a.id,b.id;
select * from (select * from aly_test where pad>1) a right outer join (select * from aly_order where pad>3) b on a.pad=b.pad order by a.id,b.id;
select * from (select * from aly_test where pad>1) a natural left outer join (select * from aly_order where pad>3) b order by a.id,b.id;
select * from (select * from aly_test where pad>1) a natural right outer join (select * from aly_order where pad>3) b order by a.id,b.id;
SELECT DISTINCT aly_test.id FROM aly_test,aly_order where aly_test.pad=aly_order.pad;
select * from aly_test a left join aly_order b on a.pad=b.pad where a.t_id>b.o_id group by b.pad;
(select name from aly_test where pad=1 order by id limit 10) union all (select name from aly_order where pad=1 order by id limit 10); --/*allow_diff_sequence*/
(select name from aly_test where pad=1 order by id limit 10) union distinct (select name from aly_order where pad=1 order by id limit 10); --/*allow_diff_sequence*/
select a.id,b.id,c.pad from aly_test a,aly_order b,a_manager c where a.id=b.id and a.id=c.pad;
create view view_test1 as select * from aly_test where id=1;
replace view view_test1 as select * from aly_test where id >3;
select * from view_test1;
create or replace view view_test as select * from aly_test;
alter view view_test as select * from aly_order;
select * from view_test;
drop view view_test;
load data local infile "./test1.txt" into table aly_test fields terminated by ',' lines terminated by '\n';
ALTER TABLE aly_test ADD COLUMN name3 CHAR(5) FIRST,ADD COLUMN name4 CHAR(5) AFTER  t_id;
ALTER TABLE aly_test DROP column name3,DROP column name4;
ALTER TABLE aly_test ADD INDEX idx (id ASC,R_NAME(2) DESC);
#ALTER TABLE aly_test DROP KEY k_1;
ALTER TABLE aly_test DROP PRIMARY KEY;
ALTER TABLE aly_test ADD PRIMARY KEY USING HASH (id);
ALTER TABLE aly_test DROP PRIMARY KEY;
ALTER TABLE aly_test ADD CONSTRAINT pK_id PRIMARY KEY (id);
ALTER TABLE aly_test DROP PRIMARY KEY;
ALTER TABLE aly_test ADD UNIQUE KEY uk_id (id ASC,pad DESC);
ALTER TABLE aly_test DROP KEY uk_id;
ALTER TABLE aly_test CHANGE name ID1 varchar(40)  NOT NULL DEFAULT 10 COMMENT 'my column1';
ALTER TABLE aly_test CHANGE ID1 name char(40) NOT NULL DEFAULT '';
ALTER TABLE aly_test MODIFY COLUMN ID1 BIGINT UNSIGNED UNIQUE DEFAULT 1 COMMENT 'my column2' AFTER pad;
SHOW CREATE TABLE aly_test;
SHOW INDEX FROM aly_test;
DESC aly_test;
#DROP INDEX idx_id ON aly_test;
lock tables aly_test write;
unlock tables;
lock tables aly_test read;
unlock tables;
show full columns from aly_test from mytest where field like 'o%';
show full tables in mytest where table_type like 'base%';
show open tables from mytest like 'aly_o%';
show index from aly_test in mytest;
show keys in aly_test from mytest;
show databases;
replace into aly_test values (1,1,'test中id为1',1);
truncate table aly_test;
delete from aly_test;
/*charset*/
drop table if exists test_shard;
CREATE TABLE test_shard ( id long,c1 CHAR(1) CHARACTER SET latin1, c2 CHAR(1) CHARACTER SET ascii,`c3` char(10) CHARACTER SET gbk, c4 char(10) character set utf8) DEFAULT CHARSET=utf8;
INSERT INTO test_shard VALUES (11111,'a','b','你','我');
SELECT CONCAT(c1,c2),c3 FROM test_shard;
set names 'utf8';
SELECT CONCAT(c1,c2),c3 FROM test_shard;
#statement
prepare stmt from 'insert into aly_test values(111,111,"test中id为1",111)';
execute stmt;
select * from aly_test;
drop prepare stmt;
prepare stmt from 'select * from aly_test where id=?';
set @b=1;
execute stmt using @b;
drop prepare stmt;
#transaction
SET @@session.autocommit = ON;
update aly_test set name = 'aa' where id between 2 and 3;
SET @@session.autocommit = 0;
start transaction;
insert into aly_test value(20,20,"20",20);
commit;
begin;
update aly_test set pad=10;
rollback;
drop table test_shard;
drop table aly_test;
drop table aly_order;
drop table a_manager;
drop table if exists mytest.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl;
create table mytest.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl(id int);
set @abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl='mytest';
drop table mytest.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl;
#show @@connection
#kill conn_id