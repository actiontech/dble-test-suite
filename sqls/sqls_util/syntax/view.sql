#!default_db:schema1
drop table if exists test1
create table test1 (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT int(11))
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string',1),(3,3, 'another',3),(2,2, 'a\nstring',3),(4,4, '中',2),(5,5, 'a\'string\'',5),(6,6, 'a\""string\""',5),(7,7, 'a\bstring',5),(8,8, 'a\nstring',6),(9,9, 'a\rstring',6),(10,10, 'a\tstring',2)
###########################select grammar on the view####################
drop view if exists view_test
create view view_test as select 1*4
select * from view_test
drop view view_test
create view view_test as select * from test1
select * from view_test
drop view view_test
create view view_test as select * from test1 where R_NAME like'%string%'
select * from view_test
drop view view_test
create view view_test as select sum(id),R_COMMENT from test1 group by R_COMMENT 
select * from view_test
drop view view_test
create view view_test as select sum(id) a,R_COMMENT from test1 group by R_COMMENT order by a 
select * from view_test
drop view view_test
create view view_test as select sum(id) a,R_COMMENT from test1 group by R_COMMENT having R_COMMENT<6 order by a 
select * from view_test
drop view view_test
create view view_test as select sum(id) a,R_COMMENT from test1 group by R_COMMENT having R_COMMENT<6 order by a limit 3 
select * from view_test
drop view view_test
drop table if exists test1
drop table if exists schema2.test2
drop table if exists schema3.test3
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))
CREATE TABLE schema2.test2(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))
CREATE TABLE schema3.test3(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))
insert into test1 values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3)
insert into schema2.test2 values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
create view view_test as select test1.id,test1.name,schema2.test2.pad from test1,schema2.test2 where test1.id=schema2.test2.id
select * from view_test
drop view view_test
create view view_test as select test1.id,test1.name,schema2.test2.pad,schema3.test3.m_id from test1,schema2.test2,schema3.test3 where test1.id=schema2.test2.id and test1.pad=schema3.test3.pad
select * from view_test
drop view view_test
create view view_test as select test1.id,test1.name,test1.pad,schema2.test2.name as a_name from test1 inner join schema2.test2
select * from view_test
drop view view_test
create view view_test as select a.id,b.pad,a.t_id from test1 a,(select all * from schema2.test2) b where a.t_id=b.o_id
select * from view_test
drop view view_test
create view view_test as select a.id,b.id as b_id,b.pad,a.t_id from test1 a,(select all * from schema2.test2) b where a.t_id=b.o_id
select * from view_test
drop view view_test
create view view_test as select * from test1 union select * from schema2.test2
select * from view_test
drop view view_test
####################################view grammar#######################
create or replace view view_test as select * from test1
select * from view_test
create or replace view view_test as select * from test1 where R_NAME like'%string%'
select * from view_test
drop view view_test
#create or replace algorithm=undefined view view_test as select * from test1
#create or replace algorithm=undefined view view_test as select * from test1 where R_NAME like'%string%'
#create or replace algorithm=merge view view_test as select * from test1
#create or replace algorithm=merge view view_test as select * from test1 where R_NAME like'%string%'
#create or replace algorithm=temptable view view_test as select * from test1
#create or replace algorithm=temptable view view_test as select * from test1 where R_NAME like'%string%'
#create or replace definer=test view view_test as select * from test1
#create or replace definer=test view view_test as select * from test1 where R_NAME like'%string%'
#create or replace definer=current_user view view_test as select * from test1
#create or replace definer=current_user view view_test as select * from test1 where R_NAME like'%string%'
#create or replace sql security definer view view_test as select * from test1
#create or replace sql security definer view view_test as select * from test1 where R_NAME like'%string%'
#create or replace sql security invoker view view_test as select * from test1
#create or replace sql security invoker view view_test as select * from test1 where R_NAME like'%string%'
#create view view_test as select * from test1 with check option
#create view view_test as select * from test1 with cascaded check option
#create view view_test as select * from test1 with local check option
######################alter view ###################################
create or replace view view_test as select * from test1
alter view view_test as select * from schema2.test2
select * from view_test
drop view view_test
create or replace view view_test as select * from test1
alter view view_test(name) as select name from schema2.test2
select * from view_test
drop view view_test
########################drop view#################################
create view view_test as select * from test1
select * from view_test
drop view view_test
create view view_test as select * from test1
create view view_test1 as select * from schema2.test2
select * from view_test
drop view view_test,view_test1
select * from view_test1/*table doesn't exist*/
#create view view_test as select * from test1
#select * from view_test
#drop view view_test retrict
#create view view_test as select * from test1
#select * from view_test
#drop view view_test cascade
drop view if exists view_test
select * from view_test/*table doesn't exist*/
create view view_test as select * from test1
select * from view_test
drop view if exists view_test
select * from view_test/*table doesn't exist*/
######################Related to select syntax################
create view view_test as select * from test1
select * from schema2.test2 a join view_test b where a.pad=b.pad
select count(*) from (select * from view_test) a
select * from schema2.test2 union select * from view_test
select * from schema2.test2 where id<(select count(*) from view_test)
drop view view_test
####################The features of distributed view###########
create view view_test as select R_NAME from test1
select * from view_test
alter table test1 change R_NAME name varchar(50)
select * from view_test
alter table test1 change name R_NAME varchar(50)
select * from view_test
alter table test1 drop R_NAME
select * from view_test
drop view view_test
#
#clear tables
#
drop table if exists test1
drop table if exists schema2.test2
drop table if exists schema3.test3