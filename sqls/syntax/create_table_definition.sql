#CREATE TABLE [IF NOT EXISTS] tbl_name ...
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int,data varchar(10))
DESC aly_test
CREATE TABLE IF NOT EXISTS aly_test(id int,data varchar(10),test varchar(10))
DESC aly_test
#
#col_name column_definition
#data_type [NOT NULL | NULL] [DEFAULT default_value]
#
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int NOT NULL,data varchar(10))
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int,data varchar(10) NULL)
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int,data varchar(10) NOT NULL DEFAULT 'abc')
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int,data varchar(10) NULL DEFAULT 'abc')
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data char(20) DEFAULT 'abcde')
DESC aly_test
INSERT INTO aly_test VALUES (1,'a'),(2,DEFAULT),(3,NULL)
SELECT * FROM aly_test
#
#data_type [AUTO_INCREMENT]
#NONSENCE
#DROP TABLE IF EXISTS aly_test
#CREATE TABLE aly_test(id int PRIMARY KEY auto_increment,data varchar(10))
#INSERT INTO aly_test VALUES (1,'aaa')
#DESC aly_test
#
#data_type [UNIQUE [KEY] | [PRIMARY] KEY]
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data char(20) UNIQUE)
INSERT INTO aly_test VALUES (1,'aaa')
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data char(20) UNIQUE KEY)
INSERT INTO aly_test VALUES (2,'bbb')
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data char(20) PRIMARY KEY)
INSERT INTO aly_test VALUES (3,'ccc')
DESC aly_test
SELECT id,data FROM aly_test
#CREATE TABLE aly_test(id int, data char(20) KEY)
#
#data_type [COMMENT 'string']
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int PRIMARY KEY, data char(20) COMMENT 'test COMMENT')
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
SELECT id,data FROM aly_test
#
#data_type [COLUMN_FORMAT {FIXED|DYNAMIC|DEFAULT}]
#CREATE TABLE aly_test(id int, data char(20) COLUMN_FORMAT FIXED)
#CREATE TABLE aly_test(id int, data char(20) COLUMN_FORMAT DYNAMIC)
#CREATE TABLE aly_test(id int, data char(20) COLUMN_FORMAT DEFAULT)
#
#[STORAGE {DISK|MEMORY|DEFAULT}]
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data char(20) STORAGE DISK)
INSERT INTO aly_test VALUES (1,'aaa')
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data char(20) STORAGE MEMORY)
INSERT INTO aly_test VALUES (2,'bbb')
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data char(20) STORAGE DEFAULT)
INSERT INTO aly_test VALUES (3,'ccc')
DESC aly_test
SELECT id,data FROM aly_test
#
#data_type [reference_definition]
#com.alibaba.druid.sql.parser.ParserException: syntax error
#CREATE TABLE aly_order(id int,test int UNIQUE KEY,data varchar(10) )
#CREATE TABLE aly_test(id int, data int references aly_order (data))
#
#data_type [GENERATED ALWAYS] ...
#ERROR 1064 (HY000): com.alibaba.druid.sql.parser.ParserException: syntax error
#CREATE TABLE aly_test(id int, data1 varchar(10),data2 varchar(10),data3 varchar(20) GENERATED ALWAYS as (concat(data1,' ',data2)))
#
#data_type AS (expression)
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data1 varchar(10),data2 varchar(10),data3 varchar(20) as (concat(data1,' ',data2)))
INSERT INTO aly_test (id,data1,data2)  VALUES (1,'aaa1','aaa2')
DESC aly_test
SELECT id,data1,data2,data3 FROM aly_test
#
#data_type AS (expression) [VIRTUAL | STORED]
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data1 int,data2 int,data3 int as (data1+data2) virtual)
INSERT INTO aly_test (id,data1,data2) VALUES (1,1,1)
DESC aly_test
SELECT id,data1,data2,data3 FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data1 int,data2 int,data3 int as (data1+data2) stored)
INSERT INTO aly_test (id,data1,data2) VALUES (1,1,1)
DESC aly_test
SELECT id,data1,data2,data3 FROM aly_test
#
#data_type AS (expression) [UNIQUE [KEY]]
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data1 int,data2 int,data3 int as (data1+data2) UNIQUE)
INSERT INTO aly_test (id,data1,data2) VALUES (1,1,1)
DESC aly_test
SELECT id,data1,data2,data3 FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data1 int,data2 int,data3 int as (data1+data2) UNIQUE KEY)
INSERT INTO aly_test (id,data1,data2) VALUES (1,1,1)
DESC aly_test
SELECT id,data1,data2,data3 FROM aly_test
#
#data_type AS (expression) [COMMENT comment]
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data1 int,data2 int,data3 int as (data1+data2) UNIQUE KEY COMMENT 'test')
INSERT INTO aly_test (id,data1,data2) VALUES (1,1,1)
DESC aly_test
SELECT id,data1,data2,data3 FROM aly_test
#
#data_type AS (expression) [NOT NULL | NULL]
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data1 int,data2 int,data3 int as (data1+data2) NOT NULL)
INSERT INTO aly_test (id,data1,data2) VALUES (1,1,1)
DESC aly_test
SELECT id,data1,data2,data3 FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data1 int,data2 int,data3 int as (data1+data2) NULL)
INSERT INTO aly_test (id,data1,data2) VALUES (1,1,1)
DESC aly_test
SELECT id,data1,data2,data3 FROM aly_test
#
#data_type AS (expression) STORED [PRIMARY KEY]
#ERROR 3106 (HY000): 'Defining a virtual generated column as PRIMARY KEY' is not SUPPORTED for generated columns
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data1 int,data2 int,data3 int as (data1+data2) STORED PRIMARY KEY)
INSERT INTO aly_test (id,data1,data2) VALUES (1,1,1)
DESC aly_test
#CREATE TABLE aly_test(id int, data1 int,data2 int,data3 int as (data1+data2) KEY)
#
#
#create_definition
#[CONSTRAINT [symbol]] PRIMARY KEY (col_name,...)
#index_col_name not SUPPORTED
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),PRIMARY KEY (id))
INSERT INTO aly_test VALUES (1,'aaa')
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11),test int(11),detail varchar(20),PRIMARY KEY (id,test))
INSERT INTO aly_test VALUES (1,1,'aaa')
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),CONSTRAINT PK_id PRIMARY KEY (id))
INSERT INTO aly_test VALUES (1,1,'aaa')
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),CONSTRAINT PRIMARY KEY (id))
INSERT INTO aly_test VALUES (1,1,'aaa')
DESC aly_test
#ERROR 1064 (HY000): com.alibaba.druid.sql.parser.ParserException: syntax error
#CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),CONSTRAINT PRIMARY KEY (id ASC))
#CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),CONSTRAINT PRIMARY KEY (id DESC))
#
#[CONSTRAINT [symbol]] PRIMARY KEY [index_type] (col_name,...)
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),PRIMARY KEY USING BTREE (id))
INSERT INTO aly_test VALUES (1,1,'aaa')
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),CONSTRAINT PRIMARY KEY USING BTREE (id))
INSERT INTO aly_test VALUES (1,1,'aaa')
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),CONSTRAINT PRIMARY KEY USING HASH (id))
INSERT INTO aly_test VALUES (1,1,'aaa')
DESC aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),CONSTRAINT PK_id PRIMARY KEY USING HASH (id,test))
INSERT INTO aly_test VALUES (1,1,'aaa')
DESC aly_test
#
#[CONSTRAINT [symbol]] PRIMARY KEY [index_type] (col_name,...) [index_option] ...
#index_option not SUPPORTED
#ERROR 1064 (HY000): com.alibaba.druid.sql.parser.ParserException: syntax error
#CREATE TABLE aly_test ( id int(11),detail varchar(20),PRIMARY KEY (id) KEY_BLOCK_SIZE = 10)
#CREATE TABLE aly_test ( id int(11),detail varchar(20),PRIMARY KEY (id) COMMENT 'testing')
#CREATE TABLE aly_test ( id int(11),detail varchar(20),PRIMARY KEY (detail) WITH PARSER ngram)
#CREATE TABLE aly_test ( id int(11),detail varchar(20),PRIMARY KEY (id) USING HASH)
#
#
#KEY [index_name] (index_col_name,...)
#index_col_name:not SUPPORTED INSERT
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),KEY (id) )
INSERT INTO aly_test VALUES (1,'aaa')
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),KEY key_id (id))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),KEY key_id (id,test,detail))
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),KEY key_id (id ASC,test,detail(10) DESC))
#INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW CREATE TABLE aly_test
#
#KEY [index_name] [index_type] (col_name,...)
#INDEX_NAME and INDEX_TYPE at the same time exists
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),KEY key_id using btree (id))
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),KEY key_id using hash (id))
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW CREATE TABLE aly_test
#CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),KEY using hash (id))
#
#KEY [index_name] [index_type] (col_name,...) [index_option] ...
#index_option:not SUPPORTED; exclude: USING {HASH|BTREE}
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),KEY key_id (id) USING BTREE)
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),KEY key_id (id) USING HASH)
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW CREATE TABLE aly_test
#CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),KEY key_id (id) KEY_BLOCK_SIZE=1000)
#CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),KEY key_id (id) COMMENT 'string')
#CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),KEY key_id (id) WITH PARSER ngram)
#
#
#INDEX [index_name](col_name,...)
#index_col_name:not SUPPORTED
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11) NOT NULL ,index (id))
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11) NOT NULL ,test int,index id_index (id,test))
INSERT INTO aly_test VALUES (1,1)
SHOW CREATE TABLE aly_test
#CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),INDEX key_id (id ASC,test,detail(10) DESC))
#
#INDEX [index_name] [index_type] (col_name,...)
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),INDEX key_id USING HASH (id))
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW index FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),INDEX key_id USING BTREE (id))
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW index FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),INDEX USING BTREE (id))
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW index FROM aly_test
#
#INDEX [index_name] [index_type] (col_name,...) [index_option] ...
#index_option:not SUPPORTED; exclude: USING {HASH|BTREE}
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),INDEX key_id (id) USING BTREE)
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW index FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),INDEX key_id (id) USING HASH)
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW index FROM aly_test
#CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),INDEX key_id (id) KEY_BLOCK_SIZE=1000)
#CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),INDEX key_id (id) COMMENT 'string')
#CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),INDEX key_id (id) WITH PARSER ngram)
#
#
#[CONSTRAINT [symbol]] UNIQUE [index_name] (index_col_name,...)
#index_col_name:not SUPPORTED INSERT
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE (id))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE (id ASC,detail DESC))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE un_id (id ASC,detail DESC))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),CONSTRAINT UNIQUE un_id (id,detail))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),CONSTRAINT u_id UNIQUE un_id (id,detail))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
#
#[CONSTRAINT [symbol]] UNIQUE [index_name] {index_type} (index_col_name,...)
#INDEX_NAME and INDEX_TYPE at the same time exists
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE un_id USING HASH (id))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE un_id USING BTREE (id))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
#CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE USING BTREE (id))
#CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE USING HASH (id))
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),CONSTRAINT UNIQUE un_id USING BTREE (id ,detail))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),CONSTRAINT co_id UNIQUE un_id USING BTREE (id ,detail))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
#
#[CONSTRAINT [symbol]] UNIQUE [index_name] [index_type] (index_col_name,...)  [index_option] ...
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE (id,detail) USING HASH)
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
#CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE (id) KEY_BLOCK_SIZE=1000 )
#CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE (id) COMMENT 'string' )
#CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE (id) WITH PARSER ngram )
#
#
#[CONSTRAINT [symbol]] UNIQUE INDEX [index_name] [index_type] (index_col_name,...)  [index_option] ...
#index_col_name:not SUPPORTED INSERT
#INDEX_NAME and INDEX_TYPE at the same time exists
#index_option:not SUPPORTED; exclude: USING {HASH|BTREE}
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE INDEX (id,detail))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE INDEX ind_id (id,detail))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE INDEX ind_id (id ASC,detail DESC))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),CONSTRAINT UNIQUE INDEX unique_id (id,test,detail))
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),CONSTRAINT UNIQUE INDEX (id,test,detail))
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),test int,detail varchar(20),CONSTRAINT u_id UNIQUE INDEX unique_id USING HASH (id ,test,detail))
INSERT INTO aly_test VALUES (1,1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE INDEX ind_id USING HASH(id,detail))
INSERT INTO aly_test VALUES (1,'aaa')
#CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE INDEX USING HASH(id,detail))
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE INDEX idx_id (id,detail) USING HASH )
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE INDEX idx_id (id,detail) USING BTREE)
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
#
#
#[CONSTRAINT [symbol]] UNIQUE KEY [index_name] [index_type] (index_col_name,...)  [index_option] ...
#index_col_name:not SUPPORTED INSERT
#INDEX_NAME and INDEX_TYPE at the same time exists
#index_option:not SUPPORTED; exclude: USING {HASH|BTREE}
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE KEY (id,detail))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE KEY ind_id (id,detail))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
#CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE KEY ind_id (id ASC,detail DESC))
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),CONSTRAINT UNIQUE KEY unique_id (id,detail))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),CONSTRAINT u_id UNIQUE KEY (id,detail))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11) NOT NULL ,CONSTRAINT id_pk UNIQUE KEY (id))
INSERT INTO aly_test VALUES (1)
SHOW index FROM aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE KEY unique_id USING HASH(id,detail ))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
#CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE KEY USING HASH(id,detail ))
#CREATE TABLE aly_test ( id int(11),detail varchar(20),CONSTRAINT UNIQUE KEY USING HASH(id,detail ))
#CREATE TABLE aly_test ( id int(11),detail varchar(20),CONSTRAINT id_pk UNIQUE KEY USING HASH(id,detail))
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE KEY (id,detail) USING HASH)
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),UNIQUE KEY (id,detail) USING BTREE)
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),CONSTRAINT u_id UNIQUE KEY unique_id (id,detail) USING BTREE)
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test ( id int(11),detail varchar(20),CONSTRAINT UNIQUE KEY unique_id USING HASH (id))
INSERT INTO aly_test VALUES (1,'aaa')
SHOW CREATE TABLE aly_test
#CREATE TABLE aly_test ( id int(11),detail varchar(20),CONSTRAINT u_id UNIQUE KEY USING HASH (id))
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11) NOT NULL ,INDEX id_index (id) USING HASH,CONSTRAINT id_pk UNIQUE KEY (id) )
INSERT INTO aly_test VALUES (1)
SHOW index FROM aly_test
#
#
#{FULLTEXT|SPATIAL} [INDEX|KEY] [index_name] (index_col_name,...)
#      [index_option] ...
#CREATE TABLE aly_test (id int, data varchar(10), FULLTEXT INDEX idn_id (data))
#CREATE TABLE aly_test (id int, data varchar(10), SPATIAL INDEX idn_id (data))
#
#
#[CONSTRAINT [symbol]] FOREIGN KEY
#      [index_name] (index_col_name,...) REFERENCES tbl_name (index_col_name,...)
#
#
#CHECK (expr)
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11),data int,detail varchar(20),CHECK (data > 0))
INSERT INTO aly_test VALUES (1,1,'aaa')
SELECT id,data,detail FROM aly_test
SHOW CREATE TABLE aly_test
#
#
#table_option
#ENGINE [=] InnoDB
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int) engine=innodb
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int) engine innodb
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE aly_test
#
#[DEFAULT] COLLATE [=] collation_name
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int) DEFAULT CHARSET=utf8 COLLATE = utf8_bin
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test (id int) CHARSET=utf8 COLLATE = utf8_bin
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id)) DEFAULT CHARACTER SET = utf8
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id)) CHARACTER SET = gbk
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id)) CHARACTER SET gbk
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id)) COLLATE utf8_bin
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id)) DEFAULT COLLATE  gbk_chinese_ci
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE aly_test
#
#COMMENT [=] 'string'
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) COMMENT='aly_test1 TABLE'
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
#
# KEY_BLOCK_SIZE [=] value
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) KEY_BLOCK_SIZE=2
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) KEY_BLOCK_SIZE 2
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
#
#DELAY_KEY_WRITE [=] {0 | 1}
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) DELAY_KEY_WRITE=0
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) DELAY_KEY_WRITE=1
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
#
#ENCRYPTION [=] {'Y' | 'N'}
#not SUPPORTED
#CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) ENCRYPTION = 'Y'
#INSERT INTO aly_test VALUES (1)
#SHOW CREATE TABLE  aly_test
#DROP TABLE aly_test
#CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) ENCRYPTION = 'N'
#INSERT INTO aly_test VALUES (1)
#SHOW CREATE TABLE  aly_test
#
#INSERT_METHOD [=] { NO | FIRST | LAST }
DROP TABLE IF EXISTS aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) INSERT_METHOD = NO
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) INSERT_METHOD = FIRST
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) INSERT_METHOD = LAST
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
#
#ROW_FORMAT [=] {DEFAULT|DYNAMIC|FIXED|COMPRESSED|REDUNDANT|COMPACT}
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) ROW_FORMAT=DEFAULT
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) ROW_FORMAT=DYNAMIC
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
#CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) ROW_FORMAT=FIXED
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) ROW_FORMAT=COMPRESSED
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) ROW_FORMAT=REDUNDANT
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) ROW_FORMAT=COMPACT
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
#
#STATS_AUTO_RECALC [=] {DEFAULT|0|1}
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) STATS_AUTO_RECALC = DEFAULT
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) STATS_AUTO_RECALC = 0
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) STATS_AUTO_RECALC = 1
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
#
#STATS_PERSISTENT [=] {DEFAULT|0|1}
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) STATS_PERSISTENT = DEFAULT
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) STATS_PERSISTENT = 0
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
DROP TABLE aly_test
CREATE TABLE  aly_test ( id int(11) NOT NULL ,PRIMARY KEY (id) ) STATS_PERSISTENT = 1
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
#
#STATS_SAMPLE_PAGES [=] value
DROP TABLE aly_test
CREATE TABLE aly_test( id int(11) NOT NULL ,PRIMARY KEY (id)) STATS_SAMPLE_PAGES = 100
INSERT INTO aly_test VALUES (1)
SHOW CREATE TABLE  aly_test
#
#clear tables
#
DROP TABLE IF EXISTS aly_test