# Created by zhaohongjie at 2018/9/26
# organize according: http://10.186.18.11/confluence/pages/viewpage.action?pageId=7275871
#prepare
drop table if exists a_test;
drop table if exists a_order;
drop table if exists a_manager;
create table a_test(id int, name varchar(20));
create table a_order(id int, name varchar(20));
create table a_manager(id int, name varchar(20));
insert into a_test values(1,'a'),(2,'b'),(5,null);
insert into a_order values(1,1),(2,2),(3,null);
#subquery position between select and from
select *, (select name from a_order where id=2) from a_test order by id;
select *, (select name from a_order where id=8) from a_test order by id;
select *, (select name from a_order where id=3) from a_test order by id;
select *, (select 3) from a_test order by id;
select *, select 3 from a_test order by id;
#subquery position follow compare condition
select * from a_order where id > (select 2);
select * from a_order where id > (select id from a_test order by id) order by id;
select * from a_order where id > (select id from a_test order by id limit 1) order by id;
select * from a_order where id = (select id from a_test where id>8) order by id;
select * from a_order where id <= (select 2) order by id;
#subquery with [not] in
select * from a_test where id in (select id from a_order) order by id;
select * from a_test where id in (select id from a_order where id > 8);
select * from a_test where id in (select max(name) from a_test where id =0);
select * from a_test where id IN(select name from a_order where id =1);
select a.* from a_test a ,a_order b where a.id = b.id and b.name = '1';
select * from a_test where id not in (select id from a_order) order by id;
select * from a_test where id not in (select id from a_order where id > 8) order by id;
select * from a_test where id not in (select max(name) from a_test where id =0)  order by id;
select * from a_test where id not IN(select name from a_order where id =1) order by id;
select a.* from a_test a left join a_order b on a.id != b.id where b.name = '1' order by id;
SELECT * FROM a_test LEFT JOIN a_order ON a_test.id = a_order. NAME where a_test. NAME NOT IN (SELECT NAME FROM a_manager);

#subquery with some
select * from a_test  where id > SOME(select name from a_order);
select * from a_test where id >some(select name from a_order where id =0);
select * from a_test where id >some(select max(name) from a_order where id =0);
select * from a_test where id <= SOME(select name from a_order) order by id;
select * from a_test where id <some(select name from a_order where id =0);
select * from a_test where id in (select name from a_order) order by id;
select * from a_test where id <>some(select name from a_order where id=1);
select * from a_test where id <>some(select name from a_order where id>1) order by id;
select * from a_test where id <>some(select name from a_order) order by id;
select * from a_test where id <>some(select name from a_order where id =0);
select * from a_test where id <>some(select max(name) from a_order where id =0);
#subquery with all
select * from a_test where id<ALL(select id from a_order where id>1 and id<8);
select * from a_test where id <all(select name from a_order where id =0) order by id;
select * from a_test where id <all(select max(name) from a_order where id =0);
select * from a_test  where id < ALL(select name from a_order);
select * from a_test where id > all(select name from a_order where id < 4);
select * from a_test where id > all(select name from a_order where id =0) order by id;
select * from a_test where id > all(select max(name) from a_order where id =0);
select * from a_test where id <> ALL(select name from a_order);
select * from a_test where id <> ALL(select name from a_order where id < 3);
select * from a_test where id =ALL(select name from a_order where id =1) order by id;
select * from a_test where id =ALL(select name from a_order where id =5) order by id;
select * from a_test where id =ALL(select name from a_order where name is null);
select * from a_test where id =ALL(select name from a_order where name is not null);
select * from a_test where id =ALL(select name from a_order where id =0) order by id;
#subquery with [not] exists
select * from a_test where exists(select name from a_order where id =1) order by id;
select * from a_test where exists(select name from a_order where id =0);
select * from a_test where exists(select null) order by id;
select * from a_test where not exists(select name from a_order where id =1);
select * from a_test where not exists(select name from a_order where id =0) order by id;
select * from a_test where not exists(select null) order by id;
#subquery with row compare, function is not available at 2018.9.26
#select * from a_test where (id,id-2) > (select id,name from a_order where id = 2);
SELECT * FROM (SELECT 1, 2, 3) AS t1;