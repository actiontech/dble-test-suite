#!default_db:schema1
#######################shard tbale test################################
#REPLACE tbl_name VALUE(value_list,value_list1...)
drop table if exists test1
create table test1 (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
REPLACE test1 VALUE(1,1,'chen','gang')
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#REPLACE tbl_name VALUES (value_list,value_list1...),(value_list,value_list1...)
DELETE FROM test1
REPLACE test1 VALUES (4,4,'chen2','gang'),(5,3,'chen3','gang')
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#REPLACE tbl_name VALUE(default,value_list...)
DELETE FROM test1
REPLACE test1 VALUE(1,1,DEFAULT,'gang')
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#REPLACE tbl_name VALUE(expr,value_liat...)
DELETE FROM test1
REPLACE test1 VALUE(1,1+1,'chen','gang')
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#REPLACE into tbl_name (col_name,col_name1...) VALUES (value_list,value_list1...)
DELETE FROM test1
REPLACE into test1 (id,R_REGIONKEY,R_NAME ,R_COMMENT) VALUES (4,4,'chen2','gang')
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
REPLACE into test1 (id,R_REGIONKEY,R_NAME ,R_COMMENT) VALUES (4,4,'tyest','gang')
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#REPLACE tbl_name set col_name=VALUE,col_name1=value1...
drop table if exists test1
create table test1 (id int(11),R_REGIONKEY int(11) primary key default 10,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE test1 set id=1,R_REGIONKEY=1,R_NAME='chen'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#REPLACE into tbl_name set col_name=expr,col_name1=default...
DELETE FROM test1
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into test1 set id=1,R_REGIONKEY=1,R_NAME='chen'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
DELETE FROM test1
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into test1 set id=1,R_REGIONKEY=1+4,R_NAME='chen'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
DELETE FROM test1
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into test1 set id=1,R_NAME=default
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
drop table if exists test1
create table test1 (id int(11),R_REGIONKEY int(11) primary key default 10,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into test1 set id=1,R_REGIONKEY=default(R_REGIONKEY)+1
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
drop table if exists schema2.test2
create table schema2.test2 (id int(11),R_REGIONKEY int(11) primary key default 10,R_NAME varchar(50),R_COMMENT varchar(50))
replace schema2.test2 select * from test1 where id =1
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM schema2.test2
#
#clear tables
#
drop table if exists test1
drop table if exists schema2.test2