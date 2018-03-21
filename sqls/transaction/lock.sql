drop table if exists sbtest1
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
drop table if exists sbtest2
CREATE TABLE sbtest2(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#!share_conn
#*****************lock in share mode********* s lock**********************
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
#*****************lock in share mode********* w lock**********************
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id lock in share mode;
#!session 2
begin;
update sbtest1 set pad=22 where id=1;/*hang*/
#!session 1
commit;
#!session 2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#**********************************************
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id lock in share mode;
#!session 2
begin;
update sbtest1 set pad=22 where id=1;/*hang*/
#!session 1
rollback ;
#!session 2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************lock in share mode********* subquery ********commit**************
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 a,(select * from sbtest2 lock in share mode)b where a.pad=b.pad order by a.id;
#!session 2
begin;
update sbtest1 set pad=22 where id=1;
update sbtest2 set pad=22 where id=1;/*hang*/
#!session 1
commit;
#!session 2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************lock in share mode********* subquery ********rollback**************
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 a,(select * from sbtest2 lock in share mode)b where a.pad=b.pad order by a.id;
#!session 2
begin;
update sbtest1 set pad=22 where id=1;
update sbtest2 set pad=22 where id=1;/*hang*/
#!session 1
rollback;
#!session 2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* s lock***********commit***********
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id for update;
#!session 2
begin;
select * from sbtest1 for update;/*hang*/
#!session 1
commit;
#!session 2
select sleep(2);
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* s lock***********rollback***********
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id for update;
#!session 2
begin;
select * from sbtest1 for update;/*hang*/
#!session 1
rollback ;
#!session 2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* w lock***********commit***********
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id for update;
#!session 2
begin;
update sbtest1 set pad=22 where id=1;/*hang*/
#!session 1
commit;
#!session 2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* w lock***********rollback***********
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id for update;
#!session 2
begin;
update sbtest1 set pad=22 where id=1;/*hang*/
#!session 1
rollback;
#!session 2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* subquery ***********commit***********
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 a,(select * from sbtest2 for update)b where a.pad=b.pad order by a.id;
#!session 2
begin;
update sbtest1 set pad=22 where id=1;
update sbtest2 set pad=22 where id=1;/*hang*/
#!session 1
commit
#!session 2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* subquery ***********rollback***********
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 a,(select * from sbtest2 for update)b where a.pad=b.pad order by a.id;
#!session 2
begin;
update sbtest1 set pad=22 where id=1;
update sbtest2 set pad=22 where id=1;/*hang*/
#!session 1
rollback
#!session 2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* Line lock(UNIQUE) ***********commit***********
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 where k=2 for update;
#!session 2
begin;
update sbtest1 set pad=22 where id=1;
update sbtest1 set pad=22 where id=2;
#!session 1
commit
#!session 2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* Line lock(UNIQUE) ***********rollback***********
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 where k=2 for update;
#!session 2
begin;
update sbtest1 set pad=22 where id=1;
update sbtest1 set pad=22 where id=2;
#!session 1
rollback
#!session 2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* table lock(no index) ***********commit***********
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 where pad=2 for update;
#!session 2
begin;
update sbtest1 set pad=22 where id=1;
#!session 1
commit
#!session 2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* table lock(no index) ***********rollback***********
#!session 1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 where pad=2 for update;
#!session 2
begin;
update sbtest1 set pad=22 where id=1;
#!session 1
rollback
#!session 2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
