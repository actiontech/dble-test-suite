#
#join syntax
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
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global,global_table2 where test_global.pad=global_table2.pad
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a,global_table2 b where a.pad=b.pad
select a.id,b.id,b.pad,a.t_id from test_global a,(select * from global_table2 where pad>3) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select id,t_id from test_global) a,(select * from global_table2) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select test_global.id,test_global.pad,test_global.t_id from test_global join global_table2 where test_global.pad=global_table2.pad ) a,(select global_table3.id,global_table3.pad from test_global join global_table3 where test_global.pad=global_table3.pad) b where a.pad=b.pad
select test_global.id,test_global.name,a.name from test_global,(select name from global_table2) a
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global inner join global_table2 order by test_global.id,global_table2.id
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global cross join global_table2 order by test_global.id,global_table2.id
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global join global_table2 order by test_global.id,global_table2.id
select a.id,a.name,a.pad,b.name from test_global a inner join global_table2 b order by a.id,b.id
select a.id,a.name,a.pad,b.name from test_global a cross join global_table2 b order by a.id,b.id
select a.id,a.name,a.pad,b.name from test_global a join global_table2 b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a inner join (select * from global_table2 where pad>0) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a cross join (select * from global_table2 where pad>0) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a join (select * from global_table2 where pad>0) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>0) a inner join (select * from global_table2 where pad>0) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>0) a cross join (select * from global_table2 where pad>0) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>0) a join (select * from global_table2 where pad>0) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a join (select * from global_table2 where pad>0) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a join (select * from global_table2 where pad>0) b  using(pad) order by a.id,b.id
select a_test_no_shard.id,a_test_no_shard.t_id,a_test_no_shard.name,a_test_no_shard.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global straight_join global_table2 order by test_global.id,global_table2.id
select a.id,a.name,a.pad,b.name from test_global a straight_join global_table2 b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a straight_join (select * from global_table2 where pad>0) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>0) a straight_join (select * from global_table2 where pad>0) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a straight_join (select * from global_table2 where pad>0) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global left join global_table2 on test_global.pad=global_table2.pad order by test_global.id,global_table2.id
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global right join global_table2 on test_global.pad=global_table2.pad order by test_global.id,global_table2.id
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global left outer join global_table2 on test_global.pad=global_table2.pad order by test_global.id,global_table2.id
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global right outer join global_table2 on test_global.pad=global_table2.pad order by test_global.id,global_table2.id
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global left join global_table2 using(pad) order by test_global.id,global_table2.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a left join global_table2 b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a right join global_table2 b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a left outer join global_table2 b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a right outer join global_table2 b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a left join global_table2 b using(pad) order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a left join (select * from global_table2 where pad>2) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a right join (select * from global_table2 where pad>2) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a left outer join (select * from global_table2 where pad>2) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a right outer join (select * from global_table2 where pad>2) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a left join (select * from global_table2 where pad>2) b using(pad) order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>1) a left join (select * from global_table2 where pad>3) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>1) a right join (select * from global_table2 where pad>3) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>1) a left outer join (select * from global_table2 where pad>3) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>1) a right outer join (select * from global_table2 where pad>3) b on a.pad=b.pad order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>1) a left join (select * from global_table2 where pad>3) b using(pad) order by a.id,b.id
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global natural left join global_table2
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global natural right join global_table2
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global natural left outer join global_table2
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global natural right outer join global_table2
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a natural left join global_table2 b order by a.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a natural right join global_table2 b order by b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a natural left outer join global_table2 b order by a.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a natural right outer join global_table2 b order by b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a natural left join (select * from global_table2 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a natural right join (select * from global_table2 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a natural left outer join (select * from global_table2 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from test_global a natural right outer join (select * from global_table2 where pad>2) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>1) a natural left join (select * from global_table2 where pad>3) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>1) a natural right join (select * from global_table2 where pad>3) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>1) a natural left outer join (select * from global_table2 where pad>3) b order by a.id,b.id
select a.id,a.t_id,a.name,a.pad,b.id,b.o_id,b.name,b.pad from (select * from test_global where pad>1) a natural right outer join (select * from global_table2 where pad>3) b order by a.id,b.id
select test_global.id,test_global.t_id,test_global.name,test_global.pad,test_global.id,test_global.o_id,test_global.name,test_global.pad from test_global left join global_table2 on test_global.pad=global_table2.pad and test_global.id>3 order by test_global.id,global_table2.id
#
#distinct(special_scene)
#
(select pad from test_global) union distinct (select pad from global_table2)
(select * from test_global where id=2) union distinct (select test_global.id,test_global.o_id,test_global.name,test_global.pad from global_table2 where id=2)
select distinct a.pad from test_global a,global_table2 b where a.pad=b.pad
select distinct b.pad,a.pad from test_global a,(select * from global_table2 where pad=1) b where a.t_id=b.o_id
select count(distinct pad,name),avg(distinct t_id) from test_global
select count(distinct id),sum(distinct name) from test_global where id=3 or id=7
