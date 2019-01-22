#!default_db:schema1
#SHARDING TABLE
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id INT, data VARCHAR(50))
#
#INSERT [ LOW_PRIORITY | DELAYED | HIGH_PRIORITY ] [IGNORE]
#Syntax supported,but Invalid
##PRIMARY KEY must be sharding key,otherwise [IGNORE] maybe Invalid
INSERT LOW_PRIORITY INTO test1 (id,data) value (6,'e')
INSERT DELAYED INTO test1 (id,data) value (7,'f')
INSERT HIGH_PRIORITY INTO test1 (id,data) value (8,'g')
INSERT IGNORE INTO test1 (id,data) value (9,'h')
INSERT LOW_PRIORITY INTO test1 SET id=1,data='a'
INSERT DELAYED INTO test1 SET id=2,data='aa'
INSERT HIGH_PRIORITY INTO test1 SET id=3,data='aaa'
INSERT IGNORE INTO test1 SET id=4,data='aaaaa'
#
#INSERT [INTO] tbl_name (col_name,...) { VALUES| VALUE } ...
INSERT INTO test1 (id,data) VALUE (1,'a')
INSERT INTO test1 (id,data) VALUES (2,'b')
INSERT INTO test1 (id,data) VALUES (7,null)
INSERT INTO test1 (id,data) VALUES (3,'a'),(4,'b'),(5,'c')
INSERT INTO test1 (id,data) VALUES (10,concat(2,' test'))
INSERT INTO test1 (id,data) VALUES (abs(-1),concat(2,'text'))
INSERT test1 (id,data) VALUES (6,'a'),(7,'b')
INSERT test1 VALUES (8,'c'),(9,'d')
INSERT INTO test1 VALUES (abs(-1),concat(2,'text'))
SELECT id,data FROM test1
#
#INSERT INTO tbl_name (col_name,...) { VALUES| VALUE } ({ expr|DEFAULT},...) ...
#Sharding key not supported use expr and DEFAULT
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id INT NOT NULL, data INT)
INSERT INTO test1 (id,data) VALUES (1,id*id),(2,id*id)
#INSERT INTO test1 (id,data) VALUES (data+data,2),(data+data,4)
INSERT INTO test1 (id) VALUES (3),(4)
SELECT id,data FROM test1
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id INT NOT NULL default 1, data VARCHAR(10) default 'test')
INSERT INTO test1 (id,data) VALUES (1,'aaa'),(2,'bbb')
INSERT INTO test1 (id) VALUES (3),(4)
#INSERT INTO test1 (data) VALUES ('aaa')
SELECT id,data FROM test1
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id INT NOT NULL PRIMARY KEY, data VARCHAR(10))
INSERT INTO test1 (id,data) VALUES (1,'aaa'),(2,'bbb')
INSERT INTO test1 VALUES (3,'aaa')
SELECT id,data FROM test1
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id INT NOT NULL, data VARCHAR(10) default 'test')
INSERT INTO test1 (id,data) VALUES (1,'aaa'),(2,'bbb')
INSERT INTO test1 (id) VALUES (3),(4)
SELECT id,data FROM test1
#
#INSERT INTO tbl_name {VALUES|VALUE} (...)
DROP TABLE IF EXISTS test1
CREATE TABLE test1(id INT,data VARCHAR(10))
INSERT INTO test1 VALUE (1,'aaa'),(2,'bbb'),(3,'ccc'),(4,'dddd')
SELECT id,data FROM test1
INSERT INTO test1 VALUES (5,'eee'),(6,'fff')
SELECT id,data FROM test1
ALTER TABLE test1 add column name1 VARCHAR(20)
INSERT INTO test1 VALUES (4,'ddd','aaa')
SELECT id,data,name1 FROM test1
DELETE FROM test1
ALTER TABLE test1 DROP column name1
INSERT INTO test1 VALUES (5,'fff')
SELECT id,data FROM test1
DELETE FROM test1
ALTER TABLE test1 add PRIMARY KEY (id)
INSERT INTO test1 VALUES (5,'fff')
SELECT id,data FROM test1
DELETE FROM test1
INSERT INTO test1 VALUES (6,'ggg')
SELECT id,data FROM test1
#
#INSERT INTO tbl_name ... VALUES ... ON DUPLICATE KEY UPDATE ...
#After duplicate key update not supported use Sharding key
#PRIMARY KEY must be sharding key,otherwise "on duplicate key update" maybe Invalid
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id INT NOT NULL PRIMARY KEY,number INT, name VARCHAR(10))
INSERT INTO test1 VALUES (1,1,'aaa'),(2,2,'bbb'),(3,3,'ccc')
INSERT INTO test1 VALUES (5,5,'eee') ON DUPLICATE KEY UPDATE name='fff'
SELECT id,number,name FROM test1
INSERT INTO test1 VALUES (5,5,'eee') ON DUPLICATE KEY UPDATE name='fff'
SELECT id,number,name FROM test1
#INSERT INTO test1 VALUES (5,'eee') ON DUPLICATE KEY UPDATE id=1
INSERT INTO test1 VALUES (6,6,'aaa') ON DUPLICATE KEY UPDATE number=number*2,name='AAAA1'
SELECT id,number,name FROM test1
INSERT INTO test1 VALUES (6,7,'aaa') ON DUPLICATE KEY UPDATE number=number*2,name='AAAA2'
SELECT id,number,name FROM test1
INSERT INTO test1 VALUES (7,6,'aaa') ON DUPLICATE KEY UPDATE number=number*2,name='AAAA3'
SELECT id,number,name FROM test1
INSERT INTO test1 VALUES (6,6,'AAA') ON DUPLICATE KEY UPDATE number=number*2,name='AAAA4'
SELECT id,number,name FROM test1
#
#INSERT [INTO] tbl_name SET ...
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id INT(11) PRIMARY KEY,R_REGIONKEY INT(11),R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT test1 SET id = 1,R_REGIONKEY=1,R_NAME='aaa',R_COMMENT='AAA'
INSERT INTO test1 SET id = 2,R_REGIONKEY=2,R_NAME='bbb',R_COMMENT='BBB'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#
#INSERT INTO tbl_name SET col_name={ expr | DEFAULT },...
#Sharding key not supported use expr and DEFAULT
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id INT(11) PRIMARY KEY,R_REGIONKEY INT(11),R_NAME VARCHAR(50) DEFAULT 'test',R_COMMENT VARCHAR(50))
INSERT test1 SET id = 1,R_REGIONKEY=1,R_COMMENT='AAA'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT test1 SET id=1,R_REGIONKEY=5,R_NAME='test',R_COMMENT='test'
INSERT test1 SET id = 2,R_REGIONKEY=2*3,R_NAME='bbb',R_COMMENT='BBB'
INSERT test1 SET id = 3,R_REGIONKEY=3*3,R_COMMENT='BBB'
INSERT LOW_PRIORITY test1 SET id=4,R_REGIONKEY=1,R_NAME='test',R_COMMENT='test'
INSERT DELAYED test1 SET id=5,R_REGIONKEY=2,R_NAME='test',R_COMMENT='test'
INSERT HIGH_PRIORITY test1 SET id=6,R_REGIONKEY=3,R_NAME='test',R_COMMENT='test'
INSERT IGNORE test1 SET id=1,R_REGIONKEY=4,R_NAME='test',R_COMMENT='test'
#INSERT test1 SET id = 3*2,R_REGIONKEY=3*3,R_COMMENT='BBB'
#
#INSERT INTO tbl_name SET ... ON DUPLICATE KEY UPDATE ...
#After duplicate key update not supported use Sharding key
#PRIMARY KEY must be sharding key,otherwise "on duplicate key update" maybe Invalid
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id INT(11) PRIMARY KEY,R_REGIONKEY INT(11),R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT test1 SET id = 1,R_REGIONKEY=1,R_NAME='aaa',R_COMMENT='AAA'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 SET id=2,R_REGIONKEY=1*3,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*2,R_NAME='chen'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 SET id=2,R_REGIONKEY=1*3,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*2,R_NAME='chen'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
DROP TABLE IF EXISTS test1
#primary key is not id column (sharding column)
CREATE TABLE test1 (id INT(11),R_REGIONKEY INT(11) PRIMARY KEY,R_NAME VARCHAR(50),R_COMMENT VARCHAR(50))
INSERT DELAYED INTO test1 SET id=4,R_REGIONKEY=1*4,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*5
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT IGNORE INTO test1 SET id=4,R_REGIONKEY=1*4,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY*5
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 SET id=2,R_REGIONKEY=2
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
DROP TABLE IF EXISTS test1