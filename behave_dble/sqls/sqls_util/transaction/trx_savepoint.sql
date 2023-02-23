#!default_db:schema1
drop table if exists test1
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#*********************SET @@session.autocommit = ON***************************
#!share_conn_1
SET @@session.autocommit = ON
delete from test1
begin
select * from test1 order by id
savepoint sp1
insert into test1 values(1,1,1,1)
select * from test1 order by id
savepoint sp2
insert into test1 values(2,2,2,2)
select * from test1 order by id
savepoint sp1
insert into test1 values(3,3,3,3)
select * from test1 order by id
savepoint sp4
insert into test1 values(4,4,4,4)
select * from test1 order by id
savepoint sp5
rollback to savepoint sp4
select * from test1 order by id
release savepoint sp5
select * from test1 order by id
release savepoint sp4
rollback to savepoint sp1
select * from test1 order by id
rollback
select * from test1 order by id
#!share_conn_1
SET @@session.autocommit = ON
delete from test1
start transaction
select * from test1 order by id
savepoint sp1
insert into test1 values(1,1,1,1)
select * from test1 order by id
savepoint sp2
insert into test1 values(2,2,2,2)
select * from test1 order by id
savepoint sp1
insert into test1 values(3,3,3,3)
select * from test1 order by id
savepoint sp4
insert into test1 values(4,4,4,4)
select * from test1 order by id
savepoint sp5
rollback to savepoint sp4
select * from test1 order by id
release savepoint sp5
select * from test1 order by id
release savepoint sp4
rollback to savepoint sp1
select * from test1 order by id
commit
select * from test1 order by id
#*********************SET @@session.autocommit = OFF***************************
#!share_conn_1
SET @@session.autocommit = OFF
delete from test1
begin
select * from test1 order by id
savepoint sp1
insert into test1 values(1,1,1,1)
select * from test1 order by id
savepoint sp2
insert into test1 values(2,2,2,2)
select * from test1 order by id
savepoint sp1
insert into test1 values(3,3,3,3)
select * from test1 order by id
savepoint sp4
insert into test1 values(4,4,4,4)
select * from test1 order by id
savepoint sp5
rollback to savepoint sp4
select * from test1 order by id
release savepoint sp5
select * from test1 order by id
release savepoint sp4
rollback to savepoint sp1
select * from test1 order by id
rollback
select * from test1 order by id
#!share_conn_1
SET @@session.autocommit = OFF
delete from test1
start transaction
select * from test1 order by id
savepoint sp1
insert into test1 values(1,1,1,1)
select * from test1 order by id
savepoint sp2
insert into test1 values(2,2,2,2)
select * from test1 order by id
savepoint sp1
insert into test1 values(3,3,3,3)
select * from test1 order by id
savepoint sp4
insert into test1 values(4,4,4,4)
select * from test1 order by id
savepoint sp5
rollback to savepoint sp4
select * from test1 order by id
release savepoint sp5
select * from test1 order by id
release savepoint sp4
rollback to savepoint sp1
select * from test1 order by id
commit
select * from test1 order by id
#*****************set autocommit=0**********************
#!share_conn_1
SET @@autocommit = 0
delete from test1
begin
select * from test1 order by id
savepoint sp1
insert into test1 values(1,1,1,1)
select * from test1 order by id
savepoint sp2
insert into test1 values(2,2,2,2)
select * from test1 order by id
savepoint sp1
insert into test1 values(3,3,3,3)
select * from test1 order by id
savepoint sp4
insert into test1 values(4,4,4,4)
select * from test1 order by id
savepoint sp5
rollback to savepoint sp4
select * from test1 order by id
release savepoint sp5
select * from test1 order by id
release savepoint sp4
rollback to savepoint sp1
select * from test1 order by id
rollback
select * from test1 order by id
#!share_conn_1
SET @@autocommit = 0
delete from test1
start transaction
select * from test1 order by id
savepoint sp1
insert into test1 values(1,1,1,1)
select * from test1 order by id
savepoint sp2
insert into test1 values(2,2,2,2)
select * from test1 order by id
savepoint sp1
insert into test1 values(3,3,3,3)
select * from test1 order by id
savepoint sp4
insert into test1 values(4,4,4,4)
select * from test1 order by id
savepoint sp5
rollback to savepoint sp4
select * from test1 order by id
release savepoint sp5
select * from test1 order by id
release savepoint sp4
rollback to savepoint sp1
select * from test1 order by id
commit
select * from test1 order by id
#*****************set @@autocommit=1**********************
#!share_conn_1
SET @@autocommit = 1
delete from test1
begin
select * from test1 order by id
savepoint sp1
insert into test1 values(1,1,1,1)
select * from test1 order by id
savepoint sp2
insert into test1 values(2,2,2,2)
select * from test1 order by id
savepoint sp1
insert into test1 values(3,3,3,3)
select * from test1 order by id
savepoint sp4
insert into test1 values(4,4,4,4)
select * from test1 order by id
savepoint sp5
rollback to savepoint sp4
select * from test1 order by id
release savepoint sp5
select * from test1 order by id
release savepoint sp4
rollback to savepoint sp1
select * from test1 order by id
rollback
select * from test1 order by id
#!share_conn_1
SET @@autocommit = 1
delete from test1
start transaction
select * from test1 order by id
savepoint sp1
insert into test1 values(1,1,1,1)
select * from test1 order by id
savepoint sp2
insert into test1 values(2,2,2,2)
select * from test1 order by id
savepoint sp1
insert into test1 values(3,3,3,3)
select * from test1 order by id
savepoint sp4
insert into test1 values(4,4,4,4)
select * from test1 order by id
savepoint sp5
rollback to savepoint sp4
select * from test1 order by id
release savepoint sp5
select * from test1 order by id
release savepoint sp4
rollback to savepoint sp1
select * from test1 order by id
commit
select * from test1 order by id
#
#clear tables
#
drop table if exists test1