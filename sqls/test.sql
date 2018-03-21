drop table if exists sbtest1
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
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