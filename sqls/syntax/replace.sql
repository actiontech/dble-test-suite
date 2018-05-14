#######################shard tbale test################################
#REPLACE tbl_name VALUE(value_list,value_list1...)
drop table if exists aly_test
create table aly_test (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
REPLACE aly_test VALUE(1,1,'chen','gang')
SELECT * FROM aly_test
#REPLACE tbl_name VALUES (value_list,value_list1...),(value_list,value_list1...)
DELETE FROM aly_test
REPLACE aly_test VALUES (4,4,'chen2','gang'),(5,3,'chen3','gang')
SELECT * FROM aly_test
#REPLACE tbl_name VALUE(default,value_list...)
DELETE FROM aly_test
REPLACE aly_test VALUE(1,1,DEFAULT,'gang')
SELECT * FROM aly_test
#REPLACE tbl_name VALUE(expr,value_liat...)
DELETE FROM aly_test
REPLACE aly_test VALUE(1,1+1,'chen','gang')
SELECT * FROM aly_test
#REPLACE into tbl_name (col_name,col_name1...) VALUES (value_list,value_list1...)
DELETE FROM aly_test
REPLACE into aly_test (id,R_REGIONKEY,R_NAME ,R_COMMENT) VALUES (4,4,'chen2','gang')
SELECT * FROM aly_test
REPLACE into aly_test (id,R_REGIONKEY,R_NAME ,R_COMMENT) VALUES (4,4,'tyest','gang')
SELECT * FROM aly_test
#REPLACE tbl_name set col_name=VALUE,col_name1=value1...
drop table if exists aly_test
create table aly_test (id int(11) primary key,R_REGIONKEY int(11) default 10,R_NAME varchar(50),R_COMMENT varchar(50))
insert into aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE aly_test set id=1,R_REGIONKEY=1,R_NAME='chen'
SELECT * FROM aly_test
#REPLACE into tbl_name set col_name=expr,col_name1=default...
DELETE FROM aly_test
insert into aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into aly_test set id=1,R_REGIONKEY=1,R_NAME='chen'
SELECT * FROM aly_test
DELETE FROM aly_test
insert into aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into aly_test set id=1,R_REGIONKEY=1+4,R_NAME='chen'
SELECT * FROM aly_test
DELETE FROM aly_test
insert into aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into aly_test set id=1,R_NAME=default
SELECT * FROM aly_test
drop table if exists aly_test
create table aly_test (id int(11),R_REGIONKEY int(11) primary key default 10,R_NAME varchar(50),R_COMMENT varchar(50))
insert into aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into aly_test set id=1,R_REGIONKEY=default(R_REGIONKEY)+1
SELECT * FROM aly_test
#######################global tbale test################################
#REPLACE tbl_name VALUE(value_list,value_list1...)
drop table if exists global_table1
create table global_table1 (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
REPLACE global_table1 VALUE(1,1,'chen','gang')
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
#REPLACE tbl_name VALUES (value_list,value_list1...),(value_list,value_list1...)
DELETE FROM global_table1
REPLACE global_table1 VALUES (4,4,'chen2','gang'),(5,3,'chen3','gang')
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
#REPLACE tbl_name VALUE(default,value_list...)
DELETE FROM global_table1
REPLACE global_table1 VALUE(1,1,DEFAULT,'gang')
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
#REPLACE tbl_name VALUE(expr,value_liat...)
DELETE FROM global_table1
REPLACE global_table1 VALUE(1,1+1,'chen','gang')
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
#REPLACE into tbl_name (col_name,col_name1...) VALUES (value_list,value_list1...)
DELETE FROM global_table1
REPLACE into global_table1 (id,R_REGIONKEY,R_NAME ,R_COMMENT) VALUES (4,4,'chen2','gang')
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
REPLACE into global_table1 (id,R_REGIONKEY,R_NAME ,R_COMMENT) VALUES (4,4,'tyest','gang')
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
#REPLACE tbl_name set col_name=VALUE,col_name1=value1...
drop table if exists global_table1
create table global_table1 (id int(11),R_REGIONKEY int(11) primary key default 10,R_NAME varchar(50),R_COMMENT varchar(50))
insert into global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE global_table1 set id=1,R_REGIONKEY=1,R_NAME='chen'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
#REPLACE into tbl_name set col_name=expr,col_name1=default...
DELETE FROM global_table1
insert into global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into global_table1 set id=1,R_REGIONKEY=1,R_NAME='chen'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
DELETE FROM global_table1
insert into global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into global_table1 set id=1,R_REGIONKEY=1+4,R_NAME='chen'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
DELETE FROM global_table1
insert into global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into global_table1 set id=1,R_NAME=default
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
drop table if exists global_table1
create table global_table1 (id int(11),R_REGIONKEY int(11) primary key default 10,R_NAME varchar(50),R_COMMENT varchar(50))
insert into global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into global_table1 set id=1,R_REGIONKEY=default(R_REGIONKEY)+1
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
#######################no_shard tbale test################################
#REPLACE tbl_name VALUE(value_list,value_list1...)
drop table if exists test_no_shard
create table test_no_shard (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
REPLACE test_no_shard VALUE(1,1,'chen','gang')
SELECT * FROM test_no_shard
#REPLACE tbl_name VALUES (value_list,value_list1...),(value_list,value_list1...)
DELETE FROM test_no_shard
REPLACE test_no_shard VALUES (4,4,'chen2','gang'),(5,3,'chen3','gang')
SELECT * FROM test_no_shard
#REPLACE tbl_name VALUE(default,value_list...)
DELETE FROM test_no_shard
REPLACE test_no_shard VALUE(1,1,DEFAULT,'gang')
SELECT * FROM test_no_shard
#REPLACE tbl_name VALUE(expr,value_liat...)
DELETE FROM test_no_shard
REPLACE test_no_shard VALUE(1,1+1,'chen','gang')
SELECT * FROM test_no_shard
#REPLACE into tbl_name (col_name,col_name1...) VALUES (value_list,value_list1...)
DELETE FROM test_no_shard
REPLACE into test_no_shard (id,R_REGIONKEY,R_NAME ,R_COMMENT) VALUES (4,4,'chen2','gang')
SELECT * FROM test_no_shard
REPLACE into test_no_shard (id,R_REGIONKEY,R_NAME ,R_COMMENT) VALUES (4,4,'tyest','gang')
SELECT * FROM test_no_shard
#REPLACE tbl_name set col_name=VALUE,col_name1=value1...
drop table if exists test_no_shard
create table test_no_shard (id int(11),R_REGIONKEY int(11) primary key default 10,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test_no_shard (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE test_no_shard set id=1,R_REGIONKEY=1,R_NAME='chen'
SELECT * FROM test_no_shard
#REPLACE into tbl_name set col_name=expr,col_name1=default...
DELETE FROM test_no_shard
insert into test_no_shard (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into test_no_shard set id=1,R_REGIONKEY=1,R_NAME='chen'
SELECT * FROM test_no_shard
DELETE FROM test_no_shard
insert into test_no_shard (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into test_no_shard set id=1,R_REGIONKEY=1+4,R_NAME='chen'
SELECT * FROM test_no_shard
DELETE FROM test_no_shard
insert into test_no_shard (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into test_no_shard set id=1,R_NAME=default
SELECT * FROM test_no_shard
drop table if exists test_no_shard
create table test_no_shard (id int(11),R_REGIONKEY int(11) primary key default 10,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test_no_shard (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
REPLACE into test_no_shard set id=1,R_REGIONKEY=default(R_REGIONKEY)+1
SELECT * FROM test_no_shard
drop table if exists test_no_shard
drop table if exists test
create table test_no_shard (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
create table test (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
replace test_no_shard select * from test where id<4
select * from test_no_shard
replace test_no_shard set id=4,R_REGIONKEY=4
replace test_no_shard select * from test where id=4
select * from test_no_shard
drop table if exists test_no_shard
drop table if exists test
create table test_no_shard (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
create table test (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
replace test_no_shard select * from test where id<4
select * from test_no_shard
drop table if exists test_no_shard
drop table if exists test
create table test_no_shard (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
create table test (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test_no_shard (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'test','test'),(3,3, 'test','test'),(2,2, 'test','test'),(4,4, 'test','test')
insert into test (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
replace into test_no_shard(id,R_REGIONKEY,R_NAME) select id,R_REGIONKEY,R_COMMENT from test
select * from test_no_shard
#
#clear tables
#
drop table if exists test_no_shard
drop table if exists test
drop table if exists global_table1
drop table if exists aly_test