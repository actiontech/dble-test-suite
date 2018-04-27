#
#subquery syntax
#
drop table if exists a_test
drop table if exists a_order
drop table if exists a_manager
CREATE TABLE a_test(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_order(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_manager(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into a_test values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into a_order values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_manager values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
select a.id,b.id,b.pad,a.t_id from a_test a,(select all * from a_order) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test a,(select distinct * from a_order) b where a.t_id=b.o_id;
select * from (select * from a_order a group by a.id) a;
select * from (select pad,count(*) from a_order a group by pad) a;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_order having pad>3) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_order where pad>3 order by id) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_order order by id limit 3) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_order order by id limit 3) b where a.t_id=b.o_id limit 2;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_order where pad>3) b where a.t_id=b.o_id;
select * from (select a_order.pad from a_test left join a_order on a_test.pad=a_order.pad) a;
select * from (select * from a_test union select * from a_order) a where a.id >3;
select id,pad from a_test where pad=(select min(id) from a_order);
select (select name from a_test limit 1);
select (select name from a_test limit 1),id from a_order ;
select upper('test'),id from a_order ;
select id,pad,name from (select * from a_test where pad>2) a where id<5;
select pad,count(*) from (select * from a_test where pad>2) a group by pad;
select pad,count(*) from (select * from a_test where pad>2) a group by pad order by pad;
select count(*) from (select pad,count(*) a from a_test group by pad) a;
select * from a_test where pad<(select pad from a_order where id=3);
select * from a_test having pad<(select pad from a_order where id=3);
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_order where pad>3) b where a.t_id=b.o_id;
select id,pad,name from (select * from a_test where pad>2) as a;
select * from (select * from a_test where id<3) a,(select * from a_order where id>3) b;
select a.id,b.id,b.pad,a.t_id from a_test a,(select a_manager.id,a_manager.pad from a_test join a_manager where a_test.pad=a_manager.pad) b,(select * from a_order where id>3) c where a.pad=b.pad and c.pad=b.pad;
select id,name,(select count(*) from a_order) count from a_test;
select * from a_test where pad like (select pad from a_order where id=3);
select id,pad from a_test where pad>(select pad from a_test where id=2);
select * from a_test where 2 >any(select id from a_test where pad>1);
select id,pad from a_test where pad<(select pad from a_test where id=2);
select * from a_test where 'test_2'=(select name from a_order where id=2)
select * from a_test where 5=(select count(*) from a_order);
select id,pad from a_test where pad=(select pad from a_test where id=2);
select id,pad from a_test where pad>=(select pad from a_test where id=2);
select id,pad from a_test where pad<=(select pad from a_test where id=2);
select id,pad from a_test where pad<>(select pad from a_test where id=2);
select id,pad from a_test where pad !=(select pad from a_test where id=2);
select * from a_test where exists(select * from a_test where pad>1);
select * from a_test where not exists(select * from a_test where pad>1);
select * from a_test where pad not in(select id from a_test where pad>1);
select * from a_test where 2 in(select id from a_test where pad>1);
select * from a_test where pad in(select id from a_test where pad>1);
select * from a_test where pad=some(select id from a_test where pad>1);
select * from a_test where 2<>some(select id from a_test where pad>1);
select * from a_test where pad=any(select id from a_test where pad>1);
select * from a_test where pad !=any(select id from a_test where pad=3);
select * from a_test where pad>all(select id from a_test where pad<1);
select * from a_test where 2>all(select id from a_test where pad<1);
select * from a_test where 'test_2' like(select name from a_order where id=2)
select * from a_test where name like(select name from a_order where id=2)
select a.id,b.id,b.pad,a.t_id from (select a_test.id,a_test.pad,a_test.t_id from a_test join a_order where a_test.pad=a_order.pad ) a,(select a_manager.id,a_manager.pad from a_test join a_manager where a_test.pad=a_manager.pad) b where a.pad=b.pad;
select * from a_test where pad>(select pad from a_test where pad=2);
select * from a_test,(select * from a_test where id>3 union select * from a_order where id<2) a where a.id >3 and a_test.pad=a.pad;
select count(*) from (select * from a_test where pad=(select pad from a_order where id=1)) a;
select co1,co2,co3 from (select id as co1,name as co2,pad as co3 from a_test)as tb where co1>1;
select avg(sum_column1) from (select sum(id) as sum_column1 from a_test group by pad) as t1;
SELECT pad FROM a_test AS x WHERE x.id = (SELECT pad FROM a_order AS y WHERE x.id = (SELECT pad FROM a_manager WHERE y.id = a_manager.id));
select * from a_test where (id,pad)=(select id,pad from a_order limit 1);
select * from a_test where row(id,pad)=(select id,pad from a_order limit 1);
select id,name,pad from a_test where (id,pad)in(select id,pad from a_order);
select id,name,pad from a_test where (1,1)in(select id,pad from a_order);
SELECT pad FROM a_test AS x WHERE x.id = (SELECT pad FROM a_order AS y WHERE x.id = (SELECT pad FROM a_manager WHERE y.id = a_manager.id));
#
#contains Aggregate function
#
drop table if exists test_shard;
CREATE TABLE test_shard(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120),`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`));
insert into test_shard values(1,1,'id1',1),(2,2,'id2',2),(3,3,'id3',3),(4,4,'id4',4),(5,5,'id5',1),(6,6,'id6',2),(7,7,'id7',3),(8,8,'$id8$',4),(9,9,'test',3),(10,10,'中',3),(11,11,'i_',4),(12,12,'_g',5),(13,13,'y_u',6),(14,14,'20%',14),(15,15,'a_1',15),(16,16,16,-1),(0,0,0,0),(17,17,'new*\n*line',17),(18,18,'a',18);
insert into test_shard(id,k,pad) values(19,19,19);
select pad,count(id) t from test_shard group by pad having t>1;
select pad,count(id) t from test_shard group by pad order by pad;
select pad,count(id) t from test_shard group by pad having t>1 order by id;
select count(distinct id),pad from test_shard group by pad having pad >0 order by pad;
select * from test_shard where pad >(select count(id) t from test_shard group by pad having t>3);
select * from test_shard where pad >(select count(id) t from test_shard group by pad order by pad limit 1);
select * from test_shard where pad>(select count(id) t from test_shard group by pad having t>3 order by id);
select * from test_shard where pad>(select count(distinct id)t from test_shard group by pad having t >3 order by pad);
select * from (select pad,count(id) t from test_shard group by pad having t>1) a where a.pad>3;
select * from (select pad,count(id) t from test_shard group by pad order by pad)a where a.pad>1;
select * from (select pad,count(id) t from test_shard group by pad having t>1 order by id)a where a.pad>1;
select * from (select count(distinct id),pad from test_shard group by pad having pad >0 order by pad)a where a.pad>2;
select (select count(id) t from test_shard group by pad having t>3) from test_shard;
select (select count(id) t from test_shard group by pad order by pad limit 1) from test_shard;
select (select count(id) t from test_shard group by pad having t>3 order by id) from test_shard;
select (select count(distinct id)t from test_shard group by pad having t >3 order by pad) from test_shard;
select * from (select pad,count(id) t from a_test group by pad having t>1)a join (select pad,count(id) t from a_order group by pad order by pad)b;
select * from (select pad,count(id) t from a_test group by pad having t>1)a join (select pad,count(id) t from a_order group by pad order by pad)b where a.t>b.t;
select a.pad,b.pad,count(*) from (select pad,count(id) t from a_test group by pad having t>1)a join (select pad,count(id) t from a_order group by pad order by pad)b group by b.pad order by a.pad;
(select pad,count(id) t from a_test group by pad having t>1)union(select pad,count(id) t from a_order group by pad order by pad);
#
#Second supplement
#
drop table if exists a_test;
drop table if exists a_order;
drop table if exists a_manager;
CREATE TABLE a_test(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))
CREATE TABLE a_order(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))
CREATE TABLE a_manager(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))
insert into a_test values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into a_order values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_manager values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
select (select name from a_test limit 1)
select * from a_test where 'test_2'=(select name from a_order where id=2)
select * from a_test where 5=(select count(*) from a_order)
select * from a_test where 'test_2' like(select name from a_order where id=2)
select * from a_test where 2 >any(select id from a_test where pad>1)
select * from a_test where 2 in(select id from a_test where pad>1)
select * from a_test where 2<>some(select id from a_test where pad>1)
select * from a_test where 2>all(select id from a_test where pad<1)
select * from a_test where (id,pad)=(select id,pad from a_order limit 1)
select * from a_test where row(id,pad)=(select id,pad from a_order limit 1)
select id,name,pad from a_test where (id,pad)in(select id,pad from a_order)
select id,name,pad from a_test where (1,1)in(select id,pad from a_order)
SELECT pad FROM a_test AS x WHERE x.id = (SELECT pad FROM a_order AS y WHERE x.id = (SELECT pad FROM a_manager WHERE y.id = a_manager.id))
select co1,co2,co3 from (select id as co1,name as co2,pad as co3 from a_test)as tb where co1>1
select avg(sum_column1) from (select sum(id) as sum_column1 from a_test group by pad) as t1
select * from a_test order by (select pad from a_order limit 1)/*hang*/;
#select * from a_test order by (select pad from a_order limit 1);/*hang*/  #case for issue 13,waiting for fix
