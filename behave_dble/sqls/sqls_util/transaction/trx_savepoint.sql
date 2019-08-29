#!default_db:schema1
drop table if exists test1
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#*********************SET @@session.autocommit = ON***************************
#!share_conn_1
SET @@session.autocommit = ON
delete from test1
begin
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*******************begin********单节点*********************
#!share_conn_1
delete from test1
begin
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin***********双节点*********commit***********
#!share_conn_1
delete from test1
begin
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin***********双节点*********rollback***********
#!share_conn_1
delete from test1
begin
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin***********3节点*********commit***********
#!share_conn_1
delete from test1
begin
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin***********3节点*********rollback***********
#!share_conn_1
delete from test1
begin
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin***********4节点*********commit***********
#!share_conn_1
delete from test1
begin
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin***********4节点*********rollback***********
#!share_conn_1
delete from test1
begin
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin work***********单节点*********commit***********
#!share_conn_1
delete from test1
begin work
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin work***********单节点*********rollback***********
#!share_conn_1
delete from test1
begin work
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin work***********2节点*********commit***********
#!share_conn_1
delete from test1
begin work
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin work***********单节点*********rollback***********
#!share_conn_1
delete from test1
begin work
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin work***********3节点*********commit***********
#!share_conn_1
delete from test1
begin work
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin work***********3节点*********rollback***********
#!share_conn_1
delete from test1
begin work
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin work***********4节点*********commit***********
#!share_conn_1
delete from test1
begin work
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************begin work***********4节点*********rollback***********
#!share_conn_1
delete from test1
begin work
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************start transaction***********单节点*********commit***********
#!share_conn_1
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************start transaction***********单节点*********rollback***********
#!share_conn_1
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************start transaction***********2节点*********commit***********
#!share_conn_1
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************start transaction***********2节点*********rollback***********
#!share_conn_1
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************start transaction***********3节点*********commit***********
#!share_conn_1
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************start transaction***********3节点*********rollback***********
#!share_conn_1
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************start transaction***********4节点*********commit***********
#!share_conn_1
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************start transaction***********4节点*********rollback***********
#!share_conn_1
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
#*****************set autocommit=0***********单节点*********commit***********
#!share_conn_1
delete from test1
set autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set autocommit=1
#*****************set autocommit=0***********单节点*********rollback***********
#!share_conn_1
delete from test1
set autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set autocommit=1
#*****************set autocommit=0***********2节点*********commit***********
#!share_conn_1
delete from test1
set autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set autocommit=1
#*****************set autocommit=0***********2节点*********rollback***********
#!share_conn_1
delete from test1
set autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set autocommit=1
#*****************set autocommit=0***********3节点*********commit***********
#!share_conn_1
delete from test1
set autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set autocommit=1
#*****************set autocommit=0***********3节点*********rollback***********
#!share_conn_1
delete from test1
set autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set autocommit=1
#*****************set autocommit=0***********4节点*********commit***********
#!share_conn_1
delete from test1
set autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set autocommit=1
#*****************set autocommit=0***********单节点*********rollback***********
#!share_conn_1
delete from test1
set autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set autocommit=1
#*****************set @@session.autocommit=0***********单节点*********commit***********
#!share_conn_1
delete from test1
set @@session.autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********单节点*********rollback***********
#!share_conn_1
delete from test1
set @@session.autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********2节点*********commit***********
#!share_conn_1
delete from test1
set @@session.autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********2节点*********rollback***********
#!share_conn_1
delete from test1
set @@session.autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********3节点*********commit***********
#!share_conn_1
delete from test1
set @@session.autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********3节点*********rollback***********
#!share_conn_1
delete from test1
set @@session.autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********4节点*********commit***********
#!share_conn_1
delete from test1
set @@session.autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
commit
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set @@session.autocommit=1
#*****************set @@session.autocommit=0***********4节点*********rollback***********
#!share_conn_1
delete from test1
set @@session.autocommit=0
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
select * from test1 order by id
rollback
select * from test1 order by id
update test1 set pad=10
rollback
select * from test1 order by id
set @@session.autocommit=1
#***********************read write*************单节点************commit*****************
#!share_conn_1
delete from test1
start transaction read write
select * from test1 order by id
insert into test1 values(1,1,1,1)
#!share_conn_2
SET @@session.autocommit = ON
start transaction read write
select * from test1 order by id
insert into test1 values(5,5,5,5)
#!share_conn_1
commit
update test1 set pad=10 where id =1
select * from test1 order by id
#!share_conn_2
commit
select * from test1 order by id
#***********************read write*************单节点************ROLLBACK *****************
#!share_conn_1
delete from test1
start transaction read write
select * from test1 order by id
insert into test1 values(1,1,1,1)
#!share_conn_2
start transaction read write
select * from test1 order by id
insert into test1 values(5,5,5,5)
#!share_conn_1
rollback
insert into test1 values(1,1,1,1)
select * from test1 order by id
#!share_conn_2
commit
select * from test1 order by id
#***********************read write*************2节点************commit*****************
#!share_conn_1
delete from test1
start transaction read write
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
#!share_conn_2
start transaction read write
select * from test1 order by id
insert into test1 values(5,5,5,5),(6,6,6,6)
#!share_conn_1
commit
update test1 set pad=10 where id =1
select * from test1 order by id
#!share_conn_2
commit
select * from test1 order by id
#***********************read write*************2节点************ROLLBACK *****************
#!share_conn_1
delete from test1
start transaction read write
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
#!share_conn_2
start transaction read write
select * from test1 order by id
insert into test1 values(5,5,5,5),(6,6,6,6)
#!share_conn_1
rollback
insert into test1 values(1,1,1,1)
select * from test1 order by id
#!share_conn_2
commit
select * from test1 order by id
#***********************read write*************3节点************COMMIT *****************
#!share_conn_1
delete from test1
start transaction read write
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
#!share_conn_2
start transaction read write
select * from test1 order by id
insert into test1 values(5,5,5,5),(6,6,6,6),(7,7,7,7)
#!share_conn_1
commit
update test1 set pad=10 where id =1
select * from test1 order by id
#!share_conn_2
commit
select * from test1 order by id
#***********************read write*************3节点************ROLLBACK *****************
#!share_conn_1
delete from test1
start transaction read write
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
#!share_conn_2
start transaction read write
select * from test1 order by id
insert into test1 values(5,5,5,5),(6,6,6,6),(7,7,7,7)
#!share_conn_1
rollback
insert into test1 values(1,1,1,1)
select * from test1 order by id
#!share_conn_2
commit
select * from test1 order by id
#***********************read write*************4节点************COMMIT *****************
#!share_conn_1
delete from test1
start transaction read write
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
#!share_conn_2
start transaction read write
select * from test1 order by id
insert into test1 values(5,5,5,5),(6,6,6,6),(7,7,7,7),(8,8,8,8)
#!share_conn_1
commit
update test1 set pad=10 where id =1
select * from test1 order by id
#!share_conn_2
commit
select * from test1 order by id
#***********************read write*************4节点************ROLLBACK *****************
#!share_conn_1
delete from test1
start transaction read write
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
#!share_conn_2
start transaction read write
select * from test1 order by id
insert into test1 values(5,5,5,5),(6,6,6,6),(7,7,7,7),(8,8,8,8)
#!share_conn_1
rollback
insert into test1 values(1,1,1,1)
select * from test1 order by id
#!share_conn_2
commit
select * from test1 order by id
#
#clear tables
#
drop table if exists test1