# Created by zhaohongjie at 2018/9/26
# organize according: http://10.186.18.11/confluence/pages/viewpage.action?pageId=7275871
#prepare
drop table if exists aly_test;
drop table if exists aly_order;
create table aly_test(id int, name varchar(20));
create table aly_order(id int, name varchar(20));
insert into aly_test values(1,'a'),(2,'b'),(5,null);
insert into aly_order values(1,1),(2,2),(3,null);
drop table if exists aly_manager;
create table aly_manager(id int, name varchar(20));
#subquery position between select and from
select *, (select name from aly_order where id=2) from aly_test order by id;
select *, (select name from aly_order where id=8) from aly_test order by id;
select *, (select name from aly_order where id=3) from aly_test order by id;
select *, (select 3) from aly_test order by id;
select *, select 3 from aly_test order by id;
#subquery position follow compare condition
select * from aly_order where id > (select 2);
select * from aly_order where id > (select id from aly_test order by id) order by id;
select * from aly_order where id > (select id from aly_test order by id limit 1) order by id;
select * from aly_order where id = (select id from aly_test where id>8) order by id;
select * from aly_order where id <= (select 2) order by id;
#subquery with [not] in
select * from aly_test where id in (select id from aly_order) order by id;
select * from aly_test where id in (select id from aly_order where id > 8);
select * from aly_test where id in (select max(name) from aly_test where id =0);
select * from aly_test where id IN(select name from aly_order where id =1);
select a.* from aly_test a ,aly_order b where a.id = b.id and b.name = '1';
select * from aly_test where id not in (select id from aly_order) order by id;
select * from aly_test where id not in (select id from aly_order where id > 8) order by id;
select * from aly_test where id not in (select max(name) from aly_test where id =0)  order by id;
select * from aly_test where id not IN(select name from aly_order where id =1) order by id;
select a.* from aly_test a left join aly_order b on a.id != b.id where b.name = '1' order by id;
SELECT * FROM aly_test LEFT JOIN aly_order ON aly_test.id = aly_order. NAME where aly_test. NAME NOT IN (SELECT NAME FROM a_manager);
SELECT * FROM (SELECT 1, 2, 3) AS t1;
#subquery with some
select * from aly_test  where id > SOME(select name from aly_order);
select * from aly_test where id >some(select name from aly_order where id =0);
select * from aly_test where id >some(select max(name) from aly_order where id =0);
select * from aly_test where id <= SOME(select name from aly_order) order by id;
select * from aly_test where id <some(select name from aly_order where id =0);
select * from aly_test where id in (select name from aly_order) order by id;
select * from aly_test where id <>some(select name from aly_order where id=1);
select * from aly_test where id <>some(select name from aly_order where id>1) order by id;
select * from aly_test where id <>some(select name from aly_order) order by id;
select * from aly_test where id <>some(select name from aly_order where id =0);
select * from aly_test where id <>some(select max(name) from aly_order where id =0);
#subquery with all
select * from aly_test where id<ALL(select id from aly_order where id>1 and id<8);
select * from aly_test where id <all(select name from aly_order where id =0) order by id;
select * from aly_test where id <all(select max(name) from aly_order where id =0);
select * from aly_test  where id < ALL(select name from aly_order);
select * from aly_test where id > all(select name from aly_order where id < 4);
select * from aly_test where id > all(select name from aly_order where id =0) order by id;
select * from aly_test where id > all(select max(name) from aly_order where id =0);
select * from aly_test where id <> ALL(select name from aly_order);
select * from aly_test where id <> ALL(select name from aly_order where id < 3);
select * from aly_test where id =ALL(select name from aly_order where id =1) order by id;
select * from aly_test where id =ALL(select name from aly_order where id =5) order by id;
select * from aly_test where id =ALL(select name from aly_order where name is null);
select * from aly_test where id =ALL(select name from aly_order where name is not null);
select * from aly_test where id =ALL(select name from aly_order where id =0) order by id;
#subquery with [not] exists
select * from aly_test where exists(select name from aly_order where id =1) order by id;
select * from aly_test where exists(select name from aly_order where id =0);
select * from aly_test where exists(select null) order by id;
select * from aly_test where not exists(select name from aly_order where id =1);
select * from aly_test where not exists(select name from aly_order where id =0) order by id;
select * from aly_test where not exists(select null) order by id;
#subquery with row compare, function is not available at 2018.9.26
#select * from aly_test where (id,id-2) > (select id,name from aly_order where id = 2);
## case from developer
truncate aly_test;
truncate table aly_order;
insert into aly_test values(1,'a'),(2,'b'),(5,null);
insert into aly_order values(1,1),(2,2),(3,null),(5,'5'),(6,'6');
#greater than compare when any() is:single null, single value and not null, multi-values without null, multi-values contains null, empty set
select * from aly_order where id> any(select name from aly_test where id =9) order by id;
select * from aly_order where id> any(select name from aly_test where id =5) order by id;
select * from aly_order where id> any(select name from aly_test where id>1) order by id;
select * from aly_order where id> any(select name from aly_test where id =1) order by id;
select * from aly_order where id> any(select name from aly_test where id <=2) order by id;
select * from aly_order where id> any(select name from aly_test) order by id;
#not equal compare when any() is:single null, single value and not null, multi-values without null, multi-values contains null, empty set
select * from aly_order where id<> any(select name from aly_test where id =9) order by id;
select * from aly_order where id<> any(select name from aly_test where id =5) order by id;
select * from aly_order where id<> any(select name from aly_test where id>1) order by id;
select * from aly_order where id<> any(select name from aly_test where id =1) order by id;
select * from aly_order where id<> any(select name from aly_test where id <=2) order by id;
select * from aly_order where id<> any(select name from aly_test) order by id;
#less than compare when all() is:single null, single value and not null, multi-values without null, multi-values contains null, empty set
select * from aly_order where id< all(select name from aly_test where id =9) order by id;
select * from aly_order where id< all(select name from aly_test where id =5) order by id;
select * from aly_order where id< all(select name from aly_test where id>1) order by id;
select * from aly_order where id< all(select name from aly_test where id =1) order by id;
select * from aly_order where id< all(select name from aly_test where id <=2) order by id;
select * from aly_order where id< all(select name from aly_test) order by id;
#greater than compare when all() is:single null, single value and not null, multi-values without null, multi-values contains null, empty set
select * from aly_order where id> all(select name from aly_test where id =9) order by id;
select * from aly_order where id> all(select name from aly_test where id =5) order by id;
select * from aly_order where id> all(select name from aly_test where id>1) order by id;
select * from aly_order where id> all(select name from aly_test where id =1) order by id;
select * from aly_order where id> all(select name from aly_test where id <=2) order by id;
select * from aly_order where id> all(select name from aly_test) order by id;
#equal compare when all() is:single null, single value and not null, multi-values without null, multi-values contains null, empty set
select * from aly_order where id= all(select name from aly_test where id =9) order by id;
select * from aly_order where id= all(select name from aly_test where id =5) order by id;
select * from aly_order where id= all(select name from aly_test where id>1) order by id;
select * from aly_order where id= all(select name from aly_test where id =1) order by id;
select * from aly_order where id= all(select name from aly_test where id <=2) order by id;
select * from aly_order where id= all(select name from aly_test) order by id;


