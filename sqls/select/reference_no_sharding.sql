#
#table_factor
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
create index pad_index on a_test_no_shard(pad)
##############unsupport################
#select * from a_test_no_shard t use index()
#select * from a_test_no_shard t use key()
select * from a_test_no_shard use index(k_1)
select * from a_test_no_shard ignore index(k_1)
select * from a_test_no_shard force index(k_1)
select * from a_test_no_shard use index(pad_index,k_1)
select * from a_test_no_shard ignore index(pad_index,k_1)
select * from a_test_no_shard force index(pad_index,k_1)
select * from a_test_no_shard use key for join(k_1)
select * from a_test_no_shard ignore key for join(k_1)
select * from a_test_no_shard force key for join(k_1)
select * from a_test_no_shard use key for order by(k_1)
select * from a_test_no_shard ignore key for order by(k_1)
select * from a_test_no_shard force key for order by(k_1)
select count(*) from a_test_no_shard use key for group by(k_1)
select count(*) from a_test_no_shard ignore key  for group by(k_1)
select count(*) from a_test_no_shard force key for group by(k_1)
select * from a_test_no_shard use index for join(pad_index,k_1)
select * from a_test_no_shard ignore index for join(pad_index,k_1)
select * from a_test_no_shard force index for join(pad_index,k_1)
select * from a_test_no_shard use key(k_1)
select * from a_test_no_shard ignore key(k_1)
select * from a_test_no_shard force key(k_1)
#########################unsupport################
#select * from a_test_no_shard t use key(k_1) use index(pad_index) use index()
#select * from a_test_no_shard t ignore key(k_1) use index(pad_index) use index()
#select * from a_test_no_shard t ignore key(k_1) ignore index(pad_index) use index()
select * from a_test_no_shard t force key(k_1) force index(pad_index) 
select * from a_test_no_shard t ignore key(k_1) force index(pad_index)
select id,pad,name from (select * from a_test_no_shard where pad>2) as a
select * from a_test_no_shard a,a_order_no_shard b
select * from (select * from a_test_no_shard where id<3) a,(select * from a_order_no_shard where id>3) b
select a.id,b.id,b.pad,a.t_id from a_test_no_shard a,(select a_manager_no_shard.id,a_manager_no_shard.pad from a_test_no_shard join a_manager_no_shard where a_test_no_shard.pad=a_manager_no_shard.pad) b,(select * from a_order_no_shard where id>3) c where a.pad=b.pad and c.pad=b.pad
#
#join table
#
select * from a_test_no_shard a join a_order_no_shard as b order by a.id,b.id
select * from a_test_no_shard a inner join a_order_no_shard b order by a.id,b.id
select * from a_test_no_shard a cross join a_order_no_shard b order by a.id,b.id
select a.id,a.name,a.pad,b.name from a_test_no_shard a straight_join a_order_no_shard b on a.pad=b.pad
#
#SELECT ... UNION [ALL | DISTINCT] SELECT ... [UNION [ALL | DISTINCT] SELECT ...]
#
select * from a_test_no_shard union all select * from a_manager_no_shard union all select * from a_order_no_shard
select * from a_test_no_shard union distinct select * from a_manager_no_shard union distinct select * from a_order_no_shard
(select name from a_test_no_shard where pad=1 order by id limit 10) union all (select name from a_order_no_shard where pad=1 order by id limit 10)
(select name from a_test_no_shard where pad=1 order by id limit 10) union distinct (select name from a_order_no_shard where pad=1 order by id limit 10)
(select * from a_test_no_shard where pad=1) union (select * from a_order_no_shard where pad=1) order by id limit 10
(select name as sort_a from a_test_no_shard where pad=1) union (select name from a_order_no_shard where pad=1) order by sort_a limit 10
(select name as sort_a,pad from a_test_no_shard where pad=1) union (select name,pad from a_order_no_shard where pad=1) order by sort_a,pad limit 10
drop table if exists a_test_no_shard
drop table if exists a_order_no_shard
drop table if exists a_manager_no_shard