#!default_db:schema1
#
#subquery syntax
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
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select all * from schema2.sharding_4_t2) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select distinct * from schema2.sharding_4_t2) b where a.t_id=b.o_id
select * from (select * from schema2.sharding_4_t2 a group by a.id) a
select * from (select pad,count(*) from schema2.sharding_4_t2 a group by pad) a
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select * from schema2.sharding_4_t2 having pad>3) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select * from schema2.sharding_4_t2 where pad>3 order by id) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select * from schema2.sharding_4_t2 order by id limit 3) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select * from schema2.sharding_4_t2 order by id limit 3) b where a.t_id=b.o_id limit 2
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select * from schema2.sharding_4_t2 where pad>3) b where a.t_id=b.o_id
select * from (select schema2.sharding_4_t2.pad from sharding_4_t1 left join schema2.sharding_4_t2 on sharding_4_t1.pad=schema2.sharding_4_t2.pad) a
select * from (select * from sharding_4_t1 union select * from schema2.sharding_4_t2) a where a.id >3
select id,pad from sharding_4_t1 where pad=(select min(id) from schema2.sharding_4_t2)
select (select name from sharding_4_t1 order by id limit 1)
select (select name from sharding_4_t1 order by id limit 1),id from schema2.sharding_4_t2 order by id
select upper('test'),id from schema2.sharding_4_t2
select id,pad,name from (select * from sharding_4_t1 where pad>2) a where id<5
select pad,count(*) from (select * from sharding_4_t1 where pad>2) a group by pad
select pad,count(*) from (select * from sharding_4_t1 where pad>2) a group by pad order by pad
select count(*) from (select pad,count(*) a from sharding_4_t1 group by pad) a
select * from sharding_4_t1 where pad<(select pad from schema2.sharding_4_t2 where id=3)
select * from sharding_4_t1 having pad<(select pad from schema2.sharding_4_t2 where id=3)
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select * from schema2.sharding_4_t2 where pad>3) b where a.t_id=b.o_id
select id,pad,name from (select * from sharding_4_t1 where pad>2) as a
select * from (select * from sharding_4_t1 where id<3) a,(select * from schema2.sharding_4_t2 where id>3) b
select a.id,b.id,b.pad,a.t_id from sharding_4_t1 a,(select schema3.sharding_4_t3.id,schema3.sharding_4_t3.pad from sharding_4_t1 join schema3.sharding_4_t3 where sharding_4_t1.pad=schema3.sharding_4_t3.pad) b,(select * from schema2.sharding_4_t2 where id>3) c where a.pad=b.pad and c.pad=b.pad
select id,name,(select count(*) from schema2.sharding_4_t2) count from sharding_4_t1
select * from sharding_4_t1 where pad like (select pad from schema2.sharding_4_t2 where id=3)
select id,pad from sharding_4_t1 where pad>(select pad from sharding_4_t1 where id=2)
select * from sharding_4_t1 where 2 >any(select id from sharding_4_t1 where pad>1)
select id,pad from sharding_4_t1 where pad<(select pad from sharding_4_t1 where id=2)
select * from sharding_4_t1 where 'test_2'=(select name from schema2.sharding_4_t2 where id=2)
select * from sharding_4_t1 where 5=(select count(*) from schema2.sharding_4_t2)
select id,pad from sharding_4_t1 where pad=(select pad from sharding_4_t1 where id=2)
select id,pad from sharding_4_t1 where pad>=(select pad from sharding_4_t1 where id=2)
select id,pad from sharding_4_t1 where pad<=(select pad from sharding_4_t1 where id=2)
select id,pad from sharding_4_t1 where pad<>(select pad from sharding_4_t1 where id=2)
select id,pad from sharding_4_t1 where pad !=(select pad from sharding_4_t1 where id=2)
select * from sharding_4_t1 where exists(select * from sharding_4_t1 where pad>1)
select * from sharding_4_t1 where not exists(select * from sharding_4_t1 where pad>1)
select * from sharding_4_t1 where pad not in(select id from sharding_4_t1 where pad>1)
select * from sharding_4_t1 where 2 in(select id from sharding_4_t1 where pad>1)
select * from sharding_4_t1 where pad in(select id from sharding_4_t1 where pad>1)
select * from sharding_4_t1 where pad=some(select id from sharding_4_t1 where pad>1)
select * from sharding_4_t1 where 2<>some(select id from sharding_4_t1 where pad>1)
select * from sharding_4_t1 where pad=any(select id from sharding_4_t1 where pad>1)
select * from sharding_4_t1 where pad !=any(select id from sharding_4_t1 where pad=3)
select * from sharding_4_t1 where pad>all(select id from sharding_4_t1 where pad<1)
select * from sharding_4_t1 where 2>all(select id from sharding_4_t1 where pad<1)
select * from sharding_4_t1 where 'test_2' like(select name from schema2.sharding_4_t2 where id=2)
select * from sharding_4_t1 where name like(select name from schema2.sharding_4_t2 where id=2)
select a.id,b.id,b.pad,a.t_id from (select sharding_4_t1.id,sharding_4_t1.pad,sharding_4_t1.t_id from sharding_4_t1 join schema2.sharding_4_t2 where sharding_4_t1.pad=schema2.sharding_4_t2.pad ) a,(select schema3.sharding_4_t3.id,schema3.sharding_4_t3.pad from sharding_4_t1 join schema3.sharding_4_t3 where sharding_4_t1.pad=schema3.sharding_4_t3.pad) b where a.pad=b.pad
select * from sharding_4_t1 where pad>(select pad from sharding_4_t1 where pad=2)
select * from sharding_4_t1,(select * from sharding_4_t1 where id>3 union select * from schema2.sharding_4_t2 where id<2) a where a.id >3 and sharding_4_t1.pad=a.pad
select count(*) from (select * from sharding_4_t1 where pad=(select pad from schema2.sharding_4_t2 where id=1)) a
select co1,co2,co3 from (select id as co1,name as co2,pad as co3 from sharding_4_t1)as tb where co1>1
select avg(sum_column1) from (select sum(id) as sum_column1 from sharding_4_t1 group by pad) as t1
SELECT pad FROM sharding_4_t1 AS x WHERE x.id = (SELECT pad FROM schema2.sharding_4_t2 AS y WHERE x.id = (SELECT pad FROM schema3.sharding_4_t3 WHERE y.id = schema3.sharding_4_t3.id))
select * from sharding_4_t1 where (id,pad)=(select id,pad from schema2.sharding_4_t2 limit 1)
select * from sharding_4_t1 where row(id,pad)=(select id,pad from schema2.sharding_4_t2 limit 1)
select id,name,pad from sharding_4_t1 where (id,pad)in(select id,pad from schema2.sharding_4_t2)
select id,name,pad from sharding_4_t1 where (1,1)in(select id,pad from schema2.sharding_4_t2)
SELECT pad FROM sharding_4_t1 AS x WHERE x.id = (SELECT pad FROM schema2.sharding_4_t2 AS y WHERE x.id = (SELECT pad FROM schema3.sharding_4_t3 WHERE y.id = schema3.sharding_4_t3.id))
#
#contains Aggregate function
#
select * from (select pad,count(id) t from sharding_4_t1 group by pad having t>1)a join (select pad,count(id) t from schema2.sharding_4_t2 group by pad order by pad)b
select * from (select pad,count(id) t from sharding_4_t1 group by pad having t>1)a join (select pad,count(id) t from schema2.sharding_4_t2 group by pad order by pad)b where a.t>b.t
select a.pad,b.pad,count(*) from (select pad,count(id) t from sharding_4_t1 group by pad having t>1)a join (select pad,count(id) t from schema2.sharding_4_t2 group by pad order by pad)b group by b.pad order by b.pad
(select pad,count(id) t from sharding_4_t1 group by pad having t>1)union(select pad,count(id) t from schema2.sharding_4_t2 group by pad order by pad)
drop table if exists sharding_4_t1
CREATE TABLE sharding_4_t1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120),`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
insert into sharding_4_t1 values(1,1,'id1',1),(2,2,'id2',2),(3,3,'id3',3),(4,4,'id4',4),(5,5,'id5',1),(6,6,'id6',2),(7,7,'id7',3),(8,8,'$id8$',4),(9,9,'test',3),(10,10,'中',3),(11,11,'i_',4),(12,12,'_g',5),(13,13,'y_u',6),(14,14,'20%',14),(15,15,'a_1',15),(16,16,16,-1),(0,0,0,0),(17,17,'new*\n*line',17),(18,18,'a',18)
insert into sharding_4_t1(id,k,pad) values(19,19,19)
select pad,count(id) t from sharding_4_t1 group by pad having t>1
select pad,count(id) t from sharding_4_t1 group by pad order by pad
select pad,count(id) t from sharding_4_t1 group by pad having t>1 order by id/*allow_diff_sequence*/
select count(distinct id),pad from sharding_4_t1 group by pad having pad >0 order by pad
select * from sharding_4_t1 where pad >(select count(id) t from sharding_4_t1 group by pad having t>3)
select * from sharding_4_t1 where pad >(select count(id) t from sharding_4_t1 group by pad order by pad limit 1) order by id
select * from sharding_4_t1 where pad>(select count(id) t from sharding_4_t1 group by pad having t>3 order by id) order by id
select * from sharding_4_t1 where pad>(select count(distinct id)t from sharding_4_t1 group by pad having t >3) order by pad
select * from (select pad,count(id) t from sharding_4_t1 group by pad having t>1) a where a.pad>3
select * from (select pad,count(id) t from sharding_4_t1 group by pad order by pad)a where a.pad>1
select * from (select pad,count(id) t from sharding_4_t1 group by pad having t>1 order by id)a where a.pad>1/*allow_diff_sequence*/
select * from (select count(distinct id),pad from sharding_4_t1 group by pad having pad >0 order by pad)a where a.pad>2
select (select count(id) t from sharding_4_t1 group by pad having t>3) from sharding_4_t1
select (select count(id) t from sharding_4_t1 group by pad order by pad limit 1) from sharding_4_t1
select (select count(id) t from sharding_4_t1 group by pad having t>3 order by id) from sharding_4_t1
select (select count(distinct id)t from sharding_4_t1 group by pad having t >3 order by pad) from sharding_4_t1
#
#order by(subquery)
#
select * from sharding_4_t1 order by (select pad from schema2.sharding_4_t2 order by id limit 1)
#select * from sharding_4_t1 order by (select pad from schema2.sharding_4_t2 limit 1)/*hang*/  #case for issue 13,waiting for fix
#issue :1103
select s.* from (select count(1) c from schema2.sharding_4_t2 t union all select count(1) c from sharding_4_t1 t  ) s where s.c>2;
#
#clear tables
#
drop table if exists sharding_4_t1
drop table if exists schema2.sharding_4_t2
drop table if exists schema3.sharding_4_t3