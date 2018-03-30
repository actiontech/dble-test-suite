drop table if exists sbtest1
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
drop table if exists sbtest2
CREATE TABLE sbtest2(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#!share_conn
#*****************lock in share mode********* s lock**********************
#!share_conn_1
SET @@session.autocommit = ON
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id lock in share mode;
#!share_conn_2
SET @@session.autocommit = ON
begin;
select * from sbtest1 order by id lock in share mode;
#!share_conn_1
commit;
#!share_conn_2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#************************************************
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id lock in share mode;
#!share_conn_2
begin;
select * from sbtest1 order by id lock in share mode;
#!share_conn_1
rollback ;
#!share_conn_2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************lock in share mode********* w lock**********************
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id lock in share mode;
#!share_conn_2
begin;
update sbtest1 set pad=22 where id=1 /*hang*/ ;
#!share_conn_1
commit;
#!share_conn_2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#**********************************************
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id lock in share mode;
#!share_conn_2
begin;
update sbtest1 set pad=22 where id=1;/*hang*/
#!share_conn_1
rollback ;
#!share_conn_2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************lock in share mode********* subquery ********commit**************
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 a,(select * from sbtest2 lock in share mode)b where a.pad=b.pad order by a.id;
#!share_conn_2
begin;
update sbtest1 set pad=22 where id=1;
update sbtest2 set pad=22 where id=1;/*hang*/
#!share_conn_1
commit;
#!share_conn_2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************lock in share mode********* subquery ********rollback**************
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 a,(select * from sbtest2 lock in share mode)b where a.pad=b.pad order by a.id;
#!share_conn_2
begin;
update sbtest1 set pad=22 where id=1;
update sbtest2 set pad=22 where id=1;/*hang*/
#!share_conn_1
rollback;
#!share_conn_2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* s lock***********commit***********
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id for update;
#!share_conn_2
begin;
select * from sbtest1 for update;/*hang*/
#!share_conn_1
commit;
#!share_conn_2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* s lock***********rollback***********
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id for update;
#!share_conn_2
begin;
select * from sbtest1 for update;/*hang*/
#!share_conn_1
rollback ;
#!share_conn_2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* w lock***********commit***********
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id for update;
#!share_conn_2
begin;
update sbtest1 set pad=22 where id=1;/*hang*/
#!share_conn_1
commit;
#!share_conn_2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* w lock***********rollback***********
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 order by id for update;
#!share_conn_2
begin;
update sbtest1 set pad=22 where id=1;/*hang*/
#!share_conn_1
rollback;
#!share_conn_2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* subquery ***********commit***********
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 a,(select * from sbtest2 for update)b where a.pad=b.pad order by a.id;
#!share_conn_2
begin;
update sbtest1 set pad=22 where id=1;
update sbtest2 set pad=22 where id=1;/*hang*/
#!share_conn_1
commit
#!share_conn_2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* subquery ***********rollback***********
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 a,(select * from sbtest2 for update)b where a.pad=b.pad order by a.id;
#!share_conn_2
begin;
update sbtest1 set pad=22 where id=1;
update sbtest2 set pad=22 where id=1;/*hang*/
#!share_conn_1
rollback
#!share_conn_2
update sbtest1 set pad=22 where id=2;
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* Line lock(UNIQUE) ***********commit***********
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 where k=2 for update;
#!share_conn_2
begin;
update sbtest1 set pad=22 where id=1;
update sbtest1 set pad=22 where id=2;
#!share_conn_1
commit
#!share_conn_2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* Line lock(UNIQUE) ***********rollback***********
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 where k=2 for update;
#!share_conn_2
begin;
update sbtest1 set pad=22 where id=1;
update sbtest1 set pad=22 where id=2;
#!share_conn_1
rollback
#!share_conn_2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* table lock(no index) ***********commit***********
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 where pad=2 for update;
#!share_conn_2
begin;
update sbtest1 set pad=22 where id=1;
#!share_conn_1
commit
#!share_conn_2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;
#*****************for update********* table lock(no index) ***********rollback***********
#!share_conn_1
delete from sbtest1;
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6);
begin;
select * from sbtest1 where pad=2 for update;
#!share_conn_2
begin;
update sbtest1 set pad=22 where id=1;
#!share_conn_1
rollback
#!share_conn_2
select * from sbtest1 order by id;
commit;
select * from sbtest1 order by id;