#single-TABLE DELETE syntax
#
#DELETE [LOW_PRIORITY][QUICK][IGNORE] FROM tbl_name
#[LOW_PRIORITY],[QUICK] is best for MyISAM,MEMORY,MERGE
#[IGNORE] is ignore errors
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM aly_test
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE LOW_PRIORITY FROM aly_test
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE QUICK FROM aly_test
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE IGNORE FROM aly_test
SELECT * FROM aly_test
#
#DELETE FROM tbl_name [WHERE where_condition]
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM aly_test WHERE id = 1
DELETE FROM aly_test  WHERE id = 2 or id = 3
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM aly_test WHERE R_REGIONKEY = 1
DELETE FROM aly_test WHERE R_NAME like 'S%'
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM aly_test WHERE id in (1,2,3)
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM aly_test WHERE id BETWEEN 1 AND 5
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM aly_test WHERE R_COMMENT is not null
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
#
#deleting FROM multiple TABLEs ,order by AND limit is not supported
#"order by" AND "limit" are Syntax supported,but Invalid
#DELETE FROM aly_test order by id limit 3
#DELETE FROM aly_test WHERE R_COMMENT is not null order by limit 3
#DELETE aly_test,aly_order FROM aly_test inner join aly_order WHERE aly_test.id=aly_order.id
#
#NORMAL&&GLOBAL
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM global_table1
SELECT id FROM global_table1
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM global_table1 WHERE id = 1 OR id = 2
DELETE FROM global_table1 WHERE R_NAME IS NOT NULL
SELECT id FROM global_table1
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1 (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO global_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM global_table1 ORDER BY id ASC LIMIT 1
SELECT id FROM global_table1
DROP TABLE IF EXISTS global_table1
DROP TABLE IF EXISTS normal_table1
CREATE TABLE normal_table1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO normal_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM normal_table1
SELECT * FROM normal_table1
DROP TABLE IF EXISTS normal_table1
CREATE TABLE normal_table1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO normal_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM normal_table1 WHERE id = 1 OR id = 2
DELETE FROM normal_table1 WHERE R_NAME IS NOT NULL
SELECT * FROM normal_table1
DROP TABLE IF EXISTS normal_table1
CREATE TABLE normal_table1 (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO normal_table1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM normal_table1 ORDER BY id ASC LIMIT 1
SELECT * FROM normal_table1
#
#clear tables
#
DROP TABLE IF EXISTS normal_table1
DROP TABLE IF EXISTS aly_test