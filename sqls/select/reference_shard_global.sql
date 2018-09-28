#
#table_factor
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
create index pad_index on aly_test(pad)
select id,t_id,name,pad from aly_test t use index()
select id,t_id,name,pad from aly_test t use key()
select id,t_id,name,pad from aly_test use index(k_1)
select id,t_id,name,pad from aly_test ignore index(k_1)
select id,t_id,name,pad from aly_test force index(k_1)
select id,t_id,name,pad from aly_test use index(pad_index,k_1)
select id,t_id,name,pad from aly_test ignore index(pad_index,k_1)
select id,t_id,name,pad from aly_test force index(pad_index,k_1)
select id,t_id,name,pad from aly_test use key for join(k_1)
select id,t_id,name,pad from aly_test ignore key for join(k_1)
select id,t_id,name,pad from aly_test force key for join(k_1)
select id,t_id,name,pad from aly_test use key for order by(k_1) order by t_id
select id,t_id,name,pad from aly_test ignore key for order by(k_1)
select id,t_id,name,pad from aly_test force key for order by(k_1) order by t_id
select count(*) from aly_test use key for group by(k_1)
select count(*) from aly_test ignore key  for group by(k_1)
select count(*) from aly_test force key for group by(k_1)
select id,t_id,name,pad from aly_test use index for join(pad_index,k_1)
select id,t_id,name,pad from aly_test ignore index for join(pad_index,k_1)
select id,t_id,name,pad from aly_test force index for join(pad_index,k_1)
select id,t_id,name,pad from aly_test use key(k_1)
select id,t_id,name,pad from aly_test ignore key(k_1)
select id,t_id,name,pad from aly_test force key(k_1)
select id,t_id,name,pad from aly_test t use key(k_1) use index(pad_index) use index()
select id,t_id,name,pad from aly_test t ignore key(k_1) use index(pad_index) use index()
select id,t_id,name,pad from aly_test t ignore key(k_1) ignore index(pad_index) use index()
select id,t_id,name,pad from aly_test t force key(k_1) force index(pad_index)
select id,t_id,name,pad from aly_test t ignore key(k_1) force index(pad_index)
select id,pad,name from (select * from aly_test where pad>2) as a
select a.id,a.t_id,b.o_id,b.name from aly_test a,test_global b
select a.id,a.t_id,b.o_id,b.name from (select * from aly_test where id<3) a,(select * from test_global where id>3) b
select a.id,b.id,b.pad,a.t_id from aly_test a,(select a_manager.id,a_manager.pad from aly_test join a_manager where aly_test.pad=a_manager.pad) b,(select * from test_global where id>3) c where a.pad=b.pad and c.pad=b.pad
#
#join table
#
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a join test_global as b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a inner join test_global b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from aly_test a cross join test_global b order by a.id,b.id
select a.id,a.name,a.pad,b.name from aly_test a straight_join test_global b on a.pad=b.pad
#
#SELECT ... UNION [ALL | DISTINCT] SELECT ... [UNION [ALL | DISTINCT] SELECT ...]
#
select * from aly_test union all select * from a_manager union all select c.id,c.o_id,c.name,c.pad from test_global c
select * from aly_test union distinct select * from a_manager union distinct select c.id,c.o_id,c.name,c.pad from test_global c
(select name from aly_test where pad=1 order by id limit 10) union all (select name from test_global where pad=1 order by id limit 10) order by name
(select name from aly_test where pad=1 order by id limit 10) union distinct (select name from test_global where pad=1 order by id limit 10) order by name
(select * from aly_test where pad=1) union (select c.id,c.o_id,c.name,c.pad from test_global c where pad=1) order by name limit 10
(select name as sort_a from aly_test where pad=1) union (select name from test_global where pad=1) order by sort_a limit 10
(select name as sort_a,pad from aly_test where pad=1) union (select name,pad from test_global where pad=1) order by sort_a,pad limit 10
#
#clear tables
#
drop table if exists aly_test
drop table if exists test_global
drop table if exists a_manager