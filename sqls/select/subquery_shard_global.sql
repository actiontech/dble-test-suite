#
#subquery syntax
#
drop table if exists a_test
drop table if exists test_global
drop table if exists a_manager
CREATE TABLE a_test(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE test_global(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_manager(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into a_test values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into test_global values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_manager values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
select a.id,b.id,b.pad,a.t_id from a_test a,(select all * from test_global) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test a,(select distinct * from test_global) b where a.t_id=b.o_id;
select a.id,a.o_id,a.name,a.pad from (select * from test_global a group by a.id) a;
select * from (select pad,count(*) from test_global a group by pad) a;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from test_global having pad>3) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from test_global where pad>3 order by id) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from test_global order by id limit 3) b where a.t_id=b.o_id order by a.id;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from test_global order by id limit 3) b where a.t_id=b.o_id order by a.id limit 2;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from test_global where pad>3) b where a.t_id=b.o_id;
select * from (select test_global.pad from a_test left join test_global on a_test.pad=test_global.pad) a;
select * from (select * from a_test union select id,o_id,name,pad from test_global) a where a.id >3;
select id,pad from a_test where pad=(select min(id) from test_global);
select id,pad,name from (select * from a_test where pad>2) a where id<5;
select pad,count(*) from (select * from a_test where pad>2) a group by pad;
select pad,count(*) from (select * from a_test where pad>2) a group by pad order by pad;
select count(*) from (select pad,count(*) a from a_test group by pad) a;
select * from a_test where pad<(select pad from test_global where id=3);
select * from a_test having pad<(select pad from test_global where id=3);
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from test_global where pad>3) b where a.t_id=b.o_id;
select id,name,(select count(*) from test_global) count from a_test;
select * from a_test where pad like (select pad from test_global where id=3);
select id,pad from a_test where pad>(select pad from a_test where id=2);
select id,pad from a_test where pad<(select pad from a_test where id=2);
select id,pad from a_test where pad=(select pad from a_test where id=2);
select id,pad from a_test where pad>=(select pad from a_test where id=2);
select id,pad from a_test where pad<=(select pad from a_test where id=2);
select id,pad from a_test where pad<>(select pad from a_test where id=2);
select id,pad from a_test where pad !=(select pad from a_test where id=2);
select * from a_test where exists(select * from a_test where pad>1);
select * from a_test where not exists(select * from a_test where pad>1);
select * from a_test where pad not in(select id from a_test where pad>1);
select * from a_test where pad in(select id from a_test where pad>1);
select * from a_test where pad=some(select id from a_test where pad>1);
select * from a_test where pad=any(select id from a_test where pad>1);
select * from a_test where pad !=any(select id from a_test where pad=3);
select a.id,b.id,b.pad,a.t_id from (select a_test.id,a_test.pad,a_test.t_id from a_test join test_global where a_test.pad=test_global.pad ) a,(select a_manager.id,a_manager.pad from a_test join a_manager where a_test.pad=a_manager.pad) b where a.pad=b.pad;
select * from a_test where pad>(select pad from a_test where pad=2);
select * from a_test,(select * from a_test where id>3 union select id,o_id,name,pad from test_global where id<2) a where a.id >3 and a_test.pad=a.pad;
select count(*) from (select * from a_test where pad=(select pad from test_global where id=1)) a;
#
#Second supplement
#
select (select name from a_test limit 1)
select * from a_test where 'test_2'=(select name from test_global where id=2)
select * from a_test where 5=(select count(*) from test_global)
select * from a_test where 'test_2' like(select name from test_global where id=2)
select * from a_test where 2 >any(select id from a_test where pad>1)
select * from a_test where 2 in(select id from a_test where pad>1)
select * from a_test where 2<>some(select id from a_test where pad>1)
select * from a_test where 2>all(select id from a_test where pad<1)
select * from a_test where (id,pad)=(select id,pad from test_global limit 1)
select * from a_test where row(id,pad)=(select id,pad from test_global limit 1)
select id,name,pad from a_test where (id,pad)in(select id,pad from test_global)
select id,name,pad from a_test where (1,1)in(select id,pad from test_global)
SELECT pad FROM a_test AS x WHERE x.id = (SELECT pad FROM test_global AS y WHERE x.id = (SELECT pad FROM a_manager WHERE y.id = a_manager.id))
select co1,co2,co3 from (select id as co1,name as co2,pad as co3 from a_test)as tb where co1>1
select avg(sum_column1) from (select sum(id) as sum_column1 from a_test group by pad) as t1
#
#clear tables
#
drop table if exists a_test
drop table if exists test_global
drop table if exists a_manager