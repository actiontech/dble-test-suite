drop table if exists aly_test
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
drop table if exists aly_order
CREATE TABLE aly_order(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
drop table if exists testdb.tb_test
CREATE TABLE testdb.tb_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))
#*******************insert*****单节点******commit******************
#!share_conn
SET @@session.autocommit = ON
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test value(1,1,1,1)
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#*******************insert*****单节点******rollback******************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test value(1,1,1,1)
rollback
select * from aly_test order by id
insert into aly_test values(1,1,1,1)
select * from aly_test order by id
#*******************insert*****2节点******commit******************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test value(1,1,1,1)
insert into aly_test value(2,2,2,2)
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test value(1,1,1,1)
insert into aly_test value(2,2,2,2)
rollback
select * from aly_test order by id
insert into aly_test value(1,1,1,1)
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test value(1,1,1,1)
insert into aly_test value(2,2,2,2)
insert into aly_test value(3,3,3,3)
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test value(1,1,1,1)
insert into aly_test value(2,2,2,2)
insert into aly_test value(3,3,3,3)
rollback
select * from aly_test order by id
insert into aly_test value(1,1,1,1)
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test value(1,1,1,1)
insert into aly_test value(2,2,2,2)
insert into aly_test value(3,3,3,3)
insert into aly_test value(4,4,4,4)
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test value(1,1,1,1)
insert into aly_test value(2,2,2,2)
insert into aly_test value(3,3,3,3)
insert into aly_test value(4,4,4,4)
rollback
select * from aly_test order by id
insert into aly_test value(1,1,1,1)
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test values(1,1,1,1),(5,5,5,5)
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test values(1,1,1,1),(5,5,5,5)
rollback
select * from aly_test order by id
insert into aly_test values(1,1,1,1)
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test values(1,1,1,1),(2,2,2,2)
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test values(1,1,1,1),(2,2,2,2)
rollback
select * from aly_test order by id
insert into aly_test values(1,1,1,1)
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3)
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3)
rollback
select * from aly_test order by id
insert into aly_test values(1,1,1,1)
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
start transaction
select * from aly_test order by id
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
rollback
select * from aly_test order by id
insert into aly_test values(1,1,1,1)
select * from aly_test order by id
#*****************update******************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
update aly_test set pad=10 where id =1
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
update aly_test set pad=10 where id =1
rollback
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
update aly_test set pad=10 where id =1
update aly_test set pad=10 where id =2
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
update aly_test set pad=10 where id =1
update aly_test set pad=10 where id =2
rollback
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
update aly_test set pad=10 where id =1
update aly_test set pad=10 where id =2
update aly_test set pad=10 where id =3
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
update aly_test set pad=10 where id =1
update aly_test set pad=10 where id =2
update aly_test set pad=10 where id =3
rollback
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
update aly_test set pad=10 where id =1
update aly_test set pad=10 where id =2
update aly_test set pad=10 where id =3
update aly_test set pad=10 where id =4
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
update aly_test set pad=10 where id =1
update aly_test set pad=10 where id =2
update aly_test set pad=10 where id =3
update aly_test set pad=10 where id =4
rollback
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
update aly_test set pad =100
commit
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
update aly_test set pad =100
rollback
select * from aly_test order by id
update aly_test set pad=10
select * from aly_test order by id
#*****************delete*******************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
delete from aly_test where id=1
commit
select * from aly_test order by id
delete from aly_test where id=2
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
delete from aly_test where id=1
rollback
select * from aly_test order by id
delete from aly_test where id=2
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
delete from aly_test where id=1
delete from aly_test where id=2
commit
select * from aly_test order by id
delete from aly_test where id=3
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
delete from aly_test where id=1
delete from aly_test where id=2
rollback
select * from aly_test order by id
delete from aly_test where id=3
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
delete from aly_test where id=1
delete from aly_test where id=2
delete from aly_test where id=3
commit
select * from aly_test order by id
delete from aly_test where id=4
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
delete from aly_test where id=1
delete from aly_test where id=2
delete from aly_test where id=3
rollback
select * from aly_test order by id
delete from aly_test where id=4
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
delete from aly_test where id=1
delete from aly_test where id=2
delete from aly_test where id=3
delete from aly_test where id=4
commit
select * from aly_test order by id
delete from aly_test where id=3
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
delete from aly_test where id=1
delete from aly_test where id=2
delete from aly_test where id=3
delete from aly_test where id=4
rollback
select * from aly_test order by id
delete from aly_test where id=3
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
delete from aly_test
commit
select * from aly_test order by id
delete from aly_test
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
start transaction
select * from aly_test order by id
delete from aly_test
rollback
select * from aly_test order by id
delete from aly_test
select * from aly_test order by id
#*******************dml混合*****************************
#!share_conn
delete from aly_test
begin
insert into aly_test values(1,1,1,1)
update aly_test set pad=10 where id =1
delete from aly_test where id=1
select * from aly_test order by id
commit
insert into aly_test values(1,1,1,1)
rollback
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
begin
insert into aly_test values(1,1,1,1)
update aly_test set pad=10 where id =1
delete from aly_test where id=1
select * from aly_test order by id
rollback
insert into aly_test values(2,1,1,1)
rollback
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
begin
insert into aly_test values(1,1,1,1),(2,2,2,2)
update aly_test set pad=10 where id =1
delete from aly_test where id=2
select * from aly_test order by id
commit
update aly_test set pad =100
rollback
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
begin
insert into aly_test values(1,1,1,1),(2,2,2,2)
update aly_test set pad=10 where id =1
delete from aly_test where id=2
select * from aly_test order by id
rollback
update aly_test set pad =100
rollback
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
begin
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3)
update aly_test set pad=10 where id =1
delete from aly_test where id=3
select * from aly_test where id=2
commit
update aly_test set pad =100
rollback
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
begin
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3)
update aly_test set pad=10 where id =1
delete from aly_test where id=3
select * from aly_test where id=2
rollback
update aly_test set pad =100
rollback
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
begin
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
update aly_test set pad=10 where id =1
delete from aly_test where id=3
select * from aly_test where id=4
commit
update aly_test set pad =100 where id =1
rollback
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
begin
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
update aly_test set pad=10 where id =1
delete from aly_test where id=3
select * from aly_test where id=4
rollback
update aly_test set pad =100 where id=4
rollback
select * from aly_test order by id
#*******************alter*****************************
#!share_conn
delete from aly_test
begin
alter table aly_test add name char(5)
insert into aly_test values(1,1,1,1,1)
commit
insert into aly_test values(2,2,1,1,1)
select * from aly_test order by id
drop table aly_test
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
begin
alter table aly_test add name char(5)
insert into aly_test values(1,1,1,1,1)
rollback
insert into aly_test values(2,1,1,1,1)
select * from aly_test order by id
drop table aly_test
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from aly_test order by id
#**********************create**************************
#!share_conn
drop table aly_test
begin
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into aly_test values(1,1,1,1)
select * from aly_test order by id
commit
select * from aly_test order by id
#************************************************
#!share_conn
drop table aly_test
begin
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into aly_test values(1,1,1,1)
select * from aly_test order by id
rollback
select * from aly_test order by id
#********************************truncate****************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1)
begin
truncate table aly_test
commit
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1)
begin
truncate table aly_test
rollback
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2)
begin
truncate table aly_test
commit
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2)
begin
truncate table aly_test
rollback
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1)
begin
truncate table aly_test
rollback
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3)
begin
truncate table aly_test
commit
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3)
begin
truncate table aly_test
rollback
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
begin
truncate table aly_test
commit
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)
begin
truncate table aly_test
rollback
select * from aly_test order by id
#********************ddl+dml混合****************************
#!share_conn
begin
drop table aly_test
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
alter table aly_test add name char(5)
insert into aly_test values(1,1,1,1,1)
select * from aly_test order by id
commit
insert into aly_test values(2,1,1,1,1)
select * from aly_test order by id
drop table aly_test
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
#************************************************
#!share_conn
drop table aly_test
begin
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5)
truncate table aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3)
update aly_test set pad='20' where id=1
commit
select * from aly_test order by id
#************************************************
#!share_conn
drop table aly_test
begin
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5)
truncate table aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3)
update aly_test set pad='20' where id=1
rollback
select * from aly_test order by id
#**********************on duplicate key update**************************
#!share_conn_1
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
insert into aly_test values(7,1,'test',1) on duplicate key update k=k*2
#!share_conn_2
SET @@session.autocommit = ON
begin
insert into aly_test values(1,1,'test',1) on duplicate key update k=k*2
#!share_conn_1
commit
#!share_conn_2
commit
#!share_conn_1
select * from aly_test order by id
#************************************************
#!share_conn_1
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
insert into aly_test values(7,1,'test',1) on duplicate key update k=k*2
#!share_conn_2
begin
insert into aly_test values(1,1,'test',1) on duplicate key update k=k*2
#!share_conn_1
rollback
#!share_conn_2
commit
#!share_conn_1
select * from aly_test order by id
#********************跨表****************************
#!share_conn
delete from aly_test
delete from aly_order
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into aly_order values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update aly_test set pad=200 where id=1
select a.* from aly_test a,aly_order b where a.pad=b.pad order by id
commit
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
delete from aly_order
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into aly_order values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update aly_test set pad=200 where id=1
select a.* from aly_test a,aly_order b where a.pad=b.pad order by id
rollback
select * from aly_test order by id
#************************************************
#!share_conn
delete from aly_test
delete from aly_order
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into aly_order values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update aly_test set pad=200 where id=1
update aly_order set pad=200 where id=4
select * from aly_test order by id
select * from aly_order order by id
commit
select * from aly_test order by id
select * from aly_order order by id
#************************************************
#!share_conn
delete from aly_test
delete from aly_order
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
insert into aly_order values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update aly_test set pad=200 where id=1
update aly_order set pad=200 where id=4
select * from aly_test order by id
select * from aly_order order by id
rollback
select * from aly_test order by id
select * from aly_order order by id
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use testdb
delete from tb_test
insert into tb_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select a.*,b.* from tb_test a,mytest.aly_test b where a.pad=b.pad
update tb_test set c='test'
select * from tb_test order by id
select * from mytest.aly_test order by id
commit
select * from tb_test order by id
select * from mytest.aly_test order by id
use mytest
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use testdb
delete from tb_test
insert into tb_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
select a.*,b.* from tb_test a,mytest.aly_test b where a.pad=b.pad
update tb_test set c='test'
select * from tb_test order by id
select * from mytest.aly_test order by id
rollback
select * from tb_test order by id
select * from mytest.aly_test order by id
use mytest
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use testdb
delete from tb_test
insert into tb_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update mytest.aly_test set pad=200
update tb_test set c='test'
select * from tb_test order by id
select * from mytest.aly_test order by id
commit
select * from tb_test order by id
select * from mytest.aly_test order by id
use mytest
#************************************************
#!share_conn
delete from aly_test
insert into aly_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
use testdb
delete from tb_test
insert into tb_test values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4),(5,5,5,5),(6,6,6,6)
begin
update mytest.aly_test set pad=200
update tb_test set c='test'
select * from tb_test order by id
select * from mytest.aly_test order by id
rollback
select * from tb_test order by id
select * from mytest.aly_test order by id
use mytest
#**********************drop**************************
#!share_conn
begin
drop table aly_test
commit
select * from aly_test order by id
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from aly_test order by id
#************************************************
#!share_conn
begin
drop table aly_test
rollback
select * from aly_test order by id
CREATE TABLE aly_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))
select * from aly_test order by id
#
#clear tables
#
drop table if exists aly_test
drop table if exists aly_order
drop table if exists testdb.tb_test