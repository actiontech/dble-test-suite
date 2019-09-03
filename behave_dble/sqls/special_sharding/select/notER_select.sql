# Created by zhaohongjie at 2019/8/19
drop table if exists sharding_2_t1;
drop table if exists schema2.sharding_3_t1;
create table sharding_2_t1(id int);
create table schema2.sharding_3_t1(id int, name char(20), age int);
select c.id, (case c.name  when c.name is not null then  c.name else c.age end) from schema2.sharding_3_t1 c, sharding_2_t1 a where a.id=c.id;
select concat(name, cast(age as char)) from schema2.sharding_3_t1 a, sharding_2_t1 b where a.id = b.id;