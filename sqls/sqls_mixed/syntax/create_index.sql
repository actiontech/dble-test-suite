#!default_db:schema1
#CREATE [UNIQUE|FULLTEXT] INDEX index_name
#	[index_type]
#	ON tbl_name (index_col_name,...)
#
#index_col_name:
#	col_name [(length)] [ASC | DESC]
#
#index_type
#	USING {BTREE | HASH}
#
#CREATE UNIQUE INDEX index_name [index_type] ON tbl_name (index_col_name,...)
#
DROP TABLE IF EXISTS sharding_4_t1
CREATE TABLE sharding_4_t1(id int,data varchar(10))
CREATE UNIQUE INDEX idx_id ON sharding_4_t1 (id)
SHOW INDEX FROM sharding_4_t1
DROP INDEX idx_id ON sharding_4_t1
SHOW INDEX FROM sharding_4_t1
CREATE UNIQUE INDEX idx_id ON sharding_4_t1 (id,data)
SHOW INDEX FROM sharding_4_t1
DROP INDEX idx_id ON sharding_4_t1
CREATE UNIQUE INDEX idx_id ON sharding_4_t1 (id,data(3) ASC)
SHOW INDEX FROM sharding_4_t1
DROP INDEX idx_id ON sharding_4_t1
CREATE UNIQUE INDEX idx_id USING BTREE ON sharding_4_t1 (id,data(3) ASC)
SHOW INDEX FROM sharding_4_t1
DROP INDEX idx_id ON sharding_4_t1
CREATE UNIQUE INDEX idx_id USING HASH ON sharding_4_t1 (id,data(3) ASC)
SHOW INDEX FROM sharding_4_t1
DROP INDEX idx_id ON sharding_4_t1
#
#CREATE FULLTEXT INDEX index_name ON tbl_name (index_col_name,...)
#
DROP TABLE IF EXISTS sharding_4_t1
CREATE TABLE sharding_4_t1(id int,data varchar(10))
CREATE FULLTEXT INDEX idx_id ON sharding_4_t1 (data(3))
SHOW INDEX FROM sharding_4_t1
#CREATE INDEX index_name ON tbl_name (index_col_name,...)
DROP TABLE IF EXISTS sharding_4_t1
CREATE TABLE sharding_4_t1(id int,data varchar(10))
CREATE INDEX inx_id ON sharding_4_t1 (id)
SHOW INDEX FROM sharding_4_t1
INSERT INTO sharding_4_t1 VALUES (1,'aaa')
DROP INDEX inx_id ON sharding_4_t1
CREATE INDEX inx_id ON sharding_4_t1 (id,data)
SHOW INDEX FROM sharding_4_t1
INSERT INTO sharding_4_t1 VALUES (2,'bbb')
DROP INDEX inx_id ON sharding_4_t1
CREATE INDEX idx_id ON sharding_4_t1 (id ASC,data(3) DESC)
SHOW INDEX FROM sharding_4_t1
INSERT INTO sharding_4_t1 VALUES (5,'eee')
DROP INDEX idx_id ON sharding_4_t1
CREATE INDEX idx_id USING HASH ON sharding_4_t1 (id ASC,data(3) DESC)
SHOW INDEX FROM sharding_4_t1
INSERT INTO sharding_4_t1 VALUES (6,'fff')
#
#CREATE INDEX index_name [index_type] ON tbl_name (index_col_name,...)
DROP INDEX idx_id ON sharding_4_t1
CREATE INDEX inx_id USING BTREE ON sharding_4_t1 (id)
SHOW INDEX FROM sharding_4_t1
INSERT INTO sharding_4_t1 VALUES (3,'ccc')
DROP INDEX inx_id ON sharding_4_t1
CREATE INDEX inx_id USING HASH ON sharding_4_t1 (id)
SHOW INDEX FROM sharding_4_t1
INSERT INTO sharding_4_t1 VALUES (4,'ddd')
DROP INDEX inx_id ON sharding_4_t1
CREATE INDEX inx_id ON sharding_4_t1 (id) comment '测试'
SHOW INDEX FROM sharding_4_t1
#
#clear tables
#
DROP TABLE IF EXISTS sharding_4_t1
