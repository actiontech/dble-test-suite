#
#join syntax
#
drop table if exists a_test
drop table if exists a_order
drop table if exists a_manager
CREATE TABLE a_test(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_order(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_manager(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into a_test values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into a_order values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_manager values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
#
#, join
#
select * from a_test,a_order where a_test.pad=a_order.pad
select * from a_test a,a_order b where a.pad=b.pad
select distinct a_test.id from a_test,a_order where a_test.pad=a_order.pad
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_order where pad>3) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select id,t_id from a_test) a,(select * from a_order) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select a_test.id,a_test.pad,a_test.t_id from a_test join a_order where a_test.pad=a_order.pad ) a,(select a_manager.id,a_manager.pad from a_test join a_manager where a_test.pad=a_manager.pad) b where a.pad=b.pad
select a_test.id,a_test.name,a.name from a_test,(select name from a_order) a
#
# inner join /cross join/join 
#
select * from a_test inner join a_order order by a_test.id,a_order.id
select * from a_test cross join a_order order by a_test.id,a_order.id
select * from a_test join a_order order by a_test.id,a_order.id
select a.id,a.name,a.pad,b.name from a_test a inner join a_order b order by a.id,b.id
select a.id,a.name,a.pad,b.name from a_test a cross join a_order b order by a.id,b.id
select a.id,a.name,a.pad,b.name from a_test a join a_order b order by a.id,b.id
select * from a_test a inner join (select * from a_order where pad>2) b order by a.id,b.id
select * from a_test a cross join (select * from a_order where pad>2) b order by a.id,b.id
select * from a_test a join (select * from a_order where pad>2) b order by a.id,b.id
select * from (select * from a_test where pad>2) a inner join (select * from a_order where pad>2) b order by a.id,b.id
select * from (select * from a_test where pad>2) a cross join (select * from a_order where pad>2) b order by a.id,b.id
select * from (select * from a_test where pad>2) a join (select * from a_order where pad>2) b order by a.id,b.id
select * from a_test a join (select * from a_order where pad>2) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select * from a_test a join (select * from a_order where pad>2) b  using(pad) order by a.id,b.id
select * from a_test a join a_order as b order by a.id,b.id
select * from a_test a inner join a_order b order by a.id,b.id
select * from a_test a cross join a_order b order by a.id,b.id
select * from a_test straight_join a_order order by a_test.id,a_order.id
select a.id,a.name,a.pad,b.name from a_test a straight_join a_order b order by a.id,b.id
#
#straight_join
#
select * from a_test straight_join a_order order by a_test.id,a_order.id
select a.id,a.name,a.pad,b.name from a_test a straight_join a_order b order by a.id,b.id
select * from a_test a straight_join (select * from a_order where pad>0) b order by a.id,b.id
select * from (select * from a_test where pad>0) a straight_join (select * from a_order where pad>0) b order by a.id,b.id
select * from a_test a straight_join (select * from a_order where pad>0) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select a.id,a.name,a.pad,b.name from a_test a straight_join a_order b on a.pad=b.pad
#
#left join/right join/outer join
#
select * from a_test left join a_order on a_test.pad=a_order.pad order by a_test.id,a_order.id
select * from a_test right join a_order on a_test.pad=a_order.pad order by a_test.id,a_order.id
select * from a_test left outer join a_order on a_test.pad=a_order.pad order by a_test.id,a_order.id
select * from a_test right outer join a_order on a_test.pad=a_order.pad order by a_test.id,a_order.id
select * from a_test left join a_order using(pad) order by a_test.id,a_order.id
select * from a_test a left join a_order b on a.pad=b.pad order by a.id,b.id
select * from a_test a right join a_order b on a.pad=b.pad order by a.id,b.id
select * from a_test a left outer join a_order b on a.pad=b.pad order by a.id,b.id
select * from a_test a right outer join a_order b on a.pad=b.pad order by a.id,b.id
select * from a_test a left join a_order b using(pad) order by a.id,b.id
select * from a_test a left join (select * from a_order where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from a_test a right join (select * from a_order where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from a_test a left outer join (select * from a_order where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from a_test a right outer join (select * from a_order where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from a_test a left join (select * from a_order where pad>2) b using(pad) order by a.id,b.id
select * from (select * from a_test where pad>1) a left join (select * from a_order where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from a_test where pad>1) a right join (select * from a_order where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from a_test where pad>1) a left outer join (select * from a_order where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from a_test where pad>1) a right outer join (select * from a_order where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from a_test where pad>1) a left join (select * from a_order where pad>3) b using(pad) order by a.id,b.id
#
#natural left/right/outer join
#
select * from a_test natural left join a_order
select * from a_test natural right join a_order
select * from a_test natural left outer join a_order
select * from a_test natural right outer join a_order
select * from a_test a natural left join a_order b order by a.id,b.id
select * from a_test a natural right join a_order b order by a.id,b.id
select * from a_test a natural left outer join a_order b order by a.id,b.id
select * from a_test a natural right outer join a_order b order by a.id,b.id
select * from a_test a natural left join (select * from a_order where pad>2) b order by a.id,b.id
select * from a_test a natural right join (select * from a_order where pad>2) b order by a.id,b.id
select * from a_test a natural left outer join (select * from a_order where pad>2) b order by a.id,b.id
select * from a_test a natural right outer join (select * from a_order where pad>2) b order by a.id,b.id
select * from (select * from a_test where pad>1) a natural left join (select * from a_order where pad>3) b order by a.id,b.id
select * from (select * from a_test where pad>1) a natural right join (select * from a_order where pad>3) b order by a.id,b.id
select * from (select * from a_test where pad>1) a natural left outer join (select * from a_order where pad>3) b order by a.id,b.id
select * from (select * from a_test where pad>1) a natural right outer join (select * from a_order where pad>3) b order by a.id,b.id
#
#on+and
#
select * from a_test left join a_order on a_test.pad=a_order.pad and a_test.id>3 order by a_test.id,a_order.id
#
#distinct(special_scene)
#
SELECT DISTINCT a_test.id FROM a_test,a_order where a_test.pad=a_order.pad
#
#where
#
select  * from a_test a left join a_order b on a.pad=b.pad where b.pad is null
select  * from a_test a left join a_order b on a.pad=b.pad where b.pad is not null
select  * from a_test a left join a_order b on a.pad=b.pad where b.pad in(2,3,null)
select * from a_test a left join a_order b on a.pad=b.pad where a.t_id>b.o_id
select * from a_test a left join a_order b on a.pad=b.pad where a.t_id<b.o_id
select * from a_test a left join a_order b on a.pad=b.pad where a.t_id=b.o_id
#
#group by/order by
#
select  count(*) from a_test a left join a_order b on a.pad=b.pad group by b.pad
select * from a_test a left join (select * from a_order where pad>2 order by id) b on a.pad=b.pad order by a.id
select * from a_test a left join (select pad,count(*) from a_order group by pad) b on a.pad=b.pad
#
#union
#
select * from a_test union select * from a_order
select * from a_test union all select * from a_order
select * from a_test union distinct select * from a_order
select * from a_test union (select * from a_order)
(select * from a_test) union (select * from a_order)
select * from a_test union select * from a_order
(select * from a_test order by id)union select * from a_order
select * from a_test union (select * from a_order order by id)
select * from a_test union select * from a_order order by id
(select * from a_test) union (select * from a_order) order by id
(select pad from a_test) union distinct (select pad from a_order)
select distinct a.pad from a_test a,a_order b where a.pad=b.pad
(select * from a_test where id=2) union distinct (select * from a_order where id=2)
select distinct a.pad from a_test a,a_order b where a.pad=b.pad
select distinct b.pad,a.pad from a_test a,(select * from a_order where pad=1) b where a.t_id=b.o_id
select count(distinct pad,name),avg(distinct t_id) from a_test
select count(distinct id),sum(distinct name) from a_test where id=3 or id=7
select * from a_test union all select * from a_manager union all select * from a_order
select * from a_test union distinct select * from a_manager union distinct select * from a_order
(select name from a_test where pad=1 order by id limit 10) union all (select name from a_order where pad=1 order by id limit 10)/*allow_diff_sequence*/
(select name from a_test where pad=1 order by id limit 10) union distinct (select name from a_order where pad=1 order by id limit 10)/*allow_diff_sequence*/
(select * from a_test where pad=1) union (select * from a_order where pad=1) order by id limit 10
(select name as sort_a from a_test where pad=1) union (select name from a_order where pad=1) order by sort_a limit 10
(select name as sort_a,pad from a_test where pad=1) union (select name,pad from a_order where pad=1) order by sort_a,pad limit 10
select 1 union select 1
(select * from a_test left join a_order on a_test.pad=a_order.pad order by a_test.id,a_order.id)union (select * from a_order left join a_manager on a_order.pad=a_manager.pad)
select * from a_manager,(select * from a_test where id>3 union select * from a_order where id<2) a 
(select * from a_test order by id limit 0,3) union (select * from a_manager order by id limit 10,3) union (select * from a_order order by id limit 20,3)
#
#more than two tables join
#
select a.id,b.id,c.pad from a_test a,a_order b,a_manager c where a.id=b.id and a.id=c.pad
drop table if exists a_test
drop table if exists a_order
drop table if exists a_manager