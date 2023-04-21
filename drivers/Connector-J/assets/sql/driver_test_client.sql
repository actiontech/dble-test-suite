use schema1;
drop table if exists test_shard;
drop table if exists test1;
drop table if exists schema2.test2;
drop table if exists schema3.test3;
drop view if exists view_test;
drop view if exists view_test1;
CREATE TABLE schema2.test2(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(40) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8;
CREATE TABLE schema3.test3(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(40) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8;
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(40) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8;
create table test_shard (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),t datetime,b bool)DEFAULT CHARSET=UTF8;
CREATE UNIQUE INDEX idx_id USING BTREE ON schema2.test2 (id,pad(3) ASC);
insert into schema2.test2 values(1,1,'test中id为1',1),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6);
insert into schema3.test3 values(1,1,'order中id为1',1),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1);
insert into test1 values(1,1,'manager中id为1',1),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6);
insert into test_shard (id,R_REGIONKEY,R_NAME,t,b) values (1,1, 'a string','2012/12/31 11:30:45',0),(2,2, 'a string','2012/12/31 11:30:45',0),(5,5, 'a string','2018/12/03 11:30:45',0);
#insert into test_shard (id,R_REGIONKEY,R_NAME,t,b) values (3,3, 'a string','2012/12/31 11:30:45',0),(4,4, 'a string','2012/12/31 11:30:45',0),(null,null, null,null,null);
select * from test_shard where R_NAME=_utf8'中'COLLATE utf8_danish_ci;
explain select * from schema2.test2 where id=1;
explain2 shardingNode=dn2 sql=select * from test_shard where id=1;
/*!40102 SET character_set_client = gbk*/;
/*!40101 SET character_set_client = utf8*/;
/*40101%%%%%????&&&**djdjj*/;
/*dfghdfgh*/;
select (@aa:=id) AS a, (@aa+3) AS b from test_shard where R_NAME=(select CHARSET(X'4D7953514C'));
select schema1.test_shard.R_NAME from test_shard;
select * from test_shard where exists(select * from test_shard where id=1||id=3) order by id;
select * from test_shard where DATE_SUB(CURDATE(),INTERVAL 30 DAY)=2017-08-13;
select * from test_shard where id= (b'01' | B'11');
select * from test_shard where b'1000001'  in (select R_NAME from test_shard where id =18);
select * from test_shard where HEX(R_NAME) not between 0b11+0 and (select HEX(R_NAME) from test_shard where HEX(R_NAME) not in (select HEX(R_NAME) from test_shard where id <4));
select * from test_shard where HEX(R_NAME) like (select '%A%') escape (select '%') and HEX(R_NAME) not like (select '%A%');
select * from test_shard where false <> (select HEX(R_NAME) from test_shard where HEX(R_NAME)  not regexp '^A' limit 1 ) order by id;
select * from test_shard where !(true is not true) order by id;
select count(distinct id),sum(distinct R_NAME), R_REGIONKEY from test_shard where id=3 or id=7 group by R_REGIONKEY;
select * from test_shard where id>(SELECT ABS(2)) order by id limit 1 offset 1;
select pad,count(id) t from schema2.test2 group by pad having t>1;
select pad,count(id) t from schema2.test2 group by pad with rollup;
select * from test_shard order by id lock in share mode;
select * from test_shard where id=2 for update;
select a.id,b.id,b.pad,a.t_id from (select schema2.test2.id,schema2.test2.pad,schema2.test2.t_id from schema2.test2 join schema3.test3 where schema2.test2.pad=schema3.test3.pad ) a,(select test1.id,test1.pad from schema2.test2 join test1 where schema2.test2.pad=test1.pad) b where a.pad=b.pad order by a.id;
select * from schema2.test2 a join (select * from schema3.test3 where pad>2) b on a.id<b.id and a.pad=b.pad order by a.id,b.id;
select * from schema2.test2 a join (select * from schema3.test3 where pad>2) b  using(pad) order by a.id,b.id;
select * from (select * from schema2.test2 where pad>0) a straight_join (select * from schema3.test3 where pad>0) b order by a.id,b.id;
select * from (select * from schema2.test2 where pad>1) a left outer join (select * from schema3.test3 where pad>3 group by pad) b on a.pad=b.pad order by a.id,b.id;
select * from (select * from schema2.test2 where pad>1) a right outer join (select * from schema3.test3 where pad>3) b on a.pad=b.pad order by a.id,b.id;
select * from (select * from schema2.test2 where pad>1) a natural left outer join (select * from schema3.test3 where pad>3) b order by a.id,b.id;
select * from (select * from schema2.test2 where pad>1) a natural right outer join (select * from schema3.test3 where pad>3) b order by a.id,b.id;
SELECT DISTINCT schema2.test2.id FROM schema2.test2,schema3.test3 where schema2.test2.pad=schema3.test3.pad order by schema2.test2.id;
select * from schema2.test2 a left join schema3.test3 b on a.pad=b.pad where a.t_id>b.o_id group by b.pad;
(select name from schema2.test2 where pad=1 order by id limit 10) union all (select name from schema3.test3 where pad=1 order by id limit 10) order by name;
(select name from schema2.test2 where pad=1 order by id limit 10) union distinct (select name from schema3.test3 where pad=1 order by id limit 10) order by name;
select a.id,b.id,c.pad from schema2.test2 a,schema3.test3 b,test1 c where a.id=b.id and a.id=c.pad;
create view view_test1 as select * from schema2.test2 where id=1;
create or replace view view_test1 as select * from schema2.test2 where id >3;
select * from view_test1  order by id;
create or replace view view_test as select * from schema2.test2;
alter view view_test as select * from schema3.test3;
select * from view_test order by id;
load data local infile "./test1.txt" into table schema2.test2 fields terminated by ',' lines terminated by '\n';
ALTER TABLE schema2.test2 ADD COLUMN name3 CHAR(5) FIRST,ADD COLUMN name4 CHAR(5) AFTER  t_id;
ALTER TABLE schema2.test2 DROP column name3,DROP column name4;
ALTER TABLE schema2.test2 ADD INDEX idx (id ASC,R_NAME(2) DESC);
#ALTER TABLE schema2.test2 DROP KEY k_1;
ALTER TABLE schema2.test2 DROP PRIMARY KEY;
ALTER TABLE schema2.test2 ADD PRIMARY KEY USING HASH (id);
ALTER TABLE schema2.test2 DROP PRIMARY KEY;
ALTER TABLE schema2.test2 ADD CONSTRAINT pK_id PRIMARY KEY (id);
ALTER TABLE schema2.test2 DROP PRIMARY KEY;
ALTER TABLE schema2.test2 ADD UNIQUE KEY uk_id (id ASC,pad DESC);
ALTER TABLE schema2.test2 DROP KEY uk_id;
ALTER TABLE schema2.test2 CHANGE name ID1 varchar(40)  NOT NULL DEFAULT 10 COMMENT 'my column1';
ALTER TABLE schema2.test2 CHANGE ID1 name char(40) NOT NULL DEFAULT '';
ALTER TABLE schema2.test2 MODIFY COLUMN ID1 BIGINT UNSIGNED UNIQUE DEFAULT 1 COMMENT 'my column2' AFTER pad;
SHOW CREATE TABLE schema2.test2;
SHOW INDEX FROM schema2.test2;/*allow_diff*/
DESC schema2.test2;
#DROP INDEX idx_id ON schema2.test2;
lock tables schema2.test2 write;
unlock tables;
lock tables schema2.test2 read;
unlock tables;
show full columns from schema2.test2 from schema2 where field like 'o%';
show full tables in schema1 where table_type like 'base%';
show open tables from schema1 like 'aly_o%';
show index from schema2.test2 in schema2;/*allow_diff*/
show keys in schema2.test2 from schema2;/*allow_diff*/
show databases;/*allow_diff*/
replace into schema2.test2 values (1,1,'test中id为1',1);
truncate table schema2.test2;
delete from schema2.test2;
#/*charset*/
drop table if exists test_shard;
CREATE TABLE test_shard ( id long,c1 CHAR(1) CHARACTER SET latin1, c2 CHAR(1) CHARACTER SET ascii,`c3` char(10) CHARACTER SET gbk, c4 char(10) character set utf8) DEFAULT CHARSET=utf8;
INSERT INTO test_shard VALUES (11111,'a','b','你','我');
SELECT CONCAT(c1, c2),c3 FROM test_shard;
set names 'utf8';
SELECT CONCAT(c1, c2),c3 FROM test_shard;
#statement
prepare stmt from 'insert into schema2.test2 values(111,111,"test中id为1",111)';
execute stmt;
select * from schema2.test2;
drop prepare stmt;
prepare stmt from "insert into schema2.test2 values(111,111,'test中id为1',111)";
execute stmt;
select * from schema2.test2;
drop prepare stmt;
prepare stmt from 'insert into schema2.test2 values(111,111,\'test中id为1\',111)'
execute stmt;
select * from schema2.test2;
drop prepare stmt;
prepare stmt from 'select * from schema2.test2 where id=?';
set @b=1;
execute stmt using @b;
drop prepare stmt;
#transaction
SET @@session.autocommit = ON;
update schema2.test2 set name = 'aa' where id between 2 and 3;
SET @@session.autocommit = 0;
start transaction;
insert into schema2.test2 value(20,20,"20",20);
commit;
begin;
update schema2.test2 set pad=10;
rollback;
drop table test_shard;
drop table schema2.test2;
drop table schema3.test3;
drop table test1;
drop table if exists schema1.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl;
create table schema1.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl(id int);
set @abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl='schema1';
drop table schema1.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl;
#show @@connection
#kill conn_id