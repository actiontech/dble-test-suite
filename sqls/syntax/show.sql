 drop table if exists aly_test
 drop table if exists aly_order
 create table aly_order (ID int(11),O_ORDERKEY varchar(20) primary key,O_CUSTKEY varchar(20),O_TOTALPRICE int(20),MYDATE date)
 create table aly_test (ID int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
 insert into aly_order (ID,O_ORDERKEY,O_CUSTKEY,O_TOTALPRICE,MYDATE) values (1,'ORDERKEY_001','CUSTKEY_003',200000,'20141022'),(2,'ORDERKEY_002','CUSTKEY_003',100000,'19920501'),(4,'ORDERKEY_004','CUSTKEY_111',500,'20080105'),(5,'ORDERKEY_005','CUSTKEY_132',100,'19920628'),(10,'ORDERKEY_010','CUSTKEY_333',88888888,'19920720'),(11,'ORDERKEY_011','CUSTKEY_012',323456,'19920822'),(7,'ORDERKEY_007','CUSTKEY_980',12000,'19920910'),(6,'ORDERKEY_006','CUSTKEY_420',231,'19921111')
 insert into aly_test (ID,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1,'Eastern','test001'),(3,3,'Northern','test003'),(2,2,'Western','test002'),(4,4,'Southern','test004')
# show columns from aly_order
# show columns in aly_order
# show columns from aly_order from mytest
# show columns in aly_order from mytest
 show full columns from aly_order from mytest
 show full columns from aly_order from mytest like 'o%'
 show full columns from aly_order from mytest where field like 'o%'
 show table status/*allow_diff*/
 show table status like 'aly_o%'/*allow_diff*/
 show tables
 show full tables
 show tables from mytest
 show tables in mytest
 show full tables from mytest
 show full tables in mytest
 show tables like 'aly_o%'
 show full tables from mytest like 'test%'
 show full tables in mytest where table_type like 'base%'
 create INDEX index_001 ON aly_test (ID)
 show index from aly_test
 show index in aly_test
 show index from aly_test from mytest
 show index in aly_test in mytest
 show index in aly_test from mytest
 show index from aly_test in mytest
 show keys from aly_test
 show keys in aly_test
 show keys from aly_test from mytest
 show keys from aly_test in mytest
 show keys in aly_test in mytest
 show keys in aly_test from mytest
 drop index index_001 on aly_test
 create database  if not exists mytest
 show create database mytest
 show create schema mytest
 show create schema if not exists mytest
 show create database if not exists mytest
 show databases
 show schemas
 show databases like 'mytest'
 show schemas like 'mytest'
 show open tables
 show open tables from mytest
 show open tables in mytest
 show open tables from mytest like 'aly_o%'
 drop table if exists aly_test
 drop table if exists aly_order
