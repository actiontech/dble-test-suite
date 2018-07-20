DROP TABLE IF EXISTS aly_test_1_1
DROP TABLE IF EXISTS aly_test_1_2
CREATE TABLE aly_test_1_1 (id INT NOT NULL PRIMARY KEY, data VARCHAR(50))
CREATE TABLE aly_test_1_2 (id INT NOT NULL PRIMARY KEY, data VARCHAR(50))

#INSERT
insert into aly_test_1_1 (id,data) values(1,'test1'),(2,'test2'),(3,'test3')
insert into aly_test_1_2 (id,data) values(1,'a')
insert into aly_test_1_2 set id = 2,data='b'
insert into aly_test_1_2 values (2,'b') ON DUPLICATE KEY UPDATE data='bb'
select * from aly_test_1_2

#REPLACE
replace into aly_test_1_2 values (3, 'c')
replace into aly_test_1_2 set id = 1+3, data='d'
replace into aly_test_1_2 set id=5,data=default
replace aly_test_1_2 select * from aly_test_1_1 where id =1
select * from aly_test_1_2

#SELECT
select * from aly_test_1_2 order by id limit 4
select id,data from aly_test_1_2 order by id limit 4
select distinct id from aly_test_1_2 limit 4
select * from aly_test_1_2 order by id limit 1,1
select * from aly_test_1_2 order by id limit 2,3
select id,data from aly_test_1_2 group by id,data order by id,data limit 2,3

#UPDATE
update aly_test_1_2 set data = 'aa' where id =1
update aly_test_1_2 set id=id+10
update aly_test_1_2 set data=DEFAULT where id>13
select * from aly_test_1_2
update aly_test_1_2 set data='test1' where id in (13,14)
update aly_test_1_2 set data='test2' where id between 11 and 13
update aly_test_1_2 set id = 401 WHERE data LIKE '%t1%'
select * from aly_test_1_2

#LOCK
lock tables aly_test_1_2 read
unlock tables

#clear tables
DROP TABLE IF EXISTS aly_test_1_1
drop table if exists aly_test_1_2


