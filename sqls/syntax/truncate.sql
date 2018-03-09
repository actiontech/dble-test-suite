drop table if exists aly_order
drop table if exists aly_test
create table aly_order (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
create table aly_test (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
insert into aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
insert into aly_order (id,R_REGIONKEY,R_NAME,R_COMMENT) values(0,1,'test','test')
select * from aly_order
truncate aly_order
insert into aly_order (id,R_REGIONKEY,R_NAME,R_COMMENT) values(1,100,'test',null)
select * from aly_order
truncate aly_order
insert into aly_order (id,R_REGIONKEY,R_NAME,R_COMMENT) values(1,2,'yang','xi''an')
select * from aly_order where R_COMMENT='xi''an'
truncate aly_order
insert LOW_PRIORITY into aly_order(id,R_REGIONKEY,R_NAME,R_COMMENT) value(1,4,'test','test'),(2,5,'test','test')
select * from aly_order
truncate aly_order
insert HIGH_PRIORITY aly_order(id,R_REGIONKEY,R_NAME,R_COMMENT) values(1,8,'test','test'),(2,10,'test','test')
select * from aly_order
truncate aly_order
insert IGNORE aly_order(id,R_REGIONKEY,R_NAME,R_COMMENT) values(1,5,'test','test'),(2,6,'test','test')
select * from aly_order
insert IGNORE aly_order(id,R_REGIONKEY,R_NAME,R_COMMENT) values(1,7,'test','test'),(2,8,'test','test')
select * from aly_order
truncate aly_order
insert aly_order(id,R_REGIONKEY,R_NAME,R_COMMENT) values(6,12,'test','test'),(7,13,'test','test') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*2,R_NAME='chen'
select * from aly_order
truncate aly_order
insert IGNORE aly_order(id,R_REGIONKEY,R_NAME,R_COMMENT) values(13,26,'test','test'),(15,30,'test','test') ON DUPLICATE KEY UPDATE R_REGIONKEY=(select max(R_REGIONKEY) from aly_test)
select * from aly_order
truncate aly_order
insert IGNORE aly_order(id,R_REGIONKEY,R_NAME,R_COMMENT) values(1,(select min(R_REGIONKEY) from aly_test) ,'test','test'),(2,14,'test','test') ON DUPLICATE KEY UPDATE R_REGIONKEY=(select max(R_REGIONKEY) from aly_test)
select * from aly_order
truncate aly_order
insert aly_order(id,R_REGIONKEY,R_NAME,R_COMMENT) values(2,5,'test','test'),(3,6,'test','test') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY,R_NAME='chen'
select * from aly_order
truncate aly_order
insert HIGH_PRIORITY aly_order(id,R_REGIONKEY,R_NAME,R_COMMENT) values(5,7,'test','test'),(6,22,'test','test')
select * from aly_order
truncate aly_order
insert into aly_order values (100,999,'test','test')
select * from aly_order
truncate aly_order
drop table if exists aly_order
drop table if exists aly_test
