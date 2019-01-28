# Created by zhaohongjie at 2019/1/22
#!share_conn
drop table if exists schema1.test1;
drop table if exists schema2.test2;
drop table if exists schema3.test3;
create table schema1.test1(id int);
create table schema2.test2(id int);
create table schema3.test3(id int);

insert into schema1.test1 values(1);
insert into schema2.test2 values(2);
insert into schema3.test3 values(3);

select * from schema1.test1;
select * from schema2.test2;
select * from schema3.test3;
select * from schema1.test1 join schema2.test2;
select * from schema2.test2 join schema3.test3;
select * from schema1.test1 join schema2.test2 join schema3.test3;

use schema1;
select * from test1 join schema2.test2 join schema3.test3;