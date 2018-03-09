drop table if exists test_shard
CREATE TABLE test_shard(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#!share_conn
#*******************REPEATABLE READ****单节点****commit*********************
#!session 1
SET @@session.autocommit = ON
delete from test_shard
set session transaction isolation level REPEATABLE READ
begin
select * from test_shard
#!session 2
SET @@session.autocommit = ON
set session transaction isolation level REPEATABLE READ
begin
insert into test_shard values(1,1,1,1)
select * from test_shard
#!session 1
select * from test_shard
#!session 2
commit
#!session 1
select * from test_shard
commit
select * from test_shard
#*****************REPEATABLE READ*****单节点******rollback********************
#!session 1
delete from test_shard
set session transaction isolation level REPEATABLE READ
begin
select * from test_shard
#!session 2
set session transaction isolation level REPEATABLE READ
begin
insert into test_shard values(1,1,1,1)
select * from test_shard
#!session 1
select * from test_shard
#!session 2
rollback
#!session 1
select * from test_shard
commit
select * from test_shard
#*******************REPEATABLE READ****2节点****commit*********************
#!session 1
delete from test_shard
set session transaction isolation level REPEATABLE READ
begin
select * from test_shard
#!session 2
set session transaction isolation level REPEATABLE READ
begin
insert into test_shard values(1,1,1,1),(2,2,2,2)
select * from test_shard order by id
#!session 1
select * from test_shard
#!session 2
commit
#!session 1
select * from test_shard
commit
select * from test_shard order by id
#*******************REPEATABLE READ****2节点****rollback*********************
#!session 1
delete from test_shard
set session transaction isolation level REPEATABLE READ
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level REPEATABLE READ
begin
insert into test_shard values(1,1,1,1),(2,2,2,2)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
rollback
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************REPEATABLE READ****3节点****commit*********************
#!session 1
delete from test_shard
set session transaction isolation level REPEATABLE READ
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level REPEATABLE READ
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
commit
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************REPEATABLE READ****3节点****rollback*********************
#!session 1
delete from test_shard
set session transaction isolation level REPEATABLE READ
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level REPEATABLE READ
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
rollback
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************REPEATABLE READ****4节点****commit*********************
#!session 1
delete from test_shard
set session transaction isolation level REPEATABLE READ
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level REPEATABLE READ
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
commit
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************REPEATABLE READ****4节点****rollback*********************
#!session 1
delete from test_shard
set session transaction isolation level REPEATABLE READ
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level REPEATABLE READ
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
rollback
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ COMMITTED****单节点****commit*********************
#!session 1
delete from test_shard
set session transaction isolation level READ COMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ COMMITTED
begin
insert into test_shard values(1,1,1,1)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
commit
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ COMMITTED****单节点****rollback*********************
#!session 1
delete from test_shard
set session transaction isolation level READ COMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ COMMITTED
begin
insert into test_shard values(1,1,1,1)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
rollback
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ COMMITTED****2节点****commit*********************
#!session 1
delete from test_shard
set session transaction isolation level READ COMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ COMMITTED
begin
insert into test_shard values(1,1,1,1),(2,2,2,2)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
commit
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ COMMITTED****2节点****rollback*********************
#!session 1
delete from test_shard
set session transaction isolation level READ COMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ COMMITTED
begin
insert into test_shard values(1,1,1,1),(2,2,2,2)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
rollback
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ COMMITTED****3节点****commit*********************
#!session 1
delete from test_shard
set session transaction isolation level READ COMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ COMMITTED
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
commit
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ COMMITTED****单节点****rollback*********************
#!session 1
delete from test_shard
set session transaction isolation level READ COMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ COMMITTED
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
rollback
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ COMMITTED****4节点****commit*********************
#!session 1
delete from test_shard
set session transaction isolation level READ COMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ COMMITTED
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
commit
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ COMMITTED****4节点****rollback*********************
#!session 1
delete from test_shard
set session transaction isolation level READ COMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ COMMITTED
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
rollback
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ UNCOMMITTED****单节点****commit*********************
#!session 1
delete from test_shard
set session transaction isolation level READ UNCOMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test_shard values(1,1,1,1)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
commit
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ UNCOMMITTED****单节点****rollback*********************
#!session 1
delete from test_shard
set session transaction isolation level READ UNCOMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test_shard values(1,1,1,1)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
rollback
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ UNCOMMITTED****2节点****commit*********************
#!session 1
delete from test_shard
set session transaction isolation level READ UNCOMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test_shard values(1,1,1,1),(2,2,2,2)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
commit
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ UNCOMMITTED****2节点****rollback*********************
#!session 1
delete from test_shard
set session transaction isolation level READ UNCOMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test_shard values(1,1,1,1),(2,2,2,2)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
rollback
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ UNCOMMITTED****3节点****commit*********************
#!session 1
delete from test_shard
set session transaction isolation level READ UNCOMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
commit
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ UNCOMMITTED****3节点****rollback*********************
#!session 1
delete from test_shard
set session transaction isolation level READ UNCOMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
rollback
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ UNCOMMITTED****4节点****commit*********************
#!session 1
delete from test_shard
set session transaction isolation level READ UNCOMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
commit
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#*******************READ UNCOMMITTED****4节点****rollback*********************
#!session 1
delete from test_shard
set session transaction isolation level READ UNCOMMITTED
begin
select * from test_shard order by id
#!session 2
set session transaction isolation level READ UNCOMMITTED
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test_shard order by id
#!session 1
select * from test_shard order by id
#!session 2
rollback
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
#************************多种隔离级别混合************************
#!session 1
delete from test_shard
set session transaction isolation level REPEATABLE READ
begin
insert into test_shard values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test_shard order by id
#!session 2
set session transaction isolation level READ UNCOMMITTED
begin
select * from test_shard order by id
update test_shard set pad='2'
#!session 1
select * from test_shard order by id
#!session 2
select * from test_shard order by id
commit
#!session 1
select * from test_shard order by id
commit
select * from test_shard order by id
drop table if exists test_shard