#Single-table Synate
#UPDATE [LOW_PRIORITY] [IGNORE] table_name SET col_name1={expr1} [,col_name2={expr2}] ...
#[LOW_PRIORITY],[IGNORE] Invalid
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT(11) PRIMARY KEY,R_REGIONKEY INT(11),R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT INTO aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
#UPDATE aly_test SET id = 3
#SELECT * FROM aly_test
UPDATE aly_test SET R_REGIONKEY=1,R_NAME='test1',R_COMMENT="test11"
SELECT * FROM aly_test
UPDATE aly_test SET R_REGIONKEY=R_REGIONKEY+10
SELECT id,R_REGIONKEY FROM aly_test
UPDATE LOW_PRIORITY aly_test SET R_REGIONKEY=R_REGIONKEY+10
SELECT id,R_REGIONKEY FROM aly_test
UPDATE IGNORE aly_test SET R_REGIONKEY=R_REGIONKEY+10
SELECT id,R_REGIONKEY FROM aly_test
SELECT * FROM aly_test
#
#UPDATE table_name SET col_name1={DEFAULT}[,col_name2={expr2}]...
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT(11) NOT NULL DEFAULT 1,R_REGIONKEY INT(11),R_NAME VARCHAR(50) DEFAULT 'test',R_COMMENT VARCHAR(50))
INSERT INTO aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
#UPDATE aly_test SET id=DEFAULT
#SELECT * FROM aly_test
UPDATE aly_test SET R_NAME=DEFAULT,R_REGIONKEY=1
SELECT * FROM aly_test
#
#UPDATE table_name SET col_name1={DEFAULT}[,col_name2={expr2}]... [WHERE where_condition]
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT(11) NOT NULL DEFAULT 1,test INT,detail VARCHAR(20) DEFAULT 'test')
INSERT INTO aly_test (id,test,detail) VALUES (1,1,'mydetail'),(2,2,'mydetail'),(3,3,'mydetail'),(4,4,'mydetail'),(12,12,'mydetail')
UPDATE aly_test SET detail=DEFAULT WHERE test<10
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT(11),R_REGIONKEY INT(11) PRIMARY KEY,R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT INTO aly_test (id,R_REGIONKEY,R_NAME,R_COMMENT) VALUES (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
UPDATE aly_test SET R_REGIONKEY=10 WHERE R_REGIONKEY=4 OR R_REGIONKEY=1 AND R_REGIONKEY=3
SELECT * FROM aly_test
UPDATE aly_test SET R_NAME='aly' WHERE id>0
SELECT * FROM aly_test
UPDATE aly_test SET R_NAME='test' WHERE id=1
SELECT * FROM aly_test
UPDATE aly_test SET R_NAME='test1' WHERE id IN (1,2,3)
SELECT * FROM aly_test
UPDATE aly_test SET R_NAME='test1' WHERE id NOT IN (1,2,3)
SELECT * FROM aly_test
UPDATE aly_test SET R_NAME='test2' WHERE id BETWEEN 1 AND 3
SELECT * FROM aly_test
UPDATE aly_test SET R_REGIONKEY=200 WHERE R_NAME='test'
SELECT * FROM aly_test
UPDATE aly_test SET R_REGIONKEY=401 WHERE R_NAME LIKE '%aly%'
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
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
