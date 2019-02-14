#!default_db:schema1
drop table if exists test1
create table test1 (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values(0,1,'test','test')
select * from test1
truncate test1
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values(1,100,'test',null)
select * from test1
truncate test1
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values(1,2,'yang','xi''an')
select * from test1 where R_COMMENT='xi''an'
truncate test1
insert LOW_PRIORITY into test1(id,R_REGIONKEY,R_NAME,R_COMMENT) value(1,4,'test','test'),(2,5,'test','test')
select * from test1
truncate test1
insert HIGH_PRIORITY test1(id,R_REGIONKEY,R_NAME,R_COMMENT) values(1,8,'test','test'),(2,10,'test','test')
select * from test1
truncate test1
insert IGNORE test1(id,R_REGIONKEY,R_NAME,R_COMMENT) values(1,5,'test','test'),(2,6,'test','test')
select * from test1
insert IGNORE test1(id,R_REGIONKEY,R_NAME,R_COMMENT) values(1,7,'test','test'),(2,8,'test','test')
select * from test1
truncate test1
insert test1(id,R_REGIONKEY,R_NAME,R_COMMENT) values(6,12,'test','test'),(7,13,'test','test') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*2,R_NAME='chen'
select * from test1
truncate test1
insert test1(id,R_REGIONKEY,R_NAME,R_COMMENT) values(2,5,'test','test'),(3,6,'test','test') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY,R_NAME='chen'
select * from test1
truncate test1
insert HIGH_PRIORITY test1(id,R_REGIONKEY,R_NAME,R_COMMENT) values(5,7,'test','test'),(6,22,'test','test')
select * from test1
truncate test1
insert into test1 values (100,999,'test','test')
select * from test1
truncate test1
#
#clear tables
#
drop table if exists test1