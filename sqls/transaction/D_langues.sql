drop table if exists sbtest1
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
drop table if exists sbtest2
CREATE TABLE sbtest2(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
drop table if exists testdb.tb_test
CREATE TABLE testdb.tb_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#*******************insert*****单节点******commit******************
#!share_conn
SET @@session.autocommit = ON
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 value(1,1,1,1)
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#*******************insert*****单节点******rollback******************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 value(1,1,1,1)
rollback
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
#*******************insert*****2节点******commit******************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 value(1,1,1,1)
insert into sbtest1 value(2,2,2,2)
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 value(1,1,1,1)
insert into sbtest1 value(2,2,2,2)
rollback
select * from sbtest1 order by id
insert into sbtest1 value(1,1,1,1)
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 value(1,1,1,1)
insert into sbtest1 value(2,2,2,2)
insert into sbtest1 value(3,3,3,3)
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 value(1,1,1,1)
insert into sbtest1 value(2,2,2,2)
insert into sbtest1 value(3,3,3,3)
rollback
select * from sbtest1 order by id
insert into sbtest1 value(1,1,1,1)
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 value(1,1,1,1)
insert into sbtest1 value(2,2,2,2)
insert into sbtest1 value(3,3,3,3)
insert into sbtest1 value(4,4,4,4)
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 value(1,1,1,1)
insert into sbtest1 value(2,2,2,2)
insert into sbtest1 value(3,3,3,3)
insert into sbtest1 value(4,4,4,4)
rollback
select * from sbtest1 order by id
insert into sbtest1 value(1,1,1,1)
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(5,5,5,5)
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(5,5,5,5)
rollback
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
rollback
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
rollback
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
rollback
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
#*****************update******************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
update sbtest1 set pad=10 where id =1
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
update sbtest1 set pad=10 where id =1
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
update sbtest1 set pad=10 where id =1
update sbtest1 set pad=10 where id =2
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
update sbtest1 set pad=10 where id =1
update sbtest1 set pad=10 where id =2
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
update sbtest1 set pad=10 where id =1
update sbtest1 set pad=10 where id =2
update sbtest1 set pad=10 where id =3
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
update sbtest1 set pad=10 where id =1
update sbtest1 set pad=10 where id =2
update sbtest1 set pad=10 where id =3
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
update sbtest1 set pad=10 where id =1
update sbtest1 set pad=10 where id =2
update sbtest1 set pad=10 where id =3
update sbtest1 set pad=10 where id =4
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
update sbtest1 set pad=10 where id =1
update sbtest1 set pad=10 where id =2
update sbtest1 set pad=10 where id =3
update sbtest1 set pad=10 where id =4
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
update sbtest1 set pad =100
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
update sbtest1 set pad =100
rollback
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#*****************delete*******************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
delete from sbtest1 where id=1
commit
select * from sbtest1 order by id
delete from sbtest1 where id=2
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
delete from sbtest1 where id=1
rollback
select * from sbtest1 order by id
delete from sbtest1 where id=2
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
delete from sbtest1 where id=1
delete from sbtest1 where id=2
commit
select * from sbtest1 order by id
delete from sbtest1 where id=3
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
delete from sbtest1 where id=1
delete from sbtest1 where id=2
rollback
select * from sbtest1 order by id
delete from sbtest1 where id=3
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
delete from sbtest1 where id=1
delete from sbtest1 where id=2
delete from sbtest1 where id=3
commit
select * from sbtest1 order by id
delete from sbtest1 where id=4
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
delete from sbtest1 where id=1
delete from sbtest1 where id=2
delete from sbtest1 where id=3
rollback
select * from sbtest1 order by id
delete from sbtest1 where id=4
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
delete from sbtest1 where id=1
delete from sbtest1 where id=2
delete from sbtest1 where id=3
delete from sbtest1 where id=4
commit
select * from sbtest1 order by id
delete from sbtest1 where id=3
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
delete from sbtest1 where id=1
delete from sbtest1 where id=2
delete from sbtest1 where id=3
delete from sbtest1 where id=4
rollback
select * from sbtest1 order by id
delete from sbtest1 where id=3
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
delete from sbtest1
commit
select * from sbtest1 order by id
delete from sbtest1
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from sbtest1 order by id
delete from sbtest1
rollback
select * from sbtest1 order by id
delete from sbtest1
select * from sbtest1 order by id
#*******************dml混合*****************************
#!share_conn
delete from sbtest1
begin
insert into sbtest1 values(1,1,1,1)
update sbtest1 set pad=10 where id =1
delete from sbtest1 where id=1
select * from sbtest1 order by id
commit
insert into sbtest1 values(1,1,1,1)
rollback
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
begin
insert into sbtest1 values(1,1,1,1)
update sbtest1 set pad=10 where id =1
delete from sbtest1 where id=1
select * from sbtest1 order by id
rollback
insert into sbtest1 values(2,1,1,1)
rollback
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
begin
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
update sbtest1 set pad=10 where id =1
delete from sbtest1 where id=2
select * from sbtest1 order by id
commit
update sbtest1 set pad =100
rollback
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
begin
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
update sbtest1 set pad=10 where id =1
delete from sbtest1 where id=2
select * from sbtest1 order by id
rollback
update sbtest1 set pad =100
rollback
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
begin
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
update sbtest1 set pad=10 where id =1
delete from sbtest1 where id=3
select * from sbtest1 where id=2
commit
update sbtest1 set pad =100
rollback
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
begin
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
update sbtest1 set pad=10 where id =1
delete from sbtest1 where id=3
select * from sbtest1 where id=2
rollback
update sbtest1 set pad =100
rollback
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
begin
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
update sbtest1 set pad=10 where id =1
delete from sbtest1 where id=3
select * from sbtest1 where id=4
commit
update sbtest1 set pad =100 where id =1
rollback
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
begin
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
update sbtest1 set pad=10 where id =1
delete from sbtest1 where id=3
select * from sbtest1 where id=4
rollback
update sbtest1 set pad =100 where id=4
rollback
select * from sbtest1 order by id
#*******************alter*****************************
#!share_conn
delete from sbtest1
begin
alter table sbtest1 add name char(5)
insert into sbtest1 values(1,1,1,1,1)
commit
insert into sbtest1 values(2,2,1,1,1)
select * from sbtest1 order by id
drop table sbtest1
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
begin
alter table sbtest1 add name char(5)
insert into sbtest1 values(1,1,1,1,1)
rollback
insert into sbtest1 values(2,1,1,1,1)
select * from sbtest1 order by id
drop table sbtest1
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from sbtest1 order by id
#**********************create**************************
#!share_conn
drop table sbtest1
begin
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
#************************************************
#!share_conn
drop table sbtest1
begin
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
#********************************truncate****************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1)
begin
truncate table sbtest1
commit
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1)
begin
truncate table sbtest1
rollback
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
begin
truncate table sbtest1
commit
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
begin
truncate table sbtest1
rollback
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1)
begin
truncate table sbtest1
rollback
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
begin
truncate table sbtest1
commit
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
begin
truncate table sbtest1
rollback
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
begin
truncate table sbtest1
commit
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
begin
truncate table sbtest1
rollback
select * from sbtest1 order by id
#********************ddl+dml混合****************************
#!share_conn
begin
drop table sbtest1
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
alter table sbtest1 add name char(5)
insert into sbtest1 values(1,1,1,1,1)
select * from sbtest1 order by id
commit
insert into sbtest1 values(2,1,1,1,1)
select * from sbtest1 order by id
drop table sbtest1
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
#************************************************
#!share_conn
drop table sbtest1
begin
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5)
truncate table sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
update sbtest1 set pad='20' where id=1
commit
select * from sbtest1 order by id
#************************************************
#!share_conn
drop table sbtest1
begin
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5)
truncate table sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
update sbtest1 set pad='20' where id=1
rollback
select * from sbtest1 order by id
#**********************on duplicate key update**************************
#!share_conn_1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
insert into sbtest1 values(7,1,'test',1) on duplicate key update k=k*2
#!share_conn_2
SET @@session.autocommit = ON
begin
insert into sbtest1 values(1,1,'test',1) on duplicate key update k=k*2
#!share_conn_1
commit
#!share_conn_2
commit
#!share_conn_1
select * from sbtest1 order by id
#************************************************
#!share_conn_1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
insert into sbtest1 values(7,1,'test',1) on duplicate key update k=k*2
#!share_conn_2
begin
insert into sbtest1 values(1,1,'test',1) on duplicate key update k=k*2
#!share_conn_1
rollback
#!share_conn_2
commit
#!share_conn_1
select * from sbtest1 order by id
#********************跨表****************************
#!share_conn
delete from sbtest1
delete from sbtest2
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into sbtest2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update sbtest1 set pad=200 where id=1
select a.* from sbtest1 a,sbtest2 b where a.pad=b.pad order by id
commit
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
delete from sbtest2
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into sbtest2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update sbtest1 set pad=200 where id=1
select a.* from sbtest1 a,sbtest2 b where a.pad=b.pad order by id
rollback
select * from sbtest1 order by id
#************************************************
#!share_conn
delete from sbtest1
delete from sbtest2
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into sbtest2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update sbtest1 set pad=200 where id=1
update sbtest2 set pad=200 where id=4
select * from sbtest1 order by id
select * from sbtest2 order by id
commit
select * from sbtest1 order by id
select * from sbtest2 order by id
#************************************************
#!share_conn
delete from sbtest1
delete from sbtest2
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into sbtest2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update sbtest1 set pad=200 where id=1
update sbtest2 set pad=200 where id=4
select * from sbtest1 order by id
select * from sbtest2 order by id
rollback
select * from sbtest1 order by id
select * from sbtest2 order by id
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use testdb
delete from tb_test
insert into tb_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select a.*,b.* from tb_test a,mytest.sbtest1 b where a.pad=b.pad
update tb_test set c='test'
select * from tb_test order by id
select * from mytest.sbtest1 order by id
commit
select * from tb_test order by id
select * from mytest.sbtest1 order by id
use mytest
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use testdb
delete from tb_test
insert into tb_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select a.*,b.* from tb_test a,mytest.sbtest1 b where a.pad=b.pad
update tb_test set c='test'
select * from tb_test order by id
select * from mytest.sbtest1 order by id
rollback
select * from tb_test order by id
select * from mytest.sbtest1 order by id
use mytest
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use testdb
delete from tb_test
insert into tb_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update mytest.sbtest1 set pad=200
update tb_test set c='test'
select * from tb_test order by id
select * from mytest.sbtest1 order by id
commit
select * from tb_test order by id
select * from mytest.sbtest1 order by id
use mytest
#************************************************
#!share_conn
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use testdb
delete from tb_test
insert into tb_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update mytest.sbtest1 set pad=200
update tb_test set c='test'
select * from tb_test order by id
select * from mytest.sbtest1 order by id
rollback
select * from tb_test order by id
select * from mytest.sbtest1 order by id
use mytest
#**********************drop**************************
#!share_conn
begin
drop table sbtest1
commit
select * from sbtest1 order by id
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from sbtest1 order by id
#************************************************
#!share_conn
begin
drop table sbtest1
rollback
select * from sbtest1 order by id
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from sbtest1 order by id
#
#clear tables
#
drop table if exists sbtest1
drop table if exists sbtest2
drop table if exists testdb.tb_test