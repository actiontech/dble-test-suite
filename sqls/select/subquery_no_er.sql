#
#subquery syntax
#
drop table if exists a_test
drop table if exists a_two
drop table if exists a_three
CREATE TABLE a_test(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_two(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_three(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into a_test values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into a_two values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_three values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
select a.id,b.id,b.pad,a.t_id from a_test a,(select all * from a_two) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test a,(select distinct * from a_two) b where a.t_id=b.o_id;
select * from (select * from a_two a group by a.id) a;
select * from (select pad,count(*) from a_two a group by pad) a;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_two having pad>3) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_two where pad>3 order by id) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_two order by id limit 3) b where a.t_id=b.o_id;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_two order by id limit 3) b where a.t_id=b.o_id limit 2;
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_two where pad>3) b where a.t_id=b.o_id;
select * from (select a_two.pad from a_test left join a_two on a_test.pad=a_two.pad) a;
select * from (select * from a_test union select * from a_two) a where a.id >3;
select id,pad from a_test where pad=(select min(id) from a_two);
select id,pad,name from (select * from a_test where pad>2) a where id<5;
select pad,count(*) from (select * from a_test where pad>2) a group by pad;
select pad,count(*) from (select * from a_test where pad>2) a group by pad order by pad;
select count(*) from (select pad,count(*) a from a_test group by pad) a;
select * from a_test where pad<(select pad from a_two where id=3);
select * from a_test having pad<(select pad from a_two where id=3);
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_two where pad>3) b where a.t_id=b.o_id;
select id,name,(select count(*) from a_two) count from a_test;
select * from a_test where pad like (select pad from a_two where id=3);
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
select a.id,b.id,b.pad,a.t_id from (select a_test.id,a_test.pad,a_test.t_id from a_test join a_two where a_test.pad=a_two.pad ) a,(select a_three.id,a_three.pad from a_test join a_three where a_test.pad=a_three.pad) b where a.pad=b.pad;
select * from a_test where pad>(select pad from a_test where pad=2);
select * from a_test,(select * from a_test where id>3 union select * from a_two where id<2) a where a.id >3 and a_test.pad=a.pad;
select count(*) from (select * from a_test where pad=(select pad from a_two where id=1)) a;
#
#Second supplement
#
select (select name from a_test limit 1)
select * from a_test where 'test_2'=(select name from a_two where id=2)
select * from a_test where 5=(select count(*) from a_two)
select * from a_test where 'test_2' like(select name from a_two where id=2)
select * from a_test where 2 >any(select id from a_test where pad>1)
select * from a_test where 2 in(select id from a_test where pad>1)
select * from a_test where 2<>some(select id from a_test where pad>1)
select * from a_test where 2>all(select id from a_test where pad<1)
select * from a_test where (id,pad)=(select id,pad from a_two limit 1)
select * from a_test where row(id,pad)=(select id,pad from a_two limit 1)
select id,name,pad from a_test where (id,pad)in(select id,pad from a_two)
select id,name,pad from a_test where (1,1)in(select id,pad from a_two)
SELECT pad FROM a_test AS x WHERE x.id = (SELECT pad FROM a_two AS y WHERE x.id = (SELECT pad FROM a_three WHERE y.id = a_three.id))
select co1,co2,co3 from (select id as co1,name as co2,pad as co3 from a_test)as tb where co1>1
select avg(sum_column1) from (select sum(id) as sum_column1 from a_test group by pad) as t1