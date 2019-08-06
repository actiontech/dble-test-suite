#!default_db:schema1
#
#join syntax
#
drop table if exists sharding_4_t1
drop table if exists schema2.sharding_4_t2
drop table if exists schema3.sharding_4_t3
CREATE TABLE sharding_4_t1(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE schema2.sharding_4_t2(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE schema3.sharding_4_t3(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into sharding_4_t1 values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into schema2.sharding_4_t2 values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into schema3.sharding_4_t3 values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
#
#join table
#
select * from sharding_4_t1 a,schema2.sharding_4_t2 b
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select schema3.sharding_4_t3.id,schema3.sharding_4_t3.pad from sharding_4_t1 join schema3.sharding_4_t3 where sharding_4_t1.pad=schema3.sharding_4_t3.pad) b,(select * from schema2.sharding_4_t2 where id>3) c where a.pad=b.pad and c.pad=b.pad
select * from sharding_4_t1 a join schema2.sharding_4_t2 as b order by a.id,b.id
select * from sharding_4_t1 a inner join schema2.sharding_4_t2 b order by a.id,b.id
select * from sharding_4_t1 a cross join schema2.sharding_4_t2 b order by a.id,b.id
select a.id,a.name,a.pad,b.name from sharding_4_t1 a straight_join schema2.sharding_4_t2 b on a.pad=b.pad
select * from sharding_4_t1,schema2.sharding_4_t2 where sharding_4_t1.pad=schema2.sharding_4_t2.pad
select * from sharding_4_t1 a,schema2.sharding_4_t2 b where a.pad=b.pad
select distinct sharding_4_t1.id from sharding_4_t1,schema2.sharding_4_t2 where sharding_4_t1.pad=schema2.sharding_4_t2.pad
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select * from schema2.sharding_4_t2 where pad>3) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select id,t_id from sharding_4_t1) a,(select * from schema2.sharding_4_t2) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select sharding_4_t1.id,sharding_4_t1.pad,sharding_4_t1.t_id from sharding_4_t1 join schema2.sharding_4_t2 where sharding_4_t1.pad=schema2.sharding_4_t2.pad ) a,(select schema3.sharding_4_t3.id,schema3.sharding_4_t3.pad from sharding_4_t1 join schema3.sharding_4_t3 where sharding_4_t1.pad=schema3.sharding_4_t3.pad) b where a.pad=b.pad
select sharding_4_t1.id,sharding_4_t1.name,a.name from sharding_4_t1,(select name from schema2.sharding_4_t2) a
#
# inner join /cross join/join 
#
select * from sharding_4_t1 inner join schema2.sharding_4_t2 order by sharding_4_t1.id,schema2.sharding_4_t2.id
select * from sharding_4_t1 cross join schema2.sharding_4_t2 order by sharding_4_t1.id,schema2.sharding_4_t2.id
select * from sharding_4_t1 join schema2.sharding_4_t2 order by sharding_4_t1.id,schema2.sharding_4_t2.id
select a.id,a.name,a.pad,b.name from sharding_4_t1 a inner join schema2.sharding_4_t2 b order by a.id,b.id
select a.id,a.name,a.pad,b.name from sharding_4_t1 a cross join schema2.sharding_4_t2 b order by a.id,b.id
select a.id,a.name,a.pad,b.name from sharding_4_t1 a join schema2.sharding_4_t2 b order by a.id,b.id
select * from sharding_4_t1 a inner join (select * from schema2.sharding_4_t2 where pad>2) b order by a.id,b.id
select * from sharding_4_t1 a cross join (select * from schema2.sharding_4_t2 where pad>2) b order by a.id,b.id
select * from sharding_4_t1 a join (select * from schema2.sharding_4_t2 where pad>2) b order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>2) a inner join (select * from schema2.sharding_4_t2 where pad>2) b order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>2) a cross join (select * from schema2.sharding_4_t2 where pad>2) b order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>2) a join (select * from schema2.sharding_4_t2 where pad>2) b order by a.id,b.id
select * from sharding_4_t1 a join (select * from schema2.sharding_4_t2 where pad>2) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select * from sharding_4_t1 a join (select * from schema2.sharding_4_t2 where pad>2) b  using(pad) order by a.id,b.id
select * from sharding_4_t1 a join schema2.sharding_4_t2 as b order by a.id,b.id
select * from sharding_4_t1 a inner join schema2.sharding_4_t2 b order by a.id,b.id
select * from sharding_4_t1 a cross join schema2.sharding_4_t2 b order by a.id,b.id
select * from sharding_4_t1 straight_join schema2.sharding_4_t2 order by sharding_4_t1.id,schema2.sharding_4_t2.id
select a.id,a.name,a.pad,b.name from sharding_4_t1 a straight_join schema2.sharding_4_t2 b order by a.id,b.id
#
#straight_join
#
select * from sharding_4_t1 straight_join schema2.sharding_4_t2 order by sharding_4_t1.id,schema2.sharding_4_t2.id
select a.id,a.name,a.pad,b.name from sharding_4_t1 a straight_join schema2.sharding_4_t2 b order by a.id,b.id
select * from sharding_4_t1 a straight_join (select * from schema2.sharding_4_t2 where pad>0) b order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>0) a straight_join (select * from schema2.sharding_4_t2 where pad>0) b order by a.id,b.id
select * from sharding_4_t1 a straight_join (select * from schema2.sharding_4_t2 where pad>0) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select a.id,a.name,a.pad,b.name from sharding_4_t1 a straight_join schema2.sharding_4_t2 b on a.pad=b.pad
#
#left join/right join/outer join
#
select * from sharding_4_t1 left join schema2.sharding_4_t2 on sharding_4_t1.pad=schema2.sharding_4_t2.pad order by sharding_4_t1.id,schema2.sharding_4_t2.id
select * from sharding_4_t1 right join schema2.sharding_4_t2 on sharding_4_t1.pad=schema2.sharding_4_t2.pad order by sharding_4_t1.id,schema2.sharding_4_t2.id
select * from sharding_4_t1 left outer join schema2.sharding_4_t2 on sharding_4_t1.pad=schema2.sharding_4_t2.pad order by sharding_4_t1.id,schema2.sharding_4_t2.id
select * from sharding_4_t1 right outer join schema2.sharding_4_t2 on sharding_4_t1.pad=schema2.sharding_4_t2.pad order by sharding_4_t1.id,schema2.sharding_4_t2.id
select * from sharding_4_t1 left join schema2.sharding_4_t2 using(pad) order by sharding_4_t1.id,schema2.sharding_4_t2.id
select * from sharding_4_t1 a left join schema2.sharding_4_t2 b on a.pad=b.pad order by a.id,b.id
select * from sharding_4_t1 a right join schema2.sharding_4_t2 b on a.pad=b.pad order by a.id,b.id
select * from sharding_4_t1 a left outer join schema2.sharding_4_t2 b on a.pad=b.pad order by a.id,b.id
select * from sharding_4_t1 a right outer join schema2.sharding_4_t2 b on a.pad=b.pad order by a.id,b.id
select * from sharding_4_t1 a left join schema2.sharding_4_t2 b using(pad) order by a.id,b.id
select * from sharding_4_t1 a left join (select * from schema2.sharding_4_t2 where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from sharding_4_t1 a right join (select * from schema2.sharding_4_t2 where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from sharding_4_t1 a left outer join (select * from schema2.sharding_4_t2 where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from sharding_4_t1 a right outer join (select * from schema2.sharding_4_t2 where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from sharding_4_t1 a left join (select * from schema2.sharding_4_t2 where pad>2) b using(pad) order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>1) a left join (select * from schema2.sharding_4_t2 where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>1) a right join (select * from schema2.sharding_4_t2 where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>1) a left outer join (select * from schema2.sharding_4_t2 where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>1) a right outer join (select * from schema2.sharding_4_t2 where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>1) a left join (select * from schema2.sharding_4_t2 where pad>3) b using(pad) order by a.id,b.id
#
#natural left/right/outer join
#
select * from sharding_4_t1 natural left join schema2.sharding_4_t2
select * from sharding_4_t1 natural right join schema2.sharding_4_t2
select * from sharding_4_t1 natural left outer join schema2.sharding_4_t2
select * from sharding_4_t1 natural right outer join schema2.sharding_4_t2
select * from sharding_4_t1 a natural left join schema2.sharding_4_t2 b order by a.id,b.id
select * from sharding_4_t1 a natural right join schema2.sharding_4_t2 b order by a.id,b.id
select * from sharding_4_t1 a natural left outer join schema2.sharding_4_t2 b order by a.id,b.id
select * from sharding_4_t1 a natural right outer join schema2.sharding_4_t2 b order by a.id,b.id
select * from sharding_4_t1 a natural left join (select * from schema2.sharding_4_t2 where pad>2) b order by a.id,b.id
select * from sharding_4_t1 a natural right join (select * from schema2.sharding_4_t2 where pad>2) b order by a.id,b.id
select * from sharding_4_t1 a natural left outer join (select * from schema2.sharding_4_t2 where pad>2) b order by a.id,b.id
select * from sharding_4_t1 a natural right outer join (select * from schema2.sharding_4_t2 where pad>2) b order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>1) a natural left join (select * from schema2.sharding_4_t2 where pad>3) b order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>1) a natural right join (select * from schema2.sharding_4_t2 where pad>3) b order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>1) a natural left outer join (select * from schema2.sharding_4_t2 where pad>3) b order by a.id,b.id
select * from (select * from sharding_4_t1 where pad>1) a natural right outer join (select * from schema2.sharding_4_t2 where pad>3) b order by a.id,b.id
#
#on+and
#
select * from sharding_4_t1 left join schema2.sharding_4_t2 on sharding_4_t1.pad=schema2.sharding_4_t2.pad and sharding_4_t1.id>3 order by sharding_4_t1.id,schema2.sharding_4_t2.id
#
#distinct(special_scene)
#
SELECT DISTINCT sharding_4_t1.id FROM sharding_4_t1,schema2.sharding_4_t2 where sharding_4_t1.pad=schema2.sharding_4_t2.pad
#
#where
#
select  * from sharding_4_t1 a left join schema2.sharding_4_t2 b on a.pad=b.pad where b.pad is null
select  * from sharding_4_t1 a left join schema2.sharding_4_t2 b on a.pad=b.pad where b.pad is not null
select  * from sharding_4_t1 a left join schema2.sharding_4_t2 b on a.pad=b.pad where b.pad in(2,3,null)
select * from sharding_4_t1 a left join schema2.sharding_4_t2 b on a.pad=b.pad where a.t_id>b.o_id
select * from sharding_4_t1 a left join schema2.sharding_4_t2 b on a.pad=b.pad where a.t_id<b.o_id
select * from sharding_4_t1 a left join schema2.sharding_4_t2 b on a.pad=b.pad where a.t_id=b.o_id
select * from sharding_4_t1 a,schema2.sharding_4_t2 b where (a.id<3 && b.id>2)
select * from sharding_4_t1 a,schema2.sharding_4_t2 b where (a.id>1 && b.id<4 && a.pad=b.pad)
select * from sharding_4_t1 a,schema2.sharding_4_t2 b where a.id=b.id
#
#group by/order by
#
select  count(*) from sharding_4_t1 a left join schema2.sharding_4_t2 b on a.pad=b.pad group by b.pad
select * from sharding_4_t1 a left join (select * from schema2.sharding_4_t2 where pad>2 order by id) b on a.pad=b.pad order by a.id
select * from sharding_4_t1 a left join (select pad,count(*) from schema2.sharding_4_t2 group by pad) b on a.pad=b.pad
#
#more than two tables join
#
select a.id,b.id,c.pad from sharding_4_t1 a,schema2.sharding_4_t2 b,schema3.sharding_4_t3 c where a.id=b.id and a.id=c.pad
#
#union
#
select * from sharding_4_t1 union select * from schema2.sharding_4_t2
select * from sharding_4_t1 union all select * from schema2.sharding_4_t2
select * from sharding_4_t1 union distinct select * from schema2.sharding_4_t2
select * from sharding_4_t1 union (select * from schema2.sharding_4_t2)
(select * from sharding_4_t1) union (select * from schema2.sharding_4_t2)
select * from sharding_4_t1 union select * from schema2.sharding_4_t2
(select * from sharding_4_t1 order by id)union select * from schema2.sharding_4_t2/*allow_diff_sequence*/
select * from sharding_4_t1 union (select * from schema2.sharding_4_t2 order by id)/*allow_diff_sequence*/
select * from sharding_4_t1 union select * from schema2.sharding_4_t2 order by id/*allow_diff_sequence*/
(select * from sharding_4_t1) union (select * from schema2.sharding_4_t2) order by name/*allow_diff_sequence*/
(select pad from sharding_4_t1) union distinct (select pad from schema2.sharding_4_t2)
select distinct a.pad from sharding_4_t1 a,schema2.sharding_4_t2 b where a.pad=b.pad
(select * from sharding_4_t1 where id=2) union distinct (select * from schema2.sharding_4_t2 where id=2)
select distinct a.pad from sharding_4_t1 a,schema2.sharding_4_t2 b where a.pad=b.pad
select distinct b.pad,a.pad from sharding_4_t1 a,(select * from schema2.sharding_4_t2 where pad=1) b where a.t_id=b.o_id
select count(distinct pad,name),avg(distinct t_id) from sharding_4_t1
select count(distinct id),sum(distinct name) from sharding_4_t1 where id=3 or id=7
select * from sharding_4_t1 union all select * from schema3.sharding_4_t3 union all select * from schema2.sharding_4_t2
select * from sharding_4_t1 union distinct select * from schema3.sharding_4_t3 union distinct select * from schema2.sharding_4_t2
(select name from sharding_4_t1 where pad=1 order by id limit 10) union all (select name from schema2.sharding_4_t2 where pad=1 order by id limit 10)/*allow_diff_sequence*/
(select name from sharding_4_t1 where pad=1 order by id limit 10) union distinct (select name from schema2.sharding_4_t2 where pad=1 order by id limit 10)/*allow_diff_sequence*/
(select * from sharding_4_t1 where pad=1) union (select * from schema2.sharding_4_t2 where pad=1) order by name limit 10
(select name as sort_a from sharding_4_t1 where pad=1) union (select name from schema2.sharding_4_t2 where pad=1) order by sort_a limit 10
(select name as sort_a,pad from sharding_4_t1 where pad=1) union (select name,pad from schema2.sharding_4_t2 where pad=1) order by sort_a,pad limit 10
select 1 union select 1
(select * from sharding_4_t1 left join schema2.sharding_4_t2 on sharding_4_t1.pad=schema2.sharding_4_t2.pad order by sharding_4_t1.id,schema2.sharding_4_t2.id)union (select * from schema2.sharding_4_t2 left join schema3.sharding_4_t3 on schema2.sharding_4_t2.pad=schema3.sharding_4_t3.pad)order by t_id, o_id/*allow_diff_sequence*/
select * from schema3.sharding_4_t3,(select * from sharding_4_t1 where id>3 union select * from schema2.sharding_4_t2 where id<2) a
(select * from sharding_4_t1 order by id limit 0,3) union (select * from schema3.sharding_4_t3 order by id limit 10,3) union (select * from schema2.sharding_4_t2 order by id limit 20,3)
(select a.id, a.name, b.name from sharding_4_t1 a left join schema2.sharding_4_t2 b on a.pad=b.pad) union(select schema3.sharding_4_t3.id, schema3.sharding_4_t3.name, schema3.sharding_4_t3.name from schema3.sharding_4_t3)/*allow_diff_sequence*/
#
#SELECT ... UNION [ALL | DISTINCT] SELECT ... [UNION [ALL | DISTINCT] SELECT ...]
#
select * from sharding_4_t1 union all select * from schema3.sharding_4_t3 union all select * from schema2.sharding_4_t2
select * from sharding_4_t1 union distinct select * from schema3.sharding_4_t3 union distinct select * from schema2.sharding_4_t2
(select name from sharding_4_t1 where pad=1 order by id limit 10) union all (select name from schema2.sharding_4_t2 where pad=1 order by id limit 10)/*allow_diff_sequence*/
(select name from sharding_4_t1 where pad=1 order by id limit 10) union distinct (select name from schema2.sharding_4_t2 where pad=1 order by id limit 10)/*allow_diff_sequence*/
(select * from sharding_4_t1 where pad=1) union (select * from schema2.sharding_4_t2 where pad=1) order by name limit 10
(select name as sort_a from sharding_4_t1 where pad=1) union (select name from schema2.sharding_4_t2 where pad=1) order by sort_a limit 10
(select name as sort_a,pad from sharding_4_t1 where pad=1) union (select name,pad from schema2.sharding_4_t2 where pad=1) order by sort_a,pad limit 10
#
#clear tables
#
drop table if exists sharding_4_t1
drop table if exists schema2.sharding_4_t2
drop table if exists schema3.sharding_4_t3