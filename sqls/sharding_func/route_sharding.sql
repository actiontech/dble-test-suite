#no use -- zhj
#ENUM
DROP TABLE IF EXISTS enum_patch_integer /* 1_2_3_4 */
CREATE TABLE enum_patch_integer(id int not null primary key,data varchar(10))/* 1_2_3_4 */
INSERT INTO enum_patch_integer (id,data) values (1,'aaa'),(2,'bbb'),(3,'ccc'),(0,'ddd')/* 1 */
INSERT INTO enum_patch_integer (id,data) values (1,'eee') on duplicate key UPDATE data = 'FFF' /* 1 */
INSERT INTO enum_patch_integer (id,data) values (4,'eee') on duplicate key UPDATE data = 'FFF'/* 1 */
#UPDATE enum_patch_integer set id = 1 /* 1 */
UPDATE enum_patch_integer set data = 'HHH' where id = 1/* 1 */
UPDATE enum_patch_integer set data = 'HHH' where id like 2/* 1_2_3_4 */
UPDATE enum_patch_integer set data = 'HHH' where id not like 2/* 1_2_3_4 */
UPDATE enum_patch_integer set data = 'AAA' where id in (1,2,3)/* 1 */
UPDATE enum_patch_integer set data = 'AAA' where id not in (1,2,3)/* 1_2_3_4 */
UPDATE enum_patch_integer set data = 'AAA' where id is not null/* 1_2_3_4 */
#UPDATE enum_patch_integer set data='BBB' where id between 1 and 3/* 1 */
UPDATE enum_patch_integer set data = 'BBB' where id = 4 or data = 'AAA'/* 1_2_3_4 */
UPDATE enum_patch_integer set data = 'BBB' where 1=1 or id = 0/* 1_2_3_4 */
UPDATE enum_patch_integer set data = 'BBB' where id is not null  or id = 0/* 1_2_3_4 */
DELETE FROM enum_patch_integer /* 1_2_3_4 */
INSERT INTO enum_patch_integer (id,data) values (1,'aaa'),(2,'bbb'),(3,'ccc'),(4,'ddd')/* 1 */
DELETE FROM enum_patch_integer where id = 1/* 1 */
DELETE FROM enum_patch_integer where id like 2/* 1_2_3_4 */
DELETE FROM enum_patch_integer where id not like 2/* 1_2_3_4 */
INSERT INTO enum_patch_integer (id,data) values (1,'aaa'),(2,'bbb'),(3,'ccc'),(4,'ddd')/* 1 */
DELETE FROM enum_patch_integer where id in (1,2)/* 1 */
DELETE FROM enum_patch_integer where id not in (1,2)/* 1_2_3_4 */
INSERT INTO enum_patch_integer (id,data) values(1,'aaa'),(2,'bbb'),(3,'ccc'),(4,'ddd')/* 1 */
DELETE FROM enum_patch_integer where id is not null/* 1_2_3_4 */
INSERT INTO enum_patch_integer (id,data) values(1,'aaa'),(2,'bbb'),(3,'ccc'),(4,'ddd')/* 1 */
#DELETE FROM enum_patch_integer where id between 1 and 2/* 1 */
DELETE FROM enum_patch_integer where id =1 or data='ccc'/* 1_2_3_4 */
DELETE FROM enum_patch_integer where data = 'ddd'/* 1_2_3_4 */
DROP TABLE enum_patch_integer/* 1_2_3_4 */
CREATE TABLE enum_patch_integer(id int,data varchar(10))/* 1_2_3_4 */
ALTER TABLE enum_patch_integer add data1 varchar(10)/* 1_2_3_4 */
ALTER TABLE enum_patch_integer DROP column data1/* 1_2_3_4 */
ALTER TABLE enum_patch_integer change column data data1 varchar(10)/* 1_2_3_4 */
ALTER TABLE enum_patch_integer modify column data1 varchar(20) not null/* 1_2_3_4 */
DROP TABLE enum_patch_integer/* 1_2_3_4 */
CREATE TABLE enum_patch_integer(id int,data varchar(10))/* 1_2_3_4 */
INSERT INTO enum_patch_integer (id,data) values (1,'aaa'),(2,'bbb'),(3,'ccc'),(4,'ddd')/* 1 */
SELECT * from enum_patch_integer/* 1_2_3_4 */
SELECT * from enum_patch_integer where id =1/* 1 */
SELECT * from enum_patch_integer where id like 1/* 1_2_3_4 */
SELECT * from enum_patch_integer where id =1 or 1=1/* 1_2_3_4 */
SELECT * from enum_patch_integer where id in (1,2,3)/* 1 */
SELECT * from enum_patch_integer where id not in (1,2,3)/* 1_2_3_4 */
SELECT * from enum_patch_integer where id not like 1/* 1_2_3_4 */
SELECT * from enum_patch_integer where id is not null/* 1_2_3_4 */
#SELECT * from enum_patch_integer where id between 1 and 3/* 1 */
SELECT * from enum_patch_integer where id >1/* 1_2_3_4 */
SELECT * from enum_patch_integer where id <3/* 1_2_3_4 */
SELECT * from enum_patch_integer where data = 'aaa'/* 1_2_3_4 */
DROP TABLE IF EXISTS enum_patch_integer /* 1_2_3_4 */
DROP TABLE IF EXISTS enum_patch_string /*1_2_3_4 */
CREATE TABLE enum_patch_string(id varchar(10) not null primary key,data varchar(10)) /* 1_2_3_4 */
INSERT INTO enum_patch_string(id,data) values ('aaa','a'),('bbb','b'),('ccc','c'),('ddd','d') /* 1_2_3_4 */
INSERT INTO enum_patch_string(id,data) values ('eee','e') on duplicate key UPDATE data = 'E' /* 1 */
INSERT INTO enum_patch_string(id,data) values ('eee','e') on duplicate key UPDATE data = 'E' /* 1 */
#UPDATE enum_patch_string set id = 'ddd'  /* 1_2_3_4 */
UPDATE enum_patch_string set data='A' where id = 'aaa' /* 1 */
UPDATE enum_patch_string set data = 'B' where id like 'bbb' /* 1_2_3_4 */
UPDATE enum_patch_string set data = 'B' where id not like 'bbb' /* 1_2_3_4 */
UPDATE enum_patch_string set data = 'C' where id in ('aaa','bbb','ccc') /* 1_2_3 */
UPDATE enum_patch_string set data = 'C' where id not in ('aaa','bbb','ccc') /* 1_2_3_4 */
UPDATE enum_patch_string set data = 'D' where id is not null /* 1_2_3_4 */
#UPDATE enum_patch_string set data=4 where id between 'aaa' and 'bbb' /* 1_2 */
UPDATE enum_patch_string set data ='E' where id = 'aaa' or data = 'D' /* 1_2_3_4 */
UPDATE enum_patch_string set data = 'F' where 1=1 or id = 'aaa' /* 1_2_3_4 */
UPDATE enum_patch_string set data = 'F' where id is not null  or id = 0 /* 1_2_3_4 */
DELETE FROM enum_patch_string  /* 1_2_3_4 */
INSERT INTO enum_patch_string(id,data) values ('aaa','a'),('bbb','b'),('ccc','c'),('ddd','d') /* 1_2_3_4 */
DELETE FROM enum_patch_string where id = 'aaa' /* 1 */
DELETE FROM enum_patch_string where id like 'aaa' /* 1_2_3_4 */
DELETE FROM enum_patch_string where id not like 'aaa' /* 1_2_3_4 */
INSERT INTO enum_patch_string (id,data) values ('aaa','a'),('bbb','b'),('ccc','c'),('ddd','d') /* 1_2_3_4 */
DELETE FROM enum_patch_string where id in ('aaa','bbb') /* 1_2 */
DELETE FROM enum_patch_string where id not in ('aaa','bbb') /* 1_2_3_4 */
INSERT INTO enum_patch_string (id,data) values ('aaa','a'),('bbb','b'),('ccc','c'),('ddd','d') /* 1_2_3_4 */
DELETE FROM enum_patch_string where id is not null /* 1_2_3_4 */
INSERT INTO enum_patch_string (id,data) values ('aaa','a'),('bbb','b'),('ccc','c'),('ddd','d') /* 1_2_3_4 */
#DELETE FROM enum_patch_string where id between 'aaa' and 'ccc' /* 1_2_3 */
DELETE FROM enum_patch_string where id ='ccc' or data='c' /* 1_2_3_4 */
DELETE FROM enum_patch_string where data = 'ddd' /* 1_2_3_4 */
DROP TABLE enum_patch_string /* 1_2_3_4 */
CREATE TABLE enum_patch_string(id VARCHAR (10),data varchar(10)) /* 1_2_3_4 */
ALTER TABLE enum_patch_string add data1 varchar(10) /* 1_2_3_4 */
ALTER TABLE enum_patch_string drop column data1 /* 1_2_3_4 */
ALTER TABLE enum_patch_string change column data data1 varchar(10)/* 1_2_3_4 */
ALTER TABLE enum_patch_string modify column data1 varchar(20) not null /* 1_2_3_4 */
DROP TABLE enum_patch_string /* 1_2_3_4 */
CREATE TABLE enum_patch_string(id varchar(10),data varchar(10)) /* 1_2_3_4 */
INSERT INTO enum_patch_string(id,data) values ('aaa','a'),('bbb','b'),('ccc','c'),('ddd','d') /* 1_2_3_4 */
SELECT * from enum_patch_string /* 1_2_3_4 */
SELECT * from enum_patch_string where id ='aaa' /* 1 */
SELECT * from enum_patch_string where id like 'aaa' /* 1_2_3_4 */
SELECT * from enum_patch_string where id ='aaa' or 1=1 /* 1_2_3_4 */
SELECT * from enum_patch_string where id in ('aaa','bbb','ccc') /* 1_2_3 */
SELECT * from enum_patch_string where id not in ('aaa','bbb','ccc') /* 1_2_3_4 */
SELECT * from enum_patch_string where id not like 'aaa' /* 1_2_3_4 */
SELECT * from enum_patch_string where id is not null /* 1_2_3_4 */
#SELECT * from enum_patch_string where id between 'aaa' and 'bbb' /* 1_2 */
SELECT * from enum_patch_string where data = 'aaa' /* 1_2_3_4 */
DROP TABLE IF EXISTS enum_patch_string /*1_2_3_4 */
#RANGE
DROP TABLE IF EXISTS range_patch /*1_2_3_4 */
CREATE TABLE range_patch(id int not null primary key,data varchar(10)) /* 1_2_3_4 */
INSERT INTO range_patch (id,data) values (1,'aaa'),(256,'bbb'),(512,'ccc'),(768,'ddd') /* 1_2_3_4 */
INSERT INTO range_patch (id,data) values (2,'eee') on duplicate key UPDATE data = 'FFF' /* 1 */
INSERT INTO range_patch (id,data) values (2,'eee') on duplicate key UPDATE data = 'FFF' /* 1 */
#UPDATE range_patch set id = 1  /* 1 */
UPDATE range_patch set data = 'HHH' where id = 1 /* 1 */
UPDATE range_patch set data = 'HHH' where id like 256 /* 1_2_3_4 */
UPDATE range_patch set data = 'HHH' where id not like 256 /* 1_2_3_4 */
UPDATE range_patch set data = 'AAA' where id in (1,256,512) /* 1_2_3 */
UPDATE range_patch set data = 'AAA' where id not in (1,256,512) /* 1_2_3_4 */
UPDATE range_patch set data = 'AAA' where id is not null /* 1_2_3_4 */
UPDATE range_patch set data='BBB' where id between 1 and 512 /* 1_2_3 */
UPDATE range_patch set data = 'BBB' where id = 768 or data = 'AAA' /* 1_2_3_4 */
UPDATE range_patch set data = 'BBB' where 1=1 or id = 0 /* 1_2_3_4 */
UPDATE range_patch set data = 'BBB' where id is not null  or id = 0 /* 1_2_3_4 */
DELETE FROM range_patch  /* 1_2_3_4 */
INSERT INTO range_patch (id,data) values (1,'aaa'),(256,'bbb'),(512,'ccc'),(768,'ddd') /* 1_2_3_4 */
DELETE FROM range_patch where id = 1 /* 1 */
DELETE FROM range_patch where id like 256 /* 1_2_3_4 */
DELETE FROM range_patch where id not like 256 /* 1_2_3_4 */
INSERT INTO range_patch (id,data) values (1,'aaa'),(256,'bbb'),(512,'ccc'),(768,'ddd') /* 1_2_3_4 */
DELETE FROM range_patch where id in (1,256) /* 1_2 */
DELETE FROM range_patch where id not in (1,256) /* 1_2_3_4 */
INSERT INTO range_patch (id,data) values (1,'aaa'),(256,'bbb'),(512,'ccc'),(768,'ddd') /* 1_2_3_4 */
DELETE FROM range_patch where id is not null /* 1_2_3_4 */
INSERT INTO range_patch (id,data) values (1,'aaa'),(256,'bbb'),(512,'ccc'),(768,'ddd') /* 1_2_3_4 */
DELETE FROM range_patch where id between 1 and 256 /* 1_2 */
DELETE FROM range_patch where id =1 or data='ccc' /* 1_2_3_4 */
DELETE FROM range_patch where data = 'ddd' /* 1_2_3_4 */
DROP TABLE range_patch /* 1_2_3_4 */
CREATE TABLE range_patch(id int,data varchar(10)) /* 1_2_3_4 */
ALTER TABLE range_patch add data1 varchar(10) /* 1_2_3_4 */
ALTER TABLE range_patch drop column data1 /* 1_2_3_4 */
ALTER TABLE range_patch change column data data1 varchar(10) /* 1_2_3_4 */
ALTER TABLE range_patch modify column data1 varchar(20) not null /* 1_2_3_4 */
DROP TABLE range_patch /* 1_2_3_4 */
CREATE TABLE range_patch(id int,data varchar(10)) /* 1_2_3_4 */
INSERT INTO range_patch (id,data) values (1,'aaa'),(256,'bbb'),(512,'ccc'),(768,'ddd') /* 1_2_3_4 */
SELECT * from range_patch /* 1_2_3_4 */
SELECT * from range_patch where id =1 /* 1 */
SELECT * from range_patch where id like 1 /* 1_2_3_4 */
SELECT * from range_patch where id =1 or 1=1 /* 1_2_3_4 */
SELECT * from range_patch where id in (1,256,512) /* 1_2_3 */
SELECT * from range_patch where id not in (1,256,512) /* 1_2_3_4 */
SELECT * from range_patch where id not like 1 /* 1_2_3_4 */
SELECT * from range_patch where id is not null /* 1_2_3_4 */
SELECT * from range_patch where id between 1 and 512 /* 1_2_3 */
SELECT * from range_patch where id >1 /* 1_2_3_4 */
SELECT * from range_patch where id <512 /* 1_2_3_4 */
SELECT * from range_patch where data = 'aaa' /* 1_2_3_4 */
DROP TABLE IF EXISTS range_patch /*1_2_3_4 */
#DATE
DROP TABLE IF EXISTS date_patch /*1_2_3_4 */
CREATE TABLE date_patch(id date not null primary key,data varchar(10)) /* 1_2_3_4 */
INSERT INTO date_patch(id,data) values ('2016-12-1','aaa'),('2016-12-11','bbb'),('2016-12-21','ccc'),('2017-1-1','ddd') /* 1_2_3_4 */
INSERT INTO date_patch (id,data) values ('2016-12-1','eee') on duplicate key UPDATE data = 'FFF' /* 1 */
INSERT INTO date_patch (id,data) values ('2016-12-1','eee') on duplicate key UPDATE data = 'FFF' /* 1 */
#UPDATE date_patch set id = 1  /* 1 */
UPDATE date_patch set data = 'HHH' where id = '2016-12-1' /* 1 */
UPDATE date_patch set data = 'HHH' where id like '2016-12-11' /* 1_2_3_4 */
UPDATE date_patch set data = 'HHH' where id not like '2016-12-11' /* 1_2_3_4 */
UPDATE date_patch set data = 'AAA' where id in ('2016-12-1','2016-12-11','2016-12-21') /* 1_2_3 */
UPDATE date_patch set data = 'AAA' where id not in ('2016-12-1','2016-12-11','2016-12-21') /* 1_2_3_4 */
UPDATE date_patch set data = 'AAA' where id is not null /* 1_2_3_4 */
UPDATE date_patch set data='BBB' where id between '2016-12-1' and '2016-12-21' /* 1_2_3 */
UPDATE date_patch set data = 'BBB' where id = '2017-1-1' or data = 'AAA' /* 1_2_3_4 */
UPDATE date_patch set data = 'BBB' where 1=1 or id = '2016-12-1' /* 1_2_3_4 */
UPDATE date_patch set data = 'BBB' where id is not null  or id = '2016-12-1' /* 1_2_3_4 */
DELETE FROM date_patch  /* 1_2_3_4 */
INSERT INTO date_patch(id,data) values ('2016-12-1','aaa'),('2016-12-11','bbb'),('2016-12-21','ccc'),('2017-1-1','ddd') /* 1_2_3_4 */
DELETE FROM date_patch where id = '2016-12-1' /* 1 */
DELETE FROM date_patch where id like '2016-12-11' /* 1_2_3_4 */
DELETE FROM date_patch where id not like '2016-12-11' /* 1_2_3_4 */
INSERT INTO date_patch(id,data) values ('2016-12-1','aaa'),('2016-12-11','bbb'),('2016-12-21','ccc'),('2017-1-1','ddd') /* 1_2_3_4 */
DELETE FROM date_patch where id in ('2016-12-1','2016-12-11') /* 1_2 */
DELETE FROM date_patch where id not in ('2016-12-1','2016-12-11') /* 1_2_3_4 */
INSERT INTO date_patch(id,data) values ('2016-12-1','aaa'),('2016-12-11','bbb'),('2016-12-21','ccc'),('2017-1-1','ddd') /* 1_2_3_4 */
DELETE FROM date_patch where id is not null /* 1_2_3_4 */
INSERT INTO date_patch(id,data) values ('2016-12-1','aaa'),('2016-12-11','bbb'),('2016-12-21','ccc'),('2017-1-1','ddd') /* 1_2_3_4 */
DELETE FROM date_patch where id between '2016-12-1' and '2016-12-11' /* 1_2 */
DELETE FROM date_patch where id ='2016-12-1' or data='ccc' /* 1_2_3_4 */
DELETE FROM date_patch where data = 'ddd' /* 1_2_3_4 */
DROP TABLE date_patch /* 1_2_3_4 */
CREATE TABLE date_patch(id date,data varchar(10)) /* 1_2_3_4 */
ALTER TABLE date_patch add data1 varchar(10) /* 1_2_3_4 */
ALTER TABLE date_patch drop column data1 /* 1_2_3_4 */
ALTER TABLE date_patch change column data data1 varchar(10) /* 1_2_3_4 */
ALTER TABLE date_patch modify column data1 varchar(20) not null /* 1_2_3_4 */
DROP TABLE date_patch /* 1_2_3_4 */
CREATE TABLE date_patch(id date,data varchar(10)) /* 1_2_3_4 */
INSERT INTO date_patch(id,data) values ('2016-12-1','aaa'),('2016-12-11','bbb'),('2016-12-21','ccc'),('2017-1-1','ddd') /* 1_2_3_4 */
SELECT * from date_patch /* 1_2_3_4 */
SELECT * from date_patch where id ='2016-12-1' /* 1 */
SELECT * from date_patch where id like '2016-12-1' /* 1_2_3_4 */
SELECT * from date_patch where id ='2016-12-1' or 1=1 /* 1_2_3_4 */
SELECT * from date_patch where id in ('2016-12-1','2016-12-11','2016-12-21') /* 1_2_3 */
SELECT * from date_patch where id not in ('2016-12-1','2016-12-11','2016-12-21') /* 1_2_3_4 */
SELECT * from date_patch where id not like '2016-12-1' /* 1_2_3_4 */
SELECT * from date_patch where id is not null /* 1_2_3_4 */
SELECT * from date_patch where id between '2016-12-1' and '2016-12-21' /* 1_2_3 */
SELECT * from date_patch where id >'2016-12-1' /* 1_2_3_4 */
SELECT * from date_patch where id <'2016-12-21' /* 1_2_3_4 */
SELECT * from date_patch where data = 'aaa' /* 1_2_3_4 */
DROP TABLE IF EXISTS date_patch /*1_2_3_4 */
#HASH
DROP TABLE IF EXISTS aly_test /*1_2_3_4 */
CREATE TABLE aly_test(id int not null ,data varchar(10)) /* 1_2_3_4 */
INSERT INTO aly_test (id,data) values (1,'aaa'),(2,'bbb'),(3,'ccc'),(0,'ddd') /* 1_2_3_4 */
INSERT INTO aly_test (id,data) values (0,'eee') on duplicate key UPDATE data = 'FFF' /* 1 */
INSERT INTO aly_test (id,data) values (4,'eee') on duplicate key UPDATE data = 'FFF' /* 1 */
#UPDATE aly_test set id = 1  /* 1 */
UPDATE aly_test set data = 'HHH' where id = 0 /* 1 */
UPDATE aly_test set data = 'HHH' where id like 2 /* 1_2_3_4 */
UPDATE aly_test set data = 'HHH' where id not like 2 /* 1_2_3_4 */
UPDATE aly_test set data = 'AAA' where id in (0,1,2) /* 1_2_3 */
UPDATE aly_test set data = 'AAA' where id not in (1,2,3) /* 1_2_3_4 */
UPDATE aly_test set data = 'AAA' where id is not null /* 1_2_3_4 */
UPDATE aly_test set data='BBB' where id between 0 and 2 /* 1_2_3 */
UPDATE aly_test set data = 'BBB' where id = 4 or data = 'AAA' /* 1_2_3_4 */
UPDATE aly_test set data = 'BBB' where 1=1 or id = 0 /* 1_2_3_4 */
UPDATE aly_test set data = 'BBB' where id is not null  or id = 0 /* 1_2_3_4 */
DELETE FROM aly_test  /* 1_2_3_4 */
INSERT INTO aly_test (id,data) values (1,'aaa'),(2,'bbb'),(3,'ccc'),(4,'ddd') /* 1_2_3_4 */
DELETE FROM aly_test where id = 0 /* 1 */
DELETE FROM aly_test where id like 2 /* 1_2_3_4 */
DELETE FROM aly_test where id not like 2 /* 1_2_3_4 */
INSERT INTO aly_test (id,data) values (1,'aaa'),(2,'bbb'),(3,'ccc'),(4,'ddd') /* 1_2_3_4 */
DELETE FROM aly_test where id in (0,1) /* 1_2 */
DELETE FROM aly_test where id not in (1,2) /* 1_2_3_4 */
INSERT INTO aly_test (id,data) values(1,'aaa'),(2,'bbb'),(3,'ccc'),(4,'ddd') /* 1_2_3_4 */
DELETE FROM aly_test where id is not null /* 1_2_3_4 */
INSERT INTO aly_test (id,data) values(1,'aaa'),(2,'bbb'),(3,'ccc'),(4,'ddd') /* 1_2_3_4 */
DELETE FROM aly_test where id between 0 and 2 /* 1_2_3 */
DELETE FROM aly_test where id =1 or data='ccc' /* 1_2_3_4 */
DELETE FROM aly_test where data = 'ddd' /* 1_2_3_4 */
DROP TABLE aly_test /* 1_2_3_4 */
CREATE TABLE aly_test(id int,data varchar(10)) /* 1_2_3_4 */
ALTER TABLE aly_test add data1 varchar(10) /* 1_2_3_4 */
ALTER TABLE aly_test drop column data1 /* 1_2_3_4 */
ALTER TABLE aly_test change column data data1 varchar(10) /* 1_2_3_4 */
ALTER TABLE aly_test modify column data1 varchar(20) not null /* 1_2_3_4 */
DROP TABLE aly_test /* 1_2_3_4 */
CREATE TABLE aly_test(id int,data varchar(10)) /* 1_2_3_4 */
INSERT INTO aly_test (id,data) values (1,'aaa'),(2,'bbb'),(3,'ccc'),(4,'ddd') /* 1_2_3_4 */
SELECT * from aly_test /* 1_2_3_4 */
SELECT * from aly_test where id =0 /* 1 */
SELECT * from aly_test where id like 1 /* 1_2_3_4 */
SELECT * from aly_test where id =1 or 1=1 /* 1_2_3_4 */
SELECT * from aly_test where id in (0,1,2) /* 1_2_3 */
SELECT * from aly_test where id not in (1,2,3) /* 1_2_3_4 */
SELECT * from aly_test where id not like 1 /* 1_2_3_4 */
SELECT * from aly_test where id is not null /* 1_2_3_4 */
SELECT * from aly_test where id between 0 and 2 /* 1_2_3 */
SELECT * from aly_test where id >1 /* 1_2_3_4 */
SELECT * from aly_test where id <3 /* 1_2_3_4 */
SELECT * from aly_test where data = 'aaa' /* 1_2_3_4 */
DROP TABLE IF EXISTS aly_test /*1_2_3_4 */
DROP TABLE IF EXISTS fixed_patch_uniform_string /*1_2_3_4 */
CREATE TABLE fixed_patch_uniform_string(id varchar(10) not null primary key,data varchar(10)) /* 1_2_3_4 */
INSERT INTO fixed_patch_uniform_string (id,data) values ('aa','aaa'),('jj','bbb'),('rr','ccc'),('zz','ddd') /* 1_2_3_4 */
INSERT INTO fixed_patch_uniform_string (id,data) values ('aa','eee') on duplicate key UPDATE data = 'FFF' /* 1 */
INSERT INTO fixed_patch_uniform_string (id,data) values ('aa','eee') on duplicate key UPDATE data = 'FFF' /* 1 */
#UPDATE fixed_patch_uniform_string set id = 1  /* 1 */
UPDATE fixed_patch_uniform_string set data = 'HHH' where id = 'aa' /* 1 */
UPDATE fixed_patch_uniform_string set data = 'HHH' where id like 'jj' /* 1_2_3_4 */
UPDATE fixed_patch_uniform_string set data = 'HHH' where id not like 'jj' /* 1_2_3_4 */
UPDATE fixed_patch_uniform_string set data = 'AAA' where id in ('aa','jj','rr') /* 1_2_3 */
UPDATE fixed_patch_uniform_string set data = 'AAA' where id not in  ('aa','jj','rr') /* 1_2_3_4 */
UPDATE fixed_patch_uniform_string set data = 'AAA' where id is not null /* 1_2_3_4 */
#UPDATE fixed_patch_uniform_string set data='BBB' where id between 'aa' and 'rr' /* 1_2_3 */
UPDATE fixed_patch_uniform_string set data = 'BBB' where id = 'zz' or data = 'AAA' /* 1_2_3_4 */
UPDATE fixed_patch_uniform_string set data = 'BBB' where 1=1 or id = 0 /* 1_2_3_4 */
UPDATE fixed_patch_uniform_string set data = 'BBB' where id is not null  or id = 'aa' /* 1_2_3_4 */
DELETE FROM fixed_patch_uniform_string  /* 1_2_3_4 */
INSERT INTO fixed_patch_uniform_string (id,data) values ('aa','aaa'),('jj','bbb'),('rr','ccc'),('zz','ddd') /* 1_2_3_4 */
DELETE FROM fixed_patch_uniform_string where id = 'aa' /* 1 */
DELETE FROM fixed_patch_uniform_string where id like 'jj' /* 1_2_3_4 */
DELETE FROM fixed_patch_uniform_string where id not like 'jj' /* 1_2_3_4 */
INSERT INTO fixed_patch_uniform_string (id,data) values ('aa','aaa'),('jj','bbb'),('rr','ccc'),('zz','ddd') /* 1_2_3_4 */
DELETE FROM fixed_patch_uniform_string where id in ('aa','jj') /* 1_2 */
DELETE FROM fixed_patch_uniform_string where id not in ('aa','jj') /* 1_2_3_4 */
INSERT INTO fixed_patch_uniform_string (id,data) values ('aa','aaa'),('jj','bbb'),('rr','ccc'),('zz','ddd') /* 1_2_3_4 */
DELETE FROM fixed_patch_uniform_string where id is not null /* 1_2_3_4 */
INSERT INTO fixed_patch_uniform_string (id,data) values ('aa','aaa'),('jj','bbb'),('rr','ccc'),('zz','ddd') /* 1_2_3_4 */
#DELETE FROM fixed_patch_uniform_string where id between 'aa' and 'jj' /* 1_2 */
DELETE FROM fixed_patch_uniform_string where id ='aa' or data='ccc' /* 1_2_3_4 */
DELETE FROM fixed_patch_uniform_string where data = 'ddd' /* 1_2_3_4 */
DROP TABLE fixed_patch_uniform_string /* 1_2_3_4 */
CREATE TABLE fixed_patch_uniform_string(id int,data varchar(10)) /* 1_2_3_4 */
ALTER TABLE fixed_patch_uniform_string add data1 varchar(10) /* 1_2_3_4 */
ALTER TABLE fixed_patch_uniform_string drop column data1 /* 1_2_3_4 */
ALTER TABLE fixed_patch_uniform_string change column data data1 varchar(10) /* 1_2_3_4 */
ALTER TABLE fixed_patch_uniform_string modify column data1 varchar(20) not null /* 1_2_3_4 */
DROP TABLE fixed_patch_uniform_string /* 1_2_3_4 */
CREATE TABLE fixed_patch_uniform_string(id varchar(10),data varchar(10)) /* 1_2_3_4 */
INSERT INTO fixed_patch_uniform_string (id,data) values ('aa','aaa'),('jj','bbb'),('rr','ccc'),('zz','ddd') /* 1_2_3_4 */
SELECT * from fixed_patch_uniform_string /* 1_2_3_4 */
SELECT * from fixed_patch_uniform_string where id ='aa' /* 1 */
SELECT * from fixed_patch_uniform_string where id like 'aa' /* 1_2_3_4 */
SELECT * from fixed_patch_uniform_string where id ='aa' or 1=1 /* 1_2_3_4 */
SELECT * from fixed_patch_uniform_string where id in ('aa','jj','rr') /* 1_2_3 */
SELECT * from fixed_patch_uniform_string where id not in ('aa','jj','rr') /* 1_2_3_4 */
SELECT * from fixed_patch_uniform_string where id not like 'aa' /* 1_2_3_4 */
SELECT * from fixed_patch_uniform_string where id is not null /* 1_2_3_4 */
#SELECT * from fixed_patch_uniform_string where id between 'aa' and 'rr' /* 1_2_3 */
SELECT * from fixed_patch_uniform_string where id >'aa' /* 1_2_3_4 */
SELECT * from fixed_patch_uniform_string where id <'rr' /* 1_2_3_4 */
SELECT * from fixed_patch_uniform_string where data = 'aaa' /* 1_2_3_4 */
DROP TABLE IF EXISTS fixed_patch_uniform_string /*1_2_3_4 */
