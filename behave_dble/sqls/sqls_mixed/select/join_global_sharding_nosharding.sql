#!default_db:schema1
# Created by zhaohongjie at 2019/1/11
drop table if exists noshard_t1
drop table if exists sharding_4_t1
drop table if exists schema2.global_4_t1
CREATE TABLE noshard_t1(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE sharding_4_t1(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
CREATE TABLE schema2.global_4_t1(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
insert into noshard_t1 values(1,1,'noshard_t1中id为1',1),(2,2,'test_2',2),(3,3,'noshard_t1中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into sharding_4_t1 values(1,1,'sharding_4_t1中id为1',1),(2,2,'test_2',2),(3,3,'sharding_4_t1中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
insert into schema2.global_4_t1 values(1,1,'global_4_t1中id为1',1),(2,2,'test_2',2),(3,3,'global_4_t1中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
#
#join table
#
select a.id,b.id,b.pad,a.o_id from (select noshard_t1.id,noshard_t1.pad,noshard_t1.o_id from noshard_t1 join schema2.global_4_t1 where noshard_t1.pad=schema2.global_4_t1.pad ) a,(select sharding_4_t1.id,sharding_4_t1.pad from noshard_t1 join sharding_4_t1 where noshard_t1.pad=sharding_4_t1.pad) b where a.pad=b.pad
select a.id,b.id,b.pad,a.m_id from (select sharding_4_t1.id,sharding_4_t1.pad,sharding_4_t1.m_id from sharding_4_t1 join schema2.global_4_t1 where sharding_4_t1.pad=schema2.global_4_t1.pad ) a,(select s2.id,s1.pad from sharding_4_t1 s1 join sharding_4_t1 s2 where s1.pad=s2.pad) b where a.pad=b.pad
select a.id,b.id,b.pad,a.t_id from schema2.global_4_t1 a,(select sharding_4_t1.id,sharding_4_t1.pad from schema2.global_4_t1 join sharding_4_t1 where schema2.global_4_t1.pad=sharding_4_t1.pad) b,(select * from noshard_t1 where id>3) c where a.pad=b.pad and c.pad=b.pad
select a.id,b.id,b.pad,a.o_id from (select noshard_t1.id,noshard_t1.pad,noshard_t1.o_id from noshard_t1 join sharding_4_t1 where noshard_t1.pad=sharding_4_t1.pad ) a,(select schema2.global_4_t1.id,schema2.global_4_t1.pad from noshard_t1 join schema2.global_4_t1 where noshard_t1.pad=schema2.global_4_t1.pad) b where a.pad=b.pad order by a.id,b.id limit 4
#
#SELECT ... UNION [ALL | DISTINCT] SELECT ... [UNION [ALL | DISTINCT] SELECT ...]
#
select a.id,a.t_id,a.name,a.pad from schema2.global_4_t1 a union all select b.id,b.m_id,b.name,b.pad from sharding_4_t1 b union all select c.id,c.o_id,c.name,c.pad from noshard_t1 c
select a.id,a.t_id,a.name,a.pad from schema2.global_4_t1 a union distinct select b.id,b.m_id,b.name,b.pad from sharding_4_t1 b union distinct select c.id,c.o_id,c.name,c.pad from noshard_t1 c

drop table if exists noshard_t1
drop table if exists sharding_4_t1
drop table if exists schema2.global_4_t1
