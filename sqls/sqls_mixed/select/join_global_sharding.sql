#!default_db:schema1
#
#prepare context
#
drop table if exists sharding_4_t1
drop table if exists schema2.global_4_t1
drop table if exists schema2.sharding_4_t2

CREATE TABLE sharding_4_t1(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE schema2.global_4_t1(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE schema2.sharding_4_t2(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8

insert into sharding_4_t1 values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into schema2.global_4_t1 values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into schema2.sharding_4_t2 values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
#
#join table
#
select a.id,a.t_id,b.o_id,b.name from sharding_4_t1 a,schema2.global_4_t1 b
select a.id,a.t_id,b.o_id,b.name from (select * from sharding_4_t1 where id<3) a,(select * from schema2.global_4_t1 where id>3) b
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select schema2.sharding_4_t2.id,schema2.sharding_4_t2.pad from sharding_4_t1 join schema2.sharding_4_t2 where sharding_4_t1.pad=schema2.sharding_4_t2.pad) b,(select * from schema2.global_4_t1 where id>3) c where a.pad=b.pad and c.pad=b.pad
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a join schema2.global_4_t1 as b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a inner join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a cross join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.name,a.pad,b.name from sharding_4_t1 a straight_join schema2.global_4_t1 b on a.pad=b.pad
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a,schema2.global_4_t1 b where a.pad=b.pad
select sharding_4_t1.id,sharding_4_t1.t_id,sharding_4_t1.name,sharding_4_t1.pad,schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from sharding_4_t1,schema2.global_4_t1 where sharding_4_t1.pad=schema2.global_4_t1.pad
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select * from schema2.global_4_t1 where pad>3) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select id,t_id from sharding_4_t1) a,(select * from schema2.global_4_t1) b where a.t_id=b.o_id
select sharding_4_t1.id,sharding_4_t1.name,a.name from sharding_4_t1,(select name from schema2.global_4_t1) a
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a inner join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a cross join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.name,a.pad,b.name from sharding_4_t1 a inner join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.name,a.pad,b.name from sharding_4_t1 a cross join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.name,a.pad,b.name from sharding_4_t1 a join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a inner join (select * from schema2.global_4_t1 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a cross join (select * from schema2.global_4_t1 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a join (select * from schema2.global_4_t1 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>2) a inner join (select * from schema2.global_4_t1 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>2) a cross join (select * from schema2.global_4_t1 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>2) a join (select * from schema2.global_4_t1 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a join (select * from schema2.global_4_t1 where pad>2) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a join (select * from schema2.global_4_t1 where pad>2) b  using(pad) order by a.id,b.id
select sharding_4_t1.id,sharding_4_t1.t_id,sharding_4_t1.name,sharding_4_t1.pad,schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from sharding_4_t1 straight_join schema2.global_4_t1 order by sharding_4_t1.id,schema2.global_4_t1.id
select a.id,a.name,a.pad,b.name from sharding_4_t1 a straight_join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a straight_join (select * from schema2.global_4_t1 where pad>0) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>0) a straight_join (select * from schema2.global_4_t1 where pad>0) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a straight_join (select * from schema2.global_4_t1 where pad>0) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select sharding_4_t1.id,sharding_4_t1.t_id,sharding_4_t1.name,sharding_4_t1.pad,schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from sharding_4_t1 left join schema2.global_4_t1 on sharding_4_t1.pad=schema2.global_4_t1.pad order by sharding_4_t1.id,schema2.global_4_t1.id
select sharding_4_t1.id,sharding_4_t1.t_id,sharding_4_t1.name,sharding_4_t1.pad,schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from sharding_4_t1 right join schema2.global_4_t1 on sharding_4_t1.pad=schema2.global_4_t1.pad order by sharding_4_t1.id,schema2.global_4_t1.id
select sharding_4_t1.id,sharding_4_t1.t_id,sharding_4_t1.name,sharding_4_t1.pad,schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from sharding_4_t1 left outer join schema2.global_4_t1 on sharding_4_t1.pad=schema2.global_4_t1.pad order by sharding_4_t1.id,schema2.global_4_t1.id
select sharding_4_t1.id,sharding_4_t1.t_id,sharding_4_t1.name,sharding_4_t1.pad,schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from sharding_4_t1 right outer join schema2.global_4_t1 on sharding_4_t1.pad=schema2.global_4_t1.pad order by sharding_4_t1.id,schema2.global_4_t1.id
select sharding_4_t1.id,sharding_4_t1.t_id,sharding_4_t1.name,sharding_4_t1.pad,schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from sharding_4_t1 left join schema2.global_4_t1 using(pad) order by sharding_4_t1.id,schema2.global_4_t1.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a left join schema2.global_4_t1 b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a right join schema2.global_4_t1 b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a left outer join schema2.global_4_t1 b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a right outer join schema2.global_4_t1 b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a left join schema2.global_4_t1 b using(pad) order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a left join (select * from schema2.global_4_t1 where pad>2) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a right join (select * from schema2.global_4_t1 where pad>2) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a left outer join (select * from schema2.global_4_t1 where pad>2) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a right outer join (select * from schema2.global_4_t1 where pad>2) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a left join (select * from schema2.global_4_t1 where pad>2) b using(pad) order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>1) a left join (select * from schema2.global_4_t1 where pad>3) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>1) a right join (select * from schema2.global_4_t1 where pad>3) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>1) a left outer join (select * from schema2.global_4_t1 where pad>3) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>1) a right outer join (select * from schema2.global_4_t1 where pad>3) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>1) a left join (select * from schema2.global_4_t1 where pad>3) b using(pad) order by a.id,b.id
select sharding_4_t1.id,sharding_4_t1.t_id,sharding_4_t1.name,sharding_4_t1.pad,schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from sharding_4_t1 natural left join schema2.global_4_t1
select sharding_4_t1.id,sharding_4_t1.t_id,sharding_4_t1.name,sharding_4_t1.pad,schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from sharding_4_t1 natural right join schema2.global_4_t1
select sharding_4_t1.id,sharding_4_t1.t_id,sharding_4_t1.name,sharding_4_t1.pad,schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from sharding_4_t1 natural left outer join schema2.global_4_t1
select sharding_4_t1.id,sharding_4_t1.t_id,sharding_4_t1.name,sharding_4_t1.pad,schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from sharding_4_t1 natural right outer join schema2.global_4_t1
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a natural left join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a natural right join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a natural left outer join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a natural right outer join schema2.global_4_t1 b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a natural left join (select * from schema2.global_4_t1 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a natural right join (select * from schema2.global_4_t1 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a natural left outer join (select * from schema2.global_4_t1 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from sharding_4_t1 a natural right outer join (select * from schema2.global_4_t1 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>1) a natural left join (select * from schema2.global_4_t1 where pad>3) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>1) a natural right join (select * from schema2.global_4_t1 where pad>3) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>1) a natural left outer join (select * from schema2.global_4_t1 where pad>3) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from sharding_4_t1 where pad>1) a natural right outer join (select * from schema2.global_4_t1 where pad>3) b order by a.id,b.id
select sharding_4_t1.id,sharding_4_t1.t_id,sharding_4_t1.name,sharding_4_t1.pad,schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from sharding_4_t1 left join schema2.global_4_t1 on sharding_4_t1.pad=schema2.global_4_t1.pad and sharding_4_t1.id>3 order by sharding_4_t1.id,schema2.global_4_t1.id
#
#distinct(special_scene)
#
(select pad from sharding_4_t1) union distinct (select pad from schema2.global_4_t1)
(select * from sharding_4_t1 where id=2) union distinct (select schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from schema2.global_4_t1 where id=2)
select distinct a.pad from sharding_4_t1 a,schema2.global_4_t1 b where a.pad=b.pad
select distinct b.pad,a.pad from sharding_4_t1 a,(select schema2.global_4_t1.id,schema2.global_4_t1.o_id,schema2.global_4_t1.name,schema2.global_4_t1.pad from schema2.global_4_t1 where pad=1) b where a.t_id=b.o_id
select count(distinct pad,name),avg(distinct t_id) from sharding_4_t1
select count(distinct id),sum(distinct name) from sharding_4_t1 where id=3 or id=7
#
#SELECT ... UNION [ALL | DISTINCT] SELECT ... [UNION [ALL | DISTINCT] SELECT ...]
#
select * from sharding_4_t1 union all select * from schema2.sharding_4_t2 union all select c.id,c.o_id,c.name,c.pad from schema2.global_4_t1 c
select * from sharding_4_t1 union distinct select * from schema2.sharding_4_t2 union distinct select c.id,c.o_id,c.name,c.pad from schema2.global_4_t1 c
(select name from sharding_4_t1 where pad=1 order by id limit 10) union all (select name from schema2.global_4_t1 where pad=1 order by id limit 10) order by name
(select name from sharding_4_t1 where pad=1 order by id limit 10) union distinct (select name from schema2.global_4_t1 where pad=1 order by id limit 10) order by name
(select * from sharding_4_t1 where pad=1) union (select c.id,c.o_id,c.name,c.pad from schema2.global_4_t1 c where pad=1) order by name limit 10
(select name as sort_a from sharding_4_t1 where pad=1) union (select name from schema2.global_4_t1 where pad=1) order by sort_a limit 10
(select name as sort_a,pad from sharding_4_t1 where pad=1) union (select name,pad from schema2.global_4_t1 where pad=1) order by sort_a,pad limit 10
#
#clear tables
#
drop table if exists sharding_4_t1
drop table if exists schema2.global_4_t1
drop table if exists schema2.sharding_4_t2