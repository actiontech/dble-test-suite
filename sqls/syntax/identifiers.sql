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


