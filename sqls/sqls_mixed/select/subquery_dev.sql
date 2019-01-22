#!default_db:schema1
# Created by zhaohongjie at 2018/9/26
# organize according to developer''s deal: http://10.186.18.11/confluence/pages/viewpage.action?pageId=7275871
#prepare
drop table if exists sharding_4_t1;
drop table if exists schema2.sharding_4_t2;
create table sharding_4_t1(id int, name varchar(20));
create table schema2.sharding_4_t2(id int, name varchar(20));
insert into sharding_4_t1 values(1,'a'),(2,'b'),(5,null);
insert into schema2.sharding_4_t2 values(1,1),(2,2),(3,null);
drop table if exists schema3.sharding_4_t3;
create table schema3.sharding_4_t3(id int, name varchar(20));
#subquery position between select and from
select *, (select name from schema2.sharding_4_t2 where id=2) from sharding_4_t1 order by id;
select *, (select name from schema2.sharding_4_t2 where id=8) from sharding_4_t1 order by id;
select *, (select name from schema2.sharding_4_t2 where id=3) from sharding_4_t1 order by id;
select *, (select 3) from sharding_4_t1 order by id;
select *, select 3 from sharding_4_t1 order by id;
#subquery position follow compare condition
select * from schema2.sharding_4_t2 where id > (select 2);
select * from schema2.sharding_4_t2 where id > (select id from sharding_4_t1 order by id) order by id;
select * from schema2.sharding_4_t2 where id > (select id from sharding_4_t1 order by id limit 1) order by id;
select * from schema2.sharding_4_t2 where id = (select id from sharding_4_t1 where id>8) order by id;
select * from schema2.sharding_4_t2 where id <= (select 2) order by id;
#subquery with [not] in
select * from sharding_4_t1 where id in (select id from schema2.sharding_4_t2) order by id;
select * from sharding_4_t1 where id in (select id from schema2.sharding_4_t2 where id > 8);
select * from sharding_4_t1 where id in (select max(name) from sharding_4_t1 where id =0);
select * from sharding_4_t1 where id IN(select name from schema2.sharding_4_t2 where id =1);
select a.* from sharding_4_t1 a ,schema2.sharding_4_t2 b where a.id = b.id and b.name = '1';
select * from sharding_4_t1 where id not in (select id from schema2.sharding_4_t2) order by id;
select * from sharding_4_t1 where id not in (select id from schema2.sharding_4_t2 where id > 8) order by id;
select * from sharding_4_t1 where id not in (select max(name) from sharding_4_t1 where id =0)  order by id;
select * from sharding_4_t1 where id not IN(select name from schema2.sharding_4_t2 where id =1) order by id;
select a.* from sharding_4_t1 a left join schema2.sharding_4_t2 b on a.id != b.id where b.name = '1' order by id;
SELECT * FROM sharding_4_t1 LEFT JOIN schema2.sharding_4_t2 ON sharding_4_t1.id = schema2.sharding_4_t2. NAME where sharding_4_t1. NAME NOT IN (SELECT NAME FROM schema3.sharding_4_t3);
SELECT * FROM (SELECT 1, 2, 3) AS t1;
#subquery with some
select * from sharding_4_t1  where id > SOME(select name from schema2.sharding_4_t2);
select * from sharding_4_t1 where id >some(select name from schema2.sharding_4_t2 where id =0);
select * from sharding_4_t1 where id >some(select max(name) from schema2.sharding_4_t2 where id =0);
select * from sharding_4_t1 where id <= SOME(select name from schema2.sharding_4_t2) order by id;
select * from sharding_4_t1 where id <some(select name from schema2.sharding_4_t2 where id =0);
select * from sharding_4_t1 where id in (select name from schema2.sharding_4_t2) order by id;
select * from sharding_4_t1 where id <>some(select name from schema2.sharding_4_t2 where id=1);
select * from sharding_4_t1 where id <>some(select name from schema2.sharding_4_t2 where id>1) order by id;
select * from sharding_4_t1 where id <>some(select name from schema2.sharding_4_t2) order by id;
select * from sharding_4_t1 where id <>some(select name from schema2.sharding_4_t2 where id =0);
select * from sharding_4_t1 where id <>some(select max(name) from schema2.sharding_4_t2 where id =0);
#subquery with all
select * from sharding_4_t1 where id<ALL(select id from schema2.sharding_4_t2 where id>1 and id<8);
select * from sharding_4_t1 where id <all(select name from schema2.sharding_4_t2 where id =0) order by id;
select * from sharding_4_t1 where id <all(select max(name) from schema2.sharding_4_t2 where id =0);
select * from sharding_4_t1  where id < ALL(select name from schema2.sharding_4_t2);
select * from sharding_4_t1 where id > all(select name from schema2.sharding_4_t2 where id < 4);
select * from sharding_4_t1 where id > all(select name from schema2.sharding_4_t2 where id =0) order by id;
select * from sharding_4_t1 where id > all(select max(name) from schema2.sharding_4_t2 where id =0);
select * from sharding_4_t1 where id <> ALL(select name from schema2.sharding_4_t2);
select * from sharding_4_t1 where id <> ALL(select name from schema2.sharding_4_t2 where id < 3);
select * from sharding_4_t1 where id =ALL(select name from schema2.sharding_4_t2 where id =1) order by id;
select * from sharding_4_t1 where id =ALL(select name from schema2.sharding_4_t2 where id =5) order by id;
select * from sharding_4_t1 where id =ALL(select name from schema2.sharding_4_t2 where name is null);
select * from sharding_4_t1 where id =ALL(select name from schema2.sharding_4_t2 where name is not null);
select * from sharding_4_t1 where id =ALL(select name from schema2.sharding_4_t2 where id =0) order by id;
#subquery with [not] exists
select * from sharding_4_t1 where exists(select name from schema2.sharding_4_t2 where id =1) order by id;
select * from sharding_4_t1 where exists(select name from schema2.sharding_4_t2 where id =0);
select * from sharding_4_t1 where exists(select null) order by id;
select * from sharding_4_t1 where not exists(select name from schema2.sharding_4_t2 where id =1);
select * from sharding_4_t1 where not exists(select name from schema2.sharding_4_t2 where id =0) order by id;
select * from sharding_4_t1 where not exists(select null) order by id;
#subquery with row compare, function is not available at 2018.9.26
#select * from sharding_4_t1 where (id,id-2) > (select id,name from schema2.sharding_4_t2 where id = 2);
## case from developer
truncate sharding_4_t1;
truncate table schema2.sharding_4_t2;
insert into sharding_4_t1 values(1,null),(2,'2'),(5,'5');
insert into schema2.sharding_4_t2 values(1,1),(2,2),(3,null),(5,'5'),(6,'6');
#greater than compare when any() is:single null, single value and not null, multi-values without null, multi-values contains null, empty set
select * from schema2.sharding_4_t2 where id> any(select name from sharding_4_t1 where id =9) order by id;
select * from schema2.sharding_4_t2 where id> any(select name from sharding_4_t1 where id =5) order by id;
select * from schema2.sharding_4_t2 where id> any(select name from sharding_4_t1 where id>1) order by id;
select * from schema2.sharding_4_t2 where id> any(select name from sharding_4_t1 where id =1) order by id;
select * from schema2.sharding_4_t2 where id> any(select name from sharding_4_t1 where id <=2) order by id;
select * from schema2.sharding_4_t2 where id> any(select name from sharding_4_t1) order by id;
#not equal compare when any() is:single null, single value and not null, multi-values without null, multi-values contains null, empty set
select * from schema2.sharding_4_t2 where id<> any(select name from sharding_4_t1 where id =9) order by id;
select * from schema2.sharding_4_t2 where id<> any(select name from sharding_4_t1 where id =5) order by id;
select * from schema2.sharding_4_t2 where id<> any(select name from sharding_4_t1 where id>1) order by id;
select * from schema2.sharding_4_t2 where id<> any(select name from sharding_4_t1 where id =1) order by id;
select * from schema2.sharding_4_t2 where id<> any(select name from sharding_4_t1 where id <=2) order by id;
select * from schema2.sharding_4_t2 where id<> any(select name from sharding_4_t1) order by id;
#less than compare when all() is:single null, single value and not null, multi-values without null, multi-values contains null, empty set
select * from schema2.sharding_4_t2 where id< all(select name from sharding_4_t1 where id =9) order by id;
select * from schema2.sharding_4_t2 where id< all(select name from sharding_4_t1 where id =5) order by id;
select * from schema2.sharding_4_t2 where id< all(select name from sharding_4_t1 where id>1) order by id;
select * from schema2.sharding_4_t2 where id< all(select name from sharding_4_t1 where id =1) order by id;
select * from schema2.sharding_4_t2 where id< all(select name from sharding_4_t1 where id <=2) order by id;
select * from schema2.sharding_4_t2 where id< all(select name from sharding_4_t1) order by id;
#greater than compare when all() is:single null, single value and not null, multi-values without null, multi-values contains null, empty set
select * from schema2.sharding_4_t2 where id> all(select name from sharding_4_t1 where id =9) order by id;
select * from schema2.sharding_4_t2 where id> all(select name from sharding_4_t1 where id =5) order by id;
select * from schema2.sharding_4_t2 where id> all(select name from sharding_4_t1 where id>1) order by id;
select * from schema2.sharding_4_t2 where id> all(select name from sharding_4_t1 where id =1) order by id;
select * from schema2.sharding_4_t2 where id> all(select name from sharding_4_t1 where id <=2) order by id;
select * from schema2.sharding_4_t2 where id> all(select name from sharding_4_t1) order by id;
#equal compare when all() is:single null, single value and not null, multi-values without null, multi-values contains null, empty set
select * from schema2.sharding_4_t2 where id= all(select name from sharding_4_t1 where id =9) order by id;
select * from schema2.sharding_4_t2 where id= all(select name from sharding_4_t1 where id =5) order by id;
select * from schema2.sharding_4_t2 where id= all(select name from sharding_4_t1 where id>1) order by id;
select * from schema2.sharding_4_t2 where id= all(select name from sharding_4_t1 where id =1) order by id;
select * from schema2.sharding_4_t2 where id= all(select name from sharding_4_t1 where id <=2) order by id;
select * from schema2.sharding_4_t2 where id= all(select name from sharding_4_t1) order by id;


