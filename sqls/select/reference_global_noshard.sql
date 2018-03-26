#
#table_factor
#
drop table if exists test_global
drop table if exists a_order_no_shard
drop table if exists a_manager
CREATE TABLE test_global(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_order_no_shard(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_manager(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into test_global values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into a_order_no_shard values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_manager values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
create index pad_index on test_global(pad)
select * from test_global t use index()
select * from test_global t use key()
select * from test_global use index(k_1)
select * from test_global ignore index(k_1)
select * from test_global force index(k_1)
select * from test_global use index(pad_index,k_1)
select * from test_global ignore index(pad_index,k_1)
select * from test_global force index(pad_index,k_1)
select * from test_global use key for join(k_1)
select * from test_global ignore key for join(k_1)
select * from test_global force key for join(k_1)
select * from test_global use key for order by(k_1)
select * from test_global ignore key for order by(k_1)
select * from test_global force key for order by(k_1)
select count(*) from test_global use key for group by(k_1)
select count(*) from test_global ignore key  for group by(k_1)
select count(*) from test_global force key for group by(k_1)
select * from test_global use index for join(pad_index,k_1)
select * from test_global ignore index for join(pad_index,k_1)
select * from test_global force index for join(pad_index,k_1)
select * from test_global use key(k_1)
select * from test_global ignore key(k_1)
select * from test_global force key(k_1)
select * from test_global t use key(k_1) use index(pad_index) use index()
select * from test_global t ignore key(k_1) use index(pad_index) use index()
select * from test_global t ignore key(k_1) ignore index(pad_index) use index()
select * from test_global t force key(k_1) force index(pad_index)
select * from test_global t ignore key(k_1) force index(pad_index)
select id,pad,name from (select * from test_global where pad>2) as a
select * from test_global a,a_order_no_shard b
select * from (select * from test_global where id<3) a,(select * from a_order_no_shard where id>3) b
select a.id,b.id,b.pad,a.t_id from test_global a,(select a_manager.id,a_manager.pad from test_global join a_manager where test_global.pad=a_manager.pad) b,(select * from a_order_no_shard where id>3) c where a.pad=b.pad and c.pad=b.pad
#
#join table
#
select * from test_global a join a_order_no_shard as b order by a.id,b.id
select * from test_global a inner join a_order_no_shard b order by a.id,b.id
select * from test_global a cross join a_order_no_shard b order by a.id,b.id
select a.id,a.name,a.pad,b.name from test_global a straight_join a_order_no_shard b on a.pad=b.pad
#
#SELECT ... UNION [ALL | DISTINCT] SELECT ... [UNION [ALL | DISTINCT] SELECT ...]
#
select * from test_global union all select * from a_manager union all select * from a_order_no_shard
select * from test_global union distinct select * from a_manager union distinct select * from a_order_no_shard
(select name from test_global where pad=1 order by id limit 10) union all (select name from a_order_no_shard where pad=1 order by id limit 10)
(select name from test_global where pad=1 order by id limit 10) union distinct (select name from a_order_no_shard where pad=1 order by id limit 10)
(select * from test_global where pad=1) union (select * from a_order_no_shard where pad=1) order by id limit 10
(select name as sort_a from test_global where pad=1) union (select name from a_order_no_shard where pad=1) order by sort_a limit 10
(select name as sort_a,pad from test_global where pad=1) union (select name,pad from a_order_no_shard where pad=1) order by sort_a,pad limit 10
