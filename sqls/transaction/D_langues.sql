drop table if exists sbtest1
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
drop table if exists sbtest2
CREATE TABLE sbtest2(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#!share_conn
#*******************insert*****单节点******commit******************
#!session 1
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
#!session 1
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 value(1,1,1,1)
rollback
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
#*******************insert*****2节点******commit******************
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(5,5,5,5)
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(5,5,5,5)
rollback
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
rollback
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
rollback
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
commit
select * from sbtest1 order by id
update sbtest1 set pad=10
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
start transaction
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
rollback
select * from sbtest1 order by id
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
#*****************update******************************
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
drop table sbtest1
begin
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
commit
select * from sbtest1 order by id
#************************************************
#!session 1
drop table sbtest1
begin
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into sbtest1 values(1,1,1,1)
select * from sbtest1 order by id
rollback
select * from sbtest1 order by id
#********************************truncate****************
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1)
begin
truncate table sbtest1
commit
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1)
begin
truncate table sbtest1
rollback
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
begin
truncate table sbtest1
commit
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2)
begin
truncate table sbtest1
rollback
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1)
begin
truncate table sbtest1
rollback
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
begin
truncate table sbtest1
commit
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3)
begin
truncate table sbtest1
rollback
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
begin
truncate table sbtest1
commit
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
begin
truncate table sbtest1
rollback
select * from sbtest1 order by id
#********************ddl+dml混合****************************
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
insert into sbtest1 values(7,1,'test',1) on duplicate key update k=k*2
#!session 2
SET @@session.autocommit = ON
begin
insert into sbtest1 values(1,1,'test',1) on duplicate key update k=k*2
#!session 1
commit
#!session 2
commit
#!session 1
select * from sbtest1 order by id
#************************************************
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
insert into sbtest1 values(7,1,'test',1) on duplicate key update k=k*2
#!session 2
begin
insert into sbtest1 values(1,1,'test',1) on duplicate key update k=k*2
#!session 1
rollback
#!session 2
commit
#!session 1
select * from sbtest1 order by id
#********************跨表****************************
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
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
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use test
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select a.*,b.* from test1 a,sbtest.sbtest1 b where a.pad=b.pad
update test1 set c='test'
select * from test1 order by id
select * from sbtest.sbtest1 order by id
commit
select * from test1 order by id
select * from sbtest.sbtest1 order by id
use sbtest
#************************************************
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use test
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select a.*,b.* from test1 a,sbtest.sbtest1 b where a.pad=b.pad
update test1 set c='test'
select * from test1 order by id
select * from sbtest.sbtest1 order by id
rollback
select * from test1 order by id
select * from sbtest.sbtest1 order by id
use sbtest
#************************************************
#!session 1
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use test
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update sbtest.sbtest1 set pad=200
update test1 set c='test'
select * from test1 order by id
select * from sbtest.sbtest1 order by id
commit
select * from test1 order by id
select * from sbtest.sbtest1 order by id
use sbtest
#************************************************
#!session
delete from sbtest1
insert into sbtest1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use test
delete from test1
insert into test1 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update sbtest.sbtest1 set pad=200
update test1 set c='test'
select * from test1 order by id
select * from sbtest.sbtest1 order by id
rollback
select * from test1 order by id
select * from sbtest.sbtest1 order by id
use sbtest
#**********************drop**************************
#!session 1
begin
drop table sbtest1
commit
select * from sbtest1 order by id
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from sbtest1 order by id
#************************************************
#!session 1
begin
drop table sbtest1
rollback
select * from sbtest1 order by id
CREATE TABLE sbtest1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from sbtest1 order by id
drop table if exists sbtest1
drop table if exists sbtest2