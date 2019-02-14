#!default_db:schema1
drop table if exists test1
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#*******************REPEATABLE READ****单节点****commit*********************
#!share_conn_1
SET @@session.autocommit = ON
delete from test1
set session transaction isolation level REPEATABLE READ
begin
select * from test1
#!share_conn_2
SET @@session.autocommit = ON
set session transaction isolation level REPEATABLE READ
begin
insert into test1 values(1,1,1,1)
select * from test1
#!share_conn_1
select * from test1
#!share_conn_2
commit
#!share_conn_1
select * from test1
commit
select * from test1
#*****************REPEATABLE READ*****单节点******rollback********************
#!share_conn_1
delete from test1
set session transaction isolation level REPEATABLE READ
begin
select * from test1
#!share_conn_2
set session transaction isolation level REPEATABLE READ
begin
insert into test1 values(1,1,1,1)
select * from test1
#!share_conn_1
select * from test1
#!share_conn_2
rollback
#!share_conn_1
select * from test1
commit
select * from test1
#*******************REPEATABLE READ****2节点****commit*********************
#!share_conn_1
delete from test1
set session transaction isolation level REPEATABLE READ
begin
select * from test1
#!share_conn_2
set session transaction isolation level REPEATABLE READ
begin
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
#!share_conn_1
select * from test1
#!share_conn_2
commit
#!share_conn_1
select * from test1
commit
select * from test1 order by id
#*******************REPEATABLE READ****2节点****rollback*********************
#!share_conn_1
delete from test1
set session transaction isolation level REPEATABLE READ
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level REPEATABLE READ
begin
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
rollback
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************REPEATABLE READ****3节点****commit*********************
#!share_conn_1
delete from test1
set session transaction isolation level REPEATABLE READ
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level REPEATABLE READ
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
commit
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************REPEATABLE READ****3节点****rollback*********************
#!share_conn_1
delete from test1
set session transaction isolation level REPEATABLE READ
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level REPEATABLE READ
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
rollback
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************REPEATABLE READ****4节点****commit*********************
#!share_conn_1
delete from test1
set session transaction isolation level REPEATABLE READ
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level REPEATABLE READ
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
commit
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************REPEATABLE READ****4节点****rollback*********************
#!share_conn_1
delete from test1
set session transaction isolation level REPEATABLE READ
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level REPEATABLE READ
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
rollback
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ COMMITTED****单节点****commit*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ COMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ COMMITTED
begin
insert into test1 values(1,1,1,1)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
commit
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ COMMITTED****单节点****rollback*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ COMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ COMMITTED
begin
insert into test1 values(1,1,1,1)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
rollback
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ COMMITTED****2节点****commit*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ COMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ COMMITTED
begin
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
commit
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ COMMITTED****2节点****rollback*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ COMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ COMMITTED
begin
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
rollback
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ COMMITTED****3节点****commit*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ COMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ COMMITTED
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
commit
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ COMMITTED****单节点****rollback*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ COMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ COMMITTED
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
rollback
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ COMMITTED****4节点****commit*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ COMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ COMMITTED
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
commit
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ COMMITTED****4节点****rollback*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ COMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ COMMITTED
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
rollback
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ UNCOMMITTED****单节点****commit*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ UNCOMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test1 values(1,1,1,1)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
commit
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ UNCOMMITTED****单节点****rollback*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ UNCOMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test1 values(1,1,1,1)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
rollback
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ UNCOMMITTED****2节点****commit*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ UNCOMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
commit
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ UNCOMMITTED****2节点****rollback*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ UNCOMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
rollback
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ UNCOMMITTED****3节点****commit*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ UNCOMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
commit
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ UNCOMMITTED****3节点****rollback*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ UNCOMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
rollback
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ UNCOMMITTED****4节点****commit*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ UNCOMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
commit
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#*******************READ UNCOMMITTED****4节点****rollback*********************
#!share_conn_1
delete from test1
set session transaction isolation level READ UNCOMMITTED
begin
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
#!share_conn_1
select * from test1 order by id
#!share_conn_2
rollback
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#************************多种隔离级别混合************************
#!share_conn_1
delete from test1
set session transaction isolation level REPEATABLE READ
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
#!share_conn_2
set session transaction isolation level READ UNCOMMITTED
begin
select * from test1 order by id
update test1 set pad='2'
#!share_conn_1
select * from test1 order by id
#!share_conn_2
select * from test1 order by id
commit
#!share_conn_1
select * from test1 order by id
commit
select * from test1 order by id
#
#clear tables
#
drop table if exists test1