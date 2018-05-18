#ALTER TABLE Syntax
#[table_options]
#not SUPPORTED
#ALTER TABLE aly_test ENGINE = InnoDB;
#ALTER TABLE aly_test AUTO_INCREMENT = 1000;
#ALTER TABLE aly_test AVG_ROW_LENGTH = 1000;
#ALTER TABLE aly_test DEFAULT CHARACTER SET = utf8;
#ALTER TABLE aly_test CHECKSUM = 0;
#ALTER TABLE aly_test DEFAULT COLLATE = utf8_bin;
#ALTER TABLE aly_test COMMENT = 'string';
#ALTER TABLE aly_test COMPRESSION = 'ZLIB';
#ALTER TABLE aly_test CONNECTION = 'connect_string';
#ALTER TABLE aly_test DATA DIRECTORY = '/tmp/'
#ALTER TABLE aly_test DELAY_KEY_WRITE = 1;
#ALTER TABLE aly_test ENCRYPTION='N';
#ALTER TABLE aly_test INDEX DIRECTORY = '/tmp/';
#ALTER TABLE aly_test INSERT_METHOD = NO;
#ALTER TABLE aly_test KEY_BLOCK_SIZE = 1000;
#ALTER TABLE aly_test MAX_ROWS = 100;
#ALTER TABLE aly_test MIN_ROES = 100;
#ALTER TABLE aly_test PACK_KEYS = 0;
#ALTER TABLE aly_test PASSWORD = 'test';
#ALTER TABLE aly_test ROW_FORMAT = COMPRESSED;
#ALTER TABLE aly_test STATS_AUTO_RECALC = DEFAULT;
#ALTER TABLE aly_test STATS_PERSISTENT = DEFAULT;
#ALTER TABLE aly_test STATS_SAMPLE_PAGES = 1;
#ALTER TABLE aly_test TABLESPACE aly_test1 STORAGE DISK;
#ALTER TABLE aly_test UNION (aly_order);
#
#ADD {INDEX|KEY} ... [index_type] ... (not SUPPORTED)
#ALTER TABLE aly_test ADD KEY id_index USING BTREE (id)
#ALTER TABLE aly_test ADD KEY id_index USING HASH (id)
#ALTER TABLE aly_test ADD KEY id_index USING BTREE (id,R_COMMENT,R_NAME)
#ALTER TABLE aly_test ADD KEY id_index USING BTREE (id ASC,R_COMMENT(2) ASC,R_NAME(2) DESC)
#
#ADD {INDEX|KEY} ... [index_option]... (not SUPPORTED)
#ALTER TABLE aly_test ADD INDEX idx (id,R_COMMENT,R_NAME) key_block_size = 100
#ALTER TABLE aly_test ADD INDEX idx (id,R_COMMENT,R_NAME) USING BTREE
#ALTER TABLE aly_test ADD INDEX idx (id,R_COMMENT,R_NAME) USING HASH
#ALTER TABLE aly_test ADD INDEX idx (id,R_COMMENT,R_NAME) with parser parser_name
#ALTER TABLE aly_test ADD INDEX idx (id,R_COMMENT,R_NAME) comment 'testing'
#
#
#ADD [COLUMN] col_name column_definition
#          [FIRST | AFTER col_name ]
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),R_REGIONKEY int(11),R_NAME varchar(50),R_COMMENT varchar(50))
ALTER TABLE aly_test ADD name CHAR(5)
INSERT INTO aly_test VALUES (1,1,'aaa','aaa','aaa')
DESC aly_test
ALTER TABLE aly_test ADD COLUMN name2 CHAR(5)
INSERT INTO aly_test VALUES (2,1,'aaa','aaa','aaa','aaa')
DESC aly_test
ALTER TABLE aly_test ADD COLUMN name3 CHAR(5) FIRST
INSERT INTO aly_test VALUES ('aaa',3,1,'aaa','aaa','aaa','aaa')
DESC aly_test
ALTER TABLE aly_test ADD COLUMN name4 CHAR(5) AFTER  R_REGIONKEY
INSERT INTO aly_test VALUES ('aaa',4,1,'aaa','aaa','aaa','aaa','aaa')
DESC aly_test
ALTER TABLE aly_test ADD COLUMN (name5 CHAR(5) ,name6 char(6))
INSERT INTO aly_test VALUES ('aaa',5,1,'aaa','aaa','aaa','aaa','aaa','aaa','aaa')
DESC aly_test
ALTER TABLE aly_test ADD COLUMN (name7 enum('node1','node2','node3') DEFAULT 'node3',name8 varchar(6) NOT NULL)
INSERT INTO aly_test VALUES ('aaa',6,1,'aaa','aaa','aaa','aaa','aaa','aaa','aaa','node1','aaa')
DESC aly_test
ALTER TABLE aly_test DROP column name,DROP column name2,DROP column name3,DROP column name4,DROP column name5
INSERT INTO aly_test VALUES (7,1,'aaa','aaa','aaa','node1','aaa')
ALTER TABLE aly_test DROP name6
INSERT INTO aly_test VALUES (8,1,'aaa','aaa','node1','aaa')
ALTER TABLE aly_test DROP COLUMN name7
INSERT INTO aly_test VALUES (9,1,'aaa','aaa','aaa')
ALTER TABLE aly_test DROP COLUMN name8
INSERT INTO aly_test VALUES (10,1,'aaa','aaa')
DESC aly_test
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM aly_test
#
#
#ALTER TABLE tbl_name  ADD {INDEX|KEY} [index_name]
#        [index_type] (index_col_name,...)[index_option] ...
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),R_REGIONKEY int(11),R_NAME varchar(50),R_COMMENT varchar(50))
ALTER TABLE aly_test ADD INDEX (id)
SHOW INDEX FROM aly_test
INSERT INTO aly_test VALUES (1,1,'aaa','aaa')
ALTER TABLE aly_test DROP INDEX id
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test ADD INDEX idx (id)
INSERT INTO aly_test VALUES (2,2,'aaa','aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP KEY idx
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test ADD INDEX idx (id,R_COMMENT,R_NAME)
INSERT INTO aly_test VALUES (3,3,'aaa','aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP KEY idx
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test ADD INDEX idx (id ASC,R_COMMENT(2) ASC,R_NAME(2) DESC)
INSERT INTO aly_test VALUES (4,4,'aaa','aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP KEY idx
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test ADD KEY (id ASC,R_NAME DESC)
INSERT INTO aly_test VALUES (5,5,'aaa','aaa')
SHOW CREATE TABLE aly_test
#ALTER TABLE aly_test DROP KEY (id)
ALTER TABLE aly_test ADD KEY idx (id ASC,R_COMMENT(2) ASC,R_NAME(2) DESC)
INSERT INTO aly_test VALUES (6,6,'aaa','aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP KEY idx
SHOW CREATE TABLE aly_test
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM aly_test
#
#[index_type] not supported
#ALTER TABLE aly_test ADD KEY id_index USING BTREE (id)
#ALTER TABLE aly_test ADD KEY id_index USING HASH (id)
#ALTER TABLE aly_test ADD KEY id_index USING BTREE (id,R_COMMENT,R_NAME)
#ALTER TABLE aly_test ADD KEY id_index USING BTREE (id ASC,R_COMMENT(2) ASC,R_NAME(2) DESC)
#
#[index_option] not supported
#ALTER TABLE aly_test ADD INDEX idx (id,R_COMMENT,R_NAME) key_block_size = 100
#ALTER TABLE aly_test ADD INDEX idx (id,R_COMMENT,R_NAME) USING BTREE
#ALTER TABLE aly_test ADD INDEX idx (id,R_COMMENT,R_NAME) USING HASH
#ALTER TABLE aly_test ADD INDEX idx (id,R_COMMENT,R_NAME) with parser parser_name
#ALTER TABLE aly_test ADD INDEX idx (id,R_COMMENT,R_NAME) comment 'testing'
#
#
# ADD [CONSTRAINT [symbol]] PRIMARY KEY
#        [index_type] (index_col_name,...) [index_option] ...
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int(11),data int,Code char(3))
ALTER TABLE aly_test ADD PRIMARY KEY (code)
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP PRIMARY KEY
ALTER TABLE aly_test ADD PRIMARY KEY (id,data)
INSERT INTO aly_test VALUES (2,2,'bbb')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP PRIMARY KEY
ALTER TABLE aly_test ADD PRIMARY KEY USING HASH (code)
INSERT INTO aly_test VALUES (4,4,'ddd')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP PRIMARY KEY
ALTER TABLE aly_test ADD PRIMARY KEY USING BTREE (code)
INSERT INTO aly_test VALUES (5,5,'eee')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP PRIMARY KEY
ALTER TABLE aly_test ADD CONSTRAINT pK_id PRIMARY KEY (id)
INSERT INTO aly_test VALUES (6,6,'fff')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP PRIMARY KEY
SELECT id,data,Code FROM aly_test
SHOW CREATE TABLE aly_test
#
#index_col_name: not SUPPORTED
#ALTER TABLE aly_test ADD PRIMARY KEY (id ASC,data DESC)
#ALTER TABLE aly_test ADD CONSTRAINT PRIMARY KEY (id)
#ALTER TABLE aly_test ADD CONSTRAINT PRIMARY KEY (id asc,code DESC)
#
#
# ADD [CONSTRAINT [symbol]] (not supported)
#        UNIQUE [INDEX|KEY] [index_name]
#        [index_type] (index_col_name,...) [index_option] ...
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int(11),data int,Code char(3))
ALTER TABLE aly_test ADD UNIQUE (code)
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP KEY Code
ALTER TABLE aly_test ADD UNIQUE up_id (id ASC)
INSERT INTO aly_test VALUES (2,2,'aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP KEY up_id
ALTER TABLE aly_test ADD UNIQUE KEY (id)
INSERT INTO aly_test VALUES (3,3,'aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP KEY id
ALTER TABLE aly_test ADD UNIQUE KEY (id,data)
INSERT INTO aly_test VALUES (4,4,'aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP KEY id
ALTER TABLE aly_test ADD UNIQUE KEY (id ASC,data DESC)
INSERT INTO aly_test VALUES (5,5,'aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP KEY id
ALTER TABLE aly_test ADD UNIQUE KEY uk_id (id ASC,data DESC)
INSERT INTO aly_test VALUES (6,6,'aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP KEY uk_id
ALTER TABLE aly_test ADD UNIQUE INDEX (id)
INSERT INTO aly_test VALUES (7,7,'aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP INDEX id
ALTER TABLE aly_test ADD UNIQUE INDEX (id ASC,data DESC)
INSERT INTO aly_test VALUES (8,8,'aaa')
SHOW CREATE TABLE aly_test
ALTER TABLE aly_test DROP INDEX id
ALTER TABLE aly_test ADD UNIQUE INDEX idxs (id asc,code DESC)
INSERT INTO aly_test VALUES (9,9,'aaa')
SHOW CREATE TABLE aly_test
SELECT id,data,code FROM aly_test
#
#[index_type] not supported
#[index_option] not supported
#CONSTRAINT UNIQUE KEY: not supported
#ALTER TABLE aly_test ADD UNIQUE USING HASH (id)
#ALTER TABLE aly_test ADD UNIQUE (id) COMMENT 'string'
#ALTER TABLE aly_test ADD UNIQUE KEY idxs USING HASH (id asc,code DESC) comment 'string'
#ALTER TABLE aly_test ADD CONSTRAINT UNIQUE KEY (id)
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
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),col1 varchar(11),col2 int(10),col3 varchar(50),col4 int(10),col5 varchar(50),col6 date,col7 double(12,6))
ALTER TABLE aly_test CHANGE col1 ID1 INTEGER  NOT NULL DEFAULT 10 COMMENT 'my column1'
INSERT INTO aly_test VALUES (1,1,1,'aaa',1,'aaa','2017-5-5',12.7)
DESC aly_test
ALTER TABLE aly_test CHANGE COLUMN col7 ID2 INTEGER FIRST
INSERT INTO aly_test VALUES (2,2,2,2,'aaa',2,'aaa','2017-5-5')
DESC aly_test
ALTER TABLE aly_test CHANGE col6 ID4 VARCHAR(10) AFTER id
INSERT INTO aly_test VALUES (3,3,'aaa',3,3,'aaa',3,'aaa')
DESC aly_test
SELECT * FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int,data int)
ALTER TABLE aly_test CHANGE COLUMN data data VARCHAR(10)
INSERT INTO aly_test VALUES (3,'aaa')
DESC aly_test
#
#
#MODIFY [COLUMN] col_name column_definition
#        [FIRST | AFTER col_name]
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int(11),R_REGIONKEY int(11),R_NAME varchar(50),R_COMMENT varchar(50))
ALTER TABLE aly_test MODIFY R_COMMENT BIGINT NOT NULL
INSERT INTO aly_test VALUES (1,1,'aaa',1)
DESC aly_test
ALTER TABLE aly_test MODIFY R_COMMENT BIGINT UNSIGNED DEFAULT 1 COMMENT 'my column' AFTER R_REGIONKEY
INSERT INTO aly_test VALUES (2,2,2,'aaa')
DESC aly_test
ALTER TABLE aly_test MODIFY R_REGIONKEY BIGINT UNSIGNED NOT NULL DEFAULT 10 COMMENT 'my column1' FIRST
INSERT INTO aly_test VALUES (3,3,3,'aaa')
DESC aly_test
ALTER TABLE aly_test MODIFY COLUMN R_COMMENT BIGINT UNSIGNED UNIQUE DEFAULT 1 COMMENT 'my column2' AFTER R_REGIONKEY
INSERT INTO aly_test VALUES (4,4,4,'aaa')
SELECT * FROM aly_test
DESC aly_test
DROP TABLE IF EXISTS aly_test
#
#
# notsharding-table
DROP TABLE IF EXISTS normal_table
CREATE TABLE normal_table (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
ALTER TABLE normal_table ADD name CHAR(5)
#test
DESC normal_table
ALTER TABLE normal_table ADD COLUMN name2 CHAR(5)
DESC normal_table
ALTER TABLE normal_table ADD COLUMN name3 CHAR(5) FIRST
DESC normal_table
ALTER TABLE normal_table ADD COLUMN name4 CHAR(5) AFTER  R_REGIONKEY
DESC normal_table
ALTER TABLE normal_table ADD COLUMN (name5 CHAR(5) ,name6 char(6))
DESC normal_table
ALTER TABLE normal_table ADD COLUMN (name7 enum('node1','node2','node3') DEFAULT 'node3',name8 varchar(6) NOT NULL)
DESC normal_table
ALTER TABLE normal_table DROP column name,DROP column name2,DROP column name3,DROP column name4,DROP column name5
ALTER TABLE normal_table DROP name6
ALTER TABLE normal_table DROP COLUMN name7
ALTER TABLE normal_table DROP COLUMN name8
DESC normal_table
DROP TABLE IF EXISTS normal_table
CREATE TABLE normal_table (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
ALTER TABLE normal_table ADD INDEX (id)
#where part will ignored
#SHOW INDEX in normal_table where Key_name='id'
SHOW INDEX in normal_table
ALTER TABLE normal_table DROP INDEX id
DROP TABLE IF EXISTS normal_table
CREATE TABLE normal_table(id int(11),Code char(3))
ALTER TABLE normal_table ADD PRIMARY KEY (code)
DESC normal_table
ALTER TABLE normal_table DROP PRIMARY KEY
DROP TABLE IF EXISTS normal_table
CREATE TABLE normal_table(id int(11),Code char(3))
ALTER TABLE normal_table ADD UNIQUE (code)
DESC normal_table
ALTER TABLE normal_table DROP KEY Code
DROP TABLE IF EXISTS normal_table
DROP TABLE IF EXISTS aly_order
CREATE TABLE aly_order(id int(11),CountryCode char(3))
CREATE TABLE normal_table (id int(11),col1 varchar(11) PRIMARY KEY,col2 int(10),col3 varchar(50),col4 int(10),col5 varchar(50),col6 date,col7 double(12,6))
ALTER TABLE normal_table CHANGE col1 ID1 INTEGER
DESC normal_table
ALTER TABLE normal_table CHANGE COLUMN col7 ID2 INTEGER
DESC normal_table
ALTER TABLE normal_table CHANGE col6 ID4 enum ('id1','id2','id3','id4') AFTER id
DESC normal_table
DROP TABLE IF EXISTS normal_table
CREATE TABLE normal_table (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
ALTER TABLE normal_table MODIFY R_COMMENT BIGINT NOT NULL
DESC normal_table
ALTER TABLE normal_table MODIFY R_COMMENT BIGINT UNSIGNED DEFAULT 1 COMMENT 'my column' AFTER R_REGIONKEY
DESC normal_table
ALTER TABLE normal_table MODIFY R_REGIONKEY BIGINT UNSIGNED NOT NULL DEFAULT 10 COMMENT 'my column1' FIRST
DESC normal_table
ALTER TABLE normal_table MODIFY COLUMN R_COMMENT BIGINT UNSIGNED UNIQUE DEFAULT 1 COMMENT 'my column2' AFTER R_REGIONKEY
DESC normal_table
DROP TABLE IF EXISTS normal_table
#global-table
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
ALTER TABLE global_table1 ADD name CHAR(5)
DESC global_table1 /* allow_diff */
ALTER TABLE global_table1 ADD COLUMN name2 CHAR(5)
DESC global_table1 /* allow_diff */
ALTER TABLE global_table1 ADD COLUMN name3 CHAR(5) FIRST
DESC global_table1 /* allow_diff */
ALTER TABLE global_table1 ADD COLUMN name4 CHAR(5) AFTER  R_REGIONKEY
DESC global_table1 /* allow_diff */
ALTER TABLE global_table1 ADD COLUMN (name5 CHAR(5) ,name6 char(6))
DESC global_table1 /* allow_diff */
ALTER TABLE global_table1 ADD COLUMN (name7 enum('node1','node2','node3') DEFAULT 'node3',name8 varchar(6) NOT NULL)
DESC global_table1 /* allow_diff */
ALTER TABLE global_table1 DROP column name,DROP column name2,DROP column name3,DROP column name4,DROP column name5
ALTER TABLE global_table1 DROP name6
ALTER TABLE global_table1 DROP COLUMN name7
ALTER TABLE global_table1 DROP COLUMN name8
DESC global_table1  /* allow_diff */
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
ALTER TABLE global_table1 ADD INDEX (id)
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1(id int(11),Code char(3))
ALTER TABLE global_table1 ADD PRIMARY KEY (code)
DESC global_table1  /* allow_diff */
ALTER TABLE global_table1 DROP PRIMARY KEY
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1(id int(11),Code char(3))
ALTER TABLE global_table1 ADD UNIQUE (code)
DESC global_table1 /* allow_diff */
ALTER TABLE global_table1 DROP KEY Code
DROP TABLE IF EXISTS aly_order
DROP TABLE IF EXISTS global_table1
CREATE TABLE aly_order(id int(11),CountryCode char(3))
CREATE TABLE global_table1 (id int(11),col1 varchar(11) PRIMARY KEY,col2 int(10),col3 varchar(50),col4 int(10),col5 varchar(50),col6 date,col7 double(12,6))
ALTER TABLE global_table1 CHANGE col1 ID1 INTEGER
DESC global_table1 /* allow_diff */
ALTER TABLE global_table1 CHANGE COLUMN col7 ID2 INTEGER
DESC global_table1 /* allow_diff */
ALTER TABLE global_table1 CHANGE col6 ID4 enum ('id1','id2','id3','id4') AFTER id
DESC global_table1 /* allow_diff */
DROP TABLE IF EXISTS global_table1
CREATE TABLE global_table1 (id int(11),R_REGIONKEY int(11) PRIMARY KEY,R_NAME varchar(50),R_COMMENT varchar(50))
ALTER TABLE global_table1 MODIFY R_COMMENT BIGINT NOT NULL
DESC global_table1 /* allow_diff */
ALTER TABLE global_table1 MODIFY R_COMMENT BIGINT UNSIGNED DEFAULT 1 COMMENT 'my column' AFTER R_REGIONKEY
DESC global_table1 /* allow_diff */
ALTER TABLE global_table1 MODIFY R_REGIONKEY BIGINT UNSIGNED NOT NULL DEFAULT 10 COMMENT 'my column1' FIRST
DESC global_table1 /* allow_diff */
ALTER TABLE global_table1 MODIFY COLUMN R_COMMENT BIGINT UNSIGNED UNIQUE DEFAULT 1 COMMENT 'my column2' AFTER R_REGIONKEY
DESC global_table1 /* allow_diff */
#
#clear tables
#
DROP TABLE IF EXISTS aly_order
DROP TABLE IF EXISTS global_table1
DROP TABLE IF EXISTS aly_test
DROP TABLE IF EXISTS normal_table