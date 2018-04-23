#!sql_thread_1
set @@session.innodb_lock_wait_timeout=10000
SET @@session.autocommit = ON
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id lock in share mode;
#!sql_thread_2
set @@session.innodb_lock_wait_timeout=100
SET @@session.autocommit = ON
begin;
select * from sbtest1 order by id lock in share mode;
#!sql_thread_1
commit;
#!sql_thread_2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;