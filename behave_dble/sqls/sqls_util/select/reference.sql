#!default_db:schema1
#
#table_factor
#
drop table if exists test1
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
insert into test1 values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
create index pad_index on test1(pad)

select id,t_id,name,pad from test1 t use index()
select id,t_id,name,pad from test1 t use key()
select id,t_id,name,pad from test1 use index(k_1)
select id,t_id,name,pad from test1 ignore index(k_1)
select id,t_id,name,pad from test1 force index(k_1)
select id,t_id,name,pad from test1 use index(pad_index,k_1)
select id,t_id,name,pad from test1 ignore index(pad_index,k_1)
select id,t_id,name,pad from test1 force index(pad_index,k_1)
select id,t_id,name,pad from test1 use key for join(k_1)
select id,t_id,name,pad from test1 ignore key for join(k_1)
select id,t_id,name,pad from test1 force key for join(k_1)
select id,t_id,name,pad from test1 use key for order by(k_1) order by t_id
select id,t_id,name,pad from test1 ignore key for order by(k_1)/*allow_diff_sequence*/
select id,t_id,name,pad from test1 force key for order by(k_1) order by t_id
select count(*) from test1 use key for group by(k_1)
select count(*) from test1 ignore key  for group by(k_1)
select count(*) from test1 force key for group by(k_1)
select id,t_id,name,pad from test1 use index for join(pad_index,k_1)
select id,t_id,name,pad from test1 ignore index for join(pad_index,k_1)
select id,t_id,name,pad from test1 force index for join(pad_index,k_1)
select id,t_id,name,pad from test1 use key(k_1)
select id,t_id,name,pad from test1 ignore key(k_1)
select id,t_id,name,pad from test1 force key(k_1)
select id,t_id,name,pad FROM test1 use INDEX (k_1) use INDEX (pad_index)
select id,t_id,name,pad from test1 t use key(k_1) use index(pad_index) use index()
select id,t_id,name,pad from test1 t ignore key(k_1) use index(pad_index) use index()
select id,t_id,name,pad from test1 t ignore key(k_1) ignore index(pad_index) use index()
select id,t_id,name,pad from test1 t force key(k_1) force index(pad_index)
select id,t_id,name,pad from test1 t ignore key(k_1) force index(pad_index)
select id,t_id,name,pad from test1 t ignore key(k_1) ignore index(pad_index)
select id,pad,name from (select * from test1 where pad>2) as a
#
#clear tables
#
drop table if exists test1