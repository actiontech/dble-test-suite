#!default_db:schema1
#single-TABLE DELETE syntax
#
#DELETE [LOW_PRIORITY][QUICK][IGNORE] FROM tbl_name
#[LOW_PRIORITY],[QUICK] is best for MyISAM,MEMORY,MERGE
#[IGNORE] is ignore errors
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM test1
SELECT id, R_REGIONKEY, R_NAME, R_COMMENT FROM test1
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE LOW_PRIORITY FROM test1
SELECT id, R_REGIONKEY, R_NAME, R_COMMENT FROM test1
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE QUICK FROM test1
SELECT id, R_REGIONKEY, R_NAME, R_COMMENT FROM test1
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE IGNORE FROM test1
SELECT id, R_REGIONKEY, R_NAME, R_COMMENT FROM test1
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM test1 order by id limit 3
SELECT id, R_REGIONKEY, R_NAME, R_COMMENT FROM test1
#
#DELETE FROM tbl_name [WHERE where_condition]
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM test1 WHERE id = 1
DELETE FROM test1  WHERE id = 2 or id = 3
SELECT id, R_REGIONKEY, R_NAME, R_COMMENT FROM test1
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM test1 WHERE R_REGIONKEY = 1
DELETE FROM test1 WHERE R_NAME like 'S%'
SELECT id, R_REGIONKEY, R_NAME, R_COMMENT FROM test1
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM test1 WHERE id in (1,2,3)
SELECT id, R_REGIONKEY, R_NAME, R_COMMENT FROM test1
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM test1 WHERE id BETWEEN 1 AND 5
SELECT id, R_REGIONKEY, R_NAME, R_COMMENT FROM test1
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
DELETE FROM test1 WHERE R_COMMENT is not null
SELECT id, R_REGIONKEY, R_NAME, R_COMMENT FROM test1
DROP TABLE IF EXISTS test1
#
#deleting FROM multiple TABLEs ,order by AND limit is not supported
#"order by" AND "limit" are Syntax supported,but Invalid
#DELETE FROM test1 WHERE R_COMMENT is not null order by limit 3
#DELETE test1,aly_order FROM test1 inner join aly_order WHERE test1.id=aly_order.id
#

#
#clear tables
#
DROP TABLE IF EXISTS test1