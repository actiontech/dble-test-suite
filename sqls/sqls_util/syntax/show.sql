#!default_db:schema1
 drop table if exists test1
 create table test1 (ID int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
 insert into test1 (ID,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1,'Eastern','test001'),(2,2,'Western','test002'),(3,3,'Northern','test003'),(4,4,'Southern','test004'),(3,3,'northern','test003'),(null,null,null,null)
 show columns in test1
 show columns from test1 from schema1
 show full columns from test1 from schema1
 show full columns from test1 from schema1 like 'n%'
 show full columns from test1 from schema1 where field like 's%'
 show table status/*allow_diff*/
 show table status like 'aly_o%'/*allow_diff*/
 show tables
 show full tables
 show tables from schema1
 show tables in schema1
 show full tables from schema1
 show full tables in schema1
 show tables like 'aly_o%'
 show full tables from schema1 like 'aly%'
 show full tables in schema1 where table_type like 'base%'
 create INDEX index_001 ON test1 (ID)
 show index from test1
 show index in test1
 show index from test1 from schema1
 show index in test1 in schema1
 show index in test1 from schema1
 show index from test1 in schema1
 show keys from test1
 show keys in test1
 show keys from test1 from schema1
 show keys from test1 in schema1
 show keys in test1 in schema1
 show keys in test1 from schema1
 drop index index_001 on test1
 create database  if not exists schema1
 show create database schema1
 show create schema schema1
 show create schema if not exists schema1
 show create database if not exists schema1
 show databases
 show schemas
 show databases like 'schema1'
 show schemas like 'schema1'
 show open tables
 show open tables from schema1
 show open tables in schema1
 show open tables from schema1 like 'aly_o%'
#
#clear tables
#
 drop table if exists test1