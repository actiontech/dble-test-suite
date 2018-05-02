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
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int,data varchar(10))
CREATE UNIQUE INDEX idx_id ON aly_test (id)
SHOW INDEX FROM aly_test
DROP INDEX idx_id ON aly_test
SHOW INDEX FROM aly_test
CREATE UNIQUE INDEX idx_id ON aly_test (id,data)
SHOW INDEX FROM aly_test
DROP INDEX idx_id ON aly_test
CREATE UNIQUE INDEX idx_id ON aly_test (id,data(3) ASC)
SHOW INDEX FROM aly_test
DROP INDEX idx_id ON aly_test
CREATE UNIQUE INDEX idx_id USING BTREE ON aly_test (id,data(3) ASC)
SHOW INDEX FROM aly_test
DROP INDEX idx_id ON aly_test
CREATE UNIQUE INDEX idx_id USING HASH ON aly_test (id,data(3) ASC)
SHOW INDEX FROM aly_test
DROP INDEX idx_id ON aly_test
#
#CREATE FULLTEXT INDEX index_name ON tbl_name (index_col_name,...)
#
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int,data varchar(10))
CREATE FULLTEXT INDEX idx_id ON aly_test (data(3))
SHOW INDEX FROM aly_test
#CREATE INDEX index_name ON tbl_name (index_col_name,...)
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int,data varchar(10))
CREATE INDEX inx_id ON aly_test (id)
SHOW INDEX FROM aly_test
INSERT INTO aly_test VALUES (1,'aaa')
DROP INDEX inx_id ON aly_test
CREATE INDEX inx_id ON aly_test (id,data)
SHOW INDEX FROM aly_test
INSERT INTO aly_test VALUES (2,'bbb')
DROP INDEX inx_id ON aly_test
CREATE INDEX idx_id ON aly_test (id ASC,data(3) DESC)
SHOW INDEX FROM aly_test
INSERT INTO aly_test VALUES (5,'eee')
DROP INDEX idx_id ON aly_test
CREATE INDEX idx_id USING HASH ON aly_test (id ASC,data(3) DESC)
SHOW INDEX FROM aly_test
INSERT INTO aly_test VALUES (6,'fff')
#
#CREATE INDEX index_name [index_type] ON tbl_name (index_col_name,...)
DROP INDEX idx_id ON aly_test
CREATE INDEX inx_id USING BTREE ON aly_test (id)
SHOW INDEX FROM aly_test
INSERT INTO aly_test VALUES (3,'ccc')
DROP INDEX inx_id ON aly_test
CREATE INDEX inx_id USING HASH ON aly_test (id)
SHOW INDEX FROM aly_test
INSERT INTO aly_test VALUES (4,'ddd')
DROP INDEX inx_id ON aly_test
CREATE INDEX inx_id ON aly_test (id) comment '测试'
SHOW INDEX FROM aly_test
DROP TABLE IF EXISTS aly_test