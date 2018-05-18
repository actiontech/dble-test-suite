#
#subquery syntax
#
drop table if exists a_test_no_shard
drop table if exists a_order_no_shard
drop table if exists a_manager_no_shard
CREATE TABLE a_test_no_shard(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_order_no_shard(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_manager_no_shard(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into a_test_no_shard values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into a_order_no_shard values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_manager_no_shard values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
select a.id,b.id,b.pad,a.t_id from a_test_no_shard a,(select all * from a_order_no_shard) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test_no_shard a,(select distinct * from a_order_no_shard) b where a.t_id=b.o_id;
select * from (select * from a_order_no_shard a group by a.id) a;
select * from (select pad,count(*) from a_order_no_shard a group by pad) a;
select a.id,b.id,b.pad,a.t_id from a_test_no_shard a,(select * from a_order_no_shard having pad>3) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test_no_shard a,(select * from a_order_no_shard where pad>3 order by id) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test_no_shard a,(select * from a_order_no_shard order by id limit 3) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test_no_shard a,(select * from a_order_no_shard order by id limit 3) b where a.t_id=b.o_id limit 2;
select a.id,b.id,b.pad,a.t_id from a_test_no_shard a,(select * from a_order_no_shard where pad>3) b where a.t_id=b.o_id;
select * from (select a_order_no_shard.pad from a_test_no_shard left join a_order_no_shard on a_test_no_shard.pad=a_order_no_shard.pad) a;
select * from (select * from a_test_no_shard union select * from a_order_no_shard) a where a.id >3;
select id,pad from a_test_no_shard where pad=(select min(id) from a_order_no_shard);
select id,pad,name from (select * from a_test_no_shard where pad>2) a where id<5;
select pad,count(*) from (select * from a_test_no_shard where pad>2) a group by pad;
select pad,count(*) from (select * from a_test_no_shard where pad>2) a group by pad order by pad;
select count(*) from (select pad,count(*) a from a_test_no_shard group by pad) a;
select * from a_test_no_shard where pad<(select pad from a_order_no_shard where id=3);
select * from a_test_no_shard having pad<(select pad from a_order_no_shard where id=3);
select a.id,b.id,b.pad,a.t_id from a_test_no_shard a,(select * from a_order_no_shard where pad>3) b where a.t_id=b.o_id;
select id,name,(select count(*) from a_order_no_shard) count from a_test_no_shard;
select * from a_test_no_shard where pad like (select pad from a_order_no_shard where id=3);
select id,pad from a_test_no_shard where pad>(select pad from a_test_no_shard where id=2);
select id,pad from a_test_no_shard where pad<(select pad from a_test_no_shard where id=2);
select id,pad from a_test_no_shard where pad=(select pad from a_test_no_shard where id=2);
select id,pad from a_test_no_shard where pad>=(select pad from a_test_no_shard where id=2);
select id,pad from a_test_no_shard where pad<=(select pad from a_test_no_shard where id=2);
select id,pad from a_test_no_shard where pad<>(select pad from a_test_no_shard where id=2);
select id,pad from a_test_no_shard where pad !=(select pad from a_test_no_shard where id=2);
select * from a_test_no_shard where exists(select * from a_test_no_shard where pad>1);
select * from a_test_no_shard where not exists(select * from a_test_no_shard where pad>1);
select * from a_test_no_shard where pad not in(select id from a_test_no_shard where pad>1);
select * from a_test_no_shard where pad in(select id from a_test_no_shard where pad>1);
select * from a_test_no_shard where pad=some(select id from a_test_no_shard where pad>1);
select * from a_test_no_shard where pad=any(select id from a_test_no_shard where pad>1);
select * from a_test_no_shard where pad !=any(select id from a_test_no_shard where pad=3);
select a.id,b.id,b.pad,a.t_id from (select a_test_no_shard.id,a_test_no_shard.pad,a_test_no_shard.t_id from a_test_no_shard join a_order_no_shard where a_test_no_shard.pad=a_order_no_shard.pad ) a,(select a_manager_no_shard.id,a_manager_no_shard.pad from a_test_no_shard join a_manager_no_shard where a_test_no_shard.pad=a_manager_no_shard.pad) b where a.pad=b.pad;
select * from a_test_no_shard where pad>(select pad from a_test_no_shard where pad=2);
select * from a_test_no_shard,(select * from a_test_no_shard where id>3 union select * from a_order_no_shard where id<2) a where a.id >3 and a_test_no_shard.pad=a.pad;
select count(*) from (select * from a_test_no_shard where pad=(select pad from a_order_no_shard where id=1)) a;
#
#Second supplement
#
select (select name from a_test_no_shard limit 1)
select * from a_test_no_shard where 'test_2'=(select name from a_order_no_shard where id=2)
select * from a_test_no_shard where 5=(select count(*) from a_order_no_shard)
select * from a_test_no_shard where 'test_2' like(select name from a_order_no_shard where id=2)
select * from a_test_no_shard where 2 >any(select id from a_test_no_shard where pad>1)
select * from a_test_no_shard where 2 in(select id from a_test_no_shard where pad>1)
select * from a_test_no_shard where 2<>some(select id from a_test_no_shard where pad>1)
select * from a_test_no_shard where 2>all(select id from a_test_no_shard where pad<1)
select * from a_test_no_shard where (id,pad)=(select id,pad from a_order_no_shard limit 1)
select * from a_test_no_shard where row(id,pad)=(select id,pad from a_order_no_shard limit 1)
select id,name,pad from a_test_no_shard where (id,pad)in(select id,pad from a_order_no_shard)
select id,name,pad from a_test_no_shard where (1,1)in(select id,pad from a_order_no_shard)
SELECT pad FROM a_test_no_shard AS x WHERE x.id = (SELECT pad FROM a_order_no_shard AS y WHERE x.id = (SELECT pad FROM a_manager_no_shard WHERE y.id = a_manager_no_shard.id))
select co1,co2,co3 from (select id as co1,name as co2,pad as co3 from a_test_no_shard)as tb where co1>1
select avg(sum_column1) from (select sum(id) as sum_column1 from a_test_no_shard group by pad) as t1
#
#clear tables
#
drop table if exists a_test_no_shard
drop table if exists a_order_no_shard
drop table if exists a_manager_no_shard