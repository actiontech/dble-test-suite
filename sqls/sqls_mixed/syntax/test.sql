#UPDATE
update sharding_4_t1 set name = 'aa' where id =1
update sharding_4_t1 set id=id+10
update sharding_4_t1 set name=DEFAULT where id>13
select * from sharding_4_t1
update sharding_4_t1 set name='sharding_4_t1' where id in (13,14)
update sharding_4_t1 set name='test2' where id between 11 and 13
update sharding_4_t1 set id = 401 WHERE name LIKE '%t1%'
select * from sharding_4_t1


#!share_conn
select @@insert_id
drop table if exists mytest_global1
create table mytest_global1(id int not null primary key auto_increment)
set @@insert_id=10
insert into mytest_global1 (id) values (null)
select id from mytest_global1
set @@session.insert_id=11
insert into mytest_global1 (id) values (null)
select id from mytest_global1
set session insert_id=12
insert into mytest_global1 (id) values (null)
select id from mytest_global1
#
#clear tables
#


#
#[ORDER BY],[LIMIT] are Syntax supported,but Invalid
#UPDATE aly_test SET R_NAME ORDER BY id LIMIT 1
#GLOBAL&&NORMAL
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1 (id INT(11),R_REGIONKEY INT(11) PRIMARY KEY,R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
UPDATE global_table1 SET R_REGIONKEY=R_REGIONKEY+10
SELECT id FROM global_table1
DELETE FROM global_table1
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
UPDATE global_table1 SET id=id+1
SELECT id FROM global_table1
UPDATE global_table1 SET id=id-1
DELETE FROM global_table1
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
UPDATE LOW_PRIORITY global_table1 SET R_REGIONKEY=R_REGIONKEY+10
SELECT id FROM global_table1
DELETE FROM global_table1
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
UPDATE IGNORE global_table1 SET R_REGIONKEY=R_REGIONKEY+1
SELECT id FROM global_table1
DELETE FROM global_table1
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
UPDATE global_table1 SET R_REGIONKEY=10 WHERE R_REGIONKEY=4
SELECT id FROM global_table1
DELETE FROM global_table1
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
UPDATE global_table1 SET R_REGIONKEY=10 WHERE R_REGIONKEY=4 OR R_REGIONKEY=1 AND R_REGIONKEY=3
SELECT id FROM global_table1
DELETE FROM global_table1
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
UPDATE global_table1 SET id=10 WHERE id=4 OR id=1 AND id=3
SELECT id FROM global_table1
DELETE FROM global_table1
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
UPDATE global_table1 SET R_REGIONKEY=R_REGIONKEY+10 WHERE R_REGIONKEY>2 order by R_NAME
SELECT id FROM global_table1
DELETE FROM global_table1
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
UPDATE global_table1 SET R_REGIONKEY=R_REGIONKEY+10 WHERE R_REGIONKEY>=2 order by R_NAME LIMIT 1
SELECT id FROM global_table1
DELETE FROM global_table1
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DROP TABLE IF EXISTS global_table1

