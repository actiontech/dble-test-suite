#!default_db:schema1
drop table if exists test1
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
drop table if exists schema2.test2
CREATE TABLE schema2.test2(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#*****************lock in share mode********* s lock**********************
#!sql_thread_1
set @@session.innodb_lock_wait_timeout=10000
SET @@session.autocommit = ON
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 order by id lock in share mode
#!sql_thread_2
set @@session.innodb_lock_wait_timeout=10000
SET @@session.autocommit = ON
begin
select * from test1 order by id lock in share mode
#!sql_thread_1
commit
#!sql_thread_2
select * from test1 order by id
commit
select * from test1 order by id
#************************************************
#!sql_thread_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 order by id lock in share mode
#!sql_thread_2
begin
select * from test1 order by id lock in share mode
#!sql_thread_1
rollback 
#!sql_thread_2
select * from test1 order by id
commit
select * from test1 order by id
#*****************lock in share mode********* w lock**********************
#!sql_thread_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 order by id lock in share mode
#!sql_thread_2
begin
update test1 set pad=22 where id=1 /*hang*/
#!sql_thread_1
commit
#!sql_thread_2
update test1 set pad=22 where id=2
select * from test1 order by id
commit
select * from test1 order by id
#**********************************************
#!sql_thread_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 order by id lock in share mode
#!sql_thread_2
begin
update test1 set pad=22 where id=1
#!sql_thread_1
rollback
#!sql_thread_2
update test1 set pad=22 where id=2
select * from test1 order by id
commit
select * from test1 order by id
#*****************lock in share mode********* subquery ********commit**************
#!sql_thread_1
delete from test1
delete from schema2.test2
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into schema2.test2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 a,(select * from schema2.test2 lock in share mode)b where a.pad=b.pad order by a.id
#!sql_thread_2
begin
update test1 set pad=22 where id=1
update schema2.test2 set pad=22 where id=1/*hang*/
#!sql_thread_1
commit
#!sql_thread_2
update test1 set pad=22 where id=2
select * from test1 order by id
commit
select * from test1 order by id
#*****************lock in share mode********* subquery ********rollback**************
#!sql_thread_1
delete from test1
delete from schema2.test2
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into schema2.test2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 a,(select * from schema2.test2 lock in share mode)b where a.pad=b.pad order by a.id
#!sql_thread_2
begin
update test1 set pad=22 where id=1
update schema2.test2 set pad=22 where id=1/*hang*/
#!sql_thread_1
rollback
#!sql_thread_2
update test1 set pad=22 where id=2
select * from test1 order by id
commit
select * from test1 order by id
#*****************for update********* s lock***********commit***********
#!sql_thread_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 order by id for update
#!sql_thread_2
begin
select * from test1 for update/*hang*/
#!sql_thread_1
commit
#!sql_thread_2
select * from test1 order by id
commit
select * from test1 order by id
#*****************for update********* s lock***********rollback***********
#!sql_thread_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 order by id for update
#!sql_thread_2
begin
select * from test1 for update/*hang*/
#!sql_thread_1
rollback 
#!sql_thread_2
select * from test1 order by id
commit
select * from test1 order by id
#*****************for update********* w lock***********commit***********
#!sql_thread_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 order by id for update
#!sql_thread_2
begin
update test1 set pad=22 where id=1/*hang*/
#!sql_thread_1
commit
#!sql_thread_2
update test1 set pad=22 where id=2
select * from test1 order by id
commit
select * from test1 order by id
#*****************for update********* w lock***********rollback***********
#!sql_thread_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 order by id for update
#!sql_thread_2
begin
update test1 set pad=22 where id=1/*hang*/
#!sql_thread_1
rollback
#!sql_thread_2
update test1 set pad=22 where id=2
select * from test1 order by id
commit
select * from test1 order by id
#*****************for update********* subquery ***********commit***********
#!sql_thread_1
delete from test1
delete from schema2.test2
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into schema2.test2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 a,(select * from schema2.test2 for update)b where a.pad=b.pad order by a.id
#!sql_thread_2
begin
update test1 set pad=22 where id=1
update schema2.test2 set pad=22 where id=1/*hang*/
#!sql_thread_1
commit
#!sql_thread_2
update test1 set pad=22 where id=2
select * from test1 order by id
commit
select * from test1 order by id
#*****************for update********* subquery ***********rollback***********
#!sql_thread_1
delete from test1
delete from schema2.test2
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into schema2.test2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 a,(select * from schema2.test2 for update)b where a.pad=b.pad order by a.id
#!sql_thread_2
begin
update test1 set pad=22 where id=1
update schema2.test2 set pad=22 where id=1/*hang*/
#!sql_thread_1
rollback
#!sql_thread_2
update test1 set pad=22 where id=2
select * from test1 order by id
commit
select * from test1 order by id
#*****************for update********* Line lock(UNIQUE) ***********commit***********
#!sql_thread_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 where k=2 for update
#!sql_thread_2
begin
update test1 set pad=22 where id=1
update test1 set pad=22 where id=2
#!sql_thread_1
commit
#!sql_thread_2
select * from test1 order by id
commit
select * from test1 order by id
#*****************for update********* Line lock(UNIQUE) ***********rollback***********
#!sql_thread_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 where k=2 for update
#!sql_thread_2
begin
update test1 set pad=22 where id=1
update test1 set pad=22 where id=2
#!sql_thread_1
rollback
#!sql_thread_2
select * from test1 order by id
commit
select * from test1 order by id
#*****************for update********* table lock(no index) ***********commit***********
#!sql_thread_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 where pad=2 for update
#!sql_thread_2
begin
update test1 set pad=22 where id=1
#!sql_thread_1
commit
#!sql_thread_2
select * from test1 order by id
commit
select * from test1 order by id
#*****************for update********* table lock(no index) ***********rollback***********
#!sql_thread_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select * from test1 where pad=2 for update
#!sql_thread_2
begin
update test1 set pad=22 where id=1
#!sql_thread_1
rollback
#!sql_thread_2
select * from test1 order by id
commit
select * from test1 order by id
#
#clear tables
#
drop table if exists test1
drop table if exists schema2.test2