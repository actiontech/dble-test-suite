#
#join syntax
#
drop table if exists a_test
drop table if exists a_two
drop table if exists a_three
CREATE TABLE a_test(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_two(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_three(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into a_test values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into a_two values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_three values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
select * from a_test,a_two where a_test.pad=a_two.pad
select * from a_test a,a_two b where a.pad=b.pad
select a.id,b.id,b.pad,a.t_id from a_test a,(select * from a_two where pad>3) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select id,t_id from a_test) a,(select * from a_two) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select a_test.id,a_test.pad,a_test.t_id from a_test join a_two where a_test.pad=a_two.pad ) a,(select a_three.id,a_three.pad from a_test join a_three where a_test.pad=a_three.pad) b where a.pad=b.pad
select a_test.id,a_test.name,a.name from a_test,(select name from a_two) a
select * from a_test inner join a_two order by a_test.id,a_two.id
select * from a_test cross join a_two order by a_test.id,a_two.id
select * from a_test join a_two order by a_test.id,a_two.id
select a.id,a.name,a.pad,b.name from a_test a inner join a_two b order by a.id,b.id
select a.id,a.name,a.pad,b.name from a_test a cross join a_two b order by a.id,b.id
select a.id,a.name,a.pad,b.name from a_test a join a_two b order by a.id,b.id
select * from a_test a inner join (select * from a_two where pad>0) b order by a.id,b.id
select * from a_test a cross join (select * from a_two where pad>0) b order by a.id,b.id
select * from a_test a join (select * from a_two where pad>0) b order by a.id,b.id
select * from (select * from a_test where pad>0) a inner join (select * from a_two where pad>0) b order by a.id,b.id
select * from (select * from a_test where pad>0) a cross join (select * from a_two where pad>0) b order by a.id,b.id
select * from (select * from a_test where pad>0) a join (select * from a_two where pad>0) b order by a.id,b.id
select * from a_test a join (select * from a_two where pad>0) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select * from a_test a join (select * from a_two where pad>0) b  using(pad) order by a.id,b.id
select * from a_test straight_join a_two order by a_test.id,a_two.id
select a.id,a.name,a.pad,b.name from a_test a straight_join a_two b order by a.id,b.id
select * from a_test a straight_join (select * from a_two where pad>0) b order by a.id,b.id
select * from (select * from a_test where pad>0) a straight_join (select * from a_two where pad>0) b order by a.id,b.id
select * from a_test a straight_join (select * from a_two where pad>0) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select * from a_test left join a_two on a_test.pad=a_two.pad order by a_test.id,a_two.id
select * from a_test right join a_two on a_test.pad=a_two.pad order by a_test.id,a_two.id
select * from a_test left outer join a_two on a_test.pad=a_two.pad order by a_test.id,a_two.id
select * from a_test right outer join a_two on a_test.pad=a_two.pad order by a_test.id,a_two.id
select * from a_test left join a_two using(pad) order by a_test.id,a_two.id
select * from a_test a left join a_two b on a.pad=b.pad order by a.id,b.id
select * from a_test a right join a_two b on a.pad=b.pad order by a.id,b.id
select * from a_test a left outer join a_two b on a.pad=b.pad order by a.id,b.id
select * from a_test a right outer join a_two b on a.pad=b.pad order by a.id,b.id
select * from a_test a left join a_two b using(pad) order by a.id,b.id
select * from a_test a left join (select * from a_two where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from a_test a right join (select * from a_two where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from a_test a left outer join (select * from a_two where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from a_test a right outer join (select * from a_two where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from a_test a left join (select * from a_two where pad>2) b using(pad) order by a.id,b.id
select * from (select * from a_test where pad>1) a left join (select * from a_two where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from a_test where pad>1) a right join (select * from a_two where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from a_test where pad>1) a left outer join (select * from a_two where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from a_test where pad>1) a right outer join (select * from a_two where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from a_test where pad>1) a left join (select * from a_two where pad>3) b using(pad) order by a.id,b.id
select * from a_test natural left join a_two
select * from a_test natural right join a_two
select * from a_test natural left outer join a_two
select * from a_test natural right outer join a_two
select * from a_test a natural left join a_two b order by a.id,b.id
select * from a_test a natural right join a_two b order by a.id,b.id
select * from a_test a natural left outer join a_two b order by a.id,b.id
select * from a_test a natural right outer join a_two b order by a.id,b.id
select * from a_test a natural left join (select * from a_two where pad>2) b order by a.id,b.id
select * from a_test a natural right join (select * from a_two where pad>2) b order by a.id,b.id
select * from a_test a natural left outer join (select * from a_two where pad>2) b order by a.id,b.id
select * from a_test a natural right outer join (select * from a_two where pad>2) b order by a.id,b.id
select * from (select * from a_test where pad>1) a natural left join (select * from a_two where pad>3) b order by a.id,b.id
select * from (select * from a_test where pad>1) a natural right join (select * from a_two where pad>3) b order by a.id,b.id
select * from (select * from a_test where pad>1) a natural left outer join (select * from a_two where pad>3) b order by a.id,b.id
select * from (select * from a_test where pad>1) a natural right outer join (select * from a_two where pad>3) b order by a.id,b.id
select * from a_test left join a_two on a_test.pad=a_two.pad and a_test.id>3 order by a_test.id,a_two.id
#
#distinct(special_scene)
#
(select pad from a_test) union distinct (select pad from a_two)
(select * from a_test where id=2) union distinct (select * from a_two where id=2)
select distinct a.pad from a_test a,a_two b where a.pad=b.pad
select distinct b.pad,a.pad from a_test a,(select * from a_two where pad=1) b where a.t_id=b.o_id
select count(distinct pad,name),avg(distinct t_id) from a_test
select count(distinct id),sum(distinct name) from a_test where id=3 or id=7
