#
#join syntax
#
drop table if exists aly_test
drop table if exists aly_order
drop table if exists a_manager
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE aly_order(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_manager(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into aly_test values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into aly_order values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_manager values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
#
#, join
#
select * from aly_test,aly_order where aly_test.pad=aly_order.pad
select * from aly_test a,aly_order b where a.pad=b.pad
select distinct aly_test.id from aly_test,aly_order where aly_test.pad=aly_order.pad
select a.id,b.id,b.pad,a.t_id from aly_test a,(select * from aly_order where pad>3) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select id,t_id from aly_test) a,(select * from aly_order) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select aly_test.id,aly_test.pad,aly_test.t_id from aly_test join aly_order where aly_test.pad=aly_order.pad ) a,(select a_manager.id,a_manager.pad from aly_test join a_manager where aly_test.pad=a_manager.pad) b where a.pad=b.pad
select aly_test.id,aly_test.name,a.name from aly_test,(select name from aly_order) a
#
# inner join /cross join/join 
#
select * from aly_test inner join aly_order order by aly_test.id,aly_order.id
select * from aly_test cross join aly_order order by aly_test.id,aly_order.id
select * from aly_test join aly_order order by aly_test.id,aly_order.id
select a.id,a.name,a.pad,b.name from aly_test a inner join aly_order b order by a.id,b.id
select a.id,a.name,a.pad,b.name from aly_test a cross join aly_order b order by a.id,b.id
select a.id,a.name,a.pad,b.name from aly_test a join aly_order b order by a.id,b.id
select * from aly_test a inner join (select * from aly_order where pad>2) b order by a.id,b.id
select * from aly_test a cross join (select * from aly_order where pad>2) b order by a.id,b.id
select * from aly_test a join (select * from aly_order where pad>2) b order by a.id,b.id
select * from (select * from aly_test where pad>2) a inner join (select * from aly_order where pad>2) b order by a.id,b.id
select * from (select * from aly_test where pad>2) a cross join (select * from aly_order where pad>2) b order by a.id,b.id
select * from (select * from aly_test where pad>2) a join (select * from aly_order where pad>2) b order by a.id,b.id
select * from aly_test a join (select * from aly_order where pad>2) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select * from aly_test a join (select * from aly_order where pad>2) b  using(pad) order by a.id,b.id
select * from aly_test a join aly_order as b order by a.id,b.id
select * from aly_test a inner join aly_order b order by a.id,b.id
select * from aly_test a cross join aly_order b order by a.id,b.id
select * from aly_test straight_join aly_order order by aly_test.id,aly_order.id
select a.id,a.name,a.pad,b.name from aly_test a straight_join aly_order b order by a.id,b.id
#
#straight_join
#
select * from aly_test straight_join aly_order order by aly_test.id,aly_order.id
select a.id,a.name,a.pad,b.name from aly_test a straight_join aly_order b order by a.id,b.id
select * from aly_test a straight_join (select * from aly_order where pad>0) b order by a.id,b.id
select * from (select * from aly_test where pad>0) a straight_join (select * from aly_order where pad>0) b order by a.id,b.id
select * from aly_test a straight_join (select * from aly_order where pad>0) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select a.id,a.name,a.pad,b.name from aly_test a straight_join aly_order b on a.pad=b.pad
#
#left join/right join/outer join
#
select * from aly_test left join aly_order on aly_test.pad=aly_order.pad order by aly_test.id,aly_order.id
select * from aly_test right join aly_order on aly_test.pad=aly_order.pad order by aly_test.id,aly_order.id
select * from aly_test left outer join aly_order on aly_test.pad=aly_order.pad order by aly_test.id,aly_order.id
select * from aly_test right outer join aly_order on aly_test.pad=aly_order.pad order by aly_test.id,aly_order.id
select * from aly_test left join aly_order using(pad) order by aly_test.id,aly_order.id
select * from aly_test a left join aly_order b on a.pad=b.pad order by a.id,b.id
select * from aly_test a right join aly_order b on a.pad=b.pad order by a.id,b.id
select * from aly_test a left outer join aly_order b on a.pad=b.pad order by a.id,b.id
select * from aly_test a right outer join aly_order b on a.pad=b.pad order by a.id,b.id
select * from aly_test a left join aly_order b using(pad) order by a.id,b.id
select * from aly_test a left join (select * from aly_order where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from aly_test a right join (select * from aly_order where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from aly_test a left outer join (select * from aly_order where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from aly_test a right outer join (select * from aly_order where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from aly_test a left join (select * from aly_order where pad>2) b using(pad) order by a.id,b.id
select * from (select * from aly_test where pad>1) a left join (select * from aly_order where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from aly_test where pad>1) a right join (select * from aly_order where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from aly_test where pad>1) a left outer join (select * from aly_order where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from aly_test where pad>1) a right outer join (select * from aly_order where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from aly_test where pad>1) a left join (select * from aly_order where pad>3) b using(pad) order by a.id,b.id
#
#natural left/right/outer join
#
select * from aly_test natural left join aly_order
select * from aly_test natural right join aly_order
select * from aly_test natural left outer join aly_order
select * from aly_test natural right outer join aly_order
select * from aly_test a natural left join aly_order b order by a.id,b.id
select * from aly_test a natural right join aly_order b order by a.id,b.id
select * from aly_test a natural left outer join aly_order b order by a.id,b.id
select * from aly_test a natural right outer join aly_order b order by a.id,b.id
select * from aly_test a natural left join (select * from aly_order where pad>2) b order by a.id,b.id
select * from aly_test a natural right join (select * from aly_order where pad>2) b order by a.id,b.id
select * from aly_test a natural left outer join (select * from aly_order where pad>2) b order by a.id,b.id
select * from aly_test a natural right outer join (select * from aly_order where pad>2) b order by a.id,b.id
select * from (select * from aly_test where pad>1) a natural left join (select * from aly_order where pad>3) b order by a.id,b.id
select * from (select * from aly_test where pad>1) a natural right join (select * from aly_order where pad>3) b order by a.id,b.id
select * from (select * from aly_test where pad>1) a natural left outer join (select * from aly_order where pad>3) b order by a.id,b.id
select * from (select * from aly_test where pad>1) a natural right outer join (select * from aly_order where pad>3) b order by a.id,b.id
#
#on+and
#
select * from aly_test left join aly_order on aly_test.pad=aly_order.pad and aly_test.id>3 order by aly_test.id,aly_order.id
#
#distinct(special_scene)
#
SELECT DISTINCT aly_test.id FROM aly_test,aly_order where aly_test.pad=aly_order.pad
#
#where
#
select  * from aly_test a left join aly_order b on a.pad=b.pad where b.pad is null
select  * from aly_test a left join aly_order b on a.pad=b.pad where b.pad is not null
select  * from aly_test a left join aly_order b on a.pad=b.pad where b.pad in(2,3,null)
select * from aly_test a left join aly_order b on a.pad=b.pad where a.t_id>b.o_id
select * from aly_test a left join aly_order b on a.pad=b.pad where a.t_id<b.o_id
select * from aly_test a left join aly_order b on a.pad=b.pad where a.t_id=b.o_id
#
#group by/order by
#
select  count(*) from aly_test a left join aly_order b on a.pad=b.pad group by b.pad
select * from aly_test a left join (select * from aly_order where pad>2 order by id) b on a.pad=b.pad order by a.id
select * from aly_test a left join (select pad,count(*) from aly_order group by pad) b on a.pad=b.pad
#
#union
#
select * from aly_test union select * from aly_order
select * from aly_test union all select * from aly_order
select * from aly_test union distinct select * from aly_order
select * from aly_test union (select * from aly_order)
(select * from aly_test) union (select * from aly_order)
select * from aly_test union select * from aly_order
(select * from aly_test order by id)union select * from aly_order/*allow_diff_sequence*/
select * from aly_test union (select * from aly_order order by id)/*allow_diff_sequence*/
select * from aly_test union select * from aly_order order by id/*allow_diff_sequence*/
(select * from aly_test) union (select * from aly_order) order by name/*allow_diff_sequence*/
(select pad from aly_test) union distinct (select pad from aly_order)
select distinct a.pad from aly_test a,aly_order b where a.pad=b.pad
(select * from aly_test where id=2) union distinct (select * from aly_order where id=2)
select distinct a.pad from aly_test a,aly_order b where a.pad=b.pad
select distinct b.pad,a.pad from aly_test a,(select * from aly_order where pad=1) b where a.t_id=b.o_id
select count(distinct pad,name),avg(distinct t_id) from aly_test
select count(distinct id),sum(distinct name) from aly_test where id=3 or id=7
select * from aly_test union all select * from a_manager union all select * from aly_order
select * from aly_test union distinct select * from a_manager union distinct select * from aly_order
(select name from aly_test where pad=1 order by id limit 10) union all (select name from aly_order where pad=1 order by id limit 10)/*allow_diff_sequence*/
(select name from aly_test where pad=1 order by id limit 10) union distinct (select name from aly_order where pad=1 order by id limit 10)/*allow_diff_sequence*/
(select * from aly_test where pad=1) union (select * from aly_order where pad=1) order by name limit 10
(select name as sort_a from aly_test where pad=1) union (select name from aly_order where pad=1) order by sort_a limit 10
(select name as sort_a,pad from aly_test where pad=1) union (select name,pad from aly_order where pad=1) order by sort_a,pad limit 10
select 1 union select 1
(select * from aly_test left join aly_order on aly_test.pad=aly_order.pad order by aly_test.id,aly_order.id)union (select * from aly_order left join a_manager on aly_order.pad=a_manager.pad)order by t_id, o_id/*allow_diff_sequence*/
select * from a_manager,(select * from aly_test where id>3 union select * from aly_order where id<2) a
(select * from aly_test order by id limit 0,3) union (select * from a_manager order by id limit 10,3) union (select * from aly_order order by id limit 20,3)
(select a.id, a.name, b.name from aly_test a left join aly_order b on a.pad=b.pad) union(select a_manager.id, a_manager.name, a_manager.name from a_manager)/*allow_diff_sequence*/
#
#more than two tables join
#
-- select a.id,b.id,c.pad from aly_test a,aly_order b,a_manager c where a.id=b.id and a.id=c.pad
#
#clear tables
#
drop table if exists aly_test
drop table if exists aly_order
drop table if exists a_manager