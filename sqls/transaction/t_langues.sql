drop table if exists sbtest1
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#*********************SET @@session.autocommit = ON***************************
#!share_conn
SET @@session.autocommit = ON
delete from sbtest1
begin
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*******************begin********单节点*********************
#!share_conn
delete from sbtest1
begin
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin***********双节点*********commit***********
#!share_conn
delete from sbtest1
begin
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin***********双节点*********rollback***********
#!share_conn
delete from sbtest1
begin
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin***********3节点*********commit***********
#!share_conn
delete from sbtest1
begin
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin***********3节点*********rollback***********
#!share_conn
delete from sbtest1
begin
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin***********4节点*********commit***********
#!share_conn
delete from sbtest1
begin
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin***********4节点*********rollback***********
#!share_conn
delete from sbtest1
begin
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin work***********单节点*********commit***********
#!share_conn
delete from sbtest1
begin work
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin work***********单节点*********rollback***********
#!share_conn
delete from sbtest1
begin work
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin work***********2节点*********commit***********
#!share_conn
delete from sbtest1
begin work
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin work***********单节点*********rollback***********
#!share_conn
delete from sbtest1
begin work
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin work***********3节点*********commit***********
#!share_conn
delete from sbtest1
begin work
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin work***********3节点*********rollback***********
#!share_conn
delete from sbtest1
begin work
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin work***********4节点*********commit***********
#!share_conn
delete from sbtest1
begin work
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************begin work***********4节点*********rollback***********
#!share_conn
delete from sbtest1
begin work
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************start transaction***********单节点*********commit***********
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************start transaction***********单节点*********rollback***********
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************start transaction***********2节点*********commit***********
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************start transaction***********2节点*********rollback***********
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************start transaction***********3节点*********commit***********
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************start transaction***********3节点*********rollback***********
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************start transaction***********4节点*********commit***********
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************start transaction***********4节点*********rollback***********
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
#*****************set autocommit=0***********单节点*********commit***********
#!share_conn
delete from sbtest1
set autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set autocommit=1
#*****************set autocommit=0***********单节点*********rollback***********
#!share_conn
delete from sbtest1
set autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set autocommit=1
#*****************set autocommit=0***********2节点*********commit***********
#!share_conn
delete from sbtest1
set autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set autocommit=1
#*****************set autocommit=0***********2节点*********rollback***********
#!share_conn
delete from sbtest1
set autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set autocommit=1
#*****************set autocommit=0***********3节点*********commit***********
#!share_conn
delete from sbtest1
set autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set autocommit=1
#*****************set autocommit=0***********3节点*********rollback***********
#!share_conn
delete from sbtest1
set autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set autocommit=1
#*****************set autocommit=0***********4节点*********commit***********
#!share_conn
delete from sbtest1
set autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set autocommit=1
#*****************set autocommit=0***********单节点*********rollback***********
#!share_conn
delete from sbtest1
set autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set autocommit=1
#*****************set @@session.autocommit=0***********单节点*********commit***********
#!share_conn
delete from sbtest1
set @@session.autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********单节点*********rollback***********
#!share_conn
delete from sbtest1
set @@session.autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********2节点*********commit***********
#!share_conn
delete from sbtest1
set @@session.autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********2节点*********rollback***********
#!share_conn
delete from sbtest1
set @@session.autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********3节点*********commit***********
#!share_conn
delete from sbtest1
set @@session.autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********3节点*********rollback***********
#!share_conn
delete from sbtest1
set @@session.autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********4节点*********commit***********
#!share_conn
delete from sbtest1
set @@session.autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********4节点*********rollback***********
#!share_conn
delete from sbtest1
set @@session.autocommit=0
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
rollback
select * from sbtest1 order by id
set @@session.autocommit=1
drop table if exists sbtest1
--#***********************read write*************************
--#!share_conn
--delete from sbtest1
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(1,1,1,1)
--#!session 2
--SET @@session.autocommit = ON
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(5,5,5,5)
--#!share_conn
--commit
--update sbtest1 set pad=10 where id =1
--select * from sbtest1 order by id
--#!session 2
--commit
--select * from sbtest1 order by id
--#************************************************
--#!share_conn
--delete from sbtest1
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(1,1,1,1)
--#!session 2
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(5,5,5,5)
--#!share_conn
--rollback
--insert into sbtest1 values(1,1,1,1)
--select * from sbtest1 order by id
--#!session 2
--commit
--select * from sbtest1 order by id
--#************************************************
--#!share_conn
--delete from sbtest1
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(1,1,1,1),(2,2,2,2)
--#!session 2
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(5,5,5,5),(6,6,6,6)
--#!share_conn
--commit
--update sbtest1 set pad=10 where id =1
--select * from sbtest1 order by id
--#!session 2
--commit
--select * from sbtest1 order by id
--#************************************************
--#!share_conn
--delete from sbtest1
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(1,1,1,1),(2,2,2,2)
--#!session 2
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(5,5,5,5),(6,6,6,6)
--#!share_conn
--rollback
--insert into sbtest1 values(1,1,1,1)
--select * from sbtest1 order by id
--#!session 2
--commit
--select * from sbtest1 order by id
--#************************************************
--#!share_conn
--delete from sbtest1
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
--#!session 2
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(5,5,5,5),(6,6,6,6),(7,7,7,7)
--#!share_conn
--commit
--update sbtest1 set pad=10 where id =1
--select * from sbtest1 order by id
--#!session 2
--commit
--select * from sbtest1 order by id
--#************************************************
--#!share_conn
--delete from sbtest1
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(1,1,1,1),(2,2,2,2,(3,3,3,3)
--#!session 2
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(5,5,5,5),(6,6,6,6),(7,7,7,7)
--#!share_conn
--rollback
--insert into sbtest1 values(1,1,1,1)
--select * from sbtest1 order by id
--#!session 2
--commit
--select * from sbtest1 order by id
--#************************************************
--#!share_conn
--delete from sbtest1
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
--#!session 2
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(5,5,5,5),(6,6,6,6),(7,7,7,7),(8,8,8,8)
--#!share_conn
--commit
--update sbtest1 set pad=10 where id =1
--select * from sbtest1 order by id
--#!session 2
--commit
--select * from sbtest1 order by id
--#************************************************
--#!share_conn
--delete from sbtest1
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(1,1,1,1),(2,2,2,2,(3,3,3,3),(4,4,4,4)
--#!session 2
--start transaction read write
--select * from sbtest1 order by id
--insert into sbtest1 values(5,5,5,5),(6,6,6,6),(7,7,7,7),(8,8,8,8)
--#!share_conn
--rollback
--insert into sbtest1 values(1,1,1,1)
--select * from sbtest1 order by id
--#!session 2
--commit
--select * from sbtest1 order by id