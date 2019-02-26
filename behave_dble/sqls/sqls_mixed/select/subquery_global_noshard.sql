#!default_db:schema1
#
#subquery syntax
#
drop table if exists schema2.global_4_t1
drop table if exists noshard_t1
drop table if exists sharding_4_t1
CREATE TABLE schema2.global_4_t1(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE noshard_t1(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE sharding_4_t1(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into schema2.global_4_t1 values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into noshard_t1 values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into sharding_4_t1 values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
select a.id,b.id,b.pad,a.t_id from schema2.global_4_t1 a,(select all * from noshard_t1) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from schema2.global_4_t1 a,(select distinct * from noshard_t1) b where a.t_id=b.o_id;
select * from (select * from noshard_t1 a group by a.id) a;
select * from (select pad,count(*) from noshard_t1 a group by pad) a;
select a.id,b.id,b.pad,a.t_id from schema2.global_4_t1 a,(select * from noshard_t1 having pad>3) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from schema2.global_4_t1 a,(select * from noshard_t1 where pad>3 order by id) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from schema2.global_4_t1 a,(select * from noshard_t1 order by id limit 3) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from schema2.global_4_t1 a,(select * from noshard_t1 order by id limit 3) b where a.t_id=b.o_id limit 2;
select a.id,b.id,b.pad,a.t_id from schema2.global_4_t1 a,(select * from noshard_t1 where pad>3) b where a.t_id=b.o_id;
select * from (select noshard_t1.pad from schema2.global_4_t1 left join noshard_t1 on schema2.global_4_t1.pad=noshard_t1.pad) a;
select * from (select id,t_id,name,pad from schema2.global_4_t1 union select * from noshard_t1) a where a.id >3;
select id,pad from schema2.global_4_t1 where pad=(select min(id) from noshard_t1);
select id,pad,name from (select * from schema2.global_4_t1 where pad>2) a where id<5;
select pad,count(*) from (select * from schema2.global_4_t1 where pad>2) a group by pad;
select pad,count(*) from (select * from schema2.global_4_t1 where pad>2) a group by pad order by pad;
select count(*) from (select pad,count(*) a from schema2.global_4_t1 group by pad) a;
select id,t_id,name,pad from schema2.global_4_t1 where pad<(select pad from noshard_t1 where id=3);
select id,t_id,name,pad from schema2.global_4_t1 having pad<(select pad from noshard_t1 where id=3);
select a.id,b.id,b.pad,a.t_id from schema2.global_4_t1 a,(select * from noshard_t1 where pad>3) b where a.t_id=b.o_id;
select id,name,(select count(*) from noshard_t1) count from schema2.global_4_t1;
select id,t_id,name,pad from schema2.global_4_t1 where pad like (select pad from noshard_t1 where id=3);
select id,pad from schema2.global_4_t1 where pad>(select pad from schema2.global_4_t1 where id=2);
select id,pad from schema2.global_4_t1 where pad<(select pad from schema2.global_4_t1 where id=2);
select id,pad from schema2.global_4_t1 where pad=(select pad from schema2.global_4_t1 where id=2);
select id,pad from schema2.global_4_t1 where pad>=(select pad from schema2.global_4_t1 where id=2);
select id,pad from schema2.global_4_t1 where pad<=(select pad from schema2.global_4_t1 where id=2);
select id,pad from schema2.global_4_t1 where pad<>(select pad from schema2.global_4_t1 where id=2);
select id,pad from schema2.global_4_t1 where pad !=(select pad from schema2.global_4_t1 where id=2);
select id,t_id,name,pad from schema2.global_4_t1 where exists(select * from schema2.global_4_t1 where pad>1);
select id,t_id,name,pad from schema2.global_4_t1 where not exists(select * from schema2.global_4_t1 where pad>1);
select id,t_id,name,pad from schema2.global_4_t1 where pad not in(select id from schema2.global_4_t1 where pad>1);
select id,t_id,name,pad from schema2.global_4_t1 where pad in(select id from schema2.global_4_t1 where pad>1);
select id,t_id,name,pad from schema2.global_4_t1 where pad=some(select id from schema2.global_4_t1 where pad>1);
select id,t_id,name,pad from schema2.global_4_t1 where pad=any(select id from schema2.global_4_t1 where pad>1);
select id,t_id,name,pad from schema2.global_4_t1 where pad !=any(select id from schema2.global_4_t1 where pad=3);
select a.id,b.id,b.pad,a.t_id from (select schema2.global_4_t1.id,schema2.global_4_t1.pad,schema2.global_4_t1.t_id from schema2.global_4_t1 join noshard_t1 where schema2.global_4_t1.pad=noshard_t1.pad ) a,(select sharding_4_t1.id,sharding_4_t1.pad from schema2.global_4_t1 join sharding_4_t1 where schema2.global_4_t1.pad=sharding_4_t1.pad) b where a.pad=b.pad;
select id,t_id,name,pad from schema2.global_4_t1 where pad>(select pad from schema2.global_4_t1 where pad=2);
select b.id,b.t_id,b.name,b.pad,a.id,a.id,a.pad,a.t_id from schema2.global_4_t1 b,(select id,t_id,name,pad from schema2.global_4_t1 where id>3 union select * from noshard_t1 where id<2) a where a.id >3 and b.pad=a.pad;
select count(*) from (select * from schema2.global_4_t1 where pad=(select pad from noshard_t1 where id=1)) a;
#
#Second supplement
#
select (select name from schema2.global_4_t1 limit 1)
select id,t_id,name,pad from schema2.global_4_t1 where 'test_2'=(select name from noshard_t1 where id=2)
select id,t_id,name,pad from schema2.global_4_t1 where 5=(select count(*) from noshard_t1)
select id,t_id,name,pad from schema2.global_4_t1 where 'test_2' like(select name from noshard_t1 where id=2)
select id,t_id,name,pad from schema2.global_4_t1 where 2 >any(select id from schema2.global_4_t1 where pad>1)
select id,t_id,name,pad from schema2.global_4_t1 where 2 in(select id from schema2.global_4_t1 where pad>1)
select id,t_id,name,pad from schema2.global_4_t1 where 2<>some(select id from schema2.global_4_t1 where pad>1)
select id,t_id,name,pad from schema2.global_4_t1 where 2>all(select id from schema2.global_4_t1 where pad<1)
select id,t_id,name,pad from schema2.global_4_t1 where (id,pad)=(select id,pad from noshard_t1 limit 1)
select id,t_id,name,pad from schema2.global_4_t1 where row(id,pad)=(select id,pad from noshard_t1 limit 1)
select id,name,pad from schema2.global_4_t1 where (id,pad)in(select id,pad from noshard_t1)
select id,name,pad from schema2.global_4_t1 where (1,1)in(select id,pad from noshard_t1)
SELECT pad FROM schema2.global_4_t1 AS x WHERE x.id = (SELECT pad FROM noshard_t1 AS y WHERE x.id = (SELECT pad FROM sharding_4_t1 WHERE y.id = sharding_4_t1.id))
select co1,co2,co3 from (select id as co1,name as co2,pad as co3 from schema2.global_4_t1)as tb where co1>1
select avg(sum_column1) from (select sum(id) as sum_column1 from schema2.global_4_t1 group by pad) as t1
#961
select id,pad from schema2.global_4_t1 where pad=1 and pad in (select id from noshard_t1) and id in (select id from noshard_t1);
#
#
#clear tables
#
drop table if exists schema2.global_4_t1
drop table if exists noshard_t1
drop table if exists sharding_4_t1