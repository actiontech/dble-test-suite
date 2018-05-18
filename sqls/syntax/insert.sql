#SHARDING TABLE
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT, data VARCHAR(50))
#
#INSERT [ LOW_PRIORITY | DELAYED | HIGH_PRIORITY ] [IGNORE]
#Syntax supported,but Invalid
##PRIMARY KEY must be sharding key,otherwise [IGNORE] maybe Invalid
INSERT LOW_PRIORITY INTO aly_test (id,data) value (6,'e')
INSERT DELAYED INTO aly_test (id,data) value (7,'f')
INSERT HIGH_PRIORITY INTO aly_test (id,data) value (8,'g')
INSERT IGNORE INTO aly_test (id,data) value (9,'h')
INSERT LOW_PRIORITY INTO aly_test SET id=1,data='a'
INSERT DELAYED INTO aly_test SET id=2,data='aa'
INSERT HIGH_PRIORITY INTO aly_test SET id=3,data='aaa'
INSERT IGNORE INTO aly_test SET id=4,data='aaaaa'
#
#INSERT [INTO] tbl_name (col_name,...) { VALUES| VALUE } ...
INSERT INTO aly_test (id,data) VALUE (1,'a')
INSERT INTO aly_test (id,data) VALUES (2,'b')
INSERT INTO aly_test (id,data) VALUES (3,'a'),(4,'b'),(5,'c')
INSERT aly_test (id,data) VALUES (6,'a'),(7,'b')
INSERT aly_test VALUES (8,'c'),(9,'d')
SELECT * FROM aly_test
#
#INSERT INTO tbl_name (col_name,...) { VALUES| VALUE } ({ expr|DEFAULT},...) ...
#Sharding key not supported use expr and DEFAULT
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT NOT NULL, data INT)
INSERT INTO aly_test (id,data) VALUES (1,id*id),(2,id*id)
#INSERT INTO aly_test (id,data) VALUES (data+data,2),(data+data,4)
INSERT INTO aly_test (id) VALUES (3),(4)
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT NOT NULL default 1, data VARCHAR(10) default 'test')
INSERT INTO aly_test (id,data) VALUES (1,'aaa'),(2,'bbb')
INSERT INTO aly_test (id) VALUES (3),(4)
#INSERT INTO aly_test (data) VALUES ('aaa')
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT NOT NULL PRIMARY KEY, data VARCHAR(10))
INSERT INTO aly_test (id,data) VALUES (1,'aaa'),(2,'bbb')
INSERT INTO aly_test VALUES (3,'aaa')
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT NOT NULL, data VARCHAR(10) default 'test')
INSERT INTO aly_test (id,data) VALUES (1,'aaa'),(2,'bbb')
INSERT INTO aly_test (id) VALUES (3),(4)
SELECT * FROM aly_test
#
#INSERT INTO tbl_name {VALUES|VALUE} (...)
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id INT,data VARCHAR(10))
INSERT INTO aly_test VALUE (1,'aaa'),(2,'bbb'),(3,'ccc'),(4,'dddd')
SELECT * FROM aly_test
INSERT INTO aly_test VALUES (5,'eee'),(6,'fff')
SELECT * FROM aly_test
ALTER TABLE aly_test add column name1 VARCHAR(20)
INSERT INTO aly_test VALUES (4,'ddd','aaa')
SELECT * FROM aly_test
DELETE FROM aly_test
ALTER TABLE aly_test DROP column name1
INSERT INTO aly_test VALUES (5,'fff')
SELECT * FROM aly_test
DELETE FROM aly_test
ALTER TABLE aly_test add PRIMARY KEY (id)
INSERT INTO aly_test VALUES (5,'fff')
SELECT * FROM aly_test
DELETE FROM aly_test
INSERT INTO aly_test VALUES (6,'ggg')
SELECT * FROM aly_test
#
#INSERT INTO tbl_name ... VALUES ... ON DUPLICATE KEY UPDATE ...
#After duplicate key update not supported use Sharding key
#PRIMARY KEY must be sharding key,otherwise "on duplicate key update" maybe Invalid
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT NOT NULL PRIMARY KEY,number INT, name VARCHAR(10))
INSERT INTO aly_test VALUES (1,1,'aaa'),(2,2,'bbb'),(3,3,'ccc')
INSERT INTO aly_test VALUES (5,5,'eee') ON DUPLICATE KEY UPDATE name='fff'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES (5,5,'eee') ON DUPLICATE KEY UPDATE name='fff'
SELECT * FROM aly_test
#INSERT INTO aly_test VALUES (5,'eee') ON DUPLICATE KEY UPDATE id=1
INSERT INTO aly_test VALUES (6,6,'aaa') ON DUPLICATE KEY UPDATE number=number*2,name='AAAA1'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES (6,7,'aaa') ON DUPLICATE KEY UPDATE number=number*2,name='AAAA2'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES (7,6,'aaa') ON DUPLICATE KEY UPDATE number=number*2,name='AAAA3'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES (6,6,'AAA') ON DUPLICATE KEY UPDATE number=number*2,name='AAAA4'
SELECT * FROM aly_test
#
#INSERT [INTO] tbl_name SET ...
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT(11) PRIMARY KEY,R_REGIONKEY INT(11),R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT aly_test SET id = 1,R_REGIONKEY=1,R_NAME='aaa',R_COMMENT='AAA'
INSERT INTO aly_test SET id = 2,R_REGIONKEY=2,R_NAME='bbb',R_COMMENT='BBB'
SELECT * FROM aly_test
#
#INSERT INTO tbl_name SET col_name={ expr | DEFAULT },...
#Sharding key not supported use expr and DEFAULT
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT(11) PRIMARY KEY,R_REGIONKEY INT(11),R_NAME VARCHAR(50) DEFAULT 'test',R_COMMENT VARCHAR(50))
INSERT aly_test SET id = 1,R_REGIONKEY=1,R_COMMENT='AAA'
SELECT * FROM aly_test
INSERT aly_test SET id = 2,R_REGIONKEY=2*3,R_NAME='bbb',R_COMMENT='BBB'
INSERT aly_test SET id = 3,R_REGIONKEY=3*3,R_COMMENT='BBB'
#INSERT aly_test SET id = 3*2,R_REGIONKEY=3*3,R_COMMENT='BBB'
#
#INSERT INTO tbl_name SET ... ON DUPLICATE KEY UPDATE ...
#After duplicate key update not supported use Sharding key
#PRIMARY KEY must be sharding key,otherwise "on duplicate key update" maybe Invalid
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id INT(11) PRIMARY KEY,R_REGIONKEY INT(11),R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT aly_test SET id = 1,R_REGIONKEY=1,R_NAME='aaa',R_COMMENT='AAA'
SELECT * FROM aly_test
INSERT INTO aly_test SET id=2,R_REGIONKEY=1*3,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*2,R_NAME='chen'
SELECT * FROM aly_test
INSERT INTO aly_test SET id=2,R_REGIONKEY=1*3,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*2,R_NAME='chen'
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
#
#GLOBAL&NORMAL TABLE
#surpported MYSQL INSERT Syntax
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1 (id INT, data VARCHAR(50))
INSERT INTO global_table1 (id,data) value (1,'a')
INSERT INTO global_table1 (id,data) VALUES (2,'b')
INSERT INTO global_table1 (id,data) VALUES (7,null)
INSERT INTO global_table1 (id,data) VALUES (3,'a'),(4,'b'),(5,'c')
INSERT INTO global_table1 (id,data) VALUES (10,concat(2,' test'))
INSERT INTO global_table1 (id,data) VALUES (abs(-1),concat(2,'text'))
INSERT LOW_PRIORITY INTO global_table1 (id,data) value (6,'e')
INSERT DELAYED INTO global_table1 (id,data) value (7,'f')
INSERT HIGH_PRIORITY INTO global_table1 (id,data) value (8,'g')
INSERT IGNORE INTO global_table1 (id,data) value (9,'h')
SELECT id,data FROM global_table1
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1 (id INT NOT NULL, name VARCHAR(10))
INSERT INTO global_table1 VALUES (1,'aaa')
INSERT INTO global_table1 VALUES (abs(-1),concat(2,'text'))
INSERT INTO global_table1 VALUES (2,'bbb'),(3,'ccc'),(4,'ddd')
INSERT INTO global_table1 VALUES (5,'eee') ON DUPLICATE KEY UPDATE name='fff'
INSERT INTO global_table1 VALUES (5,'eee') ON DUPLICATE KEY UPDATE id=6
SELECT id,name FROM global_table1
INSERT INTO global_table1 VALUES (6,'eee') ON DUPLICATE KEY UPDATE name='fff'
SELECT id,name FROM global_table1
DELETE FROM global_table1
ALTER TABLE global_table1 add column name1 VARCHAR(20)
INSERT INTO global_table1 VALUES (4,'ddd','aaa')
SELECT id,name FROM global_table1
DELETE FROM global_table1
ALTER TABLE global_table1 DROP column name1
INSERT INTO global_table1 VALUES (5,'fff')
SELECT id,name FROM global_table1
DELETE FROM global_table1
ALTER TABLE global_table1 add PRIMARY KEY (id)
INSERT INTO global_table1 VALUES (5,'fff')
SELECT id,name FROM global_table1
DELETE FROM global_table1
INSERT INTO global_table1 VALUES (6,'ggg')
SELECT id,name FROM global_table1
DROP TABLE global_table1
CREATE TABLE global_table1 (id INT(11),R_REGIONKEY INT(11) PRIMARY KEY,R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT LOW_PRIORITY global_table1 SET id=1,R_REGIONKEY=1,R_NAME='test',R_COMMENT='test'
INSERT DELAYED global_table1 SET id=1,R_REGIONKEY=2,R_NAME='test',R_COMMENT='test'
INSERT HIGH_PRIORITY global_table1 SET id=1,R_REGIONKEY=3,R_NAME='test',R_COMMENT='test'
INSERT IGNORE global_table1 SET id=1,R_REGIONKEY=4,R_NAME='test',R_COMMENT='test'
INSERT global_table1 SET id=1,R_REGIONKEY=5,R_NAME='test',R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1 (id INT(11),R_REGIONKEY INT(11) PRIMARY KEY,R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT INTO global_table1 SET id=2,R_REGIONKEY=1*3,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*2,R_NAME='chen'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 SET id=2,R_REGIONKEY=1*3,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*2,R_NAME='chen'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1 (id INT(11),R_REGIONKEY INT(11) PRIMARY KEY,R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT DELAYED INTO global_table1 SET id=4,R_REGIONKEY=1*4,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*5
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT IGNORE INTO global_table1 SET id=4,R_REGIONKEY=1*4,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*5
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1 (id INT(11),R_REGIONKEY INT(11) PRIMARY KEY,R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT INTO global_table1 SET id=2,R_REGIONKEY=2
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
DROP TABLE IF EXISTS global_table1
#
#NORMAL TABLE
DROP TABLE IF EXISTS normal_table1
CREATE TABLE normal_table1 (id INT, data VARCHAR(50))
INSERT INTO normal_table1 (id,data) value (1,'a')
INSERT INTO normal_table1 (id,data) VALUES (2,'b')
INSERT INTO normal_table1 (id,data) VALUES (7,null)
INSERT INTO normal_table1 (id,data) VALUES (3,'a'),(4,'b'),(5,'c')
INSERT INTO normal_table1 (id,data) VALUES (10,concat(2,' test'))
INSERT INTO normal_table1 (id,data) VALUES (abs(-1),concat(2,'text'))
INSERT LOW_PRIORITY INTO normal_table1 (id,data) value (6,'e')
INSERT DELAYED INTO normal_table1 (id,data) value (7,'f')
INSERT HIGH_PRIORITY INTO normal_table1 (id,data) value (8,'g')
INSERT IGNORE INTO normal_table1 (id,data) value (9,'h')
SELECT id,data FROM normal_table1
DROP TABLE IF EXISTS normal_table1
CREATE TABLE normal_table1 (id INT NOT NULL, name VARCHAR(10))
INSERT INTO normal_table1 VALUES (1,'aaa')
INSERT INTO normal_table1 VALUES (abs(-1),concat(2,'text'))
INSERT INTO normal_table1 VALUES (2,'bbb'),(3,'ccc'),(4,'ddd')
INSERT INTO normal_table1 VALUES (5,'eee') ON DUPLICATE KEY UPDATE name='fff'
INSERT INTO normal_table1 VALUES (5,'eee') ON DUPLICATE KEY UPDATE id=6
SELECT id,name FROM normal_table1
INSERT INTO normal_table1 VALUES (6,'eee') ON DUPLICATE KEY UPDATE name='fff'
SELECT id,name FROM normal_table1
DELETE FROM normal_table1
ALTER TABLE normal_table1 add column name1 VARCHAR(20)
INSERT INTO normal_table1 VALUES (4,'ddd','aaa')
SELECT id,name FROM normal_table1
DELETE FROM normal_table1
ALTER TABLE normal_table1 DROP column name1
INSERT INTO normal_table1 VALUES (5,'fff')
SELECT id,name FROM normal_table1
DELETE FROM normal_table1
ALTER TABLE normal_table1 add PRIMARY KEY (id)
INSERT INTO normal_table1 VALUES (5,'fff')
SELECT id,name FROM normal_table1
DELETE FROM normal_table1
INSERT INTO normal_table1 VALUES (6,'ggg')
SELECT id,name FROM normal_table1
DROP TABLE normal_table1
CREATE TABLE normal_table1 (id INT(11),R_REGIONKEY INT(11) PRIMARY KEY,R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT LOW_PRIORITY normal_table1 SET id=1,R_REGIONKEY=1,R_NAME='test',R_COMMENT='test'
INSERT DELAYED normal_table1 SET id=1,R_REGIONKEY=2,R_NAME='test',R_COMMENT='test'
INSERT HIGH_PRIORITY normal_table1 SET id=1,R_REGIONKEY=3,R_NAME='test',R_COMMENT='test'
INSERT IGNORE normal_table1 SET id=1,R_REGIONKEY=4,R_NAME='test',R_COMMENT='test'
INSERT normal_table1 SET id=1,R_REGIONKEY=5,R_NAME='test',R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM normal_table1
DROP TABLE IF EXISTS normal_table1
CREATE TABLE normal_table1 (id INT(11),R_REGIONKEY INT(11) PRIMARY KEY,R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT INTO normal_table1 SET id=2,R_REGIONKEY=1*3,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*2,R_NAME='chen'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM normal_table1
INSERT INTO normal_table1 SET id=2,R_REGIONKEY=1*3,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*2,R_NAME='chen'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM normal_table1
DROP TABLE IF EXISTS normal_table1
CREATE TABLE normal_table1 (id INT(11),R_REGIONKEY INT(11) PRIMARY KEY,R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
#INSERT DELAYED INTO normal_table1 SET id=4,R_REGIONKEY=1*4,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*5
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM normal_table1
INSERT IGNORE INTO normal_table1 SET id=4,R_REGIONKEY=1*4,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*5
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM normal_table1
DROP TABLE IF EXISTS normal_table1
CREATE TABLE normal_table1 (id INT(11),R_REGIONKEY INT(11) PRIMARY KEY,R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT INTO normal_table1 SET id=2,R_REGIONKEY=2
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM normal_table1
#
#clear tables
#
DROP TABLE IF EXISTS normal_table1
DROP TABLE IF EXISTS aly_test
