#!share_conn
select @@insert_id
drop table if exists mytest_global1
create table mytest_global1(id int not null primary key auto_increment)
set @@insert_id=10
insert into mytest_global1 (id) values (null)
select id from mytest_global1
set @@session.insert_id=11
insert into mytest_global1 (id) values (null)
select id from mytest_global1
set session insert_id=12
insert into mytest_global1 (id) values (null)
select id from mytest_global1
