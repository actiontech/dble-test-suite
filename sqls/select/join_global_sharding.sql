#
#join syntax
#
drop table if exists aly_test
drop table if exists test_global
drop table if exists a_manager
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE test_global(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_manager(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into aly_test values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into test_global values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_manager values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a,test_global b where a.pad=b.pad
select aly_test.id,aly_test.t_id,aly_test.name,aly_test.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from aly_test,test_global where aly_test.pad=test_global.pad
select a.id,b.id,b.pad,a.t_id from aly_test a,(select * from test_global where pad>3) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select id,t_id from aly_test) a,(select * from test_global) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select aly_test.id,aly_test.pad,aly_test.t_id from aly_test join test_global where aly_test.pad=test_global.pad ) a,(select a_manager.id,a_manager.pad from aly_test join a_manager where aly_test.pad=a_manager.pad) b where a.pad=b.pad
select aly_test.id,aly_test.name,a.name from aly_test,(select name from test_global) a
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a inner join test_global b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a cross join test_global b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a join test_global b order by a.id,b.id
select a.id,a.name,a.pad,b.name from aly_test a inner join test_global b order by a.id,b.id
select a.id,a.name,a.pad,b.name from aly_test a cross join test_global b order by a.id,b.id
select a.id,a.name,a.pad,b.name from aly_test a join test_global b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a inner join (select * from test_global where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a cross join (select * from test_global where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a join (select * from test_global where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>2) a inner join (select * from test_global where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>2) a cross join (select * from test_global where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>2) a join (select * from test_global where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a join (select * from test_global where pad>2) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a join (select * from test_global where pad>2) b  using(pad) order by a.id,b.id
select aly_test.id,aly_test.t_id,aly_test.name,aly_test.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from aly_test straight_join test_global order by aly_test.id,test_global.id
select a.id,a.name,a.pad,b.name from aly_test a straight_join test_global b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a straight_join (select * from test_global where pad>0) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>0) a straight_join (select * from test_global where pad>0) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a straight_join (select * from test_global where pad>0) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select aly_test.id,aly_test.t_id,aly_test.name,aly_test.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from aly_test left join test_global on aly_test.pad=test_global.pad order by aly_test.id,test_global.id
select aly_test.id,aly_test.t_id,aly_test.name,aly_test.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from aly_test right join test_global on aly_test.pad=test_global.pad order by aly_test.id,test_global.id
select aly_test.id,aly_test.t_id,aly_test.name,aly_test.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from aly_test left outer join test_global on aly_test.pad=test_global.pad order by aly_test.id,test_global.id
select aly_test.id,aly_test.t_id,aly_test.name,aly_test.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from aly_test right outer join test_global on aly_test.pad=test_global.pad order by aly_test.id,test_global.id
select aly_test.id,aly_test.t_id,aly_test.name,aly_test.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from aly_test left join test_global using(pad) order by aly_test.id,test_global.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a left join test_global b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a right join test_global b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a left outer join test_global b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a right outer join test_global b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a left join test_global b using(pad) order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a left join (select * from test_global where pad>2) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a right join (select * from test_global where pad>2) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a left outer join (select * from test_global where pad>2) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a right outer join (select * from test_global where pad>2) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a left join (select * from test_global where pad>2) b using(pad) order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>1) a left join (select * from test_global where pad>3) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>1) a right join (select * from test_global where pad>3) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>1) a left outer join (select * from test_global where pad>3) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>1) a right outer join (select * from test_global where pad>3) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>1) a left join (select * from test_global where pad>3) b using(pad) order by a.id,b.id
select aly_test.id,aly_test.t_id,aly_test.name,aly_test.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from aly_test natural left join test_global
select aly_test.id,aly_test.t_id,aly_test.name,aly_test.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from aly_test natural right join test_global
select aly_test.id,aly_test.t_id,aly_test.name,aly_test.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from aly_test natural left outer join test_global
select aly_test.id,aly_test.t_id,aly_test.name,aly_test.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from aly_test natural right outer join test_global
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a natural left join test_global b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a natural right join test_global b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a natural left outer join test_global b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a natural right outer join test_global b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a natural left join (select * from test_global where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a natural right join (select * from test_global where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a natural left outer join (select * from test_global where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a natural right outer join (select * from test_global where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>1) a natural left join (select * from test_global where pad>3) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>1) a natural right join (select * from test_global where pad>3) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>1) a natural left outer join (select * from test_global where pad>3) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from aly_test where pad>1) a natural right outer join (select * from test_global where pad>3) b order by a.id,b.id
select aly_test.id,aly_test.t_id,aly_test.name,aly_test.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from aly_test left join test_global on aly_test.pad=test_global.pad and aly_test.id>3 order by aly_test.id,test_global.id
#
#distinct(special_scene)
#
(select pad from aly_test) union distinct (select pad from test_global)
(select * from aly_test where id=2) union distinct (select test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global where id=2)
select distinct a.pad from aly_test a,test_global b where a.pad=b.pad
select distinct b.pad,a.pad from aly_test a,(select test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global where pad=1) b where a.t_id=b.o_id
select count(distinct pad,name),avg(distinct t_id) from aly_test
select count(distinct id),sum(distinct name) from aly_test where id=3 or id=7
#
#clear tables
#
drop table if exists aly_test
drop table if exists test_global
drop table if exists a_manager