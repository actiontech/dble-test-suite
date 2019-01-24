#!default_db:schema1
#INSERT INTO tbl_name VALUES(expr,expr,...) ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DROP TABLE if exists test1
create TABLE test1 (id int(11),R_REGIONKEY int(11) primary key default 10,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO test1 VALUES(1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,1, 'Eastern','test001'),(3,5, 'Northern','test003'),(2,6, 'Western','test002'),(4,7, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_NAME='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default(R_REGIONKEY)+10
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,9, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#INSERT INTO tbl_name VALUES(expr,expr,...) ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM test1
INSERT INTO test1 VALUES(1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test',R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test',R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,4, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_NAME='test',R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default(R_REGIONKEY)+10,R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 VALUES(1,9, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default,R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#insert ignore into tbl_name VALUES(expr,expr,...) ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM test1
INSERT INTO test1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
INSERT INTO test1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
INSERT INTO test1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
insert ignore into test1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#INSERT INTO tbl_name set col_name=expr,col_name1=default,... ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM test1
INSERT INTO test1 set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_NAME='new',R_COMMENT='new'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_NAME='new',R_COMMENT='new'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#insert ignore into tbl_name set col_name=expr,col_name1=default,... ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM test1
INSERT INTO test1 set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
INSERT INTO test1 set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
insert ignore into test1 set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
insert IGNORE schema2.test2(id,R_REGIONKEY,R_NAME,R_COMMENT) values(13,26,'test','test'),(15,30,'test','test') ON DUPLICATE KEY UPDATE R_REGIONKEY=(select max(R_REGIONKEY) from test1)
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
insert IGNORE schema2.test2(id,R_REGIONKEY,R_NAME,R_COMMENT) values(1,(select min(R_REGIONKEY) from test1) ,'test','test'),(2,14,'test','test') ON DUPLICATE KEY UPDATE R_REGIONKEY=(select max(R_REGIONKEY) from test1)
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM test1
#
#clear tables
#
DROP TABLE if exists test1