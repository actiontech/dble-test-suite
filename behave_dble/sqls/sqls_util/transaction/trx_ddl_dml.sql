#!default_db:schema1
drop table if exists test1
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
drop table if exists schema2.test2
CREATE TABLE schema2.test2(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
drop table if exists schema3.test3
CREATE TABLE schema3.test3(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#*******************insert*****单节点******commit******************
#!share_conn
SET @@session.autocommit = ON
delete from test1
start transaction
select * from test1 order by id
insert into test1 value(1,1,1,1)
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#*******************insert*****单节点******rollback******************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 value(1,1,1,1)
rollback
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
#*******************insert*****2节点******commit******************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 value(1,1,1,1)
insert into test1 value(2,2,2,2)
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 value(1,1,1,1)
insert into test1 value(2,2,2,2)
rollback
select * from test1 order by id
insert into test1 value(1,1,1,1)
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 value(1,1,1,1)
insert into test1 value(2,2,2,2)
insert into test1 value(3,3,3,3)
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 value(1,1,1,1)
insert into test1 value(2,2,2,2)
insert into test1 value(3,3,3,3)
rollback
select * from test1 order by id
insert into test1 value(1,1,1,1)
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 value(1,1,1,1)
insert into test1 value(2,2,2,2)
insert into test1 value(3,3,3,3)
insert into test1 value(4,4,4,4)
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 value(1,1,1,1)
insert into test1 value(2,2,2,2)
insert into test1 value(3,3,3,3)
insert into test1 value(4,4,4,4)
rollback
select * from test1 order by id
insert into test1 value(1,1,1,1)
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(5,5,5,5)
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(5,5,5,5)
rollback
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2)
rollback
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
rollback
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
start transaction
select * from test1 order by id
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
rollback
select * from test1 order by id
insert into test1 values(1,1,1,1)
select * from test1 order by id
#*****************update******************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
update test1 set pad=10 where id =1
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
update test1 set pad=10 where id =1
rollback
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
update test1 set pad=10 where id =1
update test1 set pad=10 where id =2
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
update test1 set pad=10 where id =1
update test1 set pad=10 where id =2
rollback
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
update test1 set pad=10 where id =1
update test1 set pad=10 where id =2
update test1 set pad=10 where id =3
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
update test1 set pad=10 where id =1
update test1 set pad=10 where id =2
update test1 set pad=10 where id =3
rollback
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
update test1 set pad=10 where id =1
update test1 set pad=10 where id =2
update test1 set pad=10 where id =3
update test1 set pad=10 where id =4
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
update test1 set pad=10 where id =1
update test1 set pad=10 where id =2
update test1 set pad=10 where id =3
update test1 set pad=10 where id =4
rollback
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
update test1 set pad =100
commit
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
update test1 set pad =100
rollback
select * from test1 order by id
update test1 set pad=10
select * from test1 order by id
#*****************delete*******************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
delete from test1 where id=1
commit
select * from test1 order by id
delete from test1 where id=2
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
delete from test1 where id=1
rollback
select * from test1 order by id
delete from test1 where id=2
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
delete from test1 where id=1
delete from test1 where id=2
commit
select * from test1 order by id
delete from test1 where id=3
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
delete from test1 where id=1
delete from test1 where id=2
rollback
select * from test1 order by id
delete from test1 where id=3
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
delete from test1 where id=1
delete from test1 where id=2
delete from test1 where id=3
commit
select * from test1 order by id
delete from test1 where id=4
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
delete from test1 where id=1
delete from test1 where id=2
delete from test1 where id=3
rollback
select * from test1 order by id
delete from test1 where id=4
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
delete from test1 where id=1
delete from test1 where id=2
delete from test1 where id=3
delete from test1 where id=4
commit
select * from test1 order by id
delete from test1 where id=3
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
delete from test1 where id=1
delete from test1 where id=2
delete from test1 where id=3
delete from test1 where id=4
rollback
select * from test1 order by id
delete from test1 where id=3
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
delete from test1
commit
select * from test1 order by id
delete from test1
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from test1 order by id
delete from test1
rollback
select * from test1 order by id
delete from test1
select * from test1 order by id
#*******************dml混合*****************************
#!share_conn
delete from test1
begin
insert into test1 values(1,1,1,1)
update test1 set pad=10 where id =1
delete from test1 where id=1
select * from test1 order by id
commit
insert into test1 values(1,1,1,1)
rollback
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
begin
insert into test1 values(1,1,1,1)
update test1 set pad=10 where id =1
delete from test1 where id=1
select * from test1 order by id
rollback
insert into test1 values(2,1,1,1)
rollback
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
begin
insert into test1 values(1,1,1,1),(2,2,2,2)
update test1 set pad=10 where id =1
delete from test1 where id=2
select * from test1 order by id
commit
update test1 set pad =100
rollback
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
begin
insert into test1 values(1,1,1,1),(2,2,2,2)
update test1 set pad=10 where id =1
delete from test1 where id=2
select * from test1 order by id
rollback
update test1 set pad =100
rollback
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
update test1 set pad=10 where id =1
delete from test1 where id=3
select * from test1 where id=2
commit
update test1 set pad =100
rollback
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
update test1 set pad=10 where id =1
delete from test1 where id=3
select * from test1 where id=2
rollback
update test1 set pad =100
rollback
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
update test1 set pad=10 where id =1
delete from test1 where id=3
select * from test1 where id=4
commit
update test1 set pad =100 where id =1
rollback
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
begin
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
update test1 set pad=10 where id =1
delete from test1 where id=3
select * from test1 where id=4
rollback
update test1 set pad =100 where id=4
rollback
select * from test1 order by id
#*******************alter*****************************
#!share_conn
delete from test1
begin
alter table test1 add name char(5)
insert into test1 values(1,1,1,1,1)
commit
insert into test1 values(2,2,1,1,1)
select * from test1 order by id
drop table test1
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
begin
alter table test1 add name char(5)
insert into test1 values(1,1,1,1,1)
rollback
insert into test1 values(2,1,1,1,1)
select * from test1 order by id
drop table test1
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from test1 order by id
#**********************create**************************
#!share_conn
drop table test1
begin
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into test1 values(1,1,1,1)
select * from test1 order by id
commit
select * from test1 order by id
#************************************************
#!share_conn
drop table test1
begin
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into test1 values(1,1,1,1)
select * from test1 order by id
rollback
select * from test1 order by id
#********************************truncate****************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1)
begin
truncate table test1
commit
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1)
begin
truncate table test1
rollback
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2)
begin
truncate table test1
commit
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2)
begin
truncate table test1
rollback
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1)
begin
truncate table test1
rollback
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
begin
truncate table test1
commit
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
begin
truncate table test1
rollback
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
begin
truncate table test1
commit
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
begin
truncate table test1
rollback
select * from test1 order by id
#********************ddl+dml混合****************************
#!share_conn
begin
drop table test1
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
alter table test1 add name char(5)
insert into test1 values(1,1,1,1,1)
select * from test1 order by id
commit
insert into test1 values(2,1,1,1,1)
select * from test1 order by id
drop table test1
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
#************************************************
#!share_conn
drop table test1
begin
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5)
truncate table test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
update test1 set pad='20' where id=1
commit
select * from test1 order by id
#************************************************
#!share_conn
drop table test1
begin
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5)
truncate table test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
update test1 set pad='20' where id=1
rollback
select * from test1 order by id
#**********************on duplicate key update**************************
#!share_conn_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
insert into test1 values(7,1,'test',1) on duplicate key update k=k*2
#!share_conn_2
SET @@session.autocommit = ON
begin
insert into test1 values(1,1,'test',1) on duplicate key update k=k*2
#!share_conn_1
commit
#!share_conn_2
commit
#!share_conn_1
select * from test1 order by id
#************************************************
#!share_conn_1
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
insert into test1 values(7,1,'test',1) on duplicate key update k=k*2
#!share_conn_2
begin
insert into test1 values(1,1,'test',1) on duplicate key update k=k*2
#!share_conn_1
rollback
#!share_conn_2
commit
#!share_conn_1
select * from test1 order by id
#********************跨表****************************
#!share_conn
delete from test1
delete from schema2.test2
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into schema2.test2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update test1 set pad=200 where id=1
select a.* from test1 a,schema2.test2 b where a.pad=b.pad order by id
commit
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
delete from schema2.test2
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into schema2.test2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update test1 set pad=200 where id=1
select a.* from test1 a,schema2.test2 b where a.pad=b.pad order by id
rollback
select * from test1 order by id
#************************************************
#!share_conn
delete from test1
delete from schema2.test2
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into schema2.test2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update test1 set pad=200 where id=1
update schema2.test2 set pad=200 where id=4
select * from test1 order by id
select * from schema2.test2 order by id
commit
select * from test1 order by id
select * from schema2.test2 order by id
#************************************************
#!share_conn
delete from test1
delete from schema2.test2
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into schema2.test2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update test1 set pad=200 where id=1
update schema2.test2 set pad=200 where id=4
select * from test1 order by id
select * from schema2.test2 order by id
rollback
select * from test1 order by id
select * from schema2.test2 order by id
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use schema3
delete from test3
insert into test3 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select a.*,b.* from test3 a,schema1.test1 b where a.pad=b.pad
update test3 set c='test'
select * from test3 order by id
select * from schema1.test1 order by id
commit
select * from test3 order by id
select * from schema1.test1 order by id
use schema1
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use schema3
delete from test3
insert into test3 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select a.*,b.* from test3 a,schema1.test1 b where a.pad=b.pad
update test3 set c='test'
select * from test3 order by id
select * from schema1.test1 order by id
rollback
select * from test3 order by id
select * from schema1.test1 order by id
use schema1
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use schema3
delete from test3
insert into test3 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update schema1.test1 set pad=200
update schema2.test2 set c='test'
select * from test3 order by id
select * from schema1.test1 order by id
commit
select * from test3 order by id
select * from schema1.test1 order by id
use schema1
#************************************************
#!share_conn
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use schema3
delete from test3
insert into test3 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update schema1.test1 set pad=200
update test3 set c='test'
select * from test3 order by id
select * from schema1.test1 order by id
rollback
select * from test3 order by id
select * from schema1.test1 order by id
use schema1
#**********************drop**************************
#!share_conn
begin
drop table test1
commit
select * from test1 order by id
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from test1 order by id
#************************************************
#!share_conn
begin
drop table test1
rollback
select * from test1 order by id
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from test1 order by id
#
#clear tables
#
drop table if exists test1
drop table if exists schema2.test2
drop table if exists schema3.test3