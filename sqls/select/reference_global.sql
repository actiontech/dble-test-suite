#
#table_factor
#
drop table if exists test_global
drop table if exists global_table2
drop table if exists global_table3
CREATE TABLE test_global(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE global_table2(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE global_table3(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into test_global values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into global_table2 values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into global_table3 values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
create index pad_index on test_global(pad)
select id,t_id,name,pad from test_global t use index()
select id,t_id,name,pad from test_global t use key()
select id,t_id,name,pad from test_global use index(k_1)
select id,t_id,name,pad from test_global ignore index(k_1)
select id,t_id,name,pad from test_global force index(k_1)
select id,t_id,name,pad from test_global use index(pad_index,k_1)
select id,t_id,name,pad from test_global ignore index(pad_index,k_1)
select id,t_id,name,pad from test_global force index(pad_index,k_1)
select id,t_id,name,pad from test_global use key for join(k_1)
select id,t_id,name,pad from test_global ignore key for join(k_1)
select id,t_id,name,pad from test_global force key for join(k_1)
select id,t_id,name,pad from test_global use key for order by(k_1) order by t_id
select id,t_id,name,pad from test_global ignore key for order by(k_1)
select id,t_id,name,pad from test_global force key for order by(k_1) order by t_id
select count(*) from test_global use key for group by(k_1)
select count(*) from test_global ignore key  for group by(k_1)
select count(*) from test_global force key for group by(k_1)
select id,t_id,name,pad from test_global use index for join(pad_index,k_1)
select id,t_id,name,pad from test_global ignore index for join(pad_index,k_1)
select id,t_id,name,pad from test_global force index for join(pad_index,k_1)
select id,t_id,name,pad from test_global use key(k_1)
select id,t_id,name,pad from test_global ignore key(k_1)
select id,t_id,name,pad from test_global force key(k_1)
select id,t_id,name,pad from test_global t use key(k_1) use index(pad_index) use index()
select id,t_id,name,pad from test_global t ignore key(k_1) use index(pad_index) use index()
select id,t_id,name,pad from test_global t ignore key(k_1) ignore index(pad_index) use index()
select id,t_id,name,pad from test_global t force key(k_1) force index(pad_index)
select id,t_id,name,pad from test_global t ignore key(k_1) force index(pad_index)
select id,pad,name from (select * from test_global where pad>2) as a
select a.id,a.t_id,b.o_id,b.name from test_global a,global_table2 b
select a.id,a.t_id,b.o_id,b.name from (select * from test_global where id<3) a,(select * from global_table2 where id>3) b
select a.id,b.id,b.pad,a.t_id from test_global a,(select global_table3.id,global_table3.pad from test_global join global_table3 where test_global.pad=global_table3.pad) b,(select * from global_table2 where id>3) c where a.pad=b.pad and c.pad=b.pad
#
#join table
#
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a join global_table2 as b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a inner join global_table2 b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a cross join global_table2 b order by a.id,b.id
select a.id,a.name,a.pad,b.name from test_global a straight_join global_table2 b on a.pad=b.pad
#
#SELECT ... UNION [ALL | DISTINCT] SELECT ... [UNION [ALL | DISTINCT] SELECT ...]
#
select a.id,a.t_id,a.name,a.pad from test_global a union all select b.id,b.m_id,b.name,b.pad from global_table3 b union all select c.id,c.o_id,c.name,c.pad from global_table2 c
select a.id,a.t_id,a.name,a.pad from test_global a union distinct select b.id,b.m_id,b.name,b.pad from global_table3 b union distinct select c.id,c.o_id,c.name,c.pad from global_table2 c
(select name from test_global where pad=1 order by id limit 10) union all (select name from global_table2 where pad=1 order by id limit 10)/*allow_diff_sequence*/
(select name from test_global where pad=1 order by id limit 10) union distinct (select name from global_table2 where pad=1 order by id limit 10)/*allow_diff_sequence*/
(select a.id,a.t_id,a.name,a.pad from test_global a where a.pad=1) union (select c.id,c.o_id,c.name,c.pad from global_table2 c where c.pad=1) order by id limit 10/*allow_diff_sequence*/
(select name as sort_a from test_global where pad=1) union (select name from global_table2 where pad=1) order by sort_a limit 10/*allow_diff_sequence*/
(select name as sort_a,pad from test_global where pad=1) union (select name,pad from global_table2 where pad=1) order by sort_a,pad limit 10/*allow_diff_sequence*/
#
#clear tables
#
drop table if exists test_global
drop table if exists global_table2
drop table if exists global_table3