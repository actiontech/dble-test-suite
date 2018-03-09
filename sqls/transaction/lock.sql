drop table if exists sbtest1
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#!share_conn
#************************************************
#!session 1
SET @@session.autocommit = ON
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id lock in share mode;
#!session 2
SET @@session.autocommit = ON
begin;
select * from sbtest1 order by id lock in share mode;
#!session 1
commit;
#!session 2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#************************************************
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id lock in share mode;
#!session 2
begin;
select * from sbtest1 order by id lock in share mode;
#!session 1
rollback ;
#!session 2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
drop table if exists sbtest1