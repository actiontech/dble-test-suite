#!default_db:schema1
#ALTER TABLE Syntax
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11),R_NAME varchar(50),R_COMMENT varchar(50))
DROP TABLE IF EXISTS schema2.test2
CREATE TABLE schema2.test2 (id int(11),R_REGIONKEY int(11),R_NAME varchar(50),R_COMMENT varchar(50))
#[table_options]
#not SUPPORTED
ALTER TABLE test1 ENGINE = InnoDB;
ALTER TABLE test1 AUTO_INCREMENT = 1000;
ALTER TABLE test1 AVG_ROW_LENGTH = 1000;
ALTER TABLE test1 DEFAULT CHARACTER SET = utf8;
ALTER TABLE test1 CHECKSUM = 0;
ALTER TABLE test1 DEFAULT COLLATE = utf8_bin;
ALTER TABLE test1 COMMENT = 'string';
ALTER TABLE test1 COMPRESSION = 'ZLIB';
ALTER TABLE test1 CONNECTION = 'connect_string';
ALTER TABLE test1 DATA DIRECTORY = '/tmp/'
ALTER TABLE test1 DELAY_KEY_WRITE = 1;
ALTER TABLE test1 ENCRYPTION='N';
ALTER TABLE test1 INDEX DIRECTORY = '/tmp/';
ALTER TABLE test1 INSERT_METHOD = NO;
ALTER TABLE test1 KEY_BLOCK_SIZE = 1000;
ALTER TABLE test1 MAX_ROWS = 100;
ALTER TABLE test1 MIN_ROWS = 100;
ALTER TABLE test1 PACK_KEYS = 0;
ALTER TABLE test1 PASSWORD = 'test';
ALTER TABLE test1 ROW_FORMAT = COMPRESSED;
ALTER TABLE test1 STATS_AUTO_RECALC = DEFAULT;
ALTER TABLE test1 STATS_PERSISTENT = DEFAULT;
ALTER TABLE test1 STATS_SAMPLE_PAGES = 1;
ALTER TABLE test1 TABLESPACE aly_test1 STORAGE DISK;
ALTER TABLE test1 UNION (schema2.test2);
#
#ADD {INDEX|KEY} ... [index_type] ... (not SUPPORTED)
ALTER TABLE test1 ADD KEY id_index USING BTREE (id)
drop index id_index on test1
ALTER TABLE test1 ADD KEY id_index USING HASH (id)
drop index id_index on test1
ALTER TABLE test1 ADD KEY id_index USING BTREE (id,R_COMMENT,R_NAME)
drop index id_index on test1
ALTER TABLE test1 ADD KEY id_index USING BTREE (id ASC,R_COMMENT(2) ASC,R_NAME(2) DESC)
drop index id_index on test1
#
#ADD {INDEX|KEY} ... [index_option]... (not SUPPORTED)
ALTER TABLE test1 ADD INDEX idx (id,R_COMMENT,R_NAME) key_block_size = 100
ALTER TABLE test1 ADD INDEX idx (id,R_COMMENT,R_NAME) USING BTREE
drop index idx on test1
ALTER TABLE test1 ADD INDEX idx (id,R_COMMENT,R_NAME) USING HASH
drop index idx on test1
ALTER TABLE test1 ADD INDEX idx (id,R_COMMENT,R_NAME) with parser parser_name
drop index idx on test1
ALTER TABLE test1 ADD INDEX idx (id,R_COMMENT,R_NAME) comment 'testing'
drop index idx on test1
#
#
#ADD [COLUMN] col_name column_definition
#          [FIRST | AFTER col_name ]
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11),R_NAME varchar(50),R_COMMENT varchar(50))
ALTER TABLE test1 ADD name CHAR(5)
INSERT INTO test1 VALUES (1,1,'aaa','aaa','aaa')
DESC test1
ALTER TABLE test1 ADD COLUMN name2 CHAR(5)
INSERT INTO test1 VALUES (2,1,'aaa','aaa','aaa','aaa')
DESC test1
ALTER TABLE test1 ADD COLUMN name3 CHAR(5) FIRST
INSERT INTO test1 VALUES ('aaa',3,1,'aaa','aaa','aaa','aaa')
DESC test1
ALTER TABLE test1 ADD COLUMN name4 CHAR(5) AFTER  R_REGIONKEY
INSERT INTO test1 VALUES ('aaa',4,1,'aaa','aaa','aaa','aaa','aaa')
DESC test1
ALTER TABLE test1 ADD COLUMN (name5 CHAR(5) ,name6 char(6))
INSERT INTO test1 VALUES ('aaa',5,1,'aaa','aaa','aaa','aaa','aaa','aaa','aaa')
DESC test1
ALTER TABLE test1 ADD COLUMN (name7 enum('node1','node2','node3') DEFAULT 'node3',name8 varchar(6) NOT NULL)
INSERT INTO test1 VALUES ('aaa',6,1,'aaa','aaa','aaa','aaa','aaa','aaa','aaa','node1','aaa')
DESC test1
ALTER TABLE test1 DROP column name,DROP column name2,DROP column name3,DROP column name4,DROP column name5
INSERT INTO test1 VALUES (7,1,'aaa','aaa','aaa','node1','aaa')
ALTER TABLE test1 DROP name6
INSERT INTO test1 VALUES (8,1,'aaa','aaa','node1','aaa')
ALTER TABLE test1 DROP COLUMN name7
INSERT INTO test1 VALUES (9,1,'aaa','aaa','aaa')
ALTER TABLE test1 DROP COLUMN name8
INSERT INTO test1 VALUES (10,1,'aaa','aaa')
DESC test1
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#
#
#ALTER TABLE tbl_name  ADD {INDEX|KEY} [index_name]
#        [index_type] (index_col_name,...)[index_option] ...
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11),R_NAME varchar(50),R_COMMENT varchar(50))
ALTER TABLE test1 ADD INDEX (id)
SHOW INDEX FROM test1
INSERT INTO test1 VALUES (1,1,'aaa','aaa')
ALTER TABLE test1 DROP INDEX id
SHOW CREATE TABLE test1
ALTER TABLE test1 ADD INDEX idx (id)
INSERT INTO test1 VALUES (2,2,'aaa','aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP KEY idx
SHOW CREATE TABLE test1
ALTER TABLE test1 ADD INDEX idx (id,R_COMMENT,R_NAME)
INSERT INTO test1 VALUES (3,3,'aaa','aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP KEY idx
SHOW CREATE TABLE test1
ALTER TABLE test1 ADD INDEX idx (id ASC,R_COMMENT(2) ASC,R_NAME(2) DESC)
INSERT INTO test1 VALUES (4,4,'aaa','aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP KEY idx
SHOW CREATE TABLE test1
ALTER TABLE test1 ADD KEY (id ASC,R_NAME DESC)
INSERT INTO test1 VALUES (5,5,'aaa','aaa')
SHOW CREATE TABLE test1
#ALTER TABLE test1 DROP KEY (id)
ALTER TABLE test1 ADD KEY idx (id ASC,R_COMMENT(2) ASC,R_NAME(2) DESC)
INSERT INTO test1 VALUES (6,6,'aaa','aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP KEY idx
SHOW CREATE TABLE test1
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#
# ADD [CONSTRAINT [symbol]] PRIMARY KEY
#        [index_type] (index_col_name,...) [index_option] ...
DROP TABLE IF EXISTS test1
CREATE TABLE test1(id int(11),data int,Code char(3))
ALTER TABLE test1 ADD PRIMARY KEY (code)
INSERT INTO test1 VALUES (1,1,'aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP PRIMARY KEY
ALTER TABLE test1 ADD PRIMARY KEY (id,data)
INSERT INTO test1 VALUES (2,2,'bbb')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP PRIMARY KEY
ALTER TABLE test1 ADD PRIMARY KEY USING HASH (code)
INSERT INTO test1 VALUES (4,4,'ddd')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP PRIMARY KEY
ALTER TABLE test1 ADD PRIMARY KEY USING BTREE (code)
INSERT INTO test1 VALUES (5,5,'eee')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP PRIMARY KEY
ALTER TABLE test1 ADD CONSTRAINT pK_id PRIMARY KEY (id)
INSERT INTO test1 VALUES (6,6,'fff')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP PRIMARY KEY
SELECT id,data,Code FROM test1
SHOW CREATE TABLE test1
#
#index_col_name: not SUPPORTED
ALTER TABLE test1 ADD PRIMARY KEY (id ASC,data DESC)
ALTER TABLE test1 ADD CONSTRAINT PRIMARY KEY (id)
ALTER TABLE test1 ADD CONSTRAINT PRIMARY KEY (id asc,code DESC)
#
#
# ADD [CONSTRAINT [symbol]] (not supported)
#        UNIQUE [INDEX|KEY] [index_name]
#        [index_type] (index_col_name,...) [index_option] ...
DROP TABLE IF EXISTS test1
CREATE TABLE test1(id int(11),data int,Code char(3))
ALTER TABLE test1 ADD UNIQUE (code)
INSERT INTO test1 VALUES (1,1,'aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP KEY Code
ALTER TABLE test1 ADD UNIQUE up_id (id ASC)
INSERT INTO test1 VALUES (2,2,'aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP KEY up_id
ALTER TABLE test1 ADD UNIQUE KEY (id)
INSERT INTO test1 VALUES (3,3,'aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP KEY id
ALTER TABLE test1 ADD UNIQUE KEY (id,data)
INSERT INTO test1 VALUES (4,4,'aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP KEY id
ALTER TABLE test1 ADD UNIQUE KEY (id ASC,data DESC)
INSERT INTO test1 VALUES (5,5,'aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP KEY id
ALTER TABLE test1 ADD UNIQUE KEY uk_id (id ASC,data DESC)
INSERT INTO test1 VALUES (6,6,'aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP KEY uk_id
ALTER TABLE test1 ADD UNIQUE INDEX (id)
INSERT INTO test1 VALUES (7,7,'aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP INDEX id
ALTER TABLE test1 ADD UNIQUE INDEX (id ASC,data DESC)
INSERT INTO test1 VALUES (8,8,'aaa')
SHOW CREATE TABLE test1
ALTER TABLE test1 DROP INDEX id
ALTER TABLE test1 ADD UNIQUE INDEX idxs (id asc,code DESC)
INSERT INTO test1 VALUES (9,9,'aaa')
SHOW CREATE TABLE test1
SELECT id,data,code FROM test1
#
#[index_type] not supported
#[index_option] not supported
#CONSTRAINT UNIQUE KEY: not supported
drop index idxs on test1
ALTER TABLE test1 ADD UNIQUE USING HASH (id)
ALTER TABLE test1 ADD UNIQUE (id) COMMENT 'string'
ALTER TABLE test1 ADD UNIQUE KEY idxs USING HASH (id asc,code DESC) comment 'string'
ALTER TABLE test1 ADD CONSTRAINT UNIQUE KEY (id)
#
#ADD FULLTEXT [INDEX|KEY] [index_name]
#        (index_col_name,...) [index_option] ... (not supported)
#
#ADD SPATIAL [INDEX|KEY] [index_name]
#        (index_col_name,...) [index_option] ... (not supported)
#
#
#CHANGE [COLUMN] old_col_name new_col_name column_definition
#        [FIRST|AFTER col_name]
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),col1 varchar(11),col2 int(10),col3 varchar(50),col4 int(10),col5 varchar(50),col6 date,col7 double(12,6))
ALTER TABLE test1 CHANGE col1 ID1 INTEGER  NOT NULL DEFAULT 10 COMMENT 'my column1'
INSERT INTO test1 VALUES (1,1,1,'aaa',1,'aaa','2017-5-5',12.7)
DESC test1
ALTER TABLE test1 CHANGE COLUMN col7 ID2 INTEGER FIRST
INSERT INTO test1 VALUES (2,2,2,2,'aaa',2,'aaa','2017-5-5')
DESC test1
ALTER TABLE test1 CHANGE col6 ID4 VARCHAR(10) AFTER id
INSERT INTO test1 VALUES (3,3,'aaa',3,3,'aaa',3,'aaa')
DESC test1
SELECT * FROM test1
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int,data int)
ALTER TABLE test1 CHANGE COLUMN data data VARCHAR(10)
INSERT INTO test1 VALUES (3,'aaa')
DESC test1
#
#
#MODIFY [COLUMN] col_name column_definition
#        [FIRST | AFTER col_name]
DROP TABLE IF EXISTS test1
CREATE TABLE test1 (id int(11),R_REGIONKEY int(11),R_NAME varchar(50),R_COMMENT varchar(50))
ALTER TABLE test1 MODIFY R_COMMENT BIGINT NOT NULL
INSERT INTO test1 VALUES (1,1,'aaa',1)
DESC test1
ALTER TABLE test1 MODIFY R_COMMENT BIGINT UNSIGNED DEFAULT 1 COMMENT 'my column' AFTER R_REGIONKEY
INSERT INTO test1 VALUES (2,2,2,'aaa')
DESC test1
ALTER TABLE test1 MODIFY R_REGIONKEY BIGINT UNSIGNED NOT NULL DEFAULT 10 COMMENT 'my column1' FIRST
INSERT INTO test1 VALUES (3,3,3,'aaa')
DESC test1
ALTER TABLE test1 MODIFY COLUMN R_COMMENT BIGINT UNSIGNED UNIQUE DEFAULT 1 COMMENT 'my column2' AFTER R_REGIONKEY
INSERT INTO test1 VALUES (4,4,4,'aaa')
SELECT * FROM test1
DESC test1
DROP TABLE IF EXISTS test1
create table test1(a int(4))
alter table test1 add 01a boolean
alter table test1 drop column test1.01a
alter table test1 add `011` boolean
alter table test1 add $ boolean
alter table test1 add _ boolean
alter table test1 add abcABC varchar(1)
alter table test1 add abc89ABC varchar(1)
alter table test1 add `select` int(4)
desc test1
#
#clear tables
#
DROP TABLE IF EXISTS test1
DROP TABLE IF EXISTS schema2.test2
